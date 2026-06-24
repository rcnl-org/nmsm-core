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
                'inverse_dynamics_joint_moment',            {{'true'   0     2.5   false}}, ...
                'activation_time_constant',                 {{'true'   0.02  0.015 true}}, ...
                'activation_nonlinearity_constant',         {{'true'   0     0.1   true}}, ...
                'optimal_muscle_fiber_length',              {{'true'   0     0.1   false}}, ...
                'tendon_slack_length',                      {{'true'   0     0.1   false}}, ...
                'electromechanical_delay',                  {{'true'   0     0.1   true}}, ...
                'electromechanical_delay_deviation',        {{'false'  0.1   0.05  true}}, ...
                'emg_scale_factor',                         {{'true'   0.3   0.2   true}}, ...
                'normalized_muscle_fiber_length',           {{'true'   0     0.01  false}}, ...
                'passive_muscle_force',                     {{'false'  0     50    false}}, ...
                'grouped_normalized_muscle_fiber_length',   {{'true'   0     0.05  false}}, ...
                'grouped_emg_scale_factor',                 {{'true'   0     0.1   false}}, ...
                'grouped_electromechanical_delay',          {{'true'   0     0.2   false}}, ...
                'muscle_excitation_penalty',                {{'true'   0.5   0.25  true}} ...
            );

        RCNLCostTerm = cell(1);
    end

    methods
        function obj = MTPTaskClass()
            % obj.RCNLCostTermSet.
        end

        function s = toStruct(obj)
            s = struct();
            s.Attributes.name = obj.name;
            s.index = obj.index;
            s.is_enabled = obj.is_enabled;
            s.muscle_specific_electromechanical_delays = obj.muscle_specific_electromechanical_delays;
            s.optimize_electromechanical_delays = obj.optimize_electromechanical_delays;
            s.optimize_activation_time_constants = obj.optimize_activation_time_constants;
            s.optimize_activation_nonlinearity_constants = obj.optimize_activation_nonlinearity_constants;
            s.optimize_emg_scale_factors = obj.optimize_emg_scale_factors;
            s.optimize_optimal_fiber_lengths = obj.optimize_optimal_fiber_lengths;
            s.optimize_tendon_slack_lengths = obj.optimize_tendon_slack_lengths;
            n = numel(obj.RCNLCostTerm);
            costTermStructs = cell(1, n);
            for i = 1:n
                if ~isempty(obj.RCNLCostTerm{i})
                    costTermStructs{i} = obj.RCNLCostTerm{i}.toStruct();
                else
                    costTermStructs{i} = [];
                end
            end
            s.RCNLCostTermSet = struct();
            s.RCNLCostTermSet.RCNLCostTerm = costTermStructs;
        end

        function makeDefaultCostTermSet(obj)
            costTermNames = fieldnames(obj.costTermStruct);
            for i = 1 : length(costTermNames)
                costTerm = RCNLCostTermClass();
                costTerm.is_enabled = obj.costTermStruct.(costTermNames{i}){1};
                costTerm.type = costTermNames{i};
                costTerm.error_center = obj.costTermStruct.(costTermNames{i}){2};
                costTerm.max_allowable_error = obj.costTermStruct.(costTermNames{i}){3};
                costTerm.uses_error_center = obj.costTermStruct.(costTermNames{i}){4};
                obj.RCNLCostTerm{i} = costTerm;
            end
        end

        function setParameterValueByIndex(obj, index, value)
            % This function is needed because ideally I could store these
            % values in an array, but struct2xml requires that I have the
            % fields of the struct be the xml elements, therefore I need to
            % individually assign these values like this.
            switch index
                case 1
                    obj.muscle_specific_electromechanical_delays = value;
                case 2
                    obj.optimize_electromechanical_delays = value;
                case 3
                    obj.optimize_activation_time_constants = value;
                case 4
                    obj.optimize_activation_nonlinearity_constants = value;
                case 5
                    obj.optimize_emg_scale_factors = value;
                case 6
                    obj.optimize_optimal_fiber_lengths = value;
                case 7
                    obj.optimize_tendon_slack_lengths = value;
            end
        end

        function value = getParameterValueByIndex(obj, index)
            switch index
                case 1
                    value = obj.muscle_specific_electromechanical_delays;
                case 2
                    value = obj.optimize_electromechanical_delays;
                case 3
                    value = obj.optimize_activation_time_constants;
                case 4
                    value = obj.optimize_activation_nonlinearity_constants;
                case 5
                    value = obj.optimize_emg_scale_factors;
                case 6
                    value = obj.optimize_optimal_fiber_lengths;
                case 7
                    value = obj.optimize_tendon_slack_lengths;
            end
        end
    end
end