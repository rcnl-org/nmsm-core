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
% Author(s): Spencer Williams                                             %
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

function solution = solveTreatmentOptimizationWithCasadi(inputs)
optimizer = casadi.Opti();

% Create optimizer variables
% TODO: add other possible fields like parameters
state = optimizer.variable(size(inputs.guess.phase.state, 1), ...
    size(inputs.guess.phase.state, 2));
control = optimizer.variable(size(inputs.guess.phase.control, 1), ...
    size(inputs.guess.phase.control, 2));

% Initialize optimizer variables
optimizer.set_initial(state, inputs.guess.phase.state);
optimizer.set_initial(control, inputs.guess.phase.control);

% Connect optimizer variables to main function
casadiValues.state = state;
casadiValues.control = control;
mainFunction = TreatmentOptimizationCallback('mainFunction', inputs, ...
    struct('enable_fd', true, 'fd_method', 'forward'));
[dynamics, pathTemp, terminalTemp, objectiveTemp] = mainFunction(state, control);

% Apply variable bounds
maxState = repmat(inputs.bounds.phase.state.upper, size(state, 1), 1);
minState = repmat(inputs.bounds.phase.state.lower, size(state, 1), 1);
optimizer.subject_to(minState(:) < state(:) < maxState(:));
maxControl = repmat(inputs.bounds.phase.control.upper, size(control, 1), 1);
minControl = repmat(inputs.bounds.phase.control.lower, size(control, 1), 1);
optimizer.subject_to(minControl(:) < control(:) < maxControl(:));

% Apply dynamic constraint
optimizer.subject_to(dynamics == 0);

% Apply path constraints
if ~isempty(inputs.initialOutputs.path)
    maxPath = repmat(inputs.maxPath, size(pathTemp, 1), 1);
    minPath = repmat(inputs.minPath, size(pathTemp, 1), 1);
    optimizer.subject_to(minPath(:) < pathTemp(:) < maxPath(:));
end

% Apply terminal constraints
if ~isempty(inputs.initialOutputs.terminal)
    optimizer.subject_to(inputs.minTerminal < terminalTemp < ...
        inputs.maxTerminal);
end

% Minimize objective
optimizer.minimize(objectiveTemp);

% Ipopt settings
optimizerOptions.detect_simple_bounds = true;
optimizerOptions.ipopt.tol = 1e-4;
optimizerOptions.ipopt.constr_viol_tol = 1e-4;

optimizer.solver('ipopt', optimizerOptions);

casadiSolution = optimizer.solve();

% Unpack solution values

end
