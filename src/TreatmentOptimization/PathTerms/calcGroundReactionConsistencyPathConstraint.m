% This function is part of the NMSM Pipeline, see file for full license.
%
% This function calculates the difference between the ground reactions and 
% the ground reaction control for the specified load. Loads are split
% between parent and child bodies.
%
% (struct, struct, string) -> (number)
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

function [pathTerm, constraintTerm] = ...
    calcGroundReactionConsistencyPathConstraint( ...
    constraintTerm, inputs, modeledValues, values)
if isfield(constraintTerm, 'internalDataIndices')
    loadName = '';
else
    loadName = constraintTerm.load;
    assert(ismember(loadName, ...
        inputs.initialGroundReactionControlLabels), loadName + ...
        " is not a valid load name for ground reaction controls and " + ...
        "consistency. These load names are based on GRF column " + ...
        "names and are body-specific: <grf_column_name>_parent or " + ...
        "<grf_column_name>_child")
end

[controlGroundReaction, constraintTerm] = findDataByLabels( ...
    constraintTerm, values.controlGroundReactions, ...
    inputs.initialGroundReactionControlLabels, loadName);
bodyGroundReaction = modeledValues.groundReactionsBody(:, ...
    constraintTerm.internalDataIndices);

pathTerm = controlGroundReaction - bodyGroundReaction;
end
