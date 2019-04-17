global g_bird_data;

figure
for i = 1:g_bird_data.img_num
    clf;
    img_path= g_bird_data.img_paths{i};
    img = imread(img_path);
    imshow(img),hold on;
    bbox = select_bbox(yolo_request(img_path));

    if size(bbox,1)==0
        pos = [0,0,size(img,2),size(img,1)];
    else
        pos = bbox(1,3:end);
    end
    rectangle('Position',pos,'EdgeColor','r');
    pause(.5);
end



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