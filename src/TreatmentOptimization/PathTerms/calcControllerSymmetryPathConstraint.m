% This function is part of the NMSM Pipeline, see file for full license.
%
% This function calculates the symmetry of controls. 
%
% (2D matrix, Cell, Array of string) -> (Number)
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

function [pathTerm, constraintTerm] = ...
    calcControllerSymmetryPathConstraint( ...
    inputs, values, constraintTerm, values)
assert(length(constraintTerm.controllers) == 2, ...
    "controller_symmetry requires exactly two <controllers> to compare.")
[controls, constraintTerm] = findControlsByLabels(constraintTerm, ...
    inputs, values, values.time, constraintTerm.controllers);
baselineControl = controls(:, 1);
shiftedControl = controls(:, 2);
if valueOrAlternate(constraintTerm, 'apply_half_cycle_shift', true)
    shiftedControl = shiftSignalHalfCycle(shiftedControl, ...
    values.time);
end
pathTerm = shiftedControl - baselineControl;
end
