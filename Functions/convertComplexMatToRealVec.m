function realVec = convertComplexMatToRealVec(complexMat)
%
% CONVERTCOMPLEXMATTOREALVEC Converts a complex-valued mat to a real-valued 
% vec by stacking columns and real/imaginary parts.
%
%     Inputs:     mat complexMat = complex matrix
%     Outputs:    vec realVec = real vector
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

  realVec = [real(complexMat(:)); imag(complexMat(:))];
end