% This function is part of the NMSM Pipeline, see file for full license.
%
%
% (Array of double, Array of double, Array of double) -> (Array of double)
% Respline data from one time range to another. 

% ----------------------------------------------------------------------- %
% The NMSM Pipeline is a toolkit for model personalization and treatment  %
% optimization of neuromusculoskeletal models through OpenSim. See        %
% nmsm.rice.edu and the NOTICE file for more information. The             %
% NMSM Pipeline is developed at Rice University and supported by the US   %
% National Institutes of Health (R01 EB030520).                           %
%                                                                         %
% Copyright (c) 2021 Rice University and the Authors                      %
% Author(s): Spencer Williams                                             %
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

function resplinedData = resplineDataToNewTime(data, oldTime, newTime)
% Assume data in Model Personalization orientation
resplinedData = zeros(size(data));
sizePerTrial = size(data, 1) / size(oldTime, 1);
for i = 1 : size(oldTime, 1)
    indicesToUse = (i - 1) * sizePerTrial + 1 : i * sizePerTrial;
    splineSet = makeGcvSplineSet(oldTime(i, :), data(indicesToUse, :)', ...
        string(indicesToUse));
    resplinedData(indicesToUse, :) = evaluateGcvSplines(splineSet, ...
        string(indicesToUse), newTime(i, :))';
end
end
