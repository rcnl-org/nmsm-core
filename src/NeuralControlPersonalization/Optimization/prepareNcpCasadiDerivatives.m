% This function is part of the NMSM Pipeline, see file for full license.
%
% Builds the CasADi symbolic cost/constraint graph ONCE for the current
% NCP problem and compiles casadi.Function objects for exact
% cost/gradient, constraint/Jacobian, and the Hessian of the Lagrangian.
% Returns plain MATLAB closures ready for fmincon's
% SpecifyObjectiveGradient/SpecifyConstraintGradient/HessianFcn options
% (interior-point algorithm required).
%
% The objective Hessian is assembled from first-order derivatives of the
% residual rather than from a full second-order graph (see below); the
% result is exact, not a Gauss-Newton approximation. The weight
% normalization constraint is a sum of squares of design variables, so its
% value, Jacobian, and (constant) Hessian are formed analytically in
% MATLAB instead of symbolically.
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

% SX rather than MX. SX differentiates the scalarized graph directly
x = SX.sym('x', numDesignVariables);

if ~inputs.optimize_synergy_vectors
    fullValues = [inputs.fixedSynergyVectorFlat; x];
elseif inputs.enforce_bilateral_symmetry
    weightsPart = x(1:inputs.numWeightsPerGroup(1));
    fullValues = [weightsPart; x];
else
    fullValues = x;
end

[objective, residual] = calcCasadiNcpCost(fullValues, inputs, params);

costAndGradientFn = Function('ncpCostAndGradient', {x}, ...
    {objective, gradient(objective, x)});

% Every cost term is a sum of squares, so with r the stacked scaled
% residual and J its Jacobian,
%
%   f = r'r   =>   d2f/dx2 = 2 * (J'J + sum_k r_k * d2(r_k)/dx2)
%
% and the second term is hessian(lambda'*r, x) evaluated at lambda = r.
% Building those two pieces costs a first-order Jacobian plus the Hessian
% of a bilinear form, which are cheaper to construct and evaluate
residualJacobianFn = Function('ncpResidualJacobian', {x}, ...
    {residual, jacobian(residual, x)});
residualWeights = SX.sym('residualWeights', residual.size1());
% x stays an input because the curvature term is only independent of it
% while every residual is bilinear in (weights, commands)
residualCurvatureFn = Function('ncpResidualCurvature', ...
    {x, residualWeights}, {hessian(residualWeights.' * residual, x)});

derivatives.costFcn = @(values) evalCostAndGradient( ...
    costAndGradientFn, values);
objectiveHessianFcn = @(values) evalObjectiveHessian( ...
    residualJacobianFn, residualCurvatureFn, values);

if ~isempty(normalizationTarget)
    % ceq_i = sum_m weights(i, m)^2 - target_i, and every weight enters
    % exactly one ceq_i, so the constraint, its Jacobian, and its Hessian
    % are all known in closed form. Building them in MATLAB rather than
    % CasADi keeps the weight->activation subgraph out of Hessian
    weightIndices = findConstrainedWeightIndices(inputs);
    target = normalizationTarget(1:length(weightIndices));
    derivatives.constraintFcn = @(values) evalConstraint(values, ...
        weightIndices, target);
    derivatives.hessianFcn = @(values, lambdaStruct) ...
        objectiveHessianFcn(values) + makeConstraintHessian( ...
        weightIndices, lambdaStruct.eqnonlin, numDesignVariables);
else
    derivatives.constraintFcn = [];
    derivatives.hessianFcn = @(values, lambdaStruct) ...
        objectiveHessianFcn(values);
end
fprintf('CasADi setup done! Time=%.2fs\n', toc(setupTic));
end

% Design variable indices of the weights in each normalization-constrained
% synergy. Under bilateral symmetry only the first group's synergies are
% constrained, and its weights are the leading design variables, so the
% design variable index equals the fullValues index in both cases.
% (struct) -> (Array of cell)
function weightIndices = findConstrainedWeightIndices(inputs)
if inputs.enforce_bilateral_symmetry
    constrainedGroups = inputs.synergyGroups(1);
else
    constrainedGroups = inputs.synergyGroups;
end
numConstraints = sum(cellfun(@(group) group.numSynergies, ...
    constrainedGroups));
weightIndices = cell(1, numConstraints);
index = 1;
constraint = 1;
for i = 1:length(constrainedGroups)
    numMuscleGroup = length(constrainedGroups{i}.muscleNames);
    for j = 1:constrainedGroups{i}.numSynergies
        weightIndices{constraint} = (index : index + numMuscleGroup - 1).';
        index = index + numMuscleGroup;
        constraint = constraint + 1;
    end
end
end

% Sum_i lambda_i * d2(ceq_i)/dx2 = 2 * lambda_i on the diagonal entries
% belonging to synergy i, since the index sets are disjoint.
% (Array of cell, Array of number, number) -> (Array of number)
function constraintHessian = makeConstraintHessian(weightIndices, ...
    lambda, numDesignVariables)
diagonal = zeros(numDesignVariables, 1);
for i = 1:length(weightIndices)
    diagonal(weightIndices{i}) = 2 * lambda(i);
end
constraintHessian = spdiags(diagonal, 0, numDesignVariables, ...
    numDesignVariables);
end

function [cost, grad] = evalCostAndGradient(fn, values)
[costOut, gradOut] = fn(values);
cost = full(costOut);
grad = full(gradOut);
end

% d2f/dx2 = 2 * (J'J + sum_k r_k * d2(r_k)/dx2) for f = r'r. Kept sparse
% because fmincon's interior-point algorithm exploits sparsity directly
% instead of factorizing a dense matrix.
% (casadi.Function, casadi.Function, Array of number) -> (Array of number)
function objectiveHessian = evalObjectiveHessian(residualJacobianFn, ...
    residualCurvatureFn, values)
[residualValue, jacobianValue] = residualJacobianFn(values);
residualValue = full(residualValue);
jacobianValue = sparse(jacobianValue);
objectiveHessian = 2 * (jacobianValue.' * jacobianValue + ...
    sparse(residualCurvatureFn(values, residualValue)));
end

function [c, ceq, gc, gceq] = evalConstraint(values, weightIndices, target)
c = [];
gc = [];
numConstraints = length(weightIndices);
ceq = zeros(numConstraints, 1);
rows = cell(1, numConstraints);
columns = cell(1, numConstraints);
entries = cell(1, numConstraints);
for i = 1:numConstraints
    synergyWeights = values(weightIndices{i});
    ceq(i) = sum(synergyWeights .^ 2) - target(i);
    rows{i} = weightIndices{i};
    columns{i} = repmat(i, length(synergyWeights), 1);
    entries{i} = 2 * synergyWeights;
end
% fmincon expects transposed (numDesignVariables x numConstraints) Jacobian
gceq = sparse(vertcat(rows{:}), vertcat(columns{:}), vertcat(entries{:}), ...
    length(values), numConstraints);
end

