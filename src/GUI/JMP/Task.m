classdef Task < handle
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
        function obj = Task(taskTemplate) % Empty task constructor
            if nargin < 1
                return
            end
            obj.name = taskTemplate.name;
            obj.is_enabled = taskTemplate.is_enabled;
            obj.index = taskTemplate.index;
            obj.marker_file_name = taskTemplate.marker_file_name;
            obj.time_range = taskTemplate.time_range;
            obj.marker_names = taskTemplate.marker_names;
            obj.JMPJointSet = taskTemplate.JMPJointSet;
            obj.JMPBodySet = taskTemplate.JMPBodySet;
            obj.jointNames = taskTemplate.jointNames;
            obj.bodyNames = taskTemplate.bodyNames;
            obj.minTime = taskTemplate.minTime;
            obj.maxTime = taskTemplate.maxTime;
            obj.markerFileMarkers = taskTemplate.markersFileMarkers;

        end
    end
end