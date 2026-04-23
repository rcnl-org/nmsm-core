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
    end
end