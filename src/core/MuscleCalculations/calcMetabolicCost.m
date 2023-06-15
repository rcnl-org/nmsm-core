% This function is part of the NMSM Pipeline, see file for full license.
%
% () -> ()
% 

% ----------------------------------------------------------------------- %
% The NMSM Pipeline is a toolkit for model personalization and treatment  %
% optimization of neuromusculoskeletal models through OpenSim. See        %
% nmsm.rice.edu and the NOTICE file for more information. The             %
% NMSM Pipeline is developed at Rice University and supported by the US   %
% National Institutes of Health (R01 EB030520).                           %
%                                                                         %
% Copyright (c) 2021 Rice University and the Authors                      %
% Author(s): Marleny Vega                                                 %
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

function metabolicCost = calcMetabolicCost(time, statePositions, ...
    muscleActivations, params)
metabolicCost = [];
for indx = 1 : numel(params.costTerms)
    if strcmpi(params.costTerms{indx}.type, 'metabolic_cost_minimization')
        import org.opensim.modeling.*
        model = Model(params.model);
        for i = 1 : params.numMuscles
            controller = PrescribedController();
            controller.addActuator(model.getMuscles().get(params.muscleNames{i}));
            controlFunction = PiecewiseLinearFunction();
            for j = 1:size(muscleActivations, 1)
                controlFunction.addPoint(time(j), muscleActivations(j, i));
            end
            controller.prescribeControlForActuator(params.muscleNames{i}, ...
                controlFunction);
            model.addComponent(controller);
        end
        
        state = model.initSystem();
        for i = 1:size(muscleActivations, 1)
            for j = 1 : size(params.coordinateNames, 2)
                if ~model.getCoordinateSet.get(params.coordinateNames(j)). ....
                        get_locked
                    model.getCoordinateSet.get(params.coordinateNames(j)). ...
                        setValue(state, statePositions(i, j));
                end
            end
            state.setTime(time(i));
            model.realizeDynamics(state);
            model.equilibrateMuscles(state);
            tempTotalCost = model.getProbeSet().get(0).getProbeOutputs(state);
            metabolicCost(i, :) = tempTotalCost.get(0);
        end
    end
end
end