function [gradsBias, gradsWeight] = runBackpropPass(neural_net, inputVec, targetVec)
%
% RUNBACKPROPPASS Train neural network on a training set and test it
% on a test set
%
%     Inputs:     struct neural_net = struct with neural net specific info
%                 vec inputVec = vector of inputs
%                 vec targetVec = vector of targets
%     Outputs:    vec gradsBias = vector of biases gradients
%                 vec gradsWeight = vector of weights gradients
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
    activationDiffFunc = @(z) 1-(activationFunc(z))^2;
  case 'sigmoid'
    activationFunc = @(z) 1.0/(1.0+exp(-z));
    activationDiffFunc = @(z) activationFunc(z)*(1-activationFunc(z));
  otherwise
    error('ERROR! Unknown activation function!');
end

% Define first derivative of cost function
costDiff = inline('output_activations - target', 'output_activations', 'target');

% Init gradients for weights and biases
gradsBias = zeros(size(neural_net.biasVecsUnrolled));
gradsWeight = zeros(size(neural_net.weightMatsUnrolled));

% Set input activations to input values
activation = inputVec;
activationVec = inputVec;
% z = w*x + b for all layers
preprocOutputVec = [];

% Init params to use to reshape the biases and weights vectors
sizeWeightMatCurrent = 1;
sizeWeightMatNext = layerSizes(1) * layerSizes(2);
sizeBiasVecCurrent = 1;
sizeBiasVecNext = layerSizes(2);

% Feedforward loop
for iLayer = 1:nLayers-1
  % Reshape weights from vec to mat
  weightMat = reshape(neural_net.weightMatsUnrolled(sizeWeightMatCurrent:sizeWeightMatNext), [layerSizes(iLayer), layerSizes(iLayer+1)])';
  % Set biases to use
  biasVec = neural_net.biasVecsUnrolled(sizeBiasVecCurrent:sizeBiasVecNext);
  % Update reshape params
  if (iLayer<nLayers-1)
    sizeWeightMatCurrent = sizeWeightMatCurrent + layerSizes(iLayer)*layerSizes(iLayer+1);
    sizeWeightMatNext = sizeWeightMatCurrent - 1 + layerSizes(iLayer+1)*layerSizes(iLayer+2);
    sizeBiasVecCurrent = sizeBiasVecCurrent + layerSizes(iLayer+1);
    sizeBiasVecNext = sizeBiasVecCurrent - 1 + layerSizes(iLayer+2);
  end
  % Compute z and the activation functions
  preprocOutput = weightMat*activation + biasVec;
  preprocOutputVec = [preprocOutputVec; preprocOutput];
  activation = arrayfun(activationFunc, preprocOutput);
  activationVec = [activationVec; activation];
end % iLayer = 1:nLayers-1

% Backward pass
% Init params to use to reshape the vectors
sizeWeightMatCurrent = length(neural_net.weightMatsUnrolled);
sizeWeightMatNext = length(neural_net.weightMatsUnrolled) - layerSizes(end)*layerSizes(end-1) + 1;
sizeBiasVecCurrent = length(neural_net.biasVecsUnrolled);
sizeBiasVecNext = length(neural_net.biasVecsUnrolled) - layerSizes(end) + 1;
sizeActivationCurrent = length(activationVec);
sizeActivationNext = length(activationVec) - layerSizes(end) + 1;
x1 = costDiff(activationVec(sizeActivationNext:sizeActivationCurrent), targetVec);
x2 = arrayfun(activationDiffFunc, preprocOutputVec(sizeBiasVecNext:sizeBiasVecCurrent));
delta = x1 .* x2;

% Update gradients with errors
gradsBias(sizeBiasVecNext:sizeBiasVecCurrent) = delta;
tmp = (delta*activationVec((sizeActivationNext-layerSizes(end-1)):(sizeActivationNext-1))')';
gradsWeight(sizeWeightMatNext:sizeWeightMatCurrent) = tmp(:); % outer product

% Backpropagate errors by looping through layers backwards
for jLayer = (nLayers-1):-1:2
  % Update reshape parameters
  if jLayer > 1
    sizeBiasVecCurrent = sizeBiasVecNext - 1;
    sizeBiasVecNext = sizeBiasVecNext - layerSizes(jLayer);
    sizeActivationNext = sizeActivationNext - layerSizes(jLayer);
  end
  % Backpropagate errors
  preprocOutput = preprocOutputVec(sizeBiasVecNext:sizeBiasVecCurrent);
  activationFuncDiffVec = arrayfun(activationDiffFunc, preprocOutput);
  weightMat = reshape(neural_net.weightMatsUnrolled(sizeWeightMatNext:sizeWeightMatCurrent), [layerSizes(jLayer), layerSizes(jLayer+1)])';
  delta = weightMat' * delta .* activationFuncDiffVec;
  % Update gradients with backrpopagated errors
  gradsBias(sizeBiasVecNext:sizeBiasVecCurrent) = delta;
  % Update reshape parameters
  if jLayer > 1
    sizeWeightMatCurrent = sizeWeightMatNext - 1;
    sizeWeightMatNext = sizeWeightMatNext - layerSizes(jLayer)*layerSizes(jLayer-1);
  end
  tmp = (delta*activationVec((sizeActivationNext-layerSizes(jLayer-1)):(sizeActivationNext-1))')';
  gradsWeight(sizeWeightMatNext:sizeWeightMatCurrent) = tmp(:);
end % jLayer = (nLayers-1):-1:2

end