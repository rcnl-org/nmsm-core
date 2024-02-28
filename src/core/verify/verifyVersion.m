% This function is part of the NMSM Pipeline, see file for full license.
%
% This function checks the version of the settings file and the tool name
% to ensure the XML file is compatible with the current version of the
% pipeline. If the XML file is not compatible, the function will return an
% error.
%
% (struct) -> ()
% returns nothing or throws and error if incompatible version

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

function verifyVersion(settingsTree, toolName)
if ~isfield(settingsTree, "NMSMPipelineDocument")
    throw(MException('verifyVersion:invalidSettingsFile', ...
        strcat("Settings file is not a valid NMSM Pipeline settings file. ", ...
        "The XML file is not an <NMSMPipelineDocument>")))
end
settingsFileVersion = convertCharsToStrings( ...
    settingsTree.NMSMPipelineDocument.Attributes.Version);
sections = settingsFileVersion.split('.');
softwareSections = getPipelineVersion().split('.');
if isempty(sections)
    throw(MException('verifyVersion:invalidSettingsFile', ...
        'Cannot find version number in settings file.'))
end
if length(sections) == 1
    sections(2) = 0;
end
if sections(1) ~= softwareSections(1)
    throw(MException('verifyVersion:invalidSettingsFile', ...
        strcat("Settings file is not compatible with this version of the NMSM Pipeline.", ...
        " Software version: ", getPipelineVersion(), ...
        " Settings file version: ", settingsFileVersion, ...
        " For the latest version of the NMSM Pipeline, please visit https://nmsm.rice.edu.")))
end
if sections(2) ~= softwareSections(2)
    warning(strcat("Settings file may not be compatible with this version of the NMSM Pipeline.", ...
        " Software version: ", getPipelineVersion(), ...
        " Settings file version: ", settingsFileVersion, ...
        " For the latest version of the NMSM Pipeline, please visit https://nmsm.rice.edu."))
end
if ~isfield(settingsTree.NMSMPipelineDocument, toolName)
    throw(MException('verifyVersion:invalidSettingsFile', ...
        strcat("The " + toolName + ...
        " is being used with a settings file that does not contain a <" ...
        + toolName + "> element.")))
end
