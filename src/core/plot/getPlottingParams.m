function params = getPlottingParams()
% Figure size params
params.units = 'normalized'; % pixels, normalized, inches, centimeters, points
params.figureSize = [0.05 0.05 0.9 0.85];
params.axisLabelFontSize = 15;
params.subplotTitleFontSize = 12;
params.legendFontSize = 8;
params.tickLabelFontSize = 10;

% Color params
params.plotBackgroundColor = "default";
params.subplotBackgroundColor = "default";

% Line params
params.lineColors = ["#4477AA", "#EE6677", "#228833", "#CCBB44", "#66CCEE", "#AA3377", "#BBBBBB"];
params.linewidth = 2;
end