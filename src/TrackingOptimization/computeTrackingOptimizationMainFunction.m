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

function output = computeTrackingOptimizationMainFunction(inputs, params)
bounds = setupProblemBounds(inputs);
guess = setupInitialGuess(inputs);
setup = setupSolverSettings(inputs, bounds, guess, params);
solution = gpops2(setup);
solution = solution.result.solution;
solution.auxdata = inputs;
if inputs.optimizeSynergyVectors
    solution.phase.parameter = solution.parameter;
end
output = computeTrackingOptimizationContinuousFunction(solution);
output.solution = solution;
end
function bounds = setupProblemBounds(inputs)
% setup time bounds
bounds.phase.initialtime.lower = -0.5;
bounds.phase.initialtime.upper = -0.5;
bounds.phase.finaltime.lower = 0.5;
bounds.phase.finaltime.upper = 0.5;
% setup state bounds
bounds.phase.initialstate.lower = -0.5 * ones(1, length(inputs.minState));
bounds.phase.initialstate.upper = 0.5 * ones(1, length(inputs.minState));
bounds.phase.finalstate.lower = -0.5 * ones(1, length(inputs.minState));
bounds.phase.finalstate.upper = 0.5 * ones(1, length(inputs.minState));
bounds.phase.state.lower = -0.5 * ones(1, length(inputs.minState));
bounds.phase.state.upper = 0.5 * ones(1, length(inputs.minState));
% setup path constraint bounds
bounds.phase.path.lower = -0.5 * ones(1, length(inputs.minPath));
bounds.phase.path.upper = 0.5 * ones(1, length(inputs.minPath));
% setup control bounds
bounds.phase.control.lower = -0.5 * ones(1, length(inputs.minControl));
bounds.phase.control.upper = 0.5 * ones(1, length(inputs.minControl));
% setup integral bounds
bounds.phase.integral.lower = zeros(1, length(inputs.minIntegral));
bounds.phase.integral.upper = ones(1, length(inputs.minIntegral));
% setup terminal constraint bounds
bounds.eventgroup.lower = inputs.minTerminal;
bounds.eventgroup.upper = inputs.maxTerminal;
% setup parameter bounds
if strcmp(inputs.controllerType, 'synergy_driven') 
if inputs.optimizeSynergyVectors
    bounds.parameter.lower = -0.5 * ones(1, length(inputs.minParameter));
    bounds.parameter.upper = 0.5 * ones(1, length(inputs.minParameter));
end
end
end
function guess = setupInitialGuess(inputs)

if isfield(inputs.initialGuess, 'state')
    guess.phase.time = scaleToBounds(inputs.initialGuess.time, inputs.maxTime, ...
        inputs.minTime);
    guess.phase.state = scaleToBounds(inputs.initialGuess.state, ...
        inputs.maxState, inputs.minState);
else
    guess.phase.state = scaleToBounds([inputs.experimentalJointAngles ...
        inputs.experimentalJointVelocities ...
        inputs.experimentalJointAccelerations], inputs.maxState, ...
        inputs.minState);
    guess.phase.time = scaleToBounds(inputs.experimentalTime, inputs.maxTime, ...
        inputs.minTime);
end
if strcmp(inputs.controllerType, 'synergy_driven') 
if isfield(inputs.initialGuess, 'control')
    guess.phase.control = scaleToBounds(inputs.initialGuess.control, ...
        inputs.maxControl, inputs.minControl);
else
    guess.phase.control = scaleToBounds([inputs.experimentalJointJerks ...
        inputs.commandsGuess], inputs.maxControl, inputs.minControl);
end
if inputs.optimizeSynergyVectors
        guess.phase.parameter = scaleToBounds(inputs.parameterGuess, ...
            inputs.maxParameter, inputs.minParameter);
end
elseif strcmp(inputs.controllerType, 'torque_driven') 
if isfield(inputs.initialGuess, 'control')
    guess.phase.control = scaleToBounds(inputs.initialGuess.control, ...
        inputs.maxControl, inputs.minControl);
else
    for i = 1:length(inputs.controlTorqueNames)
        indx = find(strcmp(convertCharsToStrings( ...
            inputs.inverseDynamicMomentLabels), ...
            strcat(inputs.controlTorqueNames(i), '_moment')));
        controlTorquesGuess(:, i) = inputs.experimentalJointMoments(:, indx);
    end
    guess.phase.control = scaleToBounds([inputs.experimentalJointJerks ...
        controlTorquesGuess], inputs.maxControl, inputs.minControl);
end
end
guess.phase.integral = scaleToBounds(1e1, inputs.maxIntegral, ...
    inputs.minIntegral);
end
function setup = setupSolverSettings(inputs, bounds, guess, params)

setup.name = params.solverSettings.optimizationFileName;
setup.functions.continuous = @computeTrackingOptimizationContinuousFunction;
auxdata.ContinuousFunc = setup.functions.continuous;
setup.functions.endpoint = @computeTrackingOptimizationEndpointFunction;
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