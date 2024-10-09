% This function is part of the NMSM Pipeline, see file for full license.
%
% This function takes a parsed settings tree (xml2struct) and finds the
% inverse dynamics, inverse kinematics, ground reactions (if applicable),
% muscle activation (if applicable) and muscle analysis (if applicable)
% data directories.
%
% (struct, struct) -> (struct)
% Returns input structure with experimental data

% ----------------------------------------------------------------------- %
% The NMSM Pipeline is a toolkit for model personalization and treatment  %
% optimization of neuromusculoskeletal models through OpenSim. See        %
% nmsm.rice.edu and the NOTICE file for more information. The             %
% NMSM Pipeline is developed at Rice University and supported by the US   %
% National Institutes of Health (R01 EB030520).                           %
%                                                                         %
% Copyright (c) 2021 Rice University and the Authors                      %
% Author(s): Marleny Vega, Claire V. Hammond                              %
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

function inputs = parseTreatmentOptimizationDataDirectory(tree, inputs)
[inputs.trackedDirectory, inputs.initialGuessDirectory] = ...
    findDataDirectory(tree);
inputs.trialName = parseTrialName(tree);
inputs = parseExperimentalData(inputs, inputs.trackedDirectory);
inputs = parseSynergyExperimentalData(tree, inputs);
inputs = parseInitialGuessData(inputs, inputs.initialGuessDirectory);
inputs = parseInitialValues(inputs);
end

function [trackedDirectory, initialGuessDirectory] = ...
    findDataDirectory(tree)
trackedDirectory = parseDataDirectory(tree);
initialGuessDirectory = ...
    parseTextOrAlternate(tree, "initial_guess_directory", "");
if strcmp(initialGuessDirectory, "")
    throw(MException("ParseError:RequiredElement", ...
        strcat("Element <initial_guess_directory> required")))
end
end

function inputs = parseExperimentalData(inputs, dataDirectory)
[inputs.experimentalJointMoments, ...
    inputs.inverseDynamicsMomentLabels] = ...
    parseTrialDataTryDirectories( ...
    fullfile(inputs.initialGuessDirectory, "IDData"), ...
    fullfile(dataDirectory, "IDData"), inputs.trialName, inputs.model, true);
[inputs.experimentalJointAngles, inputs.coordinateNames, ...
    experimentalTime] = parseTrialDataTryDirectories( ...
    fullfile(inputs.initialGuessDirectory, "IKData"), ...
    fullfile(dataDirectory, "IKData"), inputs.trialName, inputs.model, true);
inputs.coordinateNamesStrings = inputs.coordinateNames;
inputs.coordinateNames = cellstr(inputs.coordinateNames);
inputs.experimentalTime = experimentalTime - experimentalTime(1);
inputs.initialTime = inputs.experimentalTime;
if isfield(inputs.osimx, 'groundContact') && ...
        isfield(inputs.osimx.groundContact, 'contactSurface')
    inputs.contactSurfaces = inputs.osimx.groundContact.contactSurface;
    for surfaceIndex = 1:length(inputs.contactSurfaces)
        [inputs.contactSurfaces{surfaceIndex} ...
            .experimentalGroundReactionForces, ...
            inputs.contactSurfaces{surfaceIndex} ...
            .experimentalGroundReactionMoments, ...
            inputs.contactSurfaces{surfaceIndex} ...
            .electricalCenter] = parseGroundReactionDataWithoutTime( ...
            inputs, dataDirectory, surfaceIndex);
    end
else
    inputs.contactSurfaces = {};
end
end

function inputs = parseInitialGuessData(inputs, dataDirectory)
try
    [inputs.initialJointMoments, ...
        inputs.initialInverseDynamicsMomentLabels] = ...
        parseTrialData(fullfile(dataDirectory, "IDData"), ...
        inputs.trialName, inputs.model);
catch
    inputs.initialJointMoments = inputs.experimentalJointMoments;
    inputs.initialInverseDynamicsMomentLabels = ...
        inputs.inverseDynamicsMomentLabels;
end
try
    [inputs.initialJointAngles, inputs.initialCoordinateNames, ...
        initialTime] = parseTrialDataTryDirectories( ...
        fullfile(inputs.initialGuessDirectory, "IKData"), ...
        fullfile(dataDirectory, "IKData"), inputs.trialName, inputs.model, ...
        false);
catch
    inputs.initialJointAngles = inputs.experimentalJointAngles;
    inputs.initialCoordinateNames = inputs.coordinateNamesStrings;
    initialTime = inputs.experimentalTime;
end
inputs.initialTime = initialTime - initialTime(1);
if isfield(inputs.osimx, 'groundContact') && ...
        isfield(inputs.osimx.groundContact, 'contactSurface')
    for surfaceIndex = 1:length(inputs.contactSurfaces)
        try
            [inputs.contactSurfaces{surfaceIndex} ...
                .initialGroundReactionForces, ...
                inputs.contactSurfaces{surfaceIndex} ...
                .initialGroundReactionMoments, ...
                inputs.contactSurfaces{surfaceIndex} ...
                .initialElectricalCenter] = parseGroundReactionDataWithoutTime( ...
                inputs, dataDirectory, surfaceIndex);
        catch
            inputs.contactSurfaces{surfaceIndex} ...
                .initialGroundReactionForces = ...
                inputs.contactSurfaces{surfaceIndex} ...
                .experimentalGroundReactionForces;
            inputs.contactSurfaces{surfaceIndex} ...
                .initialGroundReactionMoments = ...
                inputs.contactSurfaces{surfaceIndex} ...
                .experimentalGroundReactionMoments;
            inputs.contactSurfaces{surfaceIndex} ...
                .initialElectricalCenter = ...
                inputs.contactSurfaces{surfaceIndex} ...
                .electricalCenter;
        end
    end
