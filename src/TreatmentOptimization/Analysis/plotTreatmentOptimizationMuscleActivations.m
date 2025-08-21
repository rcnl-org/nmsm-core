% This function is part of the NMSM Pipeline, see file for full license.
%
% Plots muscle activations from given .sto or .mot files.
%
% Args:
% trackedDataFile (string) - .sto or .mot file. 
%   RMSE values will be calculated between this file and all results data 
%   files.
% resultsDataFiles (Array of strings) - String array of .sto or .mot files.
%
% Optional varargin:
% columnsToUse (array of strings) - list of column names to plot in the
%   given .sto or .mot files. Useful to plot only a subset of the
%   coordinates in the model. Can be in any order.
%   Default is use all columns in trackedDataFile.
% columnNames (array of strings) - specify the names to use in subplot
%   titles (ie plot "Right Hip" instead of "hip_flexion_r".) Must be the
%   same dimension as columnsToUse.
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
function plotTreatmentOptimizationMuscleActivations(trackedDataFile, ...
    resultsDataFiles, varargin)
import org.opensim.modeling.Model
params = getPlottingParams();
if ~isempty(varargin)
    options = parseVarargin(varargin);
else
    options = struct();
end
if isfield(options, "showRmse")
    showRmse = options.showRmse;
else
    showRmse = 1;
end
model = org.opensim.modeling.Model();
[tracked, results] = parsePlottingData(trackedDataFile, resultsDataFiles, model);
tracked = resampleTrackedData(tracked, results);
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
end
% Allow renaming columns in the subplot titles
if isfield(options, "columnNames")
    tracked.labels = options.columnNames;
    for j = 1 : numel(resultsDataFiles)
        results.labels{j} = options.columnNames;
    end
end
tileFigure = makeMuscleActivationsFigure(params, options, tracked);
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
    if subplotNumber > figureSize
        tileFigure = makeMuscleActivationsFigure(params, options, tracked);
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
        plot(results.normalizedTime{j}*100, results.data{j}(:, i), ...
            LineWidth=params.linewidth, ...
            Color = params.lineColors(j+1));
    end
    hold off
    title(titleStrings{i}, fontsize = params.subplotTitleFontSize)
    if subplotNumber==1
        legend(legendString, fontsize = params.legendFontSize)
    end
    xlim("tight")
    ylim([0, 1])
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

function tileFigure = makeMuscleActivationsFigure(params, options, tracked)
if isfield(options, "figureGridSize")
    figureWidth = options.figureGridSize(1);
    figureHeight = options.figureGridSize(2);
else
    figureWidth = ceil(sqrt(numel(tracked.labels)));
    figureHeight = ceil(numel(tracked.labels)/figureWidth);
end
figure(Name = "Muscle Activations", ...
    Units=params.units, ...
    Position=params.figureSize)
tileFigure = tiledlayout(figureHeight, figureWidth, ...
    TileSpacing='compact', Padding='compact');
xlabel(tileFigure, "Percent Movement [0-100%]", ...
    fontsize=params.axisLabelFontSize)
ylabel(tileFigure, "Muscle Activations", ...
    fontsize=params.axisLabelFontSize)
set(gcf, color=params.plotBackgroundColor)
end