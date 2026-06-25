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
    %JMPTASK Summary of this class goes here
    %   Detailed explanation goes here

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
            obj.jointNames = strings(0);
            if isfield(s, 'JMPJointSet') && isfield(s.JMPJointSet, 'JMPJoint') && ...
                    ~(ischar(s.JMPJointSet.JMPJoint) && strcmp(s.JMPJointSet.JMPJoint, ''))
                joints = s.JMPJointSet.JMPJoint;
                if ~iscell(joints); joints = {joints}; end
                for j = 1 : numel(joints)
                    obj.jointNames(end+1) = joints{j}.Attributes.name;
                end
                obj.JMPJointSet.JMPJoint = joints;
            else
                obj.JMPJointSet = struct('JMPJoint', []);
            end
            obj.bodyNames = strings(0);
            if isfield(s, 'JMPBodySet')
                obj.JMPBodySet = s.JMPBodySet;
                if isfield(s.JMPBodySet, 'JMPBody') && ...
                        ~(ischar(s.JMPBodySet.JMPBody) && strcmp(s.JMPBodySet.JMPBody, ''))
                    bodies = s.JMPBodySet.JMPBody;
                    if ~iscell(bodies); bodies = {bodies}; end
                    for j = 1 : numel(bodies)
                        obj.bodyNames(end+1) = bodies{j}.Attributes.name;
                    end
                end
            else
                obj.JMPBodySet = struct('JMPBody', []);
            end
        end
    end
end