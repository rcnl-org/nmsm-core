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

function cost = calcMuscleExcitationPenaltyCost(modeledValues, ...
    experimentalData, costTerm)
errorCenter = valueOrAlternate(costTerm, "errorCenter", 0.5);
maximumAllowableError = valueOrAlternate(costTerm, "maxAllowableError", 0.25);
muscleExcitationsConstraint = modeledValues.muscleExcitationsNoTDelay(: , ...
    setdiff(1 : size(modeledValues.muscleExcitationsNoTDelay, 2), ...
    [experimentalData.synergyExtrapolation.missingEmgChannelGroups{:}]), ...
    experimentalData.numPaddingFrames + 1 : ...
    size(modeledValues.muscleExcitationsNoTDelay, 3) - ...
    experimentalData.numPaddingFrames);
cost = 30 / maximumAllowableError * (muscleExcitationsConstraint - errorCenter) .^ 8;
cost(isnan(cost))=0;
cost = sum((sqrt(0.1) .* cost).^ 2, 'all');
end