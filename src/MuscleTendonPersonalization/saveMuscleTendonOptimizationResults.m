% This function is part of the NMSM Pipeline, see file for full license.
%
% This function saves optimization results to .sto files to be plotted by
% the user in either MATLAB or Opensim
%
% (struct, struct, struct, string) -> (None)
% Saves data from optimization to 6 .sto files

function saveMuscleTendonOptimizationResults(optimizedParams, ...
        mtpInputs, precalInputs, resultsDirectory)
    if nargin < 3; precalInputs = []; end
        [finalValues, results, resultsSynx, resultsSynxNoResiduals] = ...
            getValuesToReport(mtpInputs, precalInputs, optimizedParams)
    if ~isempty(precalInputs)
        saveMuscleTendonLengthInitializationResults(precalInputs, mtpInputs, ...
            resultsDirectory)  % Change to just save the data
    end

    printJointMomentMatchingError(resultsSynx.muscleJointMoments, ...
        mtpInputs.inverseDynamicsMoments);  % Keep this
    
    saveExcitationAndActivationData(results, resultsSynx, mtpInputs, ...
        mtpInputs.synergyExtrapolation, resultsDirectory);  % Change to just save the data

    % makeModelParameterPlots(finalValues, mtpInputs, ...
    %     mtpInputs.synergyExtrapolation)  % Change to just save the data

    % makeTaskSpecificMomentMatchingPlots(...
    %     permute(resultsSynxNoResiduals.muscleJointMoments, [3 1 2]), ...
    %     permute(resultsSynx.muscleJointMoments, [3 1 2]), ...
    %     permute(mtpInputs.inverseDynamicsMoments, [3 1 2]), ...
    %     mtpInputs.coordinateNames, mtpInputs.synergyExtrapolation)  % Change to just save the data

    % makeTaskSpecificNormalizedFiberLengthsPlots( ...
    %     permute(resultsSynx.normalizedFiberLength, [3 1 2]), ...
    %     mtpInputs, mtpInputs.synergyExtrapolation)  % Change to just save the data
end

function [finalValues, results, resultsSynx, resultsSynxNoResiduals] = ...
        getValuesToReport(mtpInputs, precalInputs, optimizedParams)  % Need to downscale excitation arrays

    finalValues = makeMtpValuesAsStruct([], optimizedParams, zeros(1, 7));
    save('finalvalues.mat', 'finalValues')
    resultsSynx = calcMtpSynXModeledValues(finalValues, mtpInputs, struct());
    finalValues.synergyWeights(mtpInputs.numberOfExtrapolationWeights + 1 : end) = 0;
    resultsSynxNoResiduals = calcMtpSynXModeledValues(finalValues, mtpInputs, struct());
    results = calcMtpModeledValues(finalValues, mtpInputs, struct());
    results.time = mtpInputs.emgTime(:, mtpInputs.numPaddingFrames + 1 : ...
        end - mtpInputs.numPaddingFrames);
    results.muscleExcitations = results.muscleExcitations(:, :, ...
        mtpInputs.numPaddingFrames + 1 : end - mtpInputs.numPaddingFrames);
    resultsSynx.muscleExcitations = resultsSynx.muscleExcitations(:, :, ...
        mtpInputs.numPaddingFrames + 1 : end - mtpInputs.numPaddingFrames);
end

function saveMuscleTendonLengthInitializationResults(...
    precalInputs, mtpInputs, resultsDirectory)

    tempValues.optimalFiberLengthScaleFactors = ...
        mtpInputs.optimalFiberLength ./ precalInputs.optimalFiberLength;
    tempValues.tendonSlackLengthScaleFactors = ...
        mtpInputs.tendonSlackLength ./ precalInputs.tendonSlackLength;
    precalInputs.maxIsometricForce = mtpInputs.maxIsometricForce;
    precalInputs.optimizeIsometricMaxForce = 0;
    modeledValues = calcMuscleTendonLengthInitializationModeledValues(tempValues, precalInputs);
    savePassiveForceData(permute(modeledValues.passiveForce, [3 1 2]), ...
        precalInputs.muscleNames, resultsDirectory);
