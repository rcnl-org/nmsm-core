function params = getPlottingParams()
% Figure size params
params.units = 'normalized'; % pixels, normalized, inches, centimeters, points
params.figureSize = [0.05 0.05 0.9 0.85];
params.axisLabelFontSize = 25;
params.subplotTitleFontSize = 20;
params.legendFontSize = 25;
params.tickLabelFontSize = 25;

% Color params
params.plotBackgroundColor = "#D8D8D8";
params.subplotBackgroundColor = "#D8D8D8";

% Line params
params.lineColors = ["#4477AA", "#EE6677", "#228833", "#CCBB44", "#66CCEE", "AA3377", "BBBBBB"];
% params.lineColors = ["#4477AA", "#66CCEE", "#CCBB44", "#228833", "#EE6677", "AA3377", "BBBBBB"];
params.linewidth = 5;
end