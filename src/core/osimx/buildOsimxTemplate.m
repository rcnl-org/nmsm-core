% This function is part of the NMSM Pipeline, see file for full license.
%
% This function produces the most general outermost struct portions of an
% osimx file. An osimx file can be written to file with writeOsimxFile()
%
% (string, string) -> (struct)
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

function osimx = buildOsimxTemplate(modelName, osimModelFileName)
osimx.NMSMPipelineDocument.Attributes.Version = convertStringsToChars( ...
    strrep(getPipelineVersion, ".", "_dot_"));
osimx.NMSMPipelineDocument.OsimxModel.Attributes.name = convertStringsToChars(modelName);
osimx.NMSMPipelineDocument.OsimxModel.associated_osim_model.Comment = ...
    'File name of associated .osim file';
osimx.NMSMPipelineDocument.OsimxModel.associated_osim_model.Text = ...
    convertStringsToChars(osimModelFileName);
end

