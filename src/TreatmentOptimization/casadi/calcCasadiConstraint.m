% This function is part of the NMSM Pipeline, see file for full license.
%
% This function computes path constraints (if any) for a CasADi problem
%
% (struct) -> (struct)
%

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

function [constraint, constraints] = calcCasadiConstraint(constraints, ...
    constraintTermCalculations, allowedTypes, values, modeledValues, ...
    inputs, supportAD)
constraint = [];
for i = 1:length(constraints)
    constraintTerm = constraints{i};
    if constraintTerm.isEnabled
        nameMatch = ismember(allowedTypes, constraintTerm.type);
        if isfield(constraintTermCalculations, constraintTerm.type) && ...
                any(nameMatch)
            if supportAD(nameMatch)
                fn = constraintTermCalculations.(constraintTerm.type);
                try
                    [newConstraint, constraints{i}] = ...
                        fn(values, modeledValues, inputs, constraintTerm);
                catch
                    newConstraint = fn(values, modeledValues, inputs, ...
                        constraintTerm);
                end
%                 constraint = cat(2, constraint, newConstraint);
                constraint = [constraint, newConstraint];
            else
                if length(values.time) == 2
                    constraintLength = 1;
                else
                    constraintLength = length(values.time);
                end
                if isa(values.statePositions, 'casadi.MX')
                    constraint = [constraint, casadi.MX.zeros(constraintLength, 1)];
                else
                    constraint = [constraint, zeros(constraintLength, 1)];
%                 constraint = cat(2, constraint, ...
%                     zeros(length(values.time), 1));
                end
            end
        else
%             throw(MException('ConstraintTerms:IllegalTerm', ...
%                 strcat("Constraint term ",  constraintTerm.type, ...
%                 " is not allowed for this tool")))
        end
    end
end
end
