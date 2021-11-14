function precoder = optimizePrecoderMimoMl(simCaseStruct)
%
% OPTIMIZEPRECODERMIMOML DL-based approximation of the optimal precoder, 
% computed by means of a forward pass thru a trained neural net.
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

% Path to trained neural nets
netsPath = [pwd, '\TrainedNets'];

% Signal-related params ---------------------------------------------------
typeModulation          = simCaseStruct.signaling.typeModulation;

% Computation-related params ----------------------------------------------
nItersSignalMi          = simCaseStruct.computation.nItersSignalMi;
nItersNoiseMi           = simCaseStruct.computation.nItersNoiseMi;

% Cluster-related params --------------------------------------------------
simName                 = simCaseStruct.cluster.simName;
caseIdx                 = simCaseStruct.cluster.caseIdx;
nOrderCasesMax          = simCaseStruct.cluster.nOrderCasesMax;
caseIdxTag              = convertNumberToCaseIdxTag(caseIdx, nOrderCasesMax);
caseId                  = [simName, '_', caseIdxTag]; % ID for the sim case
simFolderPath           = simCaseStruct.cluster.simFolderPath;
simCaseSubfolderPath    = [simFolderPath, '\', caseId];
evaluateTrueMiMeanwhile = simCaseStruct.cluster.evaluateTrueMiMeanwhile;

% Channel-related params --------------------------------------------------
snrDbVec    = simCaseStruct.channel.snrDbVec;
nSnrDb      = length(snrDbVec);

% Create the case subfolder
if (~exist(simCaseSubfolderPath))
  mkdir(simCaseSubfolderPath);
end

% Download trained neural net
switch simCaseStruct.signaling.typeModulation
  case 'BPSK'
    switch simCaseStruct.channel.nTxAntennas
      case 2
        load([netsPath, '\nnWeightsBpsk2x2Mimo.mat']);
      case 3
        load([netsPath, '\nnWeightsBpsk3x3Mimo.mat']);
      otherwise
        error('ERROR! Trained weights for this antenna setup are missing!');
    end
  case 'QPSK'
    switch simCaseStruct.channel.nTxAntennas
      case 2
        load([netsPath, '\nnWeightsQpsk2x2Mimo.mat']);
      case 3
        load([netsPath, '\nnWeightsQpsk3x3Mimo.mat']);
      otherwise
        error('ERROR! Trained weights for this antenna setup are missing!');
    end
  case '8PSK'
    error('ERROR! Trained weights for this antenna setup are missing!');
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
  [N, M] = size(channelMat);
  Hmat = sqrt(snr/M) * channelMat;
  
  timeBegin = cputime; % start clock
  
  % Predict optimal precoder matrix using forward pass
  precoderMatGauss = getWfPrecoder(Hmat);
  precoderVecGauss = convertComplexMatToRealVec(precoderMatGauss);
  precoderVecPredicted = runFeedforwardPass(neuralNet, precoderVecGauss);
  precoderMatPredicted = convertRealVecToComlpexMat(precoderVecPredicted, N, M);
  precoder = precoderMatPredicted * sqrt(M)/sqrt(trace(precoderMatPredicted'*precoderMatPredicted));
  
  timeEnd = cputime; % stop clock
  
  % Performance metrics
  if evaluateTrueMiMeanwhile
    [I, ~]   = computeMiMimo(Hmat*precoder, typeModulation, 'TRUE', 'EXHAUSTIVE', 5e3, 7e3);
  else
    [I, ~]   = computeMiMimo(Hmat*precoder, typeModulation, 'TRUE', 'EXHAUSTIVE', nItersSignalMi, nItersNoiseMi);
  end
  
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