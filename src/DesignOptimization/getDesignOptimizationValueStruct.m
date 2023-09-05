% This function is part of the NMSM Pipeline, see file for full license.
%
% This function parses and scales the design variables specific to
% Design Optimization. If the model is synergy driven, synergy weights are
% properly calculated if they are fixed or being optimized. If the model
% has user defined parameters, they are parsed and scaled. Lastly, if
% the model has external torque actuators, they are parsed and
% scaled.
%
% (struct, struct) -> (struct)
% Design variables specific to Design Optimization are parsed and scaled

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

function values = getDesignOptimizationValueStruct(inputs, params)
values = getTreatmentOptimizationValueStruct(inputs, params);

numParameters = 0;
if strcmp(params.controllerType, 'synergy')
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