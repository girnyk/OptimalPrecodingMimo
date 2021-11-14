function optimizePrecoderMimo(simParamFilePath)
%
% OPTIMIZEPRECODERMIMO Optimal linear precoder, computed according
% to the algorithm originally proposed in:
%  M. Lamarca, "Linear precoding for mutual information maximization in
%  MIMO systems," in Proc. ISWCS, 2009, pp. 26–30.
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

% Read sim params list ----------------------------------------------------
caseName                = simCaseStruct.plotting.legendEntry;

% Signal-related params ---------------------------------------------------
typeModulation          = simCaseStruct.signaling.typeModulation;

% Channel-related params --------------------------------------------------
channelMatReal          = simCaseStruct.channel.channelMatReal;
channelMatImag          = simCaseStruct.channel.channelMatImag;
M                       = simCaseStruct.channel.nTxAntennas;
N                       = simCaseStruct.channel.nRxAntennas;
channelTag              = simCaseStruct.channel.channelTag;
snrDb                   = simCaseStruct.channel.currentSnrDb;

% Optimiation-related params ----------------------------------------------
nItersMax               = simCaseStruct.optimization.nItersMax;
nNoImprovementsMax      = simCaseStruct.optimization.nNoImprovementsMax;
nBackOffsMax            = simCaseStruct.optimization.nBackOffsMax;
backOffSize             = simCaseStruct.optimization.backOffSize;
stepThresholdPercent    = simCaseStruct.optimization.stepThresholdPercent;
a                       = simCaseStruct.optimization.forgettingParamMmse;
alpha_W                 = simCaseStruct.optimization.toleranceBacktrackingDirection;
beta_W                  = simCaseStruct.optimization.stepLengthBacktrackingDirection;
alpha_G                 = simCaseStruct.optimization.toleranceBacktrackingPower;
beta_G                  = simCaseStruct.optimization.stepLengthBacktrackingPower;

% Computation-related params ----------------------------------------------
methodSamplingMi        = simCaseStruct.computation.methodSamplingMi;
methodComputationMi     = simCaseStruct.computation.methodComputationMi;
methodSamplingMmse      = simCaseStruct.computation.methodSamplingMmse;
methodComputationMmse   = simCaseStruct.computation.methodComputationMmse;
nItersSignalMi          = simCaseStruct.computation.nItersSignalMi;
nItersNoiseMi           = simCaseStruct.computation.nItersNoiseMi;
nItersSignalMmse        = simCaseStruct.computation.nItersSignalMmse;
nItersNoiseMmse         = simCaseStruct.computation.nItersNoiseMmse;

% Cluster-related params --------------------------------------------------
nMiValuesBuffer         = simCaseStruct.cluster.nMiValuesBuffer;
evaluateTrueMiMeanwhile = simCaseStruct.cluster.evaluateTrueMiMeanwhile;

% Determine the size of the signal constellation --------------------------
switch(typeModulation)
  case 'BPSK'
    lSset = 2;
  case 'QPSK'
    lSset = 4;
  case '8PSK'
    lSset = 8;
  case '16QAM'
    lSset = 16;
  case '64QAM'
    lSset = 64;
  otherwise
    error('ERROR! Wrong signal constellation type!');
end;

% Init local params and vars ==============================================
snr         = 10^(snrDb/10);                  % current SNR in linear scale
H           = sqrt(snr/M) * (channelMatReal + 1i*channelMatImag); % incorporate SNR into channel matrix
Sigma_G     = eye(M);                         % init power allocation
mi          = NaN(1, nItersMax);              % init temp MI array

% Begin algorithm =========================================================

% SVD of the channel matrix
[~, Sigma_H, V_H] = svd(H, 'econ');

% Randomly initialized
Theta       = orth(randn(M, M));          % initial rotation matrix
precoder    = V_H * Sigma_G * Theta;      % init precoder matrix

% Compute MI and MMSE
miOpt       = computeMiMimo(H*precoder, typeModulation, methodComputationMi, methodSamplingMi, nItersSignalMi, nItersNoiseMi);
E           = mmseMatrixMimoTrue(H*precoder, typeModulation, methodSamplingMmse, nItersSignalMmse, nItersNoiseMmse);

fprintf('################################################################################################################\n');
fprintf(['NEW OPTIMIZATION JOB: \t\t\t\t', simCaseStruct.cluster.simName, '\n']);
fprintf('================================================================================================================\n');
fprintf('Scenario summary: \n');
fprintf('----------------------------------------------------------------------------------------------------------------\n');
fprintf(['Case name: \t\t\t\t\t\t\t', caseName, '\n']);
fprintf(['Modulation type: \t\t\t\t\t', typeModulation, '\n']);
fprintf(['Signal-to-noise ratio: \t\t\t\t', num2str(snrDb), ' [dB]\n']);
fprintf([num2str(M), 'x', num2str(N), ' MIMO channel matrix: \n']);
printComplexMatrix(H);
fprintf(['Computation method MI: \t\t\t\t', methodComputationMi, '\n']);
fprintf(['Sampling method MI: \t\t\t\t', methodSamplingMi, '\n']);
fprintf(['Computation method MMSE: \t\t\t', methodComputationMmse, '\n']);
fprintf(['Sampling method MMSE: \t\t\t\t', methodSamplingMmse, '\n']);
fprintf('================================================================================================================\n');
fprintf('OPTIMIZATION START...\n');
fprintf('================================================================================================================\n');

nNoImprovements = 0;
nBackOffs       = 0;
iIter           = 1;

timeBegin = cputime; % start clock

isSimFinished = (iIter >= nItersMax) || (nBackOffs >= nBackOffsMax);
while (~isSimFinished)
  fprintf(['Case name: \t\t\t\t\t\t\t', caseName, '\n']);
  fprintf('Iteration: \t\t\t\t\t\t\t%d / %d\n', iIter, nItersMax);
  fprintf('No improvement during: \t\t\t\t%d / %d\n', nNoImprovements, nNoImprovementsMax);
  fprintf('Number of back-offs: \t\t\t\t%d / %d\n', nBackOffs, nBackOffsMax);
  fprintf(['Computation method MI: \t\t\t\t', methodComputationMi, '\n']);
  fprintf(['Computation method MMSE: \t\t\t', methodComputationMmse, '\n']);
  fprintf(['SNR: \t\t\t\t\t\t\t\t', num2str(snrDb), ' [dB]\n']);
  fprintf(['Modulation type: \t\t\t\t\t', typeModulation, '\n']);
  fprintf(['Channel: \t\t\t\t\t\t\t', channelTag, '\n']);
  fprintf('----------------------------------------------------------------------------------------------------------------\n');

  Hbar = Sigma_H * Sigma_G * Theta;
  Wbar = Hbar' * Hbar;
  
  
  % Update eigenvectors ===================================================
  fprintf('Updating eigenvectors...');
  
  % Find optimal step size
  mu_W = backtrackingLineSearchDirection(alpha_W, beta_W, Hbar, typeModulation, methodComputationMi, methodSamplingMi, nItersSignalMi, nItersNoiseMi);

  % Compute MI gradient
  E_new = mmseMatrixMimoTrue(Hbar, 'QPSK', 'EXHAUSTIVE', nItersSignalMmse, nItersNoiseMmse);
  E = a * E + (1-a) * E_new;   % Verdu's trick for MMSE computation
  
  % Gardient update of the quadratic form
  Wbar = Wbar + mu_W*E;
  
  % Update right singular vectors of the precoder
  [U, Lambda] = eig(Wbar);
  Hbar = sqrt(Lambda) * U';    % accounting for the structure of Hbar
  Theta = U';
  
  fprintf(['\t\t\tDONE!\t\t\t\tmu_W = ', num2str(mu_W), '\n']);
  
  % Update singular values ================================================
  fprintf('Updating singular values...');
  
  % Power allocation
  p = diag(Sigma_G^2);
  
  % Gradient of MI w.r.t. G^2
  dI_G = diag(Sigma_H^2*Theta*E*Theta') - 1/M*sum( diag(Sigma_H^2*Theta*E*Theta') )*ones(M, 1);
  
  % Optimal step size
  mu_G = backtrackingLineSearchPower(alpha_G, beta_G, Sigma_H, Sigma_G, Theta, typeModulation, methodComputationMi, methodSamplingMi, nItersSignalMi, nItersNoiseMi);
  
  % Gradient update
  p = p + mu_G * dI_G;
  
  % If there are negative entries, set those to zero, renormalize
  i = find(p < 0);
  if ~isempty(i)
    p(i) = 0;
    p = p * M/sum(p);
  end
  Sigma_G = sqrt(diag(p));

  fprintf(['\t\t\tDONE!\t\t\t\tmu_G = ', num2str(mu_G), '\n']);

  % Compute optimal precoder
  fprintf('Computing metrics...');
  G_opt = V_H * Sigma_G * Theta;
  
  % Evaluate performance
  mi(iIter) = computeMiMimo(H*G_opt, typeModulation, methodComputationMi, methodSamplingMi,nItersSignalMi, nItersNoiseMi);

  % Save the MI values for the plot
  if iIter > 1
    isNoImprovement = (mi(iIter) - miOpt(iIter-1) <= stepThresholdPercent*miOpt(iIter-1));
    if (~isNoImprovement)
      miOpt(iIter) = mi(iIter);
      precoderOpt = G_opt;
      nNoImprovements = 0;
    else
      miOpt(iIter) = miOpt(iIter-1);
      nNoImprovements = nNoImprovements + 1;
      if nNoImprovements > nNoImprovementsMax
        % Kickback if stuck at a suboptimal solution
        p = p - (nBackOffs*backOffSize)*mu_G*dI_G;
        % If there are negative entries, set those to zero, renormalize
        i = find(p < 0);
        if ~isempty(i)
          p(i) = 0;
          p = p*M/sum(p);
        end
        Sigma_G = sqrt(diag(p));
        nNoImprovements = 0;
        nBackOffs = nBackOffs + 1;
      end
    end
  else
    miOpt(iIter) = mi(iIter);
    precoderOpt = G_opt;
  end
  
  fprintf('\t\t\t\tDONE!\n');
  fprintf('----------------------------------------------------------------------------------------------------------------\n');

  fprintf('Current best precoder:\n');
  printComplexMatrix(precoderOpt);
  fprintf('----------------------------------------------------------------------------------------------------------------\n');
  
  if (iIter<=nMiValuesBuffer)
    fprintf('Max mutual info:\n');
    fprintf([' [', repmat('%.3f <- ', 1, size(miOpt(1:iIter), 2)), ']\n'], flip(miOpt(1:iIter)));
  else
    fprintf('Max mutual info:\n');
    fprintf([' [', repmat('%.3f <- ', 1, size(miOpt(iIter-nMiValuesBuffer+1:iIter), 2)), ']\n'], flip(miOpt(iIter-nMiValuesBuffer+1:iIter)));
  end
    fprintf('Current mutual info:\n');
  if (iIter <= nMiValuesBuffer)
    fprintf([' [', repmat('%.3f <- ', 1, size(mi(1:iIter), 2)), ']\n'], flip(mi(1:iIter)));
  else
    fprintf([' [', repmat('%.3f <- ', 1, size(mi(iIter-nMiValuesBuffer+1:iIter), 2)), ']\n'], flip(mi(iIter-nMiValuesBuffer+1:iIter)));
  end
  
  fprintf('================================================================================================================\n');

  iIter = iIter + 1; % increment iteration counter
  isSimFinished = (iIter >= nItersMax) || (nBackOffs >= nBackOffsMax) || (abs(miOpt(iIter-1) - log(lSset)/log(2)) < 1e-2);
end % while (~isSimFinished)

timeEnd = cputime; % stop clock

if evaluateTrueMiMeanwhile
  [miFinal, ~]   = computeMiMimo(H*precoderOpt, typeModulation, 'TRUE', 'EXHAUSTIVE', 1e4, 1e4);
else
  [miFinal, ~]   = computeMiMimo(H*precoderOpt, typeModulation, methodComputationMi, methodSamplingMi, nItersSignalMi, nItersNoiseMi);
end

timeElapsedSec = (timeEnd - timeBegin) / 60; % compute execution time

fprintf('OPTIMIZATION DONE!\n');
fprintf('================================================================================================================\n');
fprintf('Optimized precoder:\n');
printComplexMatrix(precoderOpt);
fprintf('----------------------------------------------------------------------------------------------------------------\n');
fprintf(['Optimized mutual info: ', num2str(miFinal), ' [bpcu]\n']);
fprintf(['Time elapsed: ', num2str(timeElapsedSec), ' [min]\n']);

% Container for precoders -------------------------------------------------
simCaseStruct.precoding.precoderReal = real(precoderOpt);
simCaseStruct.precoding.precoderImag = imag(precoderOpt);

% Containers for performance metrics --------------------------------------
simCaseStruct.performance.miBpcu = miFinal;
simCaseStruct.performance.timeElapsedSec = timeElapsedSec;
simCaseStruct.cluster.status = 'COMPLETED';

% Save all params to file
save(simCaseStruct.cluster.matFilePath, 'simCaseStruct');

end