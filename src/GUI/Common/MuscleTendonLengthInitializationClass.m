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
        maximum_muscle_stress = 610000;
        optimize_absolute_length_changes = 'true';
        RCNLCostTermSet = struct("RCNLCostTerm", {})
    end

    methods
        function obj = MuscleTendonLengthInitializationClass()
        end
    end
end