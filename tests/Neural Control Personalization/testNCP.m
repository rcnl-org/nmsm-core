function testNCP

% Reference:
% Shourijeh, Mohammad S., and Benjamin J. Fregly.
% "Muscle Synergies Modify Optimization Estimates of Joint Stiffness During Walking."
% Journal of Biomechanical Engineering 142.1 (2020).

clear; clc; close all;

% Data to load
EMGD_data = load('results_right_NGA_1pt01234_v30_withoffset_newPrecal_5.mat');
act_leftleg = load('activation_Fmax_L_4cases.mat');
etmData_rightleg = load('Patient3_etmData_right_outliersRemoved_Periodic.mat');
etmData_leftleg = load('Patient3_etmData_left_outliersRemoved_Periodic_1trial.mat');
etmData_lefttrunk = load('Patient3_etmData_refitted_left_trunk_1trial.mat');
etmData_righttrunk = load('Patient3_etmData_refitted_right_trunk_1trial.mat');
TrunkMuscParam = load('TrunkMuscleParams.mat').TrunkMuscParam;

% % Muscle Parameters
inputs.FMo = [EMGD_data.Fmax, EMGD_data.Fmax, TrunkMuscParam.FMo, TrunkMuscParam.FMo];
inputs.optimalFiberLength = [EMGD_data.lmoOpt, EMGD_data.lmoOpt, TrunkMuscParam.lMo, TrunkMuscParam.lMo];
inputs.tendonSlackLength = [EMGD_data.ltsOpt, EMGD_data.ltsOpt, TrunkMuscParam.lTs, TrunkMuscParam.lTs];
inputs.pennationAngle = [EMGD_data.alpha, EMGD_data.alpha, TrunkMuscParam.alpha, TrunkMuscParam.alpha];
inputs.vMmax = 10 * inputs.optimalFiberLength;

% Define global parameters
inputs.numMuscles = 148;
inputs.numMuscles_legs = 90;
inputs.numMuscles_trunk = 58;
inputs.numJoints = 15;
inputs.numNodes = 21;
inputs.numSynergies = 12;
inputs.numPoints = 101;

inputs.trial_no = 22; % 21 is the first trial of 1.4 m/s
inputs.long2short_idx = 21:121;

inputs.momentTrackingWeight = 1;
inputs.activationTrackingWeight = 1;
inputs.activationMinimizationWeight = 1;
inputs.momentTrackingAllowableError = 5; % 5 Nm is the allowable error for moment tracking error
inputs.activationTrackingAllowableError = 0.01; % 0.01 is the allowable error for activation tracking error
inputs.activationMinimizationAllowableError = 0.05; % 0.05 is the allowable error for activation minimization

savefilename = "Syn" + num2str(inputs.numSynergies) + "_" + num2str(inputs.momentTrackingWeight) + "_" + num2str(inputs.activationTrackingWeight) + "_" + num2str(inputs.activationMinimizationWeight) + "_" + num2str(inputs.momentTrackingAllowableError) + "_" + num2str(inputs.activationTrackingAllowableError) + "_" + num2str(inputs.activationMinimizationAllowableError);

try
    initial_soln = load(savefilename);
catch err
    initial_soln.x = rand(1, 2 * (inputs.numSynergies / 2 * (inputs.numMuscles / 2 + inputs.numNodes)));
end

[MTL_all, MA_all, VMT_all, ID_all, muscleNames, coordinateNames, inputs] = data_parsing_WithOffset_lumbar6dof(etmData_rightleg, etmData_leftleg, etmData_lefttrunk, etmData_righttrunk, inputs.trial_no, EMGD_data, act_leftleg, inputs);

%%

muscleTendonLength = MTL_all(inputs.long2short_idx, :);
muscleTendonVelocity = VMT_all(inputs.long2short_idx, :);
inverseDynamicsMoments = ID_all(inputs.long2short_idx, :);
rVals = MACompiler(MA_all, inputs); clear 'MA_all';

if exist('x0Synergies')
    x0 = x0Synergies;
else

    try
        load(initial_soln);
    catch err
        x0 = initial_soln;
        try x; catch err; x0 = initial_soln.x; end
    end

end

% Ensure that no negative initial values are present
x0(x0 < 0) = 0;

% Ensure that synergy weights and commands are normalized
x0 = normalizeSynergyVariables(x0, inputs);

fprintf('Running Neural Control Personalization optimization . . .\n')

