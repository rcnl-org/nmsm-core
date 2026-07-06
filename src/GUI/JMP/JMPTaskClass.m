% This class is part of the NMSM Pipeline, see file for full license.
%
% This class represents the data model for a single Joint Model
% Personalization (JMP) task within the JMP GUI, including the marker
% file, time range, and joint and body parameter selections.

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
classdef JMPTaskClass < handle
    % Holds the settings for a single Joint Model Personalization task:
    % the marker file, time range, selected markers, and the joints and
    % bodies to personalize.

    properties (Access = public, SetObservable)
        name = "";
        is_enabled = 'true';
        index = 0;
        marker_file_name = "";
        time_range = [0 0];
        marker_names = strings(0, 1);
        JMPJointSet = struct("JMPJoint", []);
        JMPBodySet = struct("JMPBody", []);
        jointNames = strings(0);
        bodyNames = strings(0);
        minTime = 0;
        maxTime = 0;
        markerFileMarkers;
    end

    methods (Access = public)
        function obj = JMPTaskClass() % Empty task constructor
        end

        function struct = toStruct(obj)
            struct.Attributes.name = obj.name;
            struct.is_enabled = obj.is_enabled;
            struct.time_range = obj.time_range;
            struct.marker_file_name = obj.marker_file_name;
            struct.marker_names = obj.marker_names;
            struct.JMPJointSet = obj.JMPJointSet;
            struct.JMPBodySet = obj.JMPBodySet;
        end

        function loadFromStruct(obj, s)
            if isfield(s, 'Attributes') && isfield(s.Attributes, 'name')
                obj.name = s.Attributes.name;
            end
            applyStructToHandle(obj, s);

            joints = {};
            if isfield(s, 'JMPJointSet') && isfield(s.JMPJointSet, 'JMPJoint')
                joints = s.JMPJointSet.JMPJoint;
            end
            % xml2struct yields '' or [] for an empty set and a bare
            % struct for a single entry
            if isempty(joints) || ischar(joints)
                joints = {};
            elseif ~iscell(joints)
                joints = {joints};
            end
            obj.jointNames = strings(0);
            for i = 1 : numel(joints)
                obj.jointNames(end + 1) = joints{i}.Attributes.name;
            end
            if isempty(joints)
                obj.JMPJointSet = struct('JMPJoint', []);
            else
                obj.JMPJointSet.JMPJoint = joints;
            end

            bodies = {};
            if isfield(s, 'JMPBodySet') && isfield(s.JMPBodySet, 'JMPBody')
                bodies = s.JMPBodySet.JMPBody;
            end
            if isempty(bodies) || ischar(bodies)
                bodies = {};
            elseif ~iscell(bodies)
                bodies = {bodies};
            end
            obj.bodyNames = strings(0);
            for i = 1 : numel(bodies)
                obj.bodyNames(end + 1) = bodies{i}.Attributes.name;
            end
            if isempty(bodies)
                obj.JMPBodySet = struct('JMPBody', []);
            else
                obj.JMPBodySet.JMPBody = bodies;
            end
        end
    end
end