function [ I,t ] = retrieve_top50()
%retrieve_top50 �����ݼ��м�����ǰ��ʮ������ͼƬ
%   I��cell���� ��С50x1��ÿ��cell����һ��ͼƬ��·��
%   t: ������   ����ʹ�õ�����

global g_state;
global g_bird_data;
tic; %��ʼ��ʱ
f = g_bird_data.features.functions{g_state.task}(g_state.img);% ��ǰͼƬ������

load_features = load(g_bird_data.features.paths{g_state.task});% �����û�ѡ�������
features = cell2mat(load_features.features);

[~,Indices] = pdist2(features,f,'euclidean','smallest',50);

I = g_bird_data.img_paths(Indices);

t = toc;
t = roundn(t,-3);

end

