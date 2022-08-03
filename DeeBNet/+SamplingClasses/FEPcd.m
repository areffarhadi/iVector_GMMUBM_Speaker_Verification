%****************************In the Name of God****************************
%FEPCD (Free Energy in Persistent Contrastive Divergence) class is a
%sampling method. In this class we can generate samples from an RBM model.
%In PCD method, many persistent chains can be run in parallel and we will
%refer to the current state in each of these chains as a “fantasy”
%particle. Chain selection in this method is blind and the best one may not
%be selected. If we can define a criterion for goodness of a chain, samples
%and therefore computing gradient will be more accurate. The my proposed
%criterion for selecting the best chain is the free energy of visible
%sample v. This class  inherits from Pcd class.
%Reference: M. Keyvanrad, M. Homayounpour, “Using Free Energy in Persistent
%Contrastive Divergence in Training of Deep Belief Networks” Submitted to
%Neurocomputing, 2014.
%
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
%FEPcd class
classdef FEPcd<SamplingClasses.Pcd
    % PUBLIC METHODS ------------------------------------------------------
    methods (Access=public)
        %Constructor
        function obj=FEPcd()
            obj.methodType='FEPcd';
            obj.numberOfChains=15;
            obj.lastChainState=[];
        end
        
        %Running sampling method to generate new values in visible and
        %hidden units.
        %modelParams: Parameters of RBM model
        %posVis: Positive visible data. In FEPCD method, This matrix will
        %be used for positive hidden units
        %posHid: Positive hidden units.
        %negVis: negative visible units.
        %negHid: negative hidden units.
        function [obj,posHid,negVis,negHid]=run(obj,modelParams,posVis)
            if(isempty(obj.lastChainState))
                obj.lastChainState=obj.initPosVis(modelParams,obj.numberOfChains);
            end
            negVis=[];
            negHid=[];
            [~,hidProb]=obj.up(modelParams,posVis);
            posHid=hidProb;
            [hidSample,~]=obj.up(modelParams,obj.lastChainState);
            for j=1:ceil(size(posVis,1)/obj.numberOfChains)
                for i=1:modelParams.kSamplingIteration;
                    [visSample,visProb]=obj.down(modelParams,hidSample);
                     [hidSample,hidProb]=obj.up(modelParams,visSample);
                end
                %Difference with PCD: Sorting by free energy and using
                %best of them with lower free energy.
                [IX]=sortByFreeEnergy(obj,modelParams,visSample);
                visSample=visSample(IX,:);
                hidProb=hidProb(IX,:);              
                negVis=[negVis;visSample(1:obj.numberOfChains,:)];
                negHid=[negHid;hidProb(1:obj.numberOfChains,:)];
            end
            obj.lastChainState=visSample;
            negVis=negVis(1:size(posVis,1),:);
            negHid=negHid(1:size(posVis,1),:);
        end %End of run function
        
    end %End PUBLIC METHODS
    
    % PRIVATE METHODS -----------------------------------------------------
    methods (Access=private)
        %Initialize FEPCD chains
        %modelParams: Parameters of RBM model 
        %numberOfChains: FEPCD method uses last chain state in the last
        %update step.
        function [posVis]=initPosVis(~,modelParams,numberOfChains)
            %Difference with PCD: duplicate number of chains to choose
            %best of them equal to numberOfChains chains.
            duplicateFactor=2;
            %init posVis data
            switch modelParams.visibleValueType
                case ValueType.probability
                    posVis=rand(duplicateFactor*numberOfChains,modelParams.numVis);
                case ValueType.binary
                    posVis=0.5>rand(duplicateFactor*numberOfChains,modelParams.numVis);
                case ValueType.gaussian
                    posVis=randn(duplicateFactor*numberOfChains,modelParams.numVis);
            end
        end %End of initPosVis function
        
        %Sorting data according to their free energy
        %modelParams: Parameters of RBM model 
        %dataMatrix: A row data matrix
        function [IX]=sortByFreeEnergy(~,modelParams,dataMatrix)
            %computing free energy for each row data in dataMatrix
            %according to G. Hinton, “A practical guide to training
            %restricted boltzmann machines,” Machine Learning Group,
            %University of Toronto, Technical report, 2010.
            FE=SamplingClasses.freeEnergy(modelParams,dataMatrix);
            [~,IX] = sort(FE);
        end %End of sortByFreeEnergy function
        
    end %End PRIVATE METHODS
    
end %End FEPcd class

