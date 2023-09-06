% This function is part of the NMSM Pipeline, see file for full license.
%
% This function parses and loads the initial guesses for states (if
% specified), controls (if specified), and parameters (if specified)
%
% (struct) -> (struct)
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

function initialGuess = parseInitialGuess(inputs)
import org.opensim.modeling.Storage
initialGuess = [];
try
    [initialGuess.state, initialGuess.stateLabels, initialGuess.time] = ...
        parseTrialData(inputs.previousResultsDirectory, ...
        strcat(inputs.trialName, "_states"), inputs.model);
catch; end
if strcmp(inputs.controllerType, "torque")
    try
        [initialGuess.control, initialGuess.controlLabels] = ...
            parseTrialData(inputs.previousResultsDirectory, ...
            strcat(inputs.trialName, "_torqueControls"), inputs.model);
    catch;end
elseif strcmp(inputs.controllerType, "synergy")
    try
        [initialGuess.control, initialGuess.controlLabels] = ...
            parseTrialData(inputs.previousResultsDirectory, ...
            strcat(inputs.trialName, "_synergyCommands"), inputs.model);
    catch;end
    try
        [initialGuess.parameter, initialGuess.parameterLabels] = ...
            parseTrialData(inputs.previousResultsDirectory, ...
            "synergyWeights", inputs.model);
    catch;end
else
    throw(MException("IncorrectControllerType", ...
        "controllerType must be 'torque' or 'synergy'"));
end
end