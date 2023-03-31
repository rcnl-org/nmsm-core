% This function is part of the NMSM Pipeline, see file for full license.
%
% Calculate error between experimental and modeled vertical ground reaction 
% force. This function returns the value errors and slope errors. This
% function is meant to be used in a task where horizontal ground reaction
% forces are not included. 
%
% (struct, struct) -> (double, double)
% Calculate error between experimental and modeled vertical GRFs.

% ----------------------------------------------------------------------- %
% The NMSM Pipeline is a toolkit for model personalization and treatment  %
% optimization of neuromusculoskeletal models through OpenSim. See        %
% nmsm.rice.edu and the NOTICE file for more information. The             %
% NMSM Pipeline is developed at Rice University and supported by the US   %
% National Institutes of Health (R01 EB030520).                           %
%                                                                         %
% Copyright (c) 2021 Rice University and the Authors                      %
% Author(s): Claire V. Hammond                                            %
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

function [valueError, slopeError] = ...
    calcVerticalGroundReactionForceAndSlopeError(inputs, modeledValues)
valueError = inputs.experimentalGroundReactionForces(2, :) - ...
    modeledValues.verticalGrf;
slopeError = inputs.experimentalGroundReactionForcesSlope(2, :) - ...
    calcBSplineDerivative(inputs.time, modeledValues.verticalGrf, 2, 25);
end

