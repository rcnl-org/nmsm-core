% This function is part of the NMSM Pipeline, see file for full license.
%
% This function formats experimental and modeled passive moment data and
% saves them to appropriate .sto files in a directory specified by
% resultsDirectory.
%
% (struct, struct, string) -> (None)
% Saves passive moment data to .sto file.

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

function saveMtpPassiveMomentData(precalInputs, modeledValues, resultsDirectory)
modelPassiveMoments = permute(modeledValues.passiveModelMoments, [3 1 2]);
sizeTemp = size(modelPassiveMoments,1);
experimentalPassiveMoments = permute(precalInputs.passiveData.inverseDynamicsMoments, [3 1 2]);
numberOfMoments = size(modelPassiveMoments, 2);
dataLength = size(modelPassiveMoments, 1);
columnsWithAllZeros = all(experimentalPassiveMoments == 0, 1);
experimentalPassiveMoments = experimentalPassiveMoments(repmat(~columnsWithAllZeros, ...
    size(experimentalPassiveMoments, 1), 1, 1));
modelPassiveMoments = modelPassiveMoments(repmat(~columnsWithAllZeros, ...
    size(modelPassiveMoments, 1), 1, 1));
experimentalPassiveMoments = ...
    reshape(experimentalPassiveMoments, sizeTemp, []);
experimentalPassiveMoments = ...
    reshape(experimentalPassiveMoments', 1, numberOfMoments, dataLength);
modelPassiveMoments = ...
    reshape(modelPassiveMoments, sizeTemp, []);
modelPassiveMoments = ...
    reshape(modelPassiveMoments', 1, numberOfMoments, dataLength);
writeMtpDataToSto(precalInputs.passivePrefixes, precalInputs.prefixes, ...
    experimentalPassiveMoments, fullfile(resultsDirectory, ...
    "passiveJointMomentsExperimental"), "_passiveJointMomentsExperimental.sto")
writeMtpDataToSto(precalInputs.passivePrefixes, precalInputs.prefixes, ...
    modelPassiveMoments, fullfile(resultsDirectory, ...
    "passiveJointMomentsModeled"), "_passiveJointMomentsModeled.sto")
end