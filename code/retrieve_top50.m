function [ I,t ] = retrieve_top50()
%retrieve_top50 从数据集中检索出前五十张相似图片
%   I：cell类型 大小50x1，每个cell包含一张图片的路径
%   t: 浮点数   检索使用的秒数

global g_state;
global g_bird_data;
tic; %开始计时
f = g_bird_data.features.functions{g_state.task}(g_state.img);% 当前图片的特征

load_features = load(g_bird_data.features.paths{g_state.task});% 根据用户选择的特征
features = cell2mat(load_features.features);

[~,Indices] = pdist2(features,f,'euclidean','smallest',50);

I = g_bird_data.img_paths(Indices);

t = toc;
t = roundn(t,-3);

end

