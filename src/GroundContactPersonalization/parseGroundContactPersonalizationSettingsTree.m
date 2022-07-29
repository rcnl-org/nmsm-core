% This function is part of the NMSM Pipeline, see file for full license.
%
% 
%
% (struct) -> (struct, struct, string)
% returns the input values for Ground Contact Personalization

% ----------------------------------------------------------------------- %
% The NMSM Pipeline is a toolkit for model personalization and treatment  %
% optimization of neuromusculoskeletal models through OpenSim. See        %
% nmsm.rice.edu and the NOTICE file for more information. The             %
% NMSM Pipeline is developed at Rice University and supported by the US   %
% National Institutes of Health (R01 EB030520).                           %
%                                                                         %
% Copyright (c) 2022 Rice University and the Authors                      %
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

function [inputs, params, resultsDirectory] = ...
    parseGroundContactPersonalizationSettingsTree(settingsTree)
inputs = getInputs(settingsTree);
params = getParams(settingsTree);
resultsDirectory = getFieldByName(settingsTree, 'results_directory').Text;
if(isempty(resultsDirectory))
    resultsDirectory = pwd;
end
end

function inputs = getInputs(tree)
import org.opensim.modeling.*
inputDirectory = getFieldByName(tree, 'input_directory').Text;
modelFile = getFieldByNameOrError(tree, 'input_model_file').Text;
if(~isempty(inputDirectory))
    try
        inputs.model = fullfile(inputDirectory, modelFile);
    catch
        inputs.model = fullfile(pwd, inputDirectory, modelFile);
        inputDirectory = fullfile(pwd, inputDirectory);
    end
else
    inputs.model = fullfile(pwd, modelFile);
    inputDirectory = pwd;
end
prefixes = getPrefixes(tree, inputDirectory);
inputs.ikTime = parseTimeColumn(findFileListFromPrefixList(...
    fullfile(inputDirectory, "IKData"), prefixes));
inputs.experimentalJointKinematics = parseGcpStandard(inputs.model, ...
    findFileListFromPrefixList(fullfile(inputDirectory, "IKData"), ...
    prefixes));
inputs.grfTime = parseTimeColumn(findFileListFromPrefixList(...
    fullfile(inputDirectory, "GRFData"), prefixes));
[inputs.experimentalGrf1, inputs.experimentalGrf2] = getGrf( ...
    findFileListFromPrefixList(fullfile(inputDirectory, "GRFData"), ...
    prefixes));
inputs.toeCoordinateName = getFieldByNameOrError(tree, ...
    'toe_coordinate').Text;
inputs.toeJointName = char(Model(inputs.model).getCoordinateSet().get( ...
    inputs.toeCoordinateName).getJoint().getName());
inputs.errorCenters.markerDistanceError = getFieldByNameOrError(tree, ...
    'marker_distance_error');
inputs.errorCenters.staticFrictionCoefficient = getFieldByNameOrError(...
    tree, 'static_friction_coefficient');
inputs.errorCenters.dynamicFrictionCoefficient = getFieldByNameOrError(...
    tree, 'dynamic_friction_coefficient');
inputs.errorCenters.viscousFrictionCoefficient = getFieldByNameOrError(...
    tree, 'viscous_friction_coefficient');
end

% (struct) -> (Array of string)
function prefixes = getPrefixes(tree, inputDirectory)
prefixField = getFieldByName(tree, 'trial_prefixes');
if(length(prefixField.Text) > 0)
    prefixes = strsplit(prefixField.Text, ' ');
else
    files = dir(fullfile(inputDirectory, "IKData"));
    prefixes = string([]);
    for i=1:length(files)
        if(~files(i).isdir)
            prefixes(end+1) = files(i).name(1:end-4);
        end
    end
end
end

% (Array of string) -> (Array of double, Array of double)
function [grf1, grf2] = getGrf(files)
import org.opensim.modeling.Storage
for file=1:length(files)
    currentStorage = Storage(files(file));
    colLabels = currentStorage.getColumnLabels();
    fullGrfFile = storageToDoubleMatrix(currentStorage);
    grf1 = NaN(length(files), 3, currentStorage.getSize());
    grf2 = NaN(length(files), 3, currentStorage.getSize());
    for i=1:colLabels.size()-1
        label = char(colLabels.get(i));
        if contains(label, 'F')
            if contains(label, '1') && contains(label, 'x')
                grf1(file, 1, :) = fullGrfFile(i, :);
            end
            if contains(label, '1') && contains(label, 'y')
                grf1(file, 2, :) = fullGrfFile(i, :);
            end
            if contains(label, '1') && contains(label, 'z')
                grf1(file, 3, :) = fullGrfFile(i, :);
            end
            if contains(label, '2') && contains(label, 'x')
                grf2(file, 1, :) = fullGrfFile(i, :);
            end
            if contains(label, '2') && contains(label, 'y')
                grf2(file, 2, :) = fullGrfFile(i, :);
            end
            if contains(label, '2') && contains(label, 'z')
                grf2(file, 3, :) = fullGrfFile(i, :);
            end
        end
    end
    if any(isnan(grf1)) | any(isnan(grf1))
        throw(MException('', ['Unable to parse GRF file, check that ' ...
            'all necessary column labels are present']))
    end
end
end

function params = getParams(tree)
params = struct();
maxIterations = getFieldByName(tree, 'max_iterations');
if(isstruct(maxIterations))
    params.maxIterations = str2double(maxIterations.Text);
end
maxFunctionEvaluations = getFieldByName(tree, 'max_function_evaluations');
if(isstruct(maxFunctionEvaluations))
    params.maxFunctionEvaluations = str2double(maxFunctionEvaluations.Text);
end
end