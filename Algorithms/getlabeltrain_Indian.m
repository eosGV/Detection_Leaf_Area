function [labeled, unlabeled]= getlabeltrain_Indian(groundtruth, num)
%
% Randomly select the labeled training samples of hyperspectral data
%
% Input:
%      groundtruth: ground truth of the oringinal hyperspectral data
%      num: the number of the labeled training samples you want to select
%
% Output:
%      labeled: the labeled mask 
%      unlabeled: the rest of labeled samples in the ground truth
B= groundtruth;

[x1,y1]=find(groundtruth==1);
[x2,y2]=find(groundtruth==2);
[x3,y3]=find(groundtruth==3);
[x4,y4]=find(groundtruth==4);
[x5,y5]=find(groundtruth==5);
[x6,y6]=find(groundtruth==6);
[x7,y7]=find(groundtruth==7);
% [x8,y8]=find(groundtruth==8);
% [x9,y9]=find(groundtruth==9);
% [x10,y10]=find(groundtruth==10);
% [x11,y11]=find(groundtruth==11);
% [x12,y12]=find(groundtruth==12);
% [x13,y13]=find(groundtruth==13);
% [x14,y14]=find(groundtruth==14);
%[x15,y15]=find(groundtruth==15);
%[x16,y16]=find(groundtruth==16);

%  save DATAposxclas.mat x1 y1 x2 y2 x3 y3 x4 y4 x5 y5 x6 y6   -v7.3;

Tx=[];Ty=[];
xx1=randperm(size(x1,1));
for i=1:num
    Tx=[Tx,x1(xx1(i))];
    Ty=[Ty,y1(xx1(i))];
end

xx2=randperm(size(x2,1));
for i=1:num
    Tx=[Tx,x2(xx2(i))];
    Ty=[Ty,y2(xx2(i))];
end


xx3=randperm(size(x3,1));
for i=1:num
    Tx=[Tx,x3(xx3(i))];
    Ty=[Ty,y3(xx3(i))];
end

xx4=randperm(size(x4,1));
for i=1:num
    Tx=[Tx,x4(xx4(i))];
    Ty=[Ty,y4(xx4(i))];
end

xx5=randperm(size(x5,1));
for i=1:num
 Tx=[Tx,x5(xx5(i))];
 Ty=[Ty,y5(xx5(i))];
end

xx6=randperm(size(x6,1));
for i=1:num
 Tx=[Tx,x6(xx6(i))];
 Ty=[Ty,y6(xx6(i))];
end

xx7=randperm(size(x7,1));
for i=1:num
 Tx=[Tx,x7(xx7(i))];
 Ty=[Ty,y7(xx7(i))];
end


T=[];
for i=1:size(Tx,2)
    T=[T,groundtruth(Tx(i),Ty(i))];
    groundtruth(Tx(i),Ty(i))=0;    
end
unlabeled=groundtruth;
labeled=B-groundtruth;
