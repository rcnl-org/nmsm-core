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

function plotMuscleExcitationsAndActivations(resultsDirectory)
[muscleNames, excitations] = extractMtpDataFromSto( ...
    fullfile(resultsDirectory, "muscleExcitations"));
[~, activations] = extractMtpDataFromSto( ...
    fullfile(resultsDirectory, "muscleActivations"));
[~, excitationsSynx] = extractMtpDataFromSto( ...
    fullfile(resultsDirectory, "muscleExcitationsSynx"));
[~, activationsSynx] = extractMtpDataFromSto( ...
    fullfile(resultsDirectory, "muscleActivationsSynx"));
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

t = 1:1:size(meanExcitations,1);
numWindows = ceil(sqrt(numel(muscleNames)));
for i = 1:numel(muscleNames)
    subplot(numWindows, numWindows, i);
    hold on
    plot(meanExcitations(:,i), 'b-', linewidth=2)
    plot(meanExcitationsSynx(:,i), 'b--', linewidth=2)
    plot(meanActivations(:,i), 'r-', linewidth=2)
    plot(meanActivationsSynx(:,i), 'r--', linewidth=2)

    excitationFillRegion = [(meanExcitations(:,i)+stdExcitations(:,i)); ...
        flipud((meanExcitations(:,i)-stdExcitations(:,i)))];
    fill([t, fliplr(t)]', excitationFillRegion, 'b', FaceAlpha=0.2, ...
        EdgeColor='none', HandleVisibility='off')

    excitationSynxFillRegion = [(meanExcitationsSynx(:,i)+stdExcitationsSynx(:,i)); ...
        flipud((meanExcitationsSynx(:,i)-stdExcitationsSynx(:,i)))];
    fill([t, fliplr(t)]', excitationSynxFillRegion, 'b', FaceAlpha=0.2, ...
        EdgeColor='none', HandleVisibility='off')

    activationFillRegion = [(meanActivations(:,i)+stdActivations(:,i)); ...
        flipud((meanActivations(:,i)-stdActivations(:,i)))];
    fill([t, fliplr(t)]', activationFillRegion, 'r', FaceAlpha=0.2, ...
        EdgeColor='none', HandleVisibility='off')

    activationSynxFillRegion = [(meanActivationsSynx(:,i)+stdActivationsSynx(:,i)); ...
        flipud((meanActivationsSynx(:,i)-stdActivationsSynx(:,i)))];
    fill([t, fliplr(t)]', activationSynxFillRegion, 'r', FaceAlpha=0.2, ...
        EdgeColor='none', HandleVisibility='off')
    set(gca, fontsize=11)
    axis([1 size(meanExcitations, 1) 0 1])
    title(muscleNames(i), FontSize=12);
    if i == 1
        legend ('Excitation(without residual)', ...
            'Excitation(with residual)', ...
            'Activation(without residual)', ...
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