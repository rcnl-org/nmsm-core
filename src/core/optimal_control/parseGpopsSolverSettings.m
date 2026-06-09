% This function is part of the NMSM Pipeline, see file for full license.
%
% This function reads the optimal control settings (GPOPS-II based) from a
% separate XML file.
%
% (struct) -> (Array of string)
% Optimal control solver settings are loaded

% ----------------------------------------------------------------------- %
% The NMSM Pipeline is a toolkit for model personalization and treatment  %
% optimization of neuromusculoskeletal models through OpenSim. See        %
% nmsm.rice.edu and the NOTICE file for more information. The             %
% NMSM Pipeline is developed at Rice University and supported by the US   %
% National Institutes of Health (R01 EB030520).                           %
%                                                                         %
% Copyright (c) 2021 Rice University and the Authors                      %
% Author(s): Marleny Vega, Claire V. Hammond                              %
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

function solverSettings = parseGpopsSolverSettings(settingsTree)
solverSettings.optimizationFileName = 'TreatmentOptimization';
solverSettings.derivativeSupplier = parseTextOrAlternate( ...
    settingsTree, 'setup_derivatives_supplier', 'sparseFD');
solverSettings.derivativeLevel = parseTextOrAlternate( ...
    settingsTree, 'setup_derivatives_level', 'first');
solverSettings.derivativeDependencies = parseTextOrAlternate( ...
    settingsTree, 'setup_derivatives_dependencies', 'sparse');
solverSettings.scaleMethods = parseTextOrAlternate( ...
    settingsTree, 'setup_scales_method', 'none');
solverSettings.method = parseTextOrAlternate( ...
    settingsTree, 'setup_method', 'RPM-Differentiation');
solverSettings.meshMethod = parseTextOrAlternate( ...
    settingsTree, 'setup_mesh_method', 'hp-PattersonRao');
solverSettings.meshTolerance = parseDoubleOrAlternate( ...
    settingsTree, 'setup_mesh_tolerance', 10e-3);
solverSettings.meshMaxIterations = parseDoubleOrAlternate( ...
    settingsTree, 'setup_mesh_max_iterations', 10);
solverSettings.meshColpointsMin = parseDoubleOrAlternate( ...
    settingsTree, 'setup_mesh_colpoints_min', 3);
solverSettings.meshColpointsMax = parseDoubleOrAlternate( ...
    settingsTree, 'setup_mesh_colpoints_max', 10);
solverSettings.meshSplitMult = parseDoubleOrAlternate( ...
    settingsTree, 'setup_mesh_splitmult', 1.2);
solverSettings.meshCurveRatio = parseDoubleOrAlternate( ...
    settingsTree, 'setup_mesh_curveratio', 2);
solverSettings.meshR = parseDoubleOrAlternate( ...
    settingsTree, 'setup_mesh_R', 1.2);
solverSettings.meshSigma = parseDoubleOrAlternate( ...
    settingsTree, 'setup_mesh_sigma', 0.5);
solverSettings.numCollocationPoints = parseDoubleOrAlternate( ...
    settingsTree, 'setup_mesh_phase_intervals', 6);
solverSettings.numIntervals = parseDoubleOrAlternate( ...
    settingsTree, 'setup_mesh_phase_colpoints_per_Interval', 10);
solverSettings.solverType = parseTextOrAlternate( ...
    settingsTree, 'setup_nlp_solver', 'ipopt');
solverSettings.linearSolverType = parseTextOrAlternate( ...
    settingsTree, 'setup_nlp_linear_solver', 'ma57');
solverSettings.solverTolerance = parseDoubleOrAlternate( ...
    settingsTree, 'setup_nlp_tolerance', 1e-3);
solverSettings.stepSize = parseDoubleOrAlternate( ...
    settingsTree, 'setup_derivatives_step_size', 1e-8);
solverSettings.maxIterations = parseDoubleOrAlternate( ...
    settingsTree, 'setup_nlp_max_iterations', 2e4);
solverSettings.displayLevel = parseDoubleOrAlternate( ...
    settingsTree, 'setup_display_level', 2);
solverSettings.integralBound = parseDoubleOrAlternate( ...
    settingsTree, "integral_bound", 1);
end
