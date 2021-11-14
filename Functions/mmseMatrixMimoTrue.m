function [E, iIterNoise] = mmseMatrixMimoTrue(Hmat, typeModulation, typeSampling, nIterSignal, nIterNoise)
%
% MMSEMATRIXMIMOGAUSS Compute the MMSE matrix (error covariance) of a 
% MIMO channel with complex noise and finite-alphabet inputs, according to:
%  C. Xiao, Y. R. Zeng, "Transmit precoding for MIMO systems with
%  partial CSI and discrete-constellation inputs," in Proc. ICC, 2009.
%
%     Inputs:     mat Hmat = MIMO channel matrix
%                 str typeModulation = type of signal constellation
%                 str typeSampling = type of averaging over the signals: EXHAUSTIVE/RANDOMIZED
%                 scalar nIterSignal = number of iters for avg over signals
%                 scalar nIterNoise = number of iters for avg over noise
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

% Channel matrix sizes
[N, M] = size(Hmat);

Sset = modulationFiniteAlphabet(typeModulation);    % signal constellation
lSset = length(Sset);                               % size of the constellation

% Sample modulated symbols for averaging over signal vector
switch(typeSampling)
  case 'EXHAUSTIVE'
    % Create a combination of symbols over antennas
    nSymbols = lSset^M;
    modIndex = convertDecToBin([0:nSymbols-1], M, lSset).';
  case 'RANDOMIZED'
    % Pick symbols randomly
    nSymbols = nIterSignal;
    modIndex = randi([1 lSset], M, nIterSignal) - 1;
end
x = Sset(modIndex+1);  % pick constellation point

timeBegin = cputime; % start clock

% Loop over noise (n) -----------------------------------------------------
sumOverNoise = zeros(M,M);
for iIterNoise = 1 : nIterNoise
  n = 1/sqrt(2)*(randn(N,1) + 1i*randn(N,1));
  sumOverTrueSignal = zeros(M,M);
  
  % Loop over true signal (x0, giving y = H x0 + n) -----------------------
  for iTrueSymbolVec = 1 : nSymbols
    sumOverSignal = zeros(M,1);
    sumOverProbRxSignal = 0;
    
    % Loop over signal (x) ------------------------------------------------
    for iSymbolVec = 1 : nSymbols
      sumOverSignal = sumOverSignal + x(:,iSymbolVec)*exp(-norm(Hmat*(x(:,iTrueSymbolVec)-x(:,iSymbolVec)) + n)^2); 
      sumOverProbRxSignal = sumOverProbRxSignal + exp(-norm(Hmat*(x(:,iTrueSymbolVec)-x(:,iSymbolVec)) + n)^2); 
    end % for iSymbolVec = 1 : nSymbols
    
  sumOverTrueSignal = sumOverTrueSignal + (sumOverSignal)*sumOverSignal'/sumOverProbRxSignal^2;
  end % for iTrueSymbolVec = 1 : nSymbols
  
  sumOverNoise = sumOverNoise + sumOverTrueSignal / nSymbols;
end % for iIterNoise = 1 : nIterNoise

% Compute MMSE matrix
E = eye(M) - sumOverNoise / nIterNoise;

timeEnd = cputime; % stop clock

iIterNoise = (timeEnd - timeBegin)/60; % compute execution time

end

