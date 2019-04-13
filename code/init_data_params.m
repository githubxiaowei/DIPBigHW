function init_params()
%load_data 初始化全局变量
%   初始化全局变量：g_bird_data：结构体
%   属性：
%   classes_num：整数类型 鸟类种数 
%   classes：cell类型     种类名称列表
%   data_dir：字符串类型  数据解压后的文件夹
%   img_path：cell类型    所有图片的路径
%   img_num: 整数类型     图片总数
    global g_bird_data;

    %类型数目
    g_bird_data.classes_num = 200;

    %解压后的数据文件夹
    g_bird_data.data_dir = '../data';

    %类型列表
    d = dir([g_bird_data.data_dir,'/CUB_200_2011/images']);
    classes = {d.name};
    g_bird_data.classes = classes(3:end);
    
    %图片路径
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
            g_bird_data.start_idx(current_class) = idx;
        end
        idx = idx+1;
    end
    
    %每个类别在 img_paths 中的起始位置
 

end