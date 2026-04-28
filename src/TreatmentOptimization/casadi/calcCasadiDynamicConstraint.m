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

% Determine number of quantities for dynamic constraint
if inputs.useJerk
    numStateConstraints = size(values.statePositions, 2) * 3;
else
    numStateConstraints = size(values.statePositions, 2) * 2;
end
numControlConstraints = 0;
if inputs.useControlDynamicsFilter
    if inputs.controllerTypes(4)
        numControlConstraints = numControlConstraints + ...
            size(values.userDefinedControlDerivatives, 2);
    end
    if inputs.controllerTypes(3)
        numControlConstraints = numControlConstraints + ...
            size(values.controlMuscleActivationDerivatives, 2);
    end
    if inputs.controllerTypes(2)
        numControlConstraints = numControlConstraints + ...
            size(values.controlSynergyActivationDerivatives, 2);
    end
    if inputs.controllerTypes(1)
        numControlConstraints = numControlConstraints + ...
            size(values.torqueControlDerivatives, 2);
    end
end

% Check type of state positions so that dynamics will have the same type.
% This is an object-oriented programming sort of function, so use this
% carefully in Matlab.
if isa(values.statePositions, 'casadi.MX')
    dynamics = casadi.MX.zeros(inputs.numMeshes * ...
        inputs.numCollocationPerMesh, ...
        numStateConstraints + numControlConstraints);
else
    dynamics = zeros(inputs.numMeshes * inputs.numCollocationPerMesh, ...
        numStateConstraints + numControlConstraints);
end
index = 0;
dynamicsIndex = 1;
for i = 1 : inputs.numMeshes
    dynamics(index + 1 : ...
        index + inputs.numCollocationPerMesh, dynamicsIndex:size(values.statePositions, 2)) = ...
        collocationCoefficients * values.statePositions(index + 1 : ...
        index + inputs.numCollocationPerMesh + 1, :) - ...
        values.stateVelocities(index + 2 : ...
        index + inputs.numCollocationPerMesh + 1, :) * meshDuration;
    index = index + inputs.numCollocationPerMesh;
end
dynamicsIndex = dynamicsIndex + size(values.statePositions, 2);
index = 0;
for i = 1 : inputs.numMeshes
    dynamics(index + 1 : ...
        index + inputs.numCollocationPerMesh, ...
        dynamicsIndex:size(values.statePositions, 2) + dynamicsIndex - 1) = ...
        (collocationCoefficients * values.stateVelocities(index + 1 : ...
        index + inputs.numCollocationPerMesh + 1, :) - ...
        values.controlAccelerations(index + 2 : ...
        index + inputs.numCollocationPerMesh + 1, :) * meshDuration) / 10;
    index = index + inputs.numCollocationPerMesh;
end
dynamicsIndex = dynamicsIndex + size(values.statePositions, 2);

if inputs.useJerk
    index = 0;
    for i = 1 : inputs.numMeshes
        dynamics(index + 1 : ...
            index + inputs.numCollocationPerMesh, ...
            dynamicsIndex:size(values.statePositions, 2) + dynamicsIndex - 1) = ...
            (collocationCoefficients * values.controlAccelerations(index + 1 : ...
            index + inputs.numCollocationPerMesh + 1, :) - ...
            values.controlJerks(index + 2 : ...
            index + inputs.numCollocationPerMesh + 1, :) * meshDuration) / 100;
        index = index + inputs.numCollocationPerMesh;
    end
    dynamicsIndex = dynamicsIndex + size(values.statePositions, 2);
end

if inputs.useControlDynamicsFilter
    if inputs.controllerTypes(4)
        index = 0;
        for i = 1 : inputs.numMeshes
            meshIndices1 = index + 1 : ...
                index + inputs.numCollocationPerMesh + 1;
            meshIndices2 = index + 2 : ...
                index + inputs.numCollocationPerMesh + 1;
            dynamics(index + 1 : ...
                index + inputs.numCollocationPerMesh, ...
                dynamicsIndex:size(values.userDefinedControlDerivatives, 2) + dynamicsIndex - 1) = ...
                (collocationCoefficients * values.userDefinedControls(meshIndices1, :) - ...
                ((values.userDefinedControlDerivatives(meshIndices2, :) - ...
                values.userDefinedControls(meshIndices2, :)) / ...
                inputs.controlDynamicsFilterConstant) * meshDuration) / 100;
            index = index + inputs.numCollocationPerMesh;
        end
        dynamicsIndex = dynamicsIndex + size(values.userDefinedControlDerivatives, 2);
    end
    if inputs.controllerTypes(3)
        index = 0;
        for i = 1 : inputs.numMeshes
            meshIndices1 = index + 1 : ...
                index + inputs.numCollocationPerMesh + 1;
            meshIndices2 = index + 2 : ...
                index + inputs.numCollocationPerMesh + 1;
            dynamics(index + 1 : ...
                index + inputs.numCollocationPerMesh, ...
                dynamicsIndex:size(values.controlMuscleActivationDerivatives, 2) + dynamicsIndex - 1) = ...
                (collocationCoefficients * values.controlMuscleActivations(meshIndices1, :) - ...
                ((values.controlMuscleActivationDerivatives(meshIndices2, :) - ...
                values.controlMuscleActivations(meshIndices2, :)) / ...
                inputs.controlDynamicsFilterConstant) * meshDuration) / 100;
            index = index + inputs.numCollocationPerMesh;
        end
        dynamicsIndex = dynamicsIndex + size(values.controlMuscleActivationDerivatives, 2);
    end
    if inputs.controllerTypes(2)
        index = 0;
        for i = 1 : inputs.numMeshes
            meshIndices1 = index + 1 : ...
                index + inputs.numCollocationPerMesh + 1;
            meshIndices2 = index + 2 : ...
                index + inputs.numCollocationPerMesh + 1;
            dynamics(index + 1 : ...
                index + inputs.numCollocationPerMesh, ...
                dynamicsIndex:size(values.controlSynergyActivationDerivatives, 2) + dynamicsIndex - 1) = ...
                (collocationCoefficients * values.controlSynergyActivations(meshIndices1, :) - ...
                ((values.controlSynergyActivationDerivatives(meshIndices2, :) - ...
                values.controlSynergyActivations(meshIndices2, :)) / ...
                inputs.controlDynamicsFilterConstant) * meshDuration) / 100;
            index = index + inputs.numCollocationPerMesh;
        end
        dynamicsIndex = dynamicsIndex + size(values.controlSynergyActivationDerivatives, 2);
    end
    if inputs.controllerTypes(1)
        index = 0;
        for i = 1 : inputs.numMeshes
            meshIndices1 = index + 1 : ...
                index + inputs.numCollocationPerMesh + 1;
            meshIndices2 = index + 2 : ...
                index + inputs.numCollocationPerMesh + 1;
            dynamics(index + 1 : ...
                index + inputs.numCollocationPerMesh, ...
                dynamicsIndex:size(values.torqueControlDerivatives, 2) + dynamicsIndex - 1) = ...
                (collocationCoefficients * values.torqueControls(meshIndices1, :) - ...
                ((values.torqueControlDerivatives(meshIndices2, :) - ...
                values.torqueControls(meshIndices2, :)) / ...
                inputs.controlDynamicsFilterConstant) * meshDuration) / 100;
            index = index + inputs.numCollocationPerMesh;
        end
        dynamicsIndex = dynamicsIndex + size(values.torqueControlDerivatives, 2);
    end
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
