% This function is part of the NMSM Pipeline, see file for full license.
%
% This function formats and saves MTP data to a .sto file. It splits data
% by gait cycle and saves each gait cycle to a separate file with the
% appropriate prefix. If the output directory does not already exist, it is
% created.
%
% (array), (cell), (array), (string), (string) -> (none)
% Saves MTP data to a .sto file.

% ----------------------------------------------------------------------- %
% The NMSM Pipeline is a toolkit for model personalization and treatment  %
% optimization of neuromusculoskeletal models through OpenSim. See        %
% nmsm.rice.edu and the NOTICE file for more information. The             %
% NMSM Pipeline is developed at Rice University and supported by the US   %
% National Institutes of Health (R01 EB030520).                           %
%                                                                         %
% Copyright (c) 2021 Rice University and the Authors                      %
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
function writeMtpDataToSto(columnLabels, taskNames, data, time, ...
    directory, fileName)
if ~exist(directory, "dir")
    mkdir(directory);
end
for i = 1 : size(data,1)
    writeToSto(columnLabels, time(i, :), ...
        permute(data(i,:,:), [3 2 1]), ...
        fullfile(directory, strcat(taskNames(i), fileName)))
end
end