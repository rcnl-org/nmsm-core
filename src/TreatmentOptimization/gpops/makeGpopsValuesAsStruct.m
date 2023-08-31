% This function is part of the NMSM Pipeline, see file for full license.
%
% This function takes the raw values from gpops and turns them into a
% struct that can be interacted with more easily during calculations
%
% (struct, struct) -> (struct)
%

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

function values = makeGpopsValuesAsStruct(phase, inputs)
values.time = scaleToOriginal(phase.time, inputs.maxTime, ...
    inputs.minTime);
state = scaleToOriginal(phase.state, ones(size(phase.state, 1), 1) .* ...
    inputs.maxState, ones(size(phase.state, 1), 1) .* inputs.minState);
control = scaleToOriginal(phase.control, ones(size(phase.control, 1), 1) .* ...
    inputs.maxControl, ones(size(phase.control, 1), 1) .* inputs.minControl);
values.statePositions = getCorrectStates(state, 1, inputs.numCoordinates);
values.stateVelocities = getCorrectStates(state, 2, inputs.numCoordinates);
values.stateAccelerations = getCorrectStates(state, 3, inputs.numCoordinates);
values.controlJerks = control(:, 1 : inputs.numCoordinates);

if ~strcmp(inputs.controllerType, 'synergy_driven')
    values.controlTorques = control(:, inputs.numCoordinates + 1 : ...
        inputs.numCoordinates + inputs.numTorqueControls);
else
    values.controlSynergyActivations = control(:, ...
        inputs.numCoordinates + 1 : inputs.numCoordinates + inputs.numSynergies);
end

if strcmp(inputs.toolName, "TreatmentOptimization")
    if strcmp(inputs.controllerType, 'synergy_driven')
        if inputs.optimizeSynergyVectors
            synergyWeights = scaleToOriginal(phase.parameter(1,:), ...
                inputs.maxParameter, inputs.minParameter);
            values.synergyWeights = getSynergyWeightsFromGroups(...
                synergyWeights, inputs);
        else
            values.synergyWeights = getSynergyWeightsFromGroups(...
                inputs.synergyWeightsGuess, inputs);
        end
    end
end
if strcmp(inputs.toolName, "VerificationOptimization")
    if strcmp(inputs.controllerType, 'synergy_driven')
        values.synergyWeights = getSynergyWeightsFromGroups(...
            inputs.synergyWeightsGuess, inputs);
    end
end
if strcmp(inputs.toolName, "DesignOptimization")
    numParameters = 0;
    if strcmp(params.controllerType, 'synergy_driven')
        if params.optimizeSynergyVectors
            values.synergyWeights = scaleToOriginal(inputs.parameter(1, ...
                1 : params.numSynergyWeights), ...
                params.maxParameter, params.minParameter);
            values.synergyWeights = getSynergyWeightsFromGroups(...
                values.synergyWeights, params);
            numParameters = params.numSynergyWeights;
        else
            values.synergyWeights = getSynergyWeightsFromGroups(...
                params.synergyWeightsGuess, params);
        end
        if params.splineSynergyActivations.dim > 1
            values.controlSynergyActivations = ...
                fnval(params.splineSynergyActivations, values.time)';
        else
            values.controlSynergyActivations = ...
                fnval(params.splineSynergyActivations, values.time);
        end
        if params.enableExternalTorqueControl
            controls = scaleToOriginal(inputs.control, ones(size( ...
                inputs.control, 1), 1) .* params.maxControl, ...
                ones(size(inputs.control, 1), 1) .* params.minControl);
            values.externalTorqueControls = controls(:, params.numCoordinates + ...
                params.numSynergies + 1 : end);
        end
    else
        if isfield(params, "enableExternalTorqueControl") && ...
                params.enableExternalTorqueControl
            controls = scaleToOriginal(inputs.control, ones(size( ...
                inputs.control, 1), 1) .* params.maxControl, ...
                ones(size(inputs.control, 1), 1) .* params.minControl);
            values.externalTorqueControls = controls(:, params.numCoordinates + ...
                params.numTorqueControls + 1 : end);
        end
    end
    if isfield(params, 'userDefinedVariables')
        for i = 1:length(params.userDefinedVariables)
            values.(params.userDefinedVariables{i}.type)(i) = scaleToOriginal( ...
                inputs.parameter(1, i + numParameters), ...
                params.userDefinedVariables{i}.upper_bounds, ...
                params.userDefinedVariables{i}.lower_bounds);
        end
    end
end
end
