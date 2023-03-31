% This function is part of the NMSM Pipeline, see file for full license.
%
% Makes a grid of points in a normalized array for placing spring markers.
% The points are made in a reversed order if this is a left foot to ensure
% symmetry of stiffness coefficients when optimizing multiple feet. 
%
% (struct, struct) -> (struct)
% Makes a grid of points in a normalized array for placing spring markers. 

% ----------------------------------------------------------------------- %
% The NMSM Pipeline is a toolkit for model personalization and treatment  %
% optimization of neuromusculoskeletal models through OpenSim. See        %
% nmsm.rice.edu and the NOTICE file for more information. The             %
% NMSM Pipeline is developed at Rice University and supported by the US   %
% National Institutes of Health (R01 EB030520).                           %
%                                                                         %
% Copyright (c) 2021 Rice University and the Authors                      %
% Author(s): Claire V. Hammond, Spencer Williams                          %
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

function points = makeNormalizedGrid(cellsWide, cellsLong, isLeftFoot)
points = zeros(cellsWide * cellsLong, 2);
for i=1:cellsWide
    i_side = i;
    % If this is a left foot, markers are added in reverse order to ensure
    % symmetry of stiffness coefficients
    if isLeftFoot
        i_side = cellsWide + 1 - i_side;
    end
    for j=1:cellsLong
        x = (i_side)/(cellsWide) - (1/(2*cellsWide));
        y = (j-1)/(cellsLong-1);
        points((i-1)*cellsLong + j, :) = [x y];
    end
end
end

