function [ I ] = retrieve_top50(method)
%retrieve_top50 �����ݼ��м�����ǰ��ʮ������ͼƬ
%   method���������� ��������
%   I��cell���� ��С50x1��ÿ��cell����һ��ͼƬ��·��
%   
global g_state;
f = feat_RGBhist(g_state.img);% ��ǰͼƬ������
global g_bird_data;
load_features = load(g_bird_data.features.RGBhist);
features = cell2mat(load_features.features);
[D,Indices] = pdist2(features,f,'euclidean','smallest',50);

I = g_bird_data.img_paths(Indices);

end

