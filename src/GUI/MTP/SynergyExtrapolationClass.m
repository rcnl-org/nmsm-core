classdef SynergyExtrapolationClass < handle
    %SYNERGYEXTRAPOLATION Summary of this class goes here
    %   Detailed explanation goes here

    properties (Access = public, SetObservable)
        is_enabled = 'true';
        matrix_factorization_method = 'PCA';
        number_of_synergies = 0;
        synergy_extrapolation_categorization = 'trial';
        residual_categorization = 'task';
        RCNLCostTermSet = struct("RCNLCostTerm", {})
    end

    methods
        function obj = SynergyExtrapolationClass()
        end
    end
end