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
% All fixed (non-design-variable-dependent) numeric quantities are
% flattened to the same [numTrials*numPoints x numMuscles] layout as
% activations2d ONCE, up front, so the per-joint combination below is a
% single vectorized expression across all trials simultaneously rather
% than a trial-by-trial loop.
activeForce2d = flattenNumericTrialFirstDim( ...
    activeForceLengthCurve(inputs.normalizedFiberLengths));
muscleVelocity2d = flattenNumericTrialFirstDim( ...
    forceVelocityCurve(inputs.normalizedFiberVelocities));
passiveForce2d = flattenNumericTrialFirstDim( ...
    passiveForceLengthCurve(inputs.normalizedFiberLengths));
numJoints = size(inputs.momentArms, 2);
numRows = inputs.numTrials * inputs.numPoints;
% CasADi MX does not implicitly broadcast row/column vectors against a
% matrix (only true scalars broadcast), so expand explicitly.
maxIsoForceExpanded = repmat(reshape(inputs.maxIsometricForce, 1, []), ...
    numRows, 1);
pennationExpanded = repmat(cos(reshape(inputs.pennationAngle, 1, [])), ...
    numRows, 1);

muscleForce2d = maxIsoForceExpanded .* pennationExpanded .* ...
    (activations2d .* activeForce2d .* muscleVelocity2d + ...
    passiveForce2d); % [numTrials*numPoints x numMuscles]

% CasADi MX has no N-D array support, so momentArms (4-D: trial, joint,
% muscle, point) can only be combined with the symbolic muscleForce2d
% one joint at a time; numJoints is typically the smallest dimension
% here (single digits, vs. ~100 points), so this is the cheapest axis
% to loop over.
jointColumns = cell(1, numJoints);
for j = 1:numJoints
    momentArmsJoint2d = flattenNumericTrialFirstDim(reshape( ...
        inputs.momentArms(:, j, :, :), inputs.numTrials, ...
        size(inputs.momentArms, 3), size(inputs.momentArms, 4)));
    jointColumns{j} = sum(momentArmsJoint2d .* muscleForce2d, 2);
end
muscleJointMoments2d = [jointColumns{:}];
end

function flat = flattenNumericTrialFirstDim(data)
numTrials = size(data, 1);
numColumns = size(data, 2);
numPoints = size(data, 3);
flat = reshape(permute(data, [3 1 2]), numTrials * numPoints, numColumns);
end
