function [feature] = feat_localFGRGBhist(img_path)

img = imread(img_path);

bbox = select_bbox(py_request('B',img_path));
if size(bbox,1)==0
    pos = [1,1,size(img,2)-1,size(img,1)-1];
else
    pos = bbox(1,3:end);
    pos(1) = max(1,pos(1));
    pos(2) = max(1,pos(2));
    pos(3) = min(size(img,2)-pos(1),pos(3));
    pos(4) = min(size(img,1)-pos(2),pos(4));
end
feature = f_localFGRGBhist(img,pos);
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
