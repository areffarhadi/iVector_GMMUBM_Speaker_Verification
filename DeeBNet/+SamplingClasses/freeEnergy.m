%****************************In the Name of God****************************
%freeEnergy function computes free Energy for each row data according to G.
%Hinton, “A practical guide to training restricted boltzmann machines,”
%Machine Learning Group, University of Toronto, Technical report, 2010.

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
%freeEnergy function
%dataMatrix: A row data matrix
function FE=freeEnergy(modelParams,dataMatrix)
    FE = -dataMatrix*modelParams.visBias'- ...
        sum(log(exp(dataMatrix*modelParams.weight+ ...
        repmat(modelParams.hidBias,size(dataMatrix,1),1))+1),2);
end %End of freeEnergy function