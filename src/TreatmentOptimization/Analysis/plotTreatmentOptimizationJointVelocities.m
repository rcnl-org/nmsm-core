% This function is part of the NMSM Pipeline, see file for full license.
%
% This function reads .sto files for experimental joint angles, and a
% states file in the treatment optimization results directory, and an osim
% model file. It plots joint angles for all joints specified as states for
% GPOPS2. There is an option to plot multiple model files by passing in a 
% list of output states files in the modelDataFiles argument.
%
% There are 2 optional arguments for figure width and figure height. If no
% optional arguments are given, the figure size is automatically adjusted
% to fit all data on one plot. Giving just figure width and no figure
% height will set figure height to a default value and extra figures will
% be created as needed. If both figure width and figure height are given,
% the figure size will be fixed and extra figures will be created as
% needed.
%
% (string) (string) (List of strings) (int), (int) -> (None)
% Plot experimental and model joint angles from file

% ----------------------------------------------------------------------- %
% The NMSM Pipeline is a toolkit for model personalization and treatment  %
% optimization of neuromusculoskeletal models through OpenSim. See        %
% nmsm.rice.edu and the NOTICE file for more information. The             %
% NMSM Pipeline is developed at Rice University and supported by the US   %
% National Institutes of Health (R01 EB030520).                           %
%                                                                         %
% Copyright (c) 2024 Rice University and the Authors                      %
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

function plotTreatmentOptimizationJointVelocities(modelFileName, ...
    trackedDataFile, modelDataFiles, figureWidth, figureHeight)
import org.opensim.modeling.Storage
model = Model(modelFileName);
trackedDataStorage = Storage(trackedDataFile);
[coordinateLabels, trackedDataTime, trackedData] = parseMotToComponents(...
    model, trackedDataStorage);
trackedData = trackedData';
if trackedDataTime(1) ~= 0
    trackedDataTime = trackedDataTime - trackedDataTime(1);
end
for i = 1 : size(trackedData, 2)
    if model.getCoordinateSet().get(coordinateLabels(i)).getMotionType() ...
        .toString().toCharArray()' == "Rotational"
        trackedData(:, i) = trackedData(:, i) * 1;
    end
end
for j=1:numel(modelDataFiles)
    modeledStatesStorage = Storage(modelDataFiles(j));
    [modeledStatesLabels, modeledStatesTime, modeledStates] = ...
        parseMotToComponents(model, modeledStatesStorage);
    modeledStates = modeledStates';
    if modeledStatesTime ~= 0
        modeledStatesTime = modeledStatesTime - modeledStatesTime(1);
    end
    
    modeledVelocities{j} = modeledStates(:, size(modeledStates, 2)/2+1:end);
    modeledVelocitiesLabels = modeledStatesLabels(size(modeledStates, 2)/2+1:end);
    modeledVelocitiesTime{j} = modeledStatesTime;

    for i = 1 : size(modeledStates(:, 1:size(modeledStates, 2)/2), 2)
        if model.getCoordinateSet().get(modeledStatesLabels(i)).getMotionType() ...
            .toString().toCharArray()' == "Rotational"
            modeledVelocities{j}(:, i) = modeledVelocities{j}(:, i) * 1;

        end
    end
end
experimentalSpline = makeGcvSplineSet(trackedDataTime, ...
    trackedData, coordinateLabels);
trackedVelocities = evaluateGcvSplines(experimentalSpline, coordinateLabels, ...
    trackedDataTime, 1);
resampledExperimentalVelocities = {};
for j = 1 : numel(modelDataFiles)
    resampledExperimentalVelocities{j}= evaluateGcvSplines(experimentalSpline, ...
        coordinateLabels, modeledVelocitiesTime{j}, 1);
end
if nargin < 4
    figureWidth = ceil(sqrt(numel(modeledVelocitiesLabels)));
    figureHeight = ceil(numel(modeledVelocitiesLabels)/figureWidth);
elseif nargin < 5
    figureHeight = ceil(sqrt(numel(modeledVelocitiesLabels)));
end
figureSize = figureWidth * figureHeight;
figure(Name = "Treatment Optimization Joint Velocities", ...
    Units='normalized', ...
    Position=[0.05 0.05 0.9 0.85])
colors = getPlottingColors();
subplotNumber = 1;
figureNumber = 1;
t = tiledlayout(figureHeight, figureWidth, ...
    TileSpacing='compact', Padding='compact');
xlabel(t, "Percent Movement [0-100%]")
ylabel(t, "Joint Velocity [rad/s]")

for i=1:numel(modeledVelocitiesLabels)
    if i > figureSize * figureNumber
        figureNumber = figureNumber + 1;
        figure(Name="Treatment Optimization Joint Velocities", ...
            Units='normalized', ...
            Position=[0.05 0.05 0.9 0.85])
        t = tiledlayout(figureHeight, figureWidth, ...
            TileSpacing='Compact', Padding='Compact');
        xlabel(t, "Percent Movement [0-100%]")
        ylabel(t, "Joint Velocity [rad/s]")
        subplotNumber = 1;
    end
    coordinateIndex = find(modeledStatesLabels(i) == coordinateLabels);
    if ~isempty(coordinateIndex)
        nexttile(subplotNumber);
        hold on
        plot(trackedDataTime/trackedDataTime(end)*100, trackedVelocities(:, coordinateIndex), ...
            lineWidth=2, Color = colors(1))
        for j = 1 : numel(modelDataFiles)
            plot(modeledVelocitiesTime{j}/modeledVelocitiesTime{j}(end)*100, modeledVelocities{j}(:, i), ...
                lineWidth=2, Color = colors(j+1));
        end
        hold off
        titleString = [sprintf("%s", strrep(coordinateLabels(coordinateIndex), "_", " "))];
        for j = 1 : numel(modelDataFiles)
            rmse = rms(resampledExperimentalVelocities{j}(:, coordinateIndex) - ...
                modeledVelocities{j}(:, i));
            titleString(j+1) = sprintf("RMSE %d: %.4f", j, rmse);
        end
        title(titleString)
        if subplotNumber==1
            splitFileName = split(trackedDataFile, ["/", "\"]);
            for k = 1 : numel(splitFileName)
                if ~strcmp(splitFileName(k), "..")
                    legendValues = sprintf("%s (T)", ...
                        strrep(splitFileName(k), "_", " "));
                    break
                end
            end
            for j = 1 : numel(modelDataFiles)
                splitFileName = split(modelDataFiles(j), ["/", "\"]);
                legendValues(j+1) = sprintf("%s (%d)", splitFileName(1), j);
            end
            legend(legendValues)
        end
        xlim("tight")
        maxData = [];
        minData = [];
        for j = 1 : numel(modelDataFiles)
            maxData(j) = max(modeledVelocities{j}(:, i), [], "all");
            minData(j) = min(modeledVelocities{j}(:, i), [], "all");
        end
        maxData(j+1) = max(trackedVelocities(:, i), [], "all");
        minData(j+1) = min(trackedVelocities(:, i), [], "all");
        yLimitUpper = max(maxData);
        yLimitLower = min(minData);
        minimum = 3;
        if yLimitUpper - yLimitLower < minimum
            ylim([(yLimitUpper+yLimitLower)/2-minimum, (yLimitUpper+yLimitLower)/2+minimum])
        end
        subplotNumber = subplotNumber + 1;
    end
end

end
