% This function is part of the NMSM Pipeline, see file for full license.
%
% This function returns a string array of the muscles in the model in the
% order they are listed in the model
%
% (Model) -> (Array of string)
% Returns the muscles in the model

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

function muscles = getMusclesFromCoordinates(model, ...
    coordinates)
if ~isa(model, 'org.opensim.modeling.Model')
    model = Model(model);
end
muscles = string([]);
for i=0:model.getForceSet().getMuscles().getSize() - 1
    if(isMuscleInCoordinates(model, coordinates, ...
            model.getForceSet().getMuscles().get(i)))
        muscles(end + 1) = ...
            model.getForceSet().getMuscles().get(i).getName().toCharArray()';
    end
end
end

function output = isMuscleInCoordinates(model, coordinates, muscle)
if muscle.get_appliesForce()
    path = muscle.get_GeometryPath().getPathPointSet();
    for j = 0 : path.getSize() - 1
        bodyCoordinates = getCoordinatesFromBodies(model, ...
            path.get(j).getBodyName().toCharArray()');
        for k = 1 : length(bodyCoordinates)
            if(any(strcmp(coordinates, bodyCoordinates(k))))
                output = true;
                return
            end
        end
    end
end
output = false;
end
