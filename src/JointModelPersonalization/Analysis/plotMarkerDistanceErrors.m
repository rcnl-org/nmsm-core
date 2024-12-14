% Plots the .sto file(s) made by reportDistanceErrorByMarker
% Each .sto is expected to have the same markers in the same order and the
% same time column values
% (Array of string, boolean) -> (None)
function plotMarkerDistanceErrors(files,onePlot,figureWidth,figureHeight)
import org.opensim.modeling.Storage
import org.opensim.modeling.ArrayDouble
params = getPlottingParams();
storages = {};
fileNames = {};
for i=1:length(files)
    storages{end+1} = Storage(files(i));
    [~, fileNames{i}, ~] = fileparts(files(i));
    tempTime = ArrayDouble();
    storages{i}.getTimeColumn(tempTime);
    time{i} = columnToArray(tempTime);
end

legendList = [];
axes = [];

for i = 1:length(storages)
    data = storageToDoubleMatrix(storages{i});
    display(convertStringsToChars(strcat("File: ", fileNames{i}, " Avg: ", ...
        num2str(mean(data, 'all')), " Max: ", ...
        num2str(max(data, [], 'all')))));
end
figure(Name = "Joint Model Personalization Marker Errors", ...
    Units=params.units, ...
    Position=params.figureSize)

set(gcf, color=params.plotBackgroundColor)
if(onePlot)
    for i=1:storages{1}.getColumnLabels.getSize()-1
        for j=1:length(storages)
            yArray = ArrayDouble();
            storages{j}.getDataColumn(i-1,yArray);
            y = columnToArray(yArray);
            xlabel('time')
            ylabel('error')
            plot(time{1}, y, 'LineWidth',3)
            xlim("tight")
            legendList{end+1} = strcat(storages{j}. ...
                getColumnLabels.get(i).toCharArray', num2str(j));
            hold on
        end
    end
    legend(legendList)
else
    if nargin < 3
        figureWidth = ceil(sqrt(storages{1}.getColumnLabels().getSize()));
        figureHeight = ceil(storages{1}.getColumnLabels().getSize()/figureWidth);
    elseif nargin < 4
        figureHeight = ceil(sqrt(storages{1}.getColumnLabels().getSize()));
    end
    figureSize = figureWidth * figureHeight;
    subplotNumber = 1;
    figureNumber = 1;
    t = tiledlayout(figureHeight, figureWidth, ...
        TileSpacing='compact', Padding='compact');
    xlabel(t, "Time [s]", ...
        fontsize=params.axisLabelFontSize)
    ylabel(t, "Marker Error [m]", ...
    fontsize=params.axisLabelFontSize)
    for i=1:storages{1}.getColumnLabels().getSize()-1
        if i > figureSize * figureNumber
            linkaxes(axes, 'xy')
            figureNumber = figureNumber + 1;
            figure(Name="Joint Model Personalization Marker Errors", ...
                Units=params.units, ...
                Position=params.figureSize)
            t = tiledlayout(figureHeight, figureWidth, ...
                TileSpacing='Compact', Padding='Compact');
            xlabel(t, "Percent Movement [0-100%]", ...
                fontsize=params.axisLabelFontSize)
            ylabel(t, "Marker Error [m]", ...
                fontsize=params.axisLabelFontSize)
            set(gcf, color=params.plotBackgroundColor)
            subplotNumber = 1;
            axes = [];
            legendList = {};
        end
        axes(end+1) = nexttile(subplotNumber);
        set(gca, ...
            fontsize = params.tickLabelFontSize, ...
            color=params.subplotBackgroundColor)
        for j=1:length(storages)
            yArray = ArrayDouble();
            storages{j}.getDataColumn(i-1,yArray);
            y = columnToArray(yArray);
            hold on
            plot(time{j}, y, ...
                LineWidth=params.linewidth, ...
                Color = params.lineColors(j));
            xlim("tight")
        end
        if subplotNumber == 1
            for j = 1 : length(storages)
                legendList{end+1} = strrep(fileNames{j}, "_", " ");
            end
            legend(legendList, fontsize = params.legendFontSize)
        end
        title(strrep(storages{1}.getColumnLabels.get(i).toCharArray', "_", " "), ...
            fontsize = params.subplotTitleFontSize)
        subplotNumber = subplotNumber + 1;
    end
    linkaxes(axes, 'xy')
end
end

function out = columnToArray(column)
out = zeros(1,column.getSize());
for i=1:column.getSize()
    out(i) = column.get(i-1);
end
end