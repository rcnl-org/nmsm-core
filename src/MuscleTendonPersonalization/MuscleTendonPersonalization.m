% This function is part of the NMSM Pipeline, see file for full license.
%
% Muscle Tendon Personalization uses movement and EMG data to personalize
% the muscle characteristics of the patient.
%
% (struct, struct) -> struct
% Runs the Muscle Tendon Personalization algorithm

% ----------------------------------------------------------------------- %
% The NMSM Pipeline is a toolkit for model personalization and treatment  %
% optimization of neuromusculoskeletal models through OpenSim. See        %
% nmsm.rice.edu and the NOTICE file for more information. The             %
% NMSM Pipeline is developed at Rice University and supported by the US   %
% National Institutes of Health (R01 EB030520).                           %
%                                                                         %
% Copyright (c) 2021 Rice University and the Authors                      %
% Author(s): Claire V. Hammond                                            %
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

function results = MuscleTendonPersonalization(inputs, params)
verifyInputs(inputs); % (struct) -> (None)
verifyParams(params); % (struct) -> (None)
values = prepareInitialValues(inputs, params);
optimizerOptions = makeOptimizerOptions(params);
for i=1:length(inputs.tasks)
    taskValues = makeTaskValues(inputs.tasks{i}, params);
    taskParams = makeTaskParams(inputs.tasks{i}, params);
    optimizedValues = computeParameterOptimization(taskValues, ...
        taskParams, optimizerOptions);
    updateDesignVariables()
end
end

% (struct, struct) -> (struct)
% extract initial version of optimized values from inputs/params
function values = prepareInitialValues(inputs, params)

end

% (struct) -> (struct)
% setup optimizer options struct to pass to fmincon
function optimizerOptions = makeOptimizerOptions(params)

end

% (struct, struct) -> (Array of number)
% prepare values to be optimized for the given task
function taskValues = makeTaskValues(taskInputs, params)

end

% (struct, struct) -> (struct)
% prepare optimizer parameters for the given task
function taskParams = makeTaskParams(taskInputs, params)

end