% This function is part of the NMSM Pipeline, see file for full license.
%
%
%
% (Array of double, struct, struct) -> (struct)
% Optimize ground contact parameters according to Jackson et al. (2016)

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

function cost = calcGroundReactionCost(values, inputs, params)
[footMarkerPositionError, footMarkerSlopeError] = ...
    calcFootMarkerPositionAndSlopeError();
cost = 2 * footMarkerPositionError;
cost = [cost 1000 * footMarkerSlopeError];
cost = [cost 10000 * calcKinematicCurveSlopeError()];
[groundReactionForceValueError, groundReactionForceSlopeError] = ...
    calcGroundReactionForceAndSlopeError();
cost = [cost groundReactionForceValueError];
cost = [cost 1 / 5 * groundReactionForceSlopeError];
cost = [cost 1 / 10 * calcSpringConstantsErrorFromMean()];
cost = [cost 1 / 100 * calcKValueFromInitialValueError()];
cost = [cost 100 * calcDampingFactorsErrorFromMean()];
cost = [cost calcSpringRestingLengthError()];
cost = [cost calcDampingFactorDeviationFromInitialValueError()];
cost = [cost calcSpringConstantDeviationFromInitialValueError()];
cost = [cost calcStaticFrictionDeviationError()];
cost = [cost calcDynamicFrictionDeviationError()];
cost = [cost calcViscousFrictionDeviationError()];
cost = [cost calcStaticToDynamicFrictionDeviationError()];

cost = cost / 50;
end

