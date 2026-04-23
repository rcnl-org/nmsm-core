function [errorFlag, message] = parseOsimxFileGui(app, ...
    input_osimx_file, input_model_file)
message = [];
errorFlag = false;
if strcmp(input_osimx_file, "")
    return
end

if ~exist(input_osimx_file)
    message = "The given Osimx file does not exist";
    errorFlag = true;
    return
end

try 
    osimx = parseOsimxFile(input_osimx_file, input_model_file);
catch
    errorFlag = true;
    message = parseOsimxFileForErrors(input_osimx_file, input_model_file);
    return
end

try parseOsimxFileMuscles(app, osimx);
catch
end

try parseOsimxFileContactSurfaces(app, osimx);
catch
end

try parseOsimxFileSynergies(app, osimx);
catch
end

end

function errorMessage = parseOsimxFileForErrors(input_osimx_file, input_model_file);
    errorMessage = "Osimx file could not parse.";
end