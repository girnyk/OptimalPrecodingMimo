function G = optimizePrecoderMimoGaussOpt(simParamFilePath)
%
% OPTIMIZEPRECODERMIMOGAUSSOPT Computing the capacity-achieving 
% water-filling based precoder.
%
%     Inputs:     str simParamFilePath = path of the m-file with params
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

% Load inputParamStruct ---------------------------------------------------
load(simParamFilePath);

% Signal-related params ---------------------------------------------------
typeModulation          = simCaseStruct.signaling.typeModulation;

% Cluster-related params --------------------------------------------------
evaluateTrueMiMeanwhile = simCaseStruct.cluster.evaluateTrueMiMeanwhile;
simName                 = simCaseStruct.cluster.simName;
caseIdx                 = simCaseStruct.cluster.caseIdx;
nOrderCasesMax          = simCaseStruct.cluster.nOrderCasesMax;
caseIdxTag              = convertNumberToCaseIdxTag(caseIdx, nOrderCasesMax);
caseId                  = [simName, '_', caseIdxTag];     % ID for the sim case
simFolderPath           = simCaseStruct.cluster.simFolderPath;
simCaseSubfolderPath    = [simFolderPath, '\', caseId];

% Channel-related params --------------------------------------------------
snrDbVec    = simCaseStruct.channel.snrDbVec;
nSnrDb      = length(snrDbVec);

% Create the case subfolder
if (~exist(simCaseSubfolderPath))
  mkdir(simCaseSubfolderPath);
end

% Loop over SNRs ----------------------------------------------------------
for iSnrDb = 1 : nSnrDb
  
  snrDb = snrDbVec(iSnrDb);
  simCaseStruct.channel.currentSnrDb = snrDb;
  snr = 10^(snrDb/10);
  snrTag = convertNumberToSnrTag(snrDb);
  jobId = [caseId, '_', snrTag];
  simFileName = ['mi_', jobId];
  simFilePath   = [simCaseSubfolderPath, '\', simFileName];
  matFilePath   = [simFilePath, '.mat'];  
  simCaseStruct.cluster.matFilePath = matFilePath;
  simCaseStruct.cluster.status      = 'RUNNING';
  
  channelMat = simCaseStruct.channel.channelMatReal + 1i*simCaseStruct.channel.channelMatImag;
  
  [~, M] = size(channelMat);
  H = sqrt(snr/M) * channelMat; 
  
  timeBegin = cputime; % start clock
  
  % Compute actual water-filling precoder
  G = getWfPrecoder(H);
  
  timeEnd = cputime; % stop clock
    
  if evaluateTrueMiMeanwhile
    [I, ~]   = computeMiMimo(H*G, typeModulation, 'TRUE', 'EXHAUSTIVE', 5e3, 1e4);
  else
    [I, ~]   = computeMiMimo(H*G, typeModulation, 'TRUE', 'EXHAUSTIVE', 1e2, 1e3);
  end
  
  
  % Container for precoders -------------------------------------------------
  simCaseStruct.precoding.precoderReal = real(G);
  simCaseStruct.precoding.precoderImag = imag(G);
  
  % Containers for performance metrics --------------------------------------
  simCaseStruct.performance.miBpcu = I;
  simCaseStruct.performance.timeElapsedSec = (timeEnd - timeBegin)/60;
  simCaseStruct.cluster.status = 'COMPLETED';
  
  % ?ave all params to file
  save(simCaseStruct.cluster.matFilePath, 'simCaseStruct');
  
end % for iSnrDb = 1 : nSnrDb