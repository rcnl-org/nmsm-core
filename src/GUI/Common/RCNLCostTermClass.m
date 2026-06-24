% This class is part of the NMSM Pipeline, see file for full license.
%
% This class represents a single cost term in the NMSM Pipeline GUI,
% storing the term type, enabled state, error center, maximum allowable
% error, and whether the term supports an error center value.

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