% This function is part of the NMSM Pipeline, see file for full license.
%
% This function sets up the common initial guess for an optimal control
% problem and is used by Tracking Optimization, Verification Optimization,
% and Design Optimization
%
% (struct) -> (struct)
% return a set of setup values common to all optimal control problems

% ----------------------------------------------------------------------- %
% The NMSM Pipeline is a toolkit for model personalization and treatment  %
% optimization of neuromusculoskeletal models through OpenSim. See        %
% nmsm.rice.edu and the NOTICE file for more information. The             %
% NMSM Pipeline is developed at Rice University and supported by the US   %
% National Institutes of Health (R01 EB030520).                           %
%                                                                         %
% Copyright (c) 2021 Rice University and the Authors                      %
% Author(s): Claire V. Hammond, Marleny Vega                              %
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

function guess = setupCommonOptimalControlInitialGuess(inputs)
if isfield(inputs.initialGuess, 'state')
    guess.phase.time = scaleToBounds(inputs.initialGuess.time, inputs.maxTime, ...
        inputs.minTime);
    guess.phase.state = scaleToBounds(inputs.initialGuess.state, ...
        inputs.maxState, inputs.minState);
else
    guess.phase.state = scaleToBounds([inputs.experimentalJointAngles ...
        inputs.experimentalJointVelocities ...
        inputs.experimentalJointAccelerations], inputs.maxState, ...
        inputs.minState);
    guess.phase.time = scaleToBounds(inputs.experimentalTime, inputs.maxTime, ...
        inputs.minTime);
end
if strcmp(inputs.controllerType, 'synergy')
    if isfield(inputs.initialGuess, 'control')
        guess.phase.control = scaleToBounds(inputs.initialGuess.control, ...
            inputs.maxControl, inputs.minControl);
    else
        guess.phase.control = scaleToBounds([inputs.experimentalJointJerks ...
            inputs.synergyActivationsGuess], inputs.maxControl, inputs.minControl);
    end
    if isfield(inputs, "optimizeSynergyVectors") && ...
            inputs.optimizeSynergyVectors
        guess.parameter = scaleToBounds(inputs.synergyWeightsGuess, ...
            inputs.maxParameter, inputs.minParameter);
    end
elseif strcmp(inputs.controllerType, 'torque')
    if isfield(inputs.initialGuess, 'control')
        guess.phase.control = scaleToBounds(inputs.initialGuess.control, ...
            inputs.maxControl, inputs.minControl);
    else
        for i = 1:length(inputs.controlTorqueNames)
            indx = find(strcmp(convertCharsToStrings( ...
                inputs.inverseDynamicMomentLabels), ...
                strcat(inputs.controlTorqueNames(i), '_moment')));
            if isempty(indx)
                indx = find(strcmp(convertCharsToStrings( ...
                inputs.inverseDynamicMomentLabels), ...
                strcat(inputs.controlTorqueNames(i), '_force')));
            end
            controlTorquesGuess(:, i) = inputs.experimentalJointMoments(:, indx);
        end
        guess.phase.control = scaleToBounds([inputs.experimentalJointJerks ...
            controlTorquesGuess], inputs.maxControl, inputs.minControl);
    end
end
guess.phase.integral = scaleToBounds(1e1, inputs.maxIntegral, ...
    inputs.minIntegral);
end