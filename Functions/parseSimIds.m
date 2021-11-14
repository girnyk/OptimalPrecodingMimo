function [simCaseNameList, simNameList] = parseSimIds(simIdCellArray, nCasesPerSimMax)
%
% PARSESIMIDS Given a list of sim names (collections of sim cases) simIdCellArray,
% parse which exact sim cases are to be run
%
%     Inputs:     cell array simIdCellArray = array of sim IDs
%                 scalar nCasesPerSimMax = max number of sim cases
%     Outputs:    cell array simCaseNameList = list of sim case names
%                 cell array simNameList = list of sim names
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

if (nargin < 2)
  nCasesPerSimMax = -1;
end

simDataPath = [pwd, '\SimData'];

nCells = length(simIdCellArray);
simCaseNameList = {};
simNameList = {};
for iCell = 1:nCells
  counterCases = 0;
  if iscell(simIdCellArray)
    if (isa(simIdCellArray{iCell}, 'double'))
      simName = num2str(simIdCellArray{iCell});
      simFolderPath = [simDataPath, '\', simName];
      folderContent = dir(simFolderPath);
      for iElement = 1:length(folderContent)
        elementName = folderContent(iElement).name;
        if (~isempty(strfind(elementName, simName))) && (isempty(strfind(elementName, '.')))
          simCasePath   = [simFolderPath, '\', elementName];
          if (~exist(simCasePath))
            error(['Sim case ', simName, ' does not exist!']);
          end
          counterCases = counterCases + 1;
          if (nCasesPerSimMax > 0)
            if (counterCases <= nCasesPerSimMax)
              simCaseNameList{end+1} = elementName;
              simNameList{end+1} = simName;
            end
          else
            simCaseNameList{end+1} = elementName;
            simNameList{end+1} = simName;
          end
        end
      end % for iElement = 1:length(folderContent)
    elseif (isa(simIdCellArray{iCell}, 'char'))
      simName = simIdCellArray{iCell};
      delimiter = regexp(simName, '_');
      if ~isempty(delimiter)
        simCaseName = simName;
        simName = simName(1:delimiter-1);
        simFolderPath = [simDataPath, '\', simName(1:delimiter-1)];
        simCasePath   = [simFolderPath, '\', simCaseName];
        if (~exist(simCasePath))
          error(['Sim case ', simCasePath, ' does not exist!']);
        end
        simCaseNameList{end+1} = simCaseName;
        simNameList{end+1} = simName;
      else
        simFolderPath = [simDataPath, '\', simName];
        folderContent = dir(simFolderPath);
        for iElement = 1:length(folderContent)
          elementName = folderContent(iElement).name;
          if (~isempty(strfind(elementName, simName))) && (isempty(strfind(elementName, '.')))
            counterCases = counterCases + 1;
            if (nCasesPerSimMax > 0)
              if (counterCases <= nCasesPerSimMax)
                simCaseNameList{end+1} = elementName;
                simNameList{end+1} = simName;
              end
            else
              simCaseNameList{end+1} = elementName;
              simNameList{end+1} = simName;
            end
            
          end
        end % for iElement = 1:length(folderContent)
      end
    end
  end
end % for iCell = 1:nCells

end