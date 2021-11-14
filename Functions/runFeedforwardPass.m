function outputVec = runFeedforwardPass(neural_net, inputVec)
%
% RUNFEEDFORWARDPASS Run a feedforward pass through neural net.
%
%     Inputs:     struct neural_net = struct with neural net specific info
%                 vec inputVec = vector of inputs
%     Outputs:    vec outputVec = vector of outputs
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

% Get neural net config
layerSizes = neural_net.layerSizes;
nLayers = length(layerSizes);

switch (neural_net.activationType)
  case 'tanh'
    activationFunc = @(z) tanh(z);
  case 'sigmoid'
    activationFunc = @(z) 1.0/(1.0+exp(-z));
  otherwise
    error('ERROR! Unknown activation function!');
end

% Init params to use to reshape the biases and weights vectors
weightMatSizeCurrent = 1;
weightMatSizeNext = layerSizes(1)*layerSizes(2);
biasVecSizeCurrent = 1;
biasVecSizeNext = layerSizes(2);

% Feedforward loop
for iLayer = 1:nLayers-1
  % Reshape weights and biases
  w = reshape(neural_net.weightMatsUnrolled(weightMatSizeCurrent:weightMatSizeNext), [layerSizes(iLayer), layerSizes(iLayer+1)])';
  b = neural_net.biasVecsUnrolled(biasVecSizeCurrent:biasVecSizeNext);
  
  % Update reshape parameters
  if iLayer < nLayers - 1
    weightMatSizeCurrent = weightMatSizeCurrent + layerSizes(iLayer)*layerSizes(iLayer+1);
    weightMatSizeNext = weightMatSizeCurrent - 1 + layerSizes(iLayer+1)*layerSizes(iLayer+2);
    biasVecSizeCurrent = biasVecSizeCurrent + layerSizes(iLayer+1);
    biasVecSizeNext = biasVecSizeCurrent - 1 + layerSizes(iLayer+2);
  end
  
  % Compute activation function
  z = w*inputVec + b;
  inputVec = arrayfun(activationFunc, z);
end % for iLayer = 1:nLayers-1

outputVec = inputVec;

end