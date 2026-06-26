function params = getPlottingParams()
% Figure size params
params.units = 'normalized'; % pixels, normalized, inches, centimeters, points
params.figureSize = [0.05 0.05 0.9 0.85];
params.axisLabelFontSize = 11;
params.subplotTitleFontSize = "default";  % Can be either default or a number (units points)
params.legendFontSize = "default";  % Can be either default or a number (units points)
params.tickLabelFontSize = "default";  % Can be either default or a number (units points)

% Color params
params.plotBackgroundColor = "default";  % Can be either default or a hexidecimal color code
params.subplotBackgroundColor = "default";  % Can be either default or a hexidecimal color code

% Line params
params.lineColors = ["#4477AA", "#EE6677", "#228833", "#CCBB44", "#66CCEE", "#AA3377", "#BBBBBB"];
params.linewidth = 2;
end