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

function phaseout = calcSynergyBasedModeledValues(values, params, phaseout)
if strcmp(params.controllerType, 'synergy_driven')
    [jointAngles, jointVelocities] = getMuscleActuatedDOFs(values, params);
    [params.muscleTendonLength, params.momentArms, ...
        params.muscleTendonVelocity] = calcSurrogateModel(params, ...
        jointAngles, jointVelocities);
    [phaseout.normalizedFiberLength, phaseout.normalizedFiberVelocity] = ...
        calcNormalizedMuscleFiberLengthsAndVelocities(params, ...
        ones(1, params.numMuscles), ones(1, params.numMuscles));
    phaseout.muscleActivations = calcMuscleActivationFromSynergies(values);
    phaseout.metabolicCost = calcMetabolicCost(values.time, ...
        values.statePositions, phaseout.muscleActivations, params);
    muscleJointMoments = calcMuscleJointMoments(params, ...
        phaseout.muscleActivations, phaseout.normalizedFiberLength, ...
        phaseout.normalizedFiberVelocity);
    phaseout.muscleJointMoments = muscleJointMoments(:, params.surrogateModelIndex);
    phaseout.muscleJointMoments = phaseout.muscleJointMoments(:, params.dofsActuatedIndex);
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