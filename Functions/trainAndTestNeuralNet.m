function [neural_net, lossTrain, lossValid] = trainAndTestNeuralNet(neural_net, trainSet, nEpochs, miniBatchSize, learnRate, testSet)
%
% TRAINANDTESTNEURALNET Train neural network on a training set and test it
% on a test set
%
%     Inputs:     struct neural_net = struct with neural net specific info
%                 cell array trainSet = training set
%                 scalar nEpochs = number of epochs for training
%                 scalar miniBatchSize = size of the minibatch
%                 scalar learnRate = learning rate
%                 cell array testSet = test set for performance evaluation
%     Outputs:    struct neural_net = struct with neural net specific info
%                 vec lossTrain =  training loss over epochs
%                 vec lossValid = validation loss over epochs
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

% Check if test_data is present
if nargin > 5
  nTestObs = length(testSet);
end

% define the dimension of training data
nTrainObs = length(trainSet);

% Init loss arrays
lossTrain = NaN(nEpochs, 1);
lossValid = NaN(nEpochs, 1);

% loop through epochs
for iEpoch = 1:nEpochs
  
  % Shuffle training data
  perm = randperm(nTrainObs);
  trainSet = trainSet(perm);
  
  % Loop through minibatches
  for jBatch = 1:miniBatchSize:nTrainObs
    if (jBatch+miniBatchSize-1<nTrainObs)
      miniBatch = trainSet(jBatch:jBatch+miniBatchSize-1);
    else
      miniBatch = trainSet(jBatch:nTrainObs);
    end
    neural_net = updateMiniBatch(neural_net, miniBatch, learnRate);
  end % for jBatch = 1:miniBatchSize:nTrainObs
    
  % if test_data is present
  if nargin > 5
    lossTrain(iEpoch) = evaluateNeuralNet(neural_net, trainSet);
    lossValid(iEpoch) = evaluateNeuralNet(neural_net, testSet);
    fprintf('Epoch %d/%d: mean_loss_train=%.4f, mean_loss_val=%.4f, (n_train=%d, n_val=%d)\n', iEpoch, nEpochs, lossTrain(iEpoch), lossValid(iEpoch), nTrainObs, nTestObs);
  else
    fprintf('Epoch %d/%d complete\n', iEpoch, nEpochs);
  end
  
end % for iEpoch = 1:nEpochs

end