% This function is part of the NMSM Pipeline, see file for full license.
%
% There are multiple controllers that can be used to solve optimal control
% problems in the NMSM Pipeline. This function parses the muscle
% controller settings inside <RCNLUserDefinedController>
%
% (struct) -> (struct)
% parses user-defined controller settings from XML tree

% ----------------------------------------------------------------------- %
% The NMSM Pipeline is a toolkit for model personalization and treatment  %
% optimization of neuromusculoskeletal models through OpenSim. See        %
% nmsm.rice.edu and the NOTICE file for more information. The             %
% NMSM Pipeline is developed at Rice University and supported by the US   %
% National Institutes of Health (R01 EB030520).                           %
%                                                                         %
% Copyright (c) 2025 Rice University and the Authors                      %
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

function inputs = parseUserDefinedController(tree, inputs)
inputs.userDefinedControlLabels = parseSpaceSeparatedList(tree, ...
    "control_labels");
inputs.numUserDefinedControls = length(inputs.userDefinedControlLabels);
userControlMaxValues = str2double(parseSpaceSeparatedList(tree, ...
    "control_maximum_values"));
inputs = setupBounds(inputs, userControlMaxValues, "userControlMaxValues");
userControlMinValues = str2double(parseSpaceSeparatedList(tree, ...
    "control_minimum_values"));
inputs = setupBounds(inputs, userControlMinValues, "userControlMinValues");
end

function inputs = setupBounds(inputs, bounds, field)
if length(bounds) == 1
    inputs.(field) = repmat(bounds, 1, inputs.numUserDefinedControls);
elseif length(bounds) == inputs.numUserDefinedControls
    inputs.(field) = bounds;
else
    error("User-defined control bounds do not match the number of user-defined controls.")
end
end
