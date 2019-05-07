# -- encoding=gbk --
import cv2
import numpy as np
import os
import socket
import time
import keras
from keras.models import Sequential, Model
from keras.layers import Dense, Dropout, Activation, Flatten
from keras.layers import Conv2D, MaxPooling2D


class YOLO_server:
	def __init__(self):
		with open('yolo_model/coco.names','r') as file:     # 这是读取所有种类的名字
			self.LABELS = file.read().splitlines()

		self.args = {
			"yolo": "yolo_model",   #.weights 和 .cfg 文件所在的目录
			"confidence": 0.5,              # minimum bounding box confidence
			"threshold": 0.3,               # NMS threshold
		}

		# derive the paths to the YOLO weights and model configuration
		self.weightsPath = os.path.sep.join([self.args["yolo"], "yolov3.weights"])
		self.configPath = os.path.sep.join([self.args["yolo"], "yolov3.cfg"])

		# load YOLO object detector trained on COCO dataset (80 classes)
		print("loading YOLO from disk...")
		self.net = cv2.dnn.readNetFromDarknet(self.configPath, self.weightsPath)

	def get_bbox(self, img_path):
		image = cv2.imread(img_path)
		(H, W) = image.shape[:2]

		# determine only the *output* layer names that we need from YOLO
		ln = self.net.getLayerNames()
		ln = [ln[i[0] - 1] for i in self.net.getUnconnectedOutLayers()]

		# construct a blob from the input image and then perform a forward
		# pass of the YOLO object detector, giving us our bounding boxes and
		# associated probabilities
		blob = cv2.dnn.blobFromImage(image, 1 / 255.0, (416, 416),
			swapRB=True, crop=False)
		self.net.setInput(blob)
		start = time.time()
		layerOutputs = self.net.forward(ln)
		end = time.time()

		# show timing information on YOLO
		print("YOLO took {:.6f} seconds".format(end - start))

		boxes, confidences, classIDs = [], [], []
		# loop over each of the layer outputs
		for output in layerOutputs:
			# loop over each of the detections
			for detection in output:
				# extract the class ID and confidence of the current object detection
				scores = detection[5:]
				classID = np.argmax(scores)
				confidence = scores[classID]

				# filter out weak predictions by ensuring the detected
				# probability is greater than the minimum probability
				if confidence > self.args["confidence"]:
					# scale the bounding box coordinates back relative to the size of the image,
					# keeping in mind that YOLO actually returns the center (x, y)-coordinates
					# of the bounding box followed by the boxes' width and height
					box = detection[0:4] * np.array([W, H, W, H])
					(centerX, centerY, width, height) = box.astype("int")

					# use the center (x, y)-coordinates to derive the top and left corner of the bounding box
					x = int(centerX - (width / 2))
					y = int(centerY - (height / 2))

					# update our list of bounding box coordinates, confidences, and class IDs
					boxes.append([x, y, int(width), int(height)])
					confidences.append(float(confidence))
					classIDs.append(classID)

		idxs = cv2.dnn.NMSBoxes(boxes, confidences, self.args["confidence"],
			self.args["threshold"])

		text = "["
		# ensure at least one detection exists
		if len(idxs) > 0:
			# loop over the indexes we are keeping
			for i in idxs.flatten():
				# extract the bounding box coordinates
				(x, y) = (boxes[i][0], boxes[i][1])
				(w, h) = (boxes[i][2], boxes[i][3])
				print("{}:{:.4f}".format(self.LABELS[classIDs[i]], confidences[i]))
				text += "[{},{:.4f},{},{},{},{}];".format(classIDs[i],  confidences[i],x,y,w,h)
				# time.sleep(1)

		text+="]"
		return text


class CNN_server:
	def __init__(self):
		self.num_classes = 200

		# **CNN**: 3个卷积层+2个全连接层

		self.model = Sequential()

		self.model.add(Conv2D(32, (3, 3), padding='same', strides=2, input_shape=[64, 64, 3]))
		self.model.add(Activation('relu'))
		self.model.add(MaxPooling2D(pool_size=(2, 2)))
		self.model.add(Dropout(0.25))

		self.model.add(Conv2D(64, (3, 3), padding='same'))
		self.model.add(Activation('relu'))
		self.model.add(MaxPooling2D(pool_size=(2, 2)))
		self.model.add(Dropout(0.25))

		self.model.add(Conv2D(128, (3, 3), padding='same'))
		self.model.add(Activation('relu'))
		self.model.add(MaxPooling2D(pool_size=(2, 2)))
		self.model.add(Dropout(0.25))

		self.model.add(Flatten())

		self.model.add(Dense(512, activation='relu', name='feat_vec'))

		self.model.add(Dense(self.num_classes))
		self.model.add(Activation('softmax'))

		self.model.summary()

		# initiate optimizer
		sgd = keras.optimizers.SGD(lr=0.001, decay=1e-6, momentum=0.9, nesterov=True)

		# train the model using RMSprop
		self.model.compile(loss='categorical_crossentropy', optimizer=sgd, metrics=['accuracy'])

		weights_path = 'cnn_model/bird.best.hdf5'
		self.model.load_weights(weights_path)

		self.feature_model = Model(inputs=self.model.input, outputs=self.model.get_layer('feat_vec').output)

		feature_vecs = np.load('cnn_model/feature_vecs.npz')
		# 将训练集作为 检索库
		self.feature_vecs_database = self.normalize(feature_vecs['train'])

	def normalize(self, a):
		return np.diag(1 / np.sqrt(np.sum(np.square(a), axis=1))).dot(a)  # 归一化

	# 从 v_set 中找出和 v 最相似的 k 个元素
	def topK(self, v, v_set, k):
		dist = np.array([self.distance(v, i) for i in v_set])
		idx = np.argpartition(dist, k)[:k]
		return idx[np.argsort(dist[idx])]

	def distance(self, a, b):
		return -a.dot(b)  # 余弦距离

	def retrieve(self,x, k):
		featone = self.feature_model.predict(np.expand_dims(x, axis=0))
		return self.topK(featone[0], self.feature_vecs_database, k)

	def get_list(self, img_path):
		img = cv2.resize(cv2.imread(img_path), (64, 64))
		img = np.array(img).astype('float32') / 255
		idx_list = self.retrieve(img, 50)
		text = "["
		for i in idx_list:
			text += str(i) + ","
		text += "]"
		return text

if __name__ == '__main__':
	yolo_server = YOLO_server()
	cnn_server = CNN_server()
	sock = socket.socket(socket.AF_INET,socket.SOCK_STREAM)  # IPV4,TCP协议
	sock.bind(('127.0.0.1',54321))  # 绑定ip和端口，bind接受的是一个元组
	sock.listen(1)  # 置监听数量
	print("start server ... waiting for requests ... ")

	while True:
		connection, address = sock.accept()
		print()
		print("client ip is:", address)
		buf = connection.recv(4096)
		bufstr = buf.decode('utf8')
		print('recieved:',bufstr)
		tag = bufstr[0]
		img_path = bufstr[1:]

		if tag == 'B':
			text = yolo_server.get_bbox(img_path)
		elif tag == 'L':
			text = cnn_server.get_list(img_path)
		else:
			text = ''

		print('send:', text)
		connection.send(bytes(text, encoding="utf8"))  # 发送数据
		connection.close()  # 关闭连接
	sock.close()  # 关闭服务器
