function printComplexMatrix(Mat)
%
% PRINTCOMPLEXMATRIX Print out a prettyfied string containing a complex
% matrix. Useful for monitoring the optimal precoder during the
% optimization.
%
%     Inputs:     mat Mat = input matrix
%     Outputs:    --
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

[N, M] = size(Mat);

MatRe = real(Mat);
MatIm = imag(Mat);

MatComb = [MatRe; MatIm];
MatPrint = reshape(MatComb(:), N, 2*M);

fprintf([' [', repmat('%.3f + %.3fj\t', 1, size(Mat, 2)), ']\n'], MatPrint');

end