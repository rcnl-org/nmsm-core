% This function is part of the NMSM Pipeline, see file for full license.
%
% This function ensures the synergy weights are normalized to sum to one
% and the synergy commands are scaled in proportion
%
% (struct) -> (struct)
% scale synergy weights and commands for sum of weights to equal one

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

function inputs = normalizeSynergyData(inputs)
if inputs.controllerTypes(2)
    method = lower(inputs.synergyNormalizationMethod);
    switch method
        case "sum"
            for i = 1:size(inputs.synergyWeights, 1)
                total = sum(inputs.synergyWeights(i, :)) / ...
                    inputs.synergyNormalizationValue;
                inputs.synergyWeights(i, :) = ...
                    inputs.synergyWeights(i, :) / total;
                inputs.initialSynergyControls(:, i) = ...
                    inputs.initialSynergyControls(:, i) * total;
            end
        case "magnitude"
            for i = 1:size(inputs.synergyWeights, 1)
                total = norm(inputs.synergyWeights(i, :)) / ...
                    inputs.synergyNormalizationValue;
                inputs.synergyWeights(i, :) = ...
                    inputs.synergyWeights(i, :) / total;
                inputs.initialSynergyControls(:, i) = ...
                    inputs.initialSynergyControls(:, i) * total;
            end
        case "none"
        otherwise
            throw(MException('', "Only 'sum', 'magnitude', and " + ...
                "'none' are supported synergy normalization methods."))
    end
    inputs.initialSynergyWeights = inputs.synergyWeights;
end
end

