% This function is part of the NMSM Pipeline, see file for full license.
%
%
% (string) -> (None)
% Set up muscle excitation controls to enforce activation dynamics.

% ----------------------------------------------------------------------- %
% The NMSM Pipeline is a toolkit for model personalization and treatment  %
% optimization of neuromusculoskeletal models through OpenSim. See        %
% nmsm.rice.edu and the NOTICE file for more information. The             %
% NMSM Pipeline is developed at Rice University and supported by the US   %
% National Institutes of Health (R01 EB030520).                           %
%                                                                         %
% Copyright (c) 2021 Rice University and the Authors                      %
% Author(s): Spencer Williams                                             %
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

function inputs = setupActivationDynamics(inputs)
if any(inputs.controllerTypes(2:3)) && inputs.useActivationDynamics
    % Parse constants needed for activation dynamics calculations
    try
        inputs.activationTimeConstants = [];
        inputs.activationNonlinearityConstants = [];
        for i = 1 : inputs.numMuscles
            currentMuscle = inputs.muscleNames(i);
            inputs.activationTimeConstants(end+1) = ...
                inputs.osimx.muscles.( ...
                currentMuscle).activationTimeConstant;
            inputs.activationNonlinearityConstants(end+1) = ...
                inputs.osimx.muscles.( ...
                currentMuscle).activationNonlinearityConstant;
        end
    catch
        error("<use_activation_dynamics> requires the .osimx model " + ...
            "file to contain an activation time constant and an " + ...
            "activation nonlinearity constant for each muscle.")
    end

    % Excitation controls will be used in the dynamic constraint
    inputs.splineExcitationControls = makeGcvSplineSet( ...
        inputs.initialTime, inputs.experimentalMuscleExcitations', ...
        inputs.muscleLabels);
    if strcmpi(inputs.solverType, 'gpops')
        inputs.initialExcitationControls = ...
            inputs.experimentalMuscleExcitations;
    else
        inputs.initialExcitationControls = evaluateGcvSplines( ...
            inputs.splineExcitationControls, ...
            inputs.muscleLabels, ...
            inputs.collocationTimeOriginalWithEnd);
    end

    % Neural activations are needed as a state because GPOPS-II dynamic
    % constraints can only associate derivatives with states
    inputs.splineNeuralActivations = makeGcvSplineSet( ...
        inputs.initialTime, calcNeuralActivationsFromMuscleActivations( ...
        inputs.experimentalMuscleActivations, ...
        inputs.activationNonlinearityConstants)', ...
        inputs.muscleLabels);
    if strcmpi(inputs.solverType, 'gpops')
        inputs.initialNeuralActivations = evaluateGcvSplines( ...
            inputs.splineNeuralActivations, ...
            inputs.muscleLabels, ...
            inputs.initialTime);
    else
        inputs.initialNeuralActivations = evaluateGcvSplines( ...
            inputs.splineNeuralActivations, ...
            inputs.muscleLabels, ...
            inputs.collocationTimeOriginalWithEnd);
    end

    % Use constraints to associate neural activation states with calculated
    % neural activations. These error values may need to be changed
    for i = 1 : inputs.numMuscles
        inputs.path{end+1} = struct( ...
            'type', 'INTERNAL_activation_dynamics', ...
            'isEnabled', true, ...
            'maxError', 0.001, ...
            'minError', -0.001, ...
            'neuralActivationIndex', i);
    end
end
end