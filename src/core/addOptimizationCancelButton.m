% This function is part of the NMSM Pipeline, see file for full license.
%
% Adds a waitbar with a Cancel button to an fmincon/lsqnonlin options
% struct. Waitbar redraws are throttled to ~4/sec so displaying progress 
% does not slow down optimizations.  Clicking Cancel or closing the window 
% makes the solver stop early and return its current best point.
%
% If this tool is running through the GUI, this waitbar is skipped 
%
% (struct, double, string, matlab.apps.AppBase) -> (struct, onCleanup)
% Adds a Cancel button waitbar to an optimizer options struct

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

function [optimizerOptions, cancelCleanup] = addOptimizationCancelButton(...
    optimizerOptions, maxIterations, waitbarMessage, app)
if nargin < 4
    app = [];
end
if ~isempty(app) && ismethod(app, "CancelOptimizationGui")
    optimizerOptions.OutputFcn = @(x, optimValues, state, varargin) ...
        app.CancelOptimizationGui(x, optimValues, state);
    cancelCleanup = onCleanup(@() []);
    return
end

sizingText = sprintf('%s\ncost: %s\nclick Cancel or close the window to stop early', ...
    waitbarMessage, sprintf('%.4g', -123456.789));
waitbarHandle = waitbar(0, sizingText, ...
    'CreateCancelBtn', 'setappdata(gcbf, ''canceling'', 1)');
waitbar(0, waitbarHandle, sprintf('%s\ncost: ...\nclick Cancel or close the window to stop early', ...
    waitbarMessage));
setappdata(waitbarHandle, 'lastUpdateTic', tic);
optimizerOptions.OutputFcn = @(x, optimValues, state, varargin) cancelButtonOutputFcn( ...
    optimValues, state, waitbarHandle, maxIterations, waitbarMessage);
cancelCleanup = onCleanup(@() safeDeleteWaitbar(waitbarHandle));
end

% -----------------------------------------------------------------------
function stop = cancelButtonOutputFcn(optimValues, state, waitbarHandle, ...
    maxIterations, waitbarMessage)
stop = false;
if ~ishghandle(waitbarHandle)
    stop = true;
    return
end
if getappdata(waitbarHandle, 'canceling')
    stop = true;
end
if stop || strcmp(state, 'done')
    return
end
% throttle to ~4 updates/sec so displaying progress won't slow down
if toc(getappdata(waitbarHandle, 'lastUpdateTic')) < 0.25
    return
end
setappdata(waitbarHandle, 'lastUpdateTic', tic);
% fmincon's optimValues has .fval; lsqnonlin's has .resnorm instead
if isfield(optimValues, 'fval')
    cost = optimValues.fval;
elseif isfield(optimValues, 'resnorm')
    cost = optimValues.resnorm;
else
    cost = NaN;
end
fraction = estimateProgressFraction(waitbarHandle, optimValues.iteration, ...
    maxIterations, cost);
waitbar(fraction, waitbarHandle, sprintf( ...
    '%s\ncost: %.4g\nclick Cancel or close the window to stop early', ...
    waitbarMessage, cost));
end

% -----------------------------------------------------------------------
% track how much the cost has already dropped relative to its first 
% observed value, only falling back to iteration count when cost is 
% unavailable or hasn't improved yet
function fraction = estimateProgressFraction(waitbarHandle, iteration, ...
    maxIterations, cost)
iterationFraction = min(iteration / max(maxIterations, 1), 1);
fraction = iterationFraction;
if isfinite(cost)
    initialCost = getappdata(waitbarHandle, 'initialCost');
    if isempty(initialCost)
        setappdata(waitbarHandle, 'initialCost', cost);
    elseif initialCost ~= 0
        costFraction = (initialCost - cost) / abs(initialCost);
        fraction = max(fraction, min(max(costFraction, 0), 1));
    end
end
bestFraction = getappdata(waitbarHandle, 'bestFraction');
if ~isempty(bestFraction)
    fraction = max(fraction, bestFraction);
end
setappdata(waitbarHandle, 'bestFraction', fraction);
end

% -----------------------------------------------------------------------
% Deletes the waitbar if it still exists
function safeDeleteWaitbar(waitbarHandle)
if ishghandle(waitbarHandle)
    delete(waitbarHandle);
end
end
