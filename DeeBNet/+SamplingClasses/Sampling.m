%****************************In the Name of God****************************
%Sampling class is an interface class for using implemented sampling
%classes. Other classes can uniformly use implemented sampling classes with
%this useful class.
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
%Sampling class
classdef Sampling<handle
    % PUBLIC PROPERTIES ---------------------------------------------------
    properties (Access=public)
        %posHid: Positive hidden units.        
        posHid;
        %negVis: negative visible units.
        negVis;
        %negHid: negative hidden units.
        negHid;
    end %End PUBLIC PROPERTIES
    
    % PRIVATE PROPERTIES --------------------------------------------------
    properties (Access=private)
        %Storing object of sampling class
        methodObj;
    end %End PRIVATE PROPERTIES

    % PUBLIC METHODS ------------------------------------------------------
    methods (Access=public)
        %Constructor
        %methodType: determines sampling method type
        function obj=Sampling(methodType)
            %Creating sampling class object according to methodType
            switch methodType
                case SamplingClasses.SamplingMethodType.Gibbs
                    obj.methodObj=SamplingClasses.Gibbs();
                case SamplingClasses.SamplingMethodType.CD
                    obj.methodObj=SamplingClasses.Cd();
                case SamplingClasses.SamplingMethodType.PCD
                    obj.methodObj=SamplingClasses.Pcd();
                case SamplingClasses.SamplingMethodType.FEPCD
                    obj.methodObj=SamplingClasses.FEPcd();
            end
        end %End of Constructor
        
        %Running sampling method to generate new values in visible and
        %hidden units.
        %modelParams: Parameters of RBM model
        %data:A row data matrix for sampling from them.
        function run(obj,modelParams,data)
            [obj.methodObj,obj.posHid,obj.negVis,obj.negHid]=obj.methodObj.run(modelParams,data);
        end %End of run function
        
        %Sampling hidden units from visible units
        %modelParams: Parameters of RBM model
        %visSample: visible samples that will be used in sampling hidden units.
        %hidSample: generated hidden samples
        %hidProb: probability of activation in hidden samples
        function [hidSample,hidProb]=up(obj,modelParams,visSample)
            [hidSample,hidProb]=obj.methodObj.up(modelParams,visSample);
        end %End of up function
        
        %Sampling visible units from hiiden units
        %modelParams: Parameters of RBM model
        %visSample: visible samples that will be used in sampling hidden units.
        %visProb: probability of activation in visible samples
        function [visSample,visProb]=down(obj,modelParams,hidSample)
            [visSample,visProb]=obj.methodObj.down(modelParams,hidSample);
        end %End of down function
            
    end %End PUBLIC METHODS
    
end %End Sampling class