% This function is part of the NMSM Pipeline, see file for full license.
%
% This function fills the max allowable error and error center edit
% fields from the selected cost term, enabling the error center field
% only for cost term types that use one. Pass an empty error center
% field for panels without one.
%
% (RCNLCostTermClass, NumericEditField, NumericEditField) -> ()
% Fills cost term detail fields from the selected cost term

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
function showCostTermGui(costTerm, maxAllowableErrorField, errorCenterField)
maxAllowableErrorField.Value = costTerm.max_allowable_error;
if isempty(errorCenterField)
    return
end
errorCenterField.Value = costTerm.error_center;
errorCenterField.Enable = costTerm.uses_error_center;
end
