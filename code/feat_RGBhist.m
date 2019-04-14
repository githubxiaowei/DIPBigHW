function [ feature ] = feat_RGBhist( img )
%feat_RGBhist ����ͼƬ�� RGB ��ɫֱ��ͼ
%   img     ����ΪͼƬ
%   feature  ���ΪͼƬ����������

img = double(img);
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

% plot(feature)

end

