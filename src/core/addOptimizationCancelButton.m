% This function is part of the NMSM Pipeline, see file for full license.
%
% Adds a waitbar with a Cancel button to an fmincon/lsqnonlin options
% struct (works with both optimoptions- and legacy optimset-built structs).
% Waitbar redraws are throttled to ~4/sec so displaying progress does not
% slow down optimizations with many cheap iterations. Returns cancelCleanup,
% an onCleanup object the caller must hold for the duration of the solver
% call - it guarantees the window is closed on any exit (normal return,
% error, or interrupt) instead of being left stranded on screen.
%
% Clicking Cancel (or closing the window) makes the solver stop early and
% return its current best point, exactly as fmincon/lsqnonlin already do
% when MaxIterations is reached - no extra plumbing is needed to keep the
% in-progress result.
%
% (struct, double, string) -> (struct, onCleanup)
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
    optimizerOptions, maxIterations, waitbarMessage)
waitbarHandle = waitbar(0, waitbarMessage, ...
    'CreateCancelBtn', 'setappdata(gcbf, ''canceling'', 1)');
setappdata(waitbarHandle, 'lastUpdateTic', tic);
optimizerOptions.OutputFcn = @(x, optimValues, state) cancelButtonOutputFcn( ...
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
    % onCleanup (held by the caller) deletes the window; nothing to do
    % here but report stop.
    return
end
% throttle to ~4 updates/sec so displaying progress won't slow down
if toc(getappdata(waitbarHandle, 'lastUpdateTic')) < 0.25
    return
end
setappdata(waitbarHandle, 'lastUpdateTic', tic);
fraction = min(optimValues.iteration / max(maxIterations, 1), 1);
% fmincon's optimValues has .fval; lsqnonlin's has .resnorm instead
if isfield(optimValues, 'fval')
    cost = optimValues.fval;
elseif isfield(optimValues, 'resnorm')
    cost = optimValues.resnorm;
else
    cost = NaN;
end
waitbar(fraction, waitbarHandle, sprintf( ...
    '%s (iteration %d, cost %.4g)... click Cancel or closing the window to stop early', ...
    waitbarMessage, optimValues.iteration, cost));
end

% -----------------------------------------------------------------------
% Deletes the waitbar if it still exists; safe to call more than once and
% safe to call after the user has already closed the window.
function safeDeleteWaitbar(waitbarHandle)
if ishghandle(waitbarHandle)
    delete(waitbarHandle);
end
end
