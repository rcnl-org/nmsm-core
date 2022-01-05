% This function is part of the NMSM Pipeline, see file for full license.
%
% This function makes an InverseKinematicsSolver object from input Model,
% markerfilename and parameters. The params are a struct and have the
% following format:
% params:
%     excludedMarkers - (1D array strings of marker names)
%     markerWeights - struct(marker name, number weight)
%     accuracy - numeric
%     startTime - numeric (default: 0)
%
% (Model, string, struct) -> (InverseKinematicsSolver)
% makes an InverseKinematicsSolver from input values

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

function ikSolver = makeInverseKinematicsSolver(model, markerFileName, ...
    params)
import org.opensim.modeling.*
markersReference = makeMarkersReference(model, markerFileName, params);
ikSolver = makeIKSolverFromMarkersReference(model, markersReference, ...
    params);
end

