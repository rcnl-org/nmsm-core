% This function is part of the NMSM Pipeline, see file for full license.
%
% This function computes the sum of the squared error of the markers over
% the given frames
%
% (Model, InverseKinematicsSolver, struct) -> (number)
% Computes the sum of the squared error of the markers through all frames

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

function error = computeInverseKinematicsSquaredError(model, ikSolver, ...
    markersReference, params)
import org.opensim.modeling.*
persistent errorSize;
try
    [state, frameTimes] = prepareFrameIterations(model, ikSolver, ...
        markersReference, params);
    error = [];
    for i = 1:numel(frameTimes)
        state.setTime(frameTimes(i));
        ikSolver.track(state);
        error = [error calculateFrameSquaredError(ikSolver)];
    end
    error = error / sqrt(numel(frameTimes));
    errorSize = size(error);
catch
    error = 1e2 * ones(errorSize);
end
end

% (Model, InverseKinematicsSolver, MarkersReference, struct) =>
% (State, Array of number)
% Finds the frames in the time range and assembles the first one
function [state, frameTimes] = prepareFrameIterations(model, ikSolver, ...
    markersReference, params)
frameTimes = getMarkerFrameTimes(markersReference, ...
    valueOrAlternate(params, 'startTime', ...
    markersReference.getValidTimeRange().get(0)), ...
    valueOrAlternate(params, 'finishTime', ...
    markersReference.getValidTimeRange().get(1)));
state = initModelSystem(model);
state.setTime(frameTimes(1));
ikSolver.assemble(state);
end
