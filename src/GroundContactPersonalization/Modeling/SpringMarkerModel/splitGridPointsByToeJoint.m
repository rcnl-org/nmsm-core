% This function is part of the NMSM Pipeline, see file for full license.
%
% 
%
% (Array of double, Array of double, Array of double) 
% -> (Array of double, Array of double)
% Separates included spring marker points into hindfoot and toes portions.

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

function [insideToes, insideHindfoot] = splitGridPointsByToeJoint( ...
    insidePoints, medialPt, lateralPt)
insideToes = [];
insideHindfoot = [];
for i=1:length(insidePoints)
    if isAboveToeJoint(medialPt, lateralPt, insidePoints(i, :))
        insideHindfoot(end+1, :) = insidePoints(i, :);
    else
        insideToes(end+1, :) = insidePoints(i, :);
    end
end
end

function out = isAboveToeJoint(medialPt, lateralPt, springPt)
lineX = linspace(medialPt(2), lateralPt(2));
lineY = linspace(medialPt(1), lateralPt(1));
springLineY = linspace(springPt(2), 1);
springLineX = ones(1,length(springLineY)) * springPt(1);
out = checkIntersection(lineX, lineY, springLineX, springLineY);
end