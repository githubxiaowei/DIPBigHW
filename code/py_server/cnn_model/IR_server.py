#!/usr/bin/env python
# coding: utf-8


import keras
from keras.models import Sequential, Model
from keras.layers import Dense, Dropout, Activation, Flatten
from keras.layers import Conv2D, MaxPooling2D
import numpy as np
import cv2


def normalize(a):
    return np.diag(1/np.sqrt(np.sum(np.square(a),axis=1))).dot(a) #归一化

# 从 v_set 中找出和 v 最相似的 k 个元素
def topK(v, v_set, k):
    dist = np.array([distance(v,i) for i in v_set])
    idx = np.argpartition(dist, k)[:k]
    return idx[np.argsort(dist[idx])]

def distance(a,b):
    return -a.dot(b) # 余弦距离
    # return np.sum(np.square(a-b)) # 欧式距离

def retrieve(x,k):
    featone = feature_model.predict(np.expand_dims(x, axis=0))
    return topK(featone[0],feature_vecs_database,k)

num_classes = 200

# **CNN**: 3个卷积层+2个全连接层

model = Sequential()

model.add(Conv2D(32, (3, 3), padding='same', strides=2, input_shape=[64,64,3]))
model.add(Activation('relu'))
model.add(MaxPooling2D(pool_size=(2, 2)))
model.add(Dropout(0.25))

model.add(Conv2D(64, (3, 3), padding='same'))
model.add(Activation('relu'))
model.add(MaxPooling2D(pool_size=(2, 2)))
model.add(Dropout(0.25))

model.add(Conv2D(128, (3, 3), padding='same'))
model.add(Activation('relu'))
model.add(MaxPooling2D(pool_size=(2, 2)))
model.add(Dropout(0.25))

model.add(Flatten())

model.add(Dense(512, activation='relu', name='feat_vec'))

model.add(Dense(num_classes))
model.add(Activation('softmax'))

model.summary()

# initiate optimizer
sgd = keras.optimizers.SGD(lr=0.001, decay=1e-6, momentum=0.9, nesterov=True)

# train the model using RMSprop
model.compile(loss='categorical_crossentropy', optimizer=sgd, metrics=['accuracy'])

weights_path = 'bird.best.hdf5'
model.load_weights(weights_path)

feature_model = Model(inputs=model.input, outputs=model.get_layer('feat_vec').output)

feature_vecs = np.load('feature_vecs.npz')
feature_vecs_train, feature_vecs_test = normalize(feature_vecs['train']),normalize(feature_vecs['test'])

# 将训练集作为 检索库
feature_vecs_database = feature_vecs_train

img_path = 'D:\\Download\\DIPBigHW\\data\\CUB_200_2011\\' \
           'images\\002.Laysan_Albatross\\Laysan_Albatross_0006_702.jpg'
img = cv2.resize(cv2.imread(img_path),(64,64))
img = np.array(img).astype('float32')/255

print(retrieve(img,5))



