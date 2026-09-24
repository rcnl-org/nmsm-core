% This function is part of the NMSM Pipeline, see file for full license.
%
% This function checks that each trial has its own folder in the data
% directory's MAData subdirectory, named exactly after the trial, and that
% the muscle analysis files the tool reads are inside that folder. Each
% required file is given as a dir() pattern, such as "*_Length.sto", and
% at least one file in the trial's folder must match it. Nothing is
% reported when the data directory or its MAData folder is missing, since
% the data directory check reports those.
%
% (string, Array of string, Array of string) -> (Array of string)
% Returns one message per problem with the trials' MAData folders

% ----------------------------------------------------------------------- %
% The NMSM Pipeline is a toolkit for model personalization and treatment  %
% optimization of neuromusculoskeletal models through OpenSim. See        %
% nmsm.rice.edu and the NOTICE file for more information. The             %
% NMSM Pipeline is developed at Rice University and supported by the US   %
% National Institutes of Health (R01 EB030520).                           %
%                                                                         %
% Copyright (c) 2026 Rice University and the Authors                      %
% Author(s): Robert Salati                                                %
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
function problems = findMaDataTrialProblemsGui(dataDirectory, ...
    trialNames, requiredFilePatterns)
problems = strings(0, 1);
maDataDirectory = fullfile(dataDirectory, "MAData");
if strcmp(dataDirectory, "") || ~isfolder(maDataDirectory)
    return
end
for i = 1 : numel(trialNames)
    trialName = string(trialNames(i));
    trialDirectory = fullfile(maDataDirectory, trialName);
    if ~isfolder(trialDirectory)
        problems(end + 1, 1) = "MAData has no folder named '" + trialName + ...
            "'. Each trial's muscle analysis files must be in a " + ...
            "folder named after the trial."; %#ok<AGROW>
        continue
    end
    for j = 1 : numel(requiredFilePatterns)
        if isempty(dir(fullfile(trialDirectory, requiredFilePatterns(j))))
            problems(end + 1, 1) = "MAData/" + trialName + " has no " + ...
                requiredFilePatterns(j) + " file."; %#ok<AGROW>
        end
    end
end
end
