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

function [anteriorGrf, lateralGrf] = ...
    calcModeledHorizontalGroundReactionForces(model, state, values, ...
    beltSpeed)
latchVelocity = 0.01; % Jackson et al, 2016 page 4
slipOffset = 1e-4;
anteriorGrf = 0;
lateralGrf = 0;

for i=1:length(values.springConstants)
    height = model.getMarkerSet().get("spring_marker_" + ...
        num2str(i)).getLocationInGround(state).get(1);
    verticalVelocity = model.getMarkerSet().get("spring_marker_" + ...
        num2str(i)).getVelocityInGround(state).get(1);
    verticalGrf = 0;
    if (height-values.restingSpringLength)<0
        verticalGrf = (values.springConstants(i) * ...
            (values.restingSpringLength - height) * ...
            (1 + values.dampingFactors(i) * verticalVelocity)); % Equation 1 from Jackson et al, 2016
    end
    xVelocity = model.getMarkerSet().get("spring_marker_" + ...
        num2str(i)).getVelocityInGround(state).get(0) + beltSpeed;
    zVelocity = model.getMarkerSet().get("spring_marker_" + ...
        num2str(i)).getVelocityInGround(state).get(2);
    slipVelocity = (xVelocity ^ 2 + zVelocity ^ 2) ^ 0.5;
%     xVelocity = xVelocity / (slipVelocity + slipOffset);
%     zVelocity = zVelocity / (slipVelocity + slipOffset);
%     effectiveFrictionCoefficient = values.dynamicFrictionCoefficient * ...
%         tanh(slipVelocity / latchVelocity) + ...
%         values.viscousFrictionCoefficient * slipVelocity / latchVelocity;
%     anteriorGrf = anteriorGrf + -verticalGrf * ...
%         effectiveFrictionCoefficient * xVelocity;
%     lateralGrf = lateralGrf + -verticalGrf * ...
%         effectiveFrictionCoefficient * zVelocity;
    horizontalGrfMagnitude = verticalGrf * ... % Equation 2 from Jackson et al, 2016
        (values.dynamicFrictionCoefficient * ...
        tanh(slipVelocity / latchVelocity) + ...
        (values.staticFrictionCoefficient - ...
        values.dynamicFrictionCoefficient) * exp(-((slipVelocity - ...
        latchVelocity) ^ 2 / (2 * latchVelocity ^ 2))) - ...
        (values.staticFrictionCoefficient - ...
        values.dynamicFrictionCoefficient) * exp(-(slipVelocity + ...
        latchVelocity) ^ 2 / (2 * latchVelocity ^ 2)) + ...
        values.viscousFrictionCoefficient * (slipVelocity/latchVelocity));
    anteriorGrf = -xVelocity / slipVelocity * horizontalGrfMagnitude;
    lateralGrf = -zVelocity / slipVelocity * horizontalGrfMagnitude;
end

end
