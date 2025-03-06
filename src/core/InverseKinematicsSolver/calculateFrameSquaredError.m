% This function is part of the NMSM Pipeline, see file for full license.
%
% This function computes the sum of the squared error for all the markers
% in the argument InverseKinematicsSolver's current frame. The frame can be
% set by initialization an InverseKinematicsSolver, initializing the Model
% system, assembling the InverseKinematicsSolver for a given time.
%
% (InverseKinematicsSolver) -> (number)
% iterate through markers and sum the error
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

function error = calculateFrameSquaredError(ikSolver)
persistent solverMarkerNames
if isempty(solverMarkerNames)
    solverMarkerNames = cell(1, ikSolver.getNumMarkersInUse());
    for i = 1 : ikSolver.getNumMarkersInUse()
        solverMarkerNames{i} = ...
            ikSolver.getMarkerNameForIndex(i - 1);
            % ikSolver.getMarkerNameForIndex(i - 1).toCharArray';
            % string(ikSolver.getMarkerNameForIndex(i - 1).toCharArray');
    end
end
error = zeros(1, length(solverMarkerNames));
for i= 1 : length(error)
    error(i) = ikSolver.computeCurrentMarkerError(solverMarkerNames{i});
end
error = error / sqrt(length(error));
end

