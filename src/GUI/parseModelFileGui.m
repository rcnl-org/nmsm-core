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
        if isfield(app, "model_markers")
            parseModelMarkers(app, model);
        end
        if isfield(app, "model_joints")
            parseModelJoints(app, model);
        end
        if isfield(app, "model_bodies")
            parseModelBodies(app, model);
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