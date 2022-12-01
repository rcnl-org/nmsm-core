% This function is part of the NMSM Pipeline, see file for full license.
%
% This function calculates the scaled muscle excitations given the
% processed EMG signals and SynX-constructed muscle excitaitons for
% unmeaured muscles.
%
% data:
%   time - timestamp vectors
%   timeDelay - electromechanical delay
%   emgScalingFactor - EMG scaling factors 
%   synergyExtrapolation - vector for SynX (including both SynX weights and residual weights)
%   experimentalData.extrapolationCommands - synergy excitations extracted from measured muscle
%                  excitations for SynX
%   experimentalData.residualCommands - synergy excitations extracted from measured muscle excitations 
%                    for residual muscle excitations
%   params.missingEmgChannelPairs - Index for expanding SynX EMG to unmeasured muscles
%   MeasuredMuscIndexExpand - Index for expanding residual EMG to measured muscles
%   params.numberOfSynergies - number of synergies - double
%   size(experimentalData.emgData,2) - number of trials in total - double
%   size(params.missingEmgChannelPairs,2) - number of SynX EMG channels in total - double
%   size(params.missingEmgChannelPairs,2) - number of measured EMG channels in total - double
%   size(params.taskNames,2) -  number of tasks - double
%   experimentalData.emgData - number of time frames for each trial - double
%   params.matrixFactorizationMethod - matrix factorization algorithm - 'PCA' or 'NMF'
%   params.synergyExtrapolationCategorization - variability of synergy vector weights across trials for 
%                  SynX reconstruction
%   params.residualCategorization  - variability of synergy vector weights across trials for 
%                  residual excitation reconstruction
%   TrialIndex - trial index for each task - cell array (nTask cells)
%   nOtherDesignVariables - number of other design variables - double
%
% returns muscle excitations given a combination of measured muscle
% excitations and SynX-constructed muscle excitaitons
%
% ----------------------------------------------------------------------- %
% The NMSM Pipeline is a toolkit for model personalization and treatment  %
% optimization of neuromusculoskeletal models through OpenSim. See        %
% nmsm.rice.edu and the NOTICE file for more information. The             %
% NMSM Pipeline is developed at Rice University and supported by the US   %
% National Institutes of Health (R01 EB030520).                           %
%                                                                         %
% Copyright (c) 2021 Rice University and the Authors                      %
% Author(s): Marleny Vega, Di Ao                                          %
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

function [muscleExcitations, muscleExcitationsNoTDelay] = ...
    calcMuscleExcitationsSynX(experimentalData, timeDelay, ...
    emgScalingFactor, synergyExtrapolationVariables, params) 

experimentalData.emgDataExpanded = round(experimentalData.emgDataExpanded, 4);

% Reconstruct unmeasured muscle excitations using SynX process
unmeasuredEmgSignals = getUnmeasuredMuscleExcitations(params, ...
    experimentalData.emgData, experimentalData.extrapolationCommands, ...
    synergyExtrapolationVariables(1 : experimentalData.numberOfExtrapolationWeights));
% Reconstruct residual muscle excitations for measured muscles
residualExcitations = getResidualMuscleExcitation(params, ...
    experimentalData.residualCommands, synergyExtrapolationVariables( ...
    experimentalData.numberOfExtrapolationWeights + 1 : end));
% Insert unmeasured muscle excitations from SynX
emgData = updateEmgSignals(params.missingEmgChannelPairs, ...
    experimentalData.emgDataExpanded, unmeasuredEmgSignals);
% muscleExcitations are scaled processed Emg signals
emgData = emgData .* emgScalingFactor;
% Distribute residual excitations
muscleExcitationsNoTDelay = distributeResidualExcitations(emgData, ...
    params.currentEmgChannelPairs, residualExcitations);
% Create EMG splines
emgSplines = createEmgSignals(muscleExcitationsNoTDelay, ...
    experimentalData.emgTime, timeDelay);
% Interpolate Emg 
muscleExcitations = evaluateEmgSplines(experimentalData.emgTime, ...
    emgSplines, timeDelay);
% muscleExcitations = permute(muscleExcitations,[1 3 2]);                                     
end
function UnmeasuredExcitations = getUnmeasuredMuscleExcitations(params, ...
    emgData, extrapolationCommands, extrapolationWeights)

UnmeasuredExcitations = zeros(size(emgData, 3) * ...
    size(params.synergyCategorizationOfTrials{1}, 2), ...
    size(params.missingEmgChannelPairs,2), ...
    length(params.synergyCategorizationOfTrials));
