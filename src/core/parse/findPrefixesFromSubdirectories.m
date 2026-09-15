% This function is part of the NMSM Pipeline, see file for full license.
%
% This function finds trial prefixes by listing the subdirectories of the
% given directory and returning the names of those that contain at least
% one file matching the given extension pattern.
%
% (string, string) -> (Array of string)
% Returns subdirectory names whose contents include files of the given type

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
function prefixes = findPrefixesFromSubdirectories(inputDirectory, filePattern)
if nargin < 2
    filePattern = "*.sto";
end
entries = dir(inputDirectory);
entries = entries([entries.isdir]);
entries = entries(~ismember({entries.name}, {'.', '..'}));
prefixes = string([]);
for i = 1:length(entries)
    files = dir(fullfile(inputDirectory, entries(i).name, filePattern));
    if ~isempty(files)
        prefixes(end+1) = string(entries(i).name);
    end
end
end
