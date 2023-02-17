
processEmgData(emgDirectory, filterDegrees, highPassCutoff, lowPassCutoff, )

createMuscleTendonVelocity()

%% Split OpenSim data into trials by time pairs

% Required: pairs of start/end time of events to be extracted
trialTimePairs = [
    5.2 6.2;
    6.3 7.3;
    7.4 8.5;
];

% All values optional: files and directories of data to be split
inputSettings.ikFileName = "ik.mot";
inputSettings.idFileName = "id.mot";
% inputSettings.emgFileName = "emg.mot";
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
