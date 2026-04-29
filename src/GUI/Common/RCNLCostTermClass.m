classdef RCNLCostTermClass < handle
    %RCNLCOSTTERMSET Summary of this class goes here
    %   Detailed explanation goes here

    properties (Access = public, SetObservable)
        name = [];
        is_enabled = 'true';
        type = "";
        error_center = 0;
        max_allowable_error = 0;
    end

    methods
        function obj = RCNLCostTermClass()
        end

        function s = toStruct(obj)
            s = struct();
            if ~isempty(obj.name)
                s.Attributes.name = obj.name;
            end
            s.is_enabled = obj.is_enabled;
            s.type = obj.type;
            s.max_allowable_error = obj.max_allowable_error;
            s.error_center = obj.error_center;
        end
    end
end