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

function setup = convertToGpopsSynergyDrivenInputs(inputs, params)
bounds = setupProblemBounds(inputs, params);
guess = setupGpopsInitialGuess(inputs);
if strcmp(inputs.toolName, "DesignOptimization")
    guess = addUserDefinedTermsToGuess(guess, inputs);
end
initializeMexOrMatlabParallelFunctions(inputs.mexModel);
setup = setupGpopsSettings(inputs, ...
    bounds, guess, params, ...
    @computeGpopsContinuousFunction, ...
    @computeGpopsEndpointFunction);
checkInitialGuess(guess, inputs, ...
    @computeGpopsContinuousFunction);
end

function bounds = setupProblemBounds(inputs, params)
bounds = setupCommonOptimalControlBounds(inputs, params);
% setup parameter bounds
if strcmp(inputs.controllerType, 'synergy')
    if inputs.optimizeSynergyVectors
        bounds.parameter.lower = -0.5 * ones(1, length(inputs.minParameter));
        bounds.parameter.upper = 0.5 * ones(1, length(inputs.minParameter));
    end
end
if strcmp(inputs.toolName, "DesignOptimization")
    for i = 1:length(inputs.userDefinedVariables)
        variable = inputs.userDefinedVariables{i};
        if ~isfield(bounds, "parameter") || ...
                ~isfield(bounds.parameter, "lower")
            bounds.parameter.lower = [-0.5];
            bounds.parameter.upper = [0.5];
        else
            bounds.parameter.lower = [bounds.parameter.lower, ...
                -0.5];
            bounds.parameter.upper = [bounds.parameter.upper, ...
                0.5];
        end
    end
end
end

function guess = addUserDefinedTermsToGuess(guess, inputs)
for i = 1:length(inputs.userDefinedVariables)
    variable = inputs.userDefinedVariables{i};
    if ~isfield(guess, "parameter")
        guess.parameter = [];
    end
    guess.parameter = [guess.parameter, ...
        scaleToBounds( ...
        variable.initial_values, ...
        variable.upper_bounds, ...
        variable.lower_bounds)];
end
end
