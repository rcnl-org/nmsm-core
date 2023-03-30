% This function is part of the NMSM Pipeline, see file for full license.
%
% This function uses Equation 1 from Jackson et al 2016 to calculate the
% modeled horizontal GRF forces as the summation of the forces applied by 
% each individual spring
%
% (struct, double, double, struct, Array of double) 
% -> (double, double, Array of double)
% Returns the sum of the modeled horizontal GRF forces at the given state

% ----------------------------------------------------------------------- %
% The NMSM Pipeline is a toolkit for model personalization and treatment  %
% optimization of neuromusculoskeletal models through OpenSim. See        %
% nmsm.rice.edu and the NOTICE file for more information. The             %
% NMSM Pipeline is developed at Rice University and supported by the US   %
% National Institutes of Health (R01 EB030520).                           %
%                                                                         %
% Copyright (c) 2021 Rice University and the Authors                      %
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

function [anteriorGrf, lateralGrf, springForces] = ...
    calcModeledHorizontalGroundReactionForces(values, beltSpeed, ...
    latchVelocity, markerKinematics, springForces)
slipOffset = 1e-4;
anteriorGrf = 0;
lateralGrf = 0;

for i=1:length(values.springConstants)
    verticalGrf = springForces(2, i);
    % Add belt speed to account for treadmill motion (0 for stationary
    % force plates). 
    xVelocity = markerKinematics.xVelocity(i) + beltSpeed;
    zVelocity = markerKinematics.zVelocity(i);
    slipVelocity = (xVelocity ^ 2 + zVelocity ^ 2) ^ 0.5;
    if slipVelocity < 1e-10
        slipVelocity = 0;
    end
    % Depending on included design variables, the horizontal friction model
    % may have a tanh, linear, or combined slip-veloctiy to force
    % relationship. 
    horizontalGrfMagnitude = verticalGrf * ( ...
        values.dynamicFrictionCoefficient * ...
        tanh(slipVelocity / latchVelocity) + ...
        values.viscousFrictionCoefficient * slipVelocity);
    % Slip offset prevents division by zero at any time point. Spring
    % forces are in the opposite direction of spring marker velocities. 
    springForces(1, i) = -xVelocity / (slipVelocity + slipOffset) * ...
        horizontalGrfMagnitude;
    springForces(3, i) = -zVelocity / (slipVelocity + slipOffset) * ...
        horizontalGrfMagnitude;
    anteriorGrf = anteriorGrf + springForces(1, i);
    lateralGrf = lateralGrf + springForces(3, i);
end
end
