% This function is part of the NMSM Pipeline, see file for full license.
%
% This function calculates the scaled muscle excitations given the
% processed EMG signals
%
% (Array of numbers, 2D cell, Array of numbers, Array of numbers) -> 
% (3D matrix of numbers)
% returns the muscle excitations with time padding

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

function [muscleExcitations] = calcMuscleExcitations(time, EmgSplines, ...
    timeDelay, EmgScalingFactor)      

% Interpolated Emg is formatted as (numFrames, numMusc, numTrials)
if size(timeDelay, 2) == 1
    Emg = evaluateEMGsplinesWithOneTimeDelay(time, EmgSplines, timeDelay);
else
    Emg = evaluateEMGsplinesWithMuscleSpecificTimeDelay(time, ...
        EmgSplines, timeDelay); 
end 
% Emg is reformatted as (numFrames, numTrials, numMusc)
Emg = permute(Emg, [1 3 2]); 
% EmgScalingFactor is formatted as (1, numTrials, numMusc)
EmgScalingFactor = permute(EmgScalingFactor(ones(size(EmgSplines, ...
    1), 1), :), [3 1 2]); 
% muscleExcitations are scaled processed Emg signals
muscleExcitations = Emg .* EmgScalingFactor(ones(size(time, 1), 1), ...
    :, :); 
end