function neural_net = setupNeuralNet(layerSizes, activationType)
%
% TRAINNNMODELMIMO Train a neural model for precoder prediction
%
%     Inputs:     vec layerSizes = numbers of neurons in each layer
%                 str activationType = type of activation function
%     Outputs:    struct neural_net = struct with neural net specific info
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

neural_net = {};
neural_net.layerSizes = layerSizes;
neural_net.activationType = activationType;

% Define the number of layers
nLayers = length(layerSizes);

% Init biases and weights
neural_net.biasVecsUnrolled = [];
neural_net.weightMatsUnrolled = [];

% Set initial values for weights and biases
for iLayer = 1:nLayers-1
  nNeuronsNext = layerSizes(iLayer+1);
  nNeuronsCurrent = layerSizes(iLayer);
  randBiases = zeros(nNeuronsNext, 1);
  neural_net.biasVecsUnrolled = [neural_net.biasVecsUnrolled; randBiases(:)];
  randWeights = sqrt(2/(nNeuronsNext+nNeuronsCurrent))*randn(nNeuronsNext, nNeuronsCurrent);
  neural_net.weightMatsUnrolled = [neural_net.weightMatsUnrolled; randWeights(:)];
end % for iLayer = 1:nLayers-1

end