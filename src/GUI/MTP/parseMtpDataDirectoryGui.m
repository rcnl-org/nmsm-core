function [errorFlag, message] = parseMtpDataDirectoryGui(app, dataDirectory)
% requiredTypes logical = [EMGData GRFData IDData IKData MAData] 
import org.opensim.modeling.Storage
import org.opensim.modeling.Model
errorFlag = false;
message = "";

% Check if data directory exists
if strcmp(dataDirectory, "")
    return
end

% if a given data directory doesn't exist, give error
if ~exist(dataDirectory, "dir")
    errorFlag = true;
    message = "The given directory does not exist";
end

% The data directory must have EMGData, IDData, MAData
if ~exist(fullfile(dataDirectory, "EMGData"), "dir")
    errorFlag = true;
    message = "The given directory must contain a folder named 'EMGData'";
    return
elseif ~exist(fullfile(dataDirectory, "IDData"), "dir")
    errorFlag = true;
    message = "The given directory must contain a folder named 'IDData'";
    return
elseif ~exist(fullfile(dataDirectory, "MAData"), "dir")
    errorFlag = true;
    message = "The given directory must contain a folder named 'MAData'";
    return   
end

% parse trial names from directory
emgFolder = dir(fullfile(dataDirectory, "EMGData"));
emgFolder = emgFolder(~ismember({emgFolder.name},{'.','..'}));
idFolder = dir(fullfile(dataDirectory, "IDData"));
idFolder = idFolder(~ismember({idFolder.name},{'.','..'}));
maFolder = dir(fullfile(dataDirectory, "MAData"));
maFolder = maFolder(~ismember({maFolder.name},{'.','..'}));
emgFileNames = {emgFolder.name};
idFileNames = {idFolder.name};
maFolderNames = {maFolder.name};

files = dir(fullfile(dataDirectory, "IDData"));
if isempty(files)
    files = dir(fullfile(dataDirectory, "IKData"));
end

trialNames = string([]);
for i=1:length(files)
    if (~files(i).isdir)
        trialNames(end+1) = files(i).name(1:end-4);
    elseif(~files(i).isdir) && (islogical(includedPrefixes) || contains(files(i).name, includedPrefixes))
        % prefixes(end+1) = files(i).name(1:end-4);
        trialNames(end+1) = includedPrefixes{find( ...
            cellfun(@(x) contains(files(i).name, x), ...
            includedPrefixes), 1)};
    end
end

try 
    emgNames = {};
    for i = 1 : length(trialNames)
        [emgNames{i}, emgTime, emgData] = parseMotToComponents( ...
            org.opensim.modeling.Model(), ...
            Storage(fullfile(dataDirectory, "EMGData", ...
            strcat(trialNames(i), ".sto"))));
    end
    app.setEmgLabels(emgNames{1}); % need error for if all EMG names arent the same
catch
end

try 
    idNames = {};
    for i = 1 : length(trialNames)
        [idNames{i}, idTime, idData] = parseMotToComponents( ...
            org.opensim.modeling.Model(), ...
            Storage(fullfile(dataDirectory, "IDData", ...
            strcat(trialNames(i), ".sto"))));
    end
    app.setIDLabels(idNames{1}); % need error for if all ID names arent the same
catch
end

end