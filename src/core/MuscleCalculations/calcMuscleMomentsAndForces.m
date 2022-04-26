% This function is part of the NMSM Pipeline, see file for full license.
%
% This function calculates the model Joint moments, muscle moments, passive
% and active muscle forces, normalized muscle lengths, normalized muscle
% velocity, muscle tendon length, muscle tendon velocity, and max isometric
% force.
%
% Inputs:
% momentArms - cell structure of (1, numJoints), each cell is made up 
% of (numFrames, numTrials, numMuscles) 
% hillTypeParams.lMt - 3D matrix of (numFrames, numTrials, numMuscles)
% hillTypeParams.vMT - 3D matric of (numFrames, numTrials, numMuscles)
% hillTypeParams.vMaxFactor - number
% hillTypeParams.pennationAngle - 3D matrix of (1, 1, numMuscles)
% hillTypeParams.maxMuscleForce - 3D matrix of (1, 1, numMuscles)
% hillTypeParams.lMo - 3D matrix of (1, 1, numMuscles)
% hillTypeParams.lTs - 3D matrix of (1, 1, numMuscles)
% muscleActivations - 3D matrix of (numFrames, numTrials, numMuscles)
%
% Outputs:
% passiveForce - 3D matrix of (numFrames, numTrials, numMuscles)
% muscleForce - 3D matrix of (numFrames, numTrials, numMuscles)
% muscleMoments - 3D matrix of (numFrames, numTrials, numMuscles, numJoints)
% modelMoments - 3D matrix of (numFrames, numTrials, numJoints)
%
% (Cell, Struct, Array of number) -> (Array of number, Array of number, 
% Array of number, Array of number)
% returns muscle moments, forces, and lengths 

% ----------------------------------------------------------------------- %
% The NMSM Pipeline is a toolkit for model personalization and treatment  %
% optimization of neuromusculoskeletal models through OpenSim. See        %
% nmsm.rice.edu and the NOTICE file for more information. The             %
% NMSM Pipeline is developed at Rice University and supported by the US   %
% National Institutes of Health (R01 EB030520).                           %
%                                                                         %
% Copyright (c) 2021 Rice University and the Authors                      %
% Author(s): Marleny Vega                                                 %
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

function [passiveForce, muscleForce, muscleMoments, modelMoments] = ...
    calcMuscleMomentsAndForces(data, muscleActivations, ...
    valuesStruct)

[lMtilda, vMtilda] = ...
    calcNormalizedMusceFiberLengthsAndVelocities(data, ...
    valuesStruct);
% Preallocation of Memory
muscleMoments = zeros([size(data.muscleTendonLength), ...
    size(data.momentArms, 2)]); 
onesCol = ones(size(data.muscleTendonLength, 1), ...
    size(data.muscleTendonLength, 2));
passiveForce = onesCol .* (permute(data.maxMuscleForce, [1 3 2])  .* ...
    permute(cos(data.pennationAngle), [1 3 2]) ) .* ...
    passiveForceLengthCurve(lMtilda);
% equation 1 from Meyer 2017
muscleForce = onesCol .* (permute(data.maxMuscleForce, [1 3 2]) .* ...
    permute(cos(data.pennationAngle), [1 3 2])) .* ...
    muscleActivations .* activeForceLengthCurve(lMtilda) .* ...
    forceVelocityCurve(vMtilda) + passiveForce;
for i=1:size(momentArms, 2)
    muscleMoments(:, :, :, i) = momentArms{i} .* muscleForce;
end
modelMoments = permute(sum(muscleMoments, 3), [1 2 4 3]);
end
