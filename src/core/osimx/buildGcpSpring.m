% This function is part of the NMSM Pipeline, see file for full license.
%
% This function converts the spring portion of a parsed .osimx file
% into a new .osimx struct to be printed with writeOsimxFile(). See
% buildOsimxFromParsedOsimx(), buildGcpOsimx(), and 
% buildGcpContactSurface() for reference.
%
% (struct, struct) -> (struct)
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

function contactSurface = buildGcpSpring(contactSurface, spring)
split = strsplit(spring.name, "_");
markerNumberStr = split{end};
markerNumber = str2num(markerNumberStr);
contactSurface.GCPSpringSet.objects.GCPSpring{markerNumber}.Attributes.name = ...
    convertStringsToChars(spring.name);
contactSurface.GCPSpringSet.objects.GCPSpring{markerNumber}.parent_body.Comment = ...
    'The body that the spring is attached to';
contactSurface.GCPSpringSet.objects.GCPSpring{markerNumber}.parent_body.Text = ...
    spring.parentBody;
contactSurface.GCPSpringSet.objects.GCPSpring{markerNumber}.location.Comment = ...
    'The location of the spring in the body it is attached to';
contactSurface.GCPSpringSet.objects.GCPSpring{markerNumber}.location.Text = ...
    num2str([spring.location(1) spring.location(2) spring.location(3)], 15);
contactSurface.GCPSpringSet.objects.GCPSpring{markerNumber}.spring_constant.Comment = ...
    'The modeled spring constant for the spring';
contactSurface.GCPSpringSet.objects.GCPSpring{markerNumber}.spring_constant.Text = ...
    num2str(spring.springConstant, 15);
end

