function [errorFlag, message] = parseModelFileGui(app, input_model_file)
        message = [];
        errorFlag = false;
        if strcmp(input_model_file, "")
            return
        end
        if ~exist(input_model_file)
            message = "The given model file does not exist";
            errorFlag = true;
            return
        end

        try
            model = Model(input_model_file);
        catch
            errorFlag = true;
            message = "The given model file exists but could not be parsed by OpenSim.";
            return
        end
        try
            parseModelMarkers(app, model);
        catch
        end
        try
            parseModelJoints(app, model);
        catch
        end
        try
            parseModelBodies(app, model);
        catch
        end
        try 
            parseModelCoordinates(app, model);
        catch
        end
        try 
            parseModelGroups(app, model);
        catch
        end
    end

    function parseModelMarkers(app, model)
        numMarkers = model.getNumMarkers;
        markerSet = model.getMarkerSet();
        model_markers = string([]);
        for i = 1 : numMarkers
            model_markers(end+1) = markerSet.get(i-1).getName();
        end
        app.SetModelMarkers(model_markers);
    end

    function parseModelJoints(app, model)
        numJoints = model.getNumJoints;
        jointSet = model.getJointSet();
        model_joints = string([]);
        for i = 1 : numJoints
            model_joints(end+1) = jointSet.get(i-1).getName();
        end
        app.SetModelJoints(model_joints);
    end

    function parseModelBodies(app, model)
        numBodies = model.getNumBodies;
        bodySet = model.getBodySet();
        model_bodies = string([]);
        for i = 1 : numBodies
            model_bodies(end+1) = bodySet.get(i-1).getName();
        end
        app.SetModelBodies(model_bodies);
    end

    function parseModelCoordinates(app, model)
        coordinateSet = model.getCoordinateSet();
        numCoordinates = coordinateSet.getSize();
        model_coordinates = string([]);
        for i = 1 : numCoordinates
            model_coordinates(end+1) = coordinateSet.get(i-1).getName();
        end
        app.SetModelCoordinates(model_coordinates);
    end

    function parseModelGroups(app, model)
        forceSet = model.getForceSet();
        numGroups = forceSet.getNumGroups;
        model_groups = string([]);
        for i = 1 : numGroups
            model_groups(end+1) = forceSet.getGroup(i-1).getName();
        end
        app.SetModelGroups(model_groups);
    end