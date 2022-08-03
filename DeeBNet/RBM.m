%****************************In the Name of God****************************
% RBM class defines all necessary functions and features in all types of
% RBMs. Indeed the RBM class is an abstract class and we can't create an
% object from it.

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
%RBM Class
classdef (Abstract) RBM<handle
    
    % PUBLIC PROPERTIES ---------------------------------------------------
    properties (Access=public)
        %Storing RBM parameters
        rbmParams
    end %End PUBLIC PROPERTIES
    
    % PROTECTED PROPERTIES ------------------------------------------------
    properties (Access=protected)
        %Storing an object of Sampling class
        sampler
        %This parameter is used during training phase for updating weights.
        deltaWeight;
        %This parameter is used during training phase for updating visible
        %bias.
        deltaVisBias;
        %This parameter is used during training phase for updating hidden
        %bias.
        deltaHidBias;
    end %End PROTECTED PROPERTIES
    
    % PUBLIC METHODS ------------------------------------------------------
    methods (Access=public)
        %Constructor
        function obj=RBM(rbmParams)
            obj.rbmParams=rbmParams;
        end %End of constructor
        
    end %End PUBLIC METHODS
    
    % PUBLIC ABSTRACT METHODS ---------------------------------------------
    methods(Abstract)
        %Training function
        train(obj,trainData)
        %Get feature from dataMatrix by RBM model
        [extractedFeature]=getFeature(obj,dataMatrix)
    end %End PUBLIC ABSTRACT METHODS
end %End RBM class