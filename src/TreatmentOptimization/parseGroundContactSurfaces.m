% This function is part of the NMSM Pipeline, see file for full license.
%
% () -> ()
% 

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

function contactSurfaces = parseGroundContactSurfaces(inputs)
contactSurfacesField = getFieldByName(inputs.osimx, 'contactSurface');
if (isstruct(contactSurfacesField) || iscell(contactSurfacesField)) && ...
        isfield(inputs, 'grfFileName')
    contactSurfaces = prepareGroundContactSurfaces(inputs.model, ...
        contactSurfacesField, inputs.grfFileName);
else
    contactSurfaces = {};
end
end

function output = prepareGroundContactSurfaces(osimModel, ...
    contactSurfaces, grfFileName)
import org.opensim.modeling.Model
osimModel = Model(osimModel);
osimModel.finalizeConnections();

for i=1:length(contactSurfaces)
    output{i} = getParentChildSprings(osimModel, contactSurfaces{i});
    output{i}.midfootSuperiorPointOnBody(1) = osimModel.getMarkerSet. ...
        get(output{i}.midfootSuperiorMarker).get_location().get(0);
    output{i}.midfootSuperiorPointOnBody(2) = osimModel.getMarkerSet. ...
        get(output{i}.midfootSuperiorMarker).get_location().get(1);
    output{i}.midfootSuperiorPointOnBody(3) = osimModel.getMarkerSet. ...
        get(output{i}.midfootSuperiorMarker).get_location().get(2);
    output{i}.midfootSuperiorBody = osimModel.getBodySet.getIndex( ...
        osimModel.getMarkerSet.get(output{i}.midfootSuperiorMarker). ...
        getParentFrame().getName());
    output{i}.childBody = osimModel.getBodySet.getIndex(output{i}.childBodyName);
    output{i}.parentBody = osimModel.getBodySet. ...
        getIndex(output{i}.parentBodyName);
    output{i} = parseGroundReactionDataWithoutTime(osimModel, ...
        grfFileName, output{i});
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

function output = parseGroundReactionDataWithoutTime(model, grfFile, output)
import org.opensim.modeling.Storage
[grfColumnNames, ~, grfData] = parseMotToComponents(model, Storage(grfFile));
for i=1:size(grfColumnNames', 1)
    label = grfColumnNames(i);
    for j = 1:3
        if strcmpi(label, output.forceColumns(j))
            grf(j, :) = grfData(i, :);
        end
        if strcmpi(label, output.momentColumns(j))
            moments(j, :) = grfData(i, :);
        end
        if strcmpi(label, output.electricalCenterColumns(j))
            ec(j, :) = grfData(i, :);
        end
    end
end
if any([isnan(grf) isnan(moments) isnan(ec)])
    throw(MException('', ['Unable to parse GRF file, check that ' ...
        'all necessary column labels are present']))
end
output.experimentalGroundReactionForces = grf';
output.experimentalGroundReactionMoments = moments';
output.electricalCenter = ec';
end