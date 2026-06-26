% This function is part of the NMSM Pipeline, see file for full license.
%
% This function prints a progress bar to the Command Window. It is intended
% for loops that take a long time to run. The reverseStr output must be
% passed in on subsequent iterations for the bar to print correctly. The
% reverseStr input should be set to an empty char array if the bar has not
% yet been printed.
%
% (double, double, Array of char, double) -> (Array of char)
%  

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

function reverseStr = printProgressBar(operationNumber, ...
    totalOperations, reverseStr, progressBarElements)
% Based on:
% https://stackoverflow.com/questions/11050205/text-progress-bar-in-matlab
if nargin < 4
    progressBarElements = 50;
end

% fprintf("Progress: ");
percentDone = 100 * operationNumber / totalOperations;
progressBarFraction = round(percentDone / 100 * progressBarElements);
progressBar = "[";
if progressBarFraction > 0
    progressBar = progressBar + ...
        join(repmat("=", 1, progressBarFraction), '');
end
if progressBarElements - progressBarFraction > 0
    progressBar = progressBar + join(repmat(".", 1, ...
        progressBarElements - progressBarFraction), '');
end
progressBar = progressBar + "] ";
progressBar = sprintf('%s', progressBar);
percentage = sprintf('%3.1f', percentDone);
fullMessage = [progressBar, percentage];
fprintf([reverseStr, fullMessage, '%%']);
reverseStr = repmat(sprintf('\b'), 1, length(fullMessage) + 1);
end
