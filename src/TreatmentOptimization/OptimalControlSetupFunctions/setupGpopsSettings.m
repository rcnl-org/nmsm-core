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

function setup = setupGpopsSettings(inputs, ...
    bounds, guess, params, continuousFunction, endpointFunction)
setup.name = inputs.gpops.optimizationFileName;
setup.functions.continuous = continuousFunction;
setup.functions.endpoint = endpointFunction;
setup.auxdata = inputs;
setup.bounds = bounds;
setup.guess = guess;
setup.derivatives.supplier = inputs.gpops.derivativeSupplier;
setup.derivatives.derivativelevel = inputs.gpops.derivativeLevel;
setup.derivatives.dependencies = inputs.gpops.derivativeDependencies;
setup.derivatives.stepsize = inputs.gpops.stepSize;
setup.scales.method = inputs.gpops.scaleMethods;
setup.method = inputs.gpops.method;
setup.mesh.method = inputs.gpops.meshMethod;
if ~strcmp(setup.mesh.method, 'none')
    setup.mesh.tolerance = inputs.gpops.meshTolerance;
    setup.mesh.maxiterations = inputs.gpops.meshMaxIterations;
    setup.mesh.colpointsmin = inputs.gpops.meshColpointsMin;
    setup.mesh.colpointsmax = inputs.gpops.meshColpointsMax;
    setup.mesh.splitmult = inputs.gpops.meshSplitMult;
    % setup.mesh.curveRatio = inputs.gpops.meshCurveRatio;
    setup.mesh.R = inputs.gpops.meshR;
    % setup.mesh.sigma = inputs.gpops.meshSigma;
end
N = inputs.gpops.numCollocationPoints;
P = inputs.gpops.numIntervals;
setup.mesh.phase.colpoints = P * ones(1, N);
setup.mesh.phase.fraction = ones(1, N) / N;
setup.nlp.solver = inputs.gpops.solverType;
if strcmpi(setup.nlp.solver, 'ipopt')
    setup.nlp.ipoptoptions.linear_solver = inputs.gpops.linearSolverType;
    setup.nlp.ipoptoptions.tolerance = inputs.gpops.solverTolerance;
    setup.nlp.ipoptoptions.maxiterations = inputs.gpops.maxIterations;
    setup.nlp.ipoptoptions.warmstart = 0;
elseif strcmpi(setup.nlp.solver, 'snopt')
    setup.nlp.snoptoptions.linear_solver = inputs.gpops.linearSolverType;
    setup.nlp.snoptoptions.tolerance = inputs.gpops.solverTolerance;
    setup.nlp.snoptoptions.maxiterations = inputs.gpops.maxIterations;
end
setup.displaylevel = inputs.gpops.displayLevel;
end