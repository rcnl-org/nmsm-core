% This function is part of the NMSM Pipeline, see file for full license.
%
% This function checks a list of cost terms without touching the GUI,
% reporting whether at least one term is enabled and which enabled terms
% have a max allowable error that is not greater than zero.
%
% (Cell Array of RCNLCostTermClass) -> (logical, Array of double)
% Checks that cost terms are enabled and have valid max allowable errors

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
function [hasEnabledTerm, invalidIndices] = checkCostTermsValid(costTerms)
hasEnabledTerm = false;
invalidIndices = [];
for i = 1:length(costTerms)
    if isempty(costTerms{i}) || ~strcmp(costTerms{i}.is_enabled, 'true')
        continue
    end
    hasEnabledTerm = true;
    if costTerms{i}.max_allowable_error <= 0
        invalidIndices(end + 1) = i;
    end
end
end
