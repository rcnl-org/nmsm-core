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
% Author(s): Marleny Vega                                                 %
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

function saveTrackingOptimizationResults(solution, inputs)

values = getTrackingOptimizationValueStruct(solution.solution.phase, inputs);
outputDirectory = [inputs.resultsDirectory '\optimal'];
if ~exist(outputDirectory, 'dir')
   mkdir(outputDirectory)
end
writeToSto(inputs.coordinateNames, values.time, values.statePositions, ...
    fullfile(outputDirectory, "inverseKinematics.sto"));
writeToSto(inputs.inverseDynamicMomentLabels, values.time, ...
    solution.inverseDynamicMoments, fullfile(outputDirectory, ...
    "inverseDynamics.sto"));
groundContactLabels = [];
groundContactData = [];
for i = 1:length(inputs.contactSurfaces)
    groundContactLabels = cat(2, groundContactLabels, ...
        [inputs.contactSurfaces{i}.forceColumns, ...
        inputs.contactSurfaces{i}.momentColumns, ...
        inputs.contactSurfaces{i}.electricalCenterColumns]);
    midfootSuperiorLocation = pointKinematics(values.time, ...
        values.statePositions, values.stateVelocities, ...
        inputs.contactSurfaces{i}.midfootSuperiorPointOnBody', ...
        inputs.contactSurfaces{i}.midfootSuperiorBody, inputs.coordinateNames);
    midfootSuperiorLocation(:, 2) = 0;
    groundContactData = [groundContactData, ...
        solution.groundReactionsLab.forces{i}, ...
        solution.groundReactionsLab.moments{i}, ...
        midfootSuperiorLocation];
end
writeToSto(groundContactLabels, values.time, ...
    groundContactData, fullfile(outputDirectory, ...
    "groundReactions.sto"));
stateLabels = inputs.coordinateNames;
for i = 1 : length(inputs.coordinateNames)
    stateLabels{end + 1} = strcat(inputs.coordinateNames{i}, '_u');
end
for i = 1 : length(inputs.coordinateNames)
    stateLabels{end + 1} = strcat(inputs.coordinateNames{i}, '_dudt');
end
writeToSto(stateLabels, values.time, [values.statePositions ...
    values.stateVelocities values.stateAccelerations], ...
    fullfile(inputs.resultsDirectory, "statesSolution.sto"));
if strcmp(inputs.controllerType, 'synergy_driven')
    controlLabels = inputs.coordinateNames;
    for i = 1 : inputs.numSynergies
        controlLabels{end + 1} = strcat('command', num2str(i));
    end
    writeToSto(controlLabels, values.time, [values.controlJerks ...
        values.controlNeuralCommands], fullfile(inputs.resultsDirectory, ...
        "controlSolution.sto"));
    writeToSto(inputs.muscleLabels, linspace(1, inputs.numSynergies, ...
        inputs.numSynergies), [values.synergyWeights], ...
        fullfile(inputs.resultsDirectory, "parameterSolution.sto"));
    writeToSto(inputs.muscleLabels, values.time, solution.muscleActivations, ...
    fullfile(outputDirectory, "muscleActivations.sto"));
elseif strcmp(inputs.controllerType, 'torque_driven')
    controlLabels = inputs.coordinateNames;
    for i = 1 : inputs.numTorqueControls
        controlLabels{end + 1} = strcat('torqueControl', num2str(i));
    end
    writeToSto(controlLabels, values.time, [values.controlJerks ...
        values.controlTorques], fullfile(inputs.resultsDirectory, ...
        "controlSolution.sto"));
end
delete(inputs.mexModel);
end