% This function is part of the NMSM Pipeline, see file for full license.
%
% This function loads the emg files from disk and expands the number of
% columns of emg data to match the groups indicated in the model. The
% number of columns of emg data should match the number of muscles used in
% the model after this function is complete.
%
% (2D Array of double, 1D Array of double, string, struct) -> (None)
% parses the emg files and expands them to the correct size

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

function emgData = parseEmgWithExpansion(model, files)
dataFromFileOne = expandEmgDatas(model, files(1));
emgData = zeros([length(files) size(dataFromFileOne)]);
cells(1, :, :) = dataFromFileOne;
for i=2:length(files)
    cells(i, :, :) = expandEmgDatas(model, files(2));
end
end

