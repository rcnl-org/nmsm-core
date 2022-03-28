% Plots the .sto file(s) made by reportDistanceErrorByMarker
% Each .sto is expected to have the same markers in the same order and the
% same time column values
% (Array of string, boolean) -> (None)
function plotMarkerDistanceErrors(files,onePlot)
import org.opensim.modeling.Storage
import org.opensim.modeling.ArrayDouble
storages = {};
for i=1:length(files)
    storages{end+1} = Storage(files(i));
end
time = ArrayDouble();
storages{1}.getTimeColumn(time);
time = columnToArray(time);
legendList = {};

plots = [];

if(onePlot)
    for i=1:storages{1}.getColumnLabels.getSize()-1
        for j=1:length(storages)
            yArray = ArrayDouble();
            storages{j}.getDataColumn(i-1,yArray);
            y = columnToArray(yArray);
            xlabel('time')
            ylabel('error')
            plot(time, y)
            legendList{end+1} = strcat(storages{j}. ...
                getColumnLabels.get(i).toCharArray', num2str(j));
            hold on
        end
    end
    legend(legendList)
else
    plotSize = ceil(sqrt(storages{1}.getColumnLabels.getSize()-1));
    tiledlayout(plotSize, plotSize);
    for i=1:storages{1}.getColumnLabels().getSize()-1
        plots(end+1) = nexttile;
        for j=1:length(storages)
            yArray = ArrayDouble();
            storages{j}.getDataColumn(i-1,yArray);
            y = columnToArray(yArray);
            hold on
            xlabel('time (s)')
            ylabel('error (units of marker file)')
            plot(time, y);
            legendList{end+1} = strcat(storages{j}. ...
                getColumnLabels.get(i).toCharArray', num2str(j));
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