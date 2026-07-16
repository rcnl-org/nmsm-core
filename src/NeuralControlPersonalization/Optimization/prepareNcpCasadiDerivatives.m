% This function is part of the NMSM Pipeline, see file for full license.
%
% Builds the CasADi symbolic cost/constraint graph ONCE for the current
% NCP problem and compiles casadi.Function objects for exact
% cost/gradient, constraint/Jacobian, and the Hessian of the Lagrangian.
% Returns plain MATLAB closures ready for fmincon's
% SpecifyObjectiveGradient/SpecifyConstraintGradient/HessianFcn options
% (interior-point algorithm required).
%
% normalizationTarget: (numSynergies x 1), or [] when the 'sum'
% normalization method is used (no nonlinear equality constraint in that
% case, so the Hessian reduces to the objective's Hessian alone since
% linear constraints contribute no curvature).
%
% (struct, struct, number, Array of number) -> (struct)

% ----------------------------------------------------------------------- %
% The NMSM Pipeline is a toolkit for model personalization and treatment  %
% optimization of neuromusculoskeletal models through OpenSim. See        %
% nmsm.rice.edu and the NOTICE file for more information. The             %
% NMSM Pipeline is developed at Rice University and supported by the US   %
% National Institutes of Health (R01 EB030520).                           %
%                                                                         %
% Copyright (c) 2021 Rice University and the Authors                      %
% Author(s): Xuanning Liu                                                 %
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

function derivatives = prepareNcpCasadiDerivatives(inputs, params, ...
    numDesignVariables, normalizationTarget)
fprintf('Setting up CasADi ...\n');
setupTic = tic;
import casadi.*

x = MX.sym('x', numDesignVariables);

if inputs.enforce_bilateral_symmetry
    weightsPart = x(1:inputs.numWeightsPerGroup(1));
    fullValues = [weightsPart; x];
else
    fullValues = x;
end

objective = calcCasadiNcpCost(fullValues, inputs, params);
objectiveGradient = gradient(objective, x);

if ~isempty(normalizationTarget)
    [~, weights] = calcCasadiActivationsFromSynergyDesignVariables( ...
        fullValues, inputs);
    if inputs.enforce_bilateral_symmetry
        nSyn1 = inputs.synergyGroups{1}.numSynergies;
        ceq = sum(weights(1:nSyn1, :) .^ 2, 2) - ...
            normalizationTarget(1:nSyn1);
    else
        ceq = sum(weights .^ 2, 2) - normalizationTarget;
    end
    ceqJacobian = jacobian(ceq, x);
    lambda = MX.sym('lambda', size(ceq, 1));
    lagrangianHessian = hessian(objective + lambda.' * ceq, x);

    constraintFn = Function('ncpConstraint', {x}, {ceq, ceqJacobian});
    hessianFn = Function('ncpLagrangianHessian', {x, lambda}, ...
        {lagrangianHessian});

    derivatives.constraintFcn = @(values) evalConstraint( ...
        constraintFn, values);
    % sparse Hessian: fmincon's interior-point algorithm exploits this
    % directly instead of factorizing a dense matrix
    derivatives.hessianFcn = @(values, lambdaStruct) sparse(hessianFn( ...
        values, lambdaStruct.eqnonlin));
else
    lagrangianHessian = hessian(objective, x);
    hessianFn = Function('ncpObjectiveHessian', {x}, {lagrangianHessian});

    derivatives.constraintFcn = [];
    derivatives.hessianFcn = @(values, lambdaStruct) sparse(hessianFn(values));
end

costAndGradientFn = Function('ncpCostAndGradient', {x}, ...
    {objective, objectiveGradient});
derivatives.costFcn = @(values) evalCostAndGradient( ...
    costAndGradientFn, values);
fprintf('CasADi setup done! Time=%.2fs\n', toc(setupTic));
end

function [cost, grad] = evalCostAndGradient(fn, values)
[costOut, gradOut] = fn(values);
cost = full(costOut);
grad = full(gradOut);
end

function [c, ceq, gc, gceq] = evalConstraint(fn, values)
[ceqOut, jacOut] = fn(values);
c = [];
ceq = full(ceqOut);
gc = [];
gceq = sparse(jacOut).'; % sparse Jacobian
end

