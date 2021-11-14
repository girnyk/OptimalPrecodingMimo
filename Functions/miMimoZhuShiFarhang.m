function [I, t] = miMimoZhuShiFarhang(Hmat, typeModulation, typeSampling, nIterSignal, nIterNoise)
%
% MIMIMOZHUSHIFARHANG Computes the mutual info of a MIMO channel with 
% complex noise finite-alphabet inputs, based on the low-complexity 
% approximation proposed in:
%  H. Zhu, Z. Shi, B. Farhang-Beroujeny, and C. Schlegel, “An efficient
%  statistical approach for calculation of capacity of MIMO channels.” in
%  Proc. IASTED WOC, 2003, pp. 149-154.
%
%     Inputs:     mat Hmat = MIMO channel matrix
%                 str typeModulation = type of signal constellation
%                 str typeSampling = type of averaging over the signals: EXHAUSTIVE/RANDOMIZED
%                 scalar nIterSignal = number of iters for avg over signals
%                 scalar nIterNoise = number of iters for avg over noise
%     Outputs:    scalar I = mutual info between input and output
%                 scalar t = computation time
%
% Max Girnyk
% Stockholm, 2014-10-01
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

% Determine the size of the channel matrix
[N, M] = size(Hmat);

% Form the signal constellation
Sset  = modulationFiniteAlphabet(typeModulation);   % signal constellation
lSset = length(Sset);                               % size of the constellation

% Determine the size of the search
switch(typeSampling)
  case 'EXHAUSTIVE'
    % True averaging over all possible signal constellation points
    nSymbolVecs = lSset^M;
  case 'RANDOMIZED'
    % Averaging by random sampling of constellation points
    nSymbolVecs = nIterSignal;
end

timeBegin = cputime; % start clock

% Average over noise and signal and compute MI
% Loop over true signal (x0, giving y = H x0 + n) -------------------------
entropyNoise = zeros(nIterSignal, 1);
for iTrueSymbolVec = 1:nSymbolVecs
  % Sample modulated symbols for averaging over signal vector
  switch(typeSampling)
    case 'EXHAUSTIVE'
      % Create a combination of symbols over antennas
      modIndex = convertDecToBin(iTrueSymbolVec-1, M, lSset).'; % on-the-fly loop over all combs of symbol vecs
    case 'RANDOMIZED'
      % Pick symbols randomly
      modIndex = randi([1 lSset], M, 1) - 1;        % random selection of symbol vecs
  end
  x = Sset(modIndex+1).'; % Pick constellation point for true signal
  
  % Loop over noise (n) ---------------------------------------------------
  logProbDensityRxSignal = zeros(nIterNoise, 1);
  for iIterNoise = 1:nIterNoise
    n = sqrt(1/2) * (randn(N,1) + 1j*randn(N,1));   % complex noise
    y = Hmat * x + n;                               % Rx signal/output

    % Statistical Approximated (SA) method:
    % (1) Approximation function for low SNR, see (5) in Zhu et al. - Proc. IASTED WOC 2003
    probDensityRxSignalLow = 1/(pi^N * det(Hmat*Hmat' + eye(N))) * exp(-y' / (Hmat*Hmat' + eye(N)) * y);
    % (2) Approximation function for high SNR, see (6) in Zhu et al. - Proc. IASTED WOC 2003
    probDensityRxSignalHigh = 1/(lSset^M*pi^N) * exp(-norm(y-Hmat*x)^2);
    % Approximation function: log(max{(1), (2)})
    logProbDensityRxSignal(iIterNoise) = log(max(probDensityRxSignalLow, probDensityRxSignalHigh));
  
  end % for n = 1:nIterY
  
  % Approximated entropy of y for given x
  entropyNoise(iTrueSymbolVec) = - sum(logProbDensityRxSignal) / nIterNoise;

end % for j = 1:nIterX

% Approximated entropy of y
entropyOutput = sum(entropyNoise) / nSymbolVecs;

% Compute the approximation for normalized MI [bpcu/dim]
I = real(entropyOutput - N*(log(pi) + 1)) / M / log(2);    %  -E_y ln E_x p(y|Hx) - E_y,x ln p(y|Hx)

timeEnd = cputime; % stop clock

% Comnpute time elapsed
t = (timeEnd - timeBegin)/60;

end