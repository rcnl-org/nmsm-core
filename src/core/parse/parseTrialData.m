% This function is part of the NMSM Pipeline, see file for full license.
%
% This function looks in the given directory for all files that match the
% trialName, if there is only one, parse the file into data and data labels
%
% (string, string, Model) -> (2D matrix of number, 1D array of string)
% returns a 3D matrix of the loaded muscle tendon length data

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

function [data, dataLabels, time] = parseTrialData(directory, ...
    trialName, model)
files = findDirectoryFileNames(directory);
matchedFiles = [];
for i = 1:length(files)
    [~, name, ~] = fileparts(files(i));
    if contains(name, trialName)
        matchedFiles(end + 1) = i;
    end
end
if isempty(matchedFiles)
    throw(MException("ParseError:TrialNameFile", ...
        strcat("Cannot find file: ", trialName, " in directory ", ...
        strrep(directory, '\', '\\'))))
end
if length(matchedFiles) ~= 1
    throw(MException("ParseError:TrialNameFile", ...
        strcat("Multiple files contain: ", trialName, " in directory ", ...
        strrep(directory, '\', '\\'))))
end
[dataLabels, time, data] = parseMotToComponents(model, ...
     org.opensim.modeling.Storage(files(matchedFiles(1))));
data = data';
time = time';
end

