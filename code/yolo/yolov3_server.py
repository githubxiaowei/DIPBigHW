# -- encoding=gbk --
import cv2
import numpy as np
import os
import socket
import time


with open('yolo_model/coco.names','r') as file:     # 这是读取所有种类的名字
	LABELS = file.read().splitlines()

args = {
    "yolo": "yolo_model",   #.weights 和 .cfg 文件所在的目录
    "confidence": 0.5,              # minimum bounding box confidence
    "threshold": 0.3,               # NMS threshold
}

# derive the paths to the YOLO weights and model configuration
weightsPath = os.path.sep.join([args["yolo"], "yolov3.weights"])
configPath = os.path.sep.join([args["yolo"], "yolov3.cfg"])
 
# load YOLO object detector trained on COCO dataset (80 classes)
print("loading YOLO from disk...")
net = cv2.dnn.readNetFromDarknet(configPath, weightsPath)


sock = socket.socket(socket.AF_INET,socket.SOCK_STREAM)  # IPV4,TCP协议
sock.bind(('127.0.0.1',54321))  # 绑定ip和端口，bind接受的是一个元组
sock.listen(1)  # 置监听数量
print("start server")

while True:
	connection, address = sock.accept()
	print()
	print("client ip is:", address)
	buf = connection.recv(4096)
	bufstr = buf.decode('utf8')
	print('recieved:',bufstr)
	# load our input image and grab its spatial dimensions
	image = cv2.imread(bufstr)
	(H, W) = image.shape[:2]

	# determine only the *output* layer names that we need from YOLO
	ln = net.getLayerNames()
	ln = [ln[i[0] - 1] for i in net.getUnconnectedOutLayers()]

	# construct a blob from the input image and then perform a forward
	# pass of the YOLO object detector, giving us our bounding boxes and
	# associated probabilities
	blob = cv2.dnn.blobFromImage(image, 1 / 255.0, (416, 416),
		swapRB=True, crop=False)
	net.setInput(blob)
	start = time.time()
	layerOutputs = net.forward(ln)
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
			if confidence > args["confidence"]:
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

	idxs = cv2.dnn.NMSBoxes(boxes, confidences, args["confidence"],
		args["threshold"])

	text = "["
	# ensure at least one detection exists
	if len(idxs) > 0:
		# loop over the indexes we are keeping
		for i in idxs.flatten():
			# extract the bounding box coordinates
			(x, y) = (boxes[i][0], boxes[i][1])
			(w, h) = (boxes[i][2], boxes[i][3])
			print("{}:{:.4f}".format(LABELS[classIDs[i]], confidences[i]))
			text += "[{},{:.4f},{},{},{},{}];".format(classIDs[i],  confidences[i],x,y,w,h)
			# time.sleep(1)

	text+="]"
	print('send:', text)
	connection.send(bytes(text, encoding="utf8"))  # 发送数据
	connection.close()  # 关闭连接
sock.close()  # 关闭服务器
