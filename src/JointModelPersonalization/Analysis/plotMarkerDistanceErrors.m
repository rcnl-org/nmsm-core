% Plots the .sto file(s) made by reportDistanceErrorByMarker
% Each .sto is expected to have the same markers in the same order and the
% same time column values
% (Array of string, boolean) -> (None)
function plotMarkerDistanceErrors(files,onePlot)
import org.opensim.modeling.Storage
import org.opensim.modeling.ArrayDouble
colors = getPlottingColors();
storages = {};
fileNames = {};
for i=1:length(files)
    storages{end+1} = Storage(files(i));
    [~, fileNames{i}, ~] = fileparts(files(i));
    tempTime = ArrayDouble();
    storages{i}.getTimeColumn(tempTime);
    time{i} = columnToArray(tempTime);
end

legendList = {};
plots = [];

for i = 1:length(storages)
    data = storageToDoubleMatrix(storages{i});
    display(convertStringsToChars(strcat("File: ", fileNames{i}, " Avg: ", ...
        num2str(mean(data, 'all')), " Max: ", ...
        num2str(max(data, [], 'all')))));
end


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
    numberOfPlots = storages{1}.getColumnLabels.getSize()-1;
    plotSize = ceil(sqrt(numberOfPlots));
    tiledlayout(ceil(numberOfPlots/plotSize), plotSize);
    for i=1:storages{1}.getColumnLabels().getSize()-1
        plots(end+1) = nexttile;
        for j=1:length(storages)
            yArray = ArrayDouble();
            storages{j}.getDataColumn(i-1,yArray);
            y = columnToArray(yArray);
            hold on
            xlabel('time (s)')
            ylabel('error (m)')
            plot(time{j}, y, 'LineWidth',3, color=colors(j));
            xlim("tight")
            legendList{end+1} = strrep(strcat(storages{j}. ...
                getColumnLabels.get(i).toCharArray', " - ", fileNames{j}), ...
                '_', '\_');
        end
        legend(legendList)
        legendList = {};
    end
    linkaxes(plots, 'xy')
end
end

function out = columnToArray(column)
out = zeros(1,column.getSize());
for i=1:column.getSize()
    out(i) = column.get(i-1);
end
end