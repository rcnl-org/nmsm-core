% This function is part of the NMSM Pipeline, see file for full license.
%
% This function calculates the model Joint moments for each muscle
%
% (Cell, Struct, num array) -> (num array, num array, num array, num array)
% returns muscle moments, forces, and lengths in TO indices

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

function muscleJointMoments = ...
    calcTreatmentOptimizationMuscleJointMoments(inputs, modeledValues, ...
    momentArms)
expandedMaxIsometricForce = ones(1, 1, ...
    length(inputs.maxIsometricForce));
expandedMaxIsometricForce(1, 1, :) = inputs.maxIsometricForce;

expandedMuscleActivations = ones(size( ...
    modeledValues.muscleActivations, 1), 1, ...
    size(modeledValues.muscleActivations, 2));
expandedMuscleActivations(:, 1, :) = modeledValues.muscleActivations;

parallelComponentOfPennationAngle = cos(inputs.pennationAngle);
expandedParallelComponentOfPennationAngle = ones(1, 1, length( ...
    parallelComponentOfPennationAngle));
expandedParallelComponentOfPennationAngle(1, 1, :) = ...
    parallelComponentOfPennationAngle;

nTime    = size(modeledValues.muscleActivations, 1);
nMuscles = size(modeledValues.muscleActivations, 2);

% Use MeyerFregly2016Muscle if available
if isfield(inputs, 'MFMuscles') && ~isempty(inputs.MFMuscles)
    import org.opensim.modeling.*
    mfMuscles = inputs.MFMuscles;

    % use our normalized fiber length & velocity
    normalizedFiberLength = modeledValues.normalizedFiberLength;      % time x muscle
    normalizedFiberVelocity = modeledValues.normalizedFiberVelocity;    % time x muscle
    
    activeForceLengthMultiplier = zeros(nTime, nMuscles);
    passiveForceMultiplier = zeros(nTime, nMuscles);
    forceVelocityMultiplier = zeros(nTime, nMuscles);
    
    for m = 1:nMuscles
        muscle = mfMuscles{m};
        for t = 1:nTime
            ltilde = normalizedFiberLength(t, m);   
            vtilde = normalizedFiberVelocity(t, m);  
    
            activeForceLengthMultiplier(t, m)  = muscle.calcActiveForceLengthMultiplier(ltilde);
            passiveForceMultiplier(t, m) = muscle.calcPassiveForceMultiplier(ltilde);
            forceVelocityMultiplier(t, m) = muscle.calcForceVelocityMultiplier(vtilde);
        end
    end
    % Expand to (time x 1 x muscle)
    expandedActiveForce = ones(nTime, 1, nMuscles);
    expandedActiveForce(:, 1, :) = activeForceLengthMultiplier;
    
    expandedMuscleVelocity = ones(nTime, 1, nMuscles);
    expandedMuscleVelocity(:, 1, :) = forceVelocityMultiplier;
    
    expandedPassiveForce = ones(nTime, 1, nMuscles);
    expandedPassiveForce(:, 1, :) = passiveForceMultiplier;
else
    activeForce = activeForceLengthCurve(modeledValues.normalizedFiberLength);
    expandedActiveForce = ones(size(activeForce, 1), 1, ...
        size(activeForce, 2));
    expandedActiveForce(:, 1, :) = activeForce;
    
    muscleVelocity = forceVelocityCurve(modeledValues.normalizedFiberVelocity);
    expandedMuscleVelocity = ones(size(muscleVelocity, 1), 1, ...
        size(muscleVelocity, 2));
    expandedMuscleVelocity(:, 1, :) = muscleVelocity;
    
    passiveForce = passiveForceLengthCurve(modeledValues.normalizedFiberLength);
    expandedPassiveForce = ones(size(passiveForce, 1), 1, ...
        size(passiveForce, 2));
    expandedPassiveForce(:, 1, :) = passiveForce;
end
muscleForce = expandedMaxIsometricForce .* ...
    (expandedMuscleActivations .* expandedActiveForce .* ...
    expandedMuscleVelocity + expandedPassiveForce) .* ...
    expandedParallelComponentOfPennationAngle;

muscleJointMoments = momentArms(:, inputs.surrogateModelIndex, :) .* muscleForce;
    
muscleJointMoments = sum(muscleJointMoments, 3);
end
