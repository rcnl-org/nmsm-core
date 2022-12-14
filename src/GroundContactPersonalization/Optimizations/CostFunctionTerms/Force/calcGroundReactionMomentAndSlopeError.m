% This function is part of the NMSM Pipeline, see file for full license.
%
%
%
% (struct, struct) -> (Array of double, Array of double)
% Optimize ground contact parameters according to Jackson et al. (2016)

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
    calcGroundReactionMomentAndSlopeError(inputs, modeledValues)
valueErrors(1, :) = inputs.experimentalGroundReactionMoments(1, :) -...
    modeledValues.xGrfMoment;
slopeErrors(1, :) = inputs.experimentalGroundReactionMomentsSlope(...
    1, :) - calcBSplineDerivative(inputs.time, ...
    modeledValues.xGrfMoment, 2, 25);
valueErrors(2, :) = inputs.experimentalGroundReactionMoments(2, :) -...
    modeledValues.yGrfMoment;
slopeErrors(2, :) = inputs.experimentalGroundReactionMomentsSlope(...
    2, :) - calcBSplineDerivative(inputs.time, ...
    modeledValues.yGrfMoment, 2, 25);
valueErrors(3, :) = inputs.experimentalGroundReactionMoments(3, :) -...
    modeledValues.zGrfMoment;
slopeErrors(3, :) = inputs.experimentalGroundReactionMomentsSlope(...
    3, :) - calcBSplineDerivative(inputs.time, ...
    modeledValues.zGrfMoment, 2, 25);
end