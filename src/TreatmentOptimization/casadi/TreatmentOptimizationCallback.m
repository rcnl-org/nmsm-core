classdef TreatmentOptimizationCallback < casadi.Callback
    properties
        inputs
        derivativeDependencies
        casadiDependencies
    end
    methods
        % Construct callback with optional struct input for callback
        % options, such as how to calculate derivatives. 
        function self = TreatmentOptimizationCallback(name, inputs, ...
                derivativeDependencies, casadiDependencies, options)
            self@casadi.Callback();
            self.inputs = inputs;
            self.derivativeDependencies = derivativeDependencies;
            self.casadiDependencies = casadiDependencies;
            if nargin < 4
                options = struct();
            end
            construct(self, name, options);
        end

        % Specify input/output counts.
        function v=get_n_in(self)
            v=2;
        end
        function v=get_n_out(self)
            v=4;
        end

        % Return sparsity patterns (shapes of dense matrices in this case)
        % of expected inputs and outputs. This function will be called
        % indexing from zero. 
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

        % Return expected Jacobian sparsity pattern for each output/input
        % combination. This function will be called indexing from zero. 
        function res = get_jac_sparsity(self, oind, iind, ~)
            res = self.casadiDependencies{oind + 1, iind + 1};
        end
        
        % Tell CasADi where it has Jacobian sparsity patterns to use.
        function res = has_jac_sparsity(self, oind, iind)
            res = ~isempty(self.casadiDependencies{oind+1, iind+1});
        end

%         % Tell CasADi to use provided Jacobian calculations
%         function res = has_jacobian(self)
%             res = true;
%         end

        % Iterative call to use main model function
        function output = eval(self, casadiValues)
            structValues.state = full(casadiValues{1});
            structValues.control = full(casadiValues{2});

            outputs = computeCasadiModelFunction(structValues, ...
                self.inputs);

            output = {outputs.dynamics, outputs.path, outputs.terminal, ...
                outputs.objective};
        end
    end
end
