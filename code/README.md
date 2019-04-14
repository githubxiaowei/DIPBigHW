## 代码说明

### 图形界面

- interface.m 定义 GUI 运行过程中的一系列回调函数
- interface.fig 图形界面的布局

### 程序初始化

- init_data_params.m 初始化与数据集相关的全局变量
- init_state_params.m 初始化与程序状态相关的全局变量
- prepare_feature.m 需要在用户界面运行前**手动执行**，提前计算数据库中所有图片的特征，加快检索速度

### 基本函数

- retrie_top50.m 从数据库中检索出前 50 张最相似的图片
- feat_RGBhist.m 计算图片的 RGB 直方图特征