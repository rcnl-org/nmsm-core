% This function is part of the NMSM Pipeline, see file for full license.
%
% This function calculates the model normalized muscle fiber lengths and
% velocities
%
% Inputs:
% momentArms - cell structure of (1, numJoints), each cell is made up 
% of (numFrames, numTrials, numMuscles) 
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
% lMtilda - 3D matrix of (numFrames, numTrials, numMuscles)
% vMtilda - 3D matrix of (numFrames, numTrials, numMuscles)
%
% (Struct) -> (Array of number,Array of number)
% returns muscle fiber lengths and velocities

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

function [lMtilda, vMtilda] = ...
    calcNormalizedMusceFiberLengthsAndVelocities(data, ...
    valuesStruct)

optimalMuscleLength = permute(data.optimalMuscleLength .* ...
    findCorrectMtpValues(6, valuesStruct), [1 3 2]);
tendonSlackLength = permute(data.tendonSlackLength .* ...
    findCorrectMtpValues(5, valuesStruct), [1 3 2]);
onesCol = ones(size(data.muscleTendonLength, 1), ...
    size(data.muscleTendonLength, 2));
% Normalized muscle fiber length, equation 2 from Meyer 2017
lMtilda = (data.muscleTendonLength - onesCol .* tendonSlackLength) ./ ...
    (onesCol .* (optimalMuscleLength .*  ...
    permute(cos(data.pennationAngle), [1 3 2])));
% Normalized muscle fiber velocity, equation 3 from Meyer 2017
vMtilda = data.muscleTendonVelocity ./ (data.maxVelocityFactor * ...
    onesCol .* (optimalMuscleLength .* ...
    permute(cos(data.pennationAngle), [1 3 2])));
end
