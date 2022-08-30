% This function is part of the NMSM Pipeline, see file for full license.
%
% This function calculates the model Joint moments, muscle moments, passive
% and active muscle forces, normalized muscle lengths, normalized muscle
% velocity, muscle tendon length, muscle tendon velocity, and max isometric
% force.
%
% Inputs:
% momentArms - 4D matrix of (numFrames, numTrials, numMuscles, numJoints) 
% hillTypeParams.lMt - 3D matrix of (numFrames, numTrials, numMuscles)
% hillTypeParams.vMT - 3D matric of (numFrames, numTrials, numMuscles)
% hillTypeParams.vMaxFactor - number
% hillTypeParams.pennationAngle - 3D matrix of (1, 1, numMuscles)
% hillTypeParams.fMax - 3D matrix of (1, 1, numMuscles)
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

function modelMoments = calcMuscleMoments(experimentalData, ...
    passiveForce, muscleActivations, normalizedFiberLength, ...
    normalizedFiberVelocity)

modelMoments = experimentalData.momentArms .* ...
    experimentalData.maxIsometricForce .* (muscleActivations .* ...
    activeForceLengthCurve(normalizedFiberLength) .* ...
    forceVelocityCurve(normalizedFiberVelocity) + passiveForce) .* ...
    cos(experimentalData.pennationAngle);
end
