# -- encoding=gbk --
import cv2
import numpy as np
import os
import socket
import time
import tensorflow as tf



class YOLO_server:
	def __init__(self):
		with open('yolo_model/coco.names','r') as file:     # ���Ƕ�ȡ�������������
			self.LABELS = file.read().splitlines()

		self.args = {
			"yolo": "yolo_model",   #.weights �� .cfg �ļ����ڵ�Ŀ¼
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

from tensorflow.contrib.slim.nets import vgg

class CNN_server:
	def __init__(self):
		self.num_classes = 200
		IMAGE_SIZE = 224

		train_log_dir = 'cnn_model/vgg_16_2016_08_28/slim_fine_tune'
		feature_vecs = np.load('cnn_model/vgg_feature_vecs.npz')
		# ��ѵ������Ϊ ������
		self.feature_vecs_database = self.normalize(feature_vecs['train'])

		assert (tf.gfile.Exists(train_log_dir) == True)

		self.image_holder = tf.placeholder(tf.float32, [None, IMAGE_SIZE, IMAGE_SIZE, 3])
		self.is_training = tf.placeholder(dtype=tf.bool)

		# ����vgg16����  ����붳�����в㣬����ָ��slim.conv2d�е� trainable=False
		_, self.end_points = vgg.vgg_16(self.image_holder, is_training=self.is_training, num_classes=self.num_classes)

		# ���ڱ�������ļ�
		save = tf.train.Saver()

		# �ָ�ģ��
		self.sess = tf.Session()
		self.sess.run(tf.global_variables_initializer())

		# �������ļ����ļ�
		ckpt = tf.train.latest_checkpoint(train_log_dir)
		if ckpt != None:
			save.restore(self.sess, ckpt)
			print('�����ϴ�ѵ��������ģ�ͣ�')
		else:
			assert (False)

	def compute_feat(self, x):
		layer_outputs = self.sess.run([self.end_points],
									  feed_dict={self.image_holder: x, self.is_training: False})
		feature = layer_outputs[0]['vgg_16/fc7'].squeeze()
		return feature

	def normalize(self, a):
		return a / np.sqrt(np.sum(np.square(a)))  # ��һ��

	# �� v_set ���ҳ��� v �����Ƶ� k ��Ԫ��
	def topK(self, v, v_set, k):
		dist = np.array([self.distance(v, i) for i in v_set])
		idx = np.argpartition(dist, k)[:k]
		return idx[np.argsort(dist[idx])]

	def distance(self, a, b):
		return -a.dot(b)  # ���Ҿ���

	def retrieve(self,x, k):
		featone = self.compute_feat(np.expand_dims(x, axis=0))
		return self.topK(self.normalize(featone), self.feature_vecs_database, k)

	def get_list(self, img_path):
		img = cv2.resize(cv2.imread(img_path), (224, 224))
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
	sock = socket.socket(socket.AF_INET,socket.SOCK_STREAM)  # IPV4,TCPЭ��
	sock.bind(('127.0.0.1',54321))  # ��ip�Ͷ˿ڣ�bind���ܵ���һ��Ԫ��
	sock.listen(1)  # �ü�������
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
		connection.send(bytes(text, encoding="utf8"))  # ��������
		connection.close()  # �ر�����
	sock.close()  # �رշ�����
