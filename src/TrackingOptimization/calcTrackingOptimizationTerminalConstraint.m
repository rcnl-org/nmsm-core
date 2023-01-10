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
inputs.phasetime = [inputs.phase.initialtime; inputs.phase.finaltime];
values = getTrackingOptimizationValueStruct(inputs, params);
modeledValues = calcTrackingOptimizationModeledValues(values, params);

statePeriodicity = calcStatesPeriodicity(values, params);
groundReactionsPeriodicity = calcGroundReactionsPeriodicity(...
    modeledValues, params);
pelvisResidualsPeriodicity = calcPelvisResidualsPeriodicity(...
    modeledValues, params);
synergyWeightsPeriodicity = calcSynergyWeightsPeriodicity( ...
    values, params);
event = [statePeriodicity groundReactionsPeriodicity ...
    pelvisResidualsPeriodicity synergyWeightsPeriodicity];
end
function statePeriodicity = calcStatesPeriodicity(values, params)
isEnabled = valueOrAlternate(params, "statePeriodicityConstraint", 0);
statePeriodicity = [];
if isEnabled
    statePeriodicity = [diff(values.statePositions) ...
        diff(values.stateVelocities)];
end
end
function groundReactionsPeriodicity = calcGroundReactionsPeriodicity( ...
    modeledValues, params)
isEnabled = valueOrAlternate(params, ...
    "groundReactionsPeriodicityConstraint", 0);
groundReactionsPeriodicity = [];
if isEnabled
    groundReactionsPeriodicity = [diff(modeledValues.rightGroundReactionsLab)
        diff(modeledValues.leftGroundReactionsLab)];
end
end
function pelvisResidualsPeriodicity = calcPelvisResidualsPeriodicity( ...
    modeledValues, params)
isEnabled = valueOrAlternate(params, ...
    "pelvisResidualsPeriodicityConstraint", 0);
pelvisResidualsPeriodicity = [];
if isEnabled
    pelvisResidualsPeriodicity = diff(modeledValues.pelvisResiduals);
end
end
function synergyWeightsPeriodicity = calcSynergyWeightsPeriodicity( ...
    values, params)
isEnabled = valueOrAlternate(params, ...
    "synergyWeightsPeriodicityConstraint", 0);
synergyWeightsPeriodicity = [];
if isEnabled
    synergyWeightsPeriodicity = sum(values.synergyWeights.^2, 2);
end
end