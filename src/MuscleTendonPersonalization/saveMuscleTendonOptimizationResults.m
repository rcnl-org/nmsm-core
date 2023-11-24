% This function is part of the NMSM Pipeline, see file for full license.
%
% This function saves optimization results to .sto files to be plotted by
% the user in either MATLAB or Opensim
%
% (struct, struct, struct, string) -> (None)
% Saves data from optimization to 6 .sto files

function saveMuscleTendonOptimizationResults(optimizedParams, ...
    mtpInputs, precalInputs, resultsDirectory)
if nargin < 3
    precalInputs = [];
end
[finalValues, results, resultsSynx, resultsSynxNoResiduals] = ...
    getValuesToReport(mtpInputs, precalInputs, optimizedParams);
if ~isempty(precalInputs)
    modeledValues = getMuscleTendonLengthInitializationData(precalInputs, ...
        mtpInputs);  % Modeled passive force data & params from experimental data.
end

printJointMomentMatchingError(resultsSynx.muscleJointMoments, ...
    mtpInputs.inverseDynamicsMoments);  % Keep this

%% Save excitations and activations
saveActivationAndExcitationData(mtpInputs, results, resultsSynx, resultsDirectory);

%% Save Noramlized Fiber lengths
saveAnalysisData(mtpInputs.muscleNames, mtpInputs.prefixes, results.normalizedFiberLength, ...
    strcat(resultsDirectory, "\normalizedFiberLengths"), "_normalizedFiberLengths.sto")

%% Save Joint moments
saveJointMomentData(mtpInputs, results, resultsSynx, resultsSynxNoResiduals, resultsDirectory);

%% Save hill type model params
saveMuscleModelParameters(finalValues, fullfile(resultsDirectory, ...
    "muscleModelParemeters"));

%% Save Passive moments
savePassiveMomentData(precalInputs, modeledValues, resultsDirectory);

%% Save passive forces
savePassiveForceData(mtpInputs, modeledValues, results, resultsSynx, ...
    resultsSynxNoResiduals, resultsDirectory);
end

function savePassiveMomentData(precalInputs, modeledValues, resultsDirectory)
% Passive moments need processing first.
modelPassiveMoments = permute(modeledValues.passiveModelMoments, [3 1 2]);
sizeTemp = size(modelPassiveMoments,1);
experimentalPassiveMoments = permute(precalInputs.passiveData.inverseDynamicsMoments, [3 1 2]);

columnsWithAllZeros = all(experimentalPassiveMoments == 0, 1);

experimentalPassiveMoments = experimentalPassiveMoments(repmat(~columnsWithAllZeros, ...
    size(experimentalPassiveMoments, 1), 1, 1));

modelPassiveMoments = modelPassiveMoments(repmat(~columnsWithAllZeros, ...
    size(modelPassiveMoments, 1), 1, 1));

experimentalPassiveMoments = ...
    reshape(experimentalPassiveMoments, sizeTemp, []);
