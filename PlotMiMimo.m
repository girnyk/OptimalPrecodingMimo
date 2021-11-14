% =========================================================================
%
% Deep-learning based MIMO precoding for finite-alphabet signaling
%
% Low-complexity linear precoding for MIMO channels with discrete inputs
% Plotting results
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

clear all; close all; clc;

% Add all the subfolders to the path.
currentFilePath = fileparts(which(mfilename));
addpath(genpath(currentFilePath));


% SET SIMULATION NAMES ! ##################################################

% simNames = {'190516141657_01', 190516140037, '190422212253'}; % either a case or an entire sim
simNames = {'211115003222'};

% =========================================================================

visualsPath   = [pwd, '\Visuals'];
simDataPath   = [pwd, '\SimData'];
functionsPath = [pwd, '\Functions'];

nSimNames = length(simNames);
if (nSimNames==1)
  if iscell(simNames)
    if (isa(simNames{1}, 'double'))
      simNames{1} = num2str(simNames{1});
    end
    delimiter = regexp(simNames{1}, '_');
    if isempty(delimiter)
      isSingleSim = 1;
    end
  else
    if (isa(simNames, 'double'))
      simNames = num2str(simNames);
    end
    delimiter = regexp(simNames, '_');
    if isempty(delimiter)
      isSingleSim = 1;
    end
  end
else
  isSingleSim = 0;
end

fprintf('================================================================================================================\n');
fprintf('Load results... ');


[simCaseNameList, simNameList] = parseSimIds(simNames);
nSimCases = length(simCaseNameList);

resultStruct = {};
for iSimCase = 1:nSimCases
  simFolderPath = [simDataPath, '\', simNameList{iSimCase}];
  caseSubfolderPath = [simFolderPath, '\' simCaseNameList{iSimCase}];
  fileList = dir([caseSubfolderPath, '\*.mat']);
  nFiles = length(fileList);
  resultStruct{iSimCase} = {};
  
  for iFile = 1:nFiles
    simFileName = fileList(iFile).name;
    simFilePath = [caseSubfolderPath, '\', simFileName];
    if (exist(simFilePath))
      load(simFilePath);
    end
    if (isfield(simCaseStruct, 'performance'))
      resultStruct{iSimCase}.miBpcu(iFile) = simCaseStruct.performance.miBpcu;
      resultStruct{iSimCase}.timeElapsedSec(iFile) = simCaseStruct.performance.timeElapsedSec;
    else
      resultStruct{iSimCase}.miBpcu(iFile) = NaN;
      resultStruct{iSimCase}.timeElapsedSec(iFile) = NaN;
    end
    
    resultStruct{iSimCase}.snrDb(iFile) = simCaseStruct.channel.currentSnrDb;
    if (isfield(simCaseStruct, 'precoding'))
      if (isfield(simCaseStruct.precoding, 'precoder'))
        resultStruct{iSimCase}.precoders{iFile} = simCaseStruct.precoding.precoder;
      end
    else
      resultStruct{iSimCase}.precoders{iFile} = NaN;
    end
  end % for iFile = 1:nFiles
  
  resultStruct{iSimCase}.legendEntry = simCaseStruct.plotting.legendEntry;
  resultStruct{iSimCase}.lineType = simCaseStruct.plotting.lineType;
  resultStruct{iSimCase}.lineMarker = simCaseStruct.plotting.lineMarker;
  resultStruct{iSimCase}.lineColor = simCaseStruct.plotting.lineColor;
  resultStruct{iSimCase}.channelTag = simCaseStruct.channel.channelTag;
  resultStruct{iSimCase}.channelMatReal = simCaseStruct.channel.channelMatReal;
  resultStruct{iSimCase}.channelMatImag = simCaseStruct.channel.channelMatImag;
  clear simCaseStruct
end % for iSimCase = 1:nSimCases

fprintf('DONE!\n');
fprintf('================================================================================================================\n');

% PLOTS ===================================================================


% Plot params
legendFontSize = 14;
axisFontSize = 16;
lineWidth = 0.5;

% Plot MI ------------------
figMi = figure(1);
hold on; grid on
for iSimCase = 1 : length(resultStruct)
  [~, iSnrDb] = sort(resultStruct{iSimCase}.snrDb);
  plot(resultStruct{iSimCase}.snrDb(iSnrDb), 2*resultStruct{iSimCase}.miBpcu(iSnrDb), 'Color', resultStruct{iSimCase}.lineColor,...
    'LineStyle', resultStruct{iSimCase}.lineType, 'Marker', resultStruct{iSimCase}.lineMarker, 'LineWidth', lineWidth, 'DisplayName', resultStruct{iSimCase}.legendEntry);
end
xlabel('Signal-to-noise ratio [dB]', 'interpreter', 'latex', 'FontSize', axisFontSize);
ylabel('Mutual information [bit/sym]', 'interpreter', 'latex', 'FontSize', axisFontSize);
set(gca, 'fontsize', legendFontSize);
legend(gca, 'show', 'Location', 'SouthEast')
set(figMi, 'Units', 'Inches');
pos = get(figMi, 'Position');
set(figMi, 'PaperPositionMode', 'Auto', 'PaperUnits', 'Inches', 'PaperSize', [pos(3), pos(4)])
if isSingleSim
  if iscell(simNames)
    figFolderPath = [visualsPath, '\', simNames{1}];
    figMiName = ['plot_mi_', simNames{1}, '.pdf'];
  else
    figFolderPath = [visualsPath, '\', simNames];
    figMiName = ['plot_mi_', simNames, '.pdf'];
  end
  if (~exist(figFolderPath))
    mkdir(figFolderPath);
  end
  figMiPath = [figFolderPath, '\', figMiName];
  print(figMi, figMiPath, '-dpdf', '-r0');
end

% Plot time ------------------
figTime = figure(2);
hold on; grid on
for iSimCase = 1 : length(resultStruct)
  [~, iSnrDb] = sort(resultStruct{iSimCase}.snrDb);
  plot(resultStruct{iSimCase}.snrDb(iSnrDb), resultStruct{iSimCase}.timeElapsedSec(iSnrDb), 'Color', resultStruct{iSimCase}.lineColor,...
    'LineStyle', resultStruct{iSimCase}.lineType, 'Marker', resultStruct{iSimCase}.lineMarker, 'LineWidth', lineWidth, 'DisplayName', resultStruct{iSimCase}.legendEntry);
end
xlabel('Signal-to-noise ratio [dB]', 'interpreter', 'latex', 'FontSize', axisFontSize);
ylabel('Time [min]', 'interpreter', 'latex', 'FontSize', axisFontSize);
set(gca, 'fontsize', legendFontSize);
legend(gca,'show','Location','NorthEast')
set(figTime, 'Units', 'Inches');
pos = get(figTime, 'Position');
set(figTime, 'PaperPositionMode', 'Auto', 'PaperUnits', 'Inches', 'PaperSize', [pos(3), pos(4)])
if isSingleSim
  figFolderPath = [visualsPath, '\', simNames{1}];
  figTimeName = ['plot_time_', simNames{1}, '.pdf'];
  figTimePath = [figFolderPath, '\', figTimeName];
  print(figTime, figTimePath, '-dpdf', '-r0');
end

