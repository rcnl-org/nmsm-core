% This function is part of the NMSM Pipeline, see file for full license.
%
% This function runs fmincon for MuscleTendonPersonalization with settings
% controlled by the input params.
%
% (Array of number, struct, struct) -> (Array of number)
% returns the optimized values from Muscle Tendon optimization round

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

function optimizedValues = computeMuscleTendonRoundOptimization( ...
    initialValues, params, optimizerOptions)

A = makeA(initialValues, params);
b = makeb(initialvalues, params);
lowerBounds = makeLowerBounds(initialValues, params);
upperBounds = makeUpperBounds(initialValues, params);

optimizedValues = fmincon(@(values)computeMuscleTendonCostFunction( ...
    values, params), initialValues, A, b, [], [], lowerBounds, ...
    upperBounds, @(values)nonlcon(values, params), optimizerOptions-);

end

function A = makeA(values, params)

end

function b = makeB(values, params)

end

function lowerBounds = makeLowerBounds(values, params)

end

function upperBounds = makeUpperBounds(values, params)

end