function [E, time] = mmseMatrixMimoGauss(Hmat)
%
% MMSEMATRIXMIMOGAUSS Computes the MMSE matrix of a MIMO channel with 
% complex noise and Gaussian inputs.
%
%     Inputs:     mat Hmat = MIMO channel matrix
%     Outputs:    mat E = MMSE matrix of the MIMO channel
%                 scalar t = computation time
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

M = size(Hmat, 2);

timeBegin = cputime; % start clock

E = eye(M) / (eye(M) + (Hmat'*Hmat));

timeEnd = cputime; % end clock

time = (timeEnd-timeBegin)/60; % computation time

end
