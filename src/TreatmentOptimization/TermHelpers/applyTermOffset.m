% This function is part of the NMSM Pipeline, see file for full license.
%
% (struct, Array of number) -> (Array of number)
%
% Applies the optional <offset> field of a cost or constraint term to the
% experimental data tracked by that term. The offset is a constant added to
% the experimental data before the error is calculated, allowing a term to
% track experimental data with a known, constant shift.

% ----------------------------------------------------------------------- %
% The NMSM Pipeline is a toolkit for model personalization and treatment  %
% optimization of neuromusculoskeletal models through OpenSim. See        %
% nmsm.rice.edu and the NOTICE file for more information. The             %
% NMSM Pipeline is developed at Rice University and supported by the US   %
% National Institutes of Health (R01 EB030520).                           %
%                                                                         %
% Copyright (c) 2021 Rice University and the Authors                      %
% Author(s): Robert Salati                                                %
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

function experimentalValues = applyTermOffset(term, experimentalValues)
if ~isfield(term, "offset")
    return
end
assert(isnumeric(term.offset) && isscalar(term.offset), term.type + ...
    " requires <offset> to be a single number. Use one term per " + ...
    "offset value.");
experimentalValues = experimentalValues + term.offset;
end
