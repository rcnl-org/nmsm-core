function plotTreatmentOptimizationBounds(settingsFileName, ...
    overrideResultsDirectory)
settingsTree = xml2struct(settingsFileName);
toolName = findToolName(settingsTree);
modelFileName = parseElementTextByName(settingsTree, 'input_model_file');
resultsDirectory = getTextFromField(getFieldByName(settingsTree, ...
    'results_directory'));
if nargin > 1
    resultsDirectory = overrideResultsDirectory;
end
trackedQuantitiesDirectory = getTextFromField(getFieldByName(settingsTree, ...
    'tracked_quantities_directory'));
initialGuessDirectory = getTextFromField(getFieldByName(settingsTree, ...
    'initial_guess_directory'));
[isTorque, isSynergy] = parseControllers(settingsTree);
trialPrefix = getTextFromField(getFieldByName(settingsTree, ...
    'trial_name'));

designVariableBounds = parseTreatmentOptimizationDesignVariableBounds(...
    settingsTree);

plotJointPositionBounds(modelFileName, ...
    fullfile(trackedQuantitiesDirectory, "IKData", strcat(trialPrefix, ".sto")), ...
    fullfile(resultsDirectory, "IKData", strcat(trialPrefix, ".sto")), ...
    designVariableBounds);

end

function plotJointPositionBounds(modelFileName, trackedDataFile, ...
    modelDataFile, designVariableBounds)
params = getPlottingParams();
model = Model(modelFileName);

[coordinateLabels, trackedDataTime, trackedData, ...
    modelDataTime, modelData] = readTrackedAndModeledData(model, ...
    trackedDataFile, modelDataFile);
for i = 1 : size(trackedData, 2)
    if model.getCoordinateSet().get(coordinateLabels(i)).getMotionType() ...
            .toString().toCharArray()' == "Rotational"
        trackedData(:, i) = trackedData(:, i) * 180/pi;
    end
end
for i = 1 : size(modelData, 2)
    if model.getCoordinateSet().get(coordinateLabels(i)).getMotionType() ...
            .toString().toCharArray()' == "Rotational"
        modelData(:, i) = modelData(:, i) * 180/pi;
    end
end
maxTrackedData = max(trackedData, [], 1);
minTrackedData = min(trackedData, [], 1);
trackedDataRange = maxTrackedData-minTrackedData;

figureWidth = ceil(sqrt(numel(coordinateLabels)));
figureHeight = ceil(numel(coordinateLabels)/figureWidth);
figure(Name = "Treatment Optimization Coordinate Deviations", ...
    Units=params.units, ...
    Position=params.figureSize)
t = tiledlayout(figureHeight, figureWidth, ...
    TileSpacing='compact', Padding='compact');
xlabel(t, "Percent Movement [0-100%]", ...
    fontsize=params.axisLabelFontSize)
ylabel(t, "Joint Angle [deg]", ...
    fontsize=params.axisLabelFontSize)
set(gcf, color=params.plotBackgroundColor)
for i=1:numel(coordinateLabels)
    nexttile(i);
    set(gca, ...
        fontsize = params.tickLabelFontSize, ...
        color=params.subplotBackgroundColor)
    hold on
    plot(trackedDataTime*100, trackedData(:, i), ...
        LineWidth=params.linewidth, ...
        Color = params.lineColors(1))
    plot(modelDataTime*100, modelData(:, i), ...
        LineWidth=params.linewidth, ...
        Color = params.lineColors(2))
    plot(trackedDataTime*100, ones(size(trackedDataTime))* ...
        (maxTrackedData(i)+trackedDataRange(i)*designVariableBounds.jointPositionsMultiple), ...
        LineWidth=params.linewidth, ...
        Color = params.lineColors(1), ...
        linestyle = '--')
    plot(trackedDataTime*100, ones(size(trackedDataTime))* ...
        (minTrackedData(i)-trackedDataRange(i)*designVariableBounds.jointPositionsMultiple), ...
        LineWidth=params.linewidth, ...
        Color = params.lineColors(1), ...
        linestyle = '--')
    hold off
    titleString = [sprintf("%s", strrep(coordinateLabels(i), "_", " "))];
    title(titleString, fontsize = params.subplotTitleFontSize)
    xlim("tight")
    ylim("tight")
    if model.getCoordinateSet().get(coordinateLabels(i)).getMotionType() ...
            .toString().toCharArray()' == "Rotational"
        minimumRange = 5;
    else
        minimumRange = 0.1;
    end
    if trackedDataRange(i) < 0.1
        ylim([minTrackedData(i)-minimumRange maxTrackedData(i)+minimumRange])
    end
end
end

function [coordinateLabels, trackedDataTime, trackedData, ...
    modelDataTime, modelData] = readTrackedAndModeledData(model, ...
    trackedDataFile, modelDataFile)
import org.opensim.modeling.Storage
trackedDataStorage = Storage(trackedDataFile);
[~, trackedDataTime, trackedData] = parseMotToComponents(...
    model, trackedDataStorage);
trackedData = trackedData';
if trackedDataTime(1) ~= 0
    trackedDataTime = trackedDataTime - trackedDataTime(1);
end
trackedDataTime = trackedDataTime / trackedDataTime(end);
modelDataStorage = Storage(modelDataFile);
[coordinateLabels, modelDataTime, modelData] = parseMotToComponents(...
    model, modelDataStorage);
modelData = modelData';
if modelDataTime(1) ~= 0
    modelDataTime = modelDataTime - modelDataTime(1);
end
modelDataTime = modelDataTime / modelDataTime(end);
end

function [isTorque, isSynergy] = parseControllers(settingsTree)
synergy = getFieldByName(settingsTree, 'RCNLSynergyController');
if isstruct(synergy)
    isSynergy = true;
else
    isSynergy = false;
end
torque = getFieldByName(settingsTree, 'RCNLTorqueController');
if isstruct(torque)
    isTorque = true;
else
    isTorque = false;
end
end