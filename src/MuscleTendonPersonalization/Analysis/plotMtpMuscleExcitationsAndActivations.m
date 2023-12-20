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

function plotMtpMuscleExcitationsAndActivations(resultsDirectory)
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

figure(Name = "Muscle Excitations and Activations", ...
    Units='normalized', ...
    Position=[0.1 0.1 0.8 0.8])

time = 1:1:size(meanExcitations,1);
numWindows = ceil(sqrt(numel(muscleNames)));
for i = 1:numel(muscleNames)
    subplot(numWindows, numWindows, i);
    hold on
    plotMeanAndStd(meanExcitations(:,i), stdExcitations, time, 'b-');
    plotMeanAndStd(meanActivations(:,i), stdActivations(:,i), time, 'r-');
    if ~isempty(meanExcitationsSynx)
        plotMeanAndStd(meanExcitationsSynx(:,i), stdExcitationsSynx, time, 'b--');
    end
    if ~isempty(meanActivationsSynx)
        plotMeanAndStd(meanActivationsSynx(:,i), stdActivationsSynx, time, 'r--');
    end
    set(gca, fontsize=11)
    axis([1 size(meanExcitations, 1) 0 1])
    title(muscleNames(i), FontSize=12);
    if i == 1
        legend ('Excitation(without residual)', ...
            'Activation(without residual)', ...
            'Excitation(with residual)', ...
            'Activation(with residual)');
    end
    if mod(i,3) == 1
        ylabel("Magnitude")
    end
    if i>numel(muscleNames)-numWindows
        xlabel("Time Points")
    end
end
end