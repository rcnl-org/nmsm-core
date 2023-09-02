% This function is part of the NMSM Pipeline, see file for full license.
%
% This function sets up the input variables and mex files (or parallel 
% matlab function) for the main function of design optimization
%
% (struct, struct) -> (struct, struct)
% Inputs for the main function are setup

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

function [output, inputs] = DesignOptimization(inputs, params)
inputs = makeTreatmentOptimizationInputs(inputs, params);
initializeMexOrMatlabParallelFunctions(inputs.mexModel);
if strcmp(inputs.controllerType, 'synergy_driven')
    inputs = setupMuscleSynergies(inputs);
end
if inputs.enableExternalTorqueControl
    inputs = setupExternalTorqueControls(inputs);
end
output = computeDesignOptimizationMainFunction(inputs, params);
end

function inputs = setupMuscleSynergies(inputs)
inputs.splineSynergyActivations = spaps(inputs.initialGuess.time/inputs.initialGuess.time(end), ...
    inputs.initialGuess.control(:, inputs.numCoordinates + 1 : ...
    inputs.numCoordinates + inputs.numSynergies)', 0.0000001);
inputs.synergyLabels = inputs.initialGuess.controlLabels(:, ...
    inputs.numCoordinates + 1 : inputs.numCoordinates + inputs.numSynergies);
end

function inputs = setupExternalTorqueControls(inputs)
if size(inputs.initialGuess.control, 2) ~= length(inputs.maxControl)
    inputs.initialGuess.control = [inputs.initialGuess.control ...
        zeros(size(inputs.initialGuess.control, 1), ...
        inputs.numExternalTorqueControls)];
end
end