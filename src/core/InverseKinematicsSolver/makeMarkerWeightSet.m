% This function is part of the NMSM Pipeline, see file for full license.
%
% This function makes a marker weight set from the names of the markers and
% weights such that the name and weight at the same index of their arrays
% will be matched.
%
% (Array of string, Array of number) -> (MarkerWeightSet)
% Generate a MarkerWeightSet from an array of names and weights

% ----------------------------------------------------------------------- %
% The NMSM Pipeline is a toolkit for model personalization and treatment  %
% optimization of neuromusculoskeletal models through OpenSim. See        %
% nmsm.rice.edu and the NOTICE file for more information. The             %
% NMSM Pipeline is developed at Rice University and supported by the US   %
% National Institutes of Health (R01 EB030520).                           %
%                                                                         %
% Copyright (c) 2021 Rice University and the Authors                      %
% Author(s): Claire Hammond                                               %
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

function markerWeightSet = makeMarkerWeightSet(markerNames, weights)
if(length(markerNames) ~= length(weights))
    throw(MException('',strcat('Marker name array and weight array ', ...
        'are not the same length')))
end
import org.opensim.modeling.*
markerWeightSet = SetMarkerWeights();
for i=1:length(markerNames)
    markerWeightSet.cloneAndAppend(MarkerWeight( ...
        markerNames(i), weights(i)));
end
end

