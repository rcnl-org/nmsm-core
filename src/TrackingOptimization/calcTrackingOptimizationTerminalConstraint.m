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

statePeriodicity = calcStatesPeriodicity(values, params);
groundReactionsPeriodicity = calcGroundReactionsPeriodicity(...
    modeledValues, params);
rootSegmentResidualsPeriodicity = calcRootSegmentResidualsPeriodicity(...
    modeledValues, params);
synergyWeightsPeriodicity = calcSynergyWeightsSum( ...
    values, params);
event = [statePeriodicity groundReactionsPeriodicity ...
    rootSegmentResidualsPeriodicity synergyWeightsPeriodicity];
end
function statePeriodicity = calcStatesPeriodicity(values, params)
isPositionEnabled = valueOrAlternate(params, ...
    "statePositionPeriodicityConstraint", 0);
isVelocityEnabled = valueOrAlternate(params, ...
    "stateVelocityPeriodicityConstraint", 0);
statePeriodicity = [];
if isPositionEnabled
    statePeriodicity = [diff(values.statePositions) ...
        diff(values.stateVelocities)];
end
if isVelocityEnabled
    statePeriodicity = [statePeriodicity diff(values.statePositions) ...
        diff(values.stateVelocities)];
end
end
function groundReactionsPeriodicity = calcGroundReactionsPeriodicity( ...
    modeledValues, params)
isForcesEnabled = valueOrAlternate(params, ...
    "groundReactionForcesPeriodicityConstraint", 0);
isMomentsEnabled = valueOrAlternate(params, ...
    "groundReactionMomentsPeriodicityConstraint", 0);
groundReactionsPeriodicity = [];
if isForcesEnabled
    groundReactionsPeriodicity = [...
        diff(modeledValues.rightGroundReactionsLab(:, 1:3)) ...
        diff(modeledValues.leftGroundReactionsLab(:, 1:3))];
end
if isMomentsEnabled
    groundReactionsPeriodicity = [groundReactionsPeriodicity ...
        diff(modeledValues.rightGroundReactionsLab(:, 4:6)) ...
        diff(modeledValues.leftGroundReactionsLab(:, 4:6))];
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
    synergyWeightsSum = sum(values.synergyWeights.^2, 2)';
end
end