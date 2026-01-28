% This class is part of the NMSM Pipeline, see file for full license.
%
% This class represents the data model for a single synergy group within
% the Neural Control Personalization GUI, storing the muscle group name
% and the number of synergies for that group.

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
classdef RCNLSynergyClass < handle

    properties (Access = public, SetObservable)
        muscle_group_name = "";
        num_synergies = 1;
    end

    methods (Access = public)
        function obj = RCNLSynergyClass(s)
            if nargin > 0
                applyStructToHandle(obj, s);
            end
        end

        function s = toStruct(obj)
            s = struct();
            s.muscle_group_name = obj.muscle_group_name;
            s.num_synergies = obj.num_synergies;
        end

        function loadFromStruct(obj, s)
            applyStructToHandle(obj, s);
        end
    end
end
