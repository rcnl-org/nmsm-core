% This function is part of the NMSM Pipeline, see file for full license.
%
%
% (casadi.MX, casadi.MX, struct, struct) -> (casadi.MX)
% Calculate dynamic constraint for CasADi NCP. 

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
function dynamics = calcNcpDynamicConstraint(commandsState, ...
    commandsControl, inputs, params)
persistent collocationCoefficients;
if isempty(collocationCoefficients)
    collocationCoefficients = calcCollocationCoefficients( ...
        params.numCollocationPerMesh);
    collocationCoefficients = collocationCoefficients(:, 2:end)';
end
meshDuration = (inputs.collocationTime(end) - ...
    inputs.collocationTime(1)) / params.numMeshes;

commandsState = commandsState';
commandsControl = commandsControl';

if isa(commandsState, 'casadi.MX')
    dynamics = casadi.MX.zeros(params.numMeshes * ...
        params.numCollocationPerMesh, size(commandsState, 2));
else
    dynamics = zeros(params.numMeshes * params.numCollocationPerMesh, ...
        size(commandsState, 2));
end

index = 0;
dynamicsIndex = 0;
for i = 1 : params.numMeshes
    dynamics(dynamicsIndex + 1 : ...
        dynamicsIndex + params.numCollocationPerMesh, :) = ...
        collocationCoefficients * commandsState(index + 1 : ...
        index + params.numCollocationPerMesh + 1, :) - ...
        commandsControl(index + 2 : ...
        index + params.numCollocationPerMesh + 1, :) * meshDuration;
    index = index + params.numCollocationPerMesh;
    dynamicsIndex = dynamicsIndex + params.numCollocationPerMesh;
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