inputs.muscleTendonLength = muscleTendonLength;
inputs.muscleTendonVelocity = muscleTendonVelocity;
inputs.rVals = rVals;
inputs.inverseDynamicsMoments = inverseDynamicsMoments;
muscleNames = fixStrings(muscleNames); inputs.muscleNames = muscleNames;
coordinateNames = fixStrings(coordinateNames); inputs.coordinateNames = coordinateNames;

tic

fieldnames(inputs)

if 1
    x = computeNeuralControlOptimization(x0, inputs, struct());
else
    x = x0;
end

toc

inputs.savefilename = savefilename;
inputs.NCPtimePercent = linspace(0, 100, inputs.numPoints)';
reportNeuralControlPersonalizationResults(x, inputs, struct());

% keyboard
end

%--------------------------------------------------------------------------
function MA = MACompiler(MomentArms, inputs)

MA = zeros(inputs.numPoints, inputs.numMuscles, inputs.numJoints);

for i = 1:inputs.numJoints
    MA(:, :, i) = MomentArms{i}(inputs.long2short_idx, :);
end

end

%--------------------------------------------------------------------------
function a = fixStrings(a)

for i = 1:length(a)
    a{i} = strrep(a{i}, '_', ' ');
end

end

%% MTL
%%% Left Leg
function [MTL_all, MA_all, VMT_all, ID_all, muscleNames, coordinateNames, inputs] = ...
    data_parsing_WithOffset_lumbar6dof(etmData_rightleg, etmData_leftleg, ...
    etmData_lefttrunk, etmData_righttrunk, trial_no, EMGD_data, act_leftleg, inputs)
str = 'etmData_leftleg.Data';
MTL_leftleg = eval([str, '.MTL']);

%%% Right Leg
str = 'etmData_rightleg.Data(trial_no)';
MTL_rightleg = eval([str, '.MTL']);

%%% Left Trunk
str = 'etmData_lefttrunk.Data';
MTL_lefttrunk = eval([str, '.MTL']);

%%% Right Trunk
str = 'etmData_righttrunk.Data';
MTL_righttrunk = eval([str, '.MTL']);

%%% Concatenated MTL
MTL_all = [MTL_rightleg MTL_leftleg MTL_righttrunk MTL_lefttrunk];
clear 'MTL_rightleg' 'MTL_leftleg' 'MTL_righttrunk' 'MTL_lefttrunk'
%% Moment Arm
MatStructure = {'hip_flexion_MomentArm', 'hip_adduction_MomentArm', 'hip_rotation_MomentArm', ...
    'knee_angle_MomentArm', 'ankle_angle_MomentArm', 'subtalar_angle_MomentArm', ...
    'lumbar_extension_MomentArm', 'lumbar_bending_MomentArm', 'lumbar_rotation_MomentArm'};
%%% Left Leg
for ii = 1
    k = 1;
    StructureNames = fieldnames(etmData_leftleg.Data);

    for i = 1:size(MatStructure, 2)

        for j = 1:size(StructureNames)

            if size(StructureNames{j}, 2) == size(MatStructure{i}, 2)

                if StructureNames{j} == MatStructure{i}

                    if ~isempty(strfind(MatStructure{i}, 'MomentArm'))
                        MA_leftleg{1, k} = etmData_leftleg.Data(ii).(StructureNames{j});
                        MA_leftleg{1, k}(isnan(MA_leftleg{1, k})) = 0;
                        k = k + 1;
                    end

                end

            end

        end

    end

end


MA_leftleg{14} = MA_leftleg{7};

MA_leftleg{7} = MA_leftleg{1};
MA_leftleg{8} = MA_leftleg{2};
MA_leftleg{9} = MA_leftleg{3};
MA_leftleg{10} = MA_leftleg{4};
MA_leftleg{11} = MA_leftleg{5};
MA_leftleg{12} = MA_leftleg{6};

MA_leftleg{1} = zeros(141, 45);
MA_leftleg{2} = zeros(141, 45);
MA_leftleg{3} = zeros(141, 45);
MA_leftleg{4} = zeros(141, 45);
MA_leftleg{5} = zeros(141, 45);
MA_leftleg{6} = zeros(141, 45);

MA_leftleg{13} = zeros(141, 45);
MA_leftleg{15} = zeros(141, 45);

%%% Right Leg
for ii = trial_no
    k = 1;
    StructureNames = fieldnames(etmData_rightleg.Data);

    for i = 1:size(MatStructure, 2)

        for j = 1:size(StructureNames)

            if size(StructureNames{j}, 2) == size(MatStructure{i}, 2)

                if StructureNames{j} == MatStructure{i}

                    if ~isempty(strfind(MatStructure{i}, 'MomentArm'))
                        MA_rightleg{1, k} = etmData_rightleg.Data(ii).(StructureNames{j});
                        MA_rightleg{1, k}(isnan(MA_rightleg{1, k})) = 0;
                        k = k + 1;
                    end

                end

            end

        end

    end

