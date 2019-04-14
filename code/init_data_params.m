function init_data_params()
%load_data ��ʼ��ȫ�ֱ���
%   ��ʼ��ȫ�ֱ�����g_bird_data���ṹ��
%   ���ԣ�
%   classes_num����������    �������� 
%   classes��cell����        ���������б�
%   data_dir���ַ�������     ���ݽ�ѹ����ļ���
%   feature_dir���ַ�������  ���ݼ��������ļ���
%   img_path��cell����       ����ͼƬ��·��
%   img_num: ��������        ͼƬ����
%   start_idx����������      ÿһ��ͼƬ����ʼ����
%   train_set���߼�����      ѵ����������

    global g_bird_data;

    %������Ŀ
    g_bird_data.classes_num = 200;

    %��ѹ��������ļ���
    g_bird_data.data_dir = '../data';

    %�����б�
    d = dir([g_bird_data.data_dir,'/CUB_200_2011/images']);
    classes = {d.name};
    g_bird_data.classes = classes(3:end);
    
    %ͼƬ·��
    paths = importdata([g_bird_data.data_dir,'/CUB_200_2011/images.txt']);
    g_bird_data.img_num = length(paths);
    g_bird_data.img_paths = cell(g_bird_data.img_num,1);
    g_bird_data.start_idx = zeros(g_bird_data.classes_num,1);
    current_class = 0;
    idx = 1;
    for i = 1:g_bird_data.img_num
        path = split(paths(i),' ');
        g_bird_data.img_paths(i) = cellstr(strcat([g_bird_data.data_dir,'/CUB_200_2011/images/'],path(2)));
        temp = split(path(2),'.');
        temp = str2num(temp(1).char);
        if current_class ~= temp
            current_class = temp;
            g_bird_data.start_idx(current_class) = idx;%ÿ������� img_paths �е���ʼλ��
        end
        idx = idx+1;
    end
    
    %ѵ����������
    %g_bird_data.img_paths(g_bird_data.train_set)����ѵ����
    %g_bird_data.img_paths(~g_bird_data.train_set)���ز��Լ�
    d = importdata([g_bird_data.data_dir,'/CUB_200_2011/train_test_split.txt']);
    g_bird_data.train_set = logical(d(:,2));
    
    %���ݼ��������� prepare_feature.m ���������ļ�
    g_bird_data.features.dir = '../features';
    g_bird_data.features.RGBhist = [g_bird_data.features.dir,'/feat_RGBhist.mat'];

end