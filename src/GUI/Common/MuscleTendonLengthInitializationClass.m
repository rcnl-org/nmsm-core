classdef MuscleTendonLengthInitializationClass < handle
    %MUSCLETENDONLENGTHINITIALIZATION Summary of this class goes here
    %   Detailed explanation goes here

    properties (Access = public, SetObservable)
        is_enabled = 'true';
        passive_data_input_directory = "";
        max_normalized_muscle_fiber_length = 1.0;
        min_normalized_muscle_fiber_length = 0.7;
        optimize_maximum_muscle_stress = 'true';
        optimize_isometric_max_force = 'true';
        optimize_absolute_length_changes = 'true';
        maximum_muscle_stress = 610000;

        costTermStruct = struct( ...
                'passive_joint_moment',                             {{'true'   0     2     false}}, ...
                'optimal_muscle_fiber_length',                      {{'true'   1     0.3   true}}, ...
                'tendon_slack_length',                              {{'true'   1     0.3   true}}, ...
                'minimum_normalized_muscle_fiber_length',           {{'true'   0     0.3   false}}, ...
                'maximum_normalized_muscle_fiber_length',           {{'true'   0     0.03  false}}, ...
                'maximum_muscle_stress',                            {{'true'   1.2   0.1   true}}, ...
                'passive_muscle_force',                             {{'false'  0     10    false}}, ...
                'grouped_normalized_muscle_fiber_length',           {{'true'   0     0.1   false}}, ...
                'grouped_maximum_normalized_muscle_fiber_length',   {{'true'   0     0.1   false}} ...
                );

        RCNLCostTerm = cell(1);
    end

    methods
        function obj = MuscleTendonLengthInitializationClass()
        end

        function s = toStruct(obj)
            s = struct();
            s.is_enabled = obj.is_enabled;
            s.passive_data_input_directory = obj.passive_data_input_directory;
            s.max_normalized_muscle_fiber_length = obj.max_normalized_muscle_fiber_length;
            s.min_normalized_muscle_fiber_length = obj.min_normalized_muscle_fiber_length;
            s.optimize_maximum_muscle_stress = obj.optimize_maximum_muscle_stress;
            s.optimize_isometric_max_force = obj.optimize_isometric_max_force;
            s.maximum_muscle_stress = obj.maximum_muscle_stress;
            s.optimize_absolute_length_changes = obj.optimize_absolute_length_changes;

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
            switch index
                case 1
                    obj.optimize_maximum_muscle_stress = value;
                case 2
                    obj.optimize_isometric_max_force = value;
                case 3
                    obj.optimize_absolute_length_changes = value;
                case 4
                    obj.maximum_muscle_stress = value;
            end
        end

        function value = getParameterValueByIndex(obj, index)
            switch index
                case 1
                    value = obj.optimize_maximum_muscle_stress;
                case 2
                    value = obj.optimize_isometric_max_force;
                case 3
                    value = obj.optimize_absolute_length_changes;
                case 4
                    value = obj.maximum_muscle_stress;
            end
        end
    end
end