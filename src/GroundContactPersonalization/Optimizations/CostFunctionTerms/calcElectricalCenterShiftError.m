% This function is part of the NMSM Pipeline, see file for full license.
%
%
%
% (struct, struct, struct) -> (Array of double)
% Calculate error between experimental and adjusted electrical center. 

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

function errors = calcElectricalCenterShiftError(inputs, values, costTerm)
errors = zeros(1, 3 * length(inputs.surfaces));
if isfield(costTerm, 'axes')
    axes = [contains(lower(costTerm.axes), 'x'), ...
        contains(lower(costTerm.axes), 'y'), ...
        contains(lower(costTerm.axes), 'z')];
else
    axes = true(1, 3);
end
index = 1;
for i = 1 : length(inputs.surfaces)
    if axes(1)
        field = "electricalCenterX" + i;
        errors(index) = values.(field);
    end
    index = index + 1;
    if axes(2)
        field = "electricalCenterY" + i;
        errors(index) = values.(field);
    end
    index = index + 1;
    if axes(3)
        field = "electricalCenterZ" + i;
        errors(index) = values.(field);
    end
    index = index + 1;
end
end
