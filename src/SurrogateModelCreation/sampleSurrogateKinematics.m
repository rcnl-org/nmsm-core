% This function is part of the NMSM Pipeline, see file for full license.
%
% 
% 
% (String, 2D Array of double, Array of string, double, double, double) 
% -> (2D Array of double)
% Use LHS sampling to find kinematics for surrogate model fitting. 

% ----------------------------------------------------------------------- %
% The NMSM Pipeline is a toolkit for model personalization and treatment  %
% optimization of neuromusculoskeletal models through OpenSim. See        %
% nmsm.rice.edu and the NOTICE file for more information. The             %
% NMSM Pipeline is developed at Rice University and supported by the US   %
% National Institutes of Health (R01 EB030520).                           %
%                                                                         %
% Copyright (c) 2022 Rice University and the Authors                      %
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

function lhsKinematics = sampleSurrogateKinematics(modelFileName, ...
    referenceKinematics, coordinateNames, samplePoints, angularPadding, ...
    linearPadding)
model = Model(modelFileName);
assert(size(referenceKinematics, 2) == coordinateNames, "Unequal " + ...
    "number of coordinate names and reference kinematics columns")

padding = zeros(1, length(coordinateNames));
for j = 1 : length(coordinateNames)
    if model.getCoordinateSet().get(coordinateNames(j)) ...
        .getMotionType().toString().toCharArray()' == "Rotational"
        padding(j) = angularPadding;
    else
        padding(j) = linearPadding;
    end
end

lhsKinematics = zeros(size(referenceKinematics, 1) * samplePoints, ...
    size(referenceKinematics, 2));
for i = 1 : size(referenceKinematics, 1)
    minima = referenceKinematics(i, :) - padding;
    lhs = lhsdesign(samplePoints, length(padding)) .* ...
        (2 * padding) + minima;
    lhsKinematics((i - 1) * samplePoints + 1 : i * samplePoints, :) = lhs;
end
end
