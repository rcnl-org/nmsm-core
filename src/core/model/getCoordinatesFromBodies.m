% This function is part of the NMSM Pipeline, see file for full license.
%
% This function takes a model and an array of body names and returns an
% array of strings of coordinates directly connected to the bodies.
%
% (Model, Array of string) -> (Array of string)
% Create and return an array of coordinate names associated with the bodies

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

function coordinates = getCoordinatesFromBodies(model, bodies)
coordinates = {};
for i = 0 : model.getJointSet().getSize()-1
    childName = model.findComponent(model.getJointSet().get(i) ...
        .getChildFrame().getSocket('parent').getConnecteePath()) ...
        .getName().toCharArray';
    if(any(strcmp(bodies, childName)))
        for j=0:model.getJointSet().get(i).numCoordinates()-1
            coordinates{end+1} = model.getJointSet().get(i) ...
                .get_coordinates(j);
        end
    end
end
coordinates = string(coordinates);
end

