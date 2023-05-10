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

function output = computeDesignOptimizationMainFunction(inputs, params)
bounds = setupProblemBounds(inputs);
guess = setupCommonOptimalControlInitialGuess(inputs);
setup = setupSolverSettings(inputs, bounds, guess, params);
solution = gpops2(setup);
solution = solution.result.solution;
solution.auxdata = inputs;
output = computeDesignOptimizationContinuousFunction(solution);
output.solution = solution;
end

function bounds = setupProblemBounds(inputs)
bounds = setupCommonOptimalControlBounds(inputs);
% setup parameter bounds
if strcmp(inputs.controllerType, 'synergy_driven')
    if inputs.optimizeSynergyVectors
        bounds.parameter.lower = -0.5 * ones(1, length(inputs.minParameter));
        bounds.parameter.upper = 0.5 * ones(1, length(inputs.minParameter));
    end
end
end


function setup = setupSolverSettings(inputs, bounds, guess, params)

setup.name = params.solverSettings.optimizationFileName;
setup.functions.continuous = @computeDesignOptimizationContinuousFunction;
auxdata.ContinuousFunc = setup.functions.continuous;
setup.functions.endpoint = @computeDesignOptimizationEndpointFunction;
setup.auxdata = inputs;
setup.bounds = bounds;
setup.guess = guess;
setup.nlp.solver = params.solverSettings.solverType;
setup.nlp.ipoptoptions.linear_solver = params.solverSettings.linearSolverType;
setup.nlp.ipoptoptions.tolerance = params.solverSettings.solverTolerance;
setup.nlp.ipoptoptions.maxiterations = params.solverSettings.maxIterations;
setup.nlp.snoptoptions.linear_solver = params.solverSettings.linearSolverType;
setup.nlp.snoptoptions.tolerance = params.solverSettings.solverTolerance;
setup.nlp.snoptoptions.maxiterations = params.solverSettings.maxIterations;
setup.derivatives.stepsize1 = params.solverSettings.stepSize;
setup.derivatives.supplier = params.solverSettings.derivativeApproximation;
setup.derivatives.derivativelevel = params.solverSettings.derivativeOrder;
setup.derivatives.dependencies = params.solverSettings.derivativeDependencies;
mesh.method = params.solverSettings.meshMethod;
mesh.tolerance = params.solverSettings.meshTolerance;
mesh.maxiterations = params.solverSettings.meshMaxIterations;
N = params.solverSettings.collocationPoints;
mesh.phase.colpoints = 10*ones(1, N);
mesh.phase.fraction = ones(1, N) / N;
setup.method = params.solverSettings.method;
setup.mesh = mesh;
end