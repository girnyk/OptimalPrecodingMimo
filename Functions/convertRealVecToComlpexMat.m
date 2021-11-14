function complexMat = convertRealVecToComlpexMat(realVec, N, M)
%
% CONVERTREALVECTOCOMPLEXMAT Converts a real-valued vec toa complex-valued
% mat by reshaping the array and adding real and imag parts.
%
%     Inputs:     vec realVec = real vector
%     Outputs:    mat complexMat = complex matrix
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
  complexMat = reshape(realVec(1:end/2) + 1i*realVec(end/2+1:end), N, M);
end