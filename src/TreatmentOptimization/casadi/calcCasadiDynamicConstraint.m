% This function is part of the NMSM Pipeline, see file for full license.
%
%
% (struct, struct) -> (Array of double)
%

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

function dynamics = calcCasadiDynamicConstraint(values, inputs)
persistent collocationCoefficients;
if isempty(collocationCoefficients)
    collocationCoefficients = calcCollocationCoefficients( ...
        inputs.numCollocationPerMesh);
    collocationCoefficients = collocationCoefficients(:, 2:end)';
end
meshDuration = (values.time(end) - values.time(1)) / inputs.numMeshes;

dynamics = zeros(inputs.numMeshes * inputs.numCollocationPerMesh * 2, 1);
index = 0;
dynamicsIndex = 0;
for i = 1 : inputs.numMeshes
    dynamics(dynamicsIndex + 1 : ...
        dynamicsIndex + inputs.numCollocationPerMesh) = ...
        collocationCoefficients * values.statePositions(index + 1 : ...
        index + inputs.numCollocationPerMesh + 1) - ...
        values.stateVelocities(index + 2 : ...
        index + inputs.numCollocationPerMesh + 1) * meshDuration;
    index = index + inputs.numCollocationPerMesh;
    dynamicsIndex = dynamicsIndex + inputs.numCollocationPerMesh;
end
index = 0;
for i = 1 : inputs.numMeshes
    dynamics(dynamicsIndex + 1 : ...
        dynamicsIndex + inputs.numCollocationPerMesh) = ...
        collocationCoefficients * values.stateVelocities(index + 1 : ...
        index + inputs.numCollocationPerMesh + 1) - ...
        values.controlAccelerations(index + 2 : ...
        index + inputs.numCollocationPerMesh + 1) * meshDuration;
    index = index + inputs.numCollocationPerMesh;
    dynamicsIndex = dynamicsIndex + inputs.numCollocationPerMesh;
end
end

% Method based on code by Antoine Falisse
% https://github.com/KULeuvenNeuromechanics/PredSim/blob/master/OCP/CollocationScheme.m
function collocationCoefficients = calcCollocationCoefficients(order)
root = [0, casadi.collocation_points(order, 'radau')];
collocationCoefficients = zeros(order + 1, order + 1);

for i = 1 : order + 1
    coefficients = 1;
    for j = 1 : order + 1
        if i ~= j
            coefficients = conv(coefficients, [1, -root(j)]);
            coefficients = coefficients / (root(i) - root(j));
        end
    end

    derivative = polyder(coefficients);
    for j = 1 : order + 1
        collocationCoefficients(i, j) = polyval(derivative, root(j));
    end
end
end
