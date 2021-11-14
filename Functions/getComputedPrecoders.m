function [precoders, snrsDb] = getComputedPrecoders(simFolderName, caseNr)
%
% GETCOMPUTEDPRECODERS Load the precoders previously optimized and stored
% in a folder.
%
%     Inputs:     str simFolderName = name of the sim folder with precoders
%                 scalar caseNr = number of the case of interest in that folder
%     Outputs:    cell array precoders = precoder matrices
%                 cell array snrsDb = SNR values
%
% Max Girnyk
% Stockholm, 2014-10-01
%
% =========================================================================
%
% This Matlab script produces results used in the following paper:
%
% M. A. Girnyk, "Deep-learning based linear precoding for MIMO channels
% with finite-alphabet signaling," Physical Communication 48(2021) 101402
%
% Paper URL:          https://arxiv.org/abs/2111.03504
%
% Version:            1.0 (modified 2021-11-14)
%
% License:            This code is licensed under the Apache-2.0 license.
%                     If you use this code in any way for research that
%                     results in a publication, please cite the above paper
%
% =========================================================================

dataPath =  [pwd, '/Data'];
simFolderPath = [dataPath, '/', simFolderName];
delimiter = regexp(simFolderName, '_');

resultFileName = [simFolderPath, '/results_', simFolderName(delimiter(1)+1:delimiter(end)-1), '.mat'];
load(resultFileName);

precoders     = resultStruct{caseNr}.precoders;
snrsDb        = resultStruct{caseNr}.snrDb;

end
