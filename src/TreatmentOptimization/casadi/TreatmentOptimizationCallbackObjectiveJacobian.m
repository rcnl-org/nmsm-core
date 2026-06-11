classdef TreatmentOptimizationCallbackObjectiveJacobian < casadi.Callback
    properties
        inputs
        derivativeDependencies
        numState
        numControl
        numParameter
    end
    methods
        % Construct callback 
        function self = TreatmentOptimizationCallbackObjectiveJacobian( ...
                name, inputs, derivativeDependencies, options)
            self@casadi.Callback();
            self.inputs = inputs;
            self.derivativeDependencies = derivativeDependencies;
            self.numState = numel(self.inputs.guess.phase.state);
            self.numControl = numel(self.inputs.guess.phase.control);
            if isfield(self.inputs.guess.phase, 'parameter')
                self.numParameter = ...
                    numel(self.inputs.guess.phase.parameter);
            else
                self.numParameter = 0;
            end
            if nargin < 4
                options = struct('enable_fd', false);
            end
            construct(self, name, options);
        end

        % Specify input/output counts.
        function v=get_n_in(self)
            % Three input matrices, one extra input (current objective)
            v=4; 
        end
        function v=get_n_out(self)
            % One gradient output for each input matrix
            v=3;
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
                case 2
                    if isfield(self.inputs.guess.phase, 'parameter')
                        res = casadi.Sparsity.dense( ...
                            size(self.inputs.guess.phase.parameter, 1), ...
                            size(self.inputs.guess.phase.parameter, 2));
                    else
                        res = casadi.Sparsity.dense(0, 0);
                    end
                case 3 % 'Current objective' input
                    res = casadi.Sparsity.dense(1, 1);
            end
        end
        % Gradient outputs are flat vectors with a number of values
        % matching their corresponding input matrices.
        function res = get_sparsity_out(self, i)
            switch i
                case 0
                    res = casadi.Sparsity.dense(1, self.numState);
                case 1
                    res = casadi.Sparsity.dense(1, self.numControl);
                case 2
                    res = casadi.Sparsity.dense(1, self.numParameter);
            end
        end

        % Iterative call to use main model function
        function output = eval(self, casadiValues)
            structValues.state = full(casadiValues{1});
            structValues.control = full(casadiValues{2});
            structValues.parameter = full(casadiValues{3});
            currentObjective = full(casadiValues{4});

            stateGradient = zeros(1, self.numState);
            controlGradient = zeros(1, self.numControl);
            parameterGradient = zeros(1, self.numParameter);
            
            % Calculate state gradient
            for i = 1 : numel(structValues.state)
                % Create a copy of the inputs to perturb
                tempValues = structValues;
                % Only calculate the gradient if this is actually a
                % dependency
                if self.derivativeDependencies{1}(i)
                    tempValues.state(i) = tempValues.state(i) + ...
                        self.inputs.casadiObjectiveGradientStepSize;
                    outputs = computeCasadiFiniteDifferenceModelFunction( ...
                        tempValues, self.inputs, self.derivativeDependencies, ...
                        false, true);
                    % Forward finite difference, could easily be replaced
                    % by other methods
                    stateGradient(i) = ...
                        (outputs.objective - currentObjective) / ...
                        self.inputs.casadiObjectiveGradientStepSize;
                else
                    % If this is not a dependency, the gradient is zero
                    stateGradient(i) = 0;
                end
            end

            % Calculate control gradient
            for i = 1 : numel(structValues.control)
                tempValues = structValues;
                if self.derivativeDependencies{2}(i)
                    tempValues.control(i) = tempValues.control(i) + ...
                        self.inputs.casadiObjectiveGradientStepSize;
                    outputs = computeCasadiFiniteDifferenceModelFunction( ...
                        tempValues, self.inputs, self.derivativeDependencies, ...
                        false, true);
                    controlGradient(i) = ...
                        (outputs.objective - currentObjective) / ...
                        self.inputs.casadiObjectiveGradientStepSize;
                else
                    controlGradient(i) = 0;
                end
            end

            % Calculate parameter gradient
            if isfield(self.inputs.guess.phase, 'parameter')
                for i = 1 : numel(structValues.parameter)
                    tempValues = structValues;
                    if self.derivativeDependencies{3}(i)
                        tempValues.parameter(i) = tempValues.parameter(i) + ...
                            self.inputs.casadiObjectiveGradientStepSize;
                        outputs = computeCasadiFiniteDifferenceModelFunction( ...
                            tempValues, self.inputs, self.derivativeDependencies, ...
                        false, true);
                        parameterGradient(i) = ...
                            (outputs.objective - currentObjective) / ...
                            self.inputs.casadiObjectiveGradientStepSize;
                    else
                        parameterGradient(i) = 0;
                    end
                end
            end

            output = {stateGradient, controlGradient, parameterGradient};
        end
    end
end
