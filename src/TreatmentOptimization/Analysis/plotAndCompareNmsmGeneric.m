% This function is part of the NMSM Pipeline, see file for full license.
%
% Plots and compares any number of .sto or .mot files on the same
% subplots. Columns are matched by name, so the files do not need to have
% the same columns or the same column order. If a file is missing a
% column, that file's line is left out of that subplot. Time is normalized
% to 0-100% by default so trials with different durations line up.
%
% Args:
% dataFiles (array of strings) - .sto or .mot files to plot. The first
%   file is the reference for RMSE values.
%
% Optional varargin:
% columnsToUse (array of strings) - list of column names to plot. Can be
%   in any order.
%   Default is every column found in any of the files.
% columnNames (array of strings) - specify the names to use in subplot
%   titles (ie plot "Right Hip" instead of "hip_flexion_r".) Must be the
%   same dimension as columnsToUse.
%   Default is the column names.
% legend (array of strings) - specify legend values to use instead of the
%   default.
%   Default uses the part of each file path that differs between files.
% showRmse (boolean) - "showRmse=1" to display the RMSE between each file
%   and the first file in all subplot titles.
%   Default is 0.
% normalizeTime (boolean) - "normalizeTime=0" to plot against time in
%   seconds instead of percent movement.
%   Default is 1.
% yLabel (string) - y axis label.
%   Default is "Quantity".
% figureName (string) - name of the figure window(s).
% figureGridSize (array of int) - [FigureWidth, FigureHeight].
%
% Example:
% plotAndCompareNmsmGeneric(fullfile(["NCPResults_A", "NCPResults_B"], ...
%     "gait_1_combinedActivations.sto"), showRmse=1)

% ----------------------------------------------------------------------- %
% The NMSM Pipeline is a toolkit for model personalization and treatment  %
% optimization of neuromusculoskeletal models through OpenSim. See        %
% nmsm.rice.edu and the NOTICE file for more information. The             %
% NMSM Pipeline is developed at Rice University and supported by the US   %
% National Institutes of Health (R01 EB030520).                           %
%                                                                         %
% Copyright (c) 2021 Rice University and the Authors                      %
% Author(s): Xuanning Liu                                                 %
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
function plotAndCompareNmsmGeneric(dataFiles, varargin)
import org.opensim.modeling.Model
params = getPlottingParams();
if ~isempty(varargin)
    options = parseVarargin(varargin);
else
    options = struct();
end
showRmse = valueOrDefault(options, "showRmse", 0);
normalizeTime = valueOrDefault(options, "normalizeTime", 1);

dataFiles = reshape(string(dataFiles), 1, []);
checkDataFiles(dataFiles);
model = org.opensim.modeling.Model();
[~, inputs] = parsePlottingData([], dataFiles, model);
for j = 1 : numel(dataFiles)
    inputs.labels{j} = reshape(string(inputs.labels{j}), 1, []);
end

% Match columns by name across all files
allLabels = [inputs.labels{:}];
if isfield(options, "columnsToUse")
    columns = reshape(string(options.columnsToUse), 1, []);
    missingColumns = setdiff(columns, allLabels, "stable");
    if ~isempty(missingColumns)
        error("plotAndCompareNmsmGeneric:ColumnNotFound", ...
            "Columns not found in any data file: %s", ...
            strjoin(missingColumns, ", "));
    end
else
    columns = unique(allLabels, "stable");
end

% Allow renaming columns in the subplot titles
if isfield(options, "columnNames")
    titles = reshape(string(options.columnNames), 1, []);
    if numel(titles) ~= numel(columns)
        error("plotAndCompareNmsmGeneric:ColumnNamesMismatch", ...
            "Number of columnNames (%d) must match number of " + ...
            "columns (%d).", numel(titles), numel(columns));
    end
else
    titles = columns;
end

if isfield(options, "legend")
    legendString = string(options.legend);
    if numel(legendString) ~= numel(dataFiles)
        error("plotAndCompareNmsmGeneric:LegendMismatch", ...
            "Number of legend entries (%d) must match number of " + ...
            "data files (%d).", numel(legendString), numel(dataFiles));
    end
else
    legendString = makeLegend(dataFiles);
end

if normalizeTime
    time = cellfun(@(t) t * 100, inputs.normalizedTime, ...
        UniformOutput=false);
    xLabel = "Percent Movement [0-100%]";
else
    time = inputs.time;
    xLabel = "Time [s]";
end

tileFigure = makeFigure(params, options, numel(columns), xLabel);
figureSize = tileFigure.GridSize(1)*tileFigure.GridSize(2);
subplotNumber = 1;
for i = 1 : numel(columns)
    if subplotNumber > figureSize
        makeFigure(params, options, numel(columns), xLabel);
        subplotNumber = 1;
    end
    nexttile(subplotNumber)

    set(gca, ...
        fontsize = params.tickLabelFontSize, ...
        color=params.subplotBackgroundColor)
    hold on
    for j = 1 : numel(dataFiles)
        [lineColor, lineStyle] = getLineAppearance(params, j);
        % Missing columns still get a (empty) line so legend entries align
        plot(time{j}, getColumn(inputs, j, columns(i)), ...
            LineWidth=params.linewidth, ...
            Color=lineColor, ...
            LineStyle=lineStyle);
    end
    hold off
    titleString = titles(i);
    if showRmse
        titleString = [titleString, makeRmseStrings(inputs, columns(i))];
    end
    title(titleString, fontsize = params.subplotTitleFontSize, ...
        Interpreter="none")
    if subplotNumber==figureSize || i == numel(columns)
        legend(legendString, fontsize = params.legendFontSize, ...
            Interpreter="none")
    end
    xlim("tight")
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

