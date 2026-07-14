% This function is part of the NMSM Pipeline, see file for full license.
%
% CasADi-safe (2-D only) equivalent of calcMuscleJointMoments.m. Mirrors
% its broadcasting semantics exactly via explicit loops instead of N-D
% array expansion, since CasADi MX/SX do not support N-D arrays.
% normalizedFiberLengths/normalizedFiberVelocities are constants w.r.t.
% the design variables (computed once before optimization), so the force
% curves are evaluated on plain numeric data here, not symbolically.
%
% activations2d: [numTrials*numPoints x numMuscles], rows grouped by
% trial (see calcCasadiActivationsFromSynergyDesignVariables.m).
% Returns muscleJointMoments2d: [numTrials*numPoints x numJoints], same
% row convention.
%
% (struct, Array of number) -> (Array of number)

% ----------------------------------------------------------------------- %
% The NMSM Pipeline is a toolkit for model personalization and treatment  %
% optimization of neuromusculoskeletal models through OpenSim. See        %
% nmsm.rice.edu and the NOTICE file for more information. The             %
% NMSM Pipeline is developed at Rice University and supported by the US   %
% National Institutes of Health (R01 EB030520).                           %
%                                                                         %
% Copyright (c) 2021 Rice University and the Authors                      %
% Author(s): Xuanning Liu                                                 %
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

function muscleJointMoments2d = calcCasadiMuscleJointMoments(inputs, ...
    activations2d)
activeForce = activeForceLengthCurve(inputs.normalizedFiberLengths);
muscleVelocity = forceVelocityCurve(inputs.normalizedFiberVelocities);
passiveForce = passiveForceLengthCurve(inputs.normalizedFiberLengths);
numJoints = size(inputs.momentArms, 2);
% CasADi MX does not implicitly broadcast row/column vectors against a
% matrix (only true scalars broadcast), so expand explicitly.
maxIsoForceExpanded = repmat(reshape(inputs.maxIsometricForce, 1, []), ...
    inputs.numPoints, 1);
pennationExpanded = repmat(cos(reshape(inputs.pennationAngle, 1, [])), ...
    inputs.numPoints, 1);

rowBlocks = cell(inputs.numTrials, 1);
for t = 1:inputs.numTrials
    rows = (t - 1) * inputs.numPoints + 1 : t * inputs.numPoints;
    activationsTrial = activations2d(rows, :); % [numPoints x numMuscles]
    activeForceTrial = squeeze(activeForce(t, :, :)).';
    muscleVelocityTrial = squeeze(muscleVelocity(t, :, :)).';
    passiveForceTrial = squeeze(passiveForce(t, :, :)).';
    muscleForceTrial = maxIsoForceExpanded .* pennationExpanded .* ...
        (activationsTrial .* activeForceTrial .* muscleVelocityTrial + ...
        passiveForceTrial); % [numPoints x numMuscles]

    jointColumns = cell(1, numJoints);
    for j = 1:numJoints
        momentArmsTrialJoint = squeeze(inputs.momentArms(t, j, :, :)).';
        jointColumns{j} = sum(momentArmsTrialJoint .* muscleForceTrial, 2);
    end
    rowBlocks{t} = [jointColumns{:}]; % [numPoints x numJoints]
end
muscleJointMoments2d = vertcat(rowBlocks{:});
end
