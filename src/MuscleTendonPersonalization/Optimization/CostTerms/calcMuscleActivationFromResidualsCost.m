% This function is part of the NMSM Pipeline, see file for full license.
%
% (Array of number, struct) -> (Array of number)
% returns the cost for all rounds of the Muscle Tendon optimization

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

function cost = calcMuscleActivationFromResidualsCost(synxModeledValues, ...
    modeledValues, experimentalData, params)
costWeight = valueOrAlternate(params, ...
    "muscleActivationsFromResidualsCostWeight", 1);
errorCenter = valueOrAlternate(params, ...
    "muscleActivationsFromResidualsErrorCenter", 0);
maximumAllowableError = valueOrAlternate(params, ...
    "muscleActivationsFromResidualsMaximumAllowableError", 0.3);

cost = costWeight * calcDeviationCostTerm(...
    synxModeledValues.muscleActivations(:, setdiff(1 : ...
    size(synxModeledValues.muscleActivations, 2), ...
    [experimentalData.synergyExtrapolation.missingEmgChannelGroups{:}]), :) - ...
    modeledValues.muscleActivations(:, setdiff(1 : ...
    size(synxModeledValues.muscleActivations, 2), ...
    [experimentalData.synergyExtrapolation.missingEmgChannelGroups{:}]), :), ...
    errorCenter, maximumAllowableError);
end