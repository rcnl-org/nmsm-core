% This function is part of the NMSM Pipeline, see file for full license.
%
% This function looks in the given directory for all subdirectories and
% returns their names as a string array
%
% (string, Array of string) -> (Array of string)
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

function dirs = findFirstLevelSubDirectoriesFromPrefixes( ...
    inputDirectory, prefixes)
listings = dir(inputDirectory);
dirs = string([]);
for i=1:length(prefixes)
    for j=1:length(listings)
        index = strfind(listings(j).name, prefixes(i));
        if(length(index)==1)
            dirs(end+1) = fullfile(inputDirectory, listings(j).name);
            break
        end
    end
end
dirs = string(dirs);
end
