function [ I ] = retrieve_top50(method)
%retrieve_top50 从数据集中检索出前五十张相似图片
%   method：整数类型 检索方法
%   I：cell类型 大小50x1，每个cell包含一张图片的路径
%   
global g_state;
f = feat_RGBhist(g_state.img);% 当前图片的特征
global g_bird_data;
load_features = load(g_bird_data.features.RGBhist);
features = cell2mat(load_features.features);
[D,Indices] = pdist2(features,f,'euclidean','smallest',50);

I = g_bird_data.img_paths(Indices);

end

