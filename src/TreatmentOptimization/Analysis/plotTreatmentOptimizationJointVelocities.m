function plotTreatmentOptimizationJointVelocities(modelFileName, ...
    trackedDataFile, modelDataFiles, figureWidth, figureHeight)
import org.opensim.modeling.Storage
model = Model(modelFileName);
trackedDataStorage = Storage(trackedDataFile);
coordinateLabels = getStorageColumnNames(trackedDataStorage);
trackedData = storageToDoubleMatrix(trackedDataStorage)';
trackedDataTime = findTimeColumn(trackedDataStorage);
if trackedDataTime(1) ~= 0
    trackedDataTime = trackedDataTime - trackedDataTime(1);
end
trackedDataTime = trackedDataTime / trackedDataTime(end);
for i = 1 : size(trackedData, 2)
    if model.getCoordinateSet().get(coordinateLabels(i)).getMotionType() ...
        .toString().toCharArray()' == "Rotational"
        trackedData(:, i) = trackedData(:, i) * 1;
    end
end
for j=1:numel(modelDataFiles)
    modeledStatesStorage = Storage(modelDataFiles(j));
    modeledStates = storageToDoubleMatrix(modeledStatesStorage)';
    modeledStatesTime = findTimeColumn(modeledStatesStorage);
    modeledStatesLabels = getStorageColumnNames(modeledStatesStorage);
    if modeledStatesTime ~= 0
        modeledStatesTime = modeledStatesTime - modeledStatesTime(1);
    end
    modeledStatesTime = modeledStatesTime / modeledStatesTime(end);
    
    modeledVelocities{j} = modeledStates(:, size(modeledStates, 2)/2+1:end);
    modeledVelocitiesLabels = modeledStatesLabels(size(modeledStates, 2)/2+1:end);
    modeledVelocitiesTime{j} = modeledStatesTime;

    for i = 1 : size(modeledStates(:, 1:size(modeledStates, 2)/2), 2)
        if model.getCoordinateSet().get(modeledStatesLabels(i)).getMotionType() ...
            .toString().toCharArray()' == "Rotational"
            modeledVelocities{j}(:, i) = modeledVelocities{j}(:, i) * 1;

        end
    end
end
experimentalSpline = makeGcvSplineSet(trackedDataTime, ...
    trackedData, coordinateLabels);
trackedVelocities = evaluateGcvSplines(experimentalSpline, coordinateLabels, ...
    trackedDataTime, 1);
resampledExperimentalVelocities = {};
for j = 1 : numel(modelDataFiles)
    resampledExperimentalVelocities{j}= evaluateGcvSplines(experimentalSpline, ...
        coordinateLabels, modeledVelocitiesTime{j}, 1);
end
if nargin < 4
    figureWidth = ceil(sqrt(numel(modeledVelocitiesLabels)));
    figureHeight = ceil(numel(modeledVelocitiesLabels)/figureWidth);
elseif nargin < 5
    figureHeight = ceil(sqrt(numel(modeledVelocitiesLabels)));
end
figureSize = figureWidth * figureHeight;
figure(Name = "Treatment Optimization Joint Velocities", ...
    Units='normalized', ...
    Position=[0.05 0.05 0.9 0.85])
colors = getPlottingColors();
subplotNumber = 1;
figureNumber = 1;
t = tiledlayout(figureHeight, figureWidth, ...
    TileSpacing='compact', Padding='compact');
xlabel(t, "Percent Movement [0-100%]")
ylabel(t, "Joint Velocities [deg/s]")

for i=1:numel(modeledVelocitiesLabels)
    if i > figureSize * figureNumber
        figureNumber = figureNumber + 1;
        figure(Name="Treatment Optimization Joint Angles", ...
            Units='normalized', ...
            Position=[0.05 0.05 0.9 0.85])
        t = tiledlayout(figureHeight, figureWidth, ...
            TileSpacing='Compact', Padding='Compact');
        xlabel(t, "Percent Movement [0-100%]")
        ylabel(t, "Joint Angle [deg]")
        subplotNumber = 1;
    end
    coordinateIndex = find(modeledStatesLabels(i) == coordinateLabels);
    if ~isempty(coordinateIndex)
        nexttile(subplotNumber);
        hold on
        plot(trackedDataTime*100, trackedVelocities(:, coordinateIndex), ...
            lineWidth=2, Color = colors(1))
        for j = 1 : numel(modelDataFiles)
            plot(modeledVelocitiesTime{j}*100, modeledVelocities{j}(:, i), ...
                lineWidth=2, Color = colors(j+1));
        end
        hold off
        titleString = [sprintf("%s", strrep(coordinateLabels(coordinateIndex), "_", " "))];
        for j = 1 : numel(modelDataFiles)
            rmse = rms(resampledExperimentalVelocities{j}(:, i) - ...
                modeledVelocities{j}(:, i));
            titleString(j+1) = sprintf("RMSE %d: %.4f", j, rmse);
        end
        title(titleString)
        if subplotNumber==1
            splitFileName = split(trackedDataFile, ["/", "\"]);
            for k = 1 : numel(splitFileName)
                if ~strcmp(splitFileName(k), "..")
                    legendValues = sprintf("%s (T)", ...
                        strrep(splitFileName(k), "_", " "));
                    break
                end
            end
            for j = 1 : numel(modelDataFiles)
                splitFileName = split(modelDataFiles(j), ["/", "\"]);
                legendValues(j+1) = sprintf("%s (%d)", splitFileName(1), j);
            end
            legend(legendValues)
        end
        xlim("tight")
        maxData = [];
        minData = [];
        for j = 1 : numel(modelDataFiles)
            maxData(j) = max(modeledVelocities{j}(:, i), [], "all");
            minData(j) = min(modeledVelocities{j}(:, i), [], "all");
        end
        maxData(j+1) = max(trackedVelocities(:, i), [], "all");
        minData(j+1) = min(trackedVelocities(:, i), [], "all");
        yLimitUpper = max(maxData);
        yLimitLower = min(minData);
        minimum = 3;
        if yLimitUpper - yLimitLower < minimum
            ylim([(yLimitUpper+yLimitLower)/2-minimum, (yLimitUpper+yLimitLower)/2+minimum])
        end
        subplotNumber = subplotNumber + 1;
    end
end

end
