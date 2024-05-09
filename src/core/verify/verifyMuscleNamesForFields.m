% This function is part of the NMSM Pipeline, see file for full license.
%
% This function verifies that the strings in the input array are all valid
% Matlab variable names. If any names are invalid, users will need to
% change muscle names in their .osim model for it to be compatible with the
% pipeline. 
%
% (Array of string) -> ()
% returns nothing or throws an error if muscle names are invalid

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

function verifyMuscleNamesForFields(names)
for name = names
    assert(isvarname(name), "Muscle name " + name + " is not" + ...
        " a valid MATLAB variable name. Variable names must contain " + ...
        "only letters, numbers, and underscores, cannot start with a" + ...
        " number, and must be fewer than 64 characters. This muscle " + ...
        "should be renamed to be compatible with the NMSM Pipeline. ")
end
end
