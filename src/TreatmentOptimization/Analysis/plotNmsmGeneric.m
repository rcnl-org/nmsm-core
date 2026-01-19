function plotNmsmGeneric(dataFiles, varargin)
import org.opensim.modeling.Model
params = getPlottingParams();
if ~isempty(varargin)
    options = parseVarargin(varargin);
else
    options = struct();
end
if isfield(options, "showRmse")
    showRmse = options.showRmse;
else
    showRmse = 0;
end
model = org.opensim.modeling.Model();
[~, inputs] = parsePlottingData([], dataFiles, model);
tileFigure = makeFigure(params, options, inputs);
if isfield(options, "legend")
    legendString = options.legend;
else
    legendString = makeLegend(dataFiles);
end
figureSize = tileFigure.GridSize(1)*tileFigure.GridSize(2);
subplotNumber = 1;
for i = 1 : numel(inputs.labels{1})
    if subplotNumber > figureSize
        makeFigure(params, options, tracked);
        subplotNumber = 1;
    end
    nexttile(subplotNumber)

    set(gca, ...
        fontsize = params.tickLabelFontSize, ...
        color=params.subplotBackgroundColor)
    hold on
    for j = 1 : numel(inputs.data)
        plot(inputs.time{j}, inputs.data{j}(:, i), ...
            LineWidth=params.linewidth, ...
            Color = params.lineColors(j));
    end
    hold off
    title(inputs.labels{1}(i), fontsize = params.subplotTitleFontSize, ...
        Interpreter="none")
    if subplotNumber==figureSize || i == numel(inputs.labels{1})
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

function tileFigure = makeFigure(params, options, inputs)
if isfield(options, "figureGridSize")
    figureWidth = options.figureGridSize(1);
    figureHeight = options.figureGridSize(2);
else
    figureWidth = ceil(sqrt(numel(inputs.labels{1})));
    figureHeight = ceil(numel(inputs.labels{1})/figureWidth);
end 
figure(Units=params.units, Position=params.figureSize)
tileFigure = tiledlayout(figureHeight, figureWidth, ...
    TileSpacing='compact', Padding='compact');
xlabel(tileFigure, "Percent Movement [0-100%]", ...
    fontsize=params.axisLabelFontSize)
ylabel(tileFigure, "Quantity", ...
    fontsize=params.axisLabelFontSize)
set(gcf, color=params.plotBackgroundColor)
end

function legendString = makeLegend(dataFiles)
legendString = {};
for j = 1 : numel(dataFiles)
    [~, fileName, ~] = fileparts(dataFiles{j});
    legendString{j} = fileName;
end
end