%     if precalInputs.passiveMomentDataExists
%         plotPassiveMomentData(permute(modeledValues.passiveModelMoments, [3 1 2]), ...
%             permute(precalInputs.passiveData.inverseDynamicsMoments, [3 1 2]), ...
%             precalInputs.passivePrefixes)
%     end
end

function savePassiveForceData(modeledValue, muscleNames, resultsDirectory)

    meanModeledValue = squeeze(mean(modeledValue, 2));
    stdModeledValue = squeeze(std(modeledValue, [], 2));
    
    data = {meanModeledValue, stdModeledValue};
    dataNames = ["meanModeledValue", "stdModeledValue"];

    [stoDataArray, stoColumnLabels] = groupDataByMuscle(data, dataNames, muscleNames);

    writeToSto(stoColumnLabels, 1:1:length(stoDataArray), stoDataArray, ...
        strcat(resultsDirectory, "/passiveForceData/", "_passiveForceData.sto"))  % Maybe needs counter for gait cycles?
end 

function printJointMomentMatchingError(muscleJointMoments, inverseDynamicsMoments)  % Good

    for i = 1 : size(muscleJointMoments, 2)
        jointMomentsRmse(i) = sqrt(sum((muscleJointMoments(:, i, :) - ...
            inverseDynamicsMoments(:, i, :)) .^ 2, 'all') / ...
            (numel(inverseDynamicsMoments(:, 1, :)) - 1));
        jointMomentsMae(i) = sum(abs(muscleJointMoments(:, i, :) - ...
            inverseDynamicsMoments(:, i, :)) / ...
            numel(inverseDynamicsMoments(:, 1, :)), 'all');
    end
    fprintf(['The root mean sqrt (RMS) errors between model-predicted ' ...
        'and inverse dynamic moments are: \n' ]);
    fprintf(['\n ' num2str(jointMomentsRmse) ' \n']);
    fprintf(['The mean absolute errors (MAEs) between model-predicted ' ...
        'and inverse dynamic moments are: \n' ]);
    fprintf(['\n ' num2str(jointMomentsMae) ' \n']);
end

function saveExcitationAndActivationData(results, resultsSynx, ...
        experimentalData, synergyParameters, resultsDirectory)
    muscleLabels = getSynxMuscleNames(experimentalData.muscleNames, ...
        synergyParameters.missingEmgChannelGroups);
    for i = 1 : numel(synergyParameters.taskNames)
        
        [stoDataArray, stoColumnLabels] = formatMuscleExcitationsAndActivations(...
            results.muscleExcitations(synergyParameters.trialIndex{i}, :, :), ...
            resultsSynx.muscleExcitations(synergyParameters.trialIndex{i}, :, :), ...
            results.muscleActivations(synergyParameters.trialIndex{i}, :, :), ...
            resultsSynx.muscleActivations(synergyParameters.trialIndex{i}, :, :), ...
            muscleLabels);
        writeToSto(stoColumnLabels, 1:1:length(stoDataArray), stoDataArray, ...
            strcat(resultsDirectory, "/muscleExcitationsAndActivations/", ...
            synergyParameters.taskNames{i}, "_muscleExcitationsActivations.sto"))
    end
end

