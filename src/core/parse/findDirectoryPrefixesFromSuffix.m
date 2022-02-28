% This function is part of the NMSM Pipeline, see file for full license.
%
% This function returns an array of strings of the prefixes of the files
% for a given suffix. If a file is named 'Patient4_Left_01_id.sto' then an
% input of '_id.sto' will return 'Patient4_Left_01'.
%
% (string, string) -> (Array of string)
% returns the name of all files in the directory

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

function names = findDirectoryPrefixesFromSuffix(directory, suffix)
files = dir(directory);
names = string([]);
for i=1:length(files)
    index = strfind(files(i).name, suffix);
    if(length(index)==1)
        names(end+1) = files(i).name(1:index(1)-1);
    end
end
end

