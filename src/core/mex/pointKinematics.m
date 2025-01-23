% This function is part of the NMSM Pipeline, see file for full license.
%
% This function uses a mex file or a matlab function with parallel workers
% to calculate the position and velocity of a point.
%
% (Array of number, 2D matrix, 2D matrix, 2D matrix (or Array of number), 
% Array of number (or number), Array of string, Cell) -> (2D matrix, 2D matrix)
% Returns point positions and point velocities

% ----------------------------------------------------------------------- %
% The NMSM Pipeline is a toolkit for model personalization and treatment  %
% optimization of neuromusculoskeletal models through OpenSim. See        %
% nmsm.rice.edu and the NOTICE file for more information. The             %
% NMSM Pipeline is developed at Rice University and supported by the US   %
% National Institutes of Health (R01 EB030520).                           %
%                                                                         %
% Copyright (c) 2021 Rice University and the Authors                      %
% Author(s): Spencer Williams, Marleny Vega                               %
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

function [pointPositions, pointVelocities] = pointKinematics(time, ...
    jointAngles, jointVelocities, pointLocationOnBody, body, modelName, ...
    coordinateLabels, version)
if isequal(mexext, 'mexw64')
    pool = gcp();
    numWorkers = pool.NumWorkers;

    index = 1;
    timeParts = cell(1, numWorkers);
    jointAnglesParts = cell(1, numWorkers);
    pointPositionsParts = cell(1, numWorkers);
    pointVelocitiesParts = cell(1, numWorkers);
    
    remainder = mod(length(time), numWorkers);
    for i = 1 : numWorkers
        if i <= remainder
            nextIndex = index - 1 + ceil(length(time) / numWorkers);
        else
            nextIndex = index - 1 + floor(length(time) / numWorkers);
        end
        timeParts{i} = time(index : nextIndex);
        jointAnglesParts{i} = jointAngles(index : nextIndex, :);
        index = nextIndex + 1;
    end

    parfor i = 1 : numWorkers
        if version >= 40501
            [pointPositionsParts{i}, pointVelocitiesParts{i}] = ...
                pointKinematicsMexWindows40501(timeParts{i}, jointAnglesParts{i}, ...
                jointVelocities, pointLocationOnBody', body, coordinateLabels);
        else
            [pointPositionsParts{i}, pointVelocitiesParts{i}] = ...
                pointKinematicsMexWindows40400(timeParts{i}, jointAnglesParts{i}, ...
                jointVelocities, pointLocationOnBody', body, coordinateLabels);
        end
    end

    pointPositions = pointPositionsParts{1};
    pointVelocities = pointVelocitiesParts{1};
    for part = 2 : numWorkers
        pointPositions = cat(1, pointPositions, pointPositionsParts{part});
        pointVelocities = cat(1, pointVelocities, pointVelocitiesParts{part});
    end
else
    [pointPositions, pointVelocities] = pointKinematicsMatlabParallel(time, ...
        jointAngles, jointVelocities, pointLocationOnBody, body, modelName, ...
        coordinateLabels);
end
end