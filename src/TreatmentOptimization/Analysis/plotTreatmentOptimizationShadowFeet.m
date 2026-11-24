% This function is part of the NMSM Pipeline, see file for full license.
%
% Plots the pose of each shadow foot against the pose of the model's foot
% from <trial>_shadowFeetValidation.sto files written by Treatment
% Optimization with <use_shadow_feet>. Each contact surface gets its own
% figure with the toe angle, the three ground joint rotations, and the
% three ground joint translations. The model's foot is drawn with a solid
% line and the shadow foot with a dashed line, in one color per results
% file.
%
% Args:
% resultsDataFiles (Array of strings) - String array of
%   _shadowFeetValidation.sto files.
%
% Optional varargin:
% useRadians (logical) - "useRadians=0" for plotting angles in degrees, or
%   "useRadians=1" for plotting angles in radians.
%   Default is 0.
% legend (array of strings) - specify legend values to use instead of the
%   default, one per results file.
%   Default is the name of each file's results directory.
% showRmse (boolean) - "showRmse=1" to show the RMSE between the shadow
%   foot and the model's foot in each subplot title. "showRmse=0" to hide
%   it.
%   Default is 1.
% figureGridSize (array of int) - [FigureWidth, FigureHeight].
%   Default is [4, 2].

% ----------------------------------------------------------------------- %
% The NMSM Pipeline is a toolkit for model personalization and treatment  %
% optimization of neuromusculoskeletal models through OpenSim. See        %
% nmsm.rice.edu and the NOTICE file for more information. The             %
% NMSM Pipeline is developed at Rice University and supported by the US   %
% National Institutes of Health (R01 EB030520).                           %
%                                                                         %
% Copyright (c) 2026 Rice University and the Authors                      %
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

function plotTreatmentOptimizationShadowFeet(resultsDataFiles, varargin)
params = getPlottingParams();
if ~isempty(varargin)
    options = parseVarargin(varargin);
else
    options = struct();
end
useRadians = valueOrAlternate(options, "useRadians", 0);
showRmse = valueOrAlternate(options, "showRmse", 1);
resultsDataFiles = convertCharsToStrings(resultsDataFiles);

[~, results] = parsePlottingData([], resultsDataFiles, ...
    org.opensim.modeling.Model());
if isfield(options, "legend")
    fileNames = options.legend;
else
    % Each file is in the top of its results directory
    fileNames = strings(1, numel(resultsDataFiles));
    for j = 1 : numel(resultsDataFiles)
        [~, fileNames(j)] = fileparts(fileparts(resultsDataFiles(j)));
    end
end
legendString = strings(1, 0);
for j = 1 : numel(resultsDataFiles)
    legendString(end + 1 : end + 2) = [fileNames(j) + " model foot", ...
        fileNames(j) + " shadow foot"];
end

% The file has, for each contact surface, seven shadow foot columns each
% followed by the matching model foot column
labels = string(results.labels{1});
numSurfaces = numel(labels) / 14;
for surface = 1 : numSurfaces
    columns = 14 * (surface - 1) + (1 : 14);
    shadowLabels = labels(columns(1 : 2 : end));
    footName = extractBefore(shadowLabels(2), "_shadow");
    makeShadowFeetFigure(params, options, footName, useRadians);
    for k = 1 : 7
        nexttile(k);
        set(gca, fontsize = params.tickLabelFontSize, ...
            color = params.subplotBackgroundColor)
        isAngle = k <= 4;
        scale = 1;
        if isAngle && ~useRadians
            scale = 180 / pi;
        end
        titleString = strrep(erase(shadowLabels(k), "_shadow"), "_", " ");
        hold on
        for j = 1 : numel(resultsDataFiles)
            [shadowColumn, modelColumn] = findColumns(results.labels{j}, ...
                shadowLabels(k));
            shadow = results.data{j}(:, shadowColumn) * scale;
            model = results.data{j}(:, modelColumn) * scale;
            color = params.lineColors(mod(j - 1, ...
                numel(params.lineColors)) + 1);
            plot(results.normalizedTime{j} * 100, model, ...
                LineWidth = params.linewidth, Color = color)
            plot(results.normalizedTime{j} * 100, shadow, ...
                LineWidth = params.linewidth, Color = color, ...
                LineStyle = "--")
            if showRmse
                titleString(end + 1) = sprintf("RMSE %d: %.4g %s", j, ...
                    rms(shadow - model), unitName(isAngle, useRadians));
            end
        end
        hold off
        title(titleString, fontsize = params.subplotTitleFontSize, ...
            Interpreter = "none")
        xlim("tight")
        if k == 7
            legend(legendString, fontsize = params.legendFontSize, ...
                Interpreter = "none")
        end
    end
end
end

function options = parseVarargin(varargin)
options = struct();
varargin = varargin{1};
for k = 1 : 2 : numel(varargin)
    options.(varargin{k}) = varargin{k + 1};
end
end

function [shadowColumn, modelColumn] = findColumns(labels, shadowLabel)
labels = string(labels);
shadowColumn = find(labels == shadowLabel, 1);
modelColumn = find(labels == erase(shadowLabel, "_shadow"), 1);
assert(~isempty(shadowColumn) && ~isempty(modelColumn), ...
    "Shadow feet results files do not have the same contact surfaces")
end

function name = unitName(isAngle, useRadians)
if ~isAngle
    name = "m";
elseif useRadians
    name = "rad";
else
    name = "deg";
end
end

function makeShadowFeetFigure(params, options, footName, useRadians)
if isfield(options, "figureGridSize")
    figureWidth = options.figureGridSize(1);
    figureHeight = options.figureGridSize(2);
else
    figureWidth = 4;
    figureHeight = 2;
end
figure(Name = "Shadow Foot Pose: " + footName, ...
    Units = params.units, ...
    Position = params.figureSize)
tileFigure = tiledlayout(figureHeight, figureWidth, ...
    TileSpacing = 'compact', Padding = 'compact');
title(tileFigure, "Model foot vs shadow foot: " + footName, ...
    Interpreter = "none")
xlabel(tileFigure, "Percent Movement [0-100%]", ...
    fontsize = params.axisLabelFontSize)
if useRadians
    ylabel(tileFigure, "Angle [rad] / Translation [m]", ...
        fontsize = params.axisLabelFontSize)
else
    ylabel(tileFigure, "Angle [deg] / Translation [m]", ...
        fontsize = params.axisLabelFontSize)
end
set(gcf, color = params.plotBackgroundColor)
end
