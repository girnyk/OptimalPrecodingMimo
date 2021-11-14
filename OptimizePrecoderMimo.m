% =========================================================================
%
% Deep-learning based MIMO precoding for finite-alphabet signaling
%
% Low-complexity linear precoding for MIMO channels with discrete inputs
% Precoder optimization
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

function OptimizePrecoderMimo

% % Shuffle random number generator
% rng('shuffle');
% % Or this way
% rand('state', sum(100*clock));
% Or set the seed manually
rand('state', 1);

% Clear and close everything
clear all; clc; close all;

% Add all the subfolders to the path.
currentFilePath = fileparts(which(mfilename)); 
addpath(genpath(currentFilePath));

% % Add an optional message for future reference
% disp('What is this sim about? Add a comment (e.g., test):');
% comment = input('', 's');
comment = 'Debugging';

% Create default sim param structure
defaultSimParamStruct = createDefaultSimParamStruct;

% Operation type, should be one of {'OPTIMIZATION', 'EVALUATION', 'COMPUTATION'}
operationType = 'OPTIMIZATION';

% =========================================================================
% Define common simulation params =========================================
% (how we want to run sims)
simMode                   = 'QUICK';                % short/long sim for debugging/full-blown solution: {'QUICK', 'FULL'}

% Cluster-related params --------------------------------------------------
runOnCluster              = 0;                      % flag for running on the cluster/locally
stepThresholdPercent      = 1e-1;
evaluateTrueMiMeanwhile   = 0;                      % compute true QAM MI during/after? optimization
nOrderCasesMax            = 3;                      % Max order of the number of cases allowed (how many 9s, e.g., 999)
status                    = 'STARTED';              % status of the sim: {'STARTED', 'COMPLETED', 'EVALUATED'}
createDataset             = 0;                      % Create dataset for further analysis?

% Channel-related params --------------------------------------------------
channelFadingTag          = 'PalomarVerdu';         %{'PalomarVerdu', 'ComplexRayleighIid', 'RealRayleighIid'}
channelMat                = generateFadingChannel(channelFadingTag, 2, 2);
[nRx, nTx]                = size(channelMat);       % sizes of the channel matrix
channelTag                = [num2str(nTx), 'x', num2str(nRx), channelFadingTag];
snrDbMin                  = -20;                    % lower SNR in dB
snrDbMax                  = 20;                     % higher SNR in dB
nSnrPoints                = 7;                      % number of SNR points in dB
snrDbVec                  = linspace(snrDbMin, snrDbMax, nSnrPoints);

% Optimization-related params ---------------------------------------------
if strcmp(simMode, 'QUICK')
  nItersMax               = 10;                   % max number of outer-loop iters for the precoder optimization loop
  nNoImprovementsMax      = 5;                    % max number of allowed outer-loop iters w/o improvement of MI value
  nBackOffsMax            = 2;                    % max number of allowed back-offs when stuck w/o improvement of MI value
  backOffSize             = 1;                    % back-off size
  nItersSignalMi          = 10;                   % size of the inner loop for MI computation
  nItersNoiseMi           = 10;                   % size of the outer loop for MI computation
  nItersSignalMmse        = 10;                   % size of the inner loop for MMSE computation
  nItersNoiseMmse         = 10;                   % size of the outer loop for MMSE computation
elseif strcmp(simMode, 'FULL')
  nItersMax               = 100;                  % max number of outer-loop iters for the precoder optimization loop
  nNoImprovementsMax      = 2;                    % max number of allowed outer-loop iters w/o improvement of MI value
  nBackOffsMax            = 2;                    % max number of allowed back-offs when stuck w/o improvement of MI value
  backOffSize             = 2;                    % back-off size
  nItersSignalMi          = 1e3;                  % size of the inner loop for MI computation
  nItersNoiseMi           = 1e3;                  % size of the outer loop for MI computation
  nItersSignalMmse        = 1e3;                  % size of the inner loop for MMSE computation
  nItersNoiseMmse         = 1e3;                  % size of the outer loop for MMSE computation
