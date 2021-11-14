function commonSimParamStruct = createCommonSimParamStruct(defaultSimParamStruct)
%
% CREATECOMMONSIMPARAMSTRUCT Create a struct with sim params common to all
% sim cases
%
%     Inputs:     struct defaultSimParamStruct = default struct of sim params
%     Outputs:    struct commonSimParamStruct = struct of sim params
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

M                       = defaultSimParamStruct.channel.nTxAntennas;
N                       = defaultSimParamStruct.channel.nRxAntennas;
channelTag              = defaultSimParamStruct.channel.channelTag;


% Common sim params list ==================================================

% Cluster-related params --------------------------------------------------
runOnCluster            = 0;                    % flag for running on the cluster/locally
currentDateFormat       = 'yymmdd_HHMMSS';
currentTimeStamp        = datestr(now, currentDateFormat);
simId                   = currentTimeStamp;     % ID for the entire sim
simFolderNameSuffix     = ['_', num2str(M), 'x', num2str(N), '_', channelTag];
simFolderName           = ['sim_', simId, simFolderNameSuffix];
simFolderPath           = [pwd, '\Data\', simFolderName];
nMiValuesBuffer         = 12;                   % buffer for MI values displayed in a row
logValuesToFile         = 0;                    % log MI, MMSE and time in a file
evaluateTrueMiMeanwhile = 0;                    % compute true QAM MI during optimization

cluster = struct(...
  'runOnCluster', runOnCluster,...
  'simId', simId,...
  'simFolderName', simFolderName,...
  'simFolderPath', simFolderPath,...
  'nMiValuesBuffer', nMiValuesBuffer,...
  'logValuesToFile', logValuesToFile,...
  'evaluateTrueMiMeanwhile', evaluateTrueMiMeanwhile...
  );

% Common sim params structure ---------------------------------------------
commonSimParamStruct = struct(...
  'cluster', cluster...
  );

end