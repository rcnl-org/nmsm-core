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
    calcModeledGroundReactionMoments(values, inputs, markerKinematics, ...
    springForces)
xGrfMoment = 0;
yGrfMoment = 0;
zGrfMoment = 0;

for i = 1:length(values.springConstants)
    xPosition = markerKinematics.xPosition(i);
    yPosition = markerKinematics.height(i);
    zPosition = markerKinematics.zPosition(i);
    xForce = springForces(1, i);
    yForce = springForces(2, i);
    zForce = springForces(3, i);
    xOffset = xPosition - inputs.electricalCenter(1, 1);
    yOffset = yPosition - inputs.electricalCenter(2, 1);
    zOffset = zPosition - inputs.electricalCenter(3, 1);

    xGrfMoment = xGrfMoment + -yOffset * zForce + -zOffset * yForce;
    yGrfMoment = yGrfMoment + -xOffset * zForce + zOffset * xForce;
    zGrfMoment = zGrfMoment + yOffset * xForce + xOffset * yForce;
end

end
