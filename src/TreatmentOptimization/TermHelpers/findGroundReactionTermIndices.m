% This function is part of the NMSM Pipeline, see file for full license.
%
% (struct, struct, string, string) -> (number, number)
% Resolves a ground reaction term to the contact surface it applies to and
% the axis within that surface.
%
% Terms name a contact surface with <contact_surface_list> and an axis with
% <axes>. The older <force_list> and <moment_list> elements, which name a
% force plate column, are still accepted. Because a contact surface may
% combine several force plates into one wrench, any of its plates' labels
% for a given axis resolve to the same merged column.

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

function [contactSurfaceIndex, axisIndex] = findGroundReactionTermIndices( ...
    term, inputs, columnFieldName, targetLabel)
if isfield(term, 'contact_surface')
    contactSurfaceIndex = findContactSurfaceIndexByName(inputs, ...
        term.contact_surface, term);
    axisIndex = findAxisIndex(getTermFieldOrError(term, 'axes'), term);
    return
end

targetLabel = convertCharsToStrings(targetLabel);
contactSurfaceIndex = 0;
axisIndex = 0;
for i = 1 : length(inputs.contactSurfaces)
    column = find(strcmp(convertCharsToStrings( ...
        inputs.contactSurfaces{i}.(columnFieldName)), targetLabel), 1);
    if ~isempty(column)
        contactSurfaceIndex = i;
        axisIndex = mod(column - 1, 3) + 1;
    end
end
assert(contactSurfaceIndex ~= 0, term.type + ": " + targetLabel + ...
    " is not a ground reaction column name of any contact surface.");
end

function contactSurfaceIndex = findContactSurfaceIndexByName(inputs, ...
    name, term)
name = convertCharsToStrings(name);
contactSurfaceIndex = 0;
for i = 1 : length(inputs.contactSurfaces)
    if strcmp(convertCharsToStrings(inputs.contactSurfaces{i}.name), name)
        contactSurfaceIndex = i;
    end
end
assert(contactSurfaceIndex ~= 0, term.type + ": " + name + " is not a " + ...
    "contact surface name. Contact surfaces are named by the name " + ...
    "attribute of <RCNLContactSurface>, or by their <hindfoot_body> " + ...
    "when the attribute is absent.");
end

function axisIndex = findAxisIndex(axes, term)
axisIndex = find(strcmpi(convertCharsToStrings(axes), ["x", "y", "z"]), 1);
assert(~isempty(axisIndex), term.type + ": <axes> must be some or all " + ...
    "of x, y and z.");
end
