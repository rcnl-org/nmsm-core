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

function inputs = prepareCasadiInputs(inputs, params)
inputs.bounds = setupTreatmentOptimizationBounds(inputs, params);
[inputs, inputs.guess] = setupGpopsInitialGuess(inputs);
inputs = preSplineCasadiInputs(inputs);

% Find initial values for converted FD cost terms
inputs = initializeConvertedFdCostTerms(inputs);

% Handle free final time
inputs = setupFreeFinalTime(inputs);

% First run of model functions to check for errors, preindex cost and
% constraint terms, and find initial integrated quantities
[outputsSymbolic, modeledValues, inputs] = ...
    computeCasadiSymbolicModelFunction(inputs.guess.phase, inputs);
[outputsFinite, inputs] = computeCasadiFiniteDifferenceModelFunction( ...
    inputs.guess.phase, inputs, modeledValues);
outputs.dynamics = outputsSymbolic.dynamics;
outputs.path = outputsSymbolic.path + outputsFinite.path;
outputs.terminal = outputsSymbolic.terminal + outputsFinite.terminal;
outputs.objective = outputsSymbolic.objective + outputsFinite.objective;
inputs.initialOutputs = outputs;
end

function inputs = initializeConvertedFdCostTerms(inputs)
if inputs.convertFdCostTerms
    modelOutputs = computeCasadiFiniteDifferenceModelFunction( ...
        inputs.guess.phase, inputs);
    path = modelOutputs.path;
    terminal = modelOutputs.terminal;
    % Updating the guess with this method assumes that the final controls
    % are surrogate cost values. This is probably the best type of control
    % to keep last since no other control needs to have its guess updated
    % like this. This is also true for parameters.
    for i = 1 : inputs.numConvertedContinuousCosts
        inputs.guess.phase.control(:, ...
            end - inputs.numConvertedContinuousCosts + i) = ...
            scaleToBounds( ...
            path(:, end - inputs.numConvertedContinuousCosts + i) * ...
            inputs.path{end - inputs.numConvertedContinuousCosts + i} ...
            .convertedCostTerm.maxAllowableError, inputs.maxControl(end ...
            - inputs.numConvertedContinuousCosts + i), ...
            inputs.minControl(end - ...
            inputs.numConvertedContinuousCosts + i));
    end
    for i = 1 : inputs.numConvertedDiscreteCosts
        inputs.guess.phase.parameter(:, ...
            end - inputs.numConvertedContinuousCosts + i) = ...
            scaleToBounds( ...
            terminal(end - inputs.numConvertedDiscreteCosts + i) * ...
            inputs.terminal{end - inputs.numConvertedDiscreteCosts + i} ...
            .convertedCostTerm.maxAllowableError, inputs.maxParameter( ...
            end - inputs.numConvertedContinuousCosts + i), ...
            inputs.minParameter(end - ...
            inputs.numConvertedContinuousCosts + i));
    end
end
end

function inputs = setupFreeFinalTime(inputs)
    if isfield(inputs, 'finalTimeRange')
        if ~isfield(inputs.guess.phase, 'parameter')
            inputs.guess.phase.parameter = [];
            inputs.bounds.phase.parameter = struct('lower', [], 'upper', []);
        end
        lowerScale = (inputs.finalTimeRange(1) / ...
            inputs.collocationTimeOriginalWithEnd(end));
        upperScale = (inputs.finalTimeRange(end) / ...
            inputs.collocationTimeOriginalWithEnd(end));
        inputs.guess.phase.parameter = [ ...
            scaleToBounds(1, upperScale, lowerScale) ...
            inputs.guess.phase.parameter];
        inputs.bounds.phase.parameter.lower = [-0.5 ...
            inputs.bounds.phase.parameter.lower];
        inputs.bounds.phase.parameter.upper = [0.5 ...
            inputs.bounds.phase.parameter.upper];
        inputs.minParameter = [lowerScale inputs.minParameter];
        inputs.maxParameter = [upperScale inputs.maxParameter];
    end
end
