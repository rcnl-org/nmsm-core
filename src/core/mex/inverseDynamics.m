% This function is part of the NMSM Pipeline, see file for full license.
%
% This function uses a mex file or a matlab function with parallel workers
% to calculate inverse dynamics moments.
%
% (Array of number, 2D matrix, 2D matrix, 2D matrix, Cell, 2D matrix,
% Array of string) -> (2D matrix)
% Returns inverse dynamic moments

% ----------------------------------------------------------------------- %
% The NMSM Pipeline is a toolkit for model personalization and treatment  %
% optimization of neuromusculoskeletal models through OpenSim. See        %
% nmsm.rice.edu and the NOTICE file for more information. The             %
% NMSM Pipeline is developed at Rice University and supported by the US   %
% National Institutes of Health (R01 EB030520).                           %
%                                                                         %
% Copyright (c) 2021 Rice University and the Authors                      %
% Author(s): Spencer Williams, Marleny Vega                               %
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

function inverseDynamicsMoments = inverseDynamics(time, jointAngles, ...
    jointVelocities, jointAccelerations, coordinateLabels, appliedLoads, ...
    modelName)
if isequal(mexext, 'mexw64')
    inverseDynamicsMoments = inverseDynamicsMexWindows(time, jointAngles, ...
        jointVelocities, jointAccelerations, coordinateLabels, ...
        appliedLoads);
else
    inverseDynamicsMoments = inverseDynamicsMatlabParallel(time, ...
        jointAngles, jointVelocities, jointAccelerations, coordinateLabels, ...
        appliedLoads, modelName);
end
end
