% This function is part of the NMSM Pipeline, see file for full license.
%
% Returns the vertical (OpenSim y) ground reaction force of each force
% plate from ground reaction data still in lab axes. The lab axis that
% becomes OpenSim y, and its sign, come from labToOpenSimAxes. Also returns
% the column of each plate's lab vertical force and the sign applied to it.
%
% (struct, Array of double) -> (2D Array of double, Array of double, double)
% Returns time x plates vertical force

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

function [verticalForces, columns, direction] = getVerticalForces( ...
    groundReactions, labToOpenSimAxes)
direction = sign(labToOpenSimAxes(2));
columns = 9 * (0:groundReactions.numPlates - 1) + abs(labToOpenSimAxes(2));
verticalForces = direction * groundReactions.data(:, columns);
end
