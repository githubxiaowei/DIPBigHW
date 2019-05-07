function init_data_params()
%load_data 初始化全局变量
%   初始化全局变量：g_bird_data：结构体
%   属性：
%   classes_num：整数类型    鸟类种数 
%   classes：cell类型        种类名称列表
%   data_dir：字符串类型     数据解压后的文件夹
%   feature_dir：字符串类型  数据集特征的文件夹
%   img_path：cell类型       所有图片的路径
%   img_num: 整数类型        图片总数
%   start_idx：数组类型      每一类图片的起始索引
%   train_set：逻辑数组      训练集的索引

    global g_bird_data;

    %类型数目
    g_bird_data.classes_num = 200;

    %解压后的数据文件夹
    g_bird_data.data_dir = [pwd,'/../data'];

    %类型列表
    d = dir([g_bird_data.data_dir,'/CUB_200_2011/images']);
    classes = {d.name};
    g_bird_data.classes = classes(3:end);
    
    %图片路径
    paths = importdata([g_bird_data.data_dir,'/CUB_200_2011/images.txt']);
    g_bird_data.img_num = length(paths);
    g_bird_data.img_paths = cell(g_bird_data.img_num,1);
    g_bird_data.start_idx = zeros(g_bird_data.classes_num+1,1); %多一个处理边界条件
    current_class = 0;
    idx = 1;
    for i = 1:g_bird_data.img_num
        path = split(paths(i),' ');
        g_bird_data.img_paths(i) = cellstr(strcat([g_bird_data.data_dir,'/CUB_200_2011/images/'],path(2)));
        temp = split(path(2),'.');
        temp = str2num(temp{1}); 
        if current_class ~= temp
            current_class = temp;
            g_bird_data.start_idx(current_class) = idx;%每个类别在 img_paths 中的起始位置
        end
        idx = idx+1;
    end
    g_bird_data.start_idx(g_bird_data.classes_num+1)=g_bird_data.img_num+1;
    
    %训练集的索引
    %g_bird_data.img_paths(g_bird_data.train_set)返回训练集
    %g_bird_data.img_paths(~g_bird_data.train_set)返回测试集
    d = importdata([g_bird_data.data_dir,'/CUB_200_2011/train_test_split.txt']);
    g_bird_data.train_set_indices = logical(d(:,2));
    g_bird_data.train_set = g_bird_data.img_paths(g_bird_data.train_set_indices);
    g_bird_data.test_set = g_bird_data.img_paths(~g_bird_data.train_set_indices);
    
    %数据集特征，由 prepare_feature.m 生成特征文件
    g_bird_data.features.dir = [pwd,'/../features'];
    %注册所实现的特征计算函数
    g_bird_data.features.classes = {...
        'RGBhist',...
        'HSVhist',...
        'localRGBhist',...
        'cnn',...
        };
    g_bird_data.features.functions = {...
        @feat_RGBhist,...
        @feat_HSVhist,...
        @feat_localRGBhist,...
        @(x)(x),...
        };
    
    %数据集特征文件路径
    feature_class_num = length(g_bird_data.features.classes);
    g_bird_data.features.paths = cell(feature_class_num,1);
    for i = 1: feature_class_num
        g_bird_data.features.paths{i} = ...
            [g_bird_data.features.dir,'/feat_',g_bird_data.features.classes{i},'.mat'];
    end
    
    %计算特征相似度的方法
    %具体含义 help pdist2
    g_bird_data.features.similarity_type = {...
        'euclidean',...
        'cosine',...
        'seuclidean',...
        'cityblock',...
        'minkowski',...
        'chebychev',...
        'spearman',...
        };
    
    g_bird_data.features.yolo_bbox = [g_bird_data.features.dir,'/yolo_bbox.mat'];

end