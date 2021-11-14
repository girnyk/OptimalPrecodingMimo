function [I, t] = computeMiMimo(channelMat, typeModulation, methodComputation, methodSampling, nIterSignal, nIterNoise)
%
% COMPUTEMIMIMO Computes mutual information for a MIMO channel for a given
% approach by calling the respective algorithm.
%
%     Inputs:     mat channelMat = MIMO channel matrix
%                 str typeModulation = modulation scheme
%                 str methodComputation = method of MI matrix computation
%                 str methodSampling = method of sampling: EXHAUSTIVE/RANDOMIZED
%                 scalar nIterSignal = number of samples for averaging over signal
%                 scalar nIterNoise = number of smaples for averaging over noise
%     Outputs:    scalar I = mutual info
%                 scalar t = time elapsed
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

% Call respective functions for the MI computation
switch methodComputation
  case 'GAUSS'
    [I, t] = miMimoGauss(channelMat);
  case 'GAUSS_CAPPED'
    error('ERROR! Implementation of method %s is missing!', methodComputation);
  case 'TRUE'
    [I, t] = miMimoTrue(channelMat, typeModulation, methodSampling, nIterSignal, nIterNoise);
  case 'KRASKOV_STOGBAUER_GRASSBERGER'
    error('ERROR! Implementation of method %s is missing!', methodComputation);
  case 'KOZACHENKO_LEONENKO'
    error('ERROR! Implementation of method %s is missing!', methodComputation);
  case 'EDGEWORTH'
    error('ERROR! Implementation of method %s is missing!', methodComputation);
  case 'ZHANG_CHEN_TAN'
    error('ERROR! Implementation of method %s is missing!', methodComputation);
  case 'GAUSS_HERMITE'
    error('ERROR! Implementation of method %s is missing!', methodComputation);
  case 'ZHU_SHI_FARHANG'
    [I, t] = miMimoZhuShiFarhang(channelMat, typeModulation, methodSampling, nIterSignal, nIterNoise);
  case 'HAMMING_DISTANCE_1'
    error('ERROR! Implementation of method %s is missing!', methodComputation);
  case 'ZENG_XIAO_LU'
    [I, t] = miMimoZengXiaoLu(channelMat, typeModulation, methodSampling, nIterSignal);
end

end