disp("NMSM Pipeline Version: " + getPipelineVersion() + newline)

try
    opensimVersion =strsplit(org.opensim.modeling.opensimCommon.GetVersion() ...
    .toCharArray()', '-');
    disp("OpenSim Version: " + opensimVersion)
catch
    warning("Cannot get OpenSim version. Please ensure your OpenSim scripting environment was properly setup.")
end

try 
    disp(newline + "CasADi Version: " + casadi.CasadiMeta.version())
catch
    disp(newline + "No CasADi version in path")
end

try 
    gpops2License()
catch
    disp(newline + "No GPOPS-II version in path")
end

disp(newline + "NMSM Pipeline Project Successfully Opened")