% This function is part of the NMSM Pipeline, see file for full license.
%
%

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

function [setup, inputs] = convertToGpopsInputs(inputs, params)
if isfield(inputs, 'gpops') && ~strcmpi(inputs.gpops.scaleMethods, 'none')
    bounds = setupUnscaledTreatmentOptimizationBounds(inputs, params);
else
    bounds = setupTreatmentOptimizationBounds(inputs, params);
end
[inputs, guess] = setupGpopsInitialGuess(inputs);
setup = setupGpopsSettings(inputs, ...
    bounds, guess, params, ...
    @computeGpopsContinuousFunction, ...
    @computeGpopsEndpointFunction);

setup = preSplineGpopsInputs(setup);
inputs = checkInitialGuess(guess, setup.auxdata, ...
    @computeGpopsContinuousFunction);
setup.auxdata.initialIntegrand = inputs.initialIntegrand;
setup = preSplineGpopsInputs(setup);
setup.auxdata = rmfield(setup.auxdata, "initialIntegrand");
global initialIntegral
setup.guess.phase.integral = initialIntegral;
[setup, inputs] = setupMetabolicCost(setup, inputs);
numMissing = length(initialIntegral) - length(setup.bounds.phase.integral.lower);
if strcmp(inputs.solverType, 'gpops')
    setup.bounds.phase.integral.lower(end + 1: end + numMissing) = 0;
    setup.bounds.phase.integral.upper(end + 1: end + numMissing) = ...
        (inputs.gpops.integralBound + 1) * ...
        initialIntegral(end - numMissing + 1 : end);
end
end

function [setup, inputs] = setupMetabolicCost(setup, inputs)
if valueOrAlternate(inputs, 'calculateMetabolicCost', false)
    setup.auxdata.initialMetabolicCost = inputs.initialMetabolicCost;
    preSplineGpopsInputs(setup);
    global initialMetabolicCost
    inputs.initialMetabolicCost = initialMetabolicCost;
    if strcmp(inputs.solverType, 'gpops')
        setup.bounds.phase.integral.lower(end + 1) = 0;
        setup.bounds.phase.integral.upper(end + 1) = ...
            (inputs.gpops.integralBound + 1) * ...
            max(inputs.initialMetabolicCost);
    end
end
end


