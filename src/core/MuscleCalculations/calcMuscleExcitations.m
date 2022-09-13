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
% Author(s): Marleny Vega, Claire V. Hammond, Spencer Williams            %
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

function muscleExcitations = calcMuscleExcitations(emgTime, ...
    emgSplines, electromechanicalDelays, emgScaleFactors)      

if length(electromechanicalDelays) == 1
    timeDelayedEmg = calcEmgDataWithCommonTimeDelay(emgTime, ...
        emgSplines, electromechanicalDelays / 10);
else
    timeDelayedEmg = calcEmgDataWithMuscleSpecificTimeDelay(emgTime, ...
        emgSplines, electromechanicalDelays / 10); 
end 
expandedEmgScalingFactors = ones(1, size(emgScaleFactors, 2), 1);
expandedEmgScalingFactors(1, :, 1) = emgScaleFactors;
muscleExcitations = timeDelayedEmg .* expandedEmgScalingFactors; 
end
