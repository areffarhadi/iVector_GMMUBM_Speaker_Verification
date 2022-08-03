%****************************In the Name of God****************************
%CD (Contrastive Divergence) class is a sampling method. In this class we
%can generate samples from an RBM model with training samples
%initialization. This class  inherits from Gibbs class.
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
%   	03/2014
%           LIMP(Laboratory for Intelligent Multimedia Processing),
%           AUT(Amirkabir University of Technology), Tehran, Iran
%**************************************************************************
%Cd class
classdef Cd<SamplingClasses.Gibbs
    % PUBLIC METHODS ------------------------------------------------------    
    methods (Access=public)
        %Constructor
        function obj=Cd()
            obj.methodType='Cd';
        end %End of Constructor function
        
        %Running sampling method to generate new values in visible and
        %hidden units.
        %modelParams: Parameters of RBM model
        %posVis: Positive visible data. In Cd method, This matrix will
        %be used visible units initialization and for positive hidden units
        %posHid: Positive hidden units.
        %negVis: negative visible units.
        %negHid: negative hidden units.
        function [obj,posHid,negVis,negHid]=run(obj,modelParams,posVis)
            [hidSample,hidProb]=obj.up(modelParams,posVis);
            posHid=hidProb;
            %Runnin sampling method several iteration
            for i=1:modelParams.kSamplingIteration;
               [visSample,visProb]=obj.down(modelParams,hidSample);
               [hidSample,hidProb]=obj.up(modelParams,visSample);
            end
            negVis=visSample;
            negHid=hidProb;
        end %End of run function 
        
    end %End PUBLIC METHODS    
    
end %End Cd class

