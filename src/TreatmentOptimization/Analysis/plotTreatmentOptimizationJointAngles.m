% This function is part of the NMSM Pipeline, see file for full license.
%
% This function reads .sto files for experimental and model joint angles
% and plots them. There is an option to plot multiple model files by
% passing in a list of model file names.
%
% There are 2 optional arguments for figure width and figure height. If no
% optional arguments are given, the figure size is automatically adjusted
% to fit all data on one plot. Giving just figure width and no figure
% height will set figure height to a default value and extra figures will
% be created as needed. If both figure width and figure height are given,
% the figure size will be fixed and extra figures will be created as
% needed.
%
% (string) (List of strings) (int), (int) -> (None)
% Plot experimental and model joint angles from file

% ----------------------------------------------------------------------- %
% The NMSM Pipeline is a toolkit for model personalization and treatment  %
% optimization of neuromusculoskeletal models through OpenSim. See        %
% nmsm.rice.edu and the NOTICE file for more information. The             %
% NMSM Pipeline is developed at Rice University and supported by the US   %
% National Institutes of Health (R01 EB030520).                           %
%                                                                         %
% Copyright (c) 2021 Rice University and the Authors                      %
% Author(s): Robert Salati                                                %
%                                                                         %
% Licensed under the Apache License, Version 2.0 (the "License");         %
% you may not use this file except in compliance with the License.        %
% You may obtain a copy of the License at                                 %
% http://www.apache.org/licenses/LICENSE-2.0.                             %
%                                                                         %
% Unless required by applicable law or agreed to in writing, software     %
% distributed under the License is distributed on an "AS IS" BASIS,       %
% WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or         %
% implied. See the License for the specific language governing            %
% permissions and limitations under the License.                          %
% ----------------------------------------------------------------------- %
function plotTreatmentOptimizationJointAngles(experimentalFile, ...
    modelFiles, figureWidth, figureHeight)

import org.opensim.modeling.Storage
experimentalStorage = Storage(experimentalFile);
labels = getStorageColumnNames(experimentalStorage);
experimentalData = storageToDoubleMatrix(experimentalStorage)';
experimentalData = experimentalData .* 180/pi;
experimentalTime = findTimeColumn(experimentalStorage);
if experimentalTime(1) ~= 0
    experimentalTime = experimentalTime - experimentalTime(1);
end
modelData = {};
for i=1:numel(modelFiles)
    modelStorage = Storage(modelFiles(i));
    modelData{i} = storageToDoubleMatrix(modelStorage)' .* 180/pi;
    modelTime{i} = findTimeColumn(modelStorage);
end

% Spline experimental time to the same time points as the model.
experimentalSpline = makeGcvSplineSet(experimentalTime, ...
    experimentalData, labels);
resampledExperimental = {};
for i = 1 : numel(modelFiles)
    resampledExperimental{i}= evaluateGcvSplines(experimentalSpline, ...
        labels, modelTime{i});
end
if nargin < 3
    figureWidth = ceil(sqrt(numel(labels)));
    figureHeight = ceil(numel(labels)/figureWidth);
elseif nargin < 4
    figureHeight = ceil(sqrt(numel(labels)));
end
figureSize = figureWidth * figureHeight;
figure(Name = "Treatment Optimization Joint Angles", ...
    Units='normalized', ...
    Position=[0.05 0.05 0.9 0.85])
subplotNumber = 1;
figureNumber = 1;
t = tiledlayout(figureHeight, figureWidth, ...
    TileSpacing='compact', Padding='compact');
xlabel(t, "Time [s]")
ylabel(t, "Joint Angle [deg]")
for i=1:numel(labels)
    if i > figureSize * figureNumber
        figureNumber = figureNumber + 1;
        figure(Name="Treatment Optimization Joint Angles", ...
            Units='normalized', ...
            Position=[0.05 0.05 0.9 0.85])
        t = tiledlayout(figureHeight, figureWidth, ...
            TileSpacing='Compact', Padding='Compact');
        xlabel(t, "Time [s]")
        ylabel(t, "Joint Angle [deg]")
        subplotNumber = 1;
    end
    nexttile(subplotNumber);
    hold on
    plot(experimentalTime, experimentalData(:, i), LineWidth=2);
    for j = 1 : numel(modelFiles)
        plot(modelTime{j}, modelData{j}(:, i), LineWidth=2);
    end
    hold off
    titleString = [sprintf("%s", strrep(labels(i), "_", " "))];
    for j = 1 : numel(modelFiles)
        rmse = rms(resampledExperimental{j}(:, i) - modelData{j}(:, i));
        titleString(j+1) = sprintf("RMSE %d: %.4f", j, rmse);
    end
    title(titleString)
    if subplotNumber==1
        splitFileName = split(experimentalFile, ["/", "\"]);
        for k = 1 : numel(splitFileName)
            if ~strcmp(splitFileName(k), "..")
                legendValues = sprintf("%s (T)", ...
                    strrep(splitFileName(k), "_", " "));
                break
            end
        end
        for j = 1 : numel(modelFiles)
            splitFileName = split(modelFiles(j), ["/", "\"]);
            legendValues(j+1) = sprintf("%s (%d)", splitFileName(1), j);
        end
        legend(legendValues)
    end
    xlim("tight")
    maxData = [];
    minData = [];
    for j = 1 : numel(modelFiles)
        maxData(j) = max(modelData{j}(:, i), [], "all");
        minData(j) = min(modelData{j}(:, i), [], "all");
    end
    maxData(j+1) = max(experimentalData(:, i), [], "all");
    minData(j+1) = min(experimentalData(:, i), [], "all");
    yLimitUpper = max(maxData);
    yLimitLower = min(minData);
    if yLimitUpper - yLimitLower < 10
        ylim([(yLimitUpper+yLimitLower)/2-10, (yLimitUpper+yLimitLower)/2+10])
    end
    subplotNumber = subplotNumber + 1;
end