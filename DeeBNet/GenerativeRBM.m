%****************************In the Name of God****************************
% Restricted Boltzmann machines (RBMs) have been used as generative models
% of many different types of data. Their most important use is as learning
% modules that are composed to form deep belief nets. 
% Ref: G. Hinton,"A practical guide to training restricted boltzmann
% machines,"Machine Learning Group, University of Toronto, Technical
% report, 2010.

% Permission is granted for anyone to copy, use, modify, or distribute this
% program and accompanying programs and documents for any purpose, provided
% this copyright notice is retained and prominently displayed, along with
% a note saying that the original programs are available from our web page.
%
% The programs and documents are distributed without any warranty, express
% or implied.  As the programs were written for research purposes only,
% they have not been tested to the degree that would be advisable in any
% important application.  All use of these programs is entirely at the
% user's own risk.

% CONTRIBUTORS
%	Created by:
%   	Mohammad Ali Keyvanrad (http://ceit.aut.ac.ir/~keyvanrad)
%   	04/2014
%           LIMP(Laboratory for Intelligent Multimedia Processing),
%           AUT(Amirkabir University of Technology), Tehran, Iran
%**************************************************************************
%GenerativeRBM Class
classdef GenerativeRBM<RBM
    
    % PUBLIC METHODS ------------------------------------------------------
    methods (Access=public)
        %Constructor
        function obj=GenerativeRBM(rbmParams)
            obj=obj@RBM(rbmParams);
            obj.rbmParams.rbmType=RbmType.generative;
        end %End of Constructor function
        
        %Training function
        %data: A DataStore class object for using its training data 
        function train(obj,data)
            %Initialize model parameters
            if (isempty(obj.rbmParams.weight))
                obj.rbmParams.visibleValueType=data.valueType;
                obj.rbmParams.weight=0.1*randn(size(data.trainData,2),obj.rbmParams.numHid);
                obj.rbmParams.visBias=zeros(1,size(data.trainData,2));
                obj.deltaWeight=zeros(size(obj.rbmParams.weight));
                obj.deltaVisBias=zeros(size(obj.rbmParams.visBias));
                obj.deltaHidBias=zeros(size(obj.rbmParams.hidBias));
            end
            %Create a sampling class object 
            if (isempty(obj.sampler))
                obj.sampler=SamplingClasses.Sampling(obj.rbmParams.samplingMethodType);
            end
            batchArraySize=ceil(size(data.trainData,1)/obj.rbmParams.batchSize);            
            %Computing start epoch for averaging
            avgstart = obj.rbmParams.maxEpoch + obj.rbmParams.epochNumber - obj.rbmParams.avgLast;
            %Reduction factor in averaging
            t=0;
            %Begin training
            for epoch=1:obj.rbmParams.maxEpoch
                ticID=tic;
                obj.rbmParams.epochNumber=obj.rbmParams.epochNumber+1;
                for batchNumber=1:batchArraySize
                    batchData=data.trainData(...
                        (batchNumber-1)*obj.rbmParams.batchSize+1:min(batchNumber*obj.rbmParams.batchSize,end),:);
                    obj.sampler.run(obj.rbmParams,batchData);
                    %weight
                    obj.deltaWeight=obj.rbmParams.moment(min(obj.rbmParams.epochNumber,end))*obj.deltaWeight+obj.rbmParams.learningRate*...
                        ((batchData'*obj.sampler.posHid-obj.sampler.negVis'*obj.sampler.negHid)/size(batchData,1)- ...
                        obj.rbmParams.penalty*obj.rbmParams.weight);
                    weight=obj.rbmParams.weight+obj.deltaWeight;
                    %visBias
                    obj.deltaVisBias=obj.rbmParams.moment(min(obj.rbmParams.epochNumber,end))*obj.deltaVisBias+obj.rbmParams.learningRate*...
                        ((sum(batchData,1)-sum(obj.sampler.negVis,1))/size(batchData,1));
                    visBias=obj.rbmParams.visBias+obj.deltaVisBias;
                    %HidBias
                    obj.deltaHidBias=obj.rbmParams.moment(min(obj.rbmParams.epochNumber,end))*obj.deltaHidBias+obj.rbmParams.learningRate*...
                        ((sum(obj.sampler.posHid,1)-sum(obj.sampler.negHid,1))/size(batchData,1));
                    hidBias=obj.rbmParams.hidBias+obj.deltaHidBias;
                    %Averaging in some last layers
                    if (avgstart > 0 && obj.rbmParams.epochNumber > avgstart)
                        t = t+1;
                        obj.rbmParams.weight=obj.rbmParams.weight-(1/t)*(obj.rbmParams.weight-weight);
                        obj.rbmParams.visBias=obj.rbmParams.visBias-(1/t)*(obj.rbmParams.visBias-visBias);
                        obj.rbmParams.hidBias=obj.rbmParams.hidBias-(1/t)*(obj.rbmParams.hidBias-hidBias);
                    else
                        obj.rbmParams.weight= weight;
                        obj.rbmParams.visBias= visBias;
                        obj.rbmParams.hidBias= hidBias;
                    end
                end %End batches
                elapsedTime = toc(ticID);
                estimatedTime=elapsedTime*(obj.rbmParams.maxEpoch-epoch);
                perf=obj.computePerformance(data);                
                obj.rbmParams.performanceHistory=[obj.rbmParams.performanceHistory;[perf,elapsedTime]];                
                fprintf(1,'epoch number:%g\t performance:%g\t remained RBM training time:%g\n',obj.rbmParams.epochNumber,perf,estimatedTime);                
            end %End epoches
        end %End of train function
        
        %function to get feature from data
        %dataMatrix:A row data matrix
        %k:number of running sampling
        %fixedDimensions:Define dimensions that will be fixed during
        %sampling
        %extractedFeature: Features that has been extracted.
        function [extractedFeature]=getFeature(obj,dataMatrix,k,fixedDimensions)
            if nargin<3
                k=1;
            end
            if nargin<4
                fixedDimensions=[];
            end
            
            batchArraySize=ceil(size(dataMatrix,1)/obj.rbmParams.batchSize);
            %Extracted feature matrix
            extractedFeature=zeros(size(dataMatrix,1),obj.rbmParams.numHid);
            for i=1:batchArraySize
                batchData=dataMatrix((i-1)*obj.rbmParams.batchSize+1:min(i*obj.rbmParams.batchSize,end),:);
                [hidSample,hidProb]=obj.sampler.up(obj.rbmParams,batchData);
                for j=2:k
                    [visSample,~]=obj.sampler.down(obj.rbmParams,hidSample);
                    visSample(:,fixedDimensions)=batchData(:,fixedDimensions);
                    [hidSample,hidProb]=obj.sampler.up(obj.rbmParams,visSample);
                end
                extractedFeature((i-1)*obj.rbmParams.batchSize+1:min(i*obj.rbmParams.batchSize,end),:)=...
                    hidProb;
            end
        end %End of getFeature function
        
        %Generating data from hidden features
        %extractedFeature: Hidden features
        %k: number of running sampling
        %generatedData: visible data that has been generated
        function [generatedData]=generateData(obj,extractedFeature,k)
            if nargin<3
                k=1;
            end
            [visSample,~]=obj.sampler.down(obj.rbmParams,extractedFeature);
            for i=2:k
                [hidSample,~]=obj.sampler.up(obj.rbmParams,visSample);
                [visSample,~]=obj.sampler.down(obj.rbmParams,hidSample);
            end
            generatedData=visSample;
        end %End of generateData function
        
        %Reconstructing visible data
        %dataMatrix: A row data matrix
        %k: number of running sampling
        %fixedDimensions:Define dimensions that will be fixed during
        %sampling
        %reconstructedData: Visible data that has been reconstructed
        function [reconstructedData]=reconstructData(obj,dataMatrix,k,fixedDimensions)
            if nargin<3
                k=1;
            end
            if nargin<4
                fixedDimensions=[];
            end
            [extractedFeature]=obj.getFeature(dataMatrix,k,fixedDimensions);
            [generatedData]=obj.generateData(extractedFeature,1);
            reconstructedData=generatedData;
        end %End of reconstructData function
        
        %Computing performance of trained model
        %data: A DataStore class object for using its validation data 
        %perf:Computed performance of trained model for validation data
        function perf=computePerformance(obj,data)
            perf=[];
            if (isempty(data.validationData))
                fprintf('Computing performance needs validataion data.\n');
            else
                switch obj.rbmParams.performanceMethod
                    %Computing free energy for validation data in model
                    case 'freeEnergy'
                        dataMatrixLabelsVector=zeros(size(data.validationData,1),obj.rbmParams.numberOfVisibleSoftmax);
                        dataMatrix=[dataMatrixLabelsVector,data.validationData];
                        FE=SamplingClasses.freeEnergy(obj.rbmParams,dataMatrix);
                        perf=mean(FE);
                    %Computing reconstructed error for validation data in model
                    case 'reconstruction'
                        [reconstructedData]=obj.reconstructData(data.validationData);
                        perf=sum(sum((data.validationData-reconstructedData).^2 ))/...
                            (size(data.validationData,1)*size(data.validationData,2));
                    %We can not compute classification error in generative rbm
                    case 'classification'
                        fprintf('Classification error computes in "discriminative RBM".\n');
                    otherwise
                        fprintf(1,'Your performance method (%s) is not defined or is empty.\n', obj.rbmParams.performanceMethod);
                end %End of switch
            end
        end %End of computePerformance function
        
    end %End PUBLIC METHODS
    
end %End GenerativeRBM class

