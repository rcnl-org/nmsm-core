% This function is part of the NMSM Pipeline, see file for full license.
%
% This function removes the task at the given index from a task list,
% renumbers the remaining tasks' index properties, and returns an
% adjusted selection index. The caller is responsible for handling an
% empty result (typically by creating a fresh default task).
%
% (Cell Array of task objects, double, double) ->
% (Cell Array of task objects, double)
% Removes a task from a task list and returns the new selection index

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
function [tasks, index] = removeTaskFromList(tasks, removeIndex, index)
if isempty(removeIndex) || removeIndex < 1 || removeIndex > length(tasks)
    return
end
tasks(removeIndex) = [];
for i = 1:length(tasks)
    tasks{i}.index = i;
end
index = min(max(index - 1, 1), max(length(tasks), 1));
end
