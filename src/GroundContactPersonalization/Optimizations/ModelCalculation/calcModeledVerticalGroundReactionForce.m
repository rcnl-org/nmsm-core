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
    % A height above this threshold would cause force to reach infinity.
    % This threshold can be modified by changing the transition curvature.
    height = min(height, 0.70947586);
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