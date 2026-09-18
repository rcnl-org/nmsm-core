% This function is part of the NMSM Pipeline, see file for full license.
%
% Reads the column labels and the time range out of a Ground Contact
% Personalization ground reaction force file and hands them to the app.
% The labels fill the force, moment, and electrical center dropdowns on
% the Contact Surfaces tab, and the time range is the default start and
% end time for a contact surface. An unreadable file clears both rather
% than throwing, matching parseModelFileGui, because the caller has
% already reported the bad file through the field's status icon.
%
% (App, string) -> (None)
% Parses GRF column labels for the GCP GUI.

% ----------------------------------------------------------------------- %
% The NMSM Pipeline is a toolkit for model personalization and treatment  %
% optimization of neuromusculoskeletal models through OpenSim. See        %
% nmsm.rice.edu and the NOTICE file for more information. The             %
% NMSM Pipeline is developed at Rice University and supported by the US   %
% National Institutes of Health (R01 EB030520).                           %
%                                                                         %
% Copyright (c) 2026 Rice University and the Authors                      %
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

function parseGcpGrfFileGui(app, input_grf_file)
import org.opensim.modeling.Storage
if strcmp(input_grf_file, "")
    app.setGrfColumnLabels(string([]));
    app.setGrfTimeRange([]);
    return
end
try
    storage = Storage(input_grf_file);
    % getStorageColumnNames drops the time column and returns a string
    % array, so the labels can go straight onto a dropdown's Items.
    app.setGrfColumnLabels(getStorageColumnNames(storage));
    time = findTimeColumn(storage);
    if isempty(time)
        app.setGrfTimeRange([]);
    else
        app.setGrfTimeRange([min(time) max(time)]);
    end
catch
    app.setGrfColumnLabels(string([]));
    app.setGrfTimeRange([]);
end
end
