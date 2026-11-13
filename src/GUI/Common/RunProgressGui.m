% This class is part of the NMSM Pipeline, see file for full license.
%
% This class shows a progress dialog on a tool's window while the tool
% runs. The tools take it as their optional app argument and it answers the
% calls they make on it: updateRunStageGui shows each stage's message,
% CancelOptimizationGui and isRunCancelled report the dialog's Cancel
% button, and updateTaskProgress (through updateRunTaskGui) names the task
% under way.
%
% RunProgressGui.run(figure, title, shortName, stageMessages, runFcn,
% plotFcn, cancelable) runs a tool and plots its results under the dialog,
% then reports how the run ended in an alert. stageMessages maps each stage
% label name the tool uses to the message shown for it.
%
% (Figure, string, struct, logical) -> (RunProgressGui)
% Shows a tool's run progress in a dialog on its window

% ----------------------------------------------------------------------- %
% The NMSM Pipeline is a toolkit for model personalization and treatment  %
% optimization of neuromusculoskeletal models through OpenSim. See        %
% nmsm.rice.edu and the NOTICE file for more information. The             %
% NMSM Pipeline is developed at Rice University and supported by the US   %
% National Institutes of Health (R01 EB030520).                           %
%                                                                         %
% Copyright (c) 2026 Rice University and the Authors                      %
% Author(s): Robert Salati                                                %
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

classdef RunProgressGui < handle

    properties (Access = private)
        dialog
        stageMessages struct
        % The stages turned on and not yet off, innermost last. GCP
        % initializes inside its running stage, for example.
        activeStages string = strings(0, 1)
        % The innermost active stage's message, which task and cancel
        % lines are added under
        stageMessage string = ""
        cancelShown logical = false
    end

    methods (Static)

        % Runs a tool, then plots its results, with the dialog up
        % throughout. A failed run is reported with its error. A failed
        % plot is not a failed run, since the results are already saved,
        % so it is only noted in the alert.
        function run(fig, title, shortName, stageMessages, runFcn, ...
                plotFcn, cancelable)
            progress = RunProgressGui(fig, title, stageMessages, cancelable);
            try
                runFcn(progress);
            catch exception
                delete(progress);
                fprintf(2, '%s\n', getReport(exception));
                uialert(fig, exception.message, shortName + " Failed");
                return
            end
            % The optimizers return the iterate they stopped on and the
            % tools save it, so a cancelled run is still plotted
            cancelled = progress.isRunCancelled();
            progress.setStage('PlottingResultsLabel', 'on');
            plotProblem = "";
            try
                plotFcn();
            catch exception
                plotProblem = string(exception.message);
            end
            delete(progress);
            if cancelled
                message = shortName + " Cancelled.";
            else
                message = shortName + " Completed.";
            end
            icon = 'success';
            if cancelled || plotProblem ~= ""
                icon = 'warning';
            end
            if plotProblem ~= ""
                message = message + newline + newline + "The results " + ...
                    "were saved, but plotting them failed:" + newline + ...
                    plotProblem;
            end
            uialert(fig, message, title, 'Icon', icon);
        end
    end

    methods

        % Every run starts by parsing its settings file
        function obj = RunProgressGui(fig, title, stageMessages, cancelable)
            obj.stageMessages = stageMessages;
            obj.activeStages = "ParsingLabel";
            if isfield(stageMessages, 'ParsingLabel')
                obj.stageMessage = stageMessages.ParsingLabel;
            end
            obj.dialog = uiprogressdlg(fig, 'Title', title, ...
                'Message', obj.stageMessage, 'Indeterminate', 'on', ...
                'Cancelable', cancelable);
        end

        % Called through updateRunStageGui. A stage turning off goes back
        % to the stage it ran inside, or leaves its message up until the
        % next one starts if there is none.
        function setStage(obj, labelName, state)
            if ~isfield(obj.stageMessages, labelName)
                return
            end
            labelName = string(labelName);
            obj.activeStages(obj.activeStages == labelName) = [];
            if matlab.lang.OnOffSwitchState(state)
                obj.activeStages(end + 1) = labelName;
            end
            if isempty(obj.activeStages)
                return
            end
            message = obj.stageMessages.(obj.activeStages(end));
            if message ~= obj.stageMessage
                obj.stageMessage = message;
                obj.show(message);
            end
        end

        % The optimizers' OutputFcn, looked up by name by the tools
        function stop = CancelOptimizationGui(obj, ~, ~, ~)
            drawnow
            stop = obj.isRunCancelled();
            if stop && ~obj.cancelShown
                obj.cancelShown = true;
                obj.show(obj.stageMessage + newline + "Cancelling...");
            end
        end

        % Read by the tools between stages and rounds
        function cancelled = isRunCancelled(obj)
            cancelled = isvalid(obj.dialog) && obj.dialog.CancelRequested;
        end

        % Called through updateRunTaskGui as each JMP, MTP or GCP task
        % starts. The bar keeps sweeping, as tasks can differ greatly in
        % length.
        function updateTaskProgress(obj, task, taskCount)
            obj.show(obj.stageMessage + newline + "Task " + task + ...
                " of " + taskCount);
        end

        function delete(obj)
            if ~isempty(obj.dialog) && isvalid(obj.dialog)
                delete(obj.dialog);
            end
        end
    end

    methods (Access = private)

        function show(obj, message)
            if ~isvalid(obj.dialog)
                return
            end
            obj.dialog.Message = message;
            drawnow
        end
    end
end
