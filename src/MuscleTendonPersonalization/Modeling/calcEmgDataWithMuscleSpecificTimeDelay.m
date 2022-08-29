% This function is part of the NMSM Pipeline, see file for full license.
%
% This function takes a 2D array (time) containing the time data for each
% (trial, time point), a 2D Cell Array of pp splines (spline(x,y)) of time
% and emg data, and a 1D array of number of the time delay for each muscle.
% It applies the time delay to the spline and returns the new segment of
% emg data for each unique trial and muscle combination.
%
% (2D Array of number, 2D Cell Array of pp, Array of number) -> 
% (3D Array of number)
% returns new emg data after applying the time delay

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

function emg = calcEmgDataWithMuscleSpecificTimeDelay(time, ...
    emgSplines, timeDelay)
timeIntervalInterp = linspace(0, 1, size(time, 2))'; 
emg = zeros(size(emgSplines, 1), size(emgSplines, 2), size(time, 2)); 
for trial = 1:size(emgSplines, 1)
    for muscle = 1:size(emgSplines, 2)
        interpTime = ((time(trial, end) - time(trial, 1)) * ...
            timeIntervalInterp + time(trial, 1));
        emg(trial, muscle, :) = ppval(interpTime - timeDelay(muscle), ...
            emgSplines{trial, muscle})';
    end
end
end