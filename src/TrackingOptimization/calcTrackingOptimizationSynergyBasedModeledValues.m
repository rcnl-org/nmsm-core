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

function phaseout = calcTrackingOptimizationSynergyBasedModeledValues(...
    values, params, phaseout)
if strcmp(params.controllerType, 'synergy_driven') 
jointAngles = getMuscleActuatedDOFs(values, params);
[params.muscleTendonLength, params.momentArms] = calcSurrogateModel( ...
    params, jointAngles);
params.muscleTendonVelocity = calcMuscleTendonVelocities(values.time, ...
    params.muscleTendonLength);
[phaseout.normalizedFiberLength, phaseout.normalizedFiberVelocity] = ...
    calcNormalizedMuscleFiberLengthsAndVelocities(params, ...
    ones(1, params.numMuscles), ones(1, params.numMuscles));
phaseout.muscleActivations = calcMuscleActivationFromSynergies(values);
muscleJointMoments = calcMuscleJointMoments(params, ...
    phaseout.muscleActivations, phaseout.normalizedFiberLength, ...
    phaseout.normalizedFiberVelocity);
phaseout.muscleJointMoments = muscleJointMoments(:, params.surrogateModelIndex);
phaseout.muscleJointMoments = phaseout.muscleJointMoments(:, params.dofsActuatedIndex);
end
end

function muscleActivations = calcMuscleActivationFromSynergies(values)
muscleActivations = values.controlNeuralCommands * values.synergyWeights;
end
function jointAngles = getMuscleActuatedDOFs(values, params)

for i = 1:params.numMuscles
    counter = 1;
    for j = 1:length(params.coordinateNames)
        for k = 1:length(params.surrogateModelLabels{i})
            if strcmp(params.coordinateNames(j), params.surrogateModelLabels{i}{k})
                jointAngles{i}(:,counter) = values.statePositions(:,j);
                counter = counter + 1;
            end
        end
    end
end
end
function muscleTendonVelocities = calcMuscleTendonVelocities(time, ...
    muscleTendonLength)

for i = 1 : size(muscleTendonLength, 2)
    muscleTendonVelocities(:, i) = calcDerivative(time, ...
        muscleTendonLength(:, i));
end
end