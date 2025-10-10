% This function is part of the NMSM Pipeline, see file for full license.
%
%
% (struct, Array of double) -> (Array of double)
% returns muscle joint moments

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

function muscleJointMoments = calcCasadiMuscleJointMoments(inputs, ...
    activations)

maxIsometricForce = repmat(inputs.maxIsometricForce', 1, ...
    size(activations, 2));

activeForce = activeForceLengthCurve(inputs.normalizedFiberLengths);

muscleVelocity = forceVelocityCurve(inputs.normalizedFiberVelocities);

passiveForce = passiveForceLengthCurve(inputs.normalizedFiberLengths);

parallelComponentOfPennationAngle = repmat(cos(inputs.pennationAngle)', ...
    1, size(activations, 2));

if isa(activations, 'casadi.MX')
    muscleJointMoments = casadi.MX.zeros( ...
        size(inputs.inverseDynamicsMoments, 1), size(activeForce, 2));
else
    muscleJointMoments = zeros(size(inputs.inverseDynamicsMoments, 1), ...
        size(activeForce, 2));
end

for i = 1 : size(muscleJointMoments, 1)
    muscleContributions = inputs.momentArms( ...
        (i - 1) * inputs.numMuscles + 1 : i * inputs.numMuscles, :) .* ...
        maxIsometricForce .* (activations .* activeForce .* ...
        muscleVelocity + passiveForce) .* ...
        parallelComponentOfPennationAngle;
    muscleJointMoments(i, :) = sum(muscleContributions, 1);
end
end
