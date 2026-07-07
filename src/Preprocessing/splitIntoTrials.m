% This function is part of the NMSM Pipeline, see file for full license.
%
% This function accepts a list of time pairs and input and output settings
% and splits the data into trials given by the time pairs. The data is
% written to the output directory specified in the output settings.
%
% inputSettings is a struct with the following fields:
%   model: an opensim model, can be invoked with Model(modelFileName)
%   ikFileName: a string or char array with the name of the ik data file
%   idFileName: a string or char array with the name of the id data file
%   emgFileName: a string or char array with the name of the emg data file
%   grfFileName: a string or char array with the name of the grf data file
%   maDirectory: a string or char array with the name of directory storing
%       the muscle analysis data
% outputSettings is a struct with the following fields:
%   trialPrefix: a string or char array with the prefix for the trial
%       (i.e. prefix 'gait' will name files gait_1, gait_2, etc.)
%   resultsDirectory: a string or char array with the name of the directory
%
% (2xN array, struct, struct) -> (None)
% splits the data into trials given by time pairs

% ----------------------------------------------------------------------- %
% The NMSM Pipeline is a toolkit for model personalization and treatment  %
% optimization of neuromusculoskeletal models through OpenSim. See        %
% nmsm.rice.edu and the NOTICE file for more information. The             %
% NMSM Pipeline is developed at Rice University and supported by the US   %
% National Institutes of Health (R01 EB030520).                           %
%                                                                         %
% Copyright (c) 2021 Rice University and the Authors                      %
% Author(s): Claire V. Hammond                                            %
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

function splitIntoTrials(timePairs, inputSettings, outputSettings)

model = inputSettings.model;
ikFileName = getFieldByName(inputSettings, 'ikFileName');
idFileName = getFieldByName(inputSettings, 'idFileName');
emgFileName = getFieldByName(inputSettings, 'emgFileName');
grfFileName = getFieldByName(inputSettings, 'grfFileName');
muscleAnalysisDirectory = getFieldByName(inputSettings, 'maDirectory');
trialName = getFieldByNameOrAlternate(outputSettings, 'trialPrefix', ...
    'trial');
outputDir = getFieldByNameOrAlternate(outputSettings, ...
    'resultsDirectory', 'preprocessed');
cutoffFrequency = valueOrAlternate(inputSettings, 'cutoffFrequency', 6);
rowsPerTrial = valueOrAlternate(inputSettings, 'rowsPerTrial', 101);

model = Model(model);
ikOutputDir = 'IKData';
idOutputDir = 'IDData';
maOutputDir = 'MAData';
emgOutputDir = 'EMGData';
grfOutputDir = 'GRFData';
included.ik = isstring(ikFileName) || ischar(ikFileName);
included.id = isstring(idFileName) || ischar(idFileName);
included.emg = isstring(emgFileName) || ischar(emgFileName);
included.grf = isstring(grfFileName) || ischar(grfFileName);
included.ma = isstring(muscleAnalysisDirectory) || ...
    ischar(muscleAnalysisDirectory);
makeDirectoryStructure(outputDir, ikOutputDir, idOutputDir, ...
    maOutputDir, emgOutputDir, grfOutputDir, included);
if included.ik
    preprocessInverseKinematicsData(model, ikFileName, ...
        outputDir, ikOutputDir, trialName)
end
if included.id
    preprocessDataFile(idFileName, outputDir, idOutputDir, trialName)
end
if included.grf
    preprocessDataFile(grfFileName, outputDir, grfOutputDir, trialName)
end
if included.ma
    coordinates = getAllCoordinates(model);
    preprocessMuscleAnalysisData(outputDir, muscleAnalysisDirectory, ...
        maOutputDir, trialName, coordinates)
else
    coordinates = [];
end
if included.emg
    preprocessDataFile(emgFileName, outputDir, emgOutputDir, trialName)
end

[filesToSection, filesToFilter] = makeFilesToSection(outputDir, ...
    ikOutputDir, idOutputDir, maOutputDir, grfOutputDir, trialName, ...
    coordinates, included);
sectionDataFiles(filesToSection, timePairs, rowsPerTrial, trialName, ...
    filesToFilter, cutoffFrequency);

if included.emg
numBufferRows = calcNumPaddingFrames(timePairs, rowsPerTrial);
paddedTimePairs = addBufferToTimePairs(timePairs, numBufferRows, ...
    rowsPerTrial);
sectionDataFiles( ...
    [fullfile(outputDir, emgOutputDir, trialName + ".sto")], ...
    paddedTimePairs, (2 * numBufferRows) + rowsPerTrial, trialName, ...
    false, cutoffFrequency);
end
for i=1:length(filesToSection)
    delete(filesToSection(i));
end
if included.emg
    delete(fullfile(outputDir, emgOutputDir, trialName + ".sto"));
end
if included.ma
    moveMAFilesToSeparateDirectories(trialName, outputDir, ...
        maOutputDir, timePairs)
end
end

function makeDirectoryStructure(outputDir, ikDir, idDir, maDir, emgDir, ...
    grfDir, included)
if not(isfolder(outputDir))
    mkdir(outputDir)
end

if not(isfolder(fullfile(outputDir, ikDir))) && included.ik
    mkdir(fullfile(outputDir, ikDir))
end

if not(isfolder(fullfile(outputDir, idDir))) && included.id
    mkdir(fullfile(outputDir, idDir))
end

if not(isfolder(fullfile(outputDir, maDir))) && included.ma
    mkdir(fullfile(outputDir, maDir))
end

if not(isfolder(fullfile(outputDir, emgDir))) && included.emg
    mkdir(fullfile(outputDir, emgDir))
