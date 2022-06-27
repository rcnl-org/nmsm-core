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
[state, numFrames, frequency, finishTime] = prepareFrameIterations(...
    model, ikSolver, markersReference, params);
markerTable = markersReference.getMarkerTable();
times = markerTable.getIndependentColumn();
error = [];
frameCounter = 0;
for i=1:numFrames - 1 %start time is set so start with recording error
    ikSolver.track(state);
    error = [error calculateFrameSquaredError(ikSolver)];
    frameCounter = frameCounter + 1;
    time = times.get(markerTable.getNearestRowIndexForTime( ...
        state.getTime() + 1/frequency));
    state.setTime(double(time));
    if(finishTime)
        if(state.getTime() + 1/frequency > finishTime);break;end
    end
end
error = error / sqrt(frameCounter);
end

% (Model, InverseKinematicsSolver, MarkersReference, struct) =>
% (State, number, number, number)
% Parses params for the IKSolver
function [state, numFrames, frequency, finishTime] = ...
        prepareFrameIterations(model, ikSolver, markersReference, params)
state = initModelSystem(model);
state.setTime(valueOrAlternate(params, 'startTime', ...
    markersReference.getValidTimeRange().get(0)));
ikSolver.assemble(state);
numFrames = valueOrAlternate(params, 'numFrames', ...
    markersReference.getNumFrames());
frequency = valueOrAlternate(params, 'frequency', ...
    markersReference.getSamplingFrequency());
finishTime = valueOrZero(params, 'finishTime');
end
