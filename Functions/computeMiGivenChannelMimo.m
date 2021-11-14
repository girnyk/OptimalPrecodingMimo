function computeMiGivenChannelMimo(simParamFilePath)
%
% COMPUTEMIGIVENCHANNELMIMO Computes mutual information for a MIMO channel 
% for a given approach given a channel matrix by calling the respective 
% algorithm.
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

% Channel-related params --------------------------------------------------
snrIdxCurrent           = simCaseStruct.channel.snrIdxCurrent;
M                       = simCaseStruct.channel.nTxAntennas;
N                       = simCaseStruct.channel.nRxAntennas;

% Computation-related params ----------------------------------------------
methodSamplingMi        = simCaseStruct.computation.methodSamplingMi;
methodComputationMi     = simCaseStruct.computation.methodComputationMi;
methodSamplingMmse      = simCaseStruct.computation.methodSamplingMmse;
methodComputationMmse   = simCaseStruct.computation.methodComputationMmse;

% Container for precoders -------------------------------------------------
G                       = simCaseStruct.precoding.precoder;

snrDb       = simCaseStruct.channel.currentSnrDb; % current SNR point
snr         = 10^(snrDb/10);                      % SNR in linear scale
H           = sqrt(snr/M)*channelMat;             % incorporate SNR into channel matrix

fprintf('################################################################################################################\n');
fprintf('NEW COMPUTATION JOB\n');
fprintf('================================================================================================================\n');
fprintf('Scenario summary: \n');
fprintf('----------------------------------------------------------------------------------------------------------------\n');
fprintf(['Modulation type: \t\t\t\t\t', typeModulation, '\n']);
fprintf(['Signal-to-noise ratio: \t\t\t\t', num2str(snrDb), ' [dB]\n']);
fprintf([num2str(M), 'x', num2str(N), ' MIMO channel matrix: \n']);
printComplexMatrix(H);
fprintf('Precoder:\n');
printComplexMatrix(G);
fprintf(['Computation method MI: \t\t\t\t', methodComputationMi, '\n']);
fprintf(['Sampling method MI: \t\t\t\t', methodSamplingMi, '\n']);
fprintf(['Computation method MMSE: \t\t\t', methodComputationMmse, '\n']);
fprintf(['Sampling method MMSE: \t\t\t\t', methodSamplingMmse, '\n']);
fprintf('================================================================================================================\n');
fprintf('COMPUTATION START... ');
[miFinal, timeFinal] = computeMiMimo(H*G, typeModulation, 'TRUE', 'EXHAUSTIVE', 1e3, 2e3); 
fprintf('DONE!\n');
fprintf('================================================================================================================\n');
fprintf(['mutual info: ', num2str(miFinal), ' [bpcu]\n\n']);

% Containers for performance metrics --------------------------------------
simCaseStruct.performance.miBpcu                = miFinal;
simCaseStruct.performance.timeElapsedSec        = timeFinal;

% Save performance to file --------------------------------------
save(simCaseStruct.cluster.matFileName, 'simCaseStruct');

end