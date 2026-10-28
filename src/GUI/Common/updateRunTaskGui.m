% This function is part of the NMSM Pipeline, see file for full license.
%
% This function names the task under way in a GUI run, as "Task 2 of 5"
% under the current stage. A task can run for a long time with nothing
% else to show for it. The tools are normally called from a script with no
% GUI, so an empty or deleted app, or one with no task display, is ignored.
%
% (App, double, double) -> ()
% Shows which task of a GUI run is under way

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
function updateRunTaskGui(app, task, taskCount)
if isempty(app) || ~isobject(app) || ~isvalid(app) || ...
        ~ismethod(app, "updateTaskProgress")
    return
end
app.updateTaskProgress(task, taskCount);
end
