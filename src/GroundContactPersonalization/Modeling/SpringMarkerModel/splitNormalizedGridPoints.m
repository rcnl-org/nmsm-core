% This function is part of the NMSM Pipeline, see file for full license.
%
% 
%
% (Array of double, logical) -> (Array of double, Array of double)
% Separates spring marker points into those inside and outside the shoe. 

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

function [insidePoints, outsidePoints] = splitNormalizedGridPoints( ...
    points, isLeftFoot)
shoeCurve = load(fullfile(fileparts(mfilename('fullpath')), ...
    "shoeCurve.mat")).shoeCurve;
insidePoints = [];
outsidePoints = [];
for i=1:size(points, 1)
    % If this is a left foot, flip points across the vertical centerline
    if(isLeftFoot)
        points(i,1) = 1 - points(i,1);
    end
    if(isInShoeOutline(points(i,1), points(i,2), shoeCurve.x, shoeCurve.y))
        insidePoints(end+1, :) = points(i, :);
    else
        outsidePoints(end+1, :) = points(i, :);
    end
end
end

function isInShoe = isInShoeOutline(normalizedX, normalizedY, curveX, ...
    curveY)
try
    lineX = normalizedX:abs(normalizedX-1)/100:1;
    lineY = ones(1,length(lineX)) * normalizedY;
    isInShoe = checkIntersection(curveX, curveY, lineX, lineY);
    if(isInShoe)
        lineX = 0:abs(normalizedX)/100:normalizedX;
        lineY = ones(1,length(lineX)) * normalizedY;
        isInShoe = checkIntersection(curveX, curveY, lineX, lineY);
    end
    if(isInShoe)
        lineY = normalizedY:abs(normalizedY-1)/100:1;
        lineX = ones(1,length(lineY)) * normalizedX;
        isInShoe = checkIntersection(curveX, curveY, lineX, lineY);
    end
    if(isInShoe)
        lineY = 0:abs(normalizedY)/100:normalizedY;
        lineX = ones(1,length(lineY)) * normalizedX;
        isInShoe = checkIntersection(curveX, curveY, lineX, lineY);
    end
catch
    isInShoe = false;
end
end