for j = 1:size(params.missingEmgChannelPairs,2)
if strcmpi(params.matrixFactorizationMethod,'PCA')
    SynxVars = reshape(extrapolationWeights',(params.numberOfSynergies + 1) * ...
        length(params.synergyCategorizationOfTrials), ...
        size(params.missingEmgChannelPairs, 2))'; 
    for i = 1 : length(params.synergyCategorizationOfTrials)
        UnmeasuredExcitations(:, j, i) = extrapolationCommands{i} * SynxVars(j, ...
            (i - 1) * (params.numberOfSynergies + 1) + 1 : (i - 1) * ...
            (params.numberOfSynergies + 1) + params.numberOfSynergies)' + ...
            repmat(SynxVars(j, i * (params.numberOfSynergies + 1)), ...
            size(emgData,  3) * ...
            size(params.synergyCategorizationOfTrials{i}, 2), 1);
    end
elseif strcmp(params.matrixFactorizationMethod,'NMF')
    SynxVars = reshape(synxVars', params.numberOfSynergies * ...
        length(params.synergyCategorizationOfTrials), ...
        size(params.missingEmgChannelPairs, 2))';
    for i = 1 : length(params.synergyCategorizationOfTrials)
        UnmeasuredExcitations = zeros(emgData * size( ...
            params.synergyCategorizationOfTrials{i}, 2), ...
            size(params.missingEmgChannelPairs, ...
            2), length(params.synergyCategorizationOfTrials));
        UnmeasuredExcitations(:, j, i) = extrapolationCommands{i} * ...
            SynxVars(j, (i - 1) * params.numberOfSynergies + 1 : ...
            i * params.numberOfSynergies, :)';
    end
end
end
UnmeasuredExcitations = permute(UnmeasuredExcitations, [3 2 1]);
end
function residualExcitations = getResidualMuscleExcitation(params, ...
    residualCommands, residualWeights)

if strcmpi(params.matrixFactorizationMethod,'PCA')
    ResVar = reshape(residualWeights', (params.numberOfSynergies + 1), ...
        size(params.missingEmgChannelPairs, 2), ...
        size(params.residualCategorizationOfTrials, 2));
    for i = 1 : size(params.residualCategorizationOfTrials, 2)
        residualExcitations{i}= residualCommands{i} * ResVar(1 : ...
            params.numberOfSynergies, :, i) + ResVar( ...
            params.numberOfSynergies + 1, : , i);
    end
elseif strcmp(params.matrixFactorizationMethod,'NMF')
    ResVar = reshape(residualWeights', params.numberOfSynergies, ...
        size(params.missingEmgChannelPairs, 2), ...
        size(params.residualCategorizationOfTrials, 2));
    for i = 1 : size(params.residualCategorizationOfTrials, 2)
        residualExcitations{i}= residualCommands{i} * ResVar(1 : ...
            params.numberOfSynergies, :, i);
    end
end
concatResidualExcitations = [];
for i = 1:size(params.residualCategorizationOfTrials, 2)
    concatResidualExcitations = [concatResidualExcitations; 
        residualExcitations{i}];
end
residualExcitations = concatResidualExcitations;
end
function emgData = updateEmgSignals(missingEmgChannelPairs, emgData, ...
    unmeasuredEmgSignals)

for i = 1 : size(missingEmgChannelPairs, 2) 
for j = 1 : size(missingEmgChannelPairs{i}, 2)
    emgData(:, missingEmgChannelPairs{i}(1, j), :) = ...
        unmeasuredEmgSignals(:, i, :);
end
end
end
function emgData = distributeResidualExcitations(emgData, ...
    currentEmgChannelPairs, residualExcitations)

%Distribute residual muscle excitations to measured muscles
residualExcitationsExpanded = zeros(size(emgData, 3) * ...
size(emgData, 1), size(emgData, 2));
for i = 1 : size(currentEmgChannelPairs, 2)
for j = 1 : size(currentEmgChannelPairs{i}, 2)
    residualExcitationsExpanded(:, currentEmgChannelPairs{i}(1, j)) = ...
        residualExcitations(:, i);
end
end
residualExcitationsExpanded = reshape(residualExcitationsExpanded, ...
    size(emgData, 3), size(emgData, 1), size(emgData, 2));
emgData = emgData + permute(residualExcitationsExpanded, [2 3 1]);
end
function emgSplines = createEmgSignals(emgData, emgTime, timeDelay)

emgSplines = cell(size(emgData, 1), size(emgData, 2));
if size(timeDelay, 2) <= 2
    for j = 1 : size(emgData, 1)
        emgSplines{j} = spline(emgTime(j, 1 : 4 : end), ...
            emgData(j, :, 1 : 4 : end)'); 
    end
else
    for i = 1 : size(emgData, 2)
        for j = 1:size(emgData, 1)
            emgSplines{j, i} = spline(emgTime(j, 1 : 4 : end), ...
                emgData(j, i, 1 : 4 : end)); 
        end
    end
end
end
function emgData = evaluateEmgSplines(emgTime, emgSplines, timeDelay)

if size(timeDelay, 2) == 1
    emgData = calcEmgDataWithCommonTimeDelay(emgTime, emgSplines, ...
        timeDelay / 10);
else
    emgData = calcEmgDataWithMuscleSpecificTimeDelay(emgTime, ...
        emgSplines, timeDelay / 10);
end
end