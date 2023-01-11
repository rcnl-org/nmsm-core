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

function phaseout = computeTrackingOptimizationMainFunction(inputs, params)

load('inputData.mat')
params.modelName = 'optModel_GPOPS.osim';
pointKinematics(params.modelName);
inverseDynamics(params.modelName);

if params.runOptimization
bounds = setupProblemBounds(params);
guess = setupInitialGuess(params);
setup = setupSolverSettings(params, bounds, guess, params);
output = gpops2(setup);
solution = output.result.solution;
save(params.solutionFileName, 'solution', 'params');
save(params.outputFileName, 'output');
end
inputs = solution.phase;
outputContinuous = computeTrackingOptimizationContinuousFunction(inputs, params);
% plotSolution(solution, params, outputContinuous)
end
function bounds = setupProblemBounds(params)
% setup time bounds
bounds.phase.initialtime.lower = -0.5;
bounds.phase.initialtime.upper = -0.5;
bounds.phase.finaltime.lower = 0.5;
bounds.phase.finaltime.upper = 0.5;
% setup state bounds
bounds.phase.initialstate.lower = -0.5 * ones(1, length(params.minState));
bounds.phase.initialstate.upper = 0.5 * ones(1, length(params.minState));
bounds.phase.finalstate.lower = -0.5 * ones(1, length(params.minState));
bounds.phase.finalstate.upper = 0.5 * ones(1, length(params.minState));
bounds.phase.state.lower = -0.5 * ones(1, length(params.minState));
bounds.phase.state.upper = 0.5 * ones(1, length(params.minState));
% setup path constraint bounds
bounds.phase.path.lower = -0.5 * ones(1, length(params.minPath));
bounds.phase.path.upper = 0.5 * ones(1, length(params.minPath));
% setup control bounds
bounds.phase.control.lower = -0.5 * ones(1, length(params.minControl));
bounds.phase.control.upper = 0.5 * ones(1, length(params.minControl));
% setup integral bounds
bounds.phase.integral.lower = zeros(1, length(params.minIntegral));
bounds.phase.integral.upper = ones(1, length(params.minIntegral));
% % setup terminal constraint bounds
% bounds.eventgroup.lower = params.eventgroup.lower;
% bounds.eventgroup.upper = params.eventgroup.upper;
% setup parameter bounds
bounds.parameter.lower = -0.5 * ones(1, length(params.minParameter));
bounds.parameter.upper = 0.5 * ones(1, length(params.minParameter));
end
function guess = setupInitialGuess(params)

if params.loadInitialGuess
    load(params.initialGuessFileName)
    guess = solution;
    if length(guess.phase.integral) ~= length(params.maxIntegral)
        guess.phase.integral = scaleToBounds(1e1, params.maxIntegral, ...
        params.minIntegral);
    end
else
    guess.phase.time = scaleToBounds(params.time, params.maxTime, ...
        params.minTime);
    guess.phase.state = scaleToBounds([params.jointAngles ...
        params.jointVelocities params.jointAcceleration], ...
        params.maxState, params.minState);
    guess.phase.control = scaleToBounds([params.jointJerk ...
        params.neuralCommandsRight params.neuralCommandsLeft], ...
        params.maxControl, params.minControl);
    guess.phase.integral = scaleToBounds(1e1, params.maxIntegral, ...
        params.minIntegral);
    guess.parameter = scaleToBounds(params.synergyWeights, ...
        params.maxParameter, params.minParameter);
end
end
function scaledValue = scaleToBounds(value, maximum, minimum)

scaledValue = (value - (maximum + minimum) / 2) ./ (maximum + minimum);
end
function setup = setupSolverSettings(params, bounds, guess, solver)

setup.name = params.optimizationFileName;
setup.functions.continuous = @computeTrackingOptimizationContinuousFunction;
auxdata.ContinuousFunc = setup.functions.continuous;
setup.functions.endpoint = @computeTrackingOptimizationEndpointFunction;
setup.auxdata = params;
setup.bounds = bounds;
setup.guess = guess;
setup.nlp.solver = solver.type;
setup.nlp.ipoptoptions.linear_solver = 'ma57';
setup.nlp.ipoptoptions.tolerance = solver.tolerance;
setup.nlp.ipoptoptions.maxiterations = solver.maxIterations;
setup.derivatives.stepsize1 = solver.stepSize;
setup.derivatives.supplier = 'sparseCD';
setup.derivatives.derivativelevel = 'first';
setup.derivatives.dependencies = 'sparse';
mesh.method = 'hp-PattersonRao';
mesh.tolerance = solver.mesh.tolerance;
mesh.maxiterations = solver.mesh.maxIterations;
mesh.colpointsmin = solver.mesh.minColPoints;
mesh.colpointsmax = solver.mesh.maxColPoints;
N = solver.mesh.N;
mesh.phase.colpoints = 10*ones(1, N);
mesh.phase.fraction = ones(1, N) / N;
setup.method = 'RPM-integration';
setup.mesh = mesh;
end