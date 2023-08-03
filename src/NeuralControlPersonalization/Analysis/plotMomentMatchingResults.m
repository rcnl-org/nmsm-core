function plotMomentMatchingResults(experimentalMomentsFile, ...
    modeledMomentsFile, figureWidth, figureHeight)
import org.opensim.modeling.Storage
if nargin < 3
    figureWidth = 4;
end
if nargin < 4
    figureHeight = 2;
end
figureSize = figureWidth * figureHeight;

[experimentalColumns, experimentalTime, experimentalMoments] = ...
    parseMotToComponents(org.opensim.modeling.Model(), ...
    Storage(experimentalMomentsFile));
[modeledColumns, modeledTime, modeledMoments] = parseMotToComponents( ...
    org.opensim.modeling.Model(), Storage(modeledMomentsFile));

includedColumns = ismember(experimentalColumns, modeledColumns);
experimentalMoments = experimentalMoments(includedColumns, :);
experimentalColumns = experimentalColumns(includedColumns);

figureNumber = 1;
subplotNumber = 1;
hasLegend = false;
figure(figureNumber)
for i = 1:length(experimentalColumns)
    if i > figureSize * figureNumber
        figureNumber = figureNumber + 1;
        figure(figureNumber)
        subplotNumber = 1;
        hasLegend = false;
    end
    subplot(figureHeight, figureWidth, subplotNumber)
    plot(experimentalTime, experimentalMoments(i, :), 'LineWidth', 2)
    modeledIndex = find(experimentalColumns(i) == modeledColumns);
    if ~isempty(modeledIndex)
        hold on
        plot(modeledTime, modeledMoments(modeledIndex, :), 'LineWidth', 2);
        if ~hasLegend
            legend("Experimental Moments", "Modeled Moments")
            hasLegend = true;
        end
        hold off
        error = rms(experimentalMoments(i, :) - ...
            modeledMoments(modeledIndex, :));
    else
        error = "N/A";
    end
    title(strrep(experimentalColumns(i), "_", " ") + newline + ...
        " RMSE: " + error)
    xlim([modeledTime(1) modeledTime(end)])
    subplotNumber = subplotNumber + 1;
end
end
