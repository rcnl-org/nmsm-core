% This function is part of the NMSM Pipeline, see file for full license.
%
% This function takes a GCP settings file and creates plots for GRF and
% kinematic matching for each contact surface, and creates a grid plot of
% stiffness coefficients.
%
% (string) -> (None)

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
function plotGcpResultsFromSettingsFile(settingsFileName)
import org.opensim.modeling.Storage
settingsTree = xml2struct(settingsFileName);
resultsDirectory = getFieldByName(settingsTree, 'results_directory').Text;
modelFileName = getFieldByName(settingsTree, 'input_model_file').Text;
modelName = split(modelFileName, ["/", "\"]);
modelName = erase(modelName(end), ".osim");
osimxFileName = getFieldByName(settingsTree, "input_osimx_file");

if ~isstruct(osimxFileName) || strcmp(osimxFileName.Text, "")
    outputOsimxFileName = strcat(modelName, "_gcp.osimx");
else
    osimxFilePath = getFieldByName(settingsTree, 'input_osimx_file').Text;
    osimxFilePathSplit = split(osimxFilePath, ["\", "/"]);
    osimxFileName = osimxFilePathSplit{end};
    outputOsimxFileName = strrep(osimxFileName, ".osimx", "_gcp.osimx");
end
contactSurfaceSet = getFieldByName(settingsTree, 'GCPContactSurfaceSet');
for foot = 1 : numel(contactSurfaceSet.GCPContactSurface)
    plotGcpGroundReactionsFromFiles( ...
        fullfile(resultsDirectory, strcat(modelName, ...             
            strcat("_Foot_",num2str(foot), ...
            "_replacedExperimentalGroundReactions.sto"))), ...
        fullfile(resultsDirectory, strcat(modelName, ...             
            strcat("_Foot_",num2str(foot), ...
            "_optimizedGroundReactions.sto"))))
    plotGcpFootKinematicsFromFiles( ...
        fullfile(resultsDirectory, strcat(modelName, ...
            strcat("_Foot_",num2str(foot), ...
            "_experimentalFootKinematics.sto"))), ...
        fullfile(resultsDirectory, strcat(modelName, ...             
            strcat("_Foot_",num2str(foot), ...
            "_optimizedFootKinematics.sto"))))
end
% Spring grid
plotGcpStiffnessCoefficients( ...
    modelFileName, ...
    fullfile(resultsDirectory, outputOsimxFileName))
end


