% This function is part of the NMSM Pipeline, see file for full license.
%
% This function sets up GPOPS-II to run Tracking Optimization.
%
% (struct) -> (struct, struct)
% Assigns optimal control settings and runs Tracking Optimization

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

function output = computeTrackingOptimizationMainFunction(inputs, params)
bounds = setupProblemBounds(inputs, params);
guess = setupCommonOptimalControlInitialGuess(inputs);
setup = setupCommonOptimalControlSolverSettings(inputs, ...
    bounds, guess, params, ...
    @computeTrackingOptimizationContinuousFunction, ...
    @computeTrackingOptimizationEndpointFunction);
checkInitialGuess(guess, inputs, ...
    @computeTrackingOptimizationContinuousFunction);
solution = gpops2(setup);
solution = solution.result.solution;
solution.auxdata = inputs;
if inputs.optimizeSynergyVectors
    solution.phase.parameter = solution.parameter;
end
output = computeTrackingOptimizationContinuousFunction(solution);
output.solution = solution;
end

function bounds = setupProblemBounds(inputs, params)
bounds = setupCommonOptimalControlBounds(inputs, params);
% setup parameter bounds
if strcmp(inputs.controllerType, 'synergy_driven')
    if inputs.optimizeSynergyVectors
        bounds.parameter.lower = -0.5 * ones(1, length(inputs.minParameter));
        bounds.parameter.upper = 0.5 * ones(1, length(inputs.minParameter));
    end
end
end
