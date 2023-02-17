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

function event = calcTrackingOptimizationTerminalConstraint(inputs, params)

inputs.phase.state = [inputs.phase.initialstate; inputs.phase.finalstate];
inputs.phase.time = [inputs.phase.initialtime; inputs.phase.finaltime];
inputs.phase.parameter = inputs.parameter;
inputs.phase.control = ones(size(inputs.phase.time,1),length(params.minControl));
values = getTrackingOptimizationValueStruct(inputs.phase, params);
modeledValues = calcTrackingOptimizationTorqueBasedModeledValues(values, params);

statePositionPeriodicity = calcStatePositionPeriodicity(values, params);
stateVelocityPeriodicity = calcStateVelocityPeriodicity(values, params);
externalForcesPeriodicity = calcExternalForcesPeriodicity(...
    modeledValues, params);
externalMomentsPeriodicity = calcExternalMomentsPeriodicity(...
    modeledValues, params);
rootSegmentResidualsPeriodicity = calcRootSegmentResidualsPeriodicity(...
    modeledValues, params);
synergyWeightsPeriodicity = calcSynergyWeightsSum( ...
    values, params);
event = [statePositionPeriodicity stateVelocityPeriodicity ...
    rootSegmentResidualsPeriodicity externalForcesPeriodicity ...
    externalMomentsPeriodicity synergyWeightsPeriodicity];
end
function statePositionPeriodicity = calcStatePositionPeriodicity(values, params)
isEnabled = valueOrAlternate(params, ...
    "statePositionPeriodicityConstraint", 0);
statePositionPeriodicity = [];
if isEnabled
    statePositionPeriodicity = diff(values.statePositions);
end
end
function stateVelocityPeriodicity = calcStateVelocityPeriodicity(values, params)
isEnabled = valueOrAlternate(params, ...
    "stateVelocityPeriodicityConstraint", 0);
stateVelocityPeriodicity = [];
if isEnabled
    stateVelocityPeriodicity = diff(values.stateVelocities);
end
end
function externalForcesPeriodicity = calcExternalForcesPeriodicity( ...
    modeledValues, params)
isEnabled = valueOrAlternate(params, ...
    "externalForcePeriodicityConstraint", 0);
externalLoads = [modeledValues.rightGroundReactionsLab ...
    modeledValues.leftGroundReactionsLab];
externalForcesPeriodicity = [];
if isEnabled
    externalForcesPeriodicity = [ ...
        diff(externalLoads(:, params.trackedExternalForcesIndex))];
end
end
function externalMomentsPeriodicity = calcExternalMomentsPeriodicity( ...
    modeledValues, params)
isEnabled = valueOrAlternate(params, ...
    "externalMomentPeriodicityConstraint", 0); 
externalLoads = [modeledValues.rightGroundReactionsLab ...
    modeledValues.leftGroundReactionsLab];
externalMomentsPeriodicity = [];
if isEnabled
    externalMomentsPeriodicity = [ ...
        diff(externalLoads(:, params.trackedExternalMomentsIndex))];
end
end
function rootSegmentResidualsPeriodicity = calcRootSegmentResidualsPeriodicity( ...
    modeledValues, params)
isEnabled = valueOrAlternate(params, ...
    "rootSegmentResidualLoadPeriodicityConstraint", 0);
rootSegmentResidualsPeriodicity = [];
if isEnabled
    rootSegmentResidualsPeriodicity = diff(modeledValues.rootSegmentResiduals);
end
end
function synergyWeightsSum = calcSynergyWeightsSum( ...
    values, params)
isEnabled = valueOrAlternate(params, ...
    "synergyWeightsSumConstraint", 0);
synergyWeightsSum = [];
if isEnabled
    synergyWeights = zeros(params.numSynergies, params.numMuscles);
    valuesIndex = 1;
    row = 1;
    column = 1; % the sum of the muscles in the previous synergy groups
    for i = 1:length(params.synergyGroups)
        for j = 1: params.synergyGroups{i}.numSynergies
            synergyWeights(row, column : ...
                column + length(params.synergyGroups{i}.muscleNames) - 1) = ...
                values.synergyWeights(valuesIndex : ...
                valuesIndex + length(params.synergyGroups{i}.muscleNames) - 1);
            valuesIndex = valuesIndex + length(params.synergyGroups{i}.muscleNames);
            row = row + 1;
        end
        column = column + length(params.synergyGroups{i}.muscleNames);
    end
    synergyWeightsSum = sum(synergyWeights, 2)';
end
end