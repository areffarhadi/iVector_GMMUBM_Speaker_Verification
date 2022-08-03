%****************************In the Name of God****************************
% RbmParameters class has all parameters of an RBM. Also it has an
% instructor to set default values for RBM parameters.

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
%   	01/2014
%           LIMP(Laboratory for Intelligent Multimedia Processing),
%           AUT(Amirkabir University of Technology), Tehran, Iran
%**************************************************************************
%RbmParameters Class
classdef RbmParameters<handle
    
    % PUBLIC PROPERTIES ---------------------------------------------------
    properties (Access=public)
        % The undirected weights between the two layers in the form of a 2D
        % matrix with 'numVis' rows and 'numHid' columns
        weight;
        
        % A vector with 'numVis' length that has biases to the visible
        % layer
        visBias;
        
        % A vector with 'numHid' length that has biases to the hidden
        % layer
        hidBias;
        
        % Number of hidden units
        numHid;
        
        % Momentum in learning procedure
        % It's a vector that determines momentum value in each epoch
        moment;
        
        % Learning rate in learning procedure
        learningRate;
        
        % The size of batches in learning procedure
        batchSize;
        
        % Maximum epoch in learning procedure
        maxEpoch;
        
        % Epoch number
        epochNumber;
        
        % How many epochs before maxEpoch to start averaging.
        % Procedure suggested for faster convergence by Kevin Swersky in
        % his MSc thesis 
        avgLast;
        
        % Penalty in learning procedure
        penalty;
        
        % Kind of method that will be used for sampling in an RBM
        samplingMethodType;
        
        % The number of iterations that will be performed for getting to a
        % sample from model
        kSamplingIteration;
        
        % Determines RBM's type
        rbmType;
        
        % The number of visible softmax units
        numberOfVisibleSoftmax;
        
        % A vector with performance value in each epoch.
        performanceHistory;
        
        % The method that will be used for computing performance :
        %'freeEnergy' 'reconstruction' 'classification'
        performanceMethod;
    end %End PUBLIC PROPERTIES
    
    % PRIVATE PROPERTIES --------------------------------------------------
    properties (Access=private)
        % Type of values that will be used in visible units
        % visibleValueType get ValueType enumeration values
        internalVisibleValueType;
        
        % Type of values that will be used in hidden units
        % hiddenValueType get ValueType enumeration values
        internalHiddenValueType;
    end %End PRIVATE PROPERTIES
    
    % DEPENDENT PROPERTIES ------------------------------------------------
    properties (Dependent)
        % Number of visible units
        numVis;
        
        % Type of values that will be used in visible units
        % visibleValueType get ValueType enumeration values
        visibleValueType;
        
        % Type of values that will be used in hidden units
        % hiddenValueType get ValueType enumeration values
        hiddenValueType;
        
    end %End DEPENDENT PROPERTIES
    
    % PUBLIC METHODS ------------------------------------------------------
    methods
        
        % Constructor
        % numHid: Number of hidden units
        % hiddenValueType: Type of values that will be used in hidden units
        function obj=RbmParameters(numHid,hiddenValueType)
            if nargin<1
                numHid=100;
            end
            if nargin<2
                hiddenValueType=ValueType.binary;
            end
            obj.numHid=numHid;
            obj.hiddenValueType=hiddenValueType;
            obj.hidBias=zeros(1,numHid);
            obj.rbmType=RbmType.generative;   
            % In this moment definition, each value in the vector is for
            % each epoch sequentially and the  last value is used for other
            % epochs.
            obj.moment=[0.5 0.4 0.3 0.2 0.1 0];
            obj.batchSize=100;
            obj.maxEpoch=50;
            obj.epochNumber=0;
            obj.avgLast=5;
            obj.penalty=0.0002;
            obj.samplingMethodType=SamplingClasses.SamplingMethodType.CD;
            obj.kSamplingIteration=1;
            obj.numberOfVisibleSoftmax=0;
            obj.performanceHistory=[];
            obj.performanceMethod='freeEnergy';
        end %End of constructor Function
        
        % return numVis property
        function numVis=get.numVis(obj)
            numVis=size(obj.weight,1);
        end
        
        % return visibleValueType property
        function visibleValueType=get.visibleValueType(obj)
            visibleValueType=obj.internalVisibleValueType;
        end
        
        % set visibleValueType property
        function set.visibleValueType(obj,value)
            obj.internalVisibleValueType=value;
            if(value==ValueType.gaussian || obj.internalHiddenValueType==ValueType.gaussian)
                obj.learningRate=0.001;
            else
                obj.learningRate=0.1;
            end
        end
        
        % return hiddenValueType property
        function hiddenValueType=get.hiddenValueType(obj)
            hiddenValueType=obj.internalHiddenValueType;
        end
        
        % set hiddenValueType property
        function set.hiddenValueType(obj,value)
            obj.internalHiddenValueType=value;
            if(value==ValueType.gaussian)
                obj.learningRate=0.001;
            else
                obj.learningRate=0.1;
            end
        end
        
    end %End PUBLIC METHODS
    
end %End RbmParameters class

