% This function is part of the NMSM Pipeline, see file for full license.
%
% This function reads .sto files created by
% saveMuscleTendonPersonalizationResults.m containing inverse dynamics
% joint moments and model joint moments and creates plots of them.
%
% (string) -> (None)
% Plot joint moment curves from file.

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
function plotMtpJointMoments(resultsDirectory, figureWidth, figureHeight)
analysisDirectory = fullfile(resultsDirectory, "Analysis");
params = getPlottingParams();
[jointLabels, idMoments] = extractMtpDataFromSto( ...
    fullfile(analysisDirectory, "inverseDynamicsJointMoments"));

[~, modelMoments] = extractMtpDataFromSto( ...
    fullfile(analysisDirectory, "modelJointMoments"));

if exist(fullfile(analysisDirectory, "modelJointMomentsSynx"), "dir")
    [~, modelMomentsSynx] = extractMtpDataFromSto( ...
        fullfile(analysisDirectory, "modelJointMomentsSynx"));
else
    modelMomentsSynx = [];
end

jointLabels = strrep(jointLabels, '_', ' ');
meanIdMoments = mean(idMoments, 3);
stdIdMoments = std(idMoments, [], 3);
meanMoments = mean(modelMoments, 3);
stdMoments = std(modelMoments, [], 3);
meanMomentsSynx = mean(modelMomentsSynx, 3);
stdMomentsSynx = std(modelMomentsSynx, [], 3);
maxMoment = max([ ...
    max(meanIdMoments, [], "all"), ...
    max(meanMoments, [], "all"), ...
    max(meanMomentsSynx, [], "all")]);
minMoment = min([ ...
    min(meanIdMoments, [], "all"), ...
    min(meanMoments, [], "all"), ...
    min(meanMomentsSynx, [], "all")]);
if nargin < 2
    figureWidth = ceil(sqrt(numel(jointLabels)));
    figureHeight = ceil(numel(jointLabels)/figureWidth);
elseif nargin < 3
    figureHeight = ceil(sqrt(numel(jointLabels)));
end
figureSize = figureWidth * figureHeight;
subplotNumber = 1;
figureNumber = 1;
figure(Name = strcat(resultsDirectory, ...
    " Joint Moment Matching"), ...
    Units=params.units, ...
    Position=params.figureSize)

time = 1:1:size(meanIdMoments,1);
t = tiledlayout(figureHeight, figureWidth, ...
    TileSpacing='Compact', Padding='Compact');
xlabel(t, "Percent Movement [0-100%]", ...
    fontsize=params.axisLabelFontSize)
ylabel(t, "Joint Moment [Nm]", ...
    fontsize=params.axisLabelFontSize)
set(gcf, color=params.plotBackgroundColor)
for i=1:numel(jointLabels)
    if i > figureSize * figureNumber
        figureNumber = figureNumber + 1;
        figure(Name = strcat(resultsDirectory, ...
            " Joint Moment Matching"), ...
            Units=params.units, ...
            Position=params.figureSize)
        t = tiledlayout(figureHeight, figureWidth, ...
            TileSpacing='Compact', Padding='Compact');
        xlabel(t, "Joint Position", ...
            fontsize=params.axisLabelFontSize)
        ylabel(t, "Joint Moment [Nm]", ...
            fontsize=params.axisLabelFontSize)
        subplotNumber = 1;
    end
    nexttile(subplotNumber);
    set(gca, ...
        fontsize = params.tickLabelFontSize, ...
        color=params.subplotBackgroundColor)
    if ~isempty(meanMomentsSynx)
        hold on
        plotMeanAndStd(meanIdMoments(:,i), stdIdMoments(:,i), ...
            time, params.lineColors(1))
        plotMeanAndStd(meanMomentsSynx(:,i), stdMomentsSynx(:,i), ...
            time, params.lineColors(2))
        plotMeanAndStd(meanMoments(:, i), stdMoments(:, i), ...
            time, params.lineColors(2), '--')
        hold off
        rmse = rms(meanMomentsSynx(:,i) - meanIdMoments(:,i));
        mae = mean(abs(meanMomentsSynx(:,i) - meanIdMoments(:,i)));
        title(sprintf("%s \n RMSE: %.4f, MAE: %.4f", ...
            jointLabels(i), rmse, mae), ...
            fontsize = params.subplotTitleFontSize)
        axis([time(1) time(end) minMoment, maxMoment])
        if subplotNumber == 1
            legend("Mean Inverse Dynamics Moment", ...
                "Mean Model Moment (SynX)", ...
                "Mean Model Moment (No SynX)", ...
                fontsize = params.legendFontSize)
        end
    else
        hold on
        plotMeanAndStd(meanIdMoments(:,i), stdIdMoments(:,i), ...
            time, params.lineColors(1))
        plotMeanAndStd(meanMoments(:, i), stdMoments(:, i), ...
            time, params.lineColors(2))
        hold off
        set(gca, fontsize=11)
        rmse = rms(meanMoments(:,i) - meanIdMoments(:,i));
        mae = mean(abs(meanMoments(:,i) - meanIdMoments(:,i)));
        title(sprintf("%s \n RMSE: %.4f, MAE: %.4f", ...
            jointLabels(i), rmse, mae), ...
            fontsize = params.subplotTitleFontSize)
        xlim("tight")
        ylim([minMoment, maxMoment])
        if subplotNumber == 1
            legend("Mean Inverse Dynamics Moment", ...
                "Mean Model Moment (No SynX)", ...
                fontsize = params.legendFontSize)
        end
    end
    subplotNumber = subplotNumber + 1;
end
end