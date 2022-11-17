% This function is part of the NMSM Pipeline, see file for full license.
%
%
%
% (Array of double, struct, struct) -> (struct)
% Optimize ground contact parameters according to Jackson et al. (2016)

% ----------------------------------------------------------------------- %
% The NMSM Pipeline is a toolkit for model personalization and treatment  %
% optimization of neuromusculoskeletal models through OpenSim. See        %
% nmsm.rice.edu and the NOTICE file for more information. The             %
% NMSM Pipeline is developed at Rice University and supported by the US   %
% National Institutes of Health (R01 EB030520).                           %
%                                                                         %
% Copyright (c) 2021 Rice University and the Authors                      %
% Author(s): Claire V. Hammond, Spencer Williams                          %
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

function cost = calcGroundReactionCost(values, fieldNameOrder, inputs, ...
    params)
valuesStruct = unpackValues(values, inputs, fieldNameOrder);
valuesBSplineCoefficients = ...
    reshape(valuesStruct.bSplineCoefficients, [], 7);
[modeledJointPositions, modeledJointVelocities] = calcGCPJointKinematics( ...
    inputs.experimentalJointPositions, inputs.jointKinematicsBSplines, ...
    valuesBSplineCoefficients);
modeledValues = calcGCPModeledValues(inputs, valuesStruct, ...
    modeledJointPositions, modeledJointVelocities, [1, 1, 1, 0]);
modeledValues.jointPositions = modeledJointPositions;
modeledValues.jointVelocities = modeledJointVelocities;

% Debug plots
% subplot(1,3,1)
% plot(inputs.time, modeledValues.verticalGrf)
% hold on
% plot(inputs.time, inputs.experimentalGroundReactionForces(2,:))
% hold off
% subplot(1,3,2)
% plot(inputs.time, modeledValues.anteriorGrf)
% hold on
% plot(inputs.time, inputs.experimentalGroundReactionForces(1,:))
% hold off
% subplot(1,3,3)
% plot(inputs.time, modeledValues.lateralGrf)
% hold on
% plot(inputs.time, inputs.experimentalGroundReactionForces(3,:))
% hold off

cost = calcCost(inputs, params, modeledValues, valuesStruct);
end

function valuesStruct = unpackValues(values, inputs, fieldNameOrder)
valuesStruct = struct();
start = 1;
for i=1:length(fieldNameOrder)
    valuesStruct.(fieldNameOrder(i)) = values(start:start + ...
        numel(inputs.(fieldNameOrder(i))) - 1);
    start = start + numel(inputs.(fieldNameOrder(i)));
end
end

function cost = calcCost(inputs, params, modeledValues, valuesStruct)
cost = [];
[footMarkerPositionError, footMarkerSlopeError] = ...
    calcFootMarkerPositionAndSlopeError(inputs, modeledValues);
cost = (1 / (12 * 101)) * (1 / 0.05) * footMarkerPositionError; % Based on OpenSim IK best practices, 1-2 cm
% cost = [cost calcFootMarkerDistanceError(inputs, params, ...
%     footMarkerPositionError)];
% cost = [cost 1000 * footMarkerSlopeError];
% cost = [cost 10000 * calcKinematicCurveSlopeError(inputs, ...
%     modeledValues, 1:size(modeledValues.jointVelocities, 1))];
[groundReactionForceValueErrors, groundReactionForceSlopeErrors] = ...
    calcGroundReactionForceAndSlopeError(inputs, modeledValues);
cost = [cost (1 / 101) * (1 / 0.2) * groundReactionForceValueErrors(1, :)]; % may make this more strict (1 / 0.1)
cost = [cost (1 / 101) * (1 / 0.2) * groundReactionForceValueErrors(2, :)];
cost = [cost (1 / 101) * (1 / 0.2) * groundReactionForceValueErrors(3, :)]; % may make this more strict (1 / 0.1)
% cost = [cost 1 / 3 * groundReactionForceSlopeErrors(1)];
% cost = [cost 1 / 5 * groundReactionForceSlopeErrors(2)];
% cost = [cost 2 * groundReactionForceSlopeErrors(3)];
cost = [cost (1 / length(valuesStruct.springConstants)) * (1 / 2000) ...
    * calcSpringConstantsErrorFromMean(valuesStruct.springConstants)];
% cost = [cost 1 / 1 * abs(inputs.springConstants - ...
%     valuesStruct.springConstants)];
% cost = [cost 1 / 1e-6 * calcDampingFactorsErrorFromMean(... % may combine damping factors to one scaling factor
%     valuesStruct.dampingFactors)];
% cost = [cost 1 / 0.0001 * calcDampingFactorDeviationFromInitialValueError(... % may combine damping factors to one scaling factor
%     inputs.dampingFactors, valuesStruct.dampingFactors)];
% cost = [cost calcSpringConstantDeviationFromInitialValueError(... % may be redundant
%     inputs.springConstants, valuesStruct.springConstants)];
% cost = [cost calcStaticFrictionDeviationError(...
%     valuesStruct.staticFrictionCoefficient, params)];
% cost = [cost calcDynamicFrictionDeviationError(... % may not be needed
%     valuesStruct.dynamicFrictionCoefficient, params)];
% cost = [cost calcViscousFrictionDeviationError(...
%     valuesStruct.viscousFrictionCoefficient, params)];
% cost = [cost calcStaticToDynamicFrictionDeviationError(...
%     valuesStruct.staticFrictionCoefficient, ...
%     valuesStruct.dynamicFrictionCoefficient)];

% cost = cost / numel(cost);
end
