% This function is part of the NMSM Pipeline, see file for full license.(
%
%
%
% (struct, string) -> (None)
% Write calibrated ground contact model parameters to an .osimx file.

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

function writeGroundContactPersonalizationOsimxFile(inputs, ...
    resultsDirectory, osimxFileName)
modelFileName = inputs.bodyModel;
model = Model(modelFileName);

if isfile(osimxFileName)
    osimx = parseOsimxFile(inputs.inputOsimxFile, model);
    [~, name, ~] = fileparts(inputs.inputOsimxFile);
    outfile = fullfile(resultsDirectory, strcat(name, "_gcp.xml"));
else
    osimx = buildGcpOsimxTemplate(...
        replace(model.getName().toCharArray',".","_dot_"), modelFileName);
    [~, name, ~] = fileparts(modelFileName);
    outfile = fullfile(resultsDirectory, strcat(name, "_gcp.xml"));
end
osimx.modelName = name;
osimx.model = modelFileName;

osimx = addGcpContactSurfaces(osimx, inputs);

writeOsimxFile(buildOsimxFromOsimxStruct(osimx), outfile);
end

function osimx = addGcpContactSurfaces(osimx, inputs)
if ~isfield(osimx, 'groundContact')
    osimx.groundContact.contactSurface = {};
end
for foot = 1:length(inputs.surfaces)    
    newSurface.isLeftFoot = inputs.surfaces{foot}.isLeftFoot;
    newSurface.beltSpeed = inputs.surfaces{foot}.beltSpeed;
    newSurface.forceColumns = string(inputs.surfaces{foot}.forceColumns)';
    newSurface.momentColumns = string(inputs.surfaces{foot}.momentColumns)';
    newSurface.electricalCenterColumns = string(inputs.surfaces{foot} ...
        .electricalCenterColumns)';
    newSurface.toesCoordinateName = inputs.surfaces{foot} ...
        .toesCoordinateName;
    newSurface.toesJointName = inputs.surfaces{foot}.toesJointName;
    newSurface.toeMarker = inputs.surfaces{foot}.markerNames.toe;
    newSurface.medialMarker = inputs.surfaces{foot}.markerNames.medial;
    newSurface.lateralMarker = inputs.surfaces{foot}.markerNames.lateral;
    newSurface.heelMarker = inputs.surfaces{foot}.markerNames.heel;
    newSurface.midfootSuperiorMarker = inputs.surfaces{foot} ...
        .markerNames.midfootSuperior;
    newSurface.restingSpringLength = inputs.restingSpringLength;
    newSurface.dynamicFrictionCoefficient = inputs ...
        .dynamicFrictionCoefficient;
    newSurface.viscousFrictionCoefficient = inputs ...
        .viscousFrictionCoefficient;
    newSurface.dampingFactor = inputs.dampingFactor;
    newSurface.latchingVelocity = inputs.latchingVelocity;

    for i = 1:length(inputs.springConstants)
        newSurface.springs{i} = addGcpSpring(inputs, foot, i);
    end

    index = 1 + length(osimx.groundContact.contactSurface);
    osimx.groundContact.contactSurface{index} = newSurface;
end
end

function spring = addGcpSpring(inputs, foot, springNumber)
    spring.name = "spring_marker_" + springNumber;
    model = Model("footModel_" + foot + ".osim");
    springMarker = model.getMarkerSet.get(spring.name);
    spring.parentBody = getMarkerBodyName(model, spring.name);
    spring.location = Vec3ToArray(springMarker.get_location());
    spring.springConstant = inputs.springConstants(springNumber);
end
