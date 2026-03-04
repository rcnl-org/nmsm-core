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
end

function [data1, data2] = reorderUsingSimilarity(data1, data2)
% Reorder data2 to match data1 using GLOBAL optimal assignment on weights

weights1 = data1.trackedWeights.data;   % (numSyn x numMus)
weights2 = data2.trackedWeights.data;   % (numSyn x numMus)

numSyn1 = size(weights1,1);
numSyn2 = size(weights2,1);
if numSyn1 ~= numSyn2
    error('Number of synergies mismatch: data1=%d, data2=%d', numSyn1, numSyn2);
end
numSyn = numSyn1;

similarity = pairwiseCosineRows(weights1, weights2);
cost = -similarity;
pairs = matchpairs(cost, 1e9);   % [rowIdx, colIdx]

% Build perm so that data2(perm(i),:) aligns with data1(i,:)
perm = zeros(1, numSyn);
for p = 1:size(pairs,1)
    i = pairs(p,1);
    j = pairs(p,2);
    perm(i) = j;
end

% Apply permutation to data2
data2.trackedWeights.data = data2.trackedWeights.data(perm,:);
data2.trackedActivations.data = data2.trackedActivations.data(:,perm);

for k = 1:numel(data2.resultsWeights.data)
    data2.resultsWeights.data{k} = data2.resultsWeights.data{k}(perm,:);
end
for k = 1:numel(data2.resultsActivations.data)
    data2.resultsActivations.data{k} = data2.resultsActivations.data{k}(:,perm);
end

% Keep labels consistent if present
if isfield(data2.trackedActivations,'labels') && numel(data2.trackedActivations.labels)==numSyn
    data2.trackedActivations.labels = data2.trackedActivations.labels(perm);
end
if isfield(data2.resultsActivations,'labels')
    for k = 1:numel(data2.resultsActivations.labels)
        if numel(data2.resultsActivations.labels{k})==numSyn
            data2.resultsActivations.labels{k} = data2.resultsActivations.labels{k}(perm);
        end
    end
end


fprintf('[reorderUsingSimilarity] perm (data2 -> data1 order): ');
fprintf('%d ', perm);
fprintf('\n');

similarity_after_weight = pairwiseCosineRows(data1.trackedWeights.data, data2.trackedWeights.data);
fprintf("Similarity score of weights after reordering {sum(diag) percent score, min(diag)}: {%.4f %.4f}\n", ...
    sum(diag(similarity_after_weight))/numSyn*100, min(diag(similarity_after_weight)));

similarity_after_command = pairwiseCosineRows(data1.trackedActivations.data', data2.trackedActivations.data');
fprintf("Similarity score of commands after reordering {sum(diag) percent score, min(diag)}: {%.4f %.4f}\n", ...
    sum(diag(similarity_after_command))/numSyn*100, min(diag(similarity_after_command)));
fprintf('\n');
% matrix print
for i = 1:size(similarity_after_weight,1)
    fprintf('%.6g', similarity_after_weight(i,1));
    fprintf('\t%.6g', similarity_after_weight(i,2:end));
    fprintf('\n');
end
fprintf('\n');
for i = 1:size(similarity_after_command,1)
    fprintf('%.6g', similarity_after_command(i,1));
    fprintf('\t%.6g', similarity_after_command(i,2:end));
    fprintf('\n');
end

end


function S = pairwiseCosineRows(A, B)
% A: n x d, B: n x d
% S(i,j) = cosineSim(A(i,:), B(j,:))
nA = size(A,1);
nB = size(B,1);
S = zeros(nA, nB);
for i = 1:nA
    for j = 1:nB
        S(i,j) = cosineSim(A(i,:), B(j,:));
    end
end
end


function s = cosineSim(a,b)
a = a(:); b = b(:);
na = norm(a); nb = norm(b);
if na < eps || nb < eps
    s = 0;
else
    s = (a' * b) / (na * nb);
end
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

        if allow_negative_synergy_vector_weights
            minWeights = min(tracked.data, [], "all");
            for k = 1 : numel(results.data)
                minWeights(k) = min(results.data{k}, [], "all");
            end
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