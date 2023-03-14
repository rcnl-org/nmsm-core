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

function values = getTrackingOptimizationValueStruct(inputs, params)

values.time = scaleToOriginal(inputs.time, params.maxTime, ...
    params.minTime);
state = scaleToOriginal(inputs.state, ones(size(inputs.state, 1), 1) .* ...
    params.maxState, ones(size(inputs.state, 1), 1) .* params.minState);
control = scaleToOriginal(inputs.control, ones(size(inputs.control, 1), 1) .* ...
    params.maxControl, ones(size(inputs.control, 1), 1) .* params.minControl);
values.statePositions = getCorrectStates(state, 1, params.numCoordinates);
values.stateVelocities = getCorrectStates(state, 2, params.numCoordinates);
values.stateAccelerations = getCorrectStates(state, 3, params.numCoordinates);
values.controlJerks = control(:, 1 : params.numCoordinates);
if strcmp(params.controllerType, 'synergy_driven') 
    if params.optimizeSynergyVectors 
        values.synergyWeights = scaleToOriginal(inputs.parameter(1,:), ...
            params.maxParameter, params.minParameter);
        values.synergyWeights = getSynergyWeightsFromGroups(...
            values.synergyWeights, params);
    else
        values.synergyWeights = getSynergyWeightsFromGroups(...
            params.parameterGuess, params);
    end
    values.controlNeuralCommands = control(:, params.numCoordinates + 1 : ...
    params.numCoordinates + params.numSynergies);
else
    values.controlTorques = control(:, params.numCoordinates + 1 : ...
    params.numCoordinates + params.numTorqueControls);
end

end
function output = getCorrectStates(state, index, numCoordinates)

startIndex = (numCoordinates * (index - 1)) + 1;
endIndex = numCoordinates * index;
output = state(:, startIndex:endIndex);
end
function value = scaleToOriginal(value, maximum, minimum)

value = value .* (maximum - minimum) + (maximum + minimum) / 2;
end