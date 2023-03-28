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

function osimx = addGcpContactSurface(osimx, springs, isLeftFoot, ...
    toeCoordinate, toeJoint)

groundContact = osimx.NMSMPipelineDocument.OsimxModel.RCNLGroundContact;

groundContact.GCPContactSurfaceSet.GCPContactSurface.is_left_foot.Text = ...
    isLeftFoot;
groundContact.GCPContactSurfaceSet.GCPContactSurface.toe_coordinate.Text = ...
    toeCoordinate;
groundContact.GCPContactSurfaceSet.GCPContactSurface.toe_joint.Text = ...
    toeJoint;

contactSurface = groundContact.GCPContactSurfaceSet.GCPContactSurface;

for i = 1:length(springs)
    contactSurface.GCPSpringSet.objects.GCPSpring{i}.Attributes.name = ...
        springs{i}.name;
    contactSurface.GCPSpringSet.objects.GCPSpring{i}.parent_body.Text = ...
        springs.parentBody;
    contactSurface.GCPSpringSet.objects.GCPSpring{i}.location.Text = ...
        springs.location;
    contactSurface.GCPSpringSet.objects.GCPSpring{i}.spring_constant.Text = ...
        springs.spring_constant;
end
contactSurface.GCPSpringSet.groups = "";
end

