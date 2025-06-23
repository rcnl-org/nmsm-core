% This function is part of the NMSM Pipeline, see file for full license.
%
% This function reads one .sto file for treatment optimization synergy
% controls and plots it.
%
% There are 2 optional arguments for figure width and figure height. If no
% optional arguments are given, the figure size is automatically adjusted
% to fit all data on one plot. Giving just figure width and no figure
% height will set figure height to a default value and extra figures will
% be created as needed. If both figure width and figure height are given,
% the figure size will be fixed and extra figures will be created as
% needed.
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
function plotTreatmentOptimizationSynergyControls(...
    trackedActivationsFile, trackedWeightsFile, ...
    resultsActivationsFiles, resultsWeightsFiles, ...
    osimx, synergyNormalizationMethod, synergyNormalizationValue, varargin)
import org.opensim.modeling.Model
params = getPlottingParams();
if ~isempty(varargin)
    options = parseVarargin(varargin);
else
    options = struct();
end

model = org.opensim.modeling.Model();
[trackedActivations, resultsActivations] = parsePlottingData(...
    trackedActivationsFile, resultsActivationsFiles, model);

[trackedWeights, resultsWeights] = parsePlottingData(...
    trackedWeightsFile, resultsWeightsFiles, model);

[trackedActivations.data, trackedWeights.data] = normalizeSynergyData(...
    trackedActivations.data, trackedWeights.data, ...
    synergyNormalizationMethod, synergyNormalizationValue);

for i = 1 : numel(resultsActivations.data)
    [resultsActivations.data{i}, resultsWeights.data{i}] = ...
        normalizeSynergyData(...
        resultsActivations.data{i}, resultsWeights.data{i}, ...
        synergyNormalizationMethod, synergyNormalizationValue);
end
trackedActivations = resampleTrackedData(trackedActivations, ...
    resultsActivations);

plotSynergyActivations(trackedActivations, resultsActivations, ...
    params, options);
plotSynergyVectors(trackedWeights, trackedActivations.labels, ...
    resultsWeights, params, osimx);
end

function plotSynergyActivations(tracked, results, params, options)
tileFigure = makeSynergyActivationsFigure(params, options, tracked);
figureSize = tileFigure.GridSize(1)*tileFigure.GridSize(2);
subplotNumber = 1;

titleStrings = makeSubplotTitles(tracked, results);
legendString = makeLegendFromFileNames(tracked.dataFile, ...
            results.dataFiles);
% Max tracked synergy activation. Used to set the plot y axis.
maxActivations = [max(tracked.data, [], "all")];
for i = 1 : numel(results.data)
    maxActivations(i+1) = max(results.data{i}, [], "all");
end
upperYLimit = max(maxActivations);

for i=1:numel(tracked.labels)
    if subplotNumber > figureSize
        tileFigure = makeSynergyActivationsFigure(params, options, tracked);
        subplotNumber = 1;
    end
    nexttile(subplotNumber);
    set(gca, ...
        fontsize = params.tickLabelFontSize, ...
        color=params.subplotBackgroundColor)
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

    title(titleStrings{i}, fontsize = params.subplotTitleFontSize, ...
            Interpreter="none")
    if subplotNumber==1
        legend(legendString, fontsize = params.legendFontSize, ...
            Interpreter="none")
    end
    xlim("tight")
    ylim([0 upperYLimit])
    subplotNumber = subplotNumber + 1;
end
end

function plotSynergyVectors(tracked, synergyLabels, results, params, osimx)
% Outer level: iterate through synergy sets. We get 1 plot for each synergy
% set for readability.
synergyNumber = 1;
legendString = makeLegendFromFileNames(tracked.dataFile, ...
            results.dataFiles);
