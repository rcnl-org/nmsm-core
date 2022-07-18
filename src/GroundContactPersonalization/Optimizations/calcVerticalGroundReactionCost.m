% This function is part of the NMSM Pipeline, see file for full license.
%
% inputs:
%   model - Model
%   experimentalJointKinematics - 2D Array of double
%   coordinateColumns - 1D array of int of coordinate indexes
%
% (Array of double, Array of string, struct, struct) -> (struct)
% Optimize ground contact parameters according to Jackson et al. (2016)

% ----------------------------------------------------------------------- %
% The NMSM Pipeline is a toolkit for model personalization and treatment  %
% optimization of neuromusculoskeletal models through OpenSim. See        %
% nmsm.rice.edu and the NOTICE file for more information. The             %
% NMSM Pipeline is developed at Rice University and supported by the US   %
% National Institutes of Health (R01 EB030520).                           %
%                                                                         %
% Copyright (c) 2021 Rice University and the Authors                      %
% Author(s): Claire V. Hammond                                            %
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

function cost = calcVerticalGroundReactionCost(values, fieldNameOrder, ...
    inputs, params)
modeledJointKinematics = calcGCPJointKinematics( ...
    inputs.experimentalJointKinematics, inputs.jointKinematicsSplines, ...
    findValuesByFieldName(values, inputs, "bSplineCoefficients", ...
    fieldNameOrder));
[model, state] = Model(inputs.model);
cost = 0;
for i=1:length(modeledJointKinematics.position)
    temp.position = modeledJointKinematics.position(i, :);
    temp.velocity = modeledJointKinematics.velocity(i, :);
    temp.acceleration = modeledJointKinematics.acceleration(i, :);
    makeGCPState(model, state, temp, inputs.coordinateColumns)
    cost = cost + calcStateCost()
end
modelMarkerPositions = calcMarkerPositions();
modelSpringKinematics = calcSpringKinematics();
modelGroundReactForces = calcGroundReactionForce();
modelCenterOfPressure = calcCenterOfPressure();
modelFreeMoment = calcFreeMoment();

cost = calculateCost(modeledJointKinematics)

end

function calculateCost(modeledJointKinematics, values, fieldNameOrder, inputs, params)
[footMarkerPositionError, footMarkerSlopeError] = ...
    calcFootMarkerPositionAndSlopeError(modeledJointKinematics, inputs);
cost = 2 * footMarkerPositionError;
cost = [cost 1000 * footMarkerSlopeError];
cost = [cost 1000 * calcKinematicCurveSlopeError(modeledJointKinematics, inputs)];
[groundReactionForceValueError, groundReactionForceSlopeError] = ...
    calcGroundReactionForceAndSlopeError();
cost = [cost groundReactionForceValueError];
cost = [cost 1 / 5 * groundReactionForceSlopeError];
cost = [cost 1 / 100 * calcKValueFromMeanError()];
cost = [cost 100 * calcCValueFromMeanError()];
cost = [cost calcCDeviationFromInitialValueError()];
cost = [cost calcKDeviationFromInitialValueError()];
cost = [cost calcFootDistanceError()];
cost = cost / 10;
end

function modeledJointKinematics = makeModeledJointKinematics(N, ...
    bSplineCoefficients, experimentalJointKinematics)
qs = N*bSplineCoefficients;
modeledJointKinematics = experimentalJointKinematics;

if(size(qs, 2) == 5)
    modeledJointKinematics(:, 2) = modeledJointKinematics(:, 2) + qs(:, 1);
    modeledJointKinematics(:, 4:7) = modeledJointKinematics(:, 4:7) + qs(:, 2:5);
else
    modeledJointKinematics = modeledJointKinematics + qs;
end
end

function newValues = findValuesByFieldName(values, inputs, fieldName, ...
    fieldNameOrder)
start = 1;
for i = 1:find(strcmp(fieldName, fieldNameOrder))-1
    start = start + numel(inputs.(fieldNameOrder(i)));
end
newValues = values(start:start + numel(inputs.(fieldName)) - 1)
length(newValues)
end
