% This function is part of the NMSM Pipeline, see file for full license.
%
% This function reads .sto files created by
% saveMuscleTendonPersonalizationResults.m containing muscle excitations
% and activations and creates plots of them.
%
% (string) -> (None)
% Plot muscle activations and excitations from file.

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

function plotMtpMuscleExcitationsAndActivations(resultsDirectory, ...
    figureWidth, figureHeight)
analysisDirectory = fullfile(resultsDirectory, "Analysis");
[muscleNames, excitations] = extractMtpDataFromSto( ...
    fullfile(analysisDirectory, "muscleExcitations"));

[~, activations] = extractMtpDataFromSto( ...
    fullfile(analysisDirectory, "muscleActivations"));

if exist(fullfile(analysisDirectory, "muscleExcitationsSynx"), "dir")
    [~, excitationsSynx] = extractMtpDataFromSto( ...
        fullfile(analysisDirectory, "muscleExcitationsSynx"));
else
    excitationsSynx = [];
end

if exist(fullfile(analysisDirectory, "muscleActivationsSynx"), "dir")
    [~, activationsSynx] = extractMtpDataFromSto( ...
        fullfile(analysisDirectory, "muscleActivationsSynx"));
else
    activationsSynx = [];
end
muscleNames = strrep(muscleNames, '_', ' ');
meanExcitations = mean(excitations, 3);
stdExcitations = std(excitations,[], 3);
meanActivations = mean(activations, 3);
stdActivations = std(activations,[], 3);
meanExcitationsSynx = mean(excitationsSynx, 3);
stdExcitationsSynx = std(excitationsSynx,[], 3);
meanActivationsSynx = mean(activationsSynx, 3);
stdActivationsSynx = std(activationsSynx,[], 3);
time = 1:1:size(meanExcitations,1);

if nargin < 2
    figureWidth = ceil(sqrt(numel(muscleNames)));
    figureHeight = ceil(numel(muscleNames)/figureWidth);
elseif nargin < 3
    figureHeight = ceil(sqrt(numel(muscleNames)));
end
figureSize = figureWidth * figureHeight;
subplotNumber = 1;
figureNumber = 1;
figure(Name = strcat(resultsDirectory, ...
        " Muscle Excitations and Activations"), ...
    Units='normalized', ...
    Position=[0.05 0.05 0.9 0.85])
t = tiledlayout(figureHeight, figureWidth, ...
    TileSpacing='Compact', Padding='Compact');
xlabel(t, "Percent Movement [0-100%]")
ylabel(t, "Magnitude")
for i = 1:numel(muscleNames)
    if i > figureSize * figureNumber
        figureNumber = figureNumber + 1;
        figure(Name = strcat(resultsDirectory, ...
                " Muscle Excitations and Activations"), ...
            Units='normalized', ...
            Position=[0.05 0.05 0.9 0.85])
        t = tiledlayout(figureHeight, figureWidth, ...
            TileSpacing='Compact', Padding='Compact');
        xlabel(t, "Percent Movement [0-100%]")
        ylabel(t, "Magnitude")
        subplotNumber = 1;
    end
    nexttile(subplotNumber);
    hold on
    if ~isempty(meanExcitationsSynx)
        plotMeanAndStd(meanExcitations(:,i), stdExcitations(:,i), ...
            time, "#0072BD", '--');
        plotMeanAndStd(meanActivations(:,i), stdActivations(:,i), ...
            time, "#D95319", '--');
        plotMeanAndStd(meanExcitationsSynx(:,i), stdExcitationsSynx(:,i), ...
            time, "#0072BD", '-');
        plotMeanAndStd(meanActivationsSynx(:,i), stdActivationsSynx(:,i), ...
            time, "#D95319", '-');
    else
        plotMeanAndStd(meanExcitations(:,i), stdExcitations(:,i), ...
            time, "#0072BD", '-');
        plotMeanAndStd(meanActivations(:,i), stdActivations(:,i), ...
            time, "#D95319", '-');
    end
    set(gca, fontsize=11)
    axis([time(1) time(end) 0 1])
    if (max(meanExcitations(:, i)) == 0)
        title(strcat(muscleNames(i), " *"), FontSize=12);
    else
        title(muscleNames(i), FontSize=12);
    end
    if subplotNumber == 1
        legend ('Excitation (No SynX)', ...
            'Activation (No SynX)', ...
            'Excitation (With SynX)', ...
            'Activation (With SynX)');
    end
    subplotNumber = subplotNumber + 1;
end
end