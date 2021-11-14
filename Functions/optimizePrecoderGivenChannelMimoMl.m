function optimizePrecoderGivenChannelMimoMl(simParamFilePath)
%
% OPTIMIZEPRECODERGIVENCHANNELMIMOML Optimize/predict precoder using a
% trained neural net.
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

% Channel-related params --------------------------------------------------
snrIdxCurrent           = simCaseStruct.channel.snrIdxCurrent;
channelMat              = simCaseStruct.channel.channelMats{snrIdxCurrent};
nTxAntennas             = simCaseStruct.channel.nTxAntennas;
snrDb                   = simCaseStruct.channel.snrDbVec(snrIdxCurrent);

simName                 = simCaseStruct.cluster.simName;
caseIdx                 = simCaseStruct.cluster.caseIdx;
nOrderCasesMax          = simCaseStruct.cluster.nOrderCasesMax;
caseIdxTag              = convertNumberToCaseIdxTag(caseIdx, nOrderCasesMax);
caseId                  = [simName, '_', caseIdxTag];     % ID for the sim case
simFolderPath           = simCaseStruct.cluster.simFolderPath;
simCaseSubfolderPath    = [simFolderPath, '\', caseId];

% Signal-related params ---------------------------------------------------
typeModulation          = simCaseStruct.signaling.typeModulation;

% Cluster-related params --------------------------------------------------
evaluateTrueMiMeanwhile = simCaseStruct.cluster.evaluateTrueMiMeanwhile;

% Create the case subfolder
if (~exist(simCaseSubfolderPath))
  mkdir(simCaseSubfolderPath);
end

% Path to trained neural nets
netsPath = [pwd, '\TrainedNets'];

switch typeModulation
  case 'BPSK'
    switch nTxAntennas
      case 2
        load([netsPath, '\nnWeightsBpsk2x2Mimo.mat']);
      case 3
        load([netsPath, '\nnWeightsBpsk3x3Mimo.mat']);
      otherwise
        error('Unknown antenna stup');
    end
  case 'QPSK'
    switch nTxAntennas
      case 2
        load([netsPath, '\nnWeightsQpsk3x3Mimo.mat']);
      case 3
        load([netsPath, '\nnWeightsQpsk3x3Mimo.mat']);
      otherwise
        error('ERROR! Unknown antenna setup');
    end
  otherwise
    error('ERROR! No trained neural net for this constellation');
end


snr = 10^(snrDb/10);
snrTag = convertNumberToSnrTag(snrDb);
jobId = [caseId, '_', snrTag];
simFileName = ['mi_', jobId];

simFilePath   = [simCaseSubfolderPath, '\', simFileName];
matFilePath   = [simFilePath, '.mat'];

simCaseStruct.cluster.matFilePath = matFilePath;
simCaseStruct.cluster.status      = 'RUNNING';

[~, nTxAntennas] = size(channelMat);
Hmat = sqrt(snr/nTxAntennas) * channelMat;

timeBegin = cputime; % start clock

precoderMatGauss = getWfPrecoder(Hmat);
precoderVecGauss = convertComplexMatToRealVec(precoderMatGauss);
precoderVecPredicted = runFeedforwardPass(neuralNet, precoderVecGauss);
precoderMatPredicted = convertRealVecToComlpexMat(precoderVecPredicted, N, nTxAntennas);
G = precoderMatPredicted * sqrt(nTxAntennas)/sqrt(trace(precoderMatPredicted'*precoderMatPredicted));

timeEnd = cputime; % stop clock

if evaluateTrueMiMeanwhile
  [I, ~]   = computeMiMimo(Hmat*G, typeModulation, 'TRUE', 'EXHAUSTIVE', 5e3, 7e3);
else
  [I, ~]   = computeMiMimo(Hmat*G, typeModulation, 'TRUE', 'EXHAUSTIVE', 1e2, 1e3);
end

% Container for precoders -------------------------------------------------
simCaseStruct.precoding.precoderReal = real(G);
simCaseStruct.precoding.precoderImag = imag(G);

% Containers for performance metrics --------------------------------------
simCaseStruct.performance.miBpcu = I;
simCaseStruct.performance.timeElapsedSec = (timeEnd - timeBegin)/60;
simCaseStruct.cluster.status = 'COMPLETED';

% Save all params to file
save(simCaseStruct.cluster.matFilePath, 'simCaseStruct');