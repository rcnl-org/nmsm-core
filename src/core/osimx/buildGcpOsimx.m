% This function is part of the NMSM Pipeline, see file for full license.
%
% This function converts the groundContact portion of a parsed .osimx file
% into a new .osimx struct to be printed with writeOsimxFile(). See
% buildOsimxFromParsedOsimx() for reference.
%
% (struct, struct) -> (struct)
% Adds groundContact to .osimxStruct

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

function osimx = buildGcpOsimx(osimx, groundContact)
body = osimx.NMSMPipelineDocument.OsimxModel;

body.RCNLGroundContact.resting_spring_length.Comment = ...
    'The resting spring length of the surface';
body.RCNLGroundContact.resting_spring_length.Text = ...
    convertStringsToChars(num2str(groundContact.restingSpringLength));
body.RCNLGroundContact.dynamic_friction_coefficient.Comment = ...
    'The dynamic friction coefficient of the surface';
body.RCNLGroundContact.dynamic_friction_coefficient.Text = ...
    convertStringsToChars(num2str(groundContact.dynamicFrictionCoefficient));
body.RCNLGroundContact.damping_factor.Comment = 'The damping factor of the surface';
body.RCNLGroundContact.damping_factor.Text = ...
    convertStringsToChars(num2str(groundContact.dampingFactor));

osimx.NMSMPipelineDocument.OsimxModel = body;

for i = 1:length(groundContact.contactSurface)
    osimx = buildGcpContactSurface(osimx, groundContact.contactSurface{i});
end
end

