% This function is part of the NMSM Pipeline, see file for full license.
%
% MarkersReference is needed for InverseKinematicSolver as an
% initialization value. Using the model as reference, the params included
% define the markers that exist in the marker reference.
% The params are a struct containing the parameters for the
% MarkersReference. The Set of MarkerWeight is initialized with all markers
% from the model at a weight of one. Params can be set to modify excluded
% markers and change markerWeights.
% params.markerFileName = (string)
% params.excludedMarkers = (1D array of strings (names))
% params.markerWeights = (struct of weights other than 1)
%
% (Model, struct) -> (MarkersReference)
% Makes a MarkersReference from a given model and parameters

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

function markersReference = makeMarkersReference(model, markerFileName, ...
    params)
import org.opensim.modeling.MarkersReference
markerWeightSet = makeDefaultMarkerWeightSet(model);
if(isfield(params, 'excludedMarkers'))
    markerWeightSet = excludeMarkers(markerWeightSet, ...
        params.excludedMarkers);
end
if(isfield(params, 'markerWeights'))
    markerWeightSet = adjustMarkerWeights(markerWeightSet, ...
        params.markerWeights);
end
markersReference = MarkersReference(markerFileName, markerWeightSet);
end

