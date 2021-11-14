function caseIdxTag = convertNumberToCaseIdxTag(number, nDigitsMax)
%
% CONVERTNUMBERTOCASEIDXTAG Convert a number to a string tag (adding zeros
% in the beginning, e.g., to have a consistent file naming in the folder).
%
%     Inputs:     scalar number = a number to be converted
%                 scalar nDigitsMax = max number of digits allowed
%     Outputs:    str caseIdxTag = string case tag
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

caseIdxTag = '';
if (number <= 10^nDigitsMax-1)
  caseIdxDigits = zeros(1, nDigitsMax);
  orders = fliplr(10.^[0:nDigitsMax-1]);
  for iDigit = 1:nDigitsMax
    caseIdxDigits(iDigit) = floor( (number - sum(caseIdxDigits(1:iDigit-1).*orders(1:iDigit-1))) / orders(iDigit) );
    caseIdxTag = [caseIdxTag, num2str(caseIdxDigits(iDigit))];
  end
else
  error('ERROR! Input number out of bounds!')
end

end