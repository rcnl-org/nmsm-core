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
if strcmp(params.controllerType, 'synergy_driven')
    if params.optimizeSynergyVectors
        values.synergyWeights = scaleToOriginal(inputs.parameter(1,:), ...
            params.maxParameter, params.minParameter);
        values.synergyWeights = getSynergyWeightsFromGroups(...
            values.synergyWeights, params);
    else
        values.synergyWeights = getSynergyWeightsFromGroups(...
            params.synergyWeightsGuess, params);
    end
    if params.splineJointMoments.dim > 1
        values.controlSynergyActivations = ...
            fnval(params.splineSynergyActivations, values.time)';
    else
        values.controlSynergyActivations = ...
            fnval(params.splineSynergyActivations, values.time);
    end
end
for i = 1:length(params.userDefinedVariables)
    values.(params.userDefinedVariables{i}.type) = scaleToOriginal( ...
        inputs.parameter(i, 1), ...
        params.userDefinedVariables{i}.upper_bounds, ...
        params.userDefinedVariables{i}.lower_bounds);
end
end
