% This function is part of the NMSM Pipeline, see file for full license.
%
% This function validates a .osim model file and, if valid, uses OpenSim
% to parse its markers, joints, bodies, coordinates, and muscle groups,
% populating the GUI app with the extracted model components.
%
% (App, string) -> (bool, string)
% Parses an OpenSim model file and populates the app with model components

% ----------------------------------------------------------------------- %
% The NMSM Pipeline is a toolkit for model personalization and treatment  %
% optimization of neuromusculoskeletal models through OpenSim. See        %
% nmsm.rice.edu and the NOTICE file for more information. The             %
% NMSM Pipeline is developed at Rice University and supported by the US   %
% National Institutes of Health (R01 EB030520).                           %
%                                                                         %
% Copyright (c) 2026 Rice University and the Authors                      %
% Author(s): Robert Salati                                                %
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
function [errorFlag, message] = parseModelFileGui(app, input_model_file)
        message = "";
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
        app.setModelMarkers(model_markers);
    end

    function parseModelJoints(app, model)
        numJoints = model.getNumJoints;
        jointSet = model.getJointSet();
        model_joints = string([]);
        for i = 1 : numJoints
            model_joints(end+1) = jointSet.get(i-1).getName();
        end
        app.setModelJoints(model_joints);
    end

    function parseModelBodies(app, model)
        numBodies = model.getNumBodies;
        bodySet = model.getBodySet();
        model_bodies = string([]);
        for i = 1 : numBodies
            model_bodies(end+1) = bodySet.get(i-1).getName();
        end
        app.setModelBodies(model_bodies);
    end

    function parseModelCoordinates(app, model)
        coordinateSet = model.getCoordinateSet();
        numCoordinates = coordinateSet.getSize();
        model_coordinates = string([]);
        for i = 1 : numCoordinates
            model_coordinates(end+1) = coordinateSet.get(i-1).getName();
        end
        app.setModelCoordinates(model_coordinates);
    end

    function parseModelGroups(app, model)
        forceSet = model.getForceSet();
        numGroups = forceSet.getNumGroups;
        model_groups = string([]);
        for i = 1 : numGroups
            model_groups(end+1) = forceSet.getGroup(i-1).getName();
        end
        app.setModelGroups(model_groups);
    end