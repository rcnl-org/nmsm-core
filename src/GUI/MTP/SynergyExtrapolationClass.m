classdef SynergyExtrapolationClass < handle
    %SYNERGYEXTRAPOLATION Summary of this class goes here
    %   Detailed explanation goes here

    properties (Access = public, SetObservable)
        is_enabled = 'true';
        matrix_factorization_method = 'PCA';
        number_of_synergies = 0;
        synergy_extrapolation_categorization = 'trial';
        residual_categorization = 'task';

        costTermStruct = struct( ...
                'measured_inverse_dynamics_joint_moment',   {{'true'   0  2}}, ...
                'extrapolated_muscle_activation',           {{'true'   0  0.5}}, ...
                'residual_muscle_activation',               {{'true'   0  0.01}} ...
                );

        RCNLCostTerm = cell(1);
    end

    methods
        function obj = SynergyExtrapolationClass()
        end

        function s = toStruct(obj)
            s = struct();
            s.is_enabled = obj.is_enabled;
            s.matrix_factorization_method = obj.matrix_factorization_method;
            s.number_of_synergies = obj.number_of_synergies;
            s.synergy_extrapolation_categorization = obj.synergy_extrapolation_categorization;
            s.residual_categorization = obj.residual_categorization;

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
                obj.RCNLCostTerm{i} = costTerm;
            end
        end

        function setParameterValueByIndex(obj, index, value)
            switch index
                case 1
                    obj.matrix_factorization_method = value;
                case 2
                    obj.synergy_extrapolation_categorization = value;
                case 3
                    obj.residual_categorization = value;
            end
        end

        function value = getParameterValueByIndex(obj, index)
            switch index
                case 1
                    value = obj.matrix_factorization_method;
                case 2
                    value = obj.synergy_extrapolation_categorization;
                case 3
                    value = obj.residual_categorization;
            end
        end
    end
end