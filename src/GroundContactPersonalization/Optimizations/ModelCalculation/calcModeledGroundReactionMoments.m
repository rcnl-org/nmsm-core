% This function is part of the NMSM Pipeline, see file for full license.
%
% This function uses Equation 1 from Jackson et al 2016 to calculate the
% modeled horizontal GRF forces as the summation of the forces applied by 
% each individual spring
%
% (Model, State, Array of double, struct, double) => (double, double)
% Returns the sum of the modeled horizontal GRF forces at the given state

% ----------------------------------------------------------------------- %
% The NMSM Pipeline is a toolkit for model personalization and treatment  %
% optimization of neuromusculoskeletal models through OpenSim. See        %
% nmsm.rice.edu and the NOTICE file for more information. The             %
% NMSM Pipeline is developed at Rice University and supported by the US   %
% National Institutes of Health (R01 EB030520).                           %
%                                                                         %
% Copyright (c) 2021 Rice University and the Authors                      %
% Author(s): Spencer Williams                                             %
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

function [xGrfMoment, yGrfMoment, zGrfMoment] = ...
    calcModeledGroundReactionMoments(values, task, markerKinematics, ...
    springForces, currentFrame)
xGrfMoment = 0;
yGrfMoment = 0;
zGrfMoment = 0;

for i = 1:length(values.springConstants)
    xPosition = markerKinematics.xPosition(i);
    zPosition = markerKinematics.zPosition(i);
    force(1) = springForces(1, i);
    force(2) = springForces(2, i);
    force(3) = springForces(3, i);
    offset(1) = xPosition - task.midfootSuperiorPosition(1, currentFrame);
    offset(2) = 0;
    offset(3) = zPosition - task.midfootSuperiorPosition(3, currentFrame);

    moments = cross(offset, force);
    xGrfMoment = xGrfMoment + moments(1);
    yGrfMoment = yGrfMoment + moments(2);
    zGrfMoment = zGrfMoment + moments(3);
    
end

end
