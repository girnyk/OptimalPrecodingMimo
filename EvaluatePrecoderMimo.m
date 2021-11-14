% =========================================================================
%
% Deep-learning based MIMO precoding for finite-alphabet signaling
%
% Low-complexity linear precoding for MIMO channels with discrete inputs
% Precoder performance evaluation
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

function EvaluatePrecoderMimo

clear all; close all; clc;

% Add all the subfolders to the path.
currentFilePath = fileparts(which(mfilename));
addpath(genpath(currentFilePath));
functionsPath           = [pwd, '\Functions'];
simDataPath             = [pwd, '\SimData'];
visualsPath             = [pwd, '\Results'];

% =========================================================================

% Select sim number to evaluate ###########################################

% simId = 190414153606; % either a case or an entire sim?
% simId = 210419001433; % 2x2, BPSK
% simId = 210215010426; % 2x2, QPSK
% simId = 210217134641; % 3x3, BPSK
% simId = 210322192102; % 3x3, QPSK
% simId = 210317170605; % 3x3, QPSK
% simId = 210420230928; % Net: 2x2, BPSK
% simId = 210417162402; % Net: 2x2, 8PSK
% simId = 210417004809; % Net: 2x2, QPSK
% simId = 210417155326; % Net: 3x3, BPSK
simId = 211115003222;

% Find sim folder and param file ------------------------------------------
simName = num2str(simId);
simFolderPath = [simDataPath, '\', simName];
paramFileName = ['params_', simName, '.mat'];
paramFilePath = [simFolderPath, '\', paramFileName];
load(paramFilePath);
nSimCases = length(simCaseParamStructs);

% Dispatch simulations ----------------------------------------------------
operationType = 'EVALUATION';
for iSimCase = 1:nSimCases
  if strcmp(simCaseParamStructs{iSimCase}.signaling.typeModulation, 'GAUSS')
    % Do nothing for the Gaussian case (already evaluated)
    simCaseParamStructs{1}.cluster.status = 'EVALUATED';
  else
    if (simCaseParamStructs{iSimCase}.cluster.runOnCluster)
      error('ERROR! Execution on cluster not supported!');
    else
      fprintf('\nRun new simulation locally... \n\n');
      runSimsLocally(simCaseParamStructs{iSimCase}, operationType);
      fprintf('DONE!\n');
    end
  end
end % for iSimCase = 1:nSimCases

end