for synergyGroup = 1 : numel(osimx.synergyGroups)
    synergyGroup = osimx.synergyGroups{synergyGroup};
    muscleIndices = contains(tracked.labels, synergyGroup.muscleNames);
    tileFigure = makeSynergyVectorsFigure(params, synergyGroup);
    figureHeight = tileFigure.GridSize(1);
    for i = 1 : synergyGroup.numSynergies
        weightsPlottingArray = [tracked.data(synergyNumber, ...
            muscleIndices)];
        for k = 1 : numel(results.data)
            weightsPlottingArray = [weightsPlottingArray; ...
                results.data{k}(synergyNumber, muscleIndices)];
        end

        nexttile(i)
        set(gca, ...
            fontsize = params.tickLabelFontSize, ...
            color=params.subplotBackgroundColor)
        b = bar(1:numel(synergyGroup.muscleNames), ...
            weightsPlottingArray);
        b(1).FaceColor = params.lineColors(1);
        for k = 1 : numel(results.data)
            b(k+1).FaceColor = params.lineColors(k+1);
        end
        if i == figureHeight
            xticks(1:numel(synergyGroup.muscleNames))
            xticklabels(synergyGroup.muscleNames)
        else
            xticks(1:numel(synergyGroup.muscleNames))
            xticklabels([])
        end
        
        title(strrep(synergyLabels(synergyNumber), "_", " "))
        if i == 1
            legend(legendString, fontsize = params.legendFontSize, ...
                Interpreter="none")
        end
        maxWeights = max(tracked.data, [], "all");
        for k = 1 : numel(results.data)
            maxWeights(k) = max(results.data{k}, [], "all");
        end
        ylim([0 max(maxWeights)])
        synergyNumber = synergyNumber + 1;
    end
end
end

function tileFigure = makeSynergyActivationsFigure(params, options, tracked)
if isfield(options, "figureGridSize")
    figureWidth = options.figureGridSize(1);
    figureHeight = options.figureGridSize(2);
else
    figureWidth = ceil(sqrt(numel(tracked.labels)));
    figureHeight = ceil(numel(tracked.labels)/figureWidth);
end
figure(Name = "Synergy Controls", ...
    Units=params.units, ...
    Position=params.figureSize)
tileFigure = tiledlayout(figureHeight, figureWidth, ...
    TileSpacing='compact', Padding='compact');
xlabel(tileFigure, "Percent Movement [0-100%]", ...
    fontsize=params.axisLabelFontSize)
ylabel(tileFigure, "Synergy Control", ...
    fontsize=params.axisLabelFontSize)
set(gcf, color=params.plotBackgroundColor)
end

function tileFigure = makeSynergyVectorsFigure(params, synergyGroup)
figureHeight = synergyGroup.numSynergies;
    figureWidth=1;
    figure(Name = "Synergy Weights", ...
        Units=params.units, ...
        Position=params.figureSize)
    tileFigure = tiledlayout(figureHeight, figureWidth, ...
        TileSpacing='compact', Padding='compact');
    xlabel(tileFigure, "Muscle Name", ...
        fontsize=params.axisLabelFontSize)
    ylabel(tileFigure, "Synergy Weight", ...
        fontsize=params.axisLabelFontSize)
    set(gcf, color=params.plotBackgroundColor)
end

function options = parseVarargin(varargin)
    options = struct();
    varargin = varargin{1};
    for k = 1 : 2 : numel(varargin)
        options.(varargin{k}) = varargin{k+1};
    end
end

function [synergyActivations, synergyWeights] = normalizeSynergyData(synergyActivations, ...
    synergyWeights, synergyNormalizationMethod, synergyNormalizationValue)
switch synergyNormalizationMethod
    case "sum"
        for i = 1:size(synergyWeights, 1)
            total = sum(synergyWeights(i, :)) / ...
                synergyNormalizationValue;
            synergyWeights(i, :) = ...
                synergyWeights(i, :) / total;
            synergyActivations(:, i) = ...
                synergyActivations(:, i) * total;
        end
    case "magnitude"
        for i = 1:size(synergyWeights, 1)
            total = norm(synergyWeights(i, :)) / ...
                synergyNormalizationValue;
            synergyWeights(i, :) = ...
                synergyWeights(i, :) / total;
            synergyActivations(:, i) = ...
                synergyActivations(:, i) * total;
        end
    otherwise
        throw(MException('', "Only 'sum' and 'magnitude' are " + ...
            "supported synergy normalization methods."))
end
end