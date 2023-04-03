% This function is part of the NMSM Pipeline, see file for full license.
%
% This function converts the contactSurface portion of a parsed .osimx file
% into a new .osimx struct to be printed with writeOsimxFile(). See
% buildOsimxFromParsedOsimx() and buildGcpOsimx() for reference.
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

if ~isfield(groundContact, "GCPContactSurfaceSet")
    groundContact.GCPContactSurfaceSet.GCPContactSurface = {};
end

i = length(groundContact.GCPContactSurfaceSet.GCPContactSurface) + 1;

groundContact.GCPContactSurfaceSet.GCPContactSurface{i}.is_left_foot.Comment = ...
    'Flag indicating whether foot model should be mirrored';
isLeftFoot = "false"; if contactSurface.isLeftFoot; isLeftFoot = "true"; end
groundContact.GCPContactSurfaceSet.GCPContactSurface{i}.is_left_foot.Text = ...
    convertStringsToChars(isLeftFoot);
groundContact.GCPContactSurfaceSet.GCPContactSurface{i}.toes_coordinate.Comment = ...
    'Name of the toe angle coordinate in the model file';
groundContact.GCPContactSurfaceSet.GCPContactSurface{i}.toes_coordinate.Text = ...
    contactSurface.toesCoordinateName;
groundContact.GCPContactSurfaceSet.GCPContactSurface{i}.toes_joint.Comment = ...
    'Name of the toe joint in the model file';
groundContact.GCPContactSurfaceSet.GCPContactSurface{i}.toes_joint.Text = ...
    contactSurface.toesJointName;

groundContact.GCPContactSurfaceSet.Comment = 'The set of contact surfaces modeled';

groundContact.GCPContactSurfaceSet.GCPContactSurface{i}.Comment = ...
    'The set of contact surfaces modeled';
newContactSurface = groundContact.GCPContactSurfaceSet.GCPContactSurface{i};
newContactSurface.GCPSpringSet.Comment = 'The set of springs for the contact surface';
for i = 1:length(contactSurface.springs)
    newContactSurface = buildGcpSpring(newContactSurface, contactSurface.springs{i});
end
newContactSurface.GCPSpringSet.groups = '';
groundContact.GCPContactSurfaceSet.GCPContactSurface = newContactSurface;
osimx.NMSMPipelineDocument.OsimxModel.RCNLGroundContact = groundContact;
end

