% This function is part of the NMSM Pipeline, see file for full license.
%
% This function reads .sto files for experimental and model joint loads
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
% Plot experimental and model joint loads from file

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
function plotTreatmentOptimizationJointLoads(trackedDataFile, ...
    resultsDataFiles, varargin)
import org.opensim.modeling.Model
params = getPlottingParams();
if ~isempty(varargin)
    options = parseVarargin(varargin);
else
    options = struct();
end

model = org.opensim.modeling.Model();
[tracked, results] = parsePlottingData(trackedDataFile, ...
    resultsDataFiles, model);
if isfield(options, "columnsToUse")
    [~, ~, trackedIndices] = intersect(options.columnsToUse, tracked.labels, "stable");
    tracked.data = tracked.data(:, trackedIndices); 
    tracked.labels = tracked.labels(trackedIndices);
    
    for j = 1 : numel(resultsDataFiles)
        [~, ~, resultsIndices] = intersect(options.columnsToUse, results.labels{j}, "stable");
        results.data{j} = results.data{j}(:, resultsIndices);
        results.labels{j} = results.labels{j}(resultsIndices);
    end
end
if isfield(options, "columnNames")
    tracked.labels = options.columnNames;
    for j = 1 : numel(resultsDataFiles)
        results.labels{j} = options.columnNames;
    end
end
tracked = resampleTrackedData(tracked, results);

tileFigure = makeJointLoadsFigure(params, options, tracked);
figureSize = tileFigure.GridSize(1)*tileFigure.GridSize(2);
subplotNumber = 1;

titleStrings = makeJointLoadsSubplotTitles(tracked, results);
if isfield(options, "legend")
    legendString = options.legend;
else
    legendString = makeLegendFromFileNames(trackedDataFile, ...
                resultsDataFiles);
end

yLimits = makeJointLoadsYLimits(tracked, results);

for i=1:numel(tracked.labels)
    % If we exceed the specified figure size, create a new figure
    if subplotNumber > figureSize
        makeJointLoadsFigure(params, options, tracked, useRadians);
        subplotNumber = 1;
    end
    nexttile(subplotNumber);
    
    set(gca, ...
        fontsize = params.tickLabelFontSize, ...
        color=params.subplotBackgroundColor)
    hold on
    
    plot(tracked.normalizedTime*100, tracked.data(:, i), ...
        LineWidth=params.linewidth, ...
        Color = params.lineColors(1));
    for j = 1 : numel(results.data)
        results.data{j}(:, i) = lowpassFilter(results.time{j}, results.data{j}(:, i), 4, 10, 0);
        plot(results.normalizedTime{j}*100, results.data{j}(:, i), ...
            LineWidth=params.linewidth, ...
            Color = params.lineColors(j+1));
    end
    hold off

    title(titleStrings{i}, fontsize = params.subplotTitleFontSize, ...
            Interpreter="none")
    if subplotNumber==figureSize || i == numel(tracked.labels)
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

function tileFigure = makeJointLoadsFigure(params, options, tracked)
if isfield(options, "figureGridSize")
    figureWidth = options.figureGridSize(1);
    figureHeight = options.figureGridSize(2);
else
    figureWidth = ceil(sqrt(numel(tracked.labels)));
    figureHeight = ceil(numel(tracked.labels)/figureWidth);
end
figure(Name = "Joint Loads", ...
    Units=params.units, ...
    Position=params.figureSize)
tileFigure = tiledlayout(figureHeight, figureWidth, ...
    TileSpacing='compact', Padding='compact');
xlabel(tileFigure, "Percent Movement [0-100%]", ...
    fontsize=params.axisLabelFontSize)
ylabel(tileFigure, "Joint Loads", ...
    fontsize=params.axisLabelFontSize)
set(gcf, color=params.plotBackgroundColor)
end

function yLimits = makeJointLoadsYLimits(tracked, results)
for i = 1 : numel(tracked.labels)
    maxData = [];
    minData = [];
    maxData(1) = max(tracked.data(1:end-1, i), [], "all");
    minData(1) = min(tracked.data(1:end-1, i), [], "all");
    for j = 1 : numel(results.data)
        maxData(j+1) = max(results.data{j}(1:end-1, i), [], "all");
        minData(j+1) = min(results.data{j}(1:end-1, i), [], "all");
    end
    yLimitUpper = max(maxData);
    yLimitLower = min(minData);
    if yLimitUpper - yLimitLower < 10
        yLimits{i} = [(yLimitUpper+yLimitLower)/2-10, ...
            (yLimitUpper+yLimitLower)/2+10];
    else
        yLimits{i} = [yLimitLower, yLimitUpper];
    end
end
end

function titleStrings = makeJointLoadsSubplotTitles(tracked, results)
for i = 1 : numel(tracked.labels)
    if contains(tracked.labels(i), "moment")
        titleString = [sprintf("%s [Nm]", strrep(tracked.labels(i), ...
            "_", " "))];
    elseif contains(tracked.labels(i), "force")
        titleString = [sprintf("%s [N]", strrep(tracked.labels(i), ...
            "_", " "))];
    else
        titleString = [sprintf("%s", strrep(tracked.labels(i), ...
            "_", " "))];
    end
    for j = 1 : numel(results.data)
        rmse = rms(tracked.resampledData{j}(1:end-1, i) - ...
            results.data{j}(1:end-1, i));
        % titleString(j+1) = sprintf("RMSE %d: %.4f", j, rmse);
    end
    titleStrings{i} = titleString;
end
end