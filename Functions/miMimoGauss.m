function [I, t] = miMimoGauss(Hmat)
%
% MIMIMOGAUSS Computes the mutual info of a MIMO channel with complex noise 
% and Gaussian inputs.
%
%     Inputs:     mat Hmat = MIMO channel matrix
%     Outputs:    scalar I = mutual info between input and output
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

% Channel matrix size
[N, M] = size(Hmat);

timeBegin = cputime; % start clock

% Shannon's formula
I = real(log(det(eye(N) + (Hmat*Hmat')))) / M / log(2);

timeEnd = cputime; % stop clock

% Compute time elapsed
t = (timeEnd-timeBegin)/60; 

end