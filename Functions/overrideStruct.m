function outputStruct = overrideStruct(outputStruct, inputStruct)
%
% OVERRIDESTRUCT Merge all fields of input struct into output struct
%
%     Inputs:     struct outputStruct = output struct
%                 struct struct = input struct
%     Outputs:    struct outputStruct = output struct
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

% Check that inout and output are scalar structs
validateattributes(inputStruct, {'struct'}, {'scalar'});
validateattributes(outputStruct, {'struct'}, {'scalar'});

% Loop over field names and merge
fields = fieldnames(inputStruct);
for field = fields.'
  if isstruct(inputStruct.(field{1})) && isfield(outputStruct, field{1})
    % Merge if field is already existent nested struct
    outputStruct.(field{1}) = overrideStruct(outputStruct.(field{1}), inputStruct.(field{1}));
  else
    % Copy if field is non-struct or non-existent nested struct
    outputStruct.(field{1}) = inputStruct.(field{1});
  end
end

end