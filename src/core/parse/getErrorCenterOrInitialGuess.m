% This function is part of the NMSM Pipeline, see file for full license.
%
% Deviation cost terms penalize a design variable's distance from a target.
% The target is the cost term's error center when one is given, and the
% initial guess when it is not. A cost term built without
% parseRcnlCostTermSet has no hasErrorCenter field, so its errorCenter is
% used whenever it is present and not NaN.
%
% (struct, Array of number) -> (Array of number)
% returns the error center if given, otherwise the initial guess

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

function target = getErrorCenterOrInitialGuess(costTerm, initialGuess)
if isfield(costTerm, "hasErrorCenter")
    hasErrorCenter = costTerm.hasErrorCenter;
else
    hasErrorCenter = isfield(costTerm, "errorCenter") && ...
        ~isnan(costTerm.errorCenter);
end
if hasErrorCenter
    target = costTerm.errorCenter;
else
    target = initialGuess;
end
end
