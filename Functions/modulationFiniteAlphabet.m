function Sset = modulationFiniteAlphabet(typeModulation)
%
% MODULATIONFINITEALPHABET Return a finite-alphabet signal constellation.
%
%     Inputs:     str typeModulation = type of signal constellation
%     Outputs:    vec Sset = vector of signal constellation points
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

% Modulation constellation
switch (typeModulation)
  case 'BPSK'
    Sset = [-1, 1];
  case 'QPSK'
    Sset = sqrt(1/2)*[1+1j, 1-1j, -1-1j, -1+1j];
  case '8PSK'
    Sset = sqrt(1/2)*exp(1i*2*pi*linspace(0, 0.875, 8));
  case '16QAM'
    Sset = sqrt(1/10)*[-3-3*1i, -3-1*1i, -3+1*1i, -3+3*1i,...
      -1+3*1i, -1+1*1i, -1-1*1i, -1-3*1i,...
      1-3*1i, 1-1*1i, +1+1*1i, 1+3*1i,...
      3+3*1i, 3+1*1i, 3-1*1i, 3-3*1i];
  case '64QAM'
    Sset = sqrt(1/42)*[-7-7*1i, -7-5*1i, -7-3*1i, -7-1*1i,...
      -5-7*1i, -5-5*1i, -5-3*1i, -5-1*1i,...
      -3-7*1i, -3-5*1i, -3-3*1i, -3-1*1i,...
      -1-7*1i, -1-5*1i, -1-3*1i, -1-1*1i,...
      -7+7*1i, -7+5*1i, -7+3*1i, -7+1*1i,...
      -5+7*1i, -5+5*1i, -5+3*1i, -5+1*1i,...
      -3+7*1i, -3+5*1i, -3+3*1i, -3+1*1i,...
      -1+7*1i, -1+5*1i, -1+3*1i, -1+1*1i,...
      +7-7*1i, +7-5*1i, +7-3*1i, +7-1*1i,...
      +5-7*1i, +5-5*1i, +5-3*1i, +5-1*1i,...
      +3-7*1i, +3-5*1i, +3-3*1i, +3-1*1i,...
      +1-7*1i, +1-5*1i, +1-3*1i, +1-1*1i,...
      +7+7*1i, +7+5*1i, +7+3*1i, +7+1*1i,...
      +5+7*1i, +5+5*1i, +5+3*1i, +5+1*1i,...
      +3+7*1i, +3+5*1i, +3+3*1i, +3+1*1i,...
      +1+7*1i, +1+5*1i, +1+3*1i, +1+1*1i];
end;
end