function [stoDataArray, stoColumnLabels] = formatMuscleExcitationsAndActivations( ...
        muscleExcitations, muscleExcitationsSynx, muscleActivations, ...
        muscleActivationsSynx, muscleLabels)
    
    meanMuscleExcitation = permute(mean(muscleExcitations, 1), [3 2 1]);
    stdMuscleExcitation = permute(std(muscleExcitations, [], 1), [3 2 1]);
    meanMuscleExcitationSynx = permute(mean(muscleExcitationsSynx, 1), [3 2 1]);
    stdMuscleExcitationSynx = permute(std(muscleExcitationsSynx, [], 1), [3 2 1]);
    meanMuscleActivation = permute(mean(muscleActivations, 1), [3 2 1]);
    stdMuscleActivation = permute(std(muscleActivations, [], 1), [3 2 1]);
    meanMuscleActivationSynx = permute(mean(muscleActivationsSynx, 1), [3 2 1]);
    stdMuscleActivationSynx = permute(std(muscleActivationsSynx, [], 1), [3 2 1]);
    excitationsAndActivations = {
        meanMuscleExcitation, stdMuscleExcitation, ...
        meanMuscleExcitationSynx, stdMuscleExcitationSynx, ...
        meanMuscleActivation, stdMuscleActivation, ...
        meanMuscleActivationSynx, stdMuscleActivationSynx};
    dataNames = ["meanMuscleExcitation", "stdMuscleExcitation", ...
        "meanMuscleExcitationSynx", "stdMuscleExcitationSynx", ...
        "meanMuscleActivation", "stdMuscleActivation", ...
        "meanMuscleActivationSynx", "stdMuscleActivationSynx"];
    [stoDataArray, stoColumnLabels] = groupDataByMuscle(excitationsAndActivations, ...
        dataNames, muscleLabels);
%     for i = 0 : numel(muscleLabels) - 1
%         stoDataArray(:, i*8+1) = meanMuscleExcitation(1:101, i + 1);
%         stoDataArray(:, i*8+2) = stdMuscleExcitation(1:101, i+1);
%         stoDataArray(:, i*8+3) = meanMuscleExcitationSynx(1:101, i+1);
%         stoDataArray(:, i*8+4) = stdMuscleExcitationSynx(1:101, i+1);
%         stoDataArray(:, i*8+5) = meanMuscleActivation(1:101, i+1);
%         stoDataArray(:, i*8+6) = stdMuscleActivation(1:101, i+1);
%         stoDataArray(:, i*8+7) = meanMuscleActivationSynx(1:101, i+1);
%         stoDataArray(:, i*8+8) = stdMuscleActivationSynx(1:101, i+1);
%     end
%     
%     stoColumnLabels = strings(8*numel(muscleLabels),1);
%     for i=0:numel(muscleLabels)-1
%         stoColumnLabels(8*i+1) = strcat(muscleLabels{i+1}, "_", "meanMuscleExcitation");
%         stoColumnLabels(8*i+2) = strcat(muscleLabels{i+1}, "_", "stdMuscleExcitation");
%         stoColumnLabels(8*i+3) = strcat(muscleLabels{i+1}, "_", "meanMuscleExcitationSynx");
%         stoColumnLabels(8*i+4) = strcat(muscleLabels{i+1}, "_", "stdMuscleExcitationSynx");
%         stoColumnLabels(8*i+5) = strcat(muscleLabels{i+1}, "_", "meanMuscleActivation");
%         stoColumnLabels(8*i+6) = strcat(muscleLabels{i+1}, "_", "stdMuscleActivation");
%         stoColumnLabels(8*i+7) = strcat(muscleLabels{i+1}, "_", "meanMuscleActivationSynx");
%         stoColumnLabels(8*i+8) = strcat(muscleLabels{i+1}, "_", "stdMuscleActivationSynx");
end

function [dataArray, columnNames] = groupDataByMuscle(...
    data, dataNames, muscleNames)
    
    lengthMuscleNames = numel(muscleNames);
    lengthDataNames = numel(dataNames);
    dataArray = zeros(length(data{1}), lengthMuscleNames*lengthDataNames);
    columnNames = strings(lengthDataNames*lengthMuscleNames, 1);
    for i = 0 : lengthMuscleNames - 1
        for j = 1 : lengthDataNames
            dataArray(:, lengthDataNames * i + j) = data{j}(:, i + 1);
            columnNames(lengthDataNames * i + j) = strcat(muscleNames(i + 1), "_", dataNames(j));
        end
    end
end

function muscleLabels = getSynxMuscleNames(muscleNames, ...
    missingEmgChannelGroups)

    for i = 1 : numel(muscleNames)
        if ismember(i, [missingEmgChannelGroups{:}])
            muscleLabels{i} = [muscleNames{i} '(*)'];
        else
            muscleLabels{i} = muscleNames{i};
        end
    end
end