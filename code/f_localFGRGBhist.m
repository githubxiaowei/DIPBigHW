function [feature] = f_localFGRGBhist(img, pos)

img = img(pos(2):(pos(2)+pos(4)),pos(1):(pos(1)+pos(3)),:);

[m,n,l]=size(img);
gausFilter = fspecial('gaussian',[15 15],1.6);%matlab�Դ���˹ģ���˲�
if l>1
R=img(:,:,1);
G=img(:,:,2);
B=img(:,:,3);
template = zeros(size(R));
for i=1:2 %�ɵ����˲�����
    R=imfilter(R,gausFilter,'conv');
    G=imfilter(G,gausFilter,'conv');
    B=imfilter(B,gausFilter,'conv');
end
RL=R(6:end-5,6:end-5);
GL=G(6:end-5,6:end-5);
BL=B(6:end-5,6:end-5);
cannyBWR=edge(RL,'canny',0.33);%canny��Ե���
cannyBWG=edge(GL,'canny',0.33);
cannyBWB=edge(BL,'canny',0.33);
BF=cannyBWB+cannyBWG+cannyBWR;
else 
    R=img(:,:,1);
    template = zeros(size(R));
    for i=1:2 %�ɵ����˲�����
        R=imfilter(R,gausFilter,'conv');
    end
    RL=R(6:end-5,6:end-5);
    cannyBWR=edge(RL,'canny',0.33);%canny��Ե���
    BF=cannyBWR;
end
A=[0 1 1 0;1 1 1 1;1 1 1 1;0 1 1 0];
se1=strel('disk',3);%�����Ǵ���һ���뾶Ϊ3��ƽ̹��Բ�̽ṹԪ��
for i=1:5
    BF=imdilate(BF,A);%����
end
k=0;
Z=zeros(size(R));
Z(6:end-5,6:end-5)=BF;
for i=1:m%���ϵ���
    for j=1:n
        if(Z(i,j)==0) 
            img(i,j,:)= 0;
            template(i,j) = 1;
        else
            break
        end
    end
end
for i=1:m%���ҵ���
    for j=0:n-1
        if(Z(i,n-j)==0)
            img(i,n-j,:)=0;
            template(i,n-j)=1;
        else
            break
        end
    end
end
for j=1:n%���ϵ���
    for i=1:m
        if(Z(i,j)==0)
            img(i,j,:)=0;
            template(i,j)=1;
        else
            break
        end
    end
end

feature = RGBhist(double(img),template);

end



function [feature] = RGBhist(img,template)
    [M,N,C] = size(img);
    bin_num = 16;
    if C > 1
        R = img(:,:,1);
        G = img(:,:,2);
        B = img(:,:,3);
        [rh,~] = hist(R(template==0),bin_num); %R_hist
        [gh,~] = hist(G(template==0),bin_num); %G_hist
        [bh,~] = hist(B(template==0),bin_num); %B_hsit
        feature = [rh,gh,bh]/(M*N - sum(template(:))); %concatenation and normalization
    else
        gray = img(:,:,1);
        [gyh,~] = hist(gray(:),bin_num); %gray_hist in case of gray img
        feature = [gyh,gyh,gyh]/(M*N);
    end
end

