% This function is part of the NMSM Pipeline, see file for full license.
%
% This function sets up the common set of settings for an optimal control
% problem and is used by Tracking Optimization, Verification Optimization,
% and Design Optimization
%
% (struct, struct, struct, struct, function handle, function handle) 
% -> (struct)
% return a set of solver values common to all optimal control problems

% ----------------------------------------------------------------------- %
% The NMSM Pipeline is a toolkit for model personalization and treatment  %
% optimization of neuromusculoskeletal models through OpenSim. See        %
% nmsm.rice.edu and the NOTICE file for more information. The             %
% NMSM Pipeline is developed at Rice University and supported by the US   %
% National Institutes of Health (R01 EB030520).                           %
%                                                                         %
% Copyright (c) 2021 Rice University and the Authors                      %
% Author(s): Claire V. Hammond, Marleny Vega                              %
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

function setup = setupCommonOptimalControlSolverSettings(inputs, ...
    bounds, guess, params, continuousFunction, endpointFunction)
setup.name = params.solverSettings.optimizationFileName;
setup.functions.continuous = continuousFunction;
auxdata.ContinuousFunc = setup.functions.continuous;
setup.functions.endpoint = endpointFunction;
setup.auxdata = inputs;
setup.bounds = bounds;
setup.guess = guess;
setup.derivatives.supplier = params.solverSettings.derivativeSupplier;
setup.derivatives.derivativelevel = params.solverSettings.derivativeLevel;
setup.derivatives.dependencies = params.solverSettings.derivativeDependencies;
setup.derivatives.stepsize1 = params.solverSettings.stepSize;
setup.scales.method = params.solverSettings.scaleMethods;
setup.method = params.solverSettings.method;
setup.mesh.method = params.solverSettings.meshMethod;
setup.mesh.tolerance = params.solverSettings.meshTolerance;
setup.mesh.maxiterations = params.solverSettings.meshMaxIterations;
setup.mesh.colpointsmin = params.solverSettings.meshColpointsMin;
setup.mesh.colpointsmax = params.solverSettings.meshColpointsMax;
setup.mesh.splitmult = params.solverSettings.meshSplitMult;
setup.mesh.curveRatio = params.solverSettings.meshCurveRatio;
setup.mesh.R = params.solverSettings.meshR;
setup.mesh.sigma = params.solverSettings.meshSigma;
N = params.solverSettings.numCollocationPoints;
P = params.solverSettings.numIntervals;
setup.mesh.phase.colpoints = P * ones(1, N);
setup.mesh.phase.fraction = ones(1, N) / N;
setup.nlp.solver = params.solverSettings.solverType;
setup.nlp.ipoptoptions.linear_solver = params.solverSettings.linearSolverType;
setup.nlp.ipoptoptions.tolerance = params.solverSettings.solverTolerance;
setup.nlp.ipoptoptions.maxiterations = params.solverSettings.maxIterations;
setup.nlp.snoptoptions.linear_solver = params.solverSettings.linearSolverType;
setup.nlp.snoptoptions.tolerance = params.solverSettings.solverTolerance;
setup.nlp.snoptoptions.maxiterations = params.solverSettings.maxIterations;
setup.displaylevel = params.solverSettings.displayLevel;
end