end

MA_rightleg{14} = MA_rightleg{7};
MA_rightleg{7} = zeros(141, 45);
MA_rightleg{8} = zeros(141, 45);
MA_rightleg{9} = zeros(141, 45);
MA_rightleg{10} = zeros(141, 45);
MA_rightleg{11} = zeros(141, 45);
MA_rightleg{12} = zeros(141, 45);
MA_rightleg{13} = zeros(141, 45);
MA_rightleg{15} = zeros(141, 45);

% trial_no = 22
% A = lumbarSurrogateModel(etmData_lefttrunk.Data.JointAngles(:,1), etmData_lefttrunk.Data.JointAngles(:,3), etmData_lefttrunk.Data.JointAngles(:,2), 141);
A = lumbarSurrogateModel(etmData_lefttrunk.Data.JointAngles(:, 1) * (pi / 180), etmData_lefttrunk.Data.JointAngles(:, 3) * (pi / 180), etmData_lefttrunk.Data.JointAngles(:, 2) * (pi / 180), 141); load('lumbarExtensionRotationCoefficients.mat')

for ii = 1:12
    momentArmslumbar(:, ii) = A * x{ii};
end

MA_rightleg{1, 13}(:, 31:33) = momentArmslumbar(:, 1:3);
MA_leftleg{1, 13}(:, 31:33) = momentArmslumbar(:, 4:6);
MA_rightleg{1, 15}(:, 31:33) = momentArmslumbar(:, 7:9);
MA_leftleg{1, 15}(:, 31:33) = momentArmslumbar(:, 10:12);

%%% Left Trunk
for ii = 1
    k = 1;
    StructureNames = fieldnames(etmData_lefttrunk.Data);
    for i = 1:size(MatStructure, 2)
        for j = 1:size(StructureNames)
            if size(StructureNames{j}, 2) == size(MatStructure{i}, 2)
                if StructureNames{j} == MatStructure{i}
                    if ~isempty(strfind(MatStructure{i}, 'MomentArm'))
                        MA_lefttrunk{1, k} = etmData_lefttrunk.Data(ii).(StructureNames{j});
                        MA_lefttrunk{1, k}(isnan(MA_lefttrunk{1, k})) = 0;
                        k = k + 1;
                    end
                end
            end
        end
    end
end

MA_lefttrunk{13} = MA_lefttrunk{1};
MA_lefttrunk{14} = MA_lefttrunk{2};
MA_lefttrunk{15} = MA_lefttrunk{3};
MA_lefttrunk{1} = zeros(141, 29);
MA_lefttrunk{2} = zeros(141, 29);
MA_lefttrunk{3} = zeros(141, 29);
MA_lefttrunk{4} = zeros(141, 29);
MA_lefttrunk{5} = zeros(141, 29);
MA_lefttrunk{6} = zeros(141, 29);
MA_lefttrunk{7} = zeros(141, 29);
MA_lefttrunk{8} = zeros(141, 29);
MA_lefttrunk{9} = zeros(141, 29);
MA_lefttrunk{10} = zeros(141, 29);
MA_lefttrunk{11} = zeros(141, 29);
MA_lefttrunk{12} = zeros(141, 29);

%%% Right Trunk
for ii = 1
    k = 1;
    StructureNames = fieldnames(etmData_righttrunk.Data);

    for i = 1:size(MatStructure, 2)
        for j = 1:size(StructureNames)
            if size(StructureNames{j}, 2) == size(MatStructure{i}, 2)
                if StructureNames{j} == MatStructure{i}
                    if ~isempty(strfind(MatStructure{i}, 'MomentArm'))
                        MA_righttrunk{1, k} = etmData_righttrunk.Data(ii).(StructureNames{j});
                        MA_righttrunk{1, k}(isnan(MA_righttrunk{1, k})) = 0;
                        k = k + 1;
                    end
                end
            end
        end
    end
end

MA_righttrunk{13} = MA_righttrunk{1};
MA_righttrunk{14} = MA_righttrunk{2};
MA_righttrunk{15} = MA_righttrunk{3};
MA_righttrunk{1} = zeros(141, 29);
MA_righttrunk{2} = zeros(141, 29);
MA_righttrunk{3} = zeros(141, 29);
MA_righttrunk{4} = zeros(141, 29);
MA_righttrunk{5} = zeros(141, 29);
MA_righttrunk{6} = zeros(141, 29);
MA_righttrunk{7} = zeros(141, 29);
MA_righttrunk{8} = zeros(141, 29);
MA_righttrunk{9} = zeros(141, 29);
MA_righttrunk{10} = zeros(141, 29);
MA_righttrunk{11} = zeros(141, 29);
MA_righttrunk{12} = zeros(141, 29);

