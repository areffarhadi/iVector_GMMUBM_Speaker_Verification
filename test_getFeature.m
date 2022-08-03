%Test getFeature function for autoEncoder DBN
% clc
% clear;
addpath('DeeBNet');
%data = MNIST.prepareMNIST('D:\DataSets\Image\MNIST\');%using MNIST dataset completely.
 data = MNIST.prepareMNIST_Small('+MNIST\');%uncomment this line to use a small part of MNIST dataset.
data.normalize('meanvar');
data.validationData=data.testData;
data.validationLabels=data.testLabels;

dbn=DBN();
dbn.dbnType='autoEncoder';
% RBM1
rbmParams=RbmParameters(1024,ValueType.binary);
rbmParams.maxEpoch=50;
rbmParams.samplingMethodType=SamplingClasses.SamplingMethodType.CD;
dbn.addRBM(rbmParams);

% RBM2
rbmParams=RbmParameters(1024,ValueType.binary);
rbmParams.maxEpoch=50;
rbmParams.samplingMethodType=SamplingClasses.SamplingMethodType.CD;
dbn.addRBM(rbmParams);
% RBM3
rbmParams=RbmParameters(512,ValueType.binary);
rbmParams.maxEpoch=50;
rbmParams.samplingMethodType=SamplingClasses.SamplingMethodType.CD;
dbn.addRBM(rbmParams);
% RBM4
rbmParams=RbmParameters(39,ValueType.binary);
rbmParams.maxEpoch=50;
rbmParams.samplingMethodType=SamplingClasses.SamplingMethodType.CD;
dbn.addRBM(rbmParams);

dbn.train(data);
save('dbn.mat','dbn');

a1=data.trainData(1:250000,:);
a2=data.trainData(600000:850000-1,:);
data.trainData=cat(1,a1,a2);
dbn.backpropagation(data);
save('dbn+BP.mat','dbn');
 %% plot
% figure;
% plotFig=[{'mo' 'go' 'm+' 'r+' 'ro' 'k+' 'g+' 'ko' 'bo' 'b+'}];
% for i=0:9
%     img=data.testData(data.testLabels==i,:);
%     ext=dbn.getFeature(img);
%     
%     plot3(ext(:,1),ext(:,2),ext(:,3),plotFig{i+1});hold on;
% end
% legend('0','1','2','3','4','5','6','7','8','9');
% hold off;
%%
%     img=data.testData(data.testLabels==0,:);
%     ext1=dbn.getFeature(img);
%     img=data.testData(data.testLabels==1,:);
%     ext2=dbn.getFeature(img);
%     img=data.testData(data.testLabels==2,:);
%     ext3=dbn.getFeature(img);
%     img=data.testData(data.testLabels==3,:);
%     ext4=dbn.getFeature(img);
%     img=data.testData(data.testLabels==4,:);
%     ext5=dbn.getFeature(img);
%     img=data.testData(data.testLabels==5,:);
%     ext6=dbn.getFeature(img);
%     img=data.testData(data.testLabels==6,:);
%     ext7=dbn.getFeature(img);
%     img=data.testData(data.testLabels==7,:);
%     ext8=dbn.getFeature(img);
%     img=data.testData(data.testLabels==8,:);
%     ext9=dbn.getFeature(img);
%     img=data.testData(data.testLabels==9,:);
%     ext10=dbn.getFeature(img);
%     
%   figure;
% plotFig=[{'mo' 'go' 'm+' 'r+' 'ro' 'k+' 'g+' 'ko' 'bo' 'b+'}];
% for i=0:9
%     img=data.testData(data.testLabels==i,:);
%     ext=dbn.getFeature(img);
%     
%     plot3(ext(:,1),ext(:,2),ext(:,3),plotFig{i+1});hold on;
% end
% legend('0','1','2','3','4','5','6','7','8','9');
% hold off;
%     