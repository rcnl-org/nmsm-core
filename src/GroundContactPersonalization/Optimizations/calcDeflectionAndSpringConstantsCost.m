% This function is part of the NMSM Pipeline, see file for full license.
%
% inputs:
%   model - Model
%   experimentalJointKinematics - 2D Array of double
%   coordinateColumns - 1D array of int of coordinate indexes
%
% (Array of double, Array of string, struct, struct) -> (struct)
% Optimize ground contact parameters according to Jackson et al. (2016)

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

function cost = calcDeflectionAndSpringConstantsCost(restingSpringLength, springHeights, ...
    inputs, params)

verticalForce = inputs.experimentalGroundReactionForces(2, :)';

deflectionMatrix = zeros(length(verticalForce), length(inputs.springConstants));
for i = 1:length(verticalForce)
    for j = 1:length(inputs.springConstants)
        % The - 0.001 term accounts for using a different force formula
        deflectionMatrix(i, j) = springHeights(i, j) - ...
            restingSpringLength - 0.001;
    end
end

[springConstants, ~, errors] = lsqnonneg(deflectionMatrix, verticalForce);

cost = [];
% Residuals from lsqnonneg are force matching errors
cost = [cost 1 / sqrt(length(errors)) * errors'];
% Alternatively, recalculate force and compare with experimental
modeledForce = deflectionMatrix * springConstants;
cost = [cost 1 / sqrt(length(errors)) * abs(modeledForce' - verticalForce')];
cost = [cost sqrt(1 / length(springConstants)) * (1 / 2000) * ...
    calcSpringConstantsErrorFromMean(springConstants)'];
% Attempt to prevent spring constants being zero
cost = [cost (1 / 2000) * abs(springConstants' - inputs.springConstants)];

end

