% This function is part of the NMSM Pipeline, see file for full license.
%
% This function sets up the common bounds for an optimal control problem
% and is used by Tracking Optimization, Verification Optimization, and
% Design Optimization
%
% () => ()
% return a set of setup values common to all optimal control problems

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

function bounds = setupTreatmentOptimizationBounds(inputs, params)
% setup time bounds
bounds.phase.initialtime.lower = -0.5;
bounds.phase.initialtime.upper = -0.5;
bounds.phase.finaltime.lower = 0.5;
bounds.phase.finaltime.upper = 0.5;
if isfield(inputs, "finalTimeRange")
    bounds.phase.finaltime.lower = scaleToBounds( ...
        inputs.finalTimeRange(1), inputs.maxTime, inputs.minTime);
end
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
bounds.phase.integral.lower = zeros(1, length(inputs.continuousMaxAllowableError));
bounds.phase.integral.upper = inputs.gpops.integralBound * ...
    ones(1, length(inputs.continuousMaxAllowableError));
% setup terminal constraint bounds
if ~isempty(inputs.minTerminal)
    bounds.eventgroup.lower = inputs.minTerminal;
end
if ~isempty(inputs.maxTerminal)
    bounds.eventgroup.upper = inputs.maxTerminal;
end
if inputs.controllerTypes(2)
    if inputs.optimizeSynergyVectors
        bounds.parameter.lower = -0.5 * ones(1, length(inputs.minParameter));
        bounds.parameter.upper = 0.5 * ones(1, length(inputs.minParameter));
    end
end
if strcmp(inputs.toolName, "DesignOptimization")
    for i = 1:length(inputs.userDefinedVariables)
        lower = -0.5 * ones(1, length(inputs.userDefinedVariables{i}.initial_values));
        upper = 0.5 * ones(1, length(inputs.userDefinedVariables{i}.initial_values));
        if ~isfield(bounds, "parameter") || ...
                ~isfield(bounds.parameter, "lower")
            bounds.parameter.lower = lower;
            bounds.parameter.upper = upper;
        else
            bounds.parameter.lower = [bounds.parameter.lower, ...
                lower];
            bounds.parameter.upper = [bounds.parameter.upper, ...
                upper];
        end
    end
end
end

