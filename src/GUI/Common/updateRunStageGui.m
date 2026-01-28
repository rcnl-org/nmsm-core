% This function is part of the NMSM Pipeline, see file for full license.
%
% This function turns one stage label of a run dialog on or off. The tools
% are normally called from a script with no GUI, so an empty or deleted app
% and a label the dialog does not define are all ignored rather than
% treated as errors. This keeps the progress reporting in the tools to a
% single line per stage.
%
% (App, string, char) -> ()
% Enables or disables a run dialog's stage label

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
function updateRunStageGui(app, labelName, state)
if isempty(app) || ~isvalid(app) || ~isprop(app, labelName)
    return
end
app.(labelName).Enable = state;
drawnow
end
