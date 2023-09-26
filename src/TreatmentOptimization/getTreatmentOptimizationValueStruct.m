% This function is part of the NMSM Pipeline, see file for full license.
%
% This function parses and scales the design variables common to all 
% treatment optimization modules (tracking, verification, and design 
% optimization). Time, states, and controls are parsed and scaled back to
% their original values.
%
% (struct, struct) -> (struct)
% Design variables common to all treatment optimization modules are parsed

% ----------------------------------------------------------------------- %
% The NMSM Pipeline is a toolkit for model personalization and treatment  %
% optimization of neuromusculoskeletal models through OpenSim. See        %
% nmsm.rice.edu and the NOTICE file for more information. The             %
% NMSM Pipeline is developed at Rice University and supported by the US   %
% National Institutes of Health (R01 EB030520).                           %
%                                                                         %
% Copyright (c) 2021 Rice University and the Authors                      %
% Author(s): Marleny Vega, Claire V. Hammond                              %
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

function values = getTreatmentOptimizationValueStruct(phase, inputs)

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

if ~strcmp(inputs.controllerType, 'synergy')
    values.controlTorques = control(:, inputs.numCoordinates + 1 : ...
    inputs.numCoordinates + length(inputs.torqueControllerCoordinateNames));
else 
    values.controlSynergyActivations = control(:, ...
    inputs.numCoordinates + 1 : inputs.numCoordinates + inputs.numSynergies);
end
end