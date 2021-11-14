function tag = convertNumberToSnrTag(number)
%
% CONVERTNUMBERTOSNRTAG Convert a float number to a string where the
% decimal point is substituted with M/P to create a convenient tag for SNRs
% for naming simulation files
%
%     Inputs:     scalar number = a number to be converted
%     Outputs:    str tag = SNR tag
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

% Decouple the sign, integer and fractional parts
numberSign = 2*(number>=0)-1;
numberIntegerDigits = floor(abs(number));
maxFractionalDigit = 6;
tol = 1e-6;
numberRounded = numberSign*floor(abs(number * 10^maxFractionalDigit)) * 10^(-maxFractionalDigit);
numberFractionalPart = abs(numberRounded) - numberIntegerDigits;
dummyVar = abs(numberRounded) * 10.^(1:maxFractionalDigit);
nFractionalDigits = find(abs(dummyVar-round(dummyVar))<tol, 1);
numberFractionalDigits = 10^nFractionalDigits * numberFractionalPart;

% Form the tag
if (numberSign==1)
  tagSeparator = 'P';
elseif (numberSign==-1)
  tagSeparator = 'M';
else
  error('Wrong sign!');
end
tag = [num2str(numberIntegerDigits), tagSeparator, num2str(numberFractionalDigits)];
end