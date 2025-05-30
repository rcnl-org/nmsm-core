% This function is part of the NMSM Pipeline, see file for full license.
%
% This function reads .sto files created by
% saveMuscleTendonPersonalizationResults.m containing passive moment data 
% and creates plots of experimental and modeled passive moment curves.
%
% (string) -> (None)
% Plot passive moment curves from file.

% ----------------------------------------------------------------------- %
% The NMSM Pipeline is a toolkit for model personalization and treatment  %
% optimization of neuromusculoskeletal models through OpenSim. See        %
% nmsm.rice.edu and the NOTICE file for more information. The             %
% NMSM Pipeline is developed at Rice University and supported by the US   %
% National Institutes of Health (R01 EB030520).                           %
%                                                                         %
% Copyright (c) 2021 Rice University and the Authors                      %
% Author(s): Di Ao, Marleny Vega, Robert Salati                           %
%                                                                         %
% Licensed under the Apache License, Version 2.0 (the "License");         %
% you may not use this file except in compliance with the License.        %
% You may obtain a copy of the License at                                 %
% http://www.apache.org/licenses/LICENSE-2.0.                             %
%                                                                         %
% Unless required by applicable law or agreed to in writing, software     %
% distributed under the License is distributed on an "AS IS" BASIS,       %
% WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or         %
% implied. See the License for the specific language governing            %
% permissions and limitations under the License.                          %
% ----------------------------------------------------------------------- %

function plotMtpPassiveMomentCurves(resultsDirectory, figureWidth, ...
    figureHeight)
params = getPlottingParams();
analysisDirectory = fullfile(resultsDirectory, "Analysis");
[momentNames, passiveMomentsExperimental] = extractMtpDataFromSto( ...
    fullfile(analysisDirectory, "passiveJointMomentsExperimental"));
[~, passiveMomentsModel] = extractMtpDataFromSto( ...
    fullfile(analysisDirectory, "passiveJointMomentsModeled"));
columnsWithAllZeros = all(passiveMomentsExperimental == 0, 1);
experimentalMomentFilesDirectory = dir(fullfile(analysisDirectory, ...
    "passiveJointMomentsExperimental"));
experimentalMomentFilesDirectory = experimentalMomentFilesDirectory(3:end);
plotLabels = [];
for i = 1 : size(passiveMomentsExperimental, 3)
    trialPrefix = strrep(experimentalMomentFilesDirectory(i).name, ...
        "passiveJointMomentsExperimental.sto", "");
    plotLabels = [plotLabels, ...
        strcat(trialPrefix, momentNames(~columnsWithAllZeros(:, :, i)))];
end
plotLabels = strrep(plotLabels, "_", " ");
passiveMomentsModel = passiveMomentsModel(:, ~columnsWithAllZeros(1,:,:));
passiveMomentsExperimental = ...
    passiveMomentsExperimental(:, ~columnsWithAllZeros(1,:,:));

if nargin < 2
    figureWidth = ceil(sqrt(numel(plotLabels)));
    figureHeight = ceil(numel(plotLabels)/figureWidth);
elseif nargin < 3
    figureHeight = ceil(sqrt(numel(plotLabels)));
end
figureSize = figureWidth * figureHeight;
subplotNumber = 1;
figureNumber = 1;
figure(Name = strcat(resultsDirectory, ...
        " Passive Moment Matching"), ...
    Units=params.units, ...
    Position=params.figureSize)
colors = getPlottingParams();
t = tiledlayout(figureHeight, figureWidth, ...
    TileSpacing='Compact', Padding='Compact');
minMoment = min([ ...
    min(passiveMomentsExperimental, [], "all"), ...
    min(passiveMomentsModel, [], "all")]);
maxMoment = max([ ...
    max(passiveMomentsExperimental, [], "all"), ...
    max(passiveMomentsModel, [], "all")]);
xlabel(t, "Joint Position [deg]", ...
    fontsize=params.axisLabelFontSize)
ylabel(t, "Joint Passive Moment [Nm]", ...
    fontsize=params.axisLabelFontSize)
set(gcf, color=params.plotBackgroundColor)
for i = 1 : numel(plotLabels)
    if i > figureSize * figureNumber
        figureNumber = figureNumber + 1;
        figure(Name = strcat(resultsDirectory, ...
                " Passive Moment Matching"), ...
            Units=params.units, ...
    Position=params.figureSize)
        t = tiledlayout(figureHeight, figureWidth, ...
            TileSpacing='Compact', Padding='Compact');
        xlabel(t, "Joint Position [deg]", ...
    fontsize=params.axisLabelFontSize)
        ylabel(t, "Joint Passive Moment [Nm]", ...
    fontsize=params.axisLabelFontSize)
        set(gcf, color=params.plotBackgroundColor)
        subplotNumber = 1;
    end
    nexttile(subplotNumber)
    set(gca, ...
        fontsize = params.tickLabelFontSize, ...
        color=params.subplotBackgroundColor)
    hold on
    plot(passiveMomentsExperimental(:, i), ...
        LineWidth=2, Color=params.lineColors(1))
    plot(passiveMomentsModel(:, i), ...
        LineWidth=2, Color=params.lineColors(2))
    hold off
    title(plotLabels(i), fontsize = params.subplotTitleFontSize)
    if subplotNumber == 1
        legend("Experimental Moments", "Model Moments", ...
            fontsize = params.legendFontSize)
    end
    xlim("tight")
    ylim([minMoment, maxMoment])
    subplotNumber = subplotNumber + 1;
end
end

