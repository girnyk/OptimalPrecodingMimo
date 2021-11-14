function mu = backtrackingLineSearchDirection(alpha, beta, Hbar, typeModulation, methodComputation, methodSampling, nIterSignal, nIterNoise)
%
% BACKTRACKINGLINESEARCHDIRECTION Line-search backtracking algorithm for
% optimizing the step size of the gradient ascent method to practically good 
% value (applied to the eigenvector matrix). The computation is done
% according to Alg. 9.2 in Ch. 9 of the following book:
%  B. Boyd and L. Vandenberghe, Convex Optimization, Cambridge University
%  Press, 2004.
%
%     Inputs:     scalar alpha = backtracking parameter
%                 scalar beta = step size decrement
%                 max Hbar = channel matrix 
%                 str typeModulation = modulation scheme
%                 str methodComputation = method of MI matrix computation
%                 str methodSampling = method of sampling: EXHAUSTIVE/RANDOMIZED
%                 scalar nIterSignal = number of samples for averaging over signal
%                 scalar nIterNoise = number of smaples for averaging over noise
%     Outputs:    scalar mu = optimal step size
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

% Compute MI and MMSE matrix for further evaluations
[I, ~] = computeMiMimo(Hbar, typeModulation, methodComputation, methodSampling, nIterSignal, nIterNoise);
[E, ~] = mmseMatrixMimoTrue(Hbar, typeModulation, methodSampling, nIterSignal, nIterNoise);

% Quadratic form for the cahnnel matrix
Wbar = Hbar' * Hbar;

% "Bisect" the step size
mu = 1/beta;                % starting value, so that we start with mu = 1
proceedWithLoop = 1;        % conditional for proceeding with the loop
iLoop = 1;                  % index for limiting the max number of loops
nLoopMax = 10;              % max number of loops

while proceedWithLoop
  mu = mu * beta;           % update the step size  
  
  % Gradient update the Gram matrix
  Wbar_new = Wbar + mu*E;
  [U_new, Lambda_new] = eig(Wbar_new);
  Hbar_new = sqrt(Lambda_new)*U_new'; % obtain Hbar from Wbar
  
  % Compute the MI value for the given step size
  [I_new, ~] = computeMiMimo(Hbar_new, typeModulation, methodComputation, methodSampling, nIterSignal, nIterNoise);
  
  % Check whether the step size is suitable (Boyd's book)
  proceedWithLoop = (I_new <= I + alpha*mu*E(:)'*E(:)) && (iLoop <= nLoopMax);
  iLoop = iLoop + 1;
  
end % while proceedWithLoop
