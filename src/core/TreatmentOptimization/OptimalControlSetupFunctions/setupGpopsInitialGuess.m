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

function guess = setupGpopsInitialGuess(inputs)
guess = struct();
guess = setupInitialStatesGuess(inputs, guess);
guess = setupInitialControlsGuess(inputs, guess);
guess = setupInitialParametersGuess(inputs, guess);
guess.phase.integral = scaleToBounds(1e1, inputs.maxAllowableError, ...
    zeros(size(inputs.maxAllowableError)));
end

function guess = setupInitialStatesGuess(inputs, guess)
if isfield(inputs, "initialStates")
    guess.phase.state = scaleToBounds(inputs.initialStates, ...
        inputs.maxState, inputs.minState);
    guess.phase.time = scaleToBounds(inputs.initialTime, inputs.maxTime, ...
        inputs.minTime);
else
    guess.phase.state = scaleToBounds([inputs.experimentalJointAngles ...
        inputs.experimentalJointVelocities ...
        inputs.experimentalJointAccelerations], inputs.maxState, ...
        inputs.minState);
    guess.phase.time = scaleToBounds(inputs.experimentalTime, inputs.maxTime, ...
        inputs.minTime);
end
end

function guess = setupInitialControlsGuess(inputs, guess)
if isfield(inputs, "initialJerks")
    controls = inputs.initialJerks;
else
    controls = inputs.experimentalJointJerks;
end
if strcmp(inputs.controllerType, "synergy")
    if isfield(inputs, "initialSynergyControls")
        controls = [controls, inputs.initialSynergyControls];
    else
        throw(MException("NoInitialSynergyControls", ...
            "initial synergy controls required for synergy driven"))
    end
end
if isfield(inputs, "initialTorqueControls")
    controls = [controls, inputs.initialTorqueControls];
else
    if ~isempty(valueOrAlternate(inputs, "torqueControllerCoordinateNames", []))
        controls = [controls, inputs.experimentalJointMoments];
    end
end
guess.phase.control = scaleToBounds(controls, inputs.maxControl, ...
    inputs.minControl);
end

function guess = setupInitialParametersGuess(inputs, guess)
if valueOrAlternate(inputs, "optimizeSynergyVectors", false)
    guess.parameter = scaleToBounds(inputs.synergyWeights, ...
        inputs.maxParameter, inputs.minParameter);
end
end