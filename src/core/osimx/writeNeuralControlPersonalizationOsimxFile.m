% This function is part of the NMSM Pipeline, see file for full license.
%
% This function prints out the optimized muscle tendon parameters from
% Neural Control Personalization in an osimx file
%
% (string, 2D matrix, string) -> (None)
% Prints Neural Control Personalization results in osimx file

% ----------------------------------------------------------------------- %
% The NMSM Pipeline is a toolkit for model personalization and treatment  %
% optimization of neuromusculoskeletal models through OpenSim. See        %
% nmsm.rice.edu and the NOTICE file for more information. The             %
% NMSM Pipeline is developed at Rice University and supported by the US   %
% National Institutes of Health (R01 EB030520).                           %
%                                                                         %
% Copyright (c) 2021 Rice University and the Authors                      %
% Author(s): Spencer Williams, Marleny Vega                               %
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

function writeNeuralControlPersonalizationOsimxFile(inputs, ...
    resultsDirectory, precalInputs)
modelFileName = inputs.model;
model = Model(modelFileName);

buildFromExisting = false;
if isfield(inputs, 'osimxFileName')
    if isfile(inputs.osimxFileName)
        osimx = parseOsimxFile(inputs.osimxFileName, model);
        [~, name, ~] = fileparts(inputs.osimxFileName);
        outfile = fullfile(resultsDirectory, strcat(name, "_ncp.xml"));
        buildFromExisting = true;
    end
end
if ~buildFromExisting
    % As only muscle parameters are included, the MtpOsimxTemplate can be
    % reused
    osimx = buildMtpOsimxTemplate(...
        replace(model.getName().toCharArray',".","_dot_"), ...
        modelFileName);
    [~, name, ~] = fileparts(modelFileName);
    outfile = fullfile(resultsDirectory, strcat(name, "_ncp.xml"));
end
osimx.modelName = name;
osimx.model = modelFileName;
if ~isfield(osimx, 'muscles')
    osimx.muscles = [];
end
for i = 1:length(inputs.muscleTendonColumnNames)
    if ~isfield(osimx.muscles, inputs.muscleTendonColumnNames(i))
        osimx.muscles.(inputs.muscleTendonColumnNames(i)) = struct();
    end
    if ~isfield(osimx.muscles.(inputs.muscleTendonColumnNames(i)), "optimalFiberLength")
        osimx.muscles.(inputs.muscleTendonColumnNames(i)) ...
            .optimalFiberLength = inputs.optimalFiberLength(i);
    end
    if ~isfield(osimx.muscles.(inputs.muscleTendonColumnNames(i)), "tendonSlackLength")
        osimx.muscles.(inputs.muscleTendonColumnNames(i)) ...
            .tendonSlackLength = inputs.tendonSlackLength(i);
    end
    if isstruct(precalInputs) && precalInputs.optimizeIsometricMaxForce && ...
            ~isfield(osimx.muscles.(inputs.muscleTendonColumnNames(i)), "maxIsometricForce")
        osimx.muscles.(inputs.muscleTendonColumnNames(i)) ...
            .maxIsometricForce = inputs.maxIsometricForce(i);
    end
end
osimx.synergyGroups = inputs.synergyGroups;

writeOsimxFile(buildOsimxFromOsimxStruct(osimx), outfile)
end

