
% MuscleTendonPersonalizationPreprocessingTool("MTPPreprocessingLatest.xml")
MuscleTendonPersonalizationPreprocessingTool("preprocessingTest.xml")

% import org.opensim.modeling.*
% 
% % settingsTree = xml2struct("MTPPreprocessingLatest.xml");
% % [inputs, params] = parseMtpPreprocessingSettingsTree(settingsTree);
% 
% % storage = Storage(strcat(pwd, "/MuscleAnalysis/optModel_v6_MuscleAnalysis_MomentArm_hip_adduction_l.sto"));
% data = storageToDoubleMatrix(storage);
% time = findTimeColumn(storage);
% columnNames = getStorageColumnNames(storage);
% coordinates = ["hip_adduction_l", "hip_flexion_l", "hip_rotation_l", "knee_angle_l", "ankle_angle_l", "subtalar_angle_l"];
% 
% [newData, newNames] = removeUnusedColumns(data, columnNames, "CPRIT_Patient3_MuscleGroups.osim", coordinates);

% inputs.resultsDir = fullfile(pwd, "preprocessed");
% inputs.ikResultsFileName = fullfile(pwd, "ik.mot");
% inputs.idResultsFileName = fullfile(pwd, "id.mot");
% inputs.maResultsDir = fullfile(pwd, "MuscleAnalysis");
% inputs.emgFileName = fullfile(pwd, "processedEMGLeft.mot");
% inputs.coordinates = ["hip_adduction_l", "hip_flexion_l", "hip_rotation_l", "knee_angle_l", "ankle_angle_l", "subtalar_angle_l"];
% inputs.model = "CPRIT_Patient3_MuscleGroups.osim";
% inputs.timeGroups = [
%     0.593, 1.667;
%     1.667, 2.767;
%     2.767, 3.827;
%     3.827, 4.907;
%     4.907, 5.993;
%     ];
% inputs.prefix = "gait";
% 
% params = struct();
% 
% processMotionLabData(inputs, params)
