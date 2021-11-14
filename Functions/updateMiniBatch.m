function neural_net = updateMiniBatch (neural_net, miniBatch, learnRate)
%
% UPDATEMINIBATCH Perform minibatch update.
%
%     Inputs:     struct neural_net = truct with neural net specific info
%                 cell array miniBatch = observations in minibatch
%                 scalar learnRate = learning rate
%     Outputs:    struct neural_net = truct with neural net specific info
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

% Get the size of minibatch
miniBatchSize = length(miniBatch);

% Init gradients of biases and weights
gradsBias = zeros(size(neural_net.biasVecsUnrolled));
gradsWeight = zeros(size(neural_net.weightMatsUnrolled));

% Loop through each row of mini_batch
for jObs = 1:miniBatchSize
  % Compute the gradients via backprop
  [deltaGradsBias, deltaGradsWeight] = runBackpropPass(neural_net, miniBatch{jObs}.precoderVecWf, miniBatch{jObs}.precoderVecDiscrete);
  gradsBias = gradsBias + deltaGradsBias;
  gradsWeight = gradsWeight + deltaGradsWeight;
end % for jObs = 1:miniBatchSize

% Update weights and biases
neural_net.biasVecsUnrolled = neural_net.biasVecsUnrolled - (learnRate/miniBatchSize).*gradsBias;
neural_net.weightMatsUnrolled = neural_net.weightMatsUnrolled - (learnRate/miniBatchSize).*gradsWeight;

end