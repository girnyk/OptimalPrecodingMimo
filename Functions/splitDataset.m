function [trainSet, testSet] = splitDataset(dataset, trainShare)
%
% SPLITDATASET Split entire dataset into training set and test set.
%
%     Inputs:     cell array dataset = dataset
%                 scalar trainShare = share of training observations
%     Outputs:    cell array trainSet = training set
%                 cell array testSet = test set
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

nObservations = length(dataset);
nTrainObs = floor(trainShare*nObservations);
idxList = randperm(nObservations);

trainSet = dataset(idxList(1:nTrainObs));
testSet = dataset(idxList(nTrainObs+1:end));

end