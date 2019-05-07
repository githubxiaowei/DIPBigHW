function [ I,t,APs ] = retrieve_topK()
%retrieve_top50 从数据集中检索出前K张相似图片
%   I：cell类型 大小Kx1，每个cell包含一张图片的路径
%   t: 浮点数   检索使用的秒数
K = 50;
global g_state;
global g_bird_data;
tic; %开始计时
f = g_bird_data.features.functions{g_state.task}(g_state.img);% 当前图片的特征
sim_type = g_bird_data.features.similarity_type{g_state.similarity_id};%相似度计算方式

load_features = load(g_bird_data.features.paths{g_state.task});% 根据用户选择的特征
features = cell2mat(load_features.features);
features = features(g_bird_data.train_set_indices,:); % 训练集特征

[~,Indices] = pdist2(features,f,sim_type,'smallest',K);

I = g_bird_data.train_set(Indices); % 训练集中的相似图片

t = toc;
t = roundn(t,-3);

APs = [0.0 0.0 0.0 0.0];
if ~strcmp('nan',g_state.img_class)
    bool_list = zeros(K,1);
    for i = 1:K
        bool_list(i) = strcmp(extract_class(I{i}),g_state.img_class);
    end
    APs(1) = AP(bool_list(1:1));
    APs(2) = AP(bool_list(1:5));
    APs(3) = AP(bool_list(1:10));
    APs(4) = AP(bool_list(1:50));
end
end

function [class] = extract_class(path)
%extract_class 从图片路径解析出图片类型
pieces = split(path,'/');
p = split(pieces(end-1),'.');
class = p(1);
end

function [ap] = AP(bool_list)
M = sum(bool_list);
if M == 0
    ap = 0.000000001;
    return;
end
t = cumsum(ones(length(bool_list),1));
p = cumsum(bool_list).*bool_list./t;
ap = sum(p)/M;
end