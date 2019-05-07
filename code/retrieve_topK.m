function [ I,t ] = retrieve_topK()
%retrieve_top50 �����ݼ��м�����ǰK������ͼƬ
%   I��cell���� ��СKx1��ÿ��cell����һ��ͼƬ��·��
%   t: ������   ����ʹ�õ�����
K = 50;
global g_state;
global g_bird_data;
tic; %��ʼ��ʱ
f = g_bird_data.features.functions{g_state.task}(g_state.img);% ��ǰͼƬ������
sim_type = g_bird_data.features.similarity_type{g_state.similarity_id};%���ƶȼ��㷽ʽ

load_features = load(g_bird_data.features.paths{g_state.task});% �����û�ѡ�������
features = cell2mat(load_features.features);

[~,Indices] = pdist2(features,f,sim_type,'smallest',K);

I = g_bird_data.img_paths(Indices);

t = toc;
t = roundn(t,-3);

end

