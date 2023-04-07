% This function is part of the NMSM Pipeline, see file for full license.
%
% This function converts the contactSurface portion of a parsed .osimx file
% into a new .osimx struct to be printed with writeOsimxFile(). See
% buildOsimxFromOsimxStruct() and buildGcpOsimx() for reference.
%
% (string, string, number, number, number) -> (struct)
% Adds groundContact to .osimx struct

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

function osimx = buildGcpContactSurface(osimx, contactSurface)
osimx.NMSMPipelineDocument.OsimxModel.RCNLGroundContact.Comment = ...
    'The modeled ground contact data';
groundContact = osimx.NMSMPipelineDocument.OsimxModel.RCNLGroundContact;

if ~isfield(groundContact, "RCNLContactSurfaceSet")
    groundContact.RCNLContactSurfaceSet.RCNLContactSurface = {};
end

i = length(groundContact.RCNLContactSurfaceSet.RCNLContactSurface) + 1;

groundContact.RCNLContactSurfaceSet.RCNLContactSurface{i}.is_left_foot.Comment = ...
    'Flag indicating whether foot model should be mirrored';
isLeftFoot = "false"; if contactSurface.isLeftFoot; isLeftFoot = "true"; end
groundContact.RCNLContactSurfaceSet.RCNLContactSurface{i}.is_left_foot.Text = ...
    convertStringsToChars(isLeftFoot);
groundContact.RCNLContactSurfaceSet.RCNLContactSurface{i}.belt_speed.Comment = ...
    'Speed of treadmill belt for recorded motion. Set to 0 if not applicable';
groundContact.RCNLContactSurfaceSet.RCNLContactSurface{i}.belt_speed.Text = ...
    contactSurface.beltSpeed;

groundContact.RCNLContactSurfaceSet.RCNLContactSurface{i}.force_columns.Comment = ...
    'Names of the force columns in the grf file, ordered X, Y, Z';
groundContact.RCNLContactSurfaceSet.RCNLContactSurface{i}.force_columns.Text = ...
    convertStringsToChars(strjoin(contactSurface.forceColumns));
groundContact.RCNLContactSurfaceSet.RCNLContactSurface{i}.moment_columns.Comment = ...
    'Names of the moment columns in the grf file, ordered X, Y, Z';
groundContact.RCNLContactSurfaceSet.RCNLContactSurface{i}.moment_columns.Text = ...
    convertStringsToChars(strjoin(contactSurface.momentColumns));
groundContact.RCNLContactSurfaceSet.RCNLContactSurface{i}.electrical_center_columns.Comment = ...
    'Names of the electrical center columns in the grf file, ordered X, Y, Z';
groundContact.RCNLContactSurfaceSet.RCNLContactSurface{i}.electrical_center_columns.Text = ...
    convertStringsToChars(strjoin(contactSurface.electricalCenterColumns));

groundContact.RCNLContactSurfaceSet.RCNLContactSurface{i}.toes_coordinate.Comment = ...
    'Name of the toe angle coordinate in the model file';
groundContact.RCNLContactSurfaceSet.RCNLContactSurface{i}.toes_coordinate.Text = ...
    contactSurface.toesCoordinateName;
groundContact.RCNLContactSurfaceSet.RCNLContactSurface{i}.toes_joint.Comment = ...
    'Name of the toe joint in the model file';
groundContact.RCNLContactSurfaceSet.RCNLContactSurface{i}.toes_joint.Text = ...
    contactSurface.toesJointName;

groundContact.RCNLContactSurfaceSet.RCNLContactSurface{i}.toe_marker.Comment = ...
    'Names of the markers used to define the foot area';
groundContact.RCNLContactSurfaceSet.RCNLContactSurface{i}.toe_marker.Text = ...
    convertStringsToChars(contactSurface.toeMarker);
groundContact.RCNLContactSurfaceSet.RCNLContactSurface{i}.medial_marker = ...
    convertStringsToChars(contactSurface.medialMarker);
groundContact.RCNLContactSurfaceSet.RCNLContactSurface{i}.lateral_marker = ...
    convertStringsToChars(contactSurface.lateralMarker);
groundContact.RCNLContactSurfaceSet.RCNLContactSurface{i}.heel_marker = ...
    convertStringsToChars(contactSurface.heelMarker);
groundContact.RCNLContactSurfaceSet.RCNLContactSurface{i}.midfoot_superior_marker = ...
    convertStringsToChars(contactSurface.midfootSuperiorMarker);


groundContact.RCNLContactSurfaceSet.RCNLContactSurface{i}.resting_spring_length.Comment = ...
    'The resting spring length of the surface';
groundContact.RCNLContactSurfaceSet.RCNLContactSurface{i}.resting_spring_length.Text = ...
    convertStringsToChars(num2str(contactSurface.restingSpringLength));
groundContact.RCNLContactSurfaceSet.RCNLContactSurface{i}.dynamic_friction_coefficient.Comment = ...
    'The dynamic friction coefficient of the surface';
groundContact.RCNLContactSurfaceSet.RCNLContactSurface{i}.dynamic_friction_coefficient.Text = ...
    convertStringsToChars(num2str(contactSurface.dynamicFrictionCoefficient));
groundContact.RCNLContactSurfaceSet.RCNLContactSurface{i}.viscous_friction_coefficient.Comment = ...
    'The viscous friction coefficient of the surface';
groundContact.RCNLContactSurfaceSet.RCNLContactSurface{i}.viscous_friction_coefficient.Text = ...
    convertStringsToChars(num2str(contactSurface.viscousFrictionCoefficient));
groundContact.RCNLContactSurfaceSet.RCNLContactSurface{i}.damping_factor.Comment = 'The damping factor of the surface';
groundContact.RCNLContactSurfaceSet.RCNLContactSurface{i}.damping_factor.Text = ...
    convertStringsToChars(num2str(contactSurface.dampingFactor));

groundContact.RCNLContactSurfaceSet.Comment = 'The set of contact surfaces modeled';

groundContact.RCNLContactSurfaceSet.RCNLContactSurface{i}.Comment = ...
    'The set of contact surfaces modeled';
newContactSurface = groundContact.RCNLContactSurfaceSet.RCNLContactSurface{i};
newContactSurface.GCPSpringSet.Comment = 'The set of springs for the contact surface';
for i = 1:length(contactSurface.springs)
    newContactSurface = buildGcpSpring(newContactSurface, contactSurface.springs{i});
end
newContactSurface.GCPSpringSet.groups = '';
groundContact.RCNLContactSurfaceSet.RCNLContactSurface = newContactSurface;
osimx.NMSMPipelineDocument.OsimxModel.RCNLGroundContact = groundContact;
end

