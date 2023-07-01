% This function is part of the NMSM Pipeline, see file for full license.
%
% Use this script to process your EMG, IK, ID, and MuscleAnalysis data in
% preparation for the other NMSM Pipeline tools. This script is intended to
% be used after Joint Model Personalization and the IK, ID, and
% MuscleAnalysis data for this script should be generated through the 
% OpenSim GUI tools. 
%
% Modify the script below with your own filenames and preferred settings.

%% Preprocessing Script

% All values required
rawEmgFileName = "input_data\Patient3_NormalGait_1pt0_02_Right_01_EMG.mot";
filterOrder = 4;
highPassCutoff = 40;
lowPassCutoff = 3.5 / 1.25;
processedEmgFileName = "Patient3_NormalGait_1pt0_02_Right_01_processedEmg.sto";

processRawEmgFile(rawEmgFileName, filterOrder, highPassCutoff, ...
    lowPassCutoff, processedEmgFileName);


%% Create Muscle Tendon Velocity
% Calculates muscle-tendon velocity using B-splines and MuscleAnalysis's
% muscle-tendon length. The file is written in the same directory as the
% muscle-tendon length file.

muscleTendonLengthFileName = "MuscleAnalysis\UF_Patient3_correctHeight_MuscleAnalysis_Length.sto";%...
    %"MuscleAnalysis/model_MuscleAnalysis_Length.sto";
cutoffFrequency = 10;
createMuscleTendonVelocity(muscleTendonLengthFileName, cutoffFrequency);

%% Split OpenSim data into trials by time pairs

% Required: pairs of start/end time of events to be extracted
trialTimePairs = [
    0.65 1.9
];

% Required: Associated .osim model file
inputSettings.model = "UF_Patient3_correctHeight_JMP_MTPGroups_NCPGroups.osim";

% All values optional: files and directories of data to be split
inputSettings.ikFileName = "input_data\Patient3_NormalGait_1pt0_02_Right_01_IK.mot";
inputSettings.idFileName = "input_data\Patient3_NormalGait_1pt0_02_Right_01_ID.sto";
% The emgFileName should be the name of the *processed* emg data file
inputSettings.emgFileName = "Patient3_NormalGait_1pt0_02_Right_01_processedEmg.sto";
inputSettings.maDirectory = "MuscleAnalysis";

% All values optional: output information, uses default values otherwise
outputSettings.resultsDirectory = "preprocessed";
% The trial prefix is the prefix of each output file, identifying the
% motion such as 'gait' or 'squat' or 'step_up'.
outputSettings.trialPrefix = "gait";

splitIntoTrials( ...
    trialTimePairs, ...
    inputSettings, ...
    outputSettings ...
    )
