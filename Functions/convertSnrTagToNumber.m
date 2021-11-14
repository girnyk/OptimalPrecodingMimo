function number = convertSnrTagToNumber(tag)
%
% CONVERTSNRTAGTONUMBER Convert a string SNR tag to a float number
%
%     Inputs:     str tag = SNR tag
%     Outputs:    scalar number = a number to be converted
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

% Parse the tag
[tagSeparator, tagParts] = regexp(tag, '[MP]', 'match', 'split');

% Form the number
numberIntegerPart = str2double(tagParts{1});
nFractionalDigits = length(tagParts{2});
numberFractionalDigits = str2double(tagParts{2});
numberFractionalPart = 10^(-nFractionalDigits) * numberFractionalDigits;
if strcmp(tagSeparator, 'P')
  number = numberIntegerPart + numberFractionalPart;
elseif strcmp(tagSeparator, 'M')
  number = -(numberIntegerPart + numberFractionalPart);
else
  error('Wrong tag separator!');
end
end