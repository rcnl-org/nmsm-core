% This function is part of the NMSM Pipeline, see file for full license.
%
% This function calculates the sum of squared errors between two synergy 
% vectors.
%
% (Array of number, struct, Array of string) -> (Number)
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

function [constraint, constraintTerm] = ...
    calcSynergyVectorSymmetryConstraint( ...
    constraintTerm, synergyWeights, inputs, synergyNames)
assert(length(synergyNames) == 2, "synergy_vector_symmetry requires " + ...
    "exactly two <synergies> to compare.")

[synergyIndices, constraintTerm] = findSynergyIndexByLabel( ...
    constraintTerm, inputs, synergyNames);
[weightIndices, constraintTerm] = findSynergyWeightIndicesByIndex( ...
    constraintTerm, inputs);

vector1 = synergyWeights(synergyIndices(1), weightIndices{1}(1) : ...
    weightIndices{1}(2));
vector2 = synergyWeights(synergyIndices(2), weightIndices{2}(1) : ...
    weightIndices{2}(2));
assert(length(vector1) == length(vector2), "synergy_vector_symmetry " + ...
    "must compare vectors of the same length.")

vectorDifference = abs(vector1 - vector2);
factor = 700 / max(max(abs(inputs.initialSynergyWeights)));
% Try soft maximum function. If it goes to infinity, use a smaller factor.
constraint = log(sum(exp(factor * vectorDifference))) / factor;
if isinf(constraint)
    constraint = log(sum(exp(factor / 10 * vectorDifference))) / ...
        (factor / 10);
end
end
