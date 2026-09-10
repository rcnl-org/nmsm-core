% This function is part of the NMSM Pipeline, see file for full license.
%
% This function validates a .osimx file and, if valid, parses its muscles,
% contact surfaces, and synergies, populating the GUI app with the
% extracted personalized model data.
%
% (App, string, string) -> (bool, string)
% Parses an osimx file and populates the app with personalized model data

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
function [errorFlag, message] = parseOsimxFileGui(app, ...
    input_osimx_file, input_model_file)
message = [];
errorFlag = false;
if strcmp(input_osimx_file, "")
    return
end

if ~exist(input_osimx_file)
    message = "The given Osimx file does not exist";
    errorFlag = true;
    return
end

try 
    osimx = parseOsimxFile(input_osimx_file, Model(input_model_file));
catch
    errorFlag = true;
    message = parseOsimxFileForErrors(input_osimx_file, input_model_file);
    return
end

try parseOsimxFileMuscles(app, osimx);
catch
end

try parseOsimxFileContactSurfaces(app, osimx);
catch
end

try parseOsimxFileSynergies(app, osimx);
catch
end

end

function errorMessage = parseOsimxFileForErrors(input_osimx_file, input_model_file);
    errorMessage = "Osimx file could not parse.";
end

function parseOsimxFileSynergies(app, osimx)
    if ~isfield(osimx, "synergyGroups")
        return
    end
    app.setOsimxSynergyGroups(osimx.synergyGroups);
end