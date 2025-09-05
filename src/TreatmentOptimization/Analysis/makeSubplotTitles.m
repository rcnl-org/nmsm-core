% This function is part of the NMSM Pipeline, see file for full license.
%
% For plotting functions only
% Builds subplot titles for plots. Builds a string with given column
% labels and RMSE between tracked and results data.

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
function titleStrings = makeSubplotTitles(tracked, results, showRmse)
for i = 1 : numel(tracked.labels)
    titleStrings{i} = [sprintf("%s", strrep(tracked.labels(i), "_", " "))];
    if showRmse
        for j = 1 : numel(results.data)
            rmse = rms(tracked.resampledData{j}(:, i) - results.data{j}(:, i));
            titleStrings{i}(j+1) = sprintf("RMSE %d: %.4f", j, rmse);
        end
    end
end

