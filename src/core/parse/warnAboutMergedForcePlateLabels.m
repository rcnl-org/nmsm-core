% This function is part of the NMSM Pipeline, see file for full license.
%
% (struct) -> ()
% Warns when a cost or constraint term names a force plate column belonging
% to a contact surface that combines several force plates.
%
% Such a term applies to the whole contact surface, so on a merged surface
% it also covers the times the other plates were carrying the foot. That is
% rarely what was meant and can leave the optimization hard to converge.

% ----------------------------------------------------------------------- %
% The NMSM Pipeline is a toolkit for model personalization and treatment  %
% optimization of neuromusculoskeletal models through OpenSim. See        %
% nmsm.rice.edu and the NOTICE file for more information. The             %
% NMSM Pipeline is developed at Rice University and supported by the US   %
% National Institutes of Health (R01 EB030520).                           %
%                                                                         %
% Copyright (c) 2021 Rice University and the Authors                      %
% Author(s): Robert Salati                                                %
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

function warnAboutMergedForcePlateLabels(inputs)
if ~isfield(inputs, 'contactSurfaces') || isempty(inputs.contactSurfaces)
    return
end
terms = {};
for field = ["costTerms", "path", "terminal"]
    if isfield(inputs, field)
        terms = [terms, inputs.(field)];
    end
end
columnFields = ["forceColumns", "momentColumns"];
alreadyWarned = strings(1, 0);
for i = 1 : length(terms)
    term = terms{i};
    if isfield(term, 'contact_surface') || ...
            (isfield(term, 'isEnabled') && ~term.isEnabled)
        continue
    end
    for field = 1 : length(columnFields)
        labelField = extractBefore(columnFields(field), "Columns");
        if ~isfield(term, labelField)
            continue
        end
        label = convertCharsToStrings(term.(labelField));
        for surface = 1 : length(inputs.contactSurfaces)
            contactSurface = inputs.contactSurfaces{surface};
            columns = convertCharsToStrings( ...
                contactSurface.(columnFields(field)));
            if numel(columns) <= 3 || ~any(strcmp(columns, label))
                continue
            end
            signature = string(term.type) + "|" + ...
                string(contactSurface.name);
            if any(strcmp(alreadyWarned, signature))
                continue
            end
            alreadyWarned(end + 1) = signature;
            warning("%s", string(term.type) + " names the force plate " + ...
                "column " + label + " with <" + labelField + "_list>, " + ...
                "but contact surface " + string(contactSurface.name) + ...
                " combines " + numel(columns) / 3 + " force plates into " + ...
                "a single wrench. The term therefore applies across the " + ...
                "whole trial, including when the other plates were " + ...
                "loaded, and the optimization may not converge. Select " + ...
                "the surface with <contact_surface_list> and <axes>, and " + ...
                "use <time_ranges> to restrict the term to one plate's " + ...
                "contact window.")
        end
    end
end
end