%%% Concatenated MA
for i = 1:15
    MA_all{i} = [MA_rightleg{i} MA_leftleg{i} MA_righttrunk{i} MA_lefttrunk{i}];
end

clear 'MA_rightleg' 'MA_leftleg' 'MA_righttrunk' 'MA_lefttrunk'
%% VMT
%%% Left Leg
str = 'etmData_leftleg.Data';
VMT_leftleg = eval([str, '.MuscleTendonVelocities']);

%%% Right Leg
str = 'etmData_rightleg.Data(trial_no)';
VMT_rightleg = eval([str, '.MuscleTendonVelocities']);

%%% Left Trunk
str = 'etmData_lefttrunk.Data';
VMT_lefttrunk = eval([str, '.MuscleTendonVelocities']);

%%% Right Trunk
str = 'etmData_righttrunk.Data';
VMT_righttrunk = eval([str, '.MuscleTendonVelocities']);

%%% Concatenated VMT
VMT_all = [VMT_rightleg VMT_leftleg VMT_righttrunk VMT_lefttrunk];
clear 'VMT_rightleg' 'VMT_leftleg' 'VMT_righttrunk' 'VMT_lefttrunk'
%% ID Loads
%%% Left Leg
str = 'etmData_leftleg.Data';
ID_leftleg = eval([str, '.IDLoads']);
ID_leftleg(:, 7) = [];
% ID_leftleg(:,8) = ID_leftleg(:,7);
% ID_leftleg(:,7) = zeros(141,1);
% ID_leftleg(:,9) = zeros(141,1);

%%% Right Leg
str = 'etmData_rightleg.Data(trial_no)';
ID_rightleg = eval([str, '.IDLoads']);
ID_rightleg(:, 7) = [];
% ID_rightleg(:,8) = ID_rightleg(:,7);
% ID_rightleg(:,7) = zeros(141,1);
% ID_rightleg(:,9) = zeros(141,1);

%%% Left Trunk
str = 'etmData_lefttrunk.Data';
ID_trunk = eval([str, '.IDLoads']);
% ID_lefttrunk(:,7) = ID_lefttrunk(:,1);
% ID_lefttrunk(:,8) = ID_lefttrunk(:,2);
% ID_lefttrunk(:,9) = ID_lefttrunk(:,3);
% ID_lefttrunk(:,1) = zeros(141,1);
% ID_lefttrunk(:,2) = zeros(141,1);
% ID_lefttrunk(:,3) = zeros(141,1);
% ID_lefttrunk(:,4) = zeros(141,1);
% ID_lefttrunk(:,5) = zeros(141,1);
% ID_lefttrunk(:,6) = zeros(141,1);

% %%% Right Trunk
% str = 'etmData_righttrunk.Data(trial_no)';
% ID_righttrunk = eval([str,'.IDLoads']);
% ID_righttrunk(:,7) = ID_righttrunk(:,1);
% ID_righttrunk(:,8) = ID_righttrunk(:,2);
% ID_righttrunk(:,9) = ID_righttrunk(:,3);
% ID_righttrunk(:,1) = zeros(141,1);
% ID_righttrunk(:,2) = zeros(141,1);
% ID_righttrunk(:,3) = zeros(141,1);
% ID_righttrunk(:,4) = zeros(141,1);
% ID_righttrunk(:,5) = zeros(141,1);
% ID_righttrunk(:,6) = zeros(141,1);

%%% Concatenated ID
ID_all = [ID_rightleg ID_leftleg ID_trunk];
clear 'ID_rightleg' 'ID_leftleg' 'ID_trunk'
clear 'etmData_leftleg' 'etmData_rightleg' 'etmData_lefttrunk' 'etmData_righttrunk'

% muscleNames_leftleg = eval([str,'.ColumnLabels']);
% VTL_leftleg = eval([str,'.MuscleTendonVelocities']);
% CoordNames_leftleg = eval([str,'.CoordinateLabels']);
% JointAngles_leftleg = eval([str,'.JointAngles']);
% JointVel_leftleg = eval([str,'.JointVelocities']);
% MomentLabels_leftleg = eval([str,'.IDLoadLabels']);
% Moments_leftleg = eval([str,'.IDLoads']);
coordinateNames = {'hip_flexion_r', 'hip_adduction_r', 'hip_rotation_r', 'knee_angle_r', 'ankle_angle_r', 'subtalar_angle_r', ...
    'hip_flexion_l', 'hip_adduction_l', 'hip_rotation_l', 'knee_angle_l', 'ankle_angle_l', 'subtalar_angle_l', ...
    'lumbar_extension', 'lumbar_bending', 'lumbar_rotation'};
