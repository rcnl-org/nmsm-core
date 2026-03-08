function SaveJMPSettingsFile(app, fileName)
% load()
settingsTree = makeJMPSettingsStruct(app);
settingsFileStruct.NMSMPipelineDocument.JointModelPersonalizationTool = ...
    settingsTree;
settingsFileStruct.NMSMPipelineDocument.Attributes.Version = '0_dot_1_dot_0';
struct2xml(settingsFileStruct, fileName)
end

function settingsTree = makeJMPSettingsStruct(app)
settingsTree.input_model_file = getRelativePath(app.getInputModelFile(), pwd);
settingsTree.output_model_file = getRelativePath(app.getOutputModelFile(), pwd);
settingsTree.allowable_error = app.getMaxAllowableError();
settingsTree.JMPTaskList = makeJMPTaskListStruct(app);
settingsTree = setOptimizationParams(app, settingsTree);
settingsTree = formatGuiDataForXml(settingsTree);
end

function JMPTaskList = makeJMPTaskListStruct(app)
    taskList = app.getTaskList;
    JMPTaskList = struct();  % Sensitive variable name
    for i = 1 : length(taskList)
        task = taskList{i};  
        task.marker_file_name = getRelativePath(task.marker_file_name, pwd);
        if ~isempty(task.JointSet)
            task.JMPJointSet = struct();  % Sensitive variable name
            task.JMPJointSet.JMPJoint = task.JointSet;  % Sensitive variable name
            task = rmfield(task, "JointSet");
        end
        if ~isempty(task.BodySet)
            task.JMPBodySet = struct();  % Sensitive variable name
            task.JMPBodySet.JMPBody = task.BodySet;  % Sensitive variable name
            task = rmfield(task, "BodySet");
        end
        
        JMPTaskList.JMPTask{i} = task;  % Sensitive variable name
    end
end

function settingsTree = setOptimizationParams(app, settingsTree)
    settingsTree.accuracy = app.accuracy;
    settingsTree.diff_min_change = app.diff_min_change;
    settingsTree.optimality_tolerance = app.optimality_tolerance;
    settingsTree.function_tolerance = app.function_tolerance;
    settingsTree.step_tolerance = app.step_tolerance;
    settingsTree.max_function_evaluations = app.max_function_evaluations;
end