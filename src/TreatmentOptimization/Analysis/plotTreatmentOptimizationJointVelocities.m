% This function is part of the NMSM Pipeline, see file for full license.
%
% Plots joint velocities from a Treatment Optimization run. 
% The tracked data file should be inverse kinematics joint angles.
% The results data files should be states files from the Treatment 
% Optimization runs.
%
% Args:
% modelFileName (string) - Osim model file being used.
% trackedDataFile (string) - .sto or .mot file. 
%   RMSE values will be calculated between this file and all results data 
%   files.
% resultsDataFiles (Array of strings) - String array of .sto or .mot files.
%
% Optional varargin:
% useRadians (boolean) - "useRadians=0" for plotting in degrees, or ...
%   "useRadians=1" for plotting in radians.
%   Default is 1.
% columnsToUse (array of strings) - list of column names to plot in the
%   given .sto or .mot files. Useful to plot only a subset of the
%   coordinates in the model. Can be in any order.
%   Default is use all columns in trackedDataFile.
% columnNames (array of strings) - overrides the string to be used in
%   subplot titles (ie subplot titled "Right Hip" instead of
%   "hip_flexion_r".) Must be the same dimension as columnsToUse.
%   Default is the column names in trackedDataFile.
% legend (array of strings) - specify legend values to use instead of the
%   default.
%   Default uses the directory structure to create legend names.
% displayRmse (boolean) - "displayRmse=1" to display RMSE values for all
%   subplots. "displayRmse=0" to hide RMSE values for all subplots.
%   Default is 1.

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
if isfield(options, "showRmse")
    showRmse = options.showRmse;
else
    showRmse = 1;
end
model = Model(modelFileName);
[tracked, results] = parsePlottingData(trackedDataFile, resultsDataFiles, model);
for j = 1 : numel(results.data)
    results.data{j} = results.data{j}(:, size(results.data{j}, 2)/2+1:end);
    results.labels{j} = results.labels{j}(1:size(results.labels{j}, 2)/2);
end

% Create tracked velocities
trackedDataSpline = makeGcvSplineSet(tracked.time, ...
    tracked.data, tracked.labels);
tracked.data = evaluateGcvSplines(trackedDataSpline, tracked.labels, ...
    tracked.time, 1);

% Reorder labels
for j = 1 : numel(results.data)
    [~, ~, indices] = intersect(results.labels{1}, results.labels{j}, 'stable');
    results.data{j}(:, 1:length(indices)) = results.data{j}(:,indices);
    results.labels{j}(1:length(indices)) = results.labels{j}(indices);
end

% Only use the coordinates in the states.
[~, ~, trackedIndicesToUse] = intersect(results.labels{1}, tracked.labels, 'stable');
tracked.labels = tracked.labels(trackedIndicesToUse);
tracked.data = tracked.data(:, trackedIndicesToUse);

if ~useRadians
    [tracked, results] = convertRadiansToDegrees(model, tracked, results);
end

tracked = resampleTrackedData(tracked, results);

yLimits = makeJointVelocitiesYLimits(tracked, results, model, useRadians);

% Allow only plot certain column names from the input files
if isfield(options, "columnsToUse")
    [~, ~, trackedIndices] = intersect(options.columnsToUse, tracked.labels, "stable");
    tracked.data = tracked.data(:, trackedIndices);
    tracked.labels = tracked.labels(trackedIndices);

    for j = 1 : numel(resultsDataFiles)
        [~, ~, resultsIndices] = intersect(options.columnsToUse, results.labels{j}, "stable");
        results.data{j} = results.data{j}(:, resultsIndices);
        results.labels{j} = results.labels{j}(resultsIndices);
    end
    yLimits = yLimits(trackedIndices);
end

% Allow renaming columns
if isfield(options, "columnNames")
    tracked.labels = options.columnNames;
    for j = 1 : numel(resultsDataFiles)
        results.labels{j} = options.columnNames;
    end
end

tileFigure = makeJointVelocitiesFigure(params, options, tracked, useRadians);

figureSize = tileFigure.GridSize(1)*tileFigure.GridSize(2);

subplotNumber = 1;

titleStrings = makeSubplotTitles(tracked, results, showRmse);

