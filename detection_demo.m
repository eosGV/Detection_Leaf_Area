% % % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  
% %                                                                  
% %                 Demo detection leaf area
% %    
% %                             
% %           
% %       Copyright notes
% %       Author: Gladys, Ghent University, Belgium
% %       Date: 05/12/2017
% %
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clc
clear all
warning('on','MATLAB:RandStream:ActivatingLegacyGenerators') 
warning('on','MATLAB:RandStream:ReadingInactiveLegacyGeneratorState')

%% add path in
p = fileparts(mfilename('fullpath'));
addpath(fullfile(p,'Algorithms'));
addpath(fullfile(p,'Images'));
%addpath(fullfile(p,'granulometry'));
%addpath(fullfile(p,'fastmorphology'));
%addpath(fullfile(p,'svm'))
%addpath(fullfile(p,'libsvm-mat-2.89-3'));
%% parameters for different methods
% the classifier used to classification
classifier_type='svm';
%type_g='partialreconstruction'; %'geodesic';%'euclidean';% 
type_se='disk';%,'square';%'line';% octagon, dodecagon, hexadecagon,  bresenhamline
%number of scales for morphological profiles
num_scales=4; 
%% load the hyperspectral data set and ground truth
load banTraceLR_0503enf; %load CuboHSI3; 

rand('state',4711007);%6
%RGB=HR_RGB;
[rows,cols,bands]=size(LR_HSI);
%[Erows,Ecols,~]=size(RGB);
%%%%%%%%%%%%%Image Test%%%%%%%%%%%%%%%%%
load banTraceLR_0529enf; %groundtruth de malla, fondo, base, midribs
[rowsT,colsT,bandsT]=size(LR_HSI2);

%%%%%%%%%%%TrainLabels%%%%%%%%%%%%%%
load banTraceLR_0503enf_3;
testlabels=TM;
figure;imagesc(testlabels)
%Train_Pavia;%getlabelmatrix
trainlabels=double(getlabeltrain_Indian(testlabels,3));
% the number of the class
class_num=7;

%original
spectraldata=double(LR_HSI); 
%test
spectraldataTest=double(LR_HSI2);

% display the original image
   figure;imshow(spectraldata(:,:,1),[]);
   figure;imagesc(spectraldata(:,:,300));
   
% display test image
 
   figure;imshow(spectraldataTest(:,:,1),[]);
   figure;imagesc(spectraldataTest(:,:,300));
   

%% Overall classification accuracy and Average classification accuracy for different methods
OAraw=0;
AAraw=0;
Kparaw=0;

OArawT=0;
AArawT=0;
KparawT=0;

%% classification accuracy for each class
avrraw=zeros(1,7); %avrraw=zeros(1,14); Original image
avrrawT=zeros(1,7); %Test image

%% ==============classification precessing==========================
[xind, yind]=find(trainlabels~=0);
for i=1:length(xind)
    Xtrspe(i,:)=spectraldata(xind(i),yind(i),:);
    labeledtrain(i)=trainlabels(xind(i),yind(i));
end

no_rep=1;
for jj=1:no_rep
    trainlabels=double(trainlabels);%double(getlabeltrain(Train_Pavia, numlabeled));%double(getlabeltrain(Train_Centre(:,224:end), numlabeled));%Train_Centre(:,224:end);%%

    mask= trainlabels; % training sets
    labels=testlabels; % testing sets

%%Orginal image
Xtsspe=reshape(spectraldata,rows*cols,bands);
classraw=knnclassify(Xtsspe,Xtrspe,labeledtrain');
outraw=reshape(classraw,rows,cols);
clear Xtsspe spectraldata

%%%Test image
XtsspeT=reshape(spectraldataTest,rowsT*colsT,bandsT);
classrawT=knnclassify(XtsspeT,Xtrspe,labeledtrain');
outrawT=reshape(classrawT,rowsT,colsT);
clear XtsspeT spectraldataTest

%% do classification 
    accuracyraw= size(find(outraw==labels),1)/size(find(labels>0),1);
   
    %% calculate the classifying accuracy for each class
    for j=1:class_num
         avraw(j)=size(find(outraw==labels & outraw==j & labels==j),1)/size(find(labels==j),1);        

         for jjj=1:class_num
             Kraw(j,jjj)=size(find(outraw==j & labels==jjj),1);
         end
    end
    disp('Kappa coefficients for Raw data set:')
    [poraw,peraw,kpraw]=kappa(Kraw);     
    Kparaw=Kparaw+kpraw;    
    avrraw=avrraw+avraw;    
    araw=sum(avraw)/class_num;    
    OAraw=OAraw+accuracyraw;
    AAraw=AAraw+araw; 
end
    Kparaw=Kparaw/no_rep
avrraw=avrraw/no_rep*100;

disp('The classification accuracy for each class: (Raw,  MPs, Stack, Proposed)')
for i=1:class_num
    disp(['The classify accuracy of class ' num2str(i),sprintf(' is: %.2f%',avrraw(i))])
end

%===========================================
%calculate the average of the OCA
disp('The overall classification accuracy: (Raw,  MPs, Stack, Proposed)')
OAraw=OAraw/no_rep*100
%===========================================
%calculate the average of the ACA
disp('The average classification accuracy: (Raw,  MPs, Stack, Proposed)')
AAraw=AAraw/no_rep*100

%% display the classification maps
%namef=[type_se,'_',num_scales,'raw_mp.fig'];
figure;
subplot(1,3,1);imagesc(testlabels);title('Ground Truth')
subplot(1,3,2);imagesc(outraw);title(sprintf('Raw (OA= %.1f%%, AA= %.1f%%) ORIGINAL', [OAraw,AAraw]))
annotation('textarrow',[0.316251830161054 0.289165446559297],...
    [0.284223367697594 0.281786941580756],'String',{'Est1'});
annotation('textarrow',[0.275256222547584 0.253294289897511],...
    [0.70346735395189 0.701030927835052],'String',{'Est2'});
annotation('textarrow',[0.248169838945827 0.234992679355783],...
    [0.871503840245776 0.8678955453149],'String',{'Est3'});
annotation('textarrow',[0.174963396778917 0.153733528550512],...
    [0.296250859106529 0.297250859106529],'String',{'Bend'});
annotation('textarrow',[0.183016105417277 0.183016105417277],...
    [0.636457044673539 0.685567010309278],'String',{'Flat'});
annotation('textarrow',[0.273060029282577 0.242313323572474],...
    [0.765513056835638 0.748079877112135],'String',{'Grid'});
annotation('textarrow',[0.158125915080527 0.154465592972182],...
    [0.804123711340206 0.845360824742268],'String',{'Background'});

%aSt1 = annotation('textbox','String','ST1','LineStyle','none','FontSize', 24,'color','blue');

% % % Image test
subplot(1,3,3);imagesc(outrawT);title(sprintf('Test image'))

