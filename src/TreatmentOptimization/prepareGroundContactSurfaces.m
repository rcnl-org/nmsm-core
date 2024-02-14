% This function is part of the NMSM Pipeline, see file for full license.
%
%
% (struct) -> (struct)
% Prepares the ground contact surface parameters and springs

% ----------------------------------------------------------------------- %
% The NMSM Pipeline is a toolkit for model personalization and treatment  %
% optimization of neuromusculoskeletal models through OpenSim. See        %
% nmsm.rice.edu and the NOTICE file for more information. The             %
% NMSM Pipeline is developed at Rice University and supported by the US   %
% National Institutes of Health (R01 EB030520).                           %
%                                                                         %
% Copyright (c) 2021 Rice University and the Authors                      %
% Author(s): Marleny Vega                                                 %
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

function contactSurfaces = prepareGroundContactSurfaces(osimModel, ...
    contactSurfaces)
import org.opensim.modeling.Model
osimModel = Model(osimModel);
osimModel.finalizeConnections();

for i=1:length(contactSurfaces)
    contactSurfaces{i} = getParentChildSprings(osimModel, contactSurfaces{i});
    contactSurfaces{i}.midfootSuperiorPointOnBody = Vec3ToArray(osimModel ...
        .getMarkerSet.get(contactSurfaces{i}.midfootSuperiorMarker).get_location());
    contactSurfaces{i}.midfootSuperiorBody = osimModel.getBodySet.getIndex( ...
        osimModel.getMarkerSet.get(contactSurfaces{i}.midfootSuperiorMarker). ...
        getParentFrame().getName());
    contactSurfaces{i}.childBody = osimModel.getBodySet.getIndex(contactSurfaces{i}.childBodyName);
    contactSurfaces{i}.parentBody = osimModel.getBodySet. ...
        getIndex(contactSurfaces{i}.parentBodyName);
end
end

function contactSurface = getParentChildSprings(osimModel, contactSurface)
contactSurface.parentSpringPointsOnBody = [];
contactSurface.parentSpringConstants = [];
contactSurface.childSpringPointsOnBody = [];
contactSurface.childSpringConstants = [];
joints = getBodyJointNames(osimModel, contactSurface.hindfootBodyName);
assert(length(joints) == 2, ...
    "Treatment Optimization supports two segment foot models only");
for i = 1 : length(joints)
    [parent, ~] = getJointBodyNames(osimModel, joints(i));
    if strcmp(parent, contactSurface.hindfootBodyName)
        contactSurface.toesJointName = joints(i);
        break
    end
end
[contactSurface.parentBodyName, contactSurface.childBodyName] = ...
    getJointBodyNames(osimModel, contactSurface.toesJointName);
for j = 1:length(contactSurface.springs)
    if strcmp(contactSurface.springs{j}.parentBody, contactSurface.parentBodyName)
        contactSurface.parentSpringPointsOnBody(end+1, :) = ...
            contactSurface.springs{j}.location;
        contactSurface.parentSpringConstants(end+1) = ...
            contactSurface.springs{j}.springConstant;
    elseif strcmp(contactSurface.springs{j}.parentBody, contactSurface.childBodyName)
        contactSurface.childSpringPointsOnBody(end+1, :) = ...
            contactSurface.springs{j}.location;
        contactSurface.childSpringConstants(end+1) = ...
            contactSurface.springs{j}.springConstant;
    end
end
end