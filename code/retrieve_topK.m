function [ I,t,APs ] = retrieve_topK()
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
features = features(g_bird_data.train_set_indices,:); % ѵ��������

[~,Indices] = pdist2(features,f,sim_type,'smallest',K);

I = g_bird_data.train_set(Indices); % ѵ�����е�����ͼƬ

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
%extract_class ��ͼƬ·��������ͼƬ����
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