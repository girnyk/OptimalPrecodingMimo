function runSimsLocally(simCaseStruct, operationType)
%
% RUNSIMSLOCALLY Runs optimization jobs on the local machine 
%
%     Inputs:     struct simCaseStruct = struct with sim case params
%                 str operationType = job type to run: {OPTIMIZATION, EVALUATION, COMPUTATION, CHANNELIZATION}
%     Outputs:    --
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

simDataPath   = [pwd, '\SimData'];

% Cluster-related params --------------------------------------------------
simName                 = simCaseStruct.cluster.simName;
caseIdx                 = simCaseStruct.cluster.caseIdx;
nOrderCasesMax          = simCaseStruct.cluster.nOrderCasesMax;
caseIdxTag              = convertNumberToCaseIdxTag(caseIdx, nOrderCasesMax);
caseId                  = [simName, '_', caseIdxTag];     % ID for the sim case
simFolderPath           = [simDataPath, '\', simName];
simCaseSubfolderPath    = [simFolderPath, '\', caseId];


% Create the case subfolder
if (~exist(simCaseSubfolderPath))
  mkdir(simCaseSubfolderPath);
end

snrDbVec      = simCaseStruct.channel.snrDbVec;
nSnrDb        = length(snrDbVec);

% Loop over SNRs ----------------------------------------------------------
for iSnrDb = 1 : nSnrDb
  
  snrDb = snrDbVec(iSnrDb);
  
  % File = current SNR point
  snrTag      = convertNumberToSnrTag(snrDb);
  jobId       = [caseId, '_', snrTag];
  simFileName = ['mi_', jobId];
  
  simCaseStruct.cluster.simDataPath = simDataPath;
  simCaseStruct.cluster.simFolderPath = simFolderPath;
  
  simCaseStruct.channel.snrIdxCurrent = iSnrDb;
  simCaseStruct.channel.currentSnrDb = snrDb;
  
  simFilePath = [simCaseSubfolderPath, '\', simFileName];
  matFilePath = [simFilePath, '.mat'];
  
  if (exist(matFilePath))
    load(matFilePath);
  end

  simCaseStruct.cluster.matFilePath = matFilePath;
  simCaseStruct.cluster.status      = 'RUNNING';
  
  if strcmp(operationType, 'OPTIMIZATION')
    % Optimize precoder
    save(matFilePath, 'simCaseStruct'); % save all params to file
    if strcmp(simCaseStruct.computation.methodComputationMi, 'NONE')
      % No precoding at all
      setOmniPrecoderMimo(matFilePath);
    elseif strcmp(simCaseStruct.computation.methodComputationMi, 'GAUSS_OPT')
      % Gaussian opt precoder for discrete constellation
      optimizePrecoderMimoGaussOpt(matFilePath);
    else
      % Optimize precoder for discrete constellation
      optimizePrecoderMimo(matFilePath);
    end
  elseif strcmp(operationType, 'EVALUATION')
    % Evaluate optimized precoder
    save(matFilePath, 'simCaseStruct');
    evaluatePrecoderMimo(matFilePath);
  elseif strcmp(operationType, 'COMPUTATION')
    % Compute mutual info for given precoder
    save(matFileName, 'simCaseStruct');
    computeMiGivenPrecoderMimo(matFilePath);
  elseif strcmp(operationType, 'CHANNELIZATION')
    % Predict opt precoder for given channel realization
    save(matFilePath, 'simCaseStruct');
    optimizePrecoderGivenChannelMimoMl(matFilePath);
  else
    error('Wrong calculation type! Should be one of {OPTIMIZATION, EVALUATION, COMPUTATION, CHANNELIZATION}');
  end

  
end % for iSnr = 1:length(snrVec)

end
