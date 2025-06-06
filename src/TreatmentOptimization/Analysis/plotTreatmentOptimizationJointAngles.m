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
% (string) (string) (List of strings) (int), (int) -> (None)
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
function plotTreatmentOptimizationJointAngles(modelFileName, ...
    trackedDataFile, resultsDataFiles, varargin)
import org.opensim.modeling.Storage
params = getPlottingParams();
if ~isempty(varargin)
    options = parseVarargin(varargin);
else
    options = struct();
end
if isfield(options, "useRadians")
    useRadians = options.useRadians;
else
    useRadians = 0;
end
model = Model(modelFileName);

[tracked, results] = parsePlottingData(trackedDataFile, resultsDataFiles);
if ~useRadians
    [tracked, results] = convertRadiansToDegrees(model, tracked, results);
end

tracked = splineAndResamplePlottingData(tracked, results);

if isfield(options, "figureGridSize")
    figureWidth = options.figureGridSize(1);
    figureHeight = options.figureGridSize(2);
else
    figureWidth = ceil(sqrt(numel(tracked.labels)));
    figureHeight = ceil(numel(tracked.labels)/figureWidth);
end
figureSize = figureWidth * figureHeight;
figure(Name = "Joint Angles", ...
    Units=params.units, ...
    Position=params.figureSize)
subplotNumber = 1;
figureNumber = 1;
t = tiledlayout(figureHeight, figureWidth, ...
    TileSpacing='compact', Padding='compact');
xlabel(t, "Percent Movement [0-100%]", ...
    fontsize=params.axisLabelFontSize)
if ~useRadians
    ylabel(t, "Joint Angle [deg]", ...
        fontsize=params.axisLabelFontSize)
else
    ylabel(t, "Joint Angle [rad]", ...
        fontsize=params.axisLabelFontSize)
end
set(gcf, color=params.plotBackgroundColor)
for i=1:numel(tracked.labels)
    % If we exceed the specified figure size, create a new figure
    if i > figureSize * figureNumber
        figureNumber = figureNumber + 1;
        figure(Name="Joint Angles", ...
            Units=params.units, ...
            Position=params.figureSize)
        t = tiledlayout(figureHeight, figureWidth, ...
    TileSpacing='compact', Padding='compact');
    xlabel(t, "Percent Movement [0-100%]", ...
        fontsize=params.axisLabelFontSize)
    if ~useRadians
        ylabel(t, "Joint Angle [deg]", ...
            fontsize=params.axisLabelFontSize)
    else
        ylabel(t, "Joint Angle [rad]", ...
            fontsize=params.axisLabelFontSize)
    end
        set(gcf, color=params.plotBackgroundColor)
        subplotNumber = 1;
    end

    nexttile(subplotNumber);
    set(gca, ...
        fontsize = params.tickLabelFontSize, ...
        color=params.subplotBackgroundColor)
    hold on
    plot(tracked.time*100, tracked.data(:, i), ...
        LineWidth=params.linewidth, ...
        Color = params.lineColors(1));
    for j = 1 : numel(results.data)
        plot(results.time{j}*100, results.data{j}(:, i), ...
            LineWidth=params.linewidth, ...
            Color = params.lineColors(j+1));
    end
    hold off

    titleString = [sprintf("%s", strrep(tracked.labels(i), "_", " "))];
    for j = 1 : numel(results.data)
        rmse = rms(tracked.resampledData{j}(:, i) - results.data{j}(:, i));
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
        legend(legendValues, fontsize = params.legendFontSize)
    end
    
    xlim("tight")
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
            minimum = 10;
        else
            minimum = 10*pi/180;
        end
    else
        minimum = 0.1;
    end
    if yLimitUpper - yLimitLower < minimum
        ylim([(yLimitUpper+yLimitLower)/2-minimum, (yLimitUpper+yLimitLower)/2+minimum])
    end
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