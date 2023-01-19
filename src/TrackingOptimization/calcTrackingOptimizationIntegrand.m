% This function is part of the NMSM Pipeline, see file for full license.
%
% () -> ()
% 

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

function integrand = calcTrackingOptimizationIntegrand(values, params, ...
    phaseout)

persistent experimentalJointAngles experimentalJointVelocities ...
    experimentalJointMoments experimentalMuscleActivations ...
    experimentalRightGroundReactions experimentalLeftGroundReactions

integrand = calcTrackingJointAngleIntegrand(experimentalJointAngles, ...
    values.statePositions, values.time, params);
% integrand = [integrand ...
%     calcTrackingJointVelocityIntegrand(experimentalJointVelocities, ...
%     values.stateVelocities, values.time, params)];
integrand = [integrand ...
    calcTrackingRightGroundReactionsIntegrand(experimentalRightGroundReactions, ...
    phaseout.rightGroundReactionsLab, values.time, params)];
integrand = [integrand ...
    calcTrackingLeftGroundReactionsIntegrand(experimentalLeftGroundReactions, ...
    phaseout.leftGroundReactionsLab, values.time, params)];
integrand = [integrand ...
    calcTrackingJointMomentIntegrand(experimentalJointMoments, ...
    phaseout.inverseDynamicMoments, values.time, params)];
integrand = [integrand ...
    calcTrackingMuscleActivationIntegrand(experimentalMuscleActivations, ...
    phaseout.muscleActivations, values.time, params)];
% integrand = [integrand ...
%     calcMinimizingJointAccelerationIntegrand(values.stateAccelerations, params)];
integrand = [integrand ...
    calcMinimizingJointJerkIntegrand(values.controlJerks, params)];

integrand = params.maxTime / values.time(end) * (integrand) ./ ...
    (params.maxIntegral - params.minIntegral);
end