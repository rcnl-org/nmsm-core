% This function is part of the NMSM Pipeline, see file for full license.
%
% This function evaluates the EMG signal from a Spline with the electromechanical time
% delay included
%
% (struct) -> (Array of number)
% returns the EMG signal 

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

function [EMG] = evaluatingEMGsplines(SplineParams)

    EMG = zeros(SplineParams.numFrames,SplineParams.numMuscles,...
        SplineParams.numTrials);

    if SplineParams.numTimeDelays == 1
        for j = 1:SplineParams.numTrials
            EMG(:,:,j) = ppval((SplineParams.Time(end,j)-SplineParams.Time(1,j))...
                *SplineParams.TimeInterp+SplineParams.Time(1,j)-...
                SplineParams.TimeDelay(1),SplineParams.EMGsplines{j})';
        end
    elseif SplineParams.numTimeDelays == SplineParams.numMuscles
        for i = 1:SplineParams.numMuscles
            for j = 1:SplineParams.numTrials
                EMG(:,i,j) = ppval((SplineParams.Time(end,j)-SplineParams.Time(1,j))...
                    *SplineParams.TimeInterp+SplineParams.Time(1,j)-...
                    SplineParams.TimeDelay(1,i),SplineParams.EMGsplines{j,i})';
            end
        end
    end

end