end

if not(isfolder(fullfile(outputDir, grfDir))) && included.grf
    mkdir(fullfile(outputDir, grfDir))
end
end

function preprocessInverseKinematicsData(model, ikFileName, ...
    outputDir, ikOutputDir, trialName)
import org.opensim.modeling.Storage
[ikColumnLabels, ikTime, ikData] = parseMotToComponents( ...
    Model(model), Storage(ikFileName));
writeToSto(ikColumnLabels, ikTime, ikData', fullfile(outputDir, ...
    ikOutputDir, trialName + ".sto"))
end

function preprocessDataFile(fileName, outputDir, ...
    fileOutputDir, trialName)
copyfile(fileName, fullfile(outputDir, ...
    fileOutputDir, trialName + ".sto"))
end

function preprocessMuscleAnalysisData(outputDir, muscleAnalysisDirectory, ...
    maOutputDir, trialName, coordinates)
moveMuscleAnalysis(fullfile(outputDir, maOutputDir), ...
    muscleAnalysisDirectory, coordinates, trialName);
end

function coordinates = getAllCoordinates(model)
coordinates = string([]);
for i = 0 : model.getCoordinateSet().getSize() - 1
    coordinates(end + 1) = model.getCoordinateSet.get(i).getName().toCharArray';
end
end

function [filesToSection, filesToFilter] = makeFilesToSection( ...
    outputDir, ikOutputDir, idOutputDir, maOutputDir, grfOutputDir, ...
    trialName, coordinates, included)
filesToSection = string([]);
filesToFilter = [];
if included.ma
    filesToSection = [ ...
        fullfile(outputDir, maOutputDir, trialName + ...
        "_Length.sto"), ...
        fullfile(outputDir, maOutputDir, trialName + ...
        "_Velocity.sto")];
    filesToFilter = [true, false];
end
if included.ik
    filesToSection(end+1) = ...
        fullfile(outputDir, ikOutputDir, trialName + ".sto");
    filesToFilter(end+1) = true;
end
if included.id
    filesToSection(end+1) = ...
        fullfile(outputDir, idOutputDir, trialName + ".sto");
    filesToFilter(end+1) = true;
end
if included.grf
    filesToSection(end+1) = fullfile(outputDir, grfOutputDir, ...
        trialName + ".sto");
    filesToFilter(end+1) = false;
end
for i=1:length(coordinates)
    if isfile(fullfile(outputDir, maOutputDir, ...
            trialName + "_MomentArm_" + coordinates(i) + ".sto"))
        filesToSection(end+1) = fullfile(outputDir, maOutputDir, ...
            trialName + "_MomentArm_" + coordinates(i) + ".sto");
        filesToFilter(end+1) = true;
    end
end
end

function moveMuscleAnalysis(outputDir, inputDir, coordinates, trialName)
files = dir(inputDir);
for i=1:length(coordinates)
    for j=1:length(files)
        if(~files(j).isdir && contains(files(j).name, "_MomentArm_" ...
                + coordinates(i)))
            copyfile(fullfile(inputDir, files(j).name), ...
                fullfile(outputDir, trialName + "_MomentArm_" + ...
                coordinates(i) + ".sto"))
            break;
        end
    end
end
for k=1:length(files)
    if(~files(k).isdir && contains(files(k).name, "MuscleAnalysis_Length"))
        copyfile(fullfile(inputDir, files(k).name), ...
            fullfile(outputDir, trialName + "_Length.sto"))
        break;
    end
end
for k=1:length(files)
    if(~files(k).isdir && contains(files(k).name, "MuscleAnalysis_Velocity"))
        copyfile(fullfile(inputDir, files(k).name), ...
            fullfile(outputDir, trialName + "_Velocity.sto"))
        break;
    end
end
end

function throwCantFindMAFileException(fileName)
throw(MException('', "Cannot find Muscle Analysis file for " + fileName));
end

function numFramesBuffer = calcNumPaddingFrames(timePairs, ...
    normalizedNumDataPoints)
shortestTrialLength = timePairs(1,2) - timePairs(1,1);
for i=2:size(timePairs, 1)
    if(timePairs(i,2) - timePairs(i,1) < shortestTrialLength)
        shortestTrialLength = timePairs(i,2) - timePairs(i,1);
    end
end
timePerFrame = shortestTrialLength / (normalizedNumDataPoints-1);
numFramesBuffer = ceil(0.2 / timePerFrame);
end

function newTimePairs = addBufferToTimePairs(timePairs, numBufferRows, ...
    rowsPerTrial)
for i=1:size(timePairs, 1)
    trialTime = timePairs(i,2) - timePairs(i,1);
    timePairs(i,1) = timePairs(i,1) - (numBufferRows / ...
        (rowsPerTrial - 1) * trialTime);
    timePairs(i,2) = timePairs(i,2) + (numBufferRows / ...
        (rowsPerTrial - 1) * trialTime);
end
newTimePairs = timePairs;
end

function moveMAFilesToSeparateDirectories(trialName, outputDir, ...
    maOutputDir, timePairs)
for i=1:size(timePairs, 1)
    mkdir(fullfile(outputDir, maOutputDir, trialName + "_" ...
        + i));
    files = dir(fullfile(outputDir, maOutputDir));
    for j=1:length(files)
        if(~files(j).isdir && contains(files(j).name, trialName + ...
                "_" + num2str(i) + "_"))
            movefile(fullfile(outputDir, maOutputDir, ...
                files(j).name), fullfile(outputDir, ...
                maOutputDir, trialName + "_" + i));
        end
    end
end
end
