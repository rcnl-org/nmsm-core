% This function is part of the NMSM Pipeline, see file for full license.
%
% This function fills a task list GUI table with each task's enabled
% state and name, followed by a row inviting the user to add a new entry.
% The column names isEnabled and taskNames are relied on by the tables'
% cell edit callbacks.
%
% (Table, Cell Array of task objects, string) -> ()
% Fills a task list GUI table from a list of tasks

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
function updateTaskListTableGui(taskTable, tasks, addRowText)
if nargin < 3
    addRowText = "Add a new task";
end
isEnabled = true(length(tasks) + 1, 1);
taskNames = strings(length(tasks) + 1, 1);
for i = 1:length(tasks)
    isEnabled(i) = strcmp(tasks{i}.is_enabled, 'true');
    taskNames(i) = tasks{i}.name;
end
isEnabled(end) = false;
taskNames(end) = addRowText;
taskTable.Data = table(isEnabled, taskNames);
end
