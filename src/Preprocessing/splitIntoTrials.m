function splitIntoFiles(outputDir, ikFileName, idFileName, ...
    muscleAnalysisDirectory, emgFileName, trialName, timePairs, model)
model = Model(model);
ikOutputDir = 'IKData';
idOutputDir = 'IDData';
maOutputDir = 'MAData';
emgOutputDir = 'EMGData';
makeDirectoryStructure(outputDir, ikOutputDir, idOutputDir, ...
    maOutputDir, emgOutputDir);
preprocessInverseKinematicsData(model, ikFileName, ...
        outputDir, ikOutputDir, trialName)
preprocessInverseDynamicsData(idFileName, outputDir, ...
        idOutputDir, trialName)
coordinates = getAllCoordinates(model);
preprocessMuscleAnalysisData(outputDir, muscleAnalysisDirectory, ...
    maOutputDir, trialName, coordinates)
preprocessEmgData(emgFileName, outputDir, emgOutputDir, trialName)

filesToSection = makeFilesToSection(outputDir, ikOutputDir, ...
    idOutputDir, maOutputDir, trialName, coordinates);
sectionDataFiles(filesToSection, timePairs, 101, trialName);

numBufferRows = calcNumPaddingFrames(timePairs);
paddedTimePairs = addBufferToTimePairs(timePairs, numBufferRows);
sectionDataFiles( ...
    [fullfile(outputDir, emgOutputDir, trialName + ".sto")], ...
    paddedTimePairs, (2 * numBufferRows) + 101, trialName)
for i=1:length(filesToSection)
    delete(filesToSection(i));
end
moveMAFilesToSeparateDirectories(trialName, outputDir, ...
        maOutputDir, timePairs)
end

function makeDirectoryStructure(outputDir, ikDir, idDir, maDir, emgDir)
if not(isfolder(outputDir))
    mkdir(outputDir)
end

if not(isfolder(fullfile(outputDir, ikDir)))
    mkdir(fullfile(outputDir, ikDir))
end

if not(isfolder(fullfile(outputDir, idDir)))
    mkdir(fullfile(outputDir, idDir))
end

if not(isfolder(fullfile(outputDir, maDir)))
    mkdir(fullfile(outputDir, maDir))
end

if not(isfolder(fullfile(outputDir, emgDir)))
    mkdir(fullfile(outputDir, emgDir))
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

function preprocessInverseDynamicsData(idFileName, outputDir, ...
        idOutputDir, trialName)
copyfile(idFileName, fullfile(outputDir, ...
    idOutputDir, trialName + ".sto"))
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

function preprocessEmgData(emgFileName, outputDir, emgOutputDir, trialName)
copyfile(emgFileName, fullfile(outputDir, ...
    emgOutputDir, trialName + ".sto"))
end

function filesToSection = makeFilesToSection(outputDir, ikOutputDir, ...
    idOutputDir, maOutputDir, trialName, coordinates)
filesToSection = [ ...
    fullfile(outputDir, maOutputDir, trialName + ...
    "_Length.sto"), ...
    fullfile(outputDir, ikOutputDir, trialName + ".sto"), ...
    fullfile(outputDir, idOutputDir, trialName + ".sto")
    ];
for i=1:length(coordinates)
    if isfile(fullfile(outputDir, maOutputDir, ...
            trialName + "_MomentArm_" + coordinates(i) + ".sto"))
        filesToSection(end+1) = fullfile(outputDir, maOutputDir, ...
            trialName + "_MomentArm_" + coordinates(i) + ".sto");
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
end

function throwCantFindMAFileException(fileName)
throw(MException('', "Cannot find Muscle Analysis file for " + fileName));
end

function numFramesBuffer = calcNumPaddingFrames(timePairs)
normalizedNumDataPoints = 101;
shortestTrialLength = timePairs(1,2) - timePairs(1,1);
for i=2:size(timePairs, 1)
    if(timePairs(i,2) - timePairs(i,1) < shortestTrialLength)
        shortestTrialLength = timePairs(i,2) - timePairs(i,1);
    end
end
timePerFrame = shortestTrialLength / (normalizedNumDataPoints-1);
numFramesBuffer = ceil(0.2 / timePerFrame);
end

function newTimePairs = addBufferToTimePairs(timePairs, numBufferRows)
rowsPerTrial = 101;
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
for i=1:length(timePairs)
    mkdir(fullfile(outputDir, maOutputDir, trialName + "_" ...
        + i));
    files = dir(fullfile(outputDir, maOutputDir));
    for j=1:length(files)
        if(~files(j).isdir && contains(files(j).name, trialName + ...
                "_" + num2str(i)))
            movefile(fullfile(outputDir, maOutputDir, ...
                files(j).name), fullfile(outputDir, ...
                maOutputDir, trialName + "_" + i));
        end
    end
end
end
