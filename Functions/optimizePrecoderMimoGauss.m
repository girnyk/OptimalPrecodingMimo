function precoder = optimizePrecoderMimoGauss(simCaseStruct)
%
% OPTIMIZEPRECODERMIMOGAUSS Water-filling based precoder for maximizing 
% the achievable rates for a MIMO channel with Gaussian inputs.
%
%     Inputs:     struct simCaseStruct = struct of sim case params
%     Outputs:    mat precoder = linear precoding matrix
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

% Cluster-related params --------------------------------------------------
simName                 = simCaseStruct.cluster.simName;
caseIdx                 = simCaseStruct.cluster.caseIdx;
nOrderCasesMax          = simCaseStruct.cluster.nOrderCasesMax;
caseIdxTag              = convertNumberToCaseIdxTag(caseIdx, nOrderCasesMax);
caseId                  = [simName, '_', caseIdxTag]; % ID for the sim case
simFolderPath           = simCaseStruct.cluster.simFolderPath;
simCaseSubfolderPath    = [simFolderPath, '\', caseId];

% Channel-related params --------------------------------------------------
snrDbVec                = simCaseStruct.channel.snrDbVec;
nSnrDb                  = length(snrDbVec);

% Create the case subfolder
if (~exist(simCaseSubfolderPath))
  mkdir(simCaseSubfolderPath);
end

% Loop over SNRs ----------------------------------------------------------
for iSnrDb = 1 : nSnrDb
  
  % SNR value in linear scale
  snrDb = snrDbVec(iSnrDb);
  simCaseStruct.channel.currentSnrDb = snrDb;
  snr = 10^(snrDb/10);
  snrTag = convertNumberToSnrTag(snrDb);
  
  % Sim case formal params
  jobId         = [caseId, '_', snrTag];
  simFileName   = ['mi_', jobId];
  simFilePath   = [simCaseSubfolderPath, '\', simFileName];
  matFilePath   = [simFilePath, '.mat'];
  simCaseStruct.cluster.matFilePath = matFilePath;
  simCaseStruct.cluster.status      = 'RUNNING';
  
  % Channel matrix
  channelMat = simCaseStruct.channel.channelMatReal + 1i*simCaseStruct.channel.channelMatImag;
  [~, M] = size(channelMat);
  Hmat = sqrt(snr/M) * channelMat; 
  
  timeBegin = cputime; % start clock
  
  % Compute water-filling precoder
  precoder = getWfPrecoder(Hmat);

  timeEnd = cputime; % stop clock
  
  % Performance metrics
  I = miMimoGauss(Hmat*precoder); 
  
  % Container for precoders -------------------------------------------------
  simCaseStruct.precoding.precoderReal = real(precoder);
  simCaseStruct.precoding.precoderImag = imag(precoder);
  
  % Containers for performance metrics --------------------------------------
  simCaseStruct.performance.miBpcu = I;
  simCaseStruct.performance.timeElapsedSec = (timeEnd - timeBegin)/60;
  simCaseStruct.cluster.status = 'COMPLETED';
  
  % Save all params to mat-file
  save(simCaseStruct.cluster.matFilePath, 'simCaseStruct');
  
end % for iSnrDb = 1 : nSnrDb