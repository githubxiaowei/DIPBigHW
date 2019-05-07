clear;
close all;
init_data_params();
global g_bird_data;
all_bbox = cell(g_bird_data.img_num,1);
figure
h = waitbar(0,'preparing yolo\_bbox for database');
for i = 1:g_bird_data.img_num
    clf;
    img_path= g_bird_data.img_paths{i};
    img = imread(img_path);
    imshow(img);
    bbox = select_bbox(py_request('B',img_path));
    if size(bbox,1)==0
        pos = [1,1,size(img,2)-1,size(img,1)-1];
    else
        pos = bbox(1,3:end);
        pos(1) = max(1,pos(1));
        pos(2) = max(1,pos(2));
        pos(3) = min(size(img,2)-pos(2),pos(3));
        pos(4) = min(size(img,1)-pos(1),pos(4));
    end
    all_bbox{i} = pos;
    rectangle('Position',pos,'EdgeColor','r');
    pause(.5);
    waitbar(i/g_bird_data.img_num);
end
close(h);
save(g_bird_data.features.yolo_bbox,'all_bbox');


function [bbox] = select_bbox(bbox)
    if size(bbox,1) > 1
        bird_row = find(bbox(:,1)==14);
        if ~isempty(bird_row)
            bbox = bbox(bird_row(1),:); 
        else
            bbox = bbox(1,:);
        end
    end
end
