classdef RCNLCostTermClass < handle
    %RCNLCOSTTERMSET Summary of this class goes here
    %   Detailed explanation goes here

    properties (Access = public, SetObservable)
        name = [];
        is_enabled = 'true';
        type = "";
        error_center = 0;
        max_allowable_error = 0;
        uses_error_center = true;
    end

    methods
        function obj = RCNLCostTermClass(s)
            if nargin == 0
                return
            end
            if isfield(s, "Attributes")
                obj.name = s.Attributes.name;
            end
            obj.is_enabled = s.is_enabled;
            obj.type = s.type;
            obj.max_allowable_error = s.max_allowable_error;
            if isfield(s, 'error_center')
                obj.error_center = s.error_center;
                obj.uses_error_center = true;
            else
                obj.uses_error_center = false;
            end
        end

        function s = toStruct(obj)
            s = struct();
            if ~isempty(obj.name)
                s.Attributes.name = obj.name;
            end
            s.is_enabled = obj.is_enabled;
            s.type = obj.type;
            s.max_allowable_error = obj.max_allowable_error;
            if obj.uses_error_center
                s.error_center = obj.error_center;
            end
        end
    end
end