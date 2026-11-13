% This function is part of the NMSM Pipeline, see file for full license.
%
% Appends a numeric suffix (_1, _2, ...) to resultsDirectory if it already
% exists, so a tool never silently overwrites a previous run's results.
% Returns resultsDirectory unchanged if it does not yet exist.
%
% (string) -> (string)

% ----------------------------------------------------------------------- %
% The NMSM Pipeline is a toolkit for model personalization and treatment  %
% optimization of neuromusculoskeletal models through OpenSim. See        %
% nmsm.rice.edu and the NOTICE file for more information. The             %
% NMSM Pipeline is developed at Rice University and supported by the US   %
% National Institutes of Health (R01 EB030520).                           %
%                                                                         %
% Copyright (c) 2021 Rice University and the Authors                      %
% Author(s): Xuanning Liu                                                 %
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

function resultsDirectory = getUniqueResultsDirectory(resultsDirectory)
baseResultsDirectory = resultsDirectory;
suffix = 1;
while exist(resultsDirectory, "dir")
    resultsDirectory = sprintf("%s_%d", baseResultsDirectory, suffix);
    suffix = suffix + 1;
end
if suffix > 1
    warning('"%s" already exists; writing results to "%s" instead.', ...
        baseResultsDirectory, resultsDirectory);
end
end
