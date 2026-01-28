% This function is part of the NMSM Pipeline, see file for full license.
%
% This function builds a cell array of RCNLCostTermClass objects from a
% struct of cost term defaults. Each field of the defaults struct is a
% cost term type mapped to a cell array of {is_enabled, error_center,
% max_allowable_error, uses_error_center}.
%
% (struct) -> (Cell Array of RCNLCostTermClass)
% Builds default cost term objects from a cost term defaults struct

% ----------------------------------------------------------------------- %
% The NMSM Pipeline is a toolkit for model personalization and treatment  %
% optimization of neuromusculoskeletal models through OpenSim. See        %
% nmsm.rice.edu and the NOTICE file for more information. The             %
% NMSM Pipeline is developed at Rice University and supported by the US   %
% National Institutes of Health (R01 EB030520).                           %
%                                                                         %
% Copyright (c) 2026 Rice University and the Authors                      %
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
function costTerms = makeDefaultCostTerms(costTermDefaults)
costTermNames = fieldnames(costTermDefaults);
costTerms = cell(1, length(costTermNames));
for i = 1:length(costTermNames)
    defaults = costTermDefaults.(costTermNames{i});
    costTerm = RCNLCostTermClass();
    costTerm.is_enabled = defaults{1};
    costTerm.type = costTermNames{i};
    costTerm.error_center = defaults{2};
    costTerm.max_allowable_error = defaults{3};
    costTerm.uses_error_center = defaults{4};
    costTerms{i} = costTerm;
end
end
