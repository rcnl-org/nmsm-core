classdef RCNLCostTermClass < handle
    %RCNLCOSTTERMSET Summary of this class goes here
    %   Detailed explanation goes here

    properties (Access = public, SetObservable)
        name = "";
        is_enabled = 'true';
        type = "";
        error_center = 0;
        max_allowable_error = 0;
    end

    methods
        function obj = RCNLCostTermClass()
        end

        function struct = toStruct(obj)
            struct.Attributes.name = obj.name;
            struct.is_enabled = obj.is_enabled;
            struct.type = obj.type;
            struct.max_allowable_error = obj.max_allowable_error;
            struct.error_center = obj.error_center;
        end
    end
end