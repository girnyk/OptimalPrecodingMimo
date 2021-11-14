function loss = evaluateNeuralNet(neural_net, testSet)
%
% EVALUATENEURALNET Evaluate trained neural net on a test set.
%
%     Inputs:     struct neural_net = struct with neural net specific info
%                 struct testSet = test set for performance evaluation
%     Outputs:    scalar loss = loss between test labels and predictions
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

% Number of observations
nTestObs = length(testSet);

% Loop through test data
errors = zeros(nTestObs, 1);
for iObs = 1:nTestObs
  % Run feedforward pass over neural net
  precoderVecPredicted = runFeedforwardPass(neural_net, testSet{iObs}.precoderVecWf);
  
  % Compute errors between predictions and test labels
  errors(iObs) = 1/length(precoderVecPredicted)*norm(precoderVecPredicted/norm(precoderVecPredicted) - testSet{iObs}.precoderVecDiscrete/norm(testSet{iObs}.precoderVecDiscrete))^2;
end % iObs = 1:nTestObs

% Compute mean loss
loss = mean(errors);

end