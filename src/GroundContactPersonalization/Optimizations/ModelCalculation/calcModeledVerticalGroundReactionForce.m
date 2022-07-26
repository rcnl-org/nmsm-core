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

function modeledVerticalGrf = calcModeledVerticalGroundReactionForce( ...
    model, state, springConstants, dampingFactors, springRestingLength)
modeledVerticalGrf = 0;
for i=1:length(springConstants)
    height = model.getMarkerSet().get("spring_marker_" + ...
        num2str(i)).getLocationInGround(state).get(1);
    verticalVelocity = model.getMarkerSet().get("spring_marker_" + ...
        num2str(i)).getVelocityInGround(state).get(1);
    modeledVerticalGrf = modeledVerticalGrf + (springConstants(i) * ...
        (height-springRestingLength) * (1 + dampingFactors(i) * ...
        verticalVelocity)); % Equation 1 from Jackson et al, 2016
end
end