experimentalPassiveMoments = ...
    reshape(experimentalPassiveMoments', 1, 12, 101); % Want a better way to do this
modelPassiveMoments = ...
    reshape(modelPassiveMoments, sizeTemp, []);
modelPassiveMoments = ...
    reshape(modelPassiveMoments', 1, 12, 101); % Want a better way to do this
saveAnalysisData(precalInputs.passivePrefixes, precalInputs.prefixes, ...
    experimentalPassiveMoments, fullfile(resultsDirectory, ...
    "passiveJointMomentsExperimental"), "_passiveJointMomentsExperimental.sto")
saveAnalysisData(precalInputs.passivePrefixes, precalInputs.prefixes, ...
    modelPassiveMoments, fullfile(resultsDirectory, ...
    "passiveJointMomentsModeled"), "_passiveJointMomentsModeled.sto")
end

function saveJointMomentData(mtpInputs, results, resultsSynx, ...
    resultsSynxNoResiduals, resultsDirectory)
saveAnalysisData(mtpInputs.coordinateNames, mtpInputs.prefixes, ...
    results.muscleJointMoments, strcat(resultsDirectory, ...
    "\modelJointMomentsNoSynx"), "_modelJointMomentsNoSynx.sto")
saveAnalysisData(mtpInputs.coordinateNames, mtpInputs.prefixes, ...
    resultsSynx.muscleJointMoments, strcat(resultsDirectory, ...
    "\modelJointMomentsSynx"), "_modelJointMomentsSynx.sto")
saveAnalysisData(mtpInputs.coordinateNames, mtpInputs.prefixes, ...
    resultsSynxNoResiduals.muscleJointMoments, strcat(resultsDirectory, ...
    "\modelJointMomentsSynxNoResiduals"), "_modelJointMomentsSynxNoResiduals.sto")
saveAnalysisData(mtpInputs.coordinateNames, mtpInputs.prefixes, ...
    mtpInputs.inverseDynamicsMoments, strcat(resultsDirectory, ...
    "\inverseDynamicsJointMoments"), "_inverseDynamicsJointMoments.sto")
end

function saveActivationAndExcitationData(mtpInputs, results, ...
    resultsSynx, resultsDirectory)
saveAnalysisData(mtpInputs.muscleNames, mtpInputs.prefixes, ...
    results.muscleExcitations, strcat(resultsDirectory, ...
    "\muscleExcitations"), "_muscleExcitations.sto")
saveAnalysisData(mtpInputs.muscleNames, mtpInputs.prefixes, ...
    resultsSynx.muscleExcitations, strcat(resultsDirectory, ...
    "\muscleExcitationsSynx"), "_muscleExcitationsSynx.sto")
saveAnalysisData(mtpInputs.muscleNames, mtpInputs.prefixes, ...
    results.muscleActivations, strcat(resultsDirectory, ...
    "\muscleActivations"), "_muscleActivations.sto")
saveAnalysisData(mtpInputs.muscleNames, mtpInputs.prefixes, ...
    resultsSynx.muscleActivations, strcat(resultsDirectory, ...
    "\muscleActivationsSynx"), "_muscleActivationsSynx.sto")
end

function saveMuscleModelParameters(finalValues, resultsDirectory)
if ~exist(resultsDirectory, "dir")
    mkdir(resultsDirectory);
end
columnLabels = ["Activation Time Constant", "Activation Nonlinearity", ...
    "Electromechanical Time Delay", "EMG Scaling Factor", ...
    "Optimal Fiber Length Scaling Factor", "Tendon Slack Length Scaling Factor"];

dataPoints = [finalValues.activationTimeConstants;
    finalValues.activationNonlinearityConstants;
    finalValues.electromechanicalDelays;
    finalValues.emgScaleFactors;
    finalValues.optimalFiberLengthScaleFactors;
    finalValues.tendonSlackLengthScaleFactors]';

writeToSto(columnLabels, 1:1:size(dataPoints,1), dataPoints, ...
    fullfile(resultsDirectory, "muscleModelParameters.sto"));
end

function savePassiveForceData(mtpInputs, modeledValues, results, resultsSynx, ...
    resultsSynxNoResiduals, resultsDirectory)
saveAnalysisData(mtpInputs.muscleNames, mtpInputs.prefixes, ...
    modeledValues.passiveForce, strcat(resultsDirectory, ...
    "\passiveForcesExperimental"), "_passiveForcesExperimental.sto");
saveAnalysisData(mtpInputs.muscleNames, mtpInputs.prefixes, ...
    results.passiveForce, strcat(resultsDirectory, ...
    "\passiveForcesModel"), "_passiveForcesModel.sto");
saveAnalysisData(mtpInputs.muscleNames, mtpInputs.prefixes, ...
    resultsSynx.passiveForce, strcat(resultsDirectory, ...
    "\passiveForcesModelSynx"), "_passiveForcesModelSynx.sto");
saveAnalysisData(mtpInputs.muscleNames, mtpInputs.prefixes, ...
    resultsSynxNoResiduals.passiveForce, strcat(resultsDirectory, ...
    "\passiveForcesModelSynxNoResiduals"), "_passiveForcesModelSynxNoResiduals.sto");
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

function modeledValues = getMuscleTendonLengthInitializationData(...
    precalInputs, mtpInputs)

tempValues.optimalFiberLengthScaleFactors = ...
    mtpInputs.optimalFiberLength ./ precalInputs.optimalFiberLength;

tempValues.tendonSlackLengthScaleFactors = ...
    mtpInputs.tendonSlackLength ./ precalInputs.tendonSlackLength;

precalInputs.maxIsometricForce = mtpInputs.maxIsometricForce;

precalInputs.optimizeIsometricMaxForce = 0;

modeledValues = calcMuscleTendonLengthInitializationModeledValues(tempValues, precalInputs);
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

function saveAnalysisData(columnLabels, taskNames, data, directory, fileName)
if ~exist(directory, "dir")
    mkdir(directory);
end
for i = 1 : size(data,1)
    writeToSto(columnLabels, 1:1:length(data(i,:,:)), ...
        permute(data(i,:,:), [3 2 1]), strcat(directory, "\", taskNames(i), fileName))
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