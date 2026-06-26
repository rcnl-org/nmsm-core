% This function is part of the NMSM Pipeline, see file for full license.
%
% This function calculates the model Joint moments for each muscle
%
% (Cell, Struct, num array) -> (num array, num array, num array, num array)
% returns muscle moments, forces, and lengths in TO indices

% ----------------------------------------------------------------------- %
% The NMSM Pipeline is a toolkit for model personalization and treatment  %
% optimization of neuromusculoskeletal models through OpenSim. See        %
% nmsm.rice.edu and the NOTICE file for more information. The             %
% NMSM Pipeline is developed at Rice University and supported by the US   %
% National Institutes of Health (R01 EB030520).                           %
%                                                                         %
% Copyright (c) 2021 Rice University and the Authors                      %
% Author(s): Spencer Williams                                             %
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

function muscleJointMoments = ...
    calcCasadiTreatmentOptimizationMuscleJointMoments(inputs, ...
    modeledValues,  momentArms)
maxIsometricForce = repmat(inputs.maxIsometricForce, ...
    size(modeledValues.muscleActivations, 1), 1);

activeForce = activeForceLengthCurve(modeledValues.normalizedFiberLength);

muscleVelocity = forceVelocityCurve(modeledValues.normalizedFiberVelocity);

passiveForce = passiveForceLengthCurve(modeledValues.normalizedFiberLength);

parallelComponentOfPennationAngle = repmat( ...
    cos(inputs.pennationAngle), ...
    size(modeledValues.muscleActivations, 1), 1);

if isa(activeForce, 'casadi.MX')
    muscleJointMoments = casadi.MX.zeros(size(activeForce, 1), ...
        length(inputs.surrogateModelIndex));
else
    muscleJointMoments = zeros(size(activeForce, 1), ...
        length(inputs.surrogateModelIndex));
end

for i = 1 : length(inputs.surrogateModelIndex)
    momentArmIndices = linspace(inputs.surrogateModelIndex(i), ...
        length(inputs.coordinateNames) * (size(activeForce, 2) - 1) + ...
        inputs.surrogateModelIndex(i), size(activeForce, 2));
    momentPerMuscle = momentArms(:, momentArmIndices) .* ...
        maxIsometricForce .* (modeledValues.muscleActivations .* ...
        activeForce .* muscleVelocity + passiveForce) .* ...
        parallelComponentOfPennationAngle;
    muscleJointMoments(:, i) = sum(momentPerMuscle, 2);
end
end
