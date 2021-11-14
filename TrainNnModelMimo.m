% =========================================================================
%
% Deep-learning based MIMO precoding for finite-alphabet signaling
%
% Low-complexity linear precoding for MIMO channels with discrete inputs
% Training of a neural network
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

function TrainNnModelMimo

% Clear and close everything
clear all; clc; close all; fclose('all');

% Add all the subfolders to the path.
currentFilePath = fileparts(which(mfilename));
addpath(genpath(currentFilePath));
simDataPath   = [pwd, '\SimData'];

% Set data and params for neural nets

% 2x2 BPSK
modName = 'Bpsk';
mimoSetup = '2x2';
simNames = {190716111048, 210409160456, 210411002555, 210413235054, 210425005012};
nEpochs = 3e2;
learnRate = 0.0025;
miniBatchSize = 10;

% % 2x2 QPSK
% modName = 'Qpsk';
% mimoSetup = '2x2';
% simNames = {210213125113, 210212000423, 210419010351};
% nEpochs = 3e2;
% learnRate = 0.0025;
% miniBatchSize = 10;

% % 3x3 BPSK
% modName = 'Bpsk';
% mimoSetup = '3x3';
% simNames = {210328011048, 210418003001};
% nEpochs = 3e2;
% learnRate = 0.0025;
% miniBatchSize = 10;

% % 3x3 QPSK
% modName = 'Qpsk';
% mimoSetup = '3x3';
% simNames = {210317170605, 210413020311, 210421180930, 210421091536};
% learnRate = 0.005;
% nEpochs = 5e2;
% miniBatchSize = 10;

fprintf('================================================================================================================\n');
fprintf('Load data... ');

nSimNames = length(simNames);
if (nSimNames==1)
  if iscell(simNames)
    if (isa(simNames{1}, 'double'))
      simNames{1} = num2str(simNames{1});
    end
    delimiter = regexp(simNames{1}, '_');
    if isempty(delimiter)
      isSingleSim = 1;
    end
  else
    if (isa(simNames, 'double'))
      simNames = num2str(simNames);
    end
    delimiter = regexp(simNames, '_');
    if isempty(delimiter)
      isSingleSim = 1;
    end
  end
else
  isSingleSim = 0;
end

nTestObs = 0;

[simCaseNameList, simNameList] = parseSimIds(simNames);
nSimCases = length(simCaseNameList);

% Infer the required data
dataStruct = {};
for iSimCase = nTestObs+1:nSimCases
  simFolderPath = [simDataPath, '\', simNameList{iSimCase}];
  caseSubfolderPath = [simFolderPath, '\' simCaseNameList{iSimCase}];
  fileList = dir([caseSubfolderPath, '\*.mat']);
  nFiles = length(fileList);
  for iFile = 1:nFiles
    simFileName = fileList(iFile).name;
    simFilePath = [caseSubfolderPath, '\', simFileName];
    if (exist(simFilePath))
      load(simFilePath);
    end
    if (isfield(simCaseStruct, 'performance')) && (isfield(simCaseStruct, 'precoding'))
      dataStruct{end+1} = {};
      dataStruct{end}.miBpcu = simCaseStruct.performance.miBpcu;
      dataStruct{end}.precoderReal = simCaseStruct.precoding.precoderReal;
      dataStruct{end}.precoderImag = simCaseStruct.precoding.precoderImag;
      dataStruct{end}.snrDb = simCaseStruct.channel.currentSnrDb;
      dataStruct{end}.channelMatReal = simCaseStruct.channel.channelMatReal;
      dataStruct{end}.channelMatImag = simCaseStruct.channel.channelMatImag;
      dataStruct{end}.nTxAntennas = simCaseStruct.channel.nTxAntennas;
      dataStruct{end}.nRxAntennas = simCaseStruct.channel.nRxAntennas;
      dataStruct{end}.typeModulation = simCaseStruct.signaling.typeModulation;
      dataStruct{end}.timestamp = simNameList{iSimCase};
    end
    clear simCaseStruct
  end
end

fprintf('DONE!\n');


fprintf('Construct dataset... ');

% Construct the dataset: create features and labels
dataset = {};
nObservations = length(dataStruct);
for iObservation = 1:nObservations
  dataset{end+1} = {};
  dataset{end}.nTxAntennas = dataStruct{iObservation}.nTxAntennas;
  dataset{end}.nRxAntennas = dataStruct{iObservation}.nRxAntennas;
  snr = 10^(dataStruct{iObservation}.snrDb/10);
  dataset{end}.snrDb = dataStruct{iObservation}.snrDb;
  channelMat = sqrt(snr/dataset{end}.nTxAntennas) * (dataStruct{iObservation}.channelMatReal + 1i*dataStruct{iObservation}.channelMatImag);
  dataset{end}.channelVec = convertComplexMatToRealVec(channelMat);
  precoderWf = getWfPrecoder(channelMat);
  dataset{end}.precoderVecWf = convertComplexMatToRealVec(precoderWf);
  precoderDiscrete = dataStruct{iObservation}.precoderReal + 1i*dataStruct{iObservation}.precoderImag;
  dataset{end}.precoderVecDiscrete = convertComplexMatToRealVec(precoderDiscrete);
  dataset{end}.miBpcu = dataStruct{iObservation}.miBpcu;
  dataset{end}.timestamp = dataStruct{iObservation}.timestamp;
  dataset{end}.typeModulation = dataStruct{iObservation}.typeModulation;
end

fprintf('DONE!\n');

fprintf('Train neural net... \n');

% Split data for training and testing
trainShare = 0.8;
[trainSet, testSet] = splitDataset(dataset, trainShare);


% Define and create neural net
inputSize = length(dataset{end}.precoderVecWf);         % 2*vec(G_wf) - size of input
outputSize = length(dataset{end}.precoderVecDiscrete);  % 2*vec(G_disc) - size of output
layerSizes = [inputSize, 2*inputSize, 2*inputSize, outputSize];      % 1 hidden layer with double the size
activationType = 'tanh';
neuralNet = setupNeuralNet(layerSizes, activationType);

% Run the SGD to train and evaluate neural net
[neuralNet, mseTrain, mseValid] = trainAndTestNeuralNet(neuralNet, trainSet, nEpochs, miniBatchSize, learnRate, testSet);

fprintf('DONE!\n');

fprintf('Save neural net... ');

% save the neural net
netsPath = [pwd, '\TrainedNets'];
% Create the case subfolder
if (~exist(netsPath))
  mkdir(netsPath);
end
netsPath = [pwd, '\TrainedNets'];
netFileName = ['nnWeights', modName, mimoSetup, 'Mimo.mat'];
save([netsPath, '\', netFileName], 'neuralNet');

fprintf('DONE!\n');

end