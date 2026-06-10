function reorderAndPlotSynergyControls(...
    trackedActivationsFile1, trackedWeightsFile1, ...
    resultsActivationsFiles1, resultsWeightsFiles1, ...
    osimxFileName1, modelFileName1, ...
    synergyNormalizationMethod1, synergyNormalizationValue1, ...
    allow_negative_synergy_vector_weights1, ...
    trackedActivationsFile2, trackedWeightsFile2, ...
    resultsActivationsFiles2, resultsWeightsFiles2, ...
    osimxFileName2, modelFileName2, ...
    synergyNormalizationMethod2, synergyNormalizationValue2, ...
    allow_negative_synergy_vector_weights2, ...
    varargin)

params = getPlottingParams();
if ~isempty(varargin)
    options = parseVarargin(varargin);
else
    options = struct();
end
osimx1 = parseOsimxFile(osimxFileName1, Model(modelFileName1));
osimx2 = parseOsimxFile(osimxFileName2, Model(modelFileName2));

data1 = prepareData(modelFileName1, trackedActivationsFile1, ...
    resultsActivationsFiles1, trackedWeightsFile1,resultsWeightsFiles1, ...
    synergyNormalizationMethod1, synergyNormalizationValue1);
data2 = prepareData(modelFileName2, trackedActivationsFile2, ...
    resultsActivationsFiles2, trackedWeightsFile2,resultsWeightsFiles2, ...
    synergyNormalizationMethod2, synergyNormalizationValue2);

[data1, data2] = reorderUsingSimilarity(data1, data2);

plotSynergyActivations(data1.trackedActivations, data1.resultsActivations, ...
    params, options, allow_negative_synergy_vector_weights1);
plotSynergyActivations(data2.trackedActivations, data2.resultsActivations, ...
    params, options, allow_negative_synergy_vector_weights2);

plotSynergyVectors(data1.trackedWeights, data1.trackedActivations.labels, ...
    data1.resultsWeights, params, osimx1, options, allow_negative_synergy_vector_weights1);
plotSynergyVectors(data2.trackedWeights, data2.trackedActivations.labels, ...
    data2.resultsWeights, params, osimx2, options, allow_negative_synergy_vector_weights2);
end


function data = prepareData(modelFileName, trackedActivationsFile, ...
    resultsActivationsFiles, trackedWeightsFile,resultsWeightsFiles, ...
    synergyNormalizationMethod, synergyNormalizationValue)
model = Model(modelFileName);
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
data.trackedActivations = trackedActivations;
data.resultsActivations = resultsActivations;
data.trackedWeights = trackedWeights;
data.resultsWeights = resultsWeights;
data.weights = trackedWeights.data;
data.activations = reshape(trackedActivations.data, [1, size(trackedActivations.data)]);
end

function plotSynergyActivations(tracked, results, params, options, ...
    allow_negative_synergy_vector_weights)
if isfield(options, "showRmse")
    showRmse = options.showRmse;
else
    showRmse = 1;
end
if isfield(options, "columnsToUse")
    [~, ~, trackedIndices] = intersect(options.columnsToUse, tracked.labels, "stable");
    tracked.data = tracked.data(:, trackedIndices); 
    tracked.labels = tracked.labels(trackedIndices);
    for j = 1 : numel(results.dataFiles)
        [~, ~, resultsIndices] = intersect(options.columnsToUse, results.labels{j}, "stable");
        results.data{j} = results.data{j}(:, resultsIndices); 
        results.labels{j} = results.labels{j}(resultsIndices);
    end
end
% Allow renaming columns in the subplot titles
if isfield(options, "columnNames")
    tracked.labels = options.columnNames;
    for j = 1 : numel(results.dataFiles)
        results.labels{j} = options.columnNames;
    end
end
tileFigure = makeSynergyActivationsFigure(params, options, tracked);
figureSize = tileFigure.GridSize(1)*tileFigure.GridSize(2);
subplotNumber = 1;
titleStrings = makeSubplotTitles(tracked, results, showRmse);
if isfield(options, "legend")
    legendString = options.legend;
else
    legendString = makeLegendFromFileNames(tracked.dataFile, ...
            results.dataFiles);
end
% Max tracked synergy activation. Used to set the plot y axis.
maxActivations = [max(tracked.data, [], "all")];
minActivations = [min(tracked.data, [], "all")];
for i = 1 : numel(results.data)
    maxActivations(i+1) = max(results.data{i}, [], "all");
    minActivations(i+1) = min(results.data{i}, [], "all");
end
upperYLimit = max(maxActivations);
lowerYLimit = 0;
if allow_negative_synergy_vector_weights
    lowerYLimit = min(minActivations);
end
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
    ylim([lowerYLimit upperYLimit])
    subplotNumber = subplotNumber + 1;
end
end

function plotSynergyVectors(tracked, synergyLabels, results, params, osimx, ...
    options, allow_negative_synergy_vector_weights)
% Outer level: iterate through synergy sets. We get 1 plot for each synergy
% set for readability.
synergyNumber = 1;
if isfield(options, "legend")
    legendString = options.legend;
else
    legendString = makeLegendFromFileNames(tracked.dataFile, ...
            results.dataFiles);
end
for synergyGroup = 1 : numel(osimx.synergyGroups)
    synergyGroupData = osimx.synergyGroups{synergyGroup};
    muscleIndices = contains(tracked.labels, synergyGroupData.muscleNames);
    tileFigure = makeSynergyVectorsFigure(params, synergyGroupData);
    figureHeight = tileFigure.GridSize(1);
    for i = 1 : synergyGroupData.numSynergies
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
        b = bar(1:numel(synergyGroupData.muscleNames), ...
            weightsPlottingArray);
        b(1).FaceColor = params.lineColors(1);
        for k = 1 : numel(results.data)
            b(k+1).FaceColor = params.lineColors(k+1);
        end
        if i == figureHeight
            xticks(1:numel(synergyGroupData.muscleNames))
            xticklabels(synergyGroupData.muscleNames)
        else
            xticks(1:numel(synergyGroupData.muscleNames))
            xticklabels([])
        end
        
        title(strrep(synergyLabels(synergyNumber), "_", " "))
        if i == 1
            legend(legendString, fontsize = params.legendFontSize, ...
                Interpreter="none")
        end
        maxWeights = max(tracked.data, [], "all");
        for k = 1 : numel(results.data)
            maxWeights(end+1) = max(results.data{k}, [], "all");
        end
        ylim([0 max(maxWeights)])

        if allow_negative_synergy_vector_weights
            ylim([-1 1])
        end
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
    case "none"
        return
end
end