else
  error('ERROR! Unknown sim mode!');
end

% Setup default sim param structure ---------------------------------------
% (Default sim case)
defaultSimParamStruct.channel.channelMatReal                  = real(channelMat);
defaultSimParamStruct.channel.channelMatImag                  = imag(channelMat);
defaultSimParamStruct.channel.nTxAntennas                     = nTx;
defaultSimParamStruct.channel.nRxAntennas                     = nRx;
defaultSimParamStruct.channel.channelTag                      = channelTag;
defaultSimParamStruct.channel.snrDbVec                        = snrDbVec;
defaultSimParamStruct.optimization.nItersMax                  = nItersMax;
defaultSimParamStruct.optimization.nNoImprovementsMax         = nNoImprovementsMax;
defaultSimParamStruct.optimization.nBackOffsMax               = nBackOffsMax;
defaultSimParamStruct.optimization.backOffSize                = backOffSize;
defaultSimParamStruct.computation.nItersSignalMi              = nItersSignalMi;
defaultSimParamStruct.computation.nItersNoiseMi               = nItersNoiseMi;
defaultSimParamStruct.computation.nItersSignalMmse            = nItersSignalMmse;
defaultSimParamStruct.computation.nItersNoiseMmse             = nItersNoiseMmse;
defaultSimParamStruct.signaling.typeModulation                = 'QPSK';
defaultSimParamStruct.cluster.runOnCluster                    = runOnCluster;
defaultSimParamStruct.cluster.simMode                         = simMode;
defaultSimParamStruct.cluster.comment                         = comment;
defaultSimParamStruct.cluster.nOrderCasesMax                  = nOrderCasesMax;
defaultSimParamStruct.cluster.evaluateTrueMiMeanwhile         = evaluateTrueMiMeanwhile;
defaultSimParamStruct.cluster.status                          = status;
defaultSimParamStruct.cluster.createDataset                   = createDataset;
defaultSimParamStruct.cluster.stepThresholdPercent            = stepThresholdPercent;

% =========================================================================

% Define simulation cases #################################################
% (uncomment and configure setups for which we want to run optimization)
simCaseParamStructs = {};

% % 
% % Case #1
% % MI computation via Gaussian signaling
% simCaseParamStructs{end+1} = {};
% simCaseParamStructs{end}.plotting.legendEntry                = 'Capacity';
% simCaseParamStructs{end}.plotting.lineType                   = '--';
% simCaseParamStructs{end}.plotting.lineMarker                 = 'none';
% simCaseParamStructs{end}.plotting.lineColor                  = [0, 0, 0];
% simCaseParamStructs{end}.signaling.typeModulation            = 'GAUSS';
% simCaseParamStructs{end}.computation.methodComputationMi     = 'GAUSS';
% simCaseParamStructs{end}.computation.methodComputationMmse   = 'GAUSS';
% simCaseParamStructs{end}.cluster.runOnCluster                = 0;
% nSnrPoints = 41;
% simCaseParamStructs{end}.channel.snrDbVec                    = linspace(snrDbMin, snrDbMax, nSnrPoints);

% Case #2
% MI computation w/o precoding
simCaseParamStructs{end+1} = {};
simCaseParamStructs{end}.plotting.legendEntry                = 'No precoder';
simCaseParamStructs{end}.plotting.lineType                   = '-.';
simCaseParamStructs{end}.plotting.lineMarker                 = 'none';
simCaseParamStructs{end}.plotting.lineColor                  = [0, 0, 1];
simCaseParamStructs{end}.computation.methodComputationMi     = 'NONE';
nSnrPoints = 25;
simCaseParamStructs{end}.channel.snrDbVec                    = linspace(snrDbMin, snrDbMax, nSnrPoints);

