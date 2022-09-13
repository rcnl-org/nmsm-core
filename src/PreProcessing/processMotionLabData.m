% This function is part of the NMSM Pipeline, see file for full license.
%
% This function takes the necessary inputs and produces the results of IK,
% ID, and MuscleAnalysis so the values can be used as inputs for
% MuscleTendonPersonalization.
%
% (struct, struct) -> (None)
% Prepares raw data for MuscleTendonPersonalization

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

function processMotionLabData(inputs, params)
import org.opensim.modeling.Storage
ikResultsDir = 'IKData';
idResultsDir = 'IDData';
maResultsDir = 'MAData';
emgResultsDir = 'EMGData';
verifyInputs(inputs);
verifyParams(params);
makeDirectoryStructure(inputs.resultsDir, ikResultsDir, idResultsDir, ...
    maResultsDir, emgResultsDir);
[ikColumnLabels, ikTime, ikData] = parseMotToComponents( ...
    Model(inputs.model), Storage(inputs.ikResultsFileName));
writeToSto(ikColumnLabels, ikTime, ikData', fullfile(inputs.resultsDir, ...
    ikResultsDir, inputs.prefix + ".sto"))
copyfile(inputs.idResultsFileName, fullfile(inputs.resultsDir, ...
    idResultsDir, inputs.prefix + ".sto"))
moveMuscleAnalysis(fullfile(inputs.resultsDir, maResultsDir), ...
    inputs.maResultsDir, inputs.coordinates, inputs.prefix);
expandEmgDatas(inputs.model, inputs.emgFileName, ...
    fullfile(inputs.resultsDir, emgResultsDir), inputs.prefix, params);
filesToSection = [ ...
    fullfile(inputs.resultsDir, maResultsDir, inputs.prefix + ...
    "_Length.sto"), ...
    fullfile(inputs.resultsDir, maResultsDir, inputs.prefix + ...
    "_Velocity.sto"), ...
    fullfile(inputs.resultsDir, emgResultsDir, inputs.prefix + ".mot"), ...
    fullfile(inputs.resultsDir, ikResultsDir, inputs.prefix + ".sto"), ...
    fullfile(inputs.resultsDir, idResultsDir, inputs.prefix + ".sto")
    ];
for i=1:length(inputs.coordinates)
    filesToSection(end+1) = fullfile(inputs.resultsDir, maResultsDir, ...
        inputs.prefix + "_MomentArm_" + inputs.coordinates(i) + ".sto");
end
numBufferRows = calcNumPaddingFrames(inputs.timePairs, params);
paddedTimePairs = addBufferToTimePairs(inputs.timePairs, numBufferRows, ...
    params);
sectionDataFiles(filesToSection, paddedTimePairs, ...
    2 * numBufferRows + valueOrAlternate(params, 'rowsPerTrial', 101), ...
    inputs.prefix, inputs.model, inputs.coordinates);
for i=1:length(filesToSection)
    delete(filesToSection(i));
end
moveMAFilesToSeparateDirectories(inputs, maResultsDir, paddedTimePairs)
end


function verifyInputs(inputs)

end

function verifyParams(params)

end

function makeDirectoryStructure(resultsDir, ikDir, idDir, maDir, emgDir)
mkdir(resultsDir)
mkdir(fullfile(resultsDir, ikDir))
mkdir(fullfile(resultsDir, idDir))
mkdir(fullfile(resultsDir, maDir))
mkdir(fullfile(resultsDir, emgDir))
end

function moveMuscleAnalysis(resultsDir, inputDir, coordinates, prefix)
files = dir(inputDir);
for i=1:length(coordinates)
    found = false;
    for j=1:length(files)
        if(~files(j).isdir && contains(files(j).name, "_MomentArm_" ...
                + coordinates(i)))
            copyfile(fullfile(inputDir, files(j).name), ...
                fullfile(resultsDir, prefix + "_MomentArm_" + ...
                coordinates(i) + ".sto"))
            found = true;
            break;
        end
    end
    if(~found)
        throwCantFindMAFileException("_MomentArm_" + coordinates(i));
    end
end
% now move length file
found = false;
for k=1:length(files)
    if(~files(k).isdir && contains(files(k).name, "MuscleAnalysis_Length"))
        copyfile(fullfile(inputDir, files(k).name), ...
            fullfile(resultsDir, prefix + "_Length.sto"))
        found = true;
        break;
    end
end
if(~found) throwCantFindMAFileException("_MuscleAnalysis_Length.sto"); end
createMuscleTendonVelocity(fullfile(resultsDir, prefix + ...
    "_Length.sto"), fullfile(resultsDir, prefix + "_Velocity.sto"));
end


function throwCantFindMAFileException(fileName)
throw(MException('', "Cannot find Muscle Analysis file for " + fileName));
end

function numFramesBuffer = calcNumPaddingFrames(timePairs, params)
normalizedNumDataPoints = valueOrAlternate(params, 'rowsPerTrial', 101);
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
    params)
rowsPerTrial = valueOrAlternate(params, 'rowsPerTrial', 101);
for i=1:size(timePairs, 1)
    trialTime = timePairs(i,2) - timePairs(i,1);
    timePairs(i,1) = timePairs(i,1) - (numBufferRows / ...
        (rowsPerTrial - 1) * trialTime);
    timePairs(i,2) = timePairs(i,2) + (numBufferRows / ...
        (rowsPerTrial - 1) * trialTime);
end
newTimePairs = timePairs;
end

function moveMAFilesToSeparateDirectories(inputs, maResultsDir, ...
    paddedTimePairs)
for i=1:length(paddedTimePairs)
    mkdir(fullfile(inputs.resultsDir, maResultsDir, inputs.prefix + "_" ...
        + i));
    files = dir(fullfile(inputs.resultsDir, maResultsDir));
    for j=1:length(files)
        if(~files(j).isdir && contains(files(j).name, inputs.prefix + ...
                "_" + num2str(i)))
            movefile(fullfile(inputs.resultsDir, maResultsDir, ...
                files(j).name), fullfile(inputs.resultsDir, ...
                maResultsDir, inputs.prefix + "_" + i));
        end
    end
end
end