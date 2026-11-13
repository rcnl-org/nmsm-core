% This function is part of the NMSM Pipeline, see file for full license.
%
% This function moves the task at the given index by the given offset
% (-1 to move up, +1 to move down), updating each moved task's index
% property. The list and index are returned unchanged if the move would
% leave the list bounds.
%
% (Cell Array of task objects, double, double) ->
% (Cell Array of task objects, double)
% Moves a task within a task list and returns its new index

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
function [tasks, index] = moveTaskInList(tasks, index, offset)
if isempty(index)
    index = [];
    return
end
newIndex = index + offset;
if index < 1 || index > length(tasks) || ...
        newIndex < 1 || newIndex > length(tasks)
    return
end
tasks([index, newIndex]) = tasks([newIndex, index]);
tasks{index}.index = index;
tasks{newIndex}.index = newIndex;
index = newIndex;
end
