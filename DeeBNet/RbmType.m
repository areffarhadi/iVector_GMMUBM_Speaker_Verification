%****************************In the Name of God****************************
% RbmType class is an enumeration that contains types of rbms is used
% in DBN.

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
%RbmType class or enumeration
classdef RbmType
    % generative: An Rbm that uses data without their labels. Result is a
    % generative model.    
    % discriminative: An Rbm that uses data with their labels. This RBM is a
    % discriminative model and can classify data to their labels.
    enumeration
        generative,discriminative
    end
    
end %End Classdef

