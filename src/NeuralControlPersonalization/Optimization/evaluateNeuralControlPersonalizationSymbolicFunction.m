% This function is part of the NMSM Pipeline, see file for full license.
%
% This function evaluates the Neural Control Personalization model,
% including any necessary costs and constraints for the optimizer. 
%
% (casadi.MX, casadi.MX, casadi.MX) -> (casadi.MX, casadi.MX, ...
% casadi.MX, casadi.MX)
% Evaluates symbolic function for Neural Control Personalization. 

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

function [dynamics, inequalityConstraints, equalityConstraints, ...
    objective] = evaluateNeuralControlPersonalizationSymbolicFunction( ...
    weights, commandsState, commandsControl)
persistent inputs
persistent params
% If only two arguments were given, this initializes the function instead
% of evaluating with variables. This is a workaround as structs cannot be
% passed directly to a CasADi symbolic function being used in an
% optimization.
if nargin == 2
    inputs = weights;
    params = commandsState;
    return
end

% Calculate modeled values TODO
weightsMatrix = casadi.MX.zeros(inputs.weightMatrixDimensions);
weightsMatrix(inputs.weightMatrixMap) = weights;
activations = casadi.MX.zeros(size(weightsMatrix, 1) * ...
    inputs.numTrials, size(commandsState, 2));
for i = 1 : inputs.numTrials
    activations((i - 1) * size(weightsMatrix, 1) + 1 : ...
        i * size(weightsMatrix, 1), :) = weightsMatrix * ...
        commandsState((i - 1) * size(weightsMatrix, 2) + 1 : ...
        i * size(weightsMatrix, 2), :);
end

% Dynamic constraint
dynamics = calcNcpDynamicConstraint(commandsState, commandsControl, ...
    inputs, params);

% Inequality constraints
inequalityConstraints = activations - 1;

% Equality constraints
equalityConstraints = casadi.MX.zeros(size(inputs.weightVectorLengths));
index = 0;
for i = 1 : length(inputs.weightVectorLengths)
    equalityConstraints(i) = ...
        sum(weights(index + 1 : index + inputs.weightVectorLengths(i))) ...
        - inputs.weightVectorLengths(i) / 10;
    index = index + inputs.weightVectorLengths(i);
end

% Cost function TODO
[continuousCost, discreteCost] = calcCasadiNcpCost(activations, inputs, ...
    params, weights);
integratedCost = integrateRadauQuadrature(continuousCost, params, ...
    inputs.collocationTime);
objective = (sum(integratedCost / ...
    (inputs.collocationTime(end) - inputs.collocationTime(1))) + ...
    sum(discreteCost)) / (length(integratedCost) + length(discreteCost));
end
