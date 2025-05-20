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
    trackedDataFile, resultsDataFiles, varargin)
import org.opensim.modeling.Storage
params = getPlottingParams();
if nargin > 3
    options = parseVarargin(varargin);
else
    options = struct();
end
if isfield(options, "useRadians")
    useRadians = options.useRadians;
else
    useRadians = 1;
end
model = Model(modelFileName);
trackedDataStorage = Storage(trackedDataFile);
[coordinateLabels, trackedDataTime, trackedData] = parseMotToComponents(...
    model, trackedDataStorage);
trackedData = trackedData';
if trackedDataTime(1) ~= 0
    trackedDataTime = trackedDataTime - trackedDataTime(1);
end
if ~useRadians
    for i = 1 : size(trackedData, 2)
        if model.getCoordinateSet().get(coordinateLabels(i)).getMotionType() ...
                .toString().toCharArray()' == "Rotational"
            trackedData(:, i) = trackedData(:, i) * 180/pi;
        end
    end
end
for j=1:numel(resultsDataFiles)
    resultsStatesStorage = Storage(resultsDataFiles(j));
    [resultsStatesLabels, resultsStatesTime, resultsStates] = ...
        parseMotToComponents(model, resultsStatesStorage);
    resultsStates = resultsStates';
    if resultsStatesTime ~= 0
        resultsStatesTime = resultsStatesTime - resultsStatesTime(1);
    end
    
    resultsVelocities{j} = resultsStates(:, size(resultsStates, 2)/2+1:end);
    resultsVelocitiesLabels = resultsStatesLabels(size(resultsStates, 2)/2+1:end);
    resultsVelocitiesTime{j} = resultsStatesTime;
    if ~useRadians
        for i = 1 : size(resultsStates(:, 1:size(resultsStates, 2)/2), 2)
            if model.getCoordinateSet().get(resultsStatesLabels(i)).getMotionType() ...
                    .toString().toCharArray()' == "Rotational"
                resultsVelocities{j}(:, i) = resultsVelocities{j}(:, i) * 180/pi;
    
            end
        end
    end
end
trackedDataSpline = makeGcvSplineSet(trackedDataTime, ...
    trackedData, coordinateLabels);
trackedVelocities = evaluateGcvSplines(trackedDataSpline, coordinateLabels, ...
    trackedDataTime, 1);
resampledTrackedVelocities = {};
for j = 1 : numel(resultsDataFiles)
    resampledTrackedVelocities{j}= evaluateGcvSplines(trackedDataSpline, ...
        coordinateLabels, resultsVelocitiesTime{j}, 1);
end
if isfield(options, "figureGridSize")
    figureWidth = options.figureGridSize(1);
    figureHeight = options.figureGridSize(2);
else
    figureWidth = ceil(sqrt(numel(resultsVelocitiesLabels)));
    figureHeight = ceil(numel(resultsVelocitiesLabels)/figureWidth);
end
figureSize = figureWidth * figureHeight;
figure(Name = "Joint Velocities", ...
    Units=params.units, ...
    Position=params.figureSize)
subplotNumber = 1;
figureNumber = 1;
t = tiledlayout(figureHeight, figureWidth, ...
    TileSpacing='compact', Padding='compact');
xlabel(t, "Percent Movement [0-100%]", ...
    fontsize=params.axisLabelFontSize)
if ~useRadians
    ylabel(t, "Joint Velocity [deg/s]", ...
        fontsize=params.axisLabelFontSize)
else
    ylabel(t, "Joint Velocity [rad/s]", ...
        fontsize=params.axisLabelFontSize)
end
set(gcf, color=params.plotBackgroundColor)
for i=1:numel(resultsVelocitiesLabels)
    if i > figureSize * figureNumber
        figureNumber = figureNumber + 1;
        figure(Name="Joint Velocities", ...
            Units=params.units, ...
            Position=params.figureSize)
        t = tiledlayout(figureHeight, figureWidth, ...
            TileSpacing='Compact', Padding='Compact');
        xlabel(t, "Percent Movement [0-100%]", ...
            fontsize=params.axisLabelFontSize)
        if ~useRadians
            ylabel(t, "Joint Velocity [deg/s]", ...
                fontsize=params.axisLabelFontSize)
        else
            ylabel(t, "Joint Velocity [rad/s]", ...
                fontsize=params.axisLabelFontSize)
        end
        set(gcf, color=params.plotBackgroundColor)
        subplotNumber = 1;
    end
    coordinateIndex = find(resultsStatesLabels(i) == coordinateLabels);
    if ~isempty(coordinateIndex)
        nexttile(subplotNumber);
        set(gca, ...
            fontsize = params.tickLabelFontSize, ...
            color=params.subplotBackgroundColor)
        hold on
        plot(trackedDataTime*100, trackedVelocities(:, coordinateIndex), ...
            LineWidth=params.linewidth, ...
            Color = params.lineColors(1))
        for j = 1 : numel(resultsDataFiles)
            plot(resultsVelocitiesTime{j}*100, resultsVelocities{j}(:, i), ...
            LineWidth=params.linewidth, ...
            Color = params.lineColors(j+1));
        end
        hold off
        titleString = [sprintf("%s", strrep(coordinateLabels(coordinateIndex), "_", " "))];
        for j = 1 : numel(resultsDataFiles)
            rmse = rms(resampledTrackedVelocities{j}(:, coordinateIndex) - ...
                resultsVelocities{j}(:, i));
            titleString(j+1) = sprintf("RMSE %d: %.4f", j, rmse);
        end
        title(titleString, fontsize = params.subplotTitleFontSize)
        if subplotNumber==1
            splitFileName = split(trackedDataFile, ["/", "\"]);
            for k = 1 : numel(splitFileName)
                if ~strcmp(splitFileName(k), "..")
                    legendValues = sprintf("%s (T)", ...
                        strrep(splitFileName(k), "_", " "));
                    break
                end
            end
            for j = 1 : numel(resultsDataFiles)
                splitFileName = split(resultsDataFiles(j), ["/", "\"]);
                legendValues(j+1) = sprintf("%s (%d)", splitFileName(1), j);
            end
            legend(legendValues, fontsize = params.legendFontSize);
        end
        xlim("tight")
        maxData = [];
        minData = [];
        for j = 1 : numel(resultsDataFiles)
            maxData(j) = max(resultsVelocities{j}(:, i), [], "all");
            minData(j) = min(resultsVelocities{j}(:, i), [], "all");
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

function options = parseVarargin(varargin)
    options = struct();
    varargin = varargin{1};
    for k = 1 : 2 : numel(varargin)
        options.(varargin{k}) = varargin{k+1};
    end
end
