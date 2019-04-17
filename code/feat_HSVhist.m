function [ feature ] = feat_HSVhist( img_path )
%feat_HSVhist ����ͼƬ�� HSV ��ɫֱ��ͼ, ������ʱ����Ϊֻ���� H ͨ��
%   img     ����ΪͼƬ
%   feature  ���ΪͼƬ����������

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


