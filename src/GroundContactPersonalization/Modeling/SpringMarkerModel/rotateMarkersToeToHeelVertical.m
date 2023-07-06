% This function is part of the NMSM Pipeline, see file for full license.
%
% 
%
% (struct) -> (struct)
% Use rotation matrices to rotate foot markers to GCP orientation. 

% ----------------------------------------------------------------------- %
% The NMSM Pipeline is a toolkit for model personalization and treatment  %
% optimization of neuromusculoskeletal models through OpenSim. See        %
% nmsm.rice.edu and the NOTICE file for more information. The             %
% NMSM Pipeline is developed at Rice University and supported by the US   %
% National Institutes of Health (R01 EB030520).                           %
%                                                                         %
% Copyright (c) 2021 Rice University and the Authors                      %
% Author(s): Claire V. Hammond                                            %
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

function [markerPositions, theta] = ...
    rotateMarkersToeToHeelVertical(markerPositions)
markerNamesList = fieldnames(markerPositions);
markersX = zeros(4,1);
markersZ = zeros(4,1);

for i=1:length(markerNamesList)
    markersX(i) = markerPositions.(markerNamesList{i})(1);
    markersZ(i) = markerPositions.(markerNamesList{i})(2);
end

[~, topIndex] = max(markersX);
top = [markersX(topIndex), markersZ(topIndex)];

markersX = markersX - top(1);
markersZ = markersZ - top(2);

theta = solveForTheta2DRotationMatrix(markersZ(4), markersX(4), 0, 1);

[markersZ, markersX] = rotateValues2D(markersZ, markersX, theta);

markersX = markersX + top(1);
markersZ = markersZ + top(2);

for i=1:length(markerNamesList)
    markerPositions.(markerNamesList{i})(1) = markersX(i);
    markerPositions.(markerNamesList{i})(2) = markersZ(i);
end
end

function theta = solveForTheta2DRotationMatrix(initialX, initialY, ...
    finalX, finalY)
rotationAngles = asin(cross([finalX finalY 0], [initialX initialY 0]) / ...
    (norm([initialX initialY]) * norm([finalX finalY])));
theta = rotationAngles(3);
end
