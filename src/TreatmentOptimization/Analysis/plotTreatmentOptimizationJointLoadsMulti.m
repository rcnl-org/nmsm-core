% This function is part of the NMSM Pipeline, see file for full license.
% 
% This function reads two .sto files: 1) experimental angles, and 2) model
% angles, and plots them. There are 2 optional arguments for figure width
% and figure height. If no optional arguments are given, the figure size is
% automatically adjusted to fit all data on one plot. Giving just figure
% width imposes the width and fits the height to fit on one plot. Giving
% both arguments will impose both figure height and width, and create
% multiple plots as needed.
%
% (string) -> (None)
% Plot joint moment curves from file.

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
function plotTreatmentOptimizationJointLoadsMulti(experimentalFile, ...
    modelFiles, figureWidth, figureHeight)

import org.opensim.modeling.Storage
experimentalStorage = Storage(experimentalFile);
labels = getStorageColumnNames(experimentalStorage);
experimentalData = storageToDoubleMatrix(experimentalStorage)';
experimentalTime = findTimeColumn(experimentalStorage);
if experimentalTime(1) ~= 0
    experimentalTime = experimentalTime - experimentalTime(1);
end
for i=1:numel(modelFiles)
    modelStorage = Storage(modelFiles(i));
    modelData{i} = storageToDoubleMatrix(modelStorage)';
    modelTime{i} = findTimeColumn(modelStorage);
end

% Spline experimental time to the same time points as the model. 
experimentalSpline = makeGcvSplineSet(experimentalTime, ... 
    experimentalData, labels);
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
figure(Name = "Treatment Optimization Joint Loads", ...
    Units='normalized', ...
    Position=[0.05 0.05 0.9 0.85])
subplotNumber = 1;
figureNumber = 1;
t = tiledlayout(figureHeight, figureWidth, ...
    TileSpacing='compact', Padding='compact');
xlabel(t, "Time [s]")
ylabel(t, "Joint Loads")
for i=1:numel(labels)
    if i > figureSize * figureNumber
        figureNumber = figureNumber + 1;
        figure(Name="Treatment Optimization Joint Loads", ...
            Units='normalized', ...
            Position=[0.05 0.05 0.9 0.85])
        t = tiledlayout(figureHeight, figureWidth, ...
            TileSpacing='Compact', Padding='Compact');
        xlabel(t, "Time [s]")
        ylabel(t, "Joint Loads")
        subplotNumber = 1;
    end
    nexttile(subplotNumber);
    hold on
    plot(experimentalTime, experimentalData(:, i), LineWidth=2);
    for j = 1 : numel(modelFiles)
        plot(modelTime{j}, modelData{j}(:, i), LineWidth=2);
    end
    hold off
    if contains(labels(i), "moment")
        titleString = [sprintf("%s [Nm]", strrep(labels(i), "_", " "))];
    elseif contains(labels(i), "force")
        titleString = [sprintf("%s [N]", strrep(labels(i), "_", " "))];
    else
        titleString = [sprintf("%s", strrep(labels(i), "_", " "))];
    end
    for j = 1 : numel(modelFiles)
        rmse = rms(resampledExperimental{j}(:, i) - modelData{j}(:, i));
        titleString(j+1) = sprintf("RMSE %d: %.4f", j, rmse);
    end
    title(titleString)
    if subplotNumber==1
        legendValues = "Experimental";
        for j = 1 : numel(modelFiles)
            splitFileName = split(modelFiles(j), ["/", "\"]);
            legendValues(j+1) = sprintf("%s (%d)", splitFileName(1), j);
        end
        legend(legendValues)
    end
    xlim([0, experimentalTime(end)])
    maxData = [];
    minData = [];
    for j = 1 : numel(modelFiles)
        maxData(j) = max(modelData{j}(1:end-1, i), [], "all");
        minData(j) = min(modelData{j}(1:end-1, i), [], "all");
    end
    maxData(j+1) = max(experimentalData(1:end-1, i), [], "all");
    minData(j+1) = min(experimentalData(1:end-1, i), [], "all");
    yLimitUpper = max(maxData);
    yLimitLower = min(minData);
    if yLimitUpper - yLimitLower < 10
        ylim([(yLimitUpper+yLimitLower)/2-10, (yLimitUpper+yLimitLower)/2+10])
    else
        ylim([yLimitLower, yLimitUpper]);
    end
    subplotNumber = subplotNumber + 1;
end