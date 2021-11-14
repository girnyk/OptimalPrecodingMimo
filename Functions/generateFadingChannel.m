function channelMatrix = generateFadingChannel(channelFadingTag, nRxAntennas, nTxAntennas)
%
% GENERATEFADINGCHANNEL Generate fading MIMO channel matrix.
%
%     Inputs:     str channelFadingTag = channel tag
%                 (scalar nRxAntennas = number of receiver antennas)
%                 (scalar nTxAntennas = number of transmitter antennas)
%     Outputs:    mat channelMatrix = MIMO channel matrix
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

if strcmp(channelFadingTag, 'PalomarVerdu')
  if (nRxAntennas==2) && (nTxAntennas==2)
    channelMatrix = [2 1; 1 1];
  else
    error('ERROR! Palomar-Verdu channel not supported for a %dx%d MIMO setup! Use 2x2 instead!', nRxAntennas, nTxAntennas);
  end
elseif strcmp(channelFadingTag, 'ComplexRayleighIid')
  channelMatrix = 1/sqrt(2)*(randn(nRxAntennas, nTxAntennas) + 1i*randn(nRxAntennas, nTxAntennas));
elseif strcmp(channelFadingTag, 'RealRayleighIid')
  channelMatrix =randn(nRxAntennas, nTxAntennas);
else
  error('ERROR! Unknown channel tag!');
end

end