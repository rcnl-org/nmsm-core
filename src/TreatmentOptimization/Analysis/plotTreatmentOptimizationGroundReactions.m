% This function is part of the NMSM Pipeline, see file for full license.
%
% This function reads .sto files for experimental and model ground
% reactions and plots them. There is an option to plot multiple model files
% by passing in a list of model file names.
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
% Plot experimental and model ground reactions from file

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
function plotTreatmentOptimizationGroundReactions(trackedDataFile, ...
    resultsDataFiles, varargin)
import org.opensim.modeling.Model
params = getPlottingParams();
if ~isempty(varargin)
    options = parseVarargin(varargin);
else
    options = struct();
end
model = org.opensim.modeling.Model();
[tracked, results] = parsePlottingData(trackedDataFile, resultsDataFiles, model);

tracked = resampleTrackedData(tracked, results);
[tracked, results] = sortGroundReactionData(tracked, results);

tileFigure = makeGroundReactionsFigure(params, options);
figureSize = tileFigure.GridSize(1)*tileFigure.GridSize(2);
subplotNumber = 1;
titleStrings = makeSubplotTitles(tracked, results);
legendString = makeLegendFromFileNames(trackedDataFile, ...
            resultsDataFiles);
yLimits = makeGroundReactionsYLimits(tracked, results);

for i=1:numel(tracked.labels)
    if subplotNumber > figureSize
        tileFigure = makeGroundReactionsFigure(params, options);
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

function [tracked, results] = sortGroundReactionData(tracked, results)
% Sort results ground reactions to be in the same order as the tracked
% ground reactions. Also removes the point columns
pointIndices = contains(tracked.labels, "_p");
tracked.labels = tracked.labels(~pointIndices);
tracked.data = tracked.data(:, ~pointIndices);
for j = 1 : numel(results.data)
    [~, ~, indices] = intersect(tracked.labels, results.labels{j}, "stable");
    results.data{j} = results.data{j}(:,indices);
    results.labels{j} = results.labels{j}(indices);
end
end

function tileFigure = makeGroundReactionsFigure(params, options)
if isfield(options, "figureGridSize")
    figureWidth = options.figureGridSize(1);
    figureHeight = options.figureGridSize(2);
else
    figureWidth = 3;
    figureHeight = 2;
end
figure(Name = "Ground Reactions", ...
    Units=params.units, ...
    Position=params.figureSize)
tileFigure = tiledlayout(figureHeight, figureWidth, ...
    TileSpacing='compact', Padding='compact');
xlabel(tileFigure, "Percent Movement [0-100%]", ...
    fontsize=params.axisLabelFontSize)
ylabel(tileFigure, "Ground Reaction", ...
    fontsize=params.axisLabelFontSize)
set(gcf, color=params.plotBackgroundColor)
end

function yLimits = makeGroundReactionsYLimits(tracked, results)
for i = 1 : numel(tracked.labels)
    maxData = [];
    minData = [];
    maxData(1) = max(tracked.data(1:end-1, i), [], "all");
    minData(1) = min(tracked.data(1:end-1, i), [], "all");
    for j = 1 : numel(results.data)
        maxData(j+1) = max(results.data{j}(1:end-1, i), [], "all");
        minData(j+1) = min(results.data{j}(1:end-1, i), [], "all");
    end
    yLimits{i} = [min(minData), max(maxData)];
end
end