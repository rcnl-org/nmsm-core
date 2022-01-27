% This function is part of the NMSM Pipeline, see file for full license.
%
% This function calculates the muscle excitations given the
% EMG signals
%
% (struct) -> (Array of number,Array of number)
% returns the muscle excitations with time padding (EMG) and without padding 
% (muscle excitations) 

% ----------------------------------------------------------------------- %
% The NMSM Pipeline is a toolkit for model personalization and treatment  %
% optimization of neuromusculoskeletal models through OpenSim. See        %
% nmsm.rice.edu and the NOTICE file for more information. The             %
% NMSM Pipeline is developed at Rice University and supported by the US   %
% National Institutes of Health (R01 EB030520).                           %
%                                                                         %
% Copyright (c) 2021 Rice University and the Authors                      %
% Author(s): Marleny Vega                                          %
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

function [muscleExcitations] = calcMuscleExcitations(time, EMGsplines, ...
    timeDelay, EMGScalingFactor)        

if size(timeDelay,2) == 1
    EMG = evaluateEMGsplinesWithOneTimeDelay(time, EMGsplines, timeDelay);
else
    EMG = evaluateEMGsplinesWithMuscleSpecificTimeDelay(time, ...
        EMGsplines, timeDelay); 
end % EMG formatted as (numFrames, numMusc, numTrials)
EMG = permute(EMG,[1 3 2]); % reformatted as (numFrames, numTrials, numMusc)
EMGScalingFactor = permute(EMGScalingFactor(ones(size(EMGsplines, ...
    1), 1), :), [3 1 2]); % formatted as (1, numTrials, numMusc)
muscleExcitations = EMG .* EMGScalingFactor(ones(size(time, 1), 1), ...
    :, :); % processed EMG signals are scaled 

end