% % Case #3
% % MI computation via Gaussian signaling
% simCaseParamStructs{end+1} = {};
% simCaseParamStructs{end}.plotting.legendEntry                = 'Water filling';
% simCaseParamStructs{end}.plotting.lineType                   = '-';
% simCaseParamStructs{end}.plotting.lineMarker                 = 'none';
% simCaseParamStructs{end}.plotting.lineColor                  = [0.5, 0.5, 0.5];
% % simCaseParamStructs{end}.signaling.typeModulation            = 'GAUSS';
% simCaseParamStructs{end}.computation.methodComputationMi     = 'GAUSS_OPT';
% nSnrPoints = 41;
% simCaseParamStructs{end}.channel.snrDbVec                    = linspace(snrDbMin, snrDbMax, nSnrPoints);


% % Case #3
% % MI computation via true exhaustive averaging
% simCaseParamStructs{end+1} = {};
% simCaseParamStructs{end}.plotting.legendEntry                = 'True optimum';
% simCaseParamStructs{end}.plotting.lineType                   = '-';
% simCaseParamStructs{end}.plotting.lineMarker                 = 'o';
% simCaseParamStructs{end}.plotting.lineColor                  = [0.5273, 0.8047, 0.9180];
% simCaseParamStructs{end}.computation.methodComputationMi     = 'TRUE';
% simCaseParamStructs{end}.computation.methodComputationMmse   = 'TRUE';
% nSnrPoints = 13;
% simCaseParamStructs{end}.channel.snrDbVec                    = linspace(snrDbMin, snrDbMax, nSnrPoints);
% simCaseParamStructs{end}.cluster.evaluateTrueMiMeanwhile     = 1;

% % Case #3.5
% % Create dataset
% nRuns = 1000;
% for iRun = 1:nRuns
%   % MI computation via Gaussian signaling
%   simCaseParamStructs{end+1} = {};
%   H = generateFadingChannel(channelFadingTag, 2, 2);
%   simCaseParamStructs{end}.channel.channelMatReal              = real(H);
%   simCaseParamStructs{end}.channel.channelMatImag              = imag(H);
%   simCaseParamStructs{end}.plotting.legendEntry                = ['TRUE_', num2str(iRun)] ;
%   simCaseParamStructs{end}.plotting.lineType                   = '-';
%   simCaseParamStructs{end}.plotting.lineMarker                 = 'o';
%   simCaseParamStructs{end}.plotting.lineColor                  = [0.5273, 0.8047, 0.9180];
%   simCaseParamStructs{end}.computation.methodComputationMi     = 'TRUE';
%   simCaseParamStructs{end}.computation.methodComputationMmse   = 'TRUE';
%   simCaseParamStructs{end}.signaling.typeModulation            = 'BPSK';
%   nSnrPoints = 7;
%   simCaseParamStructs{end}.channel.snrDbVec                    = linspace(snrDbMin, snrDbMax, nSnrPoints);
%   simCaseParamStructs{end}.cluster.createDataset               = 1;
% end


% % Case #4
% % MI computation via Zhu et al.
% simCaseParamStructs{end+1} = {};
% simCaseParamStructs{end}.plotting.legendEntry                = 'Zhu et al. [10]';
% simCaseParamStructs{end}.plotting.lineType                   = '-';
% simCaseParamStructs{end}.plotting.lineMarker                 = 'x';
% simCaseParamStructs{end}.plotting.lineColor                  = [1, 0.6445, 0];
% simCaseParamStructs{end}.computation.methodComputationMi     = 'ZHU_SHI_FARHANG';
% simCaseParamStructs{end}.computation.methodComputationMmse   = 'TRUE';
% nSnrPoints = 13;
% simCaseParamStructs{end}.channel.snrDbVec                    = linspace(snrDbMin, snrDbMax, nSnrPoints);
% 

