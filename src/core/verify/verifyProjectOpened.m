function verifyProjectOpened()
try 
    proj = currentProject();
    startupFile = proj.StartupFiles;
    [~, startupFileName, ~] = fileparts(startupFile);
    if strcmp(startupFileName, "nmsmProjectStartupScript")
        return
    else
        error("NMSM Pipeline Project is not opened.")
    end
catch
    error("NMSM Pipeline Project is not opened.")
end
end