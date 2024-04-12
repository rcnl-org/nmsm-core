% This function is part of the NMSM Pipeline, see file for full license.
%
% () -> ()
%

% ----------------------------------------------------------------------- %
% The NMSM Pipeline is a toolkit for model personalization and treatment  %
% optimization of neuromusculoskeletal models through OpenSim. See        %
% nmsm.rice.edu and the NOTICE file for more information. The             %
% NMSM Pipeline is developed at Rice University and supported by the US   %
% National Institutes of Health (R01 EB030520).                           %
%                                                                         %
% Copyright (c) 2021 Rice University and the Authors                      %
% Author(s): Marleny Vega, Claire V. Hammond, Spencer Williams            %
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

function reportSurrogateModel(inputs)
if valueOrAlternate(inputs, 'plotSurrogateResults', false)
    plotSurrogateResults(inputs);
end
if valueOrAlternate(inputs, 'plotExperimentalResults', false)
    plotExperimentalResults(inputs);
end
end

function plotSurrogateResults(inputs)
inputs = getMuscleSpecificSurrogateModelDataSurrogate(inputs);
[newMuscleTendonLengths, newMomentArms, newMuscleTendonVelocities] = ...
    calcSurrogateModel(inputs, inputs.muscleSpecificJointAngles, ...
    inputs.muscleSpecificJointVelocities);
plotSurrogateModelFitting(inputs, newMuscleTendonLengths, ...
    newMomentArms, newMuscleTendonVelocities, false);
end

function plotExperimentalResults(inputs)
inputs = getMuscleSpecificSurrogateModelDataExperimental(inputs);
inputsExperimental = parseExperimentalMaData(inputs);
if ~isempty(fieldnames(inputsExperimental))
    [newMuscleTendonLengths, newMomentArms, newMuscleTendonVelocities] = ...
        calcSurrogateModel(inputsExperimental, ...
        inputs.muscleSpecificJointAngles, ...
        inputs.muscleSpecificJointVelocities);
    plotSurrogateModelFitting(inputsExperimental, newMuscleTendonLengths, ...
        newMomentArms, newMuscleTendonVelocities, true);
else
    warning("No muscle analysis data given in tracked data directory.")
end
end

function plotSurrogateModelFitting(inputs, newMuscleTendonLengths, ...
    newMomentArms, newMuscleTendonVelocities, plottingExperimental)

nplots = ceil(sqrt(inputs.numMuscles));
% Plot muscle tendon lengths
figure('name', 'Muscle Tendon Lengths')
for i = 1 : inputs.numMuscles
    subplot(nplots, nplots, i)
    plotData(inputs.muscleTendonLengths(:, i), newMuscleTendonLengths(:, i), ...
        inputs.muscleNames{i})
    axis([1 size(inputs.muscleTendonLengths, 1) min(inputs.muscleTendonLengths,  [], ...
        'all') max(inputs.muscleTendonLengths,  [], 'all')])
    if i > inputs.numMuscles - nplots; xlabel('Data Points');
    else xticklabels(''); end
    if ismember(i, 1 : nplots : inputs.numMuscles)
        ylabel({'Muscle','Tendon Lengths'});
    else yticklabels(''); end
    if i == inputs.numMuscles
        legend('Original', 'Predicted');
    end
end

if plottingExperimental && isfield(inputs, 'muscleTendonVelocities')
    nplots = ceil(sqrt(inputs.numMuscles));
    % Plot muscle tendon velocities
    figure('name', 'Muscle Tendon Velocities')
    for i = 1 : inputs.numMuscles
        subplot(nplots, nplots, i)
        plotData(inputs.muscleTendonVelocities(:, i), newMuscleTendonVelocities(:, i), ...
            inputs.muscleNames{i})
        axis([1 size(inputs.muscleTendonVelocities, 1) min(inputs.muscleTendonVelocities,  [], ...
            'all') max(inputs.muscleTendonVelocities,  [], 'all')])
        if i > inputs.numMuscles - nplots; xlabel('Data Points');
        else xticklabels(''); end
        if ismember(i, 1 : nplots : inputs.numMuscles)
            ylabel({'Muscle','Tendon Velocities'});
        else yticklabels(''); end
        if i == inputs.numMuscles
            legend('Original', 'Predicted');
        end
    end
end

% Plot moment arms
for j = 1 : length(inputs.surrogateModelCoordinateNames)
    figure('name', 'Moment Arms')
    for i = 1 : inputs.numMuscles
        subplot(nplots, nplots, i)
        for k = 1:length(inputs.coordinateNames)
            if strcmp(inputs.surrogateModelCoordinateNames(j), inputs.coordinateNames(k))
                plotData(inputs.surrogateModelMomentArms(:,j,i), newMomentArms(:,k,i), inputs.muscleNames(i));
            end
        end
        if i > inputs.numMuscles - nplots; xlabel('Data Points');
        else xticklabels(''); end
        if ismember(i, 1 : nplots : inputs.numMuscles)
            ylabel({'Moment','Arms'}); end
        if i == inputs.numMuscles
            legend('Original', 'Predicted');
        end
    end
