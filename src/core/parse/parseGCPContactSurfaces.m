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

function output = parseGCPContactSurfaces(inputs, tree)
import org.opensim.modeling.Model
model = Model(inputs.model);
model.finalizeConnections();

contactSurfaces = getFieldByNameOrError(tree, 'ContactSurfaceSet') ...
    .objects.ContactSurface;
for i=1:length(contactSurfaces)
    surface = contactSurfaces{i};
    output{i} = parseFootData(surface);
    output{i} = parseGroundReactionData(inputs.model, ...
        inputs.grfFileName, output{i});
    tempFields = {'electricalCenterColumns'};
    output{i} = rmfield(output{i}, tempFields);
    output{i}.midfootSuperiorPointOnBody(1) = ...
        model.getMarkerSet.get(output{i}.midfootSuperior).get_location().get(0);
    output{i}.midfootSuperiorPointOnBody(2) = ...
        model.getMarkerSet.get(output{i}.midfootSuperior).get_location().get(1);
    output{i}.midfootSuperiorPointOnBody(3) = ...
        model.getMarkerSet.get(output{i}.midfootSuperior).get_location().get(2);
    output{i}.midfootSuperiorBody = model.getBodySet.getIndex( ...
        model.getMarkerSet.get(output{i}.midfootSuperior).getParentFrame().getName());
    output{i}.toeBody = model.getBodySet.getIndex(output{i}.toeBodyName);
    output{i}.calcaneusBody = model.getBodySet.getIndex(output{i}.calcaneusBodyName);
end
end

function output = parseFootData(tree)
    output.isLeftFoot = strcmpi('true', ...
        getFieldByNameOrError(tree, 'is_left_foot').Text);
    output.toeBodyName = getFieldByNameOrError(tree, ...
        'toe_body').Text;
    output.calcaneusBodyName = getFieldByNameOrError(tree, ...
        'calcaneus_body').Text;
    output.midfootSuperior = getFieldByNameOrError(tree, ...
        'midfoot_superior_marker').Text;
    output.forceColumns = split(getFieldByNameOrError(tree, ...
        'force_columns').Text);
    output.momentColumns = split(getFieldByNameOrError(tree, ...
        'moment_columns').Text);
    output.electricalCenterColumns = split(getFieldByNameOrError(tree, ...
        'electrical_center_columns').Text);
end

function output = parseGroundReactionData(bodyModel, grfFile, output)
import org.opensim.modeling.Storage
[grfColumnNames, ~, grfData] = parseMotToComponents(...
    Model(bodyModel), Storage(grfFile));
for i=1:size(grfColumnNames')
    label = grfColumnNames(i);
    for j = 1:3
        if strcmpi(label, output.forceColumns(j, :))
            grf(j, :) = grfData(i, :);
        end
        if strcmpi(label, output.momentColumns(j, :))
            moments(j, :) = grfData(i, :);
        end
        if strcmpi(label, output.electricalCenterColumns(j, :))
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