%****************************In the Name of God****************************
%PCD (Persistent Contrastive Divergence) class is a sampling method. In
%this class we can generate samples from an RBM model. Unlike CD method
%that uses training data as initial value for visible units, PCD method
%uses last chain state in the last update step. In other words, PCD uses
%successive Gibbs sampling runs to estimate model samples. Also this class
%inherits from Gibbs class. In this class many persistent chains can be run
%in parallel and we will refer to the current state in each of these chains
%as new sample or a “fantasy” particle. This class  inherits from Gibbs class.

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
%   	03/2014
%           LIMP(Laboratory for Intelligent Multimedia Processing),
%           AUT(Amirkabir University of Technology), Tehran, Iran
%**************************************************************************
%Pcd class
classdef Pcd<SamplingClasses.Gibbs
    % PROTECTED PROPERTIES ------------------------------------------------
    properties (Access=protected)
        numberOfChains
        lastChainState
    end %End PROTECTED PROPERTIES
    
    % PUBLIC METHODS ------------------------------------------------------
    methods (Access=public)
        %Constructor
        function obj=Pcd()
            obj.methodType='Pcd';
            obj.numberOfChains=15;
            obj.lastChainState=[];
        end %End of Constructor function
        
        %Running sampling method to generate new values in visible and
        %hidden units.
        %modelParams: Parameters of RBM model
        %posVis: Positive visible data. In PCD method, This matrix will
        %be used for positive hidden units
        %posHid: Positive hidden units.
        %negVis: negative visible units.
        %negHid: negative hidden units.
        function [obj,posHid,negVis,negHid]=run(obj,modelParams,posVis)
            %PCD method uses last chain state in the last update step. In
            %other words, PCD uses successive Gibbs sampling runs to
            %estimate model samples.
            if(isempty(obj.lastChainState))
                %PCD chains creation
                obj.lastChainState=obj.initPosVis(modelParams,obj.numberOfChains);
            end
            negVis=[];
            negHid=[];
            [~,hidProb]=obj.up(modelParams,posVis);
            posHid=hidProb;
            [hidSample,hidProb]=obj.up(modelParams,obj.lastChainState);           
            for j=1:ceil(size(posVis,1)/obj.numberOfChains)
                for i=1:modelParams.kSamplingIteration;
                    [visSample,visProb]=obj.down(modelParams,hidSample);                    
                    [hidSample,hidProb]=obj.up(modelParams,visSample);                    
                end
                negVis=[negVis;visSample];
                negHid=[negHid;hidProb];
            end
            obj.lastChainState=visSample;
            negVis=negVis(1:size(posVis,1),:);
            negHid=negHid(1:size(posVis,1),:);
        end %End of run function
        
    end %End PUBLIC METHODS
    
    % PRIVATE METHODS -----------------------------------------------------
    methods (Access=private)
        
        %Initialize PCD chains
        %modelParams: Parameters of RBM model 
        %numberOfChains: PCD method uses last chain state in the last
        %update step.
        function [posVis]=initPosVis(~,modelParams,numberOfChains)
            %init posVis data
            switch modelParams.visibleValueType
                case ValueType.probability
                    posVis=rand(numberOfChains,modelParams.numVis);
                case ValueType.binary
                    posVis=0.5>rand(numberOfChains,modelParams.numVis);
                case ValueType.gaussian
                    posVis=randn(numberOfChains,modelParams.numVis);
            end
        end %End of initPosVis function
        
    end %End PRIVATE METHODS
    
end %End Pcd class

