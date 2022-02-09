% This function is part of the NMSM Pipeline, see file for full license.
%
% This function returns the number of files from the directory given as
% the input starting with 1.sto, 2.sto and continuing to n.sto and stops
% when the file cannot be found in the directory. 
%
% (string) -> (number)
% returns the number of sequential files that exist starting at 1.sto

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

function counter = findNumberFiles(inputDirectoryPath)
counter = 0;
inputDir = dir(inputDirectoryPath);
for i=1:length(inputDir)
    if(strcmp(inputDir(i).name, strcat(num2str(counter+1),'.sto')))
        counter = counter + 1;
    end
end
end

