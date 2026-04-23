classdef MTPTaskClass < handle
    %MTPTASKCLASS Summary of this class goes here
    %   Detailed explanation goes here

    properties
        name = "";
        index = 0;
        is_enabled = 'true';
        muscle_specific_electromechanical_delays = 'true';
        optimize_electromechanical_delays = 'true';
        optimize_activation_time_constants = 'true';
        optimize_activation_nonlinearity_constants = 'true';
        optimize_emg_scale_factors = 'true';
        optimize_optimal_fiber_lengths = 'true';
        optimize_tendon_slack_lengths = 'true';
        costTermStruct = struct( ...
                'inverse_dynamics_joint_moment',            {{'true'   0     2.5}}, ...
                'activation_time_constant',                 {{'true'   0.02  0.015}}, ...
                'activation_nonlinearity_constant',         {{'true'   0     0.1}}, ...
                'optimal_muscle_fiber_length',              {{'true'   0     0.1}}, ...
                'tendon_slack_length',                      {{'true'   0     0.1}}, ...
                'emg_scale_factor',                         {{'true'   0.3   0.2}}, ...
                'normalized_muscle_fiber_length',           {{'true'   0     0.01}}, ...
                'passive_muscle_force',                     {{'false'  0     50}}, ...
                'grouped_normalized_muscle_fiber_length',   {{'true'   0     0.05}}, ...
                'grouped_emg_scale_factor',                 {{'true'   0     0.1}}, ...
                'grouped_electromechanical_delay',          {{'true'   0     0.2}}, ...
                'muscle_excitation_penalty',                {{'true'   0.5   0.25}} ...
            );

        RCNLCostTerm = cell(1);
        RCNLCostTermSet = struct("RCNLCostTerm", []);
    end

    methods
        function obj = MTPTaskClass()
            % obj.RCNLCostTermSet.
        end

        function struct = toStruct(obj)
        end

        function makeDefaultCostTermSet(obj)
            costTermNames = fieldnames(obj.costTermStruct);
            for i = 1 : length(costTermNames)
                costTerm = RCNLCostTermClass();
                costTerm.is_enabled = obj.costTermStruct.(costTermNames{i}){1};
                costTerm.type = costTermNames{i};
                costTerm.error_center = obj.costTermStruct.(costTermNames{i}){2};
                costTerm.max_allowable_error = obj.costTermStruct.(costTermNames{i}){3};
                obj.RCNLCostTerm{i} = costTerm;
            end
            obj.RCNLCostTermSet.RCNLCostTerm = obj.RCNLCostTerm;
        end
    end
end