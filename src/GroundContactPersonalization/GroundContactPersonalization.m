% This function is part of the NMSM Pipeline, see file for full license.
%
% 
%
% (struct, struct) -> (struct)
% Runs all Ground Contact Personalization stages from inputs and params.

% ----------------------------------------------------------------------- %
% The NMSM Pipeline is a toolkit for model personalization and treatment  %
% optimization of neuromusculoskeletal models through OpenSim. See        %
% nmsm.rice.edu and the NOTICE file for more information. The             %
% NMSM Pipeline is developed at Rice University and supported by the US   %
% National Institutes of Health (R01 EB030520).                           %
%                                                                         %
% Copyright (c) 2021 Rice University and the Authors                      %
% Author(s): Claire V. Hammond, Spencer Williams                          %
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

function results = GroundContactPersonalization(inputs, params, app)
% The optional third argument is the GUI's run window. It is kept out of
% params on purpose: the cost function's closure captures params and is
% serialized to the parallel workers, and an app handle in there warns
% once per round that an App Designer object cannot be saved. Every call
% that uses it checks first, so a scripted run is unaffected.
if nargin < 3
    app = [];
end
inputs = prepareGroundContactPersonalizationInputs(inputs);
% Optionally initializes the resting spring length.
if params.restingSpringLengthInitialization
    if valueOrAlternate(inputs, "parseInitialGuessFromOsimx", false)
        warning("initialize_resting_spring_length and " + ...
            "parse_initial_guess_from_osimx are both enabled. The resting " + ...
            "spring length initial guess from the osimx file will be " + ...
            "overwritten.");
    end
    updateRunStageGui(app, 'InitializingLabel', 'on');
    inputs = initializeRestingSpringLength(inputs);
    updateRunStageGui(app, 'InitializingLabel', 'off');
end
for surface = 1:length(inputs.surfaces)
    [inputs.surfaces{surface}.experimentalGroundReactionMoments, ...
        inputs.surfaces{surface}.experimentalMomentCenter] = ...
        replaceMomentsAboutMidfootSuperior(inputs.surfaces{surface}, ...
        inputs);
    inputs.surfaces{surface}.experimentalGroundReactionMomentsSlope = ...
        calcBSplineDerivative(inputs.surfaces{surface}.time, ...
        inputs.surfaces{surface}.experimentalGroundReactionMoments, 2, ...
        inputs.surfaces{surface}.splineNodes);
end
% Run each task as outlined in XML settings file.
for task = 1:length(params.tasks)
    reportTaskProgress(app, task, length(params.tasks));
    inputs = optimizeGroundContactPersonalizationTask(inputs, params, ...
        task, app);
    % Cancelling stops the whole sequence rather than just the round
    % that was running. The rounds already finished are kept, so the
    % results still reflect the work that was done.
    if runCancelled(app)
        break
    end
end

results = inputs;
end

% (App, double, double) -> (None)
% Names the round under way in the GUI's run window, if there is one. A
% round can run for a long time with nothing else to show for it.
function reportTaskProgress(app, task, taskCount)
if ~isempty(app) && ismethod(app, "updateTaskProgress")
    app.updateTaskProgress(task, taskCount);
end
end

% (App) -> (logical)
function cancelled = runCancelled(app)
cancelled = ~isempty(app) && ismethod(app, "isRunCancelled") && ...
    app.isRunCancelled();
end

% (struct, struct) -> (2D Array of double)
% Replace parsed experimental ground reaction moments about midfoot
% superior marker projected onto floor
function [replacedMoments, momentCenter] = ...
    replaceMomentsAboutMidfootSuperior(surface, inputs)
    replacedMoments = ...
        zeros(size(surface.experimentalGroundReactionMoments));
    momentCenter = zeros(size(surface.midfootSuperiorPosition));
    for i = 1:size(replacedMoments, 2)
        newCenter = surface.midfootSuperiorPosition(:, i);
        newCenter(2) = 0;
        replacedMoments(:, i) = ...
            surface.experimentalGroundReactionMoments(:, i) + ...
            cross((surface.electricalCenter(:, i) - newCenter), ...
            surface.experimentalGroundReactionForces(:, i));
        momentCenter(:, i) = newCenter;
    end
end
