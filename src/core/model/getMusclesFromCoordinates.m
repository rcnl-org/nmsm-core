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

% NEED TO FIX: a muscle is matched to the joint whose child body holds one
% of its path points, not to the joints it spans
%   - extra: the joint above the origin body is matched, e.g. soleus_r and
%     tibant_r (tibia, calcn) are selected for knee_angle_r
%   - missing: joints spanned with no path point on the child body are
%     skipped, e.g. gasmed_r (femur, calcn) is not selected for
%     knee_angle_r or ankle_angle_r
%   - ankle_angle_r alone selects no muscles, the ankle's child body is
%     the talus and no muscle attaches there
% Lists with hip, knee and ankle together still select the right muscles,
% because every leg muscle touches the pelvis, femur or tibia; partial
% lists do not. Used by MTP, MTLI, NCP and the TO synergy controller.
% Possible fix: match the joints on the kinematic tree path between
% consecutive path-point bodies
function output = isMuscleInCoordinates(model, coordinates, muscle)
if muscle.get_appliesForce()
    path = muscle.getGeometryPath().getPathPointSet();
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
