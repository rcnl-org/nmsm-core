% This function is part of the NMSM Pipeline, see file for full license.
%
% This function uses a spring model with damping to calculate the modeled 
% vertical GRF force as the summation of the forces applied by each
% individual spring
%
% (Array of double, double, double, struct, Array of double) 
% -> (double, Array of double)
% Returns the sum of the modeled vertical GRF forces at the given state

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

function [modeledVerticalGrf, springForces] = ...
    calcModeledVerticalGroundReactionForce(springConstants, ...
    dampingFactor, springRestingLength, ...
    markerKinematics, springForces)
modeledVerticalGrf = 0;
for i=1:length(springConstants)
    height = markerKinematics.height(i);
    verticalVelocity = markerKinematics.yVelocity(i);
    % The freglyVerticalGrf model closely approximates a linear spring
    % during contact while allowing a small force with a small slope to
    % exist for spring markers out of contact. This can help the
    % optimization algorithm find a better search direction when springs
    % are incorrectly out of contact. 
    % Small out-of-contact stiffness to improve gradient
    klow = 1e-1;
    % Horizontal offset of slope transition region
    h = 1e-3;
    % Curvature of transition between linear regions
    c = 1e-3;
    % Height where out-of-contact force becomes zero
    ymax = 1e-2;
    Kval = springConstants(i);
    height = height - springRestingLength;
    height = sign(height) .* abs(height) .^ 1.5;
    % When the height variable reaches a critical value of 0.70947586,
    % the calculated vertical ground reaction force goes to fininity. Thus,
    % it is essential to keep the height variable below this value.
    % Originally, this goal was achieved with the following line of code:
    % height = min(height, 0.70947586);
    % However, allowing the height variable to reach 0.70947586 still
    % causes a singularity in the calculated vertical ground reaction
    % force. Backing off this critical value to 0.7 and changing the line
    % of code above to the following produces faster Tracking Optimization
    % convergence:
    % height = min(height, 0.7);
    % However, this "fix" is still non-smooth, which negatively impacts
    % Tracking Optimization convergence.
    % As an alternative, the min function can be replaced with the
    % following tanh function to create a smooth height variable:
    % height = 0.7*tanh((1/0.7)*height);
    % This implementation causes the new height to be 0 when the original
    % height is zero, the new height to be essentially linear with the
    % original height when the original height is less than zero (i.e., in
    % contact situations), and the new height to follow a tanh function
    % that approaches 0.7 as the original height increases beyond 0.7
    % (i.e., out of contact situations). This tanh formulation has been
    % proven to speed up Tracking Optimization convergence substantially.
    height = 0.7*tanh((1/0.7)*height);
    numFrames = length(height);
    v = ones(numFrames, 1)' .* ((Kval + klow) ./ (Kval - klow));
    s = ones(numFrames, 1)' .* ((Kval - klow) ./ 2);
    constant = -s .* (v .* ymax - c .* log(cosh((ymax + h) ./ c)));
    freglyVerticalGrf = -s .* (v .* height - c .* ...
        log(cosh((height + h) ./ c))) - constant;
    springForces(2, i) = freglyVerticalGrf * (1 - dampingFactor * ...
        verticalVelocity);
    modeledVerticalGrf = modeledVerticalGrf + springForces(2, i);
end
end