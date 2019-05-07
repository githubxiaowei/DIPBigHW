function [ feature ] = feat_localRGBhist( img_path )
%feat_localRGBhist 计算包围盒内的 RGB 特征
%   img_path 输入图片路径

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

img = double(img(pos(2):pos(2)+pos(4),pos(1):pos(1)+pos(3),:));

[M,N,C] = size(img);
bin_num = 16;
if C > 1
    R = img(:,:,1);
    G = img(:,:,2);
    B = img(:,:,3);
    [rh,~] = hist(R(:),bin_num); %R_hist
    [gh,~] = hist(G(:),bin_num); %G_hist
    [bh,~] = hist(B(:),bin_num); %B_hsit
    feature = [rh,gh,bh]/(M*N); %concatenation and normalization
else
    gray = img(:,:,1);
    [gyh,~] = hist(gray(:),bin_num); %gray_hist in case of gray img
    feature = [gyh,gyh,gyh]/(M*N);
end

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