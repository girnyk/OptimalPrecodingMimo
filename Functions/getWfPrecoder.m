function G = getWfPrecoder(H)
%
% GETWFPRECODER Capacity-achieving precoder, computed according to the
% water-filling solution originally proposed in:
%  M. C. Cover and J.A. Thomas, Elements of Information Theory, New York:
%  Wiley, 1991.
%
%     Inputs:     mat H = MIMO channel matrix
%     Outputs:    mat G = linear precoding matrix
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

% Channel mat sizes
[N, M] = size(H);
K = min(M, N);
L = max(M, N);

% Container for eigenvalues
X = NaN(K, K);

% SVD of the channel matrix
[~, S, V] = svd(H, 'econ');
lambdaH = diag(S);
lambdaP = (K + sum(1./(lambdaH.^2)))/K - 1./(lambdaH.^2);

% Water filling
canGoOn = 1;
while canGoOn
  negativeIdx = find(lambdaP<=0);
  positiveIdx = find(lambdaP>0);
  lambdaP(negativeIdx) = 0;
  newM = length(positiveIdx);
  lambdaHnew = lambdaH(positiveIdx);
  lambdaPtemp = ( sum(1./(lambdaHnew.^2)) + K )/newM - 1./(lambdaHnew.^2);
  lambdaP(positiveIdx) = lambdaPtemp;
  canGoOn = ~isempty( find(lambdaP < 0, 1) );
end % while canGoOn

Y = diag(lambdaP);
X(1:K, 1:K) = Y(1:K, 1:K);

% Capacity-achieving linear precoder
G = V * sqrt(X);

end