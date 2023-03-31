% This function is part of the NMSM Pipeline, see file for full license.
%
% This function adds a GcpContactSurface to an existing osimx struct
% created by buildGcpOsimxTemplate() or buildOsimxTemplate()
%
% (string, string, number, number, number) -> (struct)
% Prints a generic template for an osimx file

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

function osimx = addGcpContactSurface(osimx, surface, springConstants)

osimx.NMSMPipelineDocument.OsimxModel.RCNLGroundContact.Comment = ...
    'The modeled ground contact data';
groundContact = osimx.NMSMPipelineDocument.OsimxModel.RCNLGroundContact;

groundContact.GCPContactSurfaceSet.GCPContactSurface.is_left_foot.Comment = ...
    'Flag indicating whether foot model should be mirrored';
isLeftFoot = "false"; if surface.isLeftFoot; isLeftFoot = "true"; end
groundContact.GCPContactSurfaceSet.GCPContactSurface.is_left_foot.Text = ...
    convertStringsToChars(isLeftFoot);
groundContact.GCPContactSurfaceSet.GCPContactSurface.toes_coordinate.Comment = ...
    'Name of the toe angle coordinate in the model file';
groundContact.GCPContactSurfaceSet.GCPContactSurface.toes_coordinate.Text = ...
    surface.toesCoordinateName;
groundContact.GCPContactSurfaceSet.GCPContactSurface.toes_joint.Comment = ...
    'Name of the toe joint in the model file';
groundContact.GCPContactSurfaceSet.GCPContactSurface.toes_joint.Text = ...
    surface.toesJointName;

groundContact.GCPContactSurfaceSet.Comment = 'The set of contact surfaces modeled';

groundContact.GCPContactSurfaceSet.GCPContactSurface.Comment = ...
    'The set of contact surfaces modeled';
contactSurface = groundContact.GCPContactSurfaceSet.GCPContactSurface;
contactSurface.GCPSpringSet.Comment = 'The set of springs for the contact surface';

model = Model(surface.model);
for marker = 1:surface.numSpringMarkers
    contactSurface = addGcpSpring(contactSurface, model, marker, ...
        springConstants(marker));
end
contactSurface.GCPSpringSet.groups = '';
groundContact.GCPContactSurfaceSet.GCPContactSurface = contactSurface;
osimx.NMSMPipelineDocument.OsimxModel.RCNLGroundContact = groundContact;
end