end
end
function plotData(original, predicted, muscleLabel)
plot(original, 'r', 'LineWidth', 2)
hold on; plot(predicted, 'k')
title(strrep(muscleLabel, '_', ' '))
end

function inputs = getMuscleSpecificSurrogateModelDataExperimental(inputs)
inputs.momentArms = parseSelectMomentArms( ...
    fullfile(inputs.trackedDirectory, "MAData", inputs.trialName), ...
    inputs.surrogateModelCoordinateNames, inputs.muscleNames);
inputs.momentArms = reshape(permute(inputs.momentArms, [1 4 2 3]), [], ...
    length(inputs.surrogateModelCoordinateNames), length(inputs.muscleNames));
inputs.splineJointAngles = makeGcvSplineSet(inputs.experimentalTime, ...
    inputs.experimentalJointAngles', inputs.coordinateNames);
inputs.experimentalJointVelocities = evaluateGcvSplines( ...
    inputs.splineJointAngles, inputs.coordinateNames, ...
    inputs.experimentalTime, 1);
inputs.splinedJointAngles = evaluateGcvSplines(inputs.splineJointAngles, ...
    inputs.coordinateNames, inputs.experimentalTime, 0);
inputs.splinedJointSpeeds = evaluateGcvSplines(inputs.splineJointAngles, ...
    inputs.coordinateNames, inputs.experimentalTime, 1);
inputs.muscleSpecificJointAngles = {};
inputs.muscleSpecificJointVelocities = {};
inputs.muscleSpecificMomentArms = {};
for i = 1:inputs.numMuscles
    counter = 1;
    for j = 1:length(inputs.surrogateIkCoordinateNames)
        for k = 1:length(inputs.surrogateModelCoordinateNames)
            if strcmp(inputs.surrogateIkCoordinateNames(j), inputs.surrogateModelCoordinateNames(k))
                if max(abs(inputs.surrogateModelMomentArms(:,k,i))) > inputs.epsilon
                    % inputs.surrogateModelLabels{i}(counter) = ...
                    %     inputs.coordinateNames(j);
                    inputs.muscleSpecificJointAngles{i}(:,counter) = ...
                        inputs.splinedJointAngles(:,j);
                    inputs.muscleSpecificJointVelocities{i}(:,counter) = ...
                        inputs.splinedJointSpeeds(:,j);
                    inputs.muscleSpecificMomentArms{i}(:,counter) = ...
                        inputs.momentArms(:,k,i);
                    counter = counter + 1;
                end
            end
        end
    end
end
end

function inputs = getMuscleSpecificSurrogateModelDataSurrogate(inputs)
inputs.splineJointAngles = makeGcvSplineSet(inputs.surrogateTime, ...
    inputs.surrogateModelJointAngles', inputs.coordinateNames);
inputs.splinedJointSpeeds = evaluateGcvSplines( ...
    inputs.splineJointAngles, inputs.coordinateNames, ...
    inputs.surrogateTime, 1);
inputs.muscleSpecificJointVelocities = {};
for i = 1:inputs.numMuscles
    counter = 1;
    for j = 1:length(inputs.surrogateIkCoordinateNames)
        for k = 1:length(inputs.surrogateModelCoordinateNames)
            if strcmp(inputs.surrogateIkCoordinateNames(j), inputs.surrogateModelCoordinateNames(k))
                if max(abs(inputs.surrogateModelMomentArms(:,k,i))) > inputs.epsilon
                    inputs.muscleSpecificJointVelocities{i}(:,counter) = ...
                        inputs.splinedJointSpeeds(:,j);
                    counter = counter + 1;
                end
            end
        end
    end
end
end

function inputsExperimental = parseExperimentalMaData(inputs)
try
    directory = fullfile(inputs.trackedDirectory, "MAData", inputs.trialName);
    inputsExperimental = inputs;
    inputsExperimental.surrogateModelMomentArms = parseSelectMomentArms(directory, ...
        inputs.surrogateModelCoordinateNames, inputs.muscleNames);
    [inputsExperimental.muscleTendonLengths, inputsExperimental.muscleTendonColumnNames] = ...
        parseFileFromDirectories(directory, "_Length.sto", inputs.model);
    inputsExperimental.muscleTendonLengths = findSpecificMusclesInData( ...
        inputsExperimental.muscleTendonLengths, inputsExperimental.muscleTendonColumnNames, ...
        inputs.muscleNames);
    inputsExperimental.muscleTendonLengths = reshape(permute(inputsExperimental.muscleTendonLengths, ...
        [1 3 2]), [], length(inputs.muscleNames));
    inputsExperimental.surrogateModelMomentArms = reshape(permute(inputsExperimental.surrogateModelMomentArms, [1 4 2 3]), [], ...
        length(inputs.surrogateModelCoordinateNames), length(inputs.muscleNames));
catch
    inputsExperimental = struct();
end
end