if isfield(options, "legend")
    legendString = options.legend;
else
    legendString = makeLegendFromFileNames(trackedDataFile, ...
        resultsDataFiles);
end

for i=1:numel(tracked.labels)
    % If we exceed the specified figure size, create a new figure
    if subplotNumber > figureSize
        makeJointAnglesFigure(params, options, tracked, useRadians);
        subplotNumber = 1;
    end
    nexttile(subplotNumber);
    set(gca, ...
        fontsize = params.tickLabelFontSize, ...
        color=params.subplotBackgroundColor)
    hold on
    plot(tracked.normalizedTime*100, tracked.data(:, i), ...
        LineWidth=params.linewidth, ...
        Color = params.lineColors(1))
    for j = 1 : numel(resultsDataFiles)
        plot(results.normalizedTime{j}*100, results.data{j}(:, i), ...
            LineWidth=params.linewidth, ...
            Color = params.lineColors(j+1));
    end
    hold off

    title(titleStrings{i}, fontsize = params.subplotTitleFontSize, ...
        Interpreter="none")
    if subplotNumber==1
        legend(legendString, fontsize = params.legendFontSize, ...
            Interpreter="none")
    end
    xlim("tight")
    ylim(yLimits{i});
    subplotNumber = subplotNumber + 1;
end
end

function options = parseVarargin(varargin)
options = struct();
varargin = varargin{1};
for k = 1 : 2 : numel(varargin)
    options.(varargin{k}) = varargin{k+1};
end
end

function [tracked, results] = convertRadiansToDegrees(model, tracked, results)
for i = 1 : size(tracked.data, 2)
    if model.getCoordinateSet().get(tracked.labels(i)).getMotionType() ...
            .toString().toCharArray()' == "Rotational"
        tracked.data(:, i) = tracked.data(:, i) * 180/pi;
        for j = 1 : numel(results.data)
            results.data{j}(:, i) = results.data{j}(:, i) * 180/pi;
        end
    end
end
end

function tileFigure = makeJointVelocitiesFigure(params, options, tracked, useRadians)
if isfield(options, "figureGridSize")
    figureWidth = options.figureGridSize(1);
    figureHeight = options.figureGridSize(2);
else
    figureWidth = ceil(sqrt(numel(tracked.labels)));
    figureHeight = ceil(numel(tracked.labels)/figureWidth);
end
figureSize = figureWidth * figureHeight;
figure(Name = "Joint Velocities", ...
    Units=params.units, ...
    Position=params.figureSize);
tileFigure = tiledlayout(figureHeight, figureWidth, ...
    TileSpacing='compact', Padding='compact');
xlabel(tileFigure, "Percent Movement [0-100%]", ...
    fontsize=params.axisLabelFontSize)
if ~useRadians
    ylabel(tileFigure, "Joint Velocity [deg]", ...
        fontsize=params.axisLabelFontSize)
else
    ylabel(tileFigure, "Joint Velocity [rad]", ...
        fontsize=params.axisLabelFontSize)
end
set(gcf, color=params.plotBackgroundColor)
end

function yLimits = makeJointVelocitiesYLimits(tracked, results, model, useRadians)
for i = 1 : numel(tracked.labels)
    maxData = [];
    minData = [];
    maxData(1) = max(tracked.data(:, i), [], "all");
    minData(1) = min(tracked.data(:, i), [], "all");
    for j = 1 : numel(results.data)
        maxData(j+1) = max(results.data{j}(:, i), [], "all");
        minData(j+1) = min(results.data{j}(:, i), [], "all");
    end
    yLimitUpper = max(maxData);
    yLimitLower = min(minData);
    if model.getCoordinateSet().get(tracked.labels(i)).getMotionType() ...
            .toString().toCharArray()' == "Rotational"
        if ~useRadians
            minimum = 3;
        else
            minimum = 3*pi/180;
        end
    else
        minimum = 0.03;
    end
    if yLimitUpper - yLimitLower < minimum
        yLimits{i} = [(yLimitUpper+yLimitLower)/2-minimum, ...
            (yLimitUpper+yLimitLower)/2+minimum];
    else
        yLimits{i} = [yLimitLower, yLimitUpper];
    end
end
end