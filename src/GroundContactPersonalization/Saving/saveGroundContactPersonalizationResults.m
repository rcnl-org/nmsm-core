% This function is part of the NMSM Pipeline, see file for full license.
%
% Saves a ground contact .osimx model and experimental and modeled
% kinematics and ground reactions for each foot. 
%
% (struct, struct, string) -> (None)
% Save final Ground Contact Personalization results. 

% ----------------------------------------------------------------------- %
% The NMSM Pipeline is a toolkit for model personalization and treatment  %
% optimization of neuromusculoskeletal models through OpenSim. See        %
% nmsm.rice.edu and the NOTICE file for more information. The             %
% NMSM Pipeline is developed at Rice University and supported by the US   %
% National Institutes of Health (R01 EB030520).                           %
%                                                                         %
% Copyright (c) 2021 Rice University and the Authors                      %
% Author(s): Claire V. Hammond, Spencer Williams                          %
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

function saveGroundContactPersonalizationResults(inputs, params, ...
    resultsDirectory, osimxFileName)
[~, name, ~] = fileparts(inputs.bodyModel);
if ~exist(resultsDirectory, "dir")
    mkdir(resultsDirectory);
end
writeExperimentalFootKinematicsToSto(inputs, resultsDirectory, name);
writeOptimizedFootKinematicsToSto(inputs, resultsDirectory, name);
writeReplacedExperimentalGroundReactionsToSto(inputs, ... 
    resultsDirectory, name);
writeOptimizedGroundReactionsToSto(inputs, params, resultsDirectory, name);
writeGroundContactPersonalizationOsimxFile(inputs, resultsDirectory, ...
    osimxFileName);
writeCombinedOptimizedGroundReactionsToSto(inputs, params, ...
    resultsDirectory);
if any(cellfun(@(task) any(task.designVariables(7:10)), params.tasks))
    writeExperimentalGroundReactionsNewElectricalCenterToSto(inputs, ...
        resultsDirectory);
end
writeFullBodyKinematicsFromGcp(inputs, params, resultsDirectory);
% Needs two attempts to successfully delete a used MEX function
warning('off')
for pass = 1 : 2
    for i = 1 : length(inputs.surfaces)
        mexCopy = "pointKinematics" + i + ".mexw64";
        if isfile(mexCopy)
            clear(mexCopy)
            delete(mexCopy)
        end
    end
end
warning('on')
end