% % Case #5
% % MI computation via integral approx
% simCaseParamStructs{end+1} = {};
% simCaseParamStructs{end}.plotting.legendEntry                = 'Zeng et al. [11]';
% simCaseParamStructs{end}.plotting.lineType                   = '--';
% simCaseParamStructs{end}.plotting.lineMarker                 = '+';
% simCaseParamStructs{end}.plotting.lineColor                  = [0.5, 0, 0.5];
% simCaseParamStructs{end}.computation.methodComputationMi     = 'ZENG_XIAO_LU';
% simCaseParamStructs{end}.computation.methodComputationMmse   = 'TRUE';
% nSnrPoints = 13;
% simCaseParamStructs{end}.channel.snrDbVec                    = linspace(snrDbMin, snrDbMax, nSnrPoints);

% Case #6
% MI computation via ML-model predicted
simCaseParamStructs{end+1} = {};
simCaseParamStructs{end}.plotting.legendEntry                = 'DL-based';
simCaseParamStructs{end}.plotting.lineType                   = '--';
simCaseParamStructs{end}.plotting.lineMarker                 = 's';
simCaseParamStructs{end}.plotting.lineColor                  = [1, 0, 0];
simCaseParamStructs{end}.computation.methodComputationMi     = 'ML_PREDICTED';
nSnrPoints = 13;
simCaseParamStructs{end}.channel.snrDbVec                    = linspace(snrDbMin, snrDbMax, nSnrPoints);

% #########################################################################

% =========================================================================

% Run simulations ---------------------------------------------------------

% Create sim folder if it does not exist
simName           = defaultSimParamStruct.cluster.simName;
simDataPath       = defaultSimParamStruct.cluster.simDataPath;
simFolderPath     = defaultSimParamStruct.cluster.simFolderPath;
simParamFileName  = ['params_', simName, '.mat'];
simParamFilePath  = [simFolderPath, '\', simParamFileName];
if (~exist(simFolderPath))
  mkdir(simFolderPath);
end

% Fill in param structs for picked sim cases
nSimCases = length(simCaseParamStructs);
for iSimCase = 1:nSimCases
  simCaseParamStructs{iSimCase}.cluster.caseIdx = iSimCase;
  simCaseParamStructs{iSimCase} =...
    overrideStruct(defaultSimParamStruct, simCaseParamStructs{iSimCase});
end % for iSimCase = 1:nSimCases

% Save all params to mat-file
save(simParamFilePath, 'simCaseParamStructs');

% Dispatch simulations
for iSimCase = 1:nSimCases
  if strcmp(simCaseParamStructs{iSimCase}.signaling.typeModulation, 'GAUSS') 
    % Waterfilling computation
    fprintf('\nRun water-filling locally... \n\n');
    optimizePrecoderMimoGauss(simCaseParamStructs{iSimCase});
    fprintf('DONE!\n');
  elseif strcmp(simCaseParamStructs{iSimCase}.computation.methodComputationMi, 'ML_PREDICTED') 
    % ML predicted precoder based on a trained neural net
    fprintf('\nPredict precoder locally... \n\n');
    optimizePrecoderMimoMl(simCaseParamStructs{iSimCase});
    fprintf('DONE!\n');
  elseif strcmp(simCaseParamStructs{iSimCase}.computation.methodComputationMi, 'NONE') 
    % No precoding at all
    fprintf('\nSet omni precoder locally... \n\n');
    setOmniPrecoderMimo(simCaseParamStructs{iSimCase});
    fprintf('DONE!\n');
  elseif (simCaseParamStructs{iSimCase}.cluster.runOnCluster)
    % Running sim on cluster
    error('\nERROR! Functionality not supported!\n\n');
  else
    % Local running of all other types of sims
    fprintf('\nRun new simulation locally... \n\n');
    runSimsLocally(simCaseParamStructs{iSimCase}, operationType);
    fprintf('DONE!\n');
  end
end % for iSimCase = 1:nSimCases

end



