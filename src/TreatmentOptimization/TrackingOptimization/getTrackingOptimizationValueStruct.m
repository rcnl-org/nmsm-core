% This function is part of the NMSM Pipeline, see file for full license.
%
% This function parses and scales the design variables specific to
% Tracking Optimization. If the model is synergy driven, synergy weights 
% are properly calculated if they are fixed or being optimized.
%
% (struct, struct) -> (struct)
% Design variables specific to Tracking Optimization are parsed and scaled

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

function values = getTrackingOptimizationValueStruct(phase, inputs)
values = getTreatmentOptimizationValueStruct(phase, inputs);
if strcmp(inputs.controllerType, 'synergy')
    if inputs.optimizeSynergyVectors
        synergyWeights = scaleToOriginal(phase.parameter(1,:), ...
            inputs.maxParameter, inputs.minParameter);
        values.synergyWeights = synergyWeights;
    else
        values.synergyWeights = inputs.synergyWeights;
    end
end
end
