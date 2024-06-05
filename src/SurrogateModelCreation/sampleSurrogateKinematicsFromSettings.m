% This function is part of the NMSM Pipeline, see file for full license.
%
% 
% 
% (Model, 2D Array of double, Array of string, struct) 
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
% Author(s): Spencer Williams, Claire V. Hammond                          %
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

function lhsKinematics = sampleSurrogateKinematicsFromSettings(model, ...
    referenceKinematics, coordinateNames, settings)
upperPadding = zeros(1, length(coordinateNames));
lowerPadding = zeros(1, length(coordinateNames));
maxValues = zeros(1, length(coordinateNames));
minValues = zeros(1, length(coordinateNames));
for j = 1 : length(coordinateNames)
    try
        coordinate = model.getCoordinateSet().get(coordinateNames(j));
    catch
        throw(MException('', "Coordinate " + coordinateNames(j) + ...
            " is not in model"))
    end

    if isfield(settings.padding, coordinateNames(j))
        upperPadding(j) = max(settings.padding.(coordinateNames(j)));
        lowerPadding(j) = min(settings.padding.(coordinateNames(j)));
    else
        if coordinate.getMotionType().toString().toCharArray()' ...
                == "Rotational"
            upperPadding(j) = settings.angularPadding;
            lowerPadding(j) = -settings.angularPadding;
        else
            upperPadding(j) = settings.linearPadding;
            lowerPadding(j) = -settings.linearPadding;
        end
    end

    if coordinate.get_clamped()
        maxValues(j) = coordinate.getRangeMax();
        minValues(j) = coordinate.getRangeMin();
    else
        maxValues(j) = Inf;
        minValues(j) = -Inf;
    end
end

samplePoints = settings.samplePoints;
lhsKinematics = zeros(size(referenceKinematics, 1) * samplePoints, ...
    size(referenceKinematics, 2));
for i = 1 : size(referenceKinematics, 1)
    minima = max([referenceKinematics(i, :) + lowerPadding; minValues]);
    maxima = min([referenceKinematics(i, :) + upperPadding; maxValues]);

    lhs = lhsdesign(samplePoints, length(coordinateNames)) .* ...
        (maxima - minima) + minima;
    lhsKinematics((i - 1) * samplePoints + 1 : i * samplePoints, :) = lhs;
end
end
