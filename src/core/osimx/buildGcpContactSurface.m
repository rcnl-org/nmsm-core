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
% Author(s): Claire V. Hammond, Marleny Vega                              %
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
groundContact = osimx.NMSMPipelineDocument.OsimxModel.RCNLContactSurfaceSet;

if(~isstruct(groundContact))
    i = 1;
    groundContact.RCNLContactSurface = {};
else
    i = length(groundContact.RCNLContactSurface) + 1;
    if length(groundContact.RCNLContactSurface) == 1
        groundContact.RCNLContactSurface = ...
            {groundContact.RCNLContactSurface};
    end
end

contact = groundContact.RCNLContactSurface;
contact{i}.is_left_foot.Comment = ...
    'Flag indicating whether foot model should be mirrored';
isLeftFoot = "false"; if contactSurface.isLeftFoot; isLeftFoot = "true"; end
contact{i}.is_left_foot.Text = convertStringsToChars(isLeftFoot);
contact{i}.belt_speed.Comment = ...
    'Speed of treadmill belt for recorded motion. Set to 0 if not applicable';
contact{i}.belt_speed.Text = contactSurface.beltSpeed;

contact{i}.force_columns.Comment = ...
    'Names of the force columns in the grf file, ordered X, Y, Z';
contact{i}.force_columns.Text = ...
    convertStringsToChars(strjoin(contactSurface.forceColumns));
contact{i}.moment_columns.Comment = ...
    'Names of the moment columns in the grf file, ordered X, Y, Z';
contact{i}.moment_columns.Text = ...
    convertStringsToChars(strjoin(contactSurface.momentColumns));
contact{i}.electrical_center_columns.Comment = ...
    'Names of the electrical center columns in the grf file, ordered X, Y, Z';
contact{i}.electrical_center_columns.Text = ...
    convertStringsToChars(strjoin(contactSurface.electricalCenterColumns));

contact{i}.hindfoot_body.Comment = ...
    'Name of the hindfoot body in the model file';
contact{i}.hindfoot_body.Text = contactSurface.hindfootBodyName;

contact{i}.toe_marker.Comment = ...
    'Names of the markers used to define the foot area';
contact{i}.toe_marker.Text = ...
    convertStringsToChars(contactSurface.toeMarker);
contact{i}.medial_marker = ...
    convertStringsToChars(contactSurface.medialMarker);
contact{i}.lateral_marker = ...
    convertStringsToChars(contactSurface.lateralMarker);
contact{i}.heel_marker = ...
    convertStringsToChars(contactSurface.heelMarker);
contact{i}.midfoot_superior_marker = ...
    convertStringsToChars(contactSurface.midfootSuperiorMarker);

contact{i}.resting_spring_length.Comment = ...
    'The resting spring length of the surface';
contact{i}.resting_spring_length.Text = ...
    convertStringsToChars(num2str(contactSurface.restingSpringLength));
contact{i}.dynamic_friction_coefficient.Comment = ...
    'The dynamic friction coefficient of the surface';
contact{i}.dynamic_friction_coefficient.Text = ...
    convertStringsToChars(num2str(contactSurface.dynamicFrictionCoefficient));
contact{i}.viscous_friction_coefficient.Comment = ...
    'The viscous friction coefficient of the surface';
contact{i}.viscous_friction_coefficient.Text = ...
    convertStringsToChars(num2str(contactSurface.viscousFrictionCoefficient));
contact{i}.damping_factor.Comment = 'The damping factor of the surface';
contact{i}.damping_factor.Text = ...
    convertStringsToChars(num2str(contactSurface.dampingFactor));
contact{i}.latching_velocity.Comment = 'The latching velocity of the surface';
contact{i}.latching_velocity.Text = ...
    convertStringsToChars(num2str(contactSurface.latchingVelocity));

newContactSurface = contact{i};
newContactSurface.GCPSpringSet.Comment = ...
    'The set of springs for the contact surface';
for j = 1:length(contactSurface.springs)
    newContactSurface = buildGcpSpring(newContactSurface, ...
        contactSurface.springs{j});
end
osimx.NMSMPipelineDocument.OsimxModel.RCNLContactSurfaceSet. ...
    RCNLContactSurface{i} = newContactSurface;
end