muscleNames = {'addbrev_r', 'addlong_r', 'addmagDist_r', 'addmagIsch_r', 'addmagMid_r', 'addmagProx_r', 'bflh_r', 'bfsh_r', 'edl_r', 'ehl_r', 'fdl_r', 'fhl_r', 'gaslat_r', 'gasmed_r', 'gem_r', 'glmax1_r', 'glmax2_r', 'glmax3_r', 'glmed1_r', 'glmed2_r', 'glmed3_r', 'glmin1_r', 'glmin2_r', 'glmin3_r', 'grac_r', 'iliacus_r', 'pect_r', 'perbrev_r', 'perlong_r', 'piri_r', 'Ps_L1_TP_r', 'Ps_L3_L4_IVD_r', 'Ps_L5_TP_r', 'quadfem_r', 'recfem_r', 'sart_r', 'semimem_r', 'semiten_r', 'soleus_r', 'tfl_r', 'tibant_r', 'tibpost_r', 'vasint_r', 'vaslat_r', 'vasmed_r', ...
    'addbrev_l', 'addlong_l', 'addmagDist_l', 'addmagIsch_l', 'addmagMid_l', 'addmagProx_l', 'bflh_l', 'bfsh_l', 'edl_l', 'ehl_l', 'fdl_l', 'fhl_l', 'gaslat_l', 'gasmed_l', 'gem_l', 'glmax1_l', 'glmax2_l', 'glmax3_l', 'glmed1_l', 'glmed2_l', 'glmed3_l', 'glmin1_l', 'glmin2_l', 'glmin3_l', 'grac_l', 'iliacus_l', 'pect_l', 'perbrev_l', 'perlong_l', 'piri_l', 'Ps_L1_TP_l', 'Ps_L3_L4_IVD_l', 'Ps_L5_TP_l', 'quadfem_l', 'recfem_l', 'sart_l', 'semimem_l', 'semiten_l', 'soleus_l', 'tfl_l', 'tibant_l', 'tibpost_l', 'vasint_l', 'vaslat_l', 'vasmed_l', ...
    'IO2_r', 'IO4_r', 'IO5_r', 'EO10_r', 'EO12_r', 'IL_L2_r', 'IL_L4_r', 'IL_R7_r', 'IL_R10_r', 'IL_R11_r', 'IL_R12_r', 'LTpT_T8_r', 'LTpT_T12_r', 'LTpT_R8_r', 'LTpT_R11_r', 'LTpL_L2_r', 'LTpL_L4_r', 'LTpL_L5_r', 'MF_m1t_3_r', 'MF_m2t_3_r', 'MF_m3s_r', 'MF_m4t_3_r', 'MF_m5_laminar_r', 'QL_post_I1_L3_r', 'QL_post_I2_L4_r', 'QL_post_I3_L2_r', 'QL_ant_I2_T12_r', 'QL_ant_I3_R12_I2_r', 'rect_abd_r', ...
    'IO2_l', 'IO4_l', 'IO5_l', 'EO10_l', 'EO12_l', 'IL_L2_l', 'IL_L4_l', 'IL_R7_l', 'IL_R10_l', 'IL_R11_l', 'IL_R12_l', 'LTpT_T8_l', 'LTpT_T12_l', 'LTpT_R8_l', 'LTpT_R11_l', 'LTpL_L2_l', 'LTpL_L4_l', 'LTpL_L5_l', 'MF_m1t_3_l', 'MF_m2t_3_l', 'MF_m3s_l', 'MF_m4t_3_l', 'MF_m5_laminar_l', 'QL_post_I1_L3_l', 'QL_post_I2_L4_l', 'QL_post_I3_L2_l', 'QL_ant_I2_T12_l', 'QL_ant_I3_R12_I2_l', 'rect_abd_l'};

%% EMG activations
EMGact_all = [EMGD_data.a((trial_no - 1) * inputs.numPoints + 1:trial_no * inputs.numPoints, :), act_leftleg.activation_L.case_3];
inputs.EMGact_all = EMGact_all;
end

function A = lumbarSurrogateModel(theta1, theta2, theta3, numPoints)
A = [ones(numPoints, 1), theta1, theta2, theta3, theta1 .* theta2, theta1 .* theta3, theta2 .* theta3, ...
    theta1.^2, theta2.^2, theta3.^2];
end
