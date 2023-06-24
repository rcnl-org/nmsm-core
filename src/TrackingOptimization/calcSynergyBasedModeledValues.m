% This function is part of the NMSM Pipeline, see file for full license.
%
% This function calculates muscle tendon lengths and velocities along with
% moment arms from a surrogate model. These quantities are used to
% calculate normalized fiber lengths and velocities. Muscle activations are
% calculated from muscles synergies and all of these quantities are used to
% calculate the muscle produced joint moments.
%
% (struct, struct, struct) -> (struct)
% Returns normalized fiber lengths and velocities, muscle activations, and
% muscle joint moments

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

function modeledValues = calcSynergyBasedModeledValues(values, params, ...
    modeledValues)
if strcmp(params.controllerType, 'synergy_driven')
    [jointAngles, jointVelocities] = getMuscleActuatedDOFs(values, params);
    [params.muscleTendonLength, params.momentArms, ...
        params.muscleTendonVelocity] = calcSurrogateModel(params, ...
        jointAngles, jointVelocities);
    [modeledValues.normalizedFiberLength, modeledValues.normalizedFiberVelocity] = ...
        calcNormalizedMuscleFiberLengthsAndVelocities(params, ...
        ones(1, params.numMuscles), ones(1, params.numMuscles));
    modeledValues.muscleActivations = calcMuscleActivationFromSynergies(values);
    muscleJointMoments = calcMuscleJointMoments(params, ...
        modeledValues.muscleActivations, modeledValues.normalizedFiberLength, ...
        modeledValues.normalizedFiberVelocity);
    modeledValues.muscleJointMoments = muscleJointMoments(:, ...
        params.surrogateModelIndex);
    modeledValues.muscleJointMoments = modeledValues.muscleJointMoments(:, ...
        params.dofsActuatedIndex);
end
end
function muscleActivations = calcMuscleActivationFromSynergies(values)
muscleActivations = values.controlSynergyActivations * values.synergyWeights;
end

function [jointAngles, jointVelocities] = getMuscleActuatedDOFs(values, params)
for i = 1:params.numMuscles
    counter = 1;
    for j = 1:length(params.coordinateNames)
        for k = 1:length(params.surrogateModelLabels{i})
            if strcmp(params.coordinateNames(j), params.surrogateModelLabels{i}{k})
                jointAngles{i}(:,counter) = values.statePositions(:,j);
                jointVelocities{i}(:,counter) = values.stateVelocities(:,j);
                counter = counter + 1;
            end
        end
    end
end
end