function value = valueOrDefault(options, name, default)
if isfield(options, name)
    value = options.(name);
else
    value = default;
end
end

function checkDataFiles(dataFiles)
if isempty(dataFiles)
    error("plotAndCompareNmsmGeneric:NoDataFiles", ...
        "Provide at least one .sto or .mot file to plot.");
end
for j = 1 : numel(dataFiles)
    if ~isfile(dataFiles(j))
        error("plotAndCompareNmsmGeneric:FileNotFound", ...
            "Data file not found:\n  %s", dataFiles(j));
    end
end
end

function columnData = getColumn(inputs, fileIndex, column)
columnIndex = find(inputs.labels{fileIndex} == column, 1);
if isempty(columnIndex)
    columnData = NaN(size(inputs.time{fileIndex}));
else
    columnData = inputs.data{fileIndex}(:, columnIndex);
end
end

% RMSE of each file against the first file, compared on normalized time so
% trials with different durations or sample counts can still be compared.
function rmseStrings = makeRmseStrings(inputs, column)
rmseStrings = strings(1, 0);
referenceData = getColumn(inputs, 1, column);
if all(isnan(referenceData))
    return
end
for j = 2 : numel(inputs.data)
    columnData = getColumn(inputs, j, column);
    if all(isnan(columnData))
        continue
    end
    resampledReference = interp1(inputs.normalizedTime{1}, ...
        referenceData, inputs.normalizedTime{j});
    rmse = rms(resampledReference(:) - columnData(:));
    rmseStrings(end+1) = sprintf("RMSE %d: %.4f", j, rmse);
end
end

% Colors cycle first, then line styles, so any number of files stays
% distinguishable.
function [lineColor, lineStyle] = getLineAppearance(params, fileIndex)
lineStyles = ["-", "--", ":", "-."];
numColors = numel(params.lineColors);
lineColor = params.lineColors(mod(fileIndex - 1, numColors) + 1);
lineStyle = lineStyles(mod(floor((fileIndex - 1) / numColors), ...
    numel(lineStyles)) + 1);
end

function tileFigure = makeFigure(params, options, numColumns, xLabel)
if isfield(options, "figureGridSize")
    figureWidth = options.figureGridSize(1);
    figureHeight = options.figureGridSize(2);
else
    figureWidth = ceil(sqrt(numColumns));
    figureHeight = ceil(numColumns/figureWidth);
end
figure(Name=valueOrDefault(options, "figureName", ""), ...
    Units=params.units, ...
    Position=params.figureSize)
tileFigure = tiledlayout(figureHeight, figureWidth, ...
    TileSpacing='compact', Padding='compact');
xlabel(tileFigure, xLabel, ...
    fontsize=params.axisLabelFontSize)
ylabel(tileFigure, valueOrDefault(options, "yLabel", "Quantity"), ...
    fontsize=params.axisLabelFontSize)
set(gcf, color=params.plotBackgroundColor)
end

% Builds legend labels from the part of each file path that differs
% between files. For example, "NCPResults_A/modelMoments/gait_1.sto" and
% "NCPResults_B/modelMoments/gait_1.sto" become "NCPResults_A" and
% "NCPResults_B".
function legendString = makeLegend(dataFiles)
pathParts = cell(1, numel(dataFiles));
for j = 1 : numel(dataFiles)
    listing = dir(dataFiles(j));
    [~, fileName, ~] = fileparts(listing.name);
    parts = [split(string(listing.folder), ["/", "\"]); string(fileName)]';
    pathParts{j} = parts(parts ~= "");
end
shortestLength = min(cellfun(@numel, pathParts));
numLeading = 0;
while numLeading < shortestLength - 1 && all(cellfun(@(parts) ...
        parts(numLeading + 1) == pathParts{1}(numLeading + 1), pathParts))
    numLeading = numLeading + 1;
end
numTrailing = 0;
while numLeading + numTrailing < shortestLength - 1 && all(cellfun( ...
        @(parts) parts(end - numTrailing) == ...
        pathParts{1}(end - numTrailing), pathParts))
    numTrailing = numTrailing + 1;
end
legendString = strings(1, numel(dataFiles));
for j = 1 : numel(dataFiles)
    legendString(j) = strjoin( ...
        pathParts{j}(numLeading + 1 : end - numTrailing), "/");
end
% Same file given twice
if numel(unique(legendString)) < numel(legendString)
    legendString = legendString + " (" + (1 : numel(legendString)) + ")";
end
end
