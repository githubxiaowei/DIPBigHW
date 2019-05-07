## 代码说明

### 图形界面

- interface.m 定义 GUI 运行过程中的一系列回调函数
- interface.fig 图形界面的布局

### 程序初始化

- init_data_params.m 初始化与数据集相关的全局变量
- init_state_params.m 初始化与程序状态相关的全局变量
- prepare_feature.m 需要在用户界面运行前**手动执行**，提前计算数据库中所有图片的特征，加快检索速度
- prepare_bbox.m 提前计算所有图片的 bbox，用于计算 localRGBhist 特征

### 基本函数

- retrieve_topK.m 从数据库中检索出前 K=50 张最相似的图片
- feat_RGBhist.m 计算图片的 RGB 直方图特征
- feat_HSVhist.m 计算图片的 HSV 直方图特征
- feat_localRGBhist.m 计算目标区域的 RGB 直方图特征
- py_request.m 向 python 后台进程（port：54321）发送图片路径，返回目标检测的包围盒结果
- py_server/py_server.py 在后台运行的服务器，通过 54321 端口和前端的 py_request.m 交互，接收前端发送的图片地址，返回 bbox 或者 最相似图片列表
