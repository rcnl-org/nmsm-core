% This function is part of the NMSM Pipeline, see file for full license.
%
% This function tracks the difference between the predicted step length 
% asymmetry and the error center specified. An error center of "1" would
% encourage step legth symmetry. 
%
% (struct, struct, struct, struct) -> (Array of number)
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

function cost = calcStepLengthAsymmetryIntegrand(values, modeledValues,...
    params, costTerm)

errorCenter = valueOrAlternate(costTerm, "errorCenter", 1);
stepLengthAsymmetry = calcStepLengthAsymmetry(modeledValues,...
    params, costTerm.reference_body);
cost = calcTrackingCostArrayTerm(stepLengthAsymmetry * ...
    ones(length(values.time), 1), errorCenter * ...
    ones(length(values.time), 1), 1);
end