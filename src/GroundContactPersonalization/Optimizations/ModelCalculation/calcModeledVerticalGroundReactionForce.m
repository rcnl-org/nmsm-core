% This function is part of the NMSM Pipeline, see file for full license.
%
% This function uses Equation 1 from Jackson et al 2016 to calculate the
% modeled vertical GRF force as the summation of the forces applied by each
% individual spring
%
% (Model, State, Array of double, Array of double, double) => (double)
% Returns the sum of the modeled vertical GRF forces at the given state

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

function [modeledVerticalGrf, springForces] = ...
    calcModeledVerticalGroundReactionForce(springConstants, ...
    dampingFactors, springRestingLength, ...
    markerKinematics, springForces)
modeledVerticalGrf = 0;
for i=1:length(springConstants)
    height = markerKinematics.height(i);
    verticalVelocity = markerKinematics.yVelocity(i);
    %     if (height-springRestingLength)<0
    %         springVerticalGrf = (springConstants(i) * (springRestingLength ...
    %             - height) * (1 + dampingFactors(i) * ...
    %             verticalVelocity)); % Equation 1 from Jackson et al, 2016
    %     end
    %     lowSpringConstant = 0.1;
    %     h = 1e-3;
    %     c = 5e-4;
    %     v = (springConstants(i) + lowSpringConstant) / ...
    %         (springConstants(i) - lowSpringConstant);
    %     s = (springConstants(i) - lowSpringConstant) / 2;
    %     restingLengthForceOffset = -s * (v * springRestingLength - c * ...
    %         log(cosh((springRestingLength + h) / c)));
    %     springVerticalGrf = (-s * (v * height - c * ...
    %         log(cosh((height + h) / c))) - restingLengthForceOffset) * ...
    %         (1 + dampingFactors(i) * verticalVelocity);

    klow = 1e-1;
    h = 1e-3;
    c = 5e-4;
    ymax = 1e-2;
    Kval = springConstants(i);
    height = height - springRestingLength;
    numFrames = length(height);
    v = ones(numFrames, 1)' .* ((Kval + klow) ./ (Kval - klow));
    s = ones(numFrames, 1)' .* ((Kval - klow) ./ 2);
    constant = -s .* (v .* ymax - c .* log(cosh((ymax + h) ./ c)));
    freglyVerticalGrf = -s .* (v .* height - c .* log(cosh((height + h) ./ c))) - constant;
    freglyVerticalGrf(isnan(freglyVerticalGrf)) = min(min(freglyVerticalGrf));
    freglyVerticalGrf(isinf(freglyVerticalGrf)) = min(min(freglyVerticalGrf));
    springForces(2, i) = freglyVerticalGrf * (1 + dampingFactors(i) * ...
        verticalVelocity);
    modeledVerticalGrf = modeledVerticalGrf + springForces(2, i);
end
end