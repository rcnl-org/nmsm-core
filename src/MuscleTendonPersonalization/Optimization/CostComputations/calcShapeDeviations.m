% This function is part of the NMSM Pipeline, see file for full license.
%
% This function calculates the shape difference between two curves. The
% purpose of this is to be used in a cost function that incentivises the
% optimized curve to closely match the original curve.
% 
% (3D array of number, 3D array of number) -> (2D array of number)
% Calculates shape deviation

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

function shapeDeviations = calcShapeDeviations(optimizedCurves, ...
    originalCurves)

optimizedCurves = reshape(optimizedCurves, [], ...
    size(optimizedCurves, 3), 1);
optimizedCurvesShapes = optimizedCurves - mean(optimizedCurves, 1);

originalCurves = reshape(originalCurves, [], ...
    size(originalCurves, 3), 1);
originalCurvesShapes = originalCurves - mean(originalCurves, 1);

shapeDeviations = optimizedCurvesShapes - originalCurvesShapes;
end

