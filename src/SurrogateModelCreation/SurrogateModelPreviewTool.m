% This function is part of the NMSM Pipeline, see file for full license.
%
% This function takes a properly formatted XML file and fits surrogate
% muscle geometry to validate the surrogate muscle model settings. 
%
% (string) -> (None)
% Create and plot surrogate model from Treatment Optimization settings file

% ----------------------------------------------------------------------- %
% The NMSM Pipeline is a toolkit for model personalization and treatment  %
% optimization of neuromusculoskeletal models through OpenSim. See        %
% nmsm.rice.edu and the NOTICE file for more information. The             %
% NMSM Pipeline is developed at Rice University and supported by the US   %
% National Institutes of Health (R01 EB030520).                           %
%                                                                         %
% Copyright (c) 2021 Rice University and the Authors                      %
% Author(s): Spencer Williams, Claire V. Hammond                          %
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

function SurrogateModelPreviewTool(settingsFileName, ...
    plotSurrogateResults, plotExperimentalResults)
settingsTree = xml2struct(settingsFileName);
toolFields = fieldnames(settingsTree.NMSMPipelineDocument);
switch toolFields{1} 
    case 'TrackingOptimizationTool'
        verifyVersion(settingsTree, "TrackingOptimizationTool");
        [inputs, params] = parseTrackingOptimizationSettingsTree(settingsTree);
    case 'VerificationOptimizationTool'
        verifyVersion(settingsTree, "VerificationOptimizationTool");
        [inputs, params] = parseVerificationOptimizationSettingsTree(settingsTree);
    case 'DesignOptimizationTool'
        verifyVersion(settingsTree, "DesignOptimizationTool");
        [inputs, params] = parseDesignOptimizationSettingsTree(settingsTree);
    otherwise
        MException('Incorrect Settings File', ...
            "Invalid settings file type. Valid types include " + ...
            "TrackingOptimizationTool, VerificationOptimizationTool," + ...
            " and DesignOptimizationTool.")
end
inputs.surrogateModelCoordinateNames = inputs.coordinateNames;
inputs.plotResults = true;
inputs.plotSurrogateResults = plotSurrogateResults;
inputs.plotExperimentalResults = plotExperimentalResults;
SurrogateModelCreation(inputs);
end