end
end

function inputs = parseSynergyExperimentalData(tree, inputs)
if strcmp(inputs.controllerType, "synergy")
    surrogateModelDataDirectory = getTextFromField( ...
        getFieldByNameOrError(tree, 'surrogate_model_data_directory'));
    [inputs.experimentalMuscleActivations, inputs.muscleLabels] = ...
        parseTrialData(inputs.initialGuessDirectory, ...
        strcat(inputs.trialName, "_combinedActivations"), inputs.model);
    [inputs.synergyWeights, inputs.synergyWeightsLabels] = ...
        parseTrialData(inputs.initialGuessDirectory, ...
        "synergyWeights", inputs.model);
    directory = fullfile(surrogateModelDataDirectory, "MAData", inputs.trialName);
    inputs.surrogateModelMomentArms = parseSelectMomentArms(directory, ...
        inputs.surrogateModelCoordinateNames, inputs.muscleNames);
    [inputs.muscleTendonLengths, inputs.muscleTendonColumnNames] = ...
        parseFileFromDirectories(directory, "_Length.sto", inputs.model);
    inputs.muscleTendonLengths = findSpecificMusclesInData( ...
        inputs.muscleTendonLengths, inputs.muscleTendonColumnNames, ...
        inputs.muscleNames);
    inputs.muscleTendonLengths = reshape(permute(inputs.muscleTendonLengths, ...
        [1 3 2]), [], length(inputs.muscleNames));
    inputs.surrogateModelMomentArms = reshape(permute(inputs.surrogateModelMomentArms, [1 4 2 3]), [], ...
        length(inputs.surrogateModelCoordinateNames), length(inputs.muscleNames));
    [inputs.surrogateModelJointAngles, inputs.surrogateIkCoordinateNames, inputs.surrogateTime] = ...
        parseTrialData(fullfile(surrogateModelDataDirectory, "IKData"), ...
        inputs.trialName, inputs.model);
end
end

function inputs = parseInitialValues(inputs)
try
    [inputs.initialStates, inputs.initialStatesLabels, inputs.initialTime] = ...
        parseTrialData(inputs.initialGuessDirectory, ...
        strcat(inputs.trialName, "_states"), inputs.model);
catch; end
try
    [inputs.initialAccelerations, inputs.initialAccelerationsLabels] = ...
        parseTrialData(inputs.initialGuessDirectory, ...
        strcat(inputs.trialName, "_accelerations"), inputs.model);
catch; end
try
    [inputs.initialTorqueControls, inputs.initialTorqueControlsLabels] = ...
        parseTrialData(inputs.initialGuessDirectory, ...
        strcat(inputs.trialName, "_torqueControls"), inputs.model);
catch;end
if strcmp(inputs.controllerType, "synergy")
    [inputs.initialSynergyControls, inputs.initialSynergyControlsLabels] = ...
        parseTrialData(inputs.initialGuessDirectory, ...
        strcat(inputs.trialName, "_synergyCommands"), inputs.model);
end
end

function [data, labels, time] = parseTrialDataTryDirectories( ...
    initialGuessDirectory, dataDirectory, trialName, model, ...
    tryExperimentalFirst)
if ~strcmp(initialGuessDirectory, "")
    if tryExperimentalFirst
        try
            [data, labels, time] = parseTrialData(...
                dataDirectory, trialName, model);
        catch
            [data, labels, time] = parseTrialData( ...
                initialGuessDirectory, trialName, model);
        end
    else
        try
            [data, labels, time] = parseTrialData(...
                initialGuessDirectory, trialName, model);
        catch
            [data, labels, time] = parseTrialData( ...
                dataDirectory, trialName, model);
        end
    end
else
    [data, labels, time] = parseTrialData(dataDirectory, trialName, model);
end
end

function [forces, moments, ec] = parseGroundReactionDataWithoutTime( ...
    inputs, dataDirectory, surfaceIndex)
import org.opensim.modeling.Storage
[grfData, grfColumnNames, grfTime] = parseTrialDataTryDirectories( ...
    fullfile(inputs.initialGuessDirectory, "GRFData"), ...
    fullfile(dataDirectory, "GRFData"), inputs.trialName, inputs.model, true);
forces = NaN(length(grfTime), 3);
moments = NaN(length(grfTime), 3);
ec = NaN(length(grfTime), 3);
for i=1:size(grfColumnNames', 1)
    label = grfColumnNames(i);
    for j = 1:3
        if strcmpi(label, inputs.osimx.groundContact ...
                .contactSurface{surfaceIndex}.forceColumns(j))
            forces(:, j) = grfData(:, i);
        end
        if strcmpi(label, inputs.osimx.groundContact ...
                .contactSurface{surfaceIndex}.momentColumns(j))
            moments(:, j) = grfData(:, i);
        end
        if strcmpi(label, inputs.osimx.groundContact ...
                .contactSurface{surfaceIndex}.electricalCenterColumns(j))
            ec(:, j) = grfData(:, i);
        end
    end
end
if any([isnan(forces) isnan(moments) isnan(ec)])
    throw(MException('', ['Unable to parse GRF file, check that ' ...
        'all necessary column labels are present']))
end
end
