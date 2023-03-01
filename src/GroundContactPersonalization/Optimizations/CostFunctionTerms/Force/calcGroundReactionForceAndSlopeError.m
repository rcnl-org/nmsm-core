% This function is part of the NMSM Pipeline, see file for full license.
%
% Calculate error between experimental and modeled ground reaction force.
% This function returns the value errors and slope errors. 
%
% (struct, struct) -> (Array of double, Array of double)
% Calculate error between experimental and modeled ground reaction force. 

% ----------------------------------------------------------------------- %
% The NMSM Pipeline is a toolkit for model personalization and treatment  %
% optimization of neuromusculoskeletal models through OpenSim. See        %
% nmsm.rice.edu and the NOTICE file for more information. The             %
% NMSM Pipeline is developed at Rice University and supported by the US   %
% National Institutes of Health (R01 EB030520).                           %
%                                                                         %
% Copyright (c) 2021 Rice University and the Authors                      %
% Author(s): Spencer Williams, Claire V. Hammond                          %
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

function [valueErrors, slopeErrors] = ...
    calcGroundReactionForceAndSlopeError(task, modeledValues)
valueErrors(1, :) = task.experimentalGroundReactionForces(1, :) -...
    modeledValues.anteriorGrf;
slopeErrors(1, :) = task.experimentalGroundReactionForcesSlope(...
    1, :) - calcBSplineDerivative(task.time, ...
    modeledValues.anteriorGrf, 2, 25);
valueErrors(2, :) = task.experimentalGroundReactionForces(2, :) -...
    modeledValues.verticalGrf;
slopeErrors(2, :) = task.experimentalGroundReactionForcesSlope(...
    2, :) - calcBSplineDerivative(task.time, ...
    modeledValues.verticalGrf, 2, 25);
valueErrors(3, :) = task.experimentalGroundReactionForces(3, :) -...
    modeledValues.lateralGrf;
slopeErrors(3, :) = task.experimentalGroundReactionForcesSlope(...
    3, :) - calcBSplineDerivative(task.time, ...
    modeledValues.lateralGrf, 2, 25);
end

