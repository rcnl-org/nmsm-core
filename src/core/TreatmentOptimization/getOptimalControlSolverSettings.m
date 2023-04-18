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

function solverSettings = getOptimalControlSolverSettings(settingsFileName)
solverSettingsTree = xml2struct(settingsFileName);

solverSettings.optimizationFileName = 'trackingOptimizationOutputFile.txt';
solverSettings.solverType = getTextFromField(getFieldByNameOrAlternate( ...
    solverSettingsTree, 'solver_type', 'ipopt'));
solverSettings.linearSolverType = getTextFromField( ...
    getFieldByNameOrAlternate(solverSettingsTree, 'linear_solver_type', 'ma57'));
solverSettings.solverTolerance = str2double(getTextFromField( ...
    getFieldByNameOrAlternate(solverSettingsTree, 'solver_tolerance', '1e-3')));
solverSettings.stepSize = str2double(getTextFromField( ...
    getFieldByNameOrAlternate(solverSettingsTree, 'step_size', '1e-8')));
solverSettings.maxIterations = str2double(getTextFromField( ...
    getFieldByNameOrAlternate(solverSettingsTree, 'max_iterations', '2e4')));
solverSettings.derivativeApproximation = getTextFromField( ...
    getFieldByNameOrAlternate(solverSettingsTree, 'derivative_approximation', 'sparseCD'));
solverSettings.derivativeOrder = getTextFromField( ...
    getFieldByNameOrAlternate(solverSettingsTree, 'derivative_order', 'first'));
solverSettings.derivativeDependencies = getTextFromField( ...
    getFieldByNameOrAlternate(solverSettingsTree, 'derivative_dependencies', 'sparse'));
solverSettings.meshMethod = getTextFromField( ...
    getFieldByNameOrAlternate(solverSettingsTree, 'mesh_method', ''));
solverSettings.meshTolerance = getTextFromField( ...
    getFieldByNameOrAlternate(solverSettingsTree, 'mesh_tolerance', ''));
solverSettings.meshMaxIterations = str2double(getTextFromField( ...
    getFieldByNameOrAlternate(solverSettingsTree, 'mesh_max_iterations', '0')));
solverSettings.method = getTextFromField( ...
    getFieldByNameOrAlternate(solverSettingsTree, 'method', ''));
solverSettings.collocationPoints = str2double(getTextFromField( ...
    getFieldByNameOrAlternate(solverSettingsTree, 'collocation_points', '5')));
end