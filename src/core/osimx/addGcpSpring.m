% This function is part of the NMSM Pipeline, see file for full license.
%
% This function adds the information about a spring to the
% <GCPContactSurface> in a struct made fom buildGcpOsimxTemplate
%
% (struct, Model, number, 1D array of number) -> (struct) 
% Adds a spring to the contact surface of an osimx file

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

function contactSurface = addGcpSpring(contactSurface, model, ...
    markerNumber, springConstant)
markerName = "spring_marker_" + markerNumber;
springMarker = model.getMarkerSet.get(markerName);
contactSurface.GCPSpringSet.GCPSpring{markerNumber}.Attributes.name = ...
    convertStringsToChars(markerName);
contactSurface.GCPSpringSet.GCPSpring{markerNumber}.parent_body.Comment = ...
    'The body that the spring is attached to';
contactSurface.GCPSpringSet.GCPSpring{markerNumber}.parent_body.Text = ...
    getMarkerBodyName(model, markerName);
location = springMarker.get_location();
contactSurface.GCPSpringSet.GCPSpring{markerNumber}.location.Comment = ...
    'The location of the spring in the body it is attached to';
contactSurface.GCPSpringSet.GCPSpring{markerNumber}.location.Text = ...
    num2str([location.get(0) location.get(1) location.get(2)], 15);
contactSurface.GCPSpringSet.GCPSpring{markerNumber}.spring_constant.Comment = ...
    'The modeled spring constant for the spring';
contactSurface.GCPSpringSet.GCPSpring{markerNumber}.spring_constant.Text = ...
    num2str(springConstant, 15);
end

