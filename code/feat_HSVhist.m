function [ feature ] = feat_HSVhist( img_path )
%feat_HSVhist 计算图片的 HSV 颜色直方图, 这里暂时处理为只计算 H 通道
%   img     输入为图片
%   feature  输出为图片的特征向量

img = imread(img_path);
img = double(img);
[M,N,C] = size(img);
bin_num = 16;
if C > 1
    img = rgb2hsv(img);
    H = img(:,:,1);
%     S = img(:,:,2);
%     V = img(:,:,3);
    [hh,~] = hist(H(:),bin_num); %H_hist
%     [sh,~] = hist(S(:),bin_num); %S_hist
%     [vh,~] = hist(V(:),bin_num); %V_hsit
    feature = hh/(M*N); %concatenation and normalization
else
    gray = img(:,:,1);
    [gyh,~] = hist(gray(:),bin_num); %gray_hist in case of gray img
    feature = gyh/(M*N);
end

% figure,
% plot(feature);

end


