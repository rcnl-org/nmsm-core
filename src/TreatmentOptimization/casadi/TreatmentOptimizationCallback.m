classdef TreatmentOptimizationCallback < casadi.Callback
    properties
        inputs
    end
    methods
        function self = TreatmentOptimizationCallback(name, inputs, options)
            self@casadi.Callback();
            self.inputs = inputs;
            if nargin < 3
                options = struct();
            end
            construct(self, name, options);
        end

        function v=get_n_in(self)
            v=2;
        end
        function v=get_n_out(self)
            v=4;
        end

        function res = get_sparsity_in(self, i)
            switch i
                case 0
                    res = casadi.Sparsity.dense( ...
                        size(self.inputs.guess.phase.state, 1), ...
                        size(self.inputs.guess.phase.state, 2));
                case 1
                    res = casadi.Sparsity.dense( ...
                        size(self.inputs.guess.phase.control, 1), ...
                        size(self.inputs.guess.phase.control, 2));
            end
        end
        function res = get_sparsity_out(self, i)
            switch i
                case 0
                    res = casadi.Sparsity.dense( ...
                        size(self.inputs.initialOutputs.dynamics, 1), ...
                        size(self.inputs.initialOutputs.dynamics, 2));
                case 1
                    res = casadi.Sparsity.dense( ...
                        size(self.inputs.initialOutputs.path, 1), ...
                        size(self.inputs.initialOutputs.path, 2));
                case 2
                    res = casadi.Sparsity.dense( ...
                        size(self.inputs.initialOutputs.terminal, 1), ...
                        size(self.inputs.initialOutputs.terminal, 2));
                case 3
                    res = casadi.Sparsity.dense( ...
                        size(self.inputs.initialOutputs.objective, 1), ...
                        size(self.inputs.initialOutputs.objective, 2));
            end
        end

        function output = eval(self, casadiValues)
            state = casadiValues{1};
            control = casadiValues{2};
            structValues.state = state.to_double;
            structValues.control = control.to_double;

            outputs = computeCasadiModelFunction(structValues, ...
                self.inputs);

            output = {outputs.dynamics, outputs.path, outputs.terminal, ...
                outputs.objective};
        end
    end
end
