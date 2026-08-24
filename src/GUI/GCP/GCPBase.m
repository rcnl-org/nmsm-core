classdef GCPBase < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure                       matlab.ui.Figure
        ResetButton                    matlab.ui.control.Button
        RunButton                      matlab.ui.control.Button
        HelpButton                     matlab.ui.control.Button
        SaveButton                     matlab.ui.control.Button
        LoadSettingsFileButton         matlab.ui.control.Button
        RcnlLogo                       matlab.ui.control.Image
        InputsButton                   matlab.ui.control.Button
        ContactSurfacesButton          matlab.ui.control.Button
        GCPTasksButton                 matlab.ui.control.Button
        AdvancedButton                 matlab.ui.control.Button
        GcpImage                       matlab.ui.control.Image
        Mask1                          matlab.ui.control.Image
        TabGroup                       matlab.ui.container.TabGroup
        InputsTab                      matlab.ui.container.Tab
        InputForceFileLabel            matlab.ui.control.Label
        InputForceFileEditField        matlab.ui.control.EditField
        InputForceFileSearchButton     matlab.ui.control.Button
        InputForceFileStatus           matlab.ui.control.Image
        InputMotionFileLabel           matlab.ui.control.Label
        GCPResultsDirectoryStatus      matlab.ui.control.Image
        GCPResultsDirectoryEditField   matlab.ui.control.EditField
        GCPResultsDirectoryEditFieldLabel  matlab.ui.control.Label
        GCPResultsDirectorySearchButton  matlab.ui.control.Button
        InputMotionFileStatus          matlab.ui.control.Image
        InputMotionFileEditField       matlab.ui.control.EditField
        InputMotionFileSearchButton    matlab.ui.control.Button
        InputOsimxFileStatus           matlab.ui.control.Image
        InputOsimxFileEditField        matlab.ui.control.EditField
        InputOsimxFileEditFieldLabel   matlab.ui.control.Label
        InputOsimxFileSearchButton     matlab.ui.control.Button
        InputModelFileStatus           matlab.ui.control.Image
        InputModelFileEditField        matlab.ui.control.EditField
        InputModelFileEditFieldLabel   matlab.ui.control.Label
        InputModelFileSearchButton     matlab.ui.control.Button
        ContactSurfacesTab             matlab.ui.container.Tab
        MidfootSuperiorMarkerStatus    matlab.ui.control.Image
        LateralMarkerStatus            matlab.ui.control.Image
        HeelMarkerStatus               matlab.ui.control.Image
        MedialMarkerStatus             matlab.ui.control.Image
        ToeMarkerStatus                matlab.ui.control.Image
        HindfootBodyStatus             matlab.ui.control.Image
        ElectricalCenterColumnsStatus  matlab.ui.control.Image
        MomentColumnsStatus            matlab.ui.control.Image
        ForceColumnsStatus             matlab.ui.control.Image
        TimeRangeStatus                matlab.ui.control.Image
        GridHeightEditField            matlab.ui.control.NumericEditField
        GridHeightEditFieldLabel       matlab.ui.control.Label
        GridWidthEditField             matlab.ui.control.NumericEditField
        GridWidthEditFieldLabel        matlab.ui.control.Label
        MidfootSuperiorMarkerDropDown  matlab.ui.control.DropDown
        MidfootSuperiorMarkerLabel     matlab.ui.control.Label
        HeelMarkerDropDown             matlab.ui.control.DropDown
        HeelMarkerDropDownLabel        matlab.ui.control.Label
        LateralMarkerDropDown          matlab.ui.control.DropDown
        LateralMarkerDropDownLabel     matlab.ui.control.Label
        MedialMarkerDropDown           matlab.ui.control.DropDown
        MedialMarkerLabel              matlab.ui.control.Label
        ToeMarkerDropDown              matlab.ui.control.DropDown
        ToeMarkerDropDownLabel         matlab.ui.control.Label
        HindfootBodyDropDown           matlab.ui.control.DropDown
        HindfootBodyNameLabel          matlab.ui.control.Label
        ForceColumnsDropDown_3         matlab.ui.control.DropDown
        ForceColumnsDropDown_2         matlab.ui.control.DropDown
        MomentColumnsDropDown_3        matlab.ui.control.DropDown
        MomentColumnsDropDown_2        matlab.ui.control.DropDown
        ElectricalCenterColumnsDropDown_3  matlab.ui.control.DropDown
        ElectricalCenterColumnsDropDown_2  matlab.ui.control.DropDown
        ElectricalCenterColumnsDropDown  matlab.ui.control.DropDown
        ElectricalCenterColumnsDropDownLabel  matlab.ui.control.Label
        MomentColumnsDropDown          matlab.ui.control.DropDown
        MomentColumnsLabel             matlab.ui.control.Label
        ForceColumnsDropDown           matlab.ui.control.DropDown
        ForceColumnsLabel              matlab.ui.control.Label
        BeltSpeedEditField             matlab.ui.control.NumericEditField
        BeltSpeedEditFieldLabel        matlab.ui.control.Label
        EndTimeEditField               matlab.ui.control.NumericEditField
        EndTimeEditFieldLabel          matlab.ui.control.Label
        StartTimeEditField             matlab.ui.control.NumericEditField
        StartTimeEditFieldLabel        matlab.ui.control.Label
        IsLeftFootCheckBox             matlab.ui.control.CheckBox
        ContactSurfacesStatus          matlab.ui.control.Image
        ContactSurfacesTable           matlab.ui.control.Table
        ContactSurfacesLabel           matlab.ui.control.Label
        GCPTasksTab                    matlab.ui.container.Tab
        NeighborStandardDeviationEditField  matlab.ui.control.NumericEditField
        NeighborStandardDeviationEditFieldLabel  matlab.ui.control.Label
        DesignVariablesStatus          matlab.ui.control.Image
        CostTermsStatus                matlab.ui.control.Image
        TasksStatus                    matlab.ui.control.Image
        MoveTaskDownButton             matlab.ui.control.Button
        MoveTaskUpButton               matlab.ui.control.Button
        TasksTable                     matlab.ui.control.Table
        TasksLabel                     matlab.ui.control.Label
        DesignVariablesTable           matlab.ui.control.Table
        EditDesignVariablesLabel       matlab.ui.control.Label
        EditCostTermsLabel             matlab.ui.control.Label
        CostTermPanel                  matlab.ui.container.Panel
        CostTermsTable                 matlab.ui.control.Table
        ErrorCenterEditField           matlab.ui.control.NumericEditField
        ErrorCenterEditField_2Label    matlab.ui.control.Label
        MaxAllowableErrorEditField     matlab.ui.control.NumericEditField
        MaxAllowableErrorEditField_2Label  matlab.ui.control.Label
        AdvancedTab                    matlab.ui.container.Tab
        AdvancedSettingsStatus         matlab.ui.control.Image
        AdvancedSettingsTable          matlab.ui.control.Table
        GroundContactModelPersonalizationToolLabel  matlab.ui.control.Label
        ContactSurfaceContextMenu      matlab.ui.container.ContextMenu
        RenameContactSurfaceMenu       matlab.ui.container.Menu
        DeleteContactSurfaceMenu       matlab.ui.container.Menu
        TaskContextMenu                matlab.ui.container.ContextMenu
        RenameTaskMenu                 matlab.ui.container.Menu
        DeleteTaskMenu                 matlab.ui.container.Menu
    end


    properties (Access = private, SetObservable)
        % Parsed out of the input files rather than typed by the user.
        model_markers string = [];
        model_bodies string = [];
        % The body each marker sits on, index for index with
        % model_markers, and the parent and child body of every joint.
        % Together they pick out the markers on a given foot.
        model_marker_bodies string = [];
        model_joint_parents string = [];
        model_joint_children string = [];
        grf_labels string = [];
        % [first last] time in the ground reaction force file, which is
        % the default time range for a contact surface.
        grf_time_range double = [];

        input_model_file string = "";
        input_osimx_file string = "";
        input_motion_file string = "";
        input_grf_file string = "";
        results_directory string = "";

        % Tool level rather than per surface, but shown on the Contact
        % Surfaces tab because that is where they take effect.
        grid_width double = 5;
        grid_height double = 15;

        GCPContactSurface cell = cell(0)
        contactSurfaceIndex double = 1;

        GCPTask cell = cell(0)
        taskIndex double = 1;

        advancedSettingValues string = [];

        currentSettingsFile string = "";

        % Error checking and flow control
        inputModelValid logical = false
        inputMotionFileValid logical = false
        inputGrfFileValid logical = false
        resultsDirectoryValid logical = false
        contactSurfacesValid logical = false
        tasksValid logical = false
        advancedSettingsValid logical = true
    end

    properties (Constant, Access = private)
        % The model properties holding a file or directory path. They
        % load through loadPaths rather than applySettingsStruct, which
        % would assign them before their spaces are rejoined.
        settingsPathFields = ...
            ["results_directory"
            "input_model_file"
            "input_osimx_file"
            "input_motion_file"
            "input_grf_file"]

        % Contact surface name fields, in the order their dropdowns and
        % status icons are listed by markerDropDowns and
        % markerStatusIcons. The first is checked against the model's
        % bodies and the rest against its markers.
        markerFieldNames = ...
            ["hindfoot_body"
            "toe_marker"
            "medial_marker"
            "lateral_marker"
            "heel_marker"
            "midfoot_superior_marker"]

        markerFieldLabels = ...
            ["Hindfoot body"
            "Toe marker"
            "Medial marker"
            "Lateral marker"
            "Heel marker"
            "Midfoot superior marker"]

        columnFieldNames = ...
            ["force_columns"
            "moment_columns"
            "electrical_center_columns"]

        columnFieldLabels = ...
            ["Force columns"
            "Moment columns"
            "Electrical center columns"]

        % Every tool level setting that has no widget of its own. The
        % three arrays are index parallel, and each name is literally the
        % XML element name, so setOptimizationParams can write them out
        % without a lookup table.
        advancedSettingNames = ...
            ["kinematics_filter_cutoff"
            "initialize_resting_spring_length"
            "parse_initial_guess_from_osimx"
            "initial_resting_spring_length"
            "initial_spring_constant"
            "initial_damping_factor"
            "initial_dynamic_friction_coefficient"
            "initial_viscous_friction_coefficient"
            "latching_velocity"
            "diff_min_change"
            "step_tolerance"
            "optimality_tolerance"
            "function_tolerance"
            "max_iterations"
            "max_function_evaluations"]

        % These are the parser's own fallbacks, not the values the XML
        % reference file's comments advertise; several of those are
        % stale (it claims 1e-16 for step_tolerance and 1e3 for
        % max_iterations, and writes 1 for initial_damping_factor).
        %
        % Held as text, not doubles, because two of them are booleans
        % and getBooleanLogicFromField compares against the literal
        % string 'true' - a numeric 1 would read as false, silently.
        defaultAdvancedSettingValues = ...
            ["6"
            "true"
            "false"
            "0.05"
            "2500"
            "1e-4"
            "0"
            "5"
            "0.05"
            "1e-6"
            "1e-6"
            "1e-6"
            "1e-6"
            "400"
            "300000"]

        % validateAdvancedSettingsGui cannot be reused here: it rejects
        % everything <= 0, which is wrong for the two friction
        % coefficients (initial_dynamic_friction_coefficient defaults to
        % 0), and JMP, MTP, NCP, and TO all depend on that rule.
        advancedSettingKinds = ...
            ["positive"
            "boolean"
            "boolean"
            "positive"
            "positive"
            "positive"
            "nonnegative"
            "nonnegative"
            "positive"
            "positive"
            "positive"
            "positive"
            "positive"
            "positiveInteger"
            "positiveInteger"]
    end

    properties (Access = private)  % listener handles
        inputModelFileListener
        inputOsimxFileListener
        inputMotionFileListener
        inputGrfFileListener
        resultsDirectoryListener
        modelMarkersListener
        modelBodiesListener
        grfLabelsListener
        grfTimeRangeListener
        contactSurfaceListener
        contactSurfaceIndexListener
        gridWidthListener
        gridHeightListener
        taskListener
        taskIndexListener
        advancedSettingsListener
        selectedTabListener
    end

    methods (Access = private) % listener methods

        function makeAllListeners(app)
            app.inputModelFileListener = addlistener(app, ...
                'input_model_file', 'PostSet', ...
                @(src, event)updateInputModelFile(app));
            app.inputOsimxFileListener = addlistener(app, ...
                'input_osimx_file', 'PostSet', ...
                @(src, event)updateInputOsimxFile(app));
            app.inputMotionFileListener = addlistener(app, ...
                'input_motion_file', 'PostSet', ...
                @(src, event)updateInputMotionFile(app));
            app.inputGrfFileListener = addlistener(app, ...
                'input_grf_file', 'PostSet', ...
                @(src, event)updateInputGrfFile(app));
            app.resultsDirectoryListener = addlistener(app, ...
                'results_directory', 'PostSet', ...
                @(src, event)updateResultsDirectory(app));
            app.modelMarkersListener = addlistener(app, ...
                'model_markers', 'PostSet', ...
                @(src, event)updateContactSurfaceDropDownItems(app));
            app.modelBodiesListener = addlistener(app, ...
                'model_bodies', 'PostSet', ...
                @(src, event)updateContactSurfaceDropDownItems(app));
            app.grfLabelsListener = addlistener(app, ...
                'grf_labels', 'PostSet', ...
                @(src, event)updateContactSurfaceDropDownItems(app));
            app.grfTimeRangeListener = addlistener(app, ...
                'grf_time_range', 'PostSet', ...
                @(src, event)updateContactSurfaceDefaultTimes(app));
            app.contactSurfaceListener = addlistener(app, ...
                'GCPContactSurface', 'PostSet', ...
                @(src, event)updateContactSurfaceList(app));
            app.contactSurfaceIndexListener = addlistener(app, ...
                'contactSurfaceIndex', 'PostSet', ...
                @(src, event)updateContactSurfaceIndex(app));
            app.gridWidthListener = addlistener(app, 'grid_width', ...
                'PostSet', @(src, event)updateGridWidth(app));
            app.gridHeightListener = addlistener(app, 'grid_height', ...
                'PostSet', @(src, event)updateGridHeight(app));
            app.taskListener = addlistener(app, 'GCPTask', 'PostSet', ...
                @(src, event)updateTaskList(app));
            app.taskIndexListener = addlistener(app, 'taskIndex', ...
                'PostSet', @(src, event)updateTaskIndex(app));
            app.advancedSettingsListener = addlistener(app, ...
                'advancedSettingValues', 'PostSet', ...
                @(src, event)refreshAdvancedSettingsTable(app));
            app.selectedTabListener = addlistener(app.TabGroup, ...
                'SelectedTab', 'PostSet', ...
                @(src, event)formatTabButtons(app));
        end

        function updateInputModelFile(app)
            app.InputModelFileEditField.Value = ...
                getRelativePath(app.input_model_file);
            app.validateInputModelFile();
            % The .osimx is only meaningful against a model, so it has to
            % be rechecked whenever the model changes.
            app.validateInputOsimxFile();
            app.updateRunButton();
        end

        function updateInputOsimxFile(app)
            app.InputOsimxFileEditField.Value = ...
                getRelativePath(app.input_osimx_file);
            app.validateInputOsimxFile();
            app.updateRunButton();
        end

        function updateInputMotionFile(app)
            app.InputMotionFileEditField.Value = ...
                getRelativePath(app.input_motion_file);
            app.validateInputMotionFile();
            app.updateRunButton();
        end

        function updateInputGrfFile(app)
            app.InputForceFileEditField.Value = ...
                getRelativePath(app.input_grf_file);
            app.validateInputGrfFile();
            app.updateRunButton();
        end

        function updateResultsDirectory(app)
            app.GCPResultsDirectoryEditField.Value = ...
                getRelativePath(app.results_directory);
            app.validateResultsDirectory();
            app.updateRunButton();
        end

        function updateContactSurfaceList(app)
            updateTaskListTableGui(app.ContactSurfacesTable, ...
                app.GCPContactSurface, "[+] Add new");
            app.updateContactSurfacePanel();
            app.validateContactSurfaces();
        end

        function updateContactSurfaceDefaultTimes(app)
            % A surface whose times the user has not touched follows the
            % ground reaction force file, so picking a trial fills the
            % time range in rather than leaving the class defaults.
            changed = false;
            for i = 1 : length(app.GCPContactSurface)
                surface = app.GCPContactSurface{i};
                if ~surface.timeRangeIsDefault
                    continue
                end
                app.applyDefaultTimeRange(surface);
                changed = true;
            end
            if changed
                app.updateContactSurfacePanel();
                app.validateContactSurfaces();
            end
        end

        function updateContactSurfaceIndex(app)
            app.ContactSurfacesTable.Selection = app.contactSurfaceIndex;
            app.updateContactSurfacePanel();
            app.validateContactSurfaces();
        end

        function updateGridWidth(app)
            app.GridWidthEditField.Value = app.grid_width;
        end

        function updateGridHeight(app)
            app.GridHeightEditField.Value = app.grid_height;
        end

        function updateTaskList(app)
            updateTaskListTableGui(app.TasksTable, app.GCPTask, ...
                "Add a new task");
            app.updateTaskPanel();
            app.validateTasks();
        end

        function updateTaskIndex(app)
            app.TasksTable.Selection = app.taskIndex;
            app.updateTaskPanel();
            app.validateTasks();
        end

        function refreshAdvancedSettingsTable(app)
            if numel(app.advancedSettingValues) ~= ...
                    numel(app.advancedSettingNames)
                return
            end
            Options = app.advancedSettingNames;
            % Rendered as the stored text rather than through
            % formatGuiNumber, which is sprintf('%.3g') and would print
            % character codes for 'true'.
            Values = app.advancedSettingValues;
            app.AdvancedSettingsTable.Data = table(Options, Values);
            app.validateAdvancedSettings();
            app.updateRunButton();
        end

        function formatTabButtons(app)
            % SelectedTab also fires while the figure is being torn down.
            if ~isvalid(app) || ~isvalid(app.TabGroup)
                return
            end
            updateTabButtonStyles(app.TabGroup.SelectedTab, ...
                [app.InputsTab, app.ContactSurfacesTab, ...
                app.GCPTasksTab, app.AdvancedTab], ...
                [app.InputsButton, app.ContactSurfacesButton, ...
                app.GCPTasksButton, app.AdvancedButton]);
        end
    end

    methods (Access = private) % helpers

        function validateInputModelFile(app)
            app.inputModelValid = validateRequiredFieldGui( ...
                app.input_model_file, "Input model file is required.", ...
                app.InputModelFileEditField, app.InputModelFileStatus, ...
                app.InputModelFileStatus, ...
                @(value, field, icon)validateOsimFileGui(app, value, ...
                field, icon));
            % validateOsimFileGui goes through parseModelFileGui, which
            % only collects names. The marker and joint body structure
            % the Contact Surfaces tab needs is read separately.
            if app.inputModelValid
                parseGcpModelFileGui(app, app.input_model_file);
            else
                app.model_marker_bodies = [];
                app.model_joint_parents = [];
                app.model_joint_children = [];
            end
        end

        function validateInputOsimxFile(app)
            % The .osimx is optional and only ever raises a warning, so
            % its result is deliberately not stored or gated on.
            validateOsimxFileGui(app, app.input_osimx_file, ...
                app.input_model_file, app.InputOsimxFileEditField, ...
                app.InputOsimxFileStatus);
        end

        function validateInputMotionFile(app)
            app.inputMotionFileValid = validateRequiredFieldGui( ...
                app.input_motion_file, ...
                "Input motion file is required.", ...
                app.InputMotionFileEditField, ...
                app.InputMotionFileStatus, app.InputMotionFileStatus, ...
                @validateStoFileGui);
        end

        function validateInputGrfFile(app)
            app.inputGrfFileValid = validateRequiredFieldGui( ...
                app.input_grf_file, ...
                "Input ground reaction force file is required.", ...
                app.InputForceFileEditField, app.InputForceFileStatus, ...
                app.InputForceFileStatus, @validateStoFileGui);
            if app.inputGrfFileValid
                parseGcpGrfFileGui(app, app.input_grf_file);
            else
                app.grf_labels = [];
                app.grf_time_range = [];
            end
        end

        function validateResultsDirectory(app)
            app.resultsDirectoryValid = validateRequiredFieldGui( ...
                app.results_directory, ...
                "GCP results directory is required.", ...
                app.GCPResultsDirectoryEditField, ...
                app.GCPResultsDirectoryStatus, ...
                app.GCPResultsDirectoryStatus, ...
                @validateResultsDirectoryGui);
        end

        function widgets = markerDropDowns(app)
            widgets = [app.HindfootBodyDropDown, app.ToeMarkerDropDown, ...
                app.MedialMarkerDropDown, app.LateralMarkerDropDown, ...
                app.HeelMarkerDropDown, ...
                app.MidfootSuperiorMarkerDropDown];
        end

        function icons = markerStatusIcons(app)
            icons = [app.HindfootBodyStatus, app.ToeMarkerStatus, ...
                app.MedialMarkerStatus, app.LateralMarkerStatus, ...
                app.HeelMarkerStatus, app.MidfootSuperiorMarkerStatus];
        end

        function widgets = columnDropDowns(app, columnIndex)
            switch columnIndex
                case 1
                    widgets = [app.ForceColumnsDropDown, ...
                        app.ForceColumnsDropDown_2, ...
                        app.ForceColumnsDropDown_3];
                case 2
                    widgets = [app.MomentColumnsDropDown, ...
                        app.MomentColumnsDropDown_2, ...
                        app.MomentColumnsDropDown_3];
                otherwise
                    widgets = [app.ElectricalCenterColumnsDropDown, ...
                        app.ElectricalCenterColumnsDropDown_2, ...
                        app.ElectricalCenterColumnsDropDown_3];
            end
        end

        function icons = columnStatusIcons(app)
            icons = [app.ForceColumnsStatus, app.MomentColumnsStatus, ...
                app.ElectricalCenterColumnsStatus];
        end

        function list = markerFieldList(app, index)
            if index == 1
                list = app.model_bodies;
            else
                list = app.model_markers;
            end
        end

        % (string) -> (string)
        % The toes body is the child of the joint whose parent is the
        % hindfoot body, which is how
        % prepareGroundContactPersonalizationInputs finds it too.
        function name = toesBodyName(app, hindfootBodyName)
            name = "";
            if strcmp(hindfootBodyName, "")
                return
            end
            index = find(strcmp(app.model_joint_parents, ...
                hindfootBodyName), 1);
            if ~isempty(index)
                name = app.model_joint_children(index);
            end
        end

        % (string) -> (Array of string)
        % The markers a contact surface may use: those on its hindfoot
        % body and on the toes body hanging off it. Falls back to every
        % marker in the model when the foot cannot be worked out - no
        % hindfoot body chosen yet, a model that did not parse, or a
        % foot carrying no markers at all - so the dropdowns are never
        % left mysteriously empty.
        function markers = footMarkerNames(app, hindfootBodyName)
            markers = app.model_markers;
            if strcmp(hindfootBodyName, "") || ...
                    isempty(app.model_marker_bodies) || ...
                    numel(app.model_marker_bodies) ~= numel(markers)
                return
            end
            bodies = hindfootBodyName;
            toes = app.toesBodyName(hindfootBodyName);
            if ~strcmp(toes, "")
                bodies(end + 1) = toes;
            end
            onFoot = markers(ismember(app.model_marker_bodies, bodies));
            if isempty(onFoot)
                return
            end
            markers = onFoot;
        end

        function surface = selectedContactSurface(app)
            surface = [];
            if isempty(app.GCPContactSurface) || ...
                    app.contactSurfaceIndex < 1 || ...
                    app.contactSurfaceIndex > length(app.GCPContactSurface)
                return
            end
            surface = app.GCPContactSurface{app.contactSurfaceIndex};
        end

        function createDefaultContactSurface(app)
            app.GCPContactSurface{end + 1} = GCPContactSurfaceClass();
            app.GCPContactSurface{end}.name = "Contact Surface " + ...
                length(app.GCPContactSurface);
            app.applyDefaultTimeRange(app.GCPContactSurface{end});
            app.contactSurfaceIndex = length(app.GCPContactSurface);
            app.updateContactSurfaceList();
        end

        function applyDefaultTimeRange(app, surface)
            if numel(app.grf_time_range) ~= 2
                return
            end
            surface.start_time = app.grf_time_range(1);
            surface.end_time = app.grf_time_range(2);
            % Still counts as untouched, so swapping the force file
            % moves these again.
            surface.timeRangeIsDefault = true;
        end

        function deleteContactSurface(app, deletionIndex)
            if isempty(deletionIndex) || deletionIndex < 1 || ...
                    deletionIndex > length(app.GCPContactSurface)
                return
            end
            % Written out rather than routed through removeTaskFromList,
            % which renumbers an index property that a contact surface
            % does not have.
            app.GCPContactSurface(deletionIndex) = [];
            if isempty(app.GCPContactSurface)
                app.createDefaultContactSurface();
                return
            end
            app.contactSurfaceIndex = min(max(deletionIndex - 1, 1), ...
                length(app.GCPContactSurface));
            app.updateContactSurfaceList();
        end

        function setContactSurfaceField(app, fieldName, value)
            surface = app.selectedContactSurface();
            if isempty(surface)
                return
            end
            surface.(fieldName) = value;
            app.updateContactSurfaceList();
            app.updateRunButton();
        end

        function setContactSurfaceTime(app, fieldName, value)
            surface = app.selectedContactSurface();
            if isempty(surface)
                return
            end
            % A time the user typed is theirs from now on, so a later
            % force file leaves it alone.
            surface.timeRangeIsDefault = false;
            app.setContactSurfaceField(fieldName, value);
        end

        function setContactSurfaceColumn(app, columnIndex, axis, value)
            surface = app.selectedContactSurface();
            if isempty(surface)
                return
            end
            fieldName = app.columnFieldNames(columnIndex);
            columns = surface.(fieldName);
            columns(axis) = value;
            if axis == 1
                columns = app.fillColumnAxes(columns);
            end
            surface.(fieldName) = columns;
            % The Y and Z dropdowns may have been filled in above, so the
            % panel is redrawn rather than left showing the old names.
            app.updateContactSurfacePanel();
            app.validateContactSurfaces();
            app.updateRunButton();
        end

        function columns = fillColumnAxes(app, columns)
            % Ground reaction columns come in X, Y, Z triples that differ
            % only in the trailing axis letter - ground_force_1_vx, _vy,
            % _vz and the same for the moment and electrical center
            % series - so choosing X can fill the other two.
            %
            % The trailing letter is swapped rather than the v, m, or p
            % before it being matched, which keeps this working for any
            % naming that ends in the axis. Nothing is guessed: a
            % candidate is only used when the force file actually has a
            % column by that name, so a series that does not follow the
            % convention is simply left for the user.
            name = char(columns(1));
            if isempty(name) || lower(name(end)) ~= 'x'
                return
            end
            if name(end) == 'X'
                axisLetters = 'YZ';
            else
                axisLetters = 'yz';
            end
            for i = 1 : 2
                candidate = string([name(1:end - 1) axisLetters(i)]);
                if any(strcmp(app.grf_labels, candidate))
                    columns(i + 1) = candidate;
                end
            end
        end

        function updateContactSurfacePanel(app)
            surface = app.selectedContactSurface();
            if isempty(surface)
                return
            end
            % Which markers are on offer depends on this surface's
            % hindfoot body, so the lists are rebuilt before any value
            % is written back - assigning Items clears Value.
            app.updateMarkerDropDownItems(surface);
            app.IsLeftFootCheckBox.Value = ...
                strcmp(surface.is_left_foot, 'true');
            app.StartTimeEditField.Value = surface.start_time;
            app.EndTimeEditField.Value = surface.end_time;
            app.BeltSpeedEditField.Value = surface.belt_speed;
            for i = 1 : length(app.columnFieldNames)
                widgets = app.columnDropDowns(i);
                values = surface.(app.columnFieldNames(i));
                for axis = 1 : 3
                    widgets(axis).Value = values(axis);
                end
            end
            widgets = app.markerDropDowns();
            for i = 1 : length(app.markerFieldNames)
                widgets(i).Value = surface.(app.markerFieldNames(i));
            end
        end

        function updateContactSurfaceDropDownItems(app)
            for i = 1 : length(app.columnFieldNames)
                widgets = app.columnDropDowns(i);
                for axis = 1 : 3
                    widgets(axis).Items = app.grf_labels;
                end
            end
            % The marker lists belong to the selected surface, so
            % updateContactSurfacePanel rebuilds those. Assigning Items
            % resets Value, and it puts the stored names back after.
            app.updateContactSurfacePanel();
            app.validateContactSurfaces();
        end

        function updateMarkerDropDownItems(app, surface)
            widgets = app.markerDropDowns();
            % The hindfoot dropdown still offers every body; only the
            % five marker dropdowns narrow to that body's foot.
            widgets(1).Items = app.model_bodies;
            markers = app.footMarkerNames(surface.hindfoot_body);
            for i = 2 : numel(widgets)
                widgets(i).Items = markers;
            end
        end

        function [isValid, message, status] = surfaceTimeProblem(~, ...
                surface)
            isValid = true;
            message = "";
            status = "none";
            if surface.end_time <= surface.start_time
                isValid = false;
                message = "End time must be greater than start time.";
                status = "error";
            end
        end

        function [isValid, message, status] = surfaceColumnsProblem( ...
                app, surface, columnIndex)
            isValid = true;
            message = "";
            status = "none";
            label = app.columnFieldLabels(columnIndex);
            columns = surface.(app.columnFieldNames(columnIndex));
            if numel(columns) < 3 || any(strcmp(columns, ""))
                isValid = false;
                message = label + " must name three columns (X, Y, Z).";
                status = "required";
                return
            end
            if numel(unique(columns)) < 3
                isValid = false;
                message = label + " must name three different columns.";
                status = "error";
                return
            end
            % Nothing to check against until the GRF file is readable.
            if isempty(app.grf_labels)
                return
            end
            missing = columns(~ismember(columns, app.grf_labels));
            if ~isempty(missing)
                isValid = false;
                message = label + ": " + strjoin(missing, ", ") + ...
                    " not found in the ground reaction force file.";
                status = "error";
            end
        end

        function [isValid, message, status] = surfaceNameProblem(app, ...
                surface, fieldIndex)
            isValid = true;
            message = "";
            status = "none";
            label = app.markerFieldLabels(fieldIndex);
            value = surface.(app.markerFieldNames(fieldIndex));
            if strcmp(value, "")
                isValid = false;
                message = label + " is required.";
                status = "required";
                return
            end
            % Nothing to check against until the model is readable.
            list = app.markerFieldList(fieldIndex);
            if isempty(list)
                return
            end
            if ~any(strcmp(list, value))
                isValid = false;
                message = label + " """ + value + ...
                    """ is not in the input model.";
                status = "error";
            end
        end

        % Returns the statuses alongside the messages so the caller can
        % tell a surface that is merely unfinished ("required") from one
        % holding a value that is actually wrong ("error").
        function [messages, statuses] = contactSurfaceProblems(app, ...
                surface)
            messages = string([]);
            statuses = string([]);
            [~, message, status] = app.surfaceTimeProblem(surface);
            if ~strcmp(message, "")
                messages(end + 1) = message;
                statuses(end + 1) = status;
            end
            for i = 1 : length(app.columnFieldNames)
                [~, message, status] = ...
                    app.surfaceColumnsProblem(surface, i);
                if ~strcmp(message, "")
                    messages(end + 1) = message; %#ok<AGROW>
                    statuses(end + 1) = status; %#ok<AGROW>
                end
            end
            for i = 1 : length(app.markerFieldNames)
                [~, message, status] = app.surfaceNameProblem(surface, i);
                if ~strcmp(message, "")
                    messages(end + 1) = message; %#ok<AGROW>
                    statuses(end + 1) = status; %#ok<AGROW>
                end
            end
        end

        function updateSelectedSurfaceIcons(app)
            surface = app.selectedContactSurface();
            if isempty(surface)
                return
            end
            [~, message, status] = app.surfaceTimeProblem(surface);
            setGuiFieldStatus([], app.TimeRangeStatus, status, message);
            icons = app.columnStatusIcons();
            for i = 1 : length(app.columnFieldNames)
                [~, message, status] = ...
                    app.surfaceColumnsProblem(surface, i);
                setGuiFieldStatus([], icons(i), status, message);
            end
            icons = app.markerStatusIcons();
            for i = 1 : length(app.markerFieldNames)
                [~, message, status] = app.surfaceNameProblem(surface, i);
                setGuiFieldStatus([], icons(i), status, message);
            end
        end

        function validateContactSurfaces(app)
            % removeStyle drops every style, so each bad row has to be
            % repainted on every pass.
            removeStyle(app.ContactSurfacesTable);
            app.ContactSurfacesTable.Tooltip = '';
            allMessages = string([]);
            allStatuses = string([]);
            anyEnabled = false;
            for i = 1 : length(app.GCPContactSurface)
                surface = app.GCPContactSurface{i};
                if ~strcmp(surface.is_enabled, 'true')
                    continue
                end
                anyEnabled = true;
                [messages, statuses] = ...
                    app.contactSurfaceProblems(surface);
                if isempty(messages)
                    continue
                end
                % Only a wrong value paints the row. A surface that is
                % simply not filled in yet is left alone, so the row
                % agrees with the required icon rather than shouting in
                % red at a form the user has not reached.
                if any(strcmp(statuses, "error"))
                    addStyle(app.ContactSurfacesTable, ...
                        uistyle('BackgroundColor', [1.00 0.67 0.67]), ...
                        'row', i);
                end
                allMessages(end + 1) = surface.name + ": " + ...
                    strjoin(messages, " "); %#ok<AGROW>
                allStatuses = [allStatuses statuses]; %#ok<AGROW>
            end
            if ~anyEnabled
                allMessages(end + 1) = ...
                    "At least one contact surface must be enabled.";
                allStatuses(end + 1) = "required";
            end
            app.contactSurfacesValid = isempty(allMessages);
            if app.contactSurfacesValid
                clearGuiError([], app.ContactSurfacesStatus);
            else
                message = strjoin(allMessages, newline);
                % Missing values are incomplete, not wrong, so the table
                % shows the required icon; error is kept for a value
                % that is actually bad, and wins when both are present.
                if any(strcmp(allStatuses, "error"))
                    throwGuiError(message, [], app.ContactSurfacesStatus);
                else
                    throwGuiRequired(message, [], ...
                        app.ContactSurfacesStatus);
                end
                % Also on the table, so it is readable where the user is
                % working rather than only by hovering the icon.
                app.ContactSurfacesTable.Tooltip = message;
            end
            app.updateSelectedSurfaceIcons();
        end

        function task = selectedTask(app)
            task = [];
            if isempty(app.GCPTask) || app.taskIndex < 1 || ...
                    app.taskIndex > length(app.GCPTask)
                return
            end
            task = app.GCPTask{app.taskIndex};
        end

        function createDefaultTask(app)
            app.GCPTask{end + 1} = GCPTaskClass();
            app.GCPTask{end}.name = "Task " + length(app.GCPTask);
            app.GCPTask{end}.index = length(app.GCPTask);
            app.taskIndex = length(app.GCPTask);
            app.CostTermsTable.Selection = [];
            app.updateTaskList();
        end

        function createDefaultTaskList(app)
            % The three round sequence a GCP run normally starts from.
            % Deleting every task drops back to a single blank one
            % instead, since having three reappear would be surprising.
            app.CostTermsTable.Selection = [];
            app.GCPTask = makeDefaultGCPTaskList();
            app.taskIndex = 1;
        end

        function deleteTask(app, deletionIndex)
            [app.GCPTask, newTaskIndex] = removeTaskFromList( ...
                app.GCPTask, deletionIndex, app.taskIndex);
            if isempty(app.GCPTask)
                app.createDefaultTask();
                return
            end
            app.taskIndex = newTaskIndex;
            app.updateTaskList();
        end

        function moveTask(app, offset)
            [app.GCPTask, app.taskIndex] = moveTaskInList(app.GCPTask, ...
                app.taskIndex, offset);
            app.updateTaskList();
        end

        function updateTaskPanel(app)
            task = app.selectedTask();
            if isempty(task)
                return
            end
            app.NeighborStandardDeviationEditField.Value = ...
                task.neighborStandardDeviation;
            app.updateDesignVariablesTable();
            app.updateCostTermsTable();
            app.showSelectedCostTerm();
        end

        function updateDesignVariablesTable(app)
            task = app.selectedTask();
            if isempty(task)
                return
            end
            designVariable = task.parameterLabels;
            isEnabled = false(length(designVariable), 1);
            for i = 1 : length(isEnabled)
                isEnabled(i) = strcmp( ...
                    task.getParameterValueByIndex(i), 'true');
            end
            app.DesignVariablesTable.Data = table(isEnabled, ...
                designVariable);
        end

        function updateCostTermsTable(app)
            task = app.selectedTask();
            if isempty(task)
                return
            end
            updateCostTermsTableGui(app.CostTermsTable, ...
                task.RCNLCostTerm);
        end

        function costTerm = selectedCostTerm(app)
            costTerm = [];
            task = app.selectedTask();
            if isempty(task) || ~isscalar(app.CostTermsTable.Selection)
                return
            end
            selection = app.CostTermsTable.Selection;
            if selection < 1 || selection > length(task.RCNLCostTerm)
                return
            end
            costTerm = task.RCNLCostTerm{selection};
        end

        function showSelectedCostTerm(app)
            costTerm = app.selectedCostTerm();
            if isempty(costTerm)
                % AllowEmpty is on for both fields, so an empty value is
                % how "no term selected" is shown.
                app.MaxAllowableErrorEditField.Value = [];
                app.ErrorCenterEditField.Value = [];
                app.ErrorCenterEditField.Enable = false;
                return
            end
            showCostTermGui(costTerm, app.MaxAllowableErrorEditField, ...
                app.ErrorCenterEditField);
        end

        function validateTasks(app)
            % removeStyle drops every style, so each bad row has to be
            % repainted on every pass.
            removeStyle(app.TasksTable);
            app.TasksTable.Tooltip = '';
            allMessages = string([]);
            anyEnabled = false;
            for i = 1 : length(app.GCPTask)
                task = app.GCPTask{i};
                if ~strcmp(task.is_enabled, 'true')
                    continue
                end
                anyEnabled = true;
                messages = app.taskProblems(task);
                if isempty(messages)
                    continue
                end
                addStyle(app.TasksTable, ...
                    uistyle('BackgroundColor', [1.00 0.67 0.67]), ...
                    'row', i);
                allMessages(end + 1) = task.name + ": " + ...
                    strjoin(messages, " "); %#ok<AGROW>
            end
            if ~anyEnabled
                allMessages(end + 1) = ...
                    "At least one task must be enabled.";
            end
            app.tasksValid = isempty(allMessages);
            if app.tasksValid
                clearGuiError([], app.TasksStatus);
            else
                message = strjoin(allMessages, newline);
                throwGuiError(message, [], app.TasksStatus);
                app.TasksTable.Tooltip = message;
            end
            app.updateSelectedTaskIcons();
        end

        function messages = taskProblems(app, task)
            messages = string([]);
            if ~task.anyParameterEnabled()
                messages(end + 1) = ...
                    "at least one design variable must be enabled.";
            end
            [hasEnabledTerm, invalidIndices] = ...
                checkCostTermsValid(task.RCNLCostTerm);
            % checkCostTermsValid compares max_allowable_error <= 0,
            % which is empty rather than false for a cleared field, so a
            % blank error slips past it. Saving would then omit the
            % element and the backend would quietly use 1, so say so.
            blank = false;
            for i = 1 : numel(task.RCNLCostTerm)
                term = task.RCNLCostTerm{i};
                if isempty(term) || ~strcmp(term.is_enabled, 'true')
                    continue
                end
                if isempty(term.max_allowable_error) || ...
                        any(isnan(term.max_allowable_error))
                    blank = true;
                end
            end
            if ~hasEnabledTerm
                messages(end + 1) = ...
                    "at least one cost term must be enabled.";
            elseif ~isempty(invalidIndices)
                messages(end + 1) = "max allowable error must be " + ...
                    "greater than zero for each enabled cost term.";
            elseif blank
                messages(end + 1) = "max allowable error is required " + ...
                    "for each enabled cost term.";
            end
            if isnan(task.neighborStandardDeviation) || ...
                    task.neighborStandardDeviation <= 0
                messages(end + 1) = "neighbor standard deviation " + ...
                    "must be a positive number.";
            end
        end

        function updateSelectedTaskIcons(app)
            task = app.selectedTask();
            if isempty(task)
                return
            end
            if task.anyParameterEnabled()
                clearGuiError([], app.DesignVariablesStatus);
            else
                throwGuiError("At least one design variable must be " + ...
                    "enabled.", [], app.DesignVariablesStatus);
            end
            validateCostTermsGui(task.RCNLCostTerm, app.CostTermsTable, ...
                app.MaxAllowableErrorEditField, app.CostTermsStatus, ...
                "cost term");
        end

        function [isValid, reason] = advancedSettingProblem(app, index)
            isValid = true;
            reason = "";
            value = app.advancedSettingValues(index);
            number = str2double(value);
            switch app.advancedSettingKinds(index)
                case "boolean"
                    if ~any(strcmpi(value, ["true" "false"]))
                        isValid = false;
                        reason = "must be true or false";
                    end
                case "nonnegative"
                    if isnan(number) || number < 0
                        isValid = false;
                        reason = "must be a non-negative number";
                    end
                case "positiveInteger"
                    if isnan(number) || number <= 0 || ...
                            mod(number, 1) ~= 0
                        isValid = false;
                        reason = "must be a positive integer";
                    end
                otherwise
                    if isnan(number) || number <= 0
                        isValid = false;
                        reason = "must be a positive number";
                    end
            end
        end

        function validateAdvancedSettings(app)
            removeStyle(app.AdvancedSettingsTable);
            app.AdvancedSettingsTable.Tooltip = '';
            if numel(app.advancedSettingValues) ~= ...
                    numel(app.advancedSettingNames)
                return
            end
            messages = string([]);
            for i = 1 : length(app.advancedSettingNames)
                [isValid, reason] = app.advancedSettingProblem(i);
                if isValid
                    continue
                end
                addStyle(app.AdvancedSettingsTable, ...
                    uistyle('BackgroundColor', [1.00 0.67 0.67]), ...
                    'row', i);
                messages(end + 1) = app.advancedSettingNames(i) + ...
                    ": " + reason + " (default " + ...
                    app.defaultAdvancedSettingValues(i) + ")"; %#ok<AGROW>
            end
            app.advancedSettingsValid = isempty(messages);
            if app.advancedSettingsValid
                clearGuiError([], app.AdvancedSettingsStatus);
            else
                message = strjoin(messages, newline);
                throwGuiError(message, [], app.AdvancedSettingsStatus);
                app.AdvancedSettingsTable.Tooltip = message;
            end
        end

        function validateAllFields(app)
            app.validateInputModelFile();
            app.validateInputOsimxFile();
            app.validateInputMotionFile();
            app.validateInputGrfFile();
            app.validateResultsDirectory();
            app.validateContactSurfaces();
            app.validateTasks();
        end

        function updateRunButton(app)
            app.RunButton.Enable = app.inputModelValid && ...
                app.inputMotionFileValid && app.inputGrfFileValid && ...
                app.resultsDirectoryValid && app.contactSurfacesValid && ...
                app.tasksValid && app.advancedSettingsValid;
            app.updateTabControls();
        end

        function updateTabControls(app)
            % Contact surfaces need the model for its marker and body
            % lists and the GRF file for its column labels, so both later
            % tabs stay shut until the Inputs tab is complete.
            inputsReady = app.inputModelValid && ...
                app.inputMotionFileValid && app.inputGrfFileValid && ...
                app.resultsDirectoryValid;
            app.ContactSurfacesButton.Enable = inputsReady;
            app.GCPTasksButton.Enable = inputsReady;
        end

        function resetAllFields(app)
            app.inputModelValid = false;
            app.inputMotionFileValid = false;
            app.inputGrfFileValid = false;
            app.resultsDirectoryValid = false;

            app.model_markers = [];
            app.model_bodies = [];
            app.model_marker_bodies = [];
            app.model_joint_parents = [];
            app.model_joint_children = [];
            app.grf_labels = [];
            app.grf_time_range = [];

            app.input_model_file = "";
            app.input_osimx_file = "";
            app.input_motion_file = "";
            app.input_grf_file = "";
            app.results_directory = "";

            app.grid_width = 5;
            app.grid_height = 15;

            app.GCPContactSurface = cell(0);
            app.createDefaultContactSurface();

            app.createDefaultTaskList();

            app.advancedSettingValues = app.defaultAdvancedSettingValues;

            app.currentSettingsFile = "";

            app.validateAllFields();
            app.updateRunButton();
        end
    end

    methods (Access = private) % settings file helpers

        function settingsTree = makeGcpSettingsStruct(app, ...
                settingsFileName)
            settingsFilePath = fileparts(settingsFileName);
            settingsTree.results_directory = getRelativePath( ...
                app.results_directory, settingsFilePath);
            settingsTree.input_model_file = getRelativePath( ...
                app.input_model_file, settingsFilePath);
            % Omitted rather than written blank: the parser reads it
            % with getTextFromField, and an empty element has no Text.
            if ~strcmp(app.input_osimx_file, "")
                settingsTree.input_osimx_file = getRelativePath( ...
                    app.input_osimx_file, settingsFilePath);
            end
            settingsTree.input_motion_file = getRelativePath( ...
                app.input_motion_file, settingsFilePath);
            settingsTree.input_grf_file = getRelativePath( ...
                app.input_grf_file, settingsFilePath);
            settingsTree.grid_width = app.grid_width;
            settingsTree.grid_height = app.grid_height;
            % input_directory is deliberately not written. Every path
            % above is already relative to the settings file, and the
            % parser joins them against pwd when the element is absent.

            surfaces = cell(1, length(app.GCPContactSurface));
            for i = 1 : length(app.GCPContactSurface)
                surfaces{i} = app.GCPContactSurface{i}.toStruct();
            end
            settingsTree.GCPContactSurfaceSet.GCPContactSurface = ...
                surfaces;

            tasks = cell(1, length(app.GCPTask));
            for i = 1 : length(app.GCPTask)
                tasks{i} = app.GCPTask{i}.toStruct();
            end
            settingsTree.GCPTaskList.GCPTask = tasks;

            settingsTree = app.setOptimizationParams(settingsTree);
            settingsTree = formatGuiDataForXml(settingsTree);
        end

        function settingsTree = setOptimizationParams(app, settingsTree)
            % Each advanced setting name is literally its XML element
            % name, and the values are already text, which is what the
            % boolean rows need.
            for i = 1 : length(app.advancedSettingNames)
                settingsTree.(app.advancedSettingNames(i)) = ...
                    app.advancedSettingValues(i);
            end
        end

        function loadOptimizationParams(app, settingsTree)
            values = app.advancedSettingValues;
            for i = 1 : length(app.advancedSettingNames)
                name = app.advancedSettingNames(i);
                if ~isfield(settingsTree, name)
                    continue
                end
                text = toGuiText(settingsTree.(name));
                % An element written empty carries no value, so the
                % default is kept rather than storing a blank.
                if strcmp(text, "")
                    continue
                end
                values(i) = text;
            end
            app.advancedSettingValues = values;
        end

        function applySettingsStruct(app, settingsTree)
            % The shared applyStructToHandle cannot assign this class's
            % private properties, so the same loop runs as a method.
            metaProperties = metaclass(app).PropertyList;
            metaProperties = metaProperties(~[metaProperties.Constant] ...
                & ~[metaProperties.Dependent]);
            propertyNames = {metaProperties.Name};
            fields = fieldnames(settingsTree);
            for i = 1 : length(fields)
                % Paths are left to loadPaths. formatXmlDataForGui
                % splits char on spaces, so a path through a folder like
                % "Tutorial 1" arrives here as a two element string
                % array; assigning it would fire the listener on a value
                % getRelativePath cannot take.
                if any(strcmp(fields{i}, app.settingsPathFields))
                    continue
                end
                if any(strcmp(fields{i}, propertyNames)) && ...
                        ~isstruct(settingsTree.(fields{i}))
                    app.(fields{i}) = settingsTree.(fields{i});
                end
            end
        end

        function loadPaths(app, settingsTree)
            fields = app.settingsPathFields;
            for i = 1 : length(fields)
                if ~isfield(settingsTree, fields(i))
                    continue
                end
                % formatXmlDataForGui splits char on spaces, so a path
                % containing one arrives as a string array; toGuiText
                % rejoins it.
                app.(fields(i)) = app.toAbsolutePath( ...
                    toGuiText(settingsTree.(fields(i))));
            end
        end

        function absolute = toAbsolutePath(~, value)
            if strcmp(value, "")
                absolute = "";
                return
            end
            absolute = string(GetFullPath(char(value)));
        end

        function items = normalizeXmlList(~, settingsTree, setName, ...
                itemName)
            items = {};
            if ~isfield(settingsTree, setName) || ...
                    ~isfield(settingsTree.(setName), itemName)
                return
            end
            raw = settingsTree.(setName).(itemName);
            % xml2struct is shape unstable: '', "" or [] for an empty
            % list, a bare struct for exactly one entry, a cell array
            % otherwise.
            if isstruct(raw)
                items = num2cell(raw);
            elseif iscell(raw)
                items = raw;
            end
        end

        function loadContactSurfaces(app, settingsTree)
            surfaces = app.normalizeXmlList(settingsTree, ...
                'GCPContactSurfaceSet', 'GCPContactSurface');
            if isempty(surfaces)
                return
            end
            app.GCPContactSurface = cell(0);
            for i = 1 : length(surfaces)
                app.GCPContactSurface{i} = GCPContactSurfaceClass();
                app.GCPContactSurface{i}.loadFromStruct(surfaces{i});
                if strcmp(app.GCPContactSurface{i}.name, "")
                    app.GCPContactSurface{i}.name = ...
                        "Contact Surface " + i;
                end
            end
            app.contactSurfaceIndex = 1;
            app.updateContactSurfaceList();
        end

        function loadTasks(app, settingsTree)
            tasks = app.normalizeXmlList(settingsTree, 'GCPTaskList', ...
                'GCPTask');
            if isempty(tasks)
                return
            end
            app.GCPTask = cell(0);
            for i = 1 : length(tasks)
                app.GCPTask{i} = GCPTaskClass();
                app.GCPTask{i}.loadFromStruct(tasks{i});
                if strcmp(app.GCPTask{i}.name, "")
                    app.GCPTask{i}.name = "Task " + i;
                end
            end
            % The backend runs tasks in <index> order, so show them that
            % way and renumber so position and index agree again.
            indices = cellfun(@(task)task.index, app.GCPTask);
            [~, order] = sort(indices);
            app.GCPTask = app.GCPTask(order);
            for i = 1 : length(app.GCPTask)
                app.GCPTask{i}.index = i;
            end
            app.taskIndex = 1;
            app.CostTermsTable.Selection = [];
            app.updateTaskList();
        end
    end

    methods (Access = public)

        % Public so the Run button and scripted callers can drive them
        % without a file dialog.
        function saveSettingsFile(app, settingsFileName)
            % GetFullPath before fileparts: fileparts("settings.xml") is
            % "" and cd("") throws, and a caller can pass a bare name.
            settingsFileName = GetFullPath(char(settingsFileName));
            cd(fileparts(settingsFileName));
            app.currentSettingsFile = string(settingsFileName);
            saveGuiSettings(settingsFileName, ...
                'GroundContactPersonalizationTool', ...
                app.makeGcpSettingsStruct(settingsFileName));
        end

        function loadSettingsFile(app, settingsFileName)
            settingsFileName = GetFullPath(char(settingsFileName));
            app.resetAllFields();
            % Stored paths are relative to the settings file, and
            % display, typed input, and save all pick their base
            % directory from pwd independently; the cd is what makes the
            % three agree.
            cd(fileparts(settingsFileName));
            settingsTree = loadGuiSettings(settingsFileName, ...
                'GroundContactPersonalizationTool');
            app.applySettingsStruct(settingsTree);
            app.loadPaths(settingsTree);
            app.loadOptimizationParams(settingsTree);
            app.loadContactSurfaces(settingsTree);
            app.loadTasks(settingsTree);
            app.currentSettingsFile = string(settingsFileName);
            app.validateAllFields();
            app.updateRunButton();
        end

        % parseModelFileGui and parseGcpGrfFileGui push their parsed lists
        % back through these setters. parseModelFileGui wraps each parser
        % in its own try/catch, so a setter it cannot find is swallowed
        % silently and only the lists GCP uses are defined here.
        function setModelMarkers(app, markers)
            app.model_markers = markers;
        end

        function setModelBodies(app, bodies)
            app.model_bodies = bodies;
        end

        % Sets both halves at once so the two arrays cannot drift apart.
        % parseModelFileGui has already filled model_markers with the
        % same names; re-setting them here alongside their bodies keeps
        % the pairing guaranteed rather than assumed.
        function setModelMarkerBodies(app, markers, bodies)
            app.model_marker_bodies = bodies;
            app.model_markers = markers;
        end

        function setModelJointBodies(app, parents, children)
            app.model_joint_parents = parents;
            app.model_joint_children = children;
        end

        function setGrfColumnLabels(app, labels)
            app.grf_labels = labels;
        end

        function setGrfTimeRange(app, range)
            app.grf_time_range = range;
        end
    end

    % Callbacks that handle component events
    methods (Access = private)

        % Code that executes after component creation
        function startupFcn(app)
            app.makeAllListeners();
            % Assigned after the listeners exist so the table and panel
            % are drawn by the same path a later edit uses.
            app.createDefaultContactSurface();
            app.createDefaultTaskList();
            % Assigning this fires refreshAdvancedSettingsTable, which
            % is what first draws the table.
            app.advancedSettingValues = app.defaultAdvancedSettingValues;
            app.formatTabButtons();
            app.RunButton.Tooltip = "Saves the settings file and runs " + ...
                "Ground Contact Personalization.";
            app.validateAllFields();
            app.updateRunButton();
        end

        % Value changed function: InputModelFileEditField
        function InputModelFileEditFieldValueChanged(app, event)
            app.input_model_file = ...
                getPathFieldValue(app.InputModelFileEditField);
        end

        % Button pushed function: InputModelFileSearchButton
        function InputModelFileSearchButtonPushed(app, event)
            [file, path] = uigetfile('*.osim', ...
                "Select an OpenSim Model File");
            % User hit "Cancel"
            if isequal(file, 0)
                return
            end
            app.input_model_file = fullfile(path, file);
        end

        % Value changed function: InputOsimxFileEditField
        function InputOsimxFileEditFieldValueChanged(app, event)
            app.input_osimx_file = ...
                getPathFieldValue(app.InputOsimxFileEditField);
        end

        % Button pushed function: InputOsimxFileSearchButton
        function InputOsimxFileSearchButtonPushed(app, event)
            [file, path] = uigetfile('*.osimx', ...
                "Select an Osimx File");
            % User hit "Cancel"
            if isequal(file, 0)
                return
            end
            app.input_osimx_file = fullfile(path, file);
        end

        % Value changed function: InputMotionFileEditField
        function InputMotionFileEditFieldValueChanged(app, event)
            app.input_motion_file = ...
                getPathFieldValue(app.InputMotionFileEditField);
        end

        % Button pushed function: InputMotionFileSearchButton
        function InputMotionFileSearchButtonPushed(app, event)
            [file, path] = uigetfile({'*.sto;*.mot'}, ...
                "Select an Input Motion File");
            % User hit "Cancel"
            if isequal(file, 0)
                return
            end
            app.input_motion_file = fullfile(path, file);
        end

        % Value changed function: InputForceFileEditField
        function InputForceFileEditFieldValueChanged(app, event)
            app.input_grf_file = ...
                getPathFieldValue(app.InputForceFileEditField);
        end

        % Button pushed function: InputForceFileSearchButton
        function InputForceFileSearchButtonPushed(app, event)
            [file, path] = uigetfile({'*.sto;*.mot'}, ...
                "Select an Input Ground Reaction Force File");
            % User hit "Cancel"
            if isequal(file, 0)
                return
            end
            app.input_grf_file = fullfile(path, file);
        end

        % Value changed function: GCPResultsDirectoryEditField
        function GCPResultsDirectoryEditFieldValueChanged(app, event)
            app.results_directory = ...
                getPathFieldValue(app.GCPResultsDirectoryEditField);
        end

        % Button pushed function: GCPResultsDirectorySearchButton
        function GCPResultsDirectorySearchButtonPushed(app, event)
            folder = uigetdir("Select your GCP results folder");
            % User hit "Cancel"
            if isequal(folder, 0)
                return
            end
            app.results_directory = folder;
        end

        % Selection changed function: ContactSurfacesTable
        function ContactSurfacesTableSelectionChanged(app, event)
            if isempty(app.ContactSurfacesTable.Selection)
                return
            end
            if app.ContactSurfacesTable.Selection == ...
                    height(app.ContactSurfacesTable.Data)
                % The last row is the invitation to add one.
                app.createDefaultContactSurface();
            else
                app.contactSurfaceIndex = ...
                    app.ContactSurfacesTable.Selection;
            end
        end

        % Cell edit callback: ContactSurfacesTable
        function ContactSurfacesTableCellEdit(app, event)
            rowIndex = event.Indices(1);
            if rowIndex > length(app.GCPContactSurface)
                % Restore the add-a-surface row rather than editing it.
                app.updateContactSurfaceList();
                return
            end
            app.contactSurfaceIndex = rowIndex;
            if event.Indices(2) == 1
                app.GCPContactSurface{rowIndex}.is_enabled = ...
                    boolToString(event.NewData);
            else
                app.GCPContactSurface{rowIndex}.name = ...
                    string(event.NewData);
            end
            app.updateContactSurfaceList();
            app.updateRunButton();
        end

        % Menu selected function: RenameContactSurfaceMenu
        function RenameContactSurfaceMenuSelected(app, event)
            surface = app.selectedContactSurface();
            if isempty(surface)
                return
            end
            newName = inputdlg("Rename contact surface:", "Rename", ...
                [1 40], {char(surface.name)});
            if isempty(newName)
                return
            end
            surface.name = string(newName{1});
            app.updateContactSurfaceList();
        end

        % Menu selected function: DeleteContactSurfaceMenu
        function DeleteContactSurfaceMenuSelected(app, event)
            app.deleteContactSurface(app.ContactSurfacesTable.Selection);
        end

        % Value changed function: IsLeftFootCheckBox
        function IsLeftFootCheckBoxValueChanged(app, event)
            app.setContactSurfaceField('is_left_foot', ...
                boolToString(app.IsLeftFootCheckBox.Value));
        end

        % Value changed function: StartTimeEditField
        function StartTimeEditFieldValueChanged(app, event)
            app.setContactSurfaceTime('start_time', ...
                app.StartTimeEditField.Value);
        end

        % Value changed function: EndTimeEditField
        function EndTimeEditFieldValueChanged(app, event)
            app.setContactSurfaceTime('end_time', ...
                app.EndTimeEditField.Value);
        end

        % Value changed function: BeltSpeedEditField
        function BeltSpeedEditFieldValueChanged(app, event)
            app.setContactSurfaceField('belt_speed', ...
                app.BeltSpeedEditField.Value);
        end

        % Value changed function: GridWidthEditField
        function GridWidthEditFieldValueChanged(app, event)
            app.grid_width = app.GridWidthEditField.Value;
        end

        % Value changed function: GridHeightEditField
        function GridHeightEditFieldValueChanged(app, event)
            app.grid_height = app.GridHeightEditField.Value;
        end

        % Value changed function: ForceColumnsDropDown
        function ForceColumnsDropDownValueChanged(app, event)
            app.setContactSurfaceColumn(1, 1, ...
                string(app.ForceColumnsDropDown.Value));
        end

        % Value changed function: ForceColumnsDropDown_2
        function ForceColumnsDropDown_2ValueChanged(app, event)
            app.setContactSurfaceColumn(1, 2, ...
                string(app.ForceColumnsDropDown_2.Value));
        end

        % Value changed function: ForceColumnsDropDown_3
        function ForceColumnsDropDown_3ValueChanged(app, event)
            app.setContactSurfaceColumn(1, 3, ...
                string(app.ForceColumnsDropDown_3.Value));
        end

        % Value changed function: MomentColumnsDropDown
        function MomentColumnsDropDownValueChanged(app, event)
            app.setContactSurfaceColumn(2, 1, ...
                string(app.MomentColumnsDropDown.Value));
        end

        % Value changed function: MomentColumnsDropDown_2
        function MomentColumnsDropDown_2ValueChanged(app, event)
            app.setContactSurfaceColumn(2, 2, ...
                string(app.MomentColumnsDropDown_2.Value));
        end

        % Value changed function: MomentColumnsDropDown_3
        function MomentColumnsDropDown_3ValueChanged(app, event)
            app.setContactSurfaceColumn(2, 3, ...
                string(app.MomentColumnsDropDown_3.Value));
        end

        % Value changed function: ElectricalCenterColumnsDropDown
        function ElectricalCenterColumnsDropDownValueChanged(app, event)
            app.setContactSurfaceColumn(3, 1, ...
                string(app.ElectricalCenterColumnsDropDown.Value));
        end

        % Value changed function: ElectricalCenterColumnsDropDown_2
        function ElectricalCenterColumnsDropDown_2ValueChanged(app, event)
            app.setContactSurfaceColumn(3, 2, ...
                string(app.ElectricalCenterColumnsDropDown_2.Value));
        end

        % Value changed function: ElectricalCenterColumnsDropDown_3
        function ElectricalCenterColumnsDropDown_3ValueChanged(app, event)
            app.setContactSurfaceColumn(3, 3, ...
                string(app.ElectricalCenterColumnsDropDown_3.Value));
        end

        % Value changed function: HindfootBodyDropDown
        function HindfootBodyDropDownValueChanged(app, event)
            app.setContactSurfaceField('hindfoot_body', ...
                string(app.HindfootBodyDropDown.Value));
        end

        % Value changed function: ToeMarkerDropDown
        function ToeMarkerDropDownValueChanged(app, event)
            app.setContactSurfaceField('toe_marker', ...
                string(app.ToeMarkerDropDown.Value));
        end

        % Value changed function: MedialMarkerDropDown
        function MedialMarkerDropDownValueChanged(app, event)
            app.setContactSurfaceField('medial_marker', ...
                string(app.MedialMarkerDropDown.Value));
        end

        % Value changed function: LateralMarkerDropDown
        function LateralMarkerDropDownValueChanged(app, event)
            app.setContactSurfaceField('lateral_marker', ...
                string(app.LateralMarkerDropDown.Value));
        end

        % Value changed function: HeelMarkerDropDown
        function HeelMarkerDropDownValueChanged(app, event)
            app.setContactSurfaceField('heel_marker', ...
                string(app.HeelMarkerDropDown.Value));
        end

        % Value changed function: MidfootSuperiorMarkerDropDown
        function MidfootSuperiorMarkerDropDownValueChanged(app, event)
            app.setContactSurfaceField('midfoot_superior_marker', ...
                string(app.MidfootSuperiorMarkerDropDown.Value));
        end

        % Selection changed function: TasksTable
        function TasksTableSelectionChanged(app, event)
            if isempty(app.TasksTable.Selection)
                return
            end
            if app.TasksTable.Selection == height(app.TasksTable.Data)
                % The last row is the invitation to add one.
                app.createDefaultTask();
            else
                app.taskIndex = app.TasksTable.Selection;
            end
        end

        % Cell edit callback: TasksTable
        function TasksTableCellEdit(app, event)
            rowIndex = event.Indices(1);
            if rowIndex > length(app.GCPTask)
                % Restore the add-a-task row rather than editing it.
                app.updateTaskList();
                return
            end
            app.taskIndex = rowIndex;
            if event.Indices(2) == 1
                app.GCPTask{rowIndex}.is_enabled = ...
                    boolToString(event.NewData);
            else
                app.GCPTask{rowIndex}.name = string(event.NewData);
            end
            app.updateTaskList();
            app.updateRunButton();
        end

        % Menu selected function: RenameTaskMenu
        function RenameTaskMenuSelected(app, event)
            task = app.selectedTask();
            if isempty(task)
                return
            end
            newName = inputdlg("Rename task:", "Rename", [1 40], ...
                {char(task.name)});
            if isempty(newName)
                return
            end
            task.name = string(newName{1});
            app.updateTaskList();
        end

        % Menu selected function: DeleteTaskMenu
        function DeleteTaskMenuSelected(app, event)
            app.deleteTask(app.TasksTable.Selection);
        end

        % Button pushed function: MoveTaskUpButton
        function MoveTaskUpButtonPushed(app, event)
            app.moveTask(-1);
        end

        % Button pushed function: MoveTaskDownButton
        function MoveTaskDownButtonPushed(app, event)
            app.moveTask(1);
        end

        % Cell edit callback: DesignVariablesTable
        function DesignVariablesTableCellEdit(app, event)
            task = app.selectedTask();
            if isempty(task)
                return
            end
            task.setParameterValueByIndex(event.Indices(1), ...
                boolToString(event.NewData));
            app.validateTasks();
            app.updateRunButton();
        end

        % Cell edit callback: CostTermsTable
        function CostTermsTableCellEdit(app, event)
            task = app.selectedTask();
            if isempty(task)
                return
            end
            task.RCNLCostTerm{event.Indices(1)}.is_enabled = ...
                boolToString(event.NewData);
            app.validateTasks();
            app.updateRunButton();
        end

        % Selection changed function: CostTermsTable
        function CostTermsTableSelectionChanged(app, event)
            app.showSelectedCostTerm();
            app.validateTasks();
        end

        % Value changed function: MaxAllowableErrorEditField
        function MaxAllowableErrorEditFieldValueChanged(app, event)
            costTerm = app.selectedCostTerm();
            if isempty(costTerm)
                return
            end
            costTerm.max_allowable_error = ...
                app.MaxAllowableErrorEditField.Value;
            app.validateTasks();
            app.updateRunButton();
        end

        % Value changed function: ErrorCenterEditField
        function ErrorCenterEditFieldValueChanged(app, event)
            costTerm = app.selectedCostTerm();
            if isempty(costTerm)
                return
            end
            costTerm.error_center = app.ErrorCenterEditField.Value;
        end

        % Value changed function: NeighborStandardDeviationEditField
        function NeighborStandardDeviationEditFieldValueChanged(app, event)
            task = app.selectedTask();
            if isempty(task)
                return
            end
            task.neighborStandardDeviation = ...
                app.NeighborStandardDeviationEditField.Value;
            app.validateTasks();
            app.updateRunButton();
        end

        % Cell edit callback: AdvancedSettingsTable
        function AdvancedSettingsTableCellEdit(app, event)
            values = app.advancedSettingValues;
            values(event.Indices(1)) = string(event.NewData);
            % The PostSet listener redraws the whole table, so a value
            % the user typed is shown exactly as stored.
            app.advancedSettingValues = values;
        end

        % Button pushed function: InputsButton
        function InputsButtonPushed(app, event)
            app.TabGroup.SelectedTab = app.InputsTab;
        end

        % Button pushed function: ContactSurfacesButton
        function ContactSurfacesButtonPushed(app, event)
            app.TabGroup.SelectedTab = app.ContactSurfacesTab;
        end

        % Button pushed function: GCPTasksButton
        function GCPTasksButtonPushed(app, event)
            app.TabGroup.SelectedTab = app.GCPTasksTab;
        end

        % Button pushed function: AdvancedButton
        function AdvancedButtonPushed(app, event)
            app.TabGroup.SelectedTab = app.AdvancedTab;
        end

        % Image clicked function: RcnlLogo
        function RcnlLogoImageClicked(app, event)
            web("https://nmsm.rice.edu/")
        end

        % Button pushed function: HelpButton
        function HelpButtonPushed(app, event)
            web("https://nmsm.rice.edu/guides-and-publications/tool-overviews/model-personalization/ground-contact-personalization/")
        end

        % Button pushed function: LoadSettingsFileButton
        function LoadSettingsFileButtonPushed(app, event)
            [file, path] = uigetfile('*.xml', "Load XML Settings File");
            % User hit "Cancel"
            if isequal(file, 0)
                return
            end
            app.loadSettingsFile(fullfile(path, file));
        end

        % Button pushed function: SaveButton
        function SaveButtonPushed(app, event)
            [file, path] = uiputfile('*.xml', "Save XML Settings File");
            % User hit "Cancel"
            if isequal(file, 0)
                return
            end
            app.saveSettingsFile(fullfile(path, file));
        end

        % Button pushed function: RunButton
        function RunButtonPushed(app, event)
            if strcmp(app.currentSettingsFile, "")
                [file, path] = uiputfile('*.xml', ...
                    "Save XML Settings File");
                % User hit "Cancel"
                if isequal(file, 0)
                    return
                end
                app.currentSettingsFile = fullfile(path, file);
            end
            app.saveSettingsFile(app.currentSettingsFile);
            % Clears figures left over from a previous run so the result
            % plots are the only ones on screen.
            close all
            GCPRun(app, app.currentSettingsFile);
        end

        % Button pushed function: ResetButton
        function ResetButtonPushed(app, event)
            app.resetAllFields();
        end
    end

    % Component initialization
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Get the file path for locating images
            pathToMLAPP = fileparts(mfilename('fullpath'));

            % Create UIFigure and hide until all components are created
            app.UIFigure = uifigure('Visible', 'off');
            app.UIFigure.Color = [0.851 0.851 0.851];
            app.UIFigure.Position = [500 500 1123 712];
            app.UIFigure.Name = 'MATLAB App';

            % Create GroundContactModelPersonalizationToolLabel
            app.GroundContactModelPersonalizationToolLabel = uilabel(app.UIFigure);
            app.GroundContactModelPersonalizationToolLabel.HorizontalAlignment = 'center';
            app.GroundContactModelPersonalizationToolLabel.FontSize = 25;
            app.GroundContactModelPersonalizationToolLabel.FontWeight = 'bold';
            app.GroundContactModelPersonalizationToolLabel.Position = [1 673 1123 40];
            app.GroundContactModelPersonalizationToolLabel.Text = 'Ground Contact Model Personalization Tool';

            % Create TabGroup
            app.TabGroup = uitabgroup(app.UIFigure);
            app.TabGroup.Position = [211 72 913 595];

            % Create InputsTab
            app.InputsTab = uitab(app.TabGroup);
            app.InputsTab.BackgroundColor = [0.851 0.851 0.851];
            app.InputsTab.ForegroundColor = [0 0 0];

            % Create InputModelFileSearchButton
            app.InputModelFileSearchButton = uibutton(app.InputsTab, 'push');
            app.InputModelFileSearchButton.ButtonPushedFcn = createCallbackFcn(app, @InputModelFileSearchButtonPushed, true);
            app.InputModelFileSearchButton.Icon = fullfile(pathToMLAPP, '..', 'Images', 'folderIcon.svg');
            app.InputModelFileSearchButton.VerticalAlignment = 'bottom';
            app.InputModelFileSearchButton.BackgroundColor = [0.1294 0.1804 0.4];
            app.InputModelFileSearchButton.Position = [822 516 31 30];
            app.InputModelFileSearchButton.Text = '';

            % Create InputModelFileEditFieldLabel
            app.InputModelFileEditFieldLabel = uilabel(app.InputsTab);
            app.InputModelFileEditFieldLabel.HorizontalAlignment = 'right';
            app.InputModelFileEditFieldLabel.FontSize = 18;
            app.InputModelFileEditFieldLabel.FontWeight = 'bold';
            app.InputModelFileEditFieldLabel.Position = [68 516 140 30];
            app.InputModelFileEditFieldLabel.Text = 'Input Model File';

            % Create InputModelFileEditField
            app.InputModelFileEditField = uieditfield(app.InputsTab, 'text');
            app.InputModelFileEditField.ValueChangedFcn = createCallbackFcn(app, @InputModelFileEditFieldValueChanged, true);
            app.InputModelFileEditField.Position = [218 516 587 30];

            % Create InputModelFileStatus
            app.InputModelFileStatus = uiimage(app.InputsTab);
            app.InputModelFileStatus.Visible = 'off';
            app.InputModelFileStatus.Position = [862 516 28 30];
            app.InputModelFileStatus.ImageSource = fullfile(pathToMLAPP, '..', 'Images', 'error.png');

            % Create InputOsimxFileSearchButton
            app.InputOsimxFileSearchButton = uibutton(app.InputsTab, 'push');
            app.InputOsimxFileSearchButton.ButtonPushedFcn = createCallbackFcn(app, @InputOsimxFileSearchButtonPushed, true);
            app.InputOsimxFileSearchButton.Icon = fullfile(pathToMLAPP, '..', 'Images', 'folderIcon.svg');
            app.InputOsimxFileSearchButton.VerticalAlignment = 'bottom';
            app.InputOsimxFileSearchButton.BackgroundColor = [0.1294 0.1804 0.4];
            app.InputOsimxFileSearchButton.Position = [822 461 31 30];
            app.InputOsimxFileSearchButton.Text = '';

            % Create InputOsimxFileEditFieldLabel
            app.InputOsimxFileEditFieldLabel = uilabel(app.InputsTab);
            app.InputOsimxFileEditFieldLabel.HorizontalAlignment = 'right';
            app.InputOsimxFileEditFieldLabel.FontSize = 18;
            app.InputOsimxFileEditFieldLabel.FontWeight = 'bold';
            app.InputOsimxFileEditFieldLabel.Position = [63 461 145 30];
            app.InputOsimxFileEditFieldLabel.Text = 'Input Osimx File';

            % Create InputOsimxFileEditField
            app.InputOsimxFileEditField = uieditfield(app.InputsTab, 'text');
            app.InputOsimxFileEditField.ValueChangedFcn = createCallbackFcn(app, @InputOsimxFileEditFieldValueChanged, true);
            app.InputOsimxFileEditField.Position = [218 461 587 30];

            % Create InputOsimxFileStatus
            app.InputOsimxFileStatus = uiimage(app.InputsTab);
            app.InputOsimxFileStatus.Visible = 'off';
            app.InputOsimxFileStatus.Position = [862 461 28 30];
            app.InputOsimxFileStatus.ImageSource = fullfile(pathToMLAPP, '..', 'Images', 'error.png');

            % Create InputMotionFileSearchButton
            app.InputMotionFileSearchButton = uibutton(app.InputsTab, 'push');
            app.InputMotionFileSearchButton.ButtonPushedFcn = createCallbackFcn(app, @InputMotionFileSearchButtonPushed, true);
            app.InputMotionFileSearchButton.Icon = fullfile(pathToMLAPP, '..', 'Images', 'folderIcon.svg');
            app.InputMotionFileSearchButton.VerticalAlignment = 'bottom';
            app.InputMotionFileSearchButton.BackgroundColor = [0.1294 0.1804 0.4];
            app.InputMotionFileSearchButton.Position = [822 411 31 30];
            app.InputMotionFileSearchButton.Text = '';

            % Create InputMotionFileEditField
            app.InputMotionFileEditField = uieditfield(app.InputsTab, 'text');
            app.InputMotionFileEditField.ValueChangedFcn = createCallbackFcn(app, @InputMotionFileEditFieldValueChanged, true);
            app.InputMotionFileEditField.Position = [218 411 587 30];

            % Create InputMotionFileStatus
            app.InputMotionFileStatus = uiimage(app.InputsTab);
            app.InputMotionFileStatus.Visible = 'off';
            app.InputMotionFileStatus.Position = [862 411 28 30];
            app.InputMotionFileStatus.ImageSource = fullfile(pathToMLAPP, '..', 'Images', 'error.png');

            % Create GCPResultsDirectorySearchButton
            app.GCPResultsDirectorySearchButton = uibutton(app.InputsTab, 'push');
            app.GCPResultsDirectorySearchButton.ButtonPushedFcn = createCallbackFcn(app, @GCPResultsDirectorySearchButtonPushed, true);
            app.GCPResultsDirectorySearchButton.Icon = fullfile(pathToMLAPP, '..', 'Images', 'folderIcon.svg');
            app.GCPResultsDirectorySearchButton.VerticalAlignment = 'bottom';
            app.GCPResultsDirectorySearchButton.BackgroundColor = [0.1294 0.1804 0.4];
            app.GCPResultsDirectorySearchButton.Position = [822 310 31 30];
            app.GCPResultsDirectorySearchButton.Text = '';

            % Create GCPResultsDirectoryEditFieldLabel
            app.GCPResultsDirectoryEditFieldLabel = uilabel(app.InputsTab);
            app.GCPResultsDirectoryEditFieldLabel.HorizontalAlignment = 'right';
            app.GCPResultsDirectoryEditFieldLabel.FontSize = 18;
            app.GCPResultsDirectoryEditFieldLabel.FontWeight = 'bold';
            app.GCPResultsDirectoryEditFieldLabel.Position = [9 310 199 30];
            app.GCPResultsDirectoryEditFieldLabel.Text = 'GCP Results Directory';

            % Create GCPResultsDirectoryEditField
            app.GCPResultsDirectoryEditField = uieditfield(app.InputsTab, 'text');
            app.GCPResultsDirectoryEditField.ValueChangedFcn = createCallbackFcn(app, @GCPResultsDirectoryEditFieldValueChanged, true);
            app.GCPResultsDirectoryEditField.Position = [218 310 587 30];

            % Create GCPResultsDirectoryStatus
            app.GCPResultsDirectoryStatus = uiimage(app.InputsTab);
            app.GCPResultsDirectoryStatus.Visible = 'off';
            app.GCPResultsDirectoryStatus.Position = [862 310 28 30];
            app.GCPResultsDirectoryStatus.ImageSource = fullfile(pathToMLAPP, '..', 'Images', 'error.png');

            % Create InputMotionFileLabel
            app.InputMotionFileLabel = uilabel(app.InputsTab);
            app.InputMotionFileLabel.HorizontalAlignment = 'right';
            app.InputMotionFileLabel.FontSize = 18;
            app.InputMotionFileLabel.FontWeight = 'bold';
            app.InputMotionFileLabel.Position = [31 411 177 30];
            app.InputMotionFileLabel.Text = 'Input Motion File';

            % Create InputForceFileStatus
            app.InputForceFileStatus = uiimage(app.InputsTab);
            app.InputForceFileStatus.Visible = 'off';
            app.InputForceFileStatus.Position = [862 361 28 30];
            app.InputForceFileStatus.ImageSource = fullfile(pathToMLAPP, '..', 'Images', 'error.png');

            % Create InputForceFileSearchButton
            app.InputForceFileSearchButton = uibutton(app.InputsTab, 'push');
            app.InputForceFileSearchButton.ButtonPushedFcn = createCallbackFcn(app, @InputForceFileSearchButtonPushed, true);
            app.InputForceFileSearchButton.Icon = fullfile(pathToMLAPP, '..', 'Images', 'folderIcon.svg');
            app.InputForceFileSearchButton.VerticalAlignment = 'bottom';
            app.InputForceFileSearchButton.BackgroundColor = [0.1294 0.1804 0.4];
            app.InputForceFileSearchButton.Position = [822 361 31 30];
            app.InputForceFileSearchButton.Text = '';

            % Create InputForceFileEditField
            app.InputForceFileEditField = uieditfield(app.InputsTab, 'text');
            app.InputForceFileEditField.ValueChangedFcn = createCallbackFcn(app, @InputForceFileEditFieldValueChanged, true);
            app.InputForceFileEditField.Position = [218 361 587 30];

            % Create InputForceFileLabel
            app.InputForceFileLabel = uilabel(app.InputsTab);
            app.InputForceFileLabel.HorizontalAlignment = 'right';
            app.InputForceFileLabel.FontSize = 18;
            app.InputForceFileLabel.FontWeight = 'bold';
            app.InputForceFileLabel.Position = [10 361 198 30];
            app.InputForceFileLabel.Text = 'Input Force File';

            % Create ContactSurfacesTab
            app.ContactSurfacesTab = uitab(app.TabGroup);
            app.ContactSurfacesTab.BackgroundColor = [0.851 0.851 0.851];

            % Create ContactSurfacesLabel
            app.ContactSurfacesLabel = uilabel(app.ContactSurfacesTab);
            app.ContactSurfacesLabel.HorizontalAlignment = 'center';
            app.ContactSurfacesLabel.FontSize = 18;
            app.ContactSurfacesLabel.FontWeight = 'bold';
            app.ContactSurfacesLabel.Position = [22 331 204 44];
            app.ContactSurfacesLabel.Text = {'Contact'; 'Surfaces'};

            % Create ContactSurfacesTable
            app.ContactSurfacesTable = uitable(app.ContactSurfacesTab);
            app.ContactSurfacesTable.ColumnName = {''; 'Contact Surface'};
            app.ContactSurfacesTable.ColumnWidth = {30, 'auto'};
            app.ContactSurfacesTable.RowName = {};
            app.ContactSurfacesTable.ColumnSortable = [false true];
            app.ContactSurfacesTable.SelectionType = 'row';
            app.ContactSurfacesTable.ColumnEditable = true;
            app.ContactSurfacesTable.RowStriping = 'off';
            app.ContactSurfacesTable.Multiselect = 'off';
            app.ContactSurfacesTable.SelectionChangedFcn = createCallbackFcn(app, @ContactSurfacesTableSelectionChanged, true);
            app.ContactSurfacesTable.CellEditCallback = createCallbackFcn(app, @ContactSurfacesTableCellEdit, true);
            app.ContactSurfacesTable.FontSize = 18;
            app.ContactSurfacesTable.Position = [22 87 204 242];

            % Create ContactSurfacesStatus
            app.ContactSurfacesStatus = uiimage(app.ContactSurfacesTab);
            app.ContactSurfacesStatus.Visible = 'off';
            app.ContactSurfacesStatus.Position = [180 338 28 30];
            app.ContactSurfacesStatus.ImageSource = fullfile(pathToMLAPP, '..', 'Images', 'error.png');

            % Create IsLeftFootCheckBox
            app.IsLeftFootCheckBox = uicheckbox(app.ContactSurfacesTab);
            app.IsLeftFootCheckBox.ValueChangedFcn = createCallbackFcn(app, @IsLeftFootCheckBoxValueChanged, true);
            app.IsLeftFootCheckBox.Text = 'Is Left Foot';
            app.IsLeftFootCheckBox.FontSize = 18;
            app.IsLeftFootCheckBox.FontWeight = 'bold';
            app.IsLeftFootCheckBox.Position = [278 536 119 22];

            % Create StartTimeEditFieldLabel
            app.StartTimeEditFieldLabel = uilabel(app.ContactSurfacesTab);
            app.StartTimeEditFieldLabel.HorizontalAlignment = 'right';
            app.StartTimeEditFieldLabel.FontSize = 18;
            app.StartTimeEditFieldLabel.FontWeight = 'bold';
            app.StartTimeEditFieldLabel.Position = [277 500 93 23];
            app.StartTimeEditFieldLabel.Text = 'Start Time';

            % Create StartTimeEditField
            app.StartTimeEditField = uieditfield(app.ContactSurfacesTab, 'numeric');
            app.StartTimeEditField.ValueChangedFcn = createCallbackFcn(app, @StartTimeEditFieldValueChanged, true);
            app.StartTimeEditField.FontSize = 18;
            app.StartTimeEditField.Position = [385 499 100 24];

            % Create EndTimeEditFieldLabel
            app.EndTimeEditFieldLabel = uilabel(app.ContactSurfacesTab);
            app.EndTimeEditFieldLabel.HorizontalAlignment = 'right';
            app.EndTimeEditFieldLabel.FontSize = 18;
            app.EndTimeEditFieldLabel.FontWeight = 'bold';
            app.EndTimeEditFieldLabel.Position = [524 500 86 23];
            app.EndTimeEditFieldLabel.Text = 'End Time';

            % Create EndTimeEditField
            app.EndTimeEditField = uieditfield(app.ContactSurfacesTab, 'numeric');
            app.EndTimeEditField.ValueChangedFcn = createCallbackFcn(app, @EndTimeEditFieldValueChanged, true);
            app.EndTimeEditField.FontSize = 18;
            app.EndTimeEditField.Position = [625 499 100 24];

            % Create BeltSpeedEditFieldLabel
            app.BeltSpeedEditFieldLabel = uilabel(app.ContactSurfacesTab);
            app.BeltSpeedEditFieldLabel.HorizontalAlignment = 'right';
            app.BeltSpeedEditFieldLabel.FontSize = 18;
            app.BeltSpeedEditFieldLabel.FontWeight = 'bold';
            app.BeltSpeedEditFieldLabel.Position = [273 459 98 23];
            app.BeltSpeedEditFieldLabel.Text = 'Belt Speed';

            % Create BeltSpeedEditField
            app.BeltSpeedEditField = uieditfield(app.ContactSurfacesTab, 'numeric');
            app.BeltSpeedEditField.ValueChangedFcn = createCallbackFcn(app, @BeltSpeedEditFieldValueChanged, true);
            app.BeltSpeedEditField.FontSize = 18;
            app.BeltSpeedEditField.Position = [385 458 100 24];

            % Create ForceColumnsLabel
            app.ForceColumnsLabel = uilabel(app.ContactSurfacesTab);
            app.ForceColumnsLabel.HorizontalAlignment = 'right';
            app.ForceColumnsLabel.FontSize = 18;
            app.ForceColumnsLabel.FontWeight = 'bold';
            app.ForceColumnsLabel.Position = [268 396 82 44];
            app.ForceColumnsLabel.Text = {'Force'; 'Columns'};

            % Create ForceColumnsDropDown
            app.ForceColumnsDropDown = uidropdown(app.ContactSurfacesTab);
            app.ForceColumnsDropDown.Items = {};
            app.ForceColumnsDropDown.Editable = 'on';
            app.ForceColumnsDropDown.ValueChangedFcn = createCallbackFcn(app, @ForceColumnsDropDownValueChanged, true);
            app.ForceColumnsDropDown.FontSize = 15;
            app.ForceColumnsDropDown.Position = [366 408 164 22];

            % Create MomentColumnsLabel
            app.MomentColumnsLabel = uilabel(app.ContactSurfacesTab);
            app.MomentColumnsLabel.HorizontalAlignment = 'right';
            app.MomentColumnsLabel.FontSize = 18;
            app.MomentColumnsLabel.FontWeight = 'bold';
            app.MomentColumnsLabel.Position = [272 337 82 44];
            app.MomentColumnsLabel.Text = {'Moment'; 'Columns'};

            % Create MomentColumnsDropDown
            app.MomentColumnsDropDown = uidropdown(app.ContactSurfacesTab);
            app.MomentColumnsDropDown.Items = {};
            app.MomentColumnsDropDown.Editable = 'on';
            app.MomentColumnsDropDown.ValueChangedFcn = createCallbackFcn(app, @MomentColumnsDropDownValueChanged, true);
            app.MomentColumnsDropDown.FontSize = 15;
            app.MomentColumnsDropDown.Position = [367 349 163 22];

            % Create ElectricalCenterColumnsDropDownLabel
            app.ElectricalCenterColumnsDropDownLabel = uilabel(app.ContactSurfacesTab);
            app.ElectricalCenterColumnsDropDownLabel.HorizontalAlignment = 'right';
            app.ElectricalCenterColumnsDropDownLabel.FontSize = 18;
            app.ElectricalCenterColumnsDropDownLabel.FontWeight = 'bold';
            app.ElectricalCenterColumnsDropDownLabel.Position = [271 263 85 66];
            app.ElectricalCenterColumnsDropDownLabel.Text = {'Electrical'; 'Center'; 'Columns'};

            % Create ElectricalCenterColumnsDropDown
            app.ElectricalCenterColumnsDropDown = uidropdown(app.ContactSurfacesTab);
            app.ElectricalCenterColumnsDropDown.Items = {};
            app.ElectricalCenterColumnsDropDown.Editable = 'on';
            app.ElectricalCenterColumnsDropDown.ValueChangedFcn = createCallbackFcn(app, @ElectricalCenterColumnsDropDownValueChanged, true);
            app.ElectricalCenterColumnsDropDown.FontSize = 15;
            app.ElectricalCenterColumnsDropDown.Position = [368 286 162 22];

            % Create ElectricalCenterColumnsDropDown_2
            app.ElectricalCenterColumnsDropDown_2 = uidropdown(app.ContactSurfacesTab);
            app.ElectricalCenterColumnsDropDown_2.Items = {};
            app.ElectricalCenterColumnsDropDown_2.Editable = 'on';
            app.ElectricalCenterColumnsDropDown_2.ValueChangedFcn = createCallbackFcn(app, @ElectricalCenterColumnsDropDown_2ValueChanged, true);
            app.ElectricalCenterColumnsDropDown_2.FontSize = 15;
            app.ElectricalCenterColumnsDropDown_2.Position = [540 286 163 22];

            % Create ElectricalCenterColumnsDropDown_3
            app.ElectricalCenterColumnsDropDown_3 = uidropdown(app.ContactSurfacesTab);
            app.ElectricalCenterColumnsDropDown_3.Items = {};
            app.ElectricalCenterColumnsDropDown_3.Editable = 'on';
            app.ElectricalCenterColumnsDropDown_3.ValueChangedFcn = createCallbackFcn(app, @ElectricalCenterColumnsDropDown_3ValueChanged, true);
            app.ElectricalCenterColumnsDropDown_3.FontSize = 15;
            app.ElectricalCenterColumnsDropDown_3.Position = [711 286 163 22];

            % Create MomentColumnsDropDown_2
            app.MomentColumnsDropDown_2 = uidropdown(app.ContactSurfacesTab);
            app.MomentColumnsDropDown_2.Items = {};
            app.MomentColumnsDropDown_2.Editable = 'on';
            app.MomentColumnsDropDown_2.ValueChangedFcn = createCallbackFcn(app, @MomentColumnsDropDown_2ValueChanged, true);
            app.MomentColumnsDropDown_2.FontSize = 15;
            app.MomentColumnsDropDown_2.Position = [540 349 163 22];

            % Create MomentColumnsDropDown_3
            app.MomentColumnsDropDown_3 = uidropdown(app.ContactSurfacesTab);
            app.MomentColumnsDropDown_3.Items = {};
            app.MomentColumnsDropDown_3.Editable = 'on';
            app.MomentColumnsDropDown_3.ValueChangedFcn = createCallbackFcn(app, @MomentColumnsDropDown_3ValueChanged, true);
            app.MomentColumnsDropDown_3.FontSize = 15;
            app.MomentColumnsDropDown_3.Position = [711 349 163 22];

            % Create ForceColumnsDropDown_2
            app.ForceColumnsDropDown_2 = uidropdown(app.ContactSurfacesTab);
            app.ForceColumnsDropDown_2.Items = {};
            app.ForceColumnsDropDown_2.Editable = 'on';
            app.ForceColumnsDropDown_2.ValueChangedFcn = createCallbackFcn(app, @ForceColumnsDropDown_2ValueChanged, true);
            app.ForceColumnsDropDown_2.FontSize = 15;
            app.ForceColumnsDropDown_2.Position = [540 407 163 22];

            % Create ForceColumnsDropDown_3
            app.ForceColumnsDropDown_3 = uidropdown(app.ContactSurfacesTab);
            app.ForceColumnsDropDown_3.Items = {};
            app.ForceColumnsDropDown_3.Editable = 'on';
            app.ForceColumnsDropDown_3.ValueChangedFcn = createCallbackFcn(app, @ForceColumnsDropDown_3ValueChanged, true);
            app.ForceColumnsDropDown_3.FontSize = 15;
            app.ForceColumnsDropDown_3.Position = [711 407 163 22];

            % Create HindfootBodyNameLabel
            app.HindfootBodyNameLabel = uilabel(app.ContactSurfacesTab);
            app.HindfootBodyNameLabel.HorizontalAlignment = 'right';
            app.HindfootBodyNameLabel.FontSize = 18;
            app.HindfootBodyNameLabel.FontWeight = 'bold';
            app.HindfootBodyNameLabel.Position = [440 185 79 44];
            app.HindfootBodyNameLabel.Text = {'Hindfoot'; 'Body'};

            % Create HindfootBodyDropDown
            app.HindfootBodyDropDown = uidropdown(app.ContactSurfacesTab);
            app.HindfootBodyDropDown.Items = {};
            app.HindfootBodyDropDown.Editable = 'on';
            app.HindfootBodyDropDown.ValueChangedFcn = createCallbackFcn(app, @HindfootBodyDropDownValueChanged, true);
            app.HindfootBodyDropDown.FontSize = 15;
            app.HindfootBodyDropDown.Position = [531 196 162 22];

            % Create ToeMarkerDropDownLabel
            app.ToeMarkerDropDownLabel = uilabel(app.ContactSurfacesTab);
            app.ToeMarkerDropDownLabel.HorizontalAlignment = 'right';
            app.ToeMarkerDropDownLabel.FontSize = 18;
            app.ToeMarkerDropDownLabel.FontWeight = 'bold';
            app.ToeMarkerDropDownLabel.Position = [297 121 100 23];
            app.ToeMarkerDropDownLabel.Text = 'Toe Marker';

            % Create ToeMarkerDropDown
            app.ToeMarkerDropDown = uidropdown(app.ContactSurfacesTab);
            app.ToeMarkerDropDown.Items = {};
            app.ToeMarkerDropDown.Editable = 'on';
            app.ToeMarkerDropDown.ValueChangedFcn = createCallbackFcn(app, @ToeMarkerDropDownValueChanged, true);
            app.ToeMarkerDropDown.FontSize = 15;
            app.ToeMarkerDropDown.Position = [403 121 152 22];

            % Create MedialMarkerLabel
            app.MedialMarkerLabel = uilabel(app.ContactSurfacesTab);
            app.MedialMarkerLabel.HorizontalAlignment = 'right';
            app.MedialMarkerLabel.FontSize = 18;
            app.MedialMarkerLabel.FontWeight = 'bold';
            app.MedialMarkerLabel.Position = [587 121 125 23];
            app.MedialMarkerLabel.Text = 'Medial Marker';

            % Create MedialMarkerDropDown
            app.MedialMarkerDropDown = uidropdown(app.ContactSurfacesTab);
            app.MedialMarkerDropDown.Items = {};
            app.MedialMarkerDropDown.Editable = 'on';
            app.MedialMarkerDropDown.ValueChangedFcn = createCallbackFcn(app, @MedialMarkerDropDownValueChanged, true);
            app.MedialMarkerDropDown.FontSize = 15;
            app.MedialMarkerDropDown.Position = [720 121 154 22];

            % Create LateralMarkerDropDownLabel
            app.LateralMarkerDropDownLabel = uilabel(app.ContactSurfacesTab);
            app.LateralMarkerDropDownLabel.HorizontalAlignment = 'right';
            app.LateralMarkerDropDownLabel.FontSize = 18;
            app.LateralMarkerDropDownLabel.FontWeight = 'bold';
            app.LateralMarkerDropDownLabel.Position = [269 81 128 23];
            app.LateralMarkerDropDownLabel.Text = 'Lateral Marker';

            % Create LateralMarkerDropDown
            app.LateralMarkerDropDown = uidropdown(app.ContactSurfacesTab);
            app.LateralMarkerDropDown.Items = {};
            app.LateralMarkerDropDown.Editable = 'on';
            app.LateralMarkerDropDown.ValueChangedFcn = createCallbackFcn(app, @LateralMarkerDropDownValueChanged, true);
            app.LateralMarkerDropDown.FontSize = 15;
            app.LateralMarkerDropDown.Position = [403 81 152 22];

            % Create HeelMarkerDropDownLabel
            app.HeelMarkerDropDownLabel = uilabel(app.ContactSurfacesTab);
            app.HeelMarkerDropDownLabel.HorizontalAlignment = 'right';
            app.HeelMarkerDropDownLabel.FontSize = 18;
            app.HeelMarkerDropDownLabel.FontWeight = 'bold';
            app.HeelMarkerDropDownLabel.Position = [605 81 107 23];
            app.HeelMarkerDropDownLabel.Text = 'Heel Marker';

            % Create HeelMarkerDropDown
            app.HeelMarkerDropDown = uidropdown(app.ContactSurfacesTab);
            app.HeelMarkerDropDown.Items = {};
            app.HeelMarkerDropDown.Editable = 'on';
            app.HeelMarkerDropDown.ValueChangedFcn = createCallbackFcn(app, @HeelMarkerDropDownValueChanged, true);
            app.HeelMarkerDropDown.FontSize = 15;
            app.HeelMarkerDropDown.Position = [720 81 154 22];

            % Create MidfootSuperiorMarkerLabel
            app.MidfootSuperiorMarkerLabel = uilabel(app.ContactSurfacesTab);
            app.MidfootSuperiorMarkerLabel.HorizontalAlignment = 'right';
            app.MidfootSuperiorMarkerLabel.FontSize = 18;
            app.MidfootSuperiorMarkerLabel.FontWeight = 'bold';
            app.MidfootSuperiorMarkerLabel.Position = [248 30 149 44];
            app.MidfootSuperiorMarkerLabel.Text = {'Midfoot Superior'; 'Marker'};

            % Create MidfootSuperiorMarkerDropDown
            app.MidfootSuperiorMarkerDropDown = uidropdown(app.ContactSurfacesTab);
            app.MidfootSuperiorMarkerDropDown.Items = {};
            app.MidfootSuperiorMarkerDropDown.Editable = 'on';
            app.MidfootSuperiorMarkerDropDown.ValueChangedFcn = createCallbackFcn(app, @MidfootSuperiorMarkerDropDownValueChanged, true);
            app.MidfootSuperiorMarkerDropDown.FontSize = 15;
            app.MidfootSuperiorMarkerDropDown.Position = [403 41 152 22];

            % Create GridWidthEditFieldLabel
            app.GridWidthEditFieldLabel = uilabel(app.ContactSurfacesTab);
            app.GridWidthEditFieldLabel.HorizontalAlignment = 'right';
            app.GridWidthEditFieldLabel.FontSize = 18;
            app.GridWidthEditFieldLabel.FontWeight = 'bold';
            app.GridWidthEditFieldLabel.Position = [14 488 97 23];
            app.GridWidthEditFieldLabel.Text = 'Grid Width';

            % Create GridWidthEditField
            app.GridWidthEditField = uieditfield(app.ContactSurfacesTab, 'numeric');
            app.GridWidthEditField.ValueChangedFcn = createCallbackFcn(app, @GridWidthEditFieldValueChanged, true);
            app.GridWidthEditField.Limits = [1 Inf];
            app.GridWidthEditField.FontSize = 18;
            app.GridWidthEditField.Position = [126 487 100 24];
            app.GridWidthEditField.Value = 5;

            % Create GridHeightEditFieldLabel
            app.GridHeightEditFieldLabel = uilabel(app.ContactSurfacesTab);
            app.GridHeightEditFieldLabel.HorizontalAlignment = 'right';
            app.GridHeightEditFieldLabel.FontSize = 18;
            app.GridHeightEditFieldLabel.FontWeight = 'bold';
            app.GridHeightEditFieldLabel.Position = [8 449 103 23];
            app.GridHeightEditFieldLabel.Text = 'Grid Height';

            % Create GridHeightEditField
            app.GridHeightEditField = uieditfield(app.ContactSurfacesTab, 'numeric');
            app.GridHeightEditField.ValueChangedFcn = createCallbackFcn(app, @GridHeightEditFieldValueChanged, true);
            app.GridHeightEditField.Limits = [1 Inf];
            app.GridHeightEditField.FontSize = 18;
            app.GridHeightEditField.Position = [126 448 100 24];
            app.GridHeightEditField.Value = 15;

            % Create TimeRangeStatus
            app.TimeRangeStatus = uiimage(app.ContactSurfacesTab);
            app.TimeRangeStatus.Visible = 'off';
            app.TimeRangeStatus.Position = [745 496 28 30];
            app.TimeRangeStatus.ImageSource = fullfile(pathToMLAPP, '..', 'Images', 'error.png');

            % Create ForceColumnsStatus
            app.ForceColumnsStatus = uiimage(app.ContactSurfacesTab);
            app.ForceColumnsStatus.Visible = 'off';
            app.ForceColumnsStatus.Position = [879 403 28 30];
            app.ForceColumnsStatus.ImageSource = fullfile(pathToMLAPP, '..', 'Images', 'error.png');

            % Create MomentColumnsStatus
            app.MomentColumnsStatus = uiimage(app.ContactSurfacesTab);
            app.MomentColumnsStatus.Visible = 'off';
            app.MomentColumnsStatus.Position = [879 345 28 30];
            app.MomentColumnsStatus.ImageSource = fullfile(pathToMLAPP, '..', 'Images', 'error.png');

            % Create ElectricalCenterColumnsStatus
            app.ElectricalCenterColumnsStatus = uiimage(app.ContactSurfacesTab);
            app.ElectricalCenterColumnsStatus.Visible = 'off';
            app.ElectricalCenterColumnsStatus.Position = [879 282 28 30];
            app.ElectricalCenterColumnsStatus.ImageSource = fullfile(pathToMLAPP, '..', 'Images', 'error.png');

            % Create HindfootBodyStatus
            app.HindfootBodyStatus = uiimage(app.ContactSurfacesTab);
            app.HindfootBodyStatus.Visible = 'off';
            app.HindfootBodyStatus.Position = [697 192 28 30];
            app.HindfootBodyStatus.ImageSource = fullfile(pathToMLAPP, '..', 'Images', 'error.png');

            % Create ToeMarkerStatus
            app.ToeMarkerStatus = uiimage(app.ContactSurfacesTab);
            app.ToeMarkerStatus.Visible = 'off';
            app.ToeMarkerStatus.Position = [558 117 28 30];
            app.ToeMarkerStatus.ImageSource = fullfile(pathToMLAPP, '..', 'Images', 'error.png');

            % Create MedialMarkerStatus
            app.MedialMarkerStatus = uiimage(app.ContactSurfacesTab);
            app.MedialMarkerStatus.Visible = 'off';
            app.MedialMarkerStatus.Position = [879 117 28 30];
            app.MedialMarkerStatus.ImageSource = fullfile(pathToMLAPP, '..', 'Images', 'error.png');

            % Create HeelMarkerStatus
            app.HeelMarkerStatus = uiimage(app.ContactSurfacesTab);
            app.HeelMarkerStatus.Visible = 'off';
            app.HeelMarkerStatus.Position = [879 77 28 30];
            app.HeelMarkerStatus.ImageSource = fullfile(pathToMLAPP, '..', 'Images', 'error.png');

            % Create LateralMarkerStatus
            app.LateralMarkerStatus = uiimage(app.ContactSurfacesTab);
            app.LateralMarkerStatus.Visible = 'off';
            app.LateralMarkerStatus.Position = [558 77 28 30];
            app.LateralMarkerStatus.ImageSource = fullfile(pathToMLAPP, '..', 'Images', 'error.png');

            % Create MidfootSuperiorMarkerStatus
            app.MidfootSuperiorMarkerStatus = uiimage(app.ContactSurfacesTab);
            app.MidfootSuperiorMarkerStatus.Visible = 'off';
            app.MidfootSuperiorMarkerStatus.Position = [558 37 28 30];
            app.MidfootSuperiorMarkerStatus.ImageSource = fullfile(pathToMLAPP, '..', 'Images', 'error.png');

            % Create GCPTasksTab
            app.GCPTasksTab = uitab(app.TabGroup);
            app.GCPTasksTab.BackgroundColor = [0.851 0.851 0.851];

            % Create CostTermPanel
            app.CostTermPanel = uipanel(app.GCPTasksTab);
            app.CostTermPanel.BackgroundColor = [1 1 1];
            app.CostTermPanel.FontWeight = 'bold';
            app.CostTermPanel.FontSize = 18;
            app.CostTermPanel.Position = [275 1 559 277];

            % Create MaxAllowableErrorEditField_2Label
            app.MaxAllowableErrorEditField_2Label = uilabel(app.CostTermPanel);
            app.MaxAllowableErrorEditField_2Label.HorizontalAlignment = 'center';
            app.MaxAllowableErrorEditField_2Label.WordWrap = 'on';
            app.MaxAllowableErrorEditField_2Label.FontSize = 18;
            app.MaxAllowableErrorEditField_2Label.Position = [44 11 116 44];
            app.MaxAllowableErrorEditField_2Label.Text = 'Max Allowable Error';

            % Create MaxAllowableErrorEditField
            app.MaxAllowableErrorEditField = uieditfield(app.CostTermPanel, 'numeric');
            app.MaxAllowableErrorEditField.Limits = [1e-08 Inf];
            app.MaxAllowableErrorEditField.AllowEmpty = 'on';
            app.MaxAllowableErrorEditField.FontSize = 18;
            app.MaxAllowableErrorEditField.Position = [173 21 78 24];
            app.MaxAllowableErrorEditField.ValueChangedFcn = createCallbackFcn(app, @MaxAllowableErrorEditFieldValueChanged, true);
            app.MaxAllowableErrorEditField.Value = [];

            % Create ErrorCenterEditField_2Label
            app.ErrorCenterEditField_2Label = uilabel(app.CostTermPanel);
            app.ErrorCenterEditField_2Label.HorizontalAlignment = 'right';
            app.ErrorCenterEditField_2Label.FontSize = 18;
            app.ErrorCenterEditField_2Label.Position = [316 22 104 23];
            app.ErrorCenterEditField_2Label.Text = 'Error Center';

            % Create ErrorCenterEditField
            app.ErrorCenterEditField = uieditfield(app.CostTermPanel, 'numeric');
            app.ErrorCenterEditField.AllowEmpty = 'on';
            app.ErrorCenterEditField.FontSize = 18;
            app.ErrorCenterEditField.Position = [436 21 77 24];
            app.ErrorCenterEditField.ValueChangedFcn = createCallbackFcn(app, @ErrorCenterEditFieldValueChanged, true);
            app.ErrorCenterEditField.Value = [];

            % Create CostTermsTable
            app.CostTermsTable = uitable(app.CostTermPanel);
            app.CostTermsTable.ColumnName = {''; 'Cost Term'};
            app.CostTermsTable.ColumnWidth = {30, 'auto'};
            app.CostTermsTable.RowName = {};
            app.CostTermsTable.SelectionType = 'row';
            app.CostTermsTable.ColumnEditable = [true false];
            app.CostTermsTable.RowStriping = 'off';
            app.CostTermsTable.Multiselect = 'off';
            app.CostTermsTable.CellEditCallback = createCallbackFcn(app, @CostTermsTableCellEdit, true);
            app.CostTermsTable.SelectionChangedFcn = createCallbackFcn(app, @CostTermsTableSelectionChanged, true);
            app.CostTermsTable.FontSize = 18;
            app.CostTermsTable.Position = [1 63 556 213];

            % Create EditCostTermsLabel
            app.EditCostTermsLabel = uilabel(app.GCPTasksTab);
            app.EditCostTermsLabel.FontSize = 18;
            app.EditCostTermsLabel.FontWeight = 'bold';
            app.EditCostTermsLabel.Position = [484 285 142 23];
            app.EditCostTermsLabel.Text = 'Edit Cost Terms';

            % Create EditDesignVariablesLabel
            app.EditDesignVariablesLabel = uilabel(app.GCPTasksTab);
            app.EditDesignVariablesLabel.FontSize = 18;
            app.EditDesignVariablesLabel.FontWeight = 'bold';
            app.EditDesignVariablesLabel.Position = [460 543 188 23];
            app.EditDesignVariablesLabel.Text = 'Edit Design Variables';

            % Create DesignVariablesTable
            app.DesignVariablesTable = uitable(app.GCPTasksTab);
            app.DesignVariablesTable.ColumnName = {''; 'Design Variable'};
            app.DesignVariablesTable.ColumnWidth = {30, 'auto'};
            app.DesignVariablesTable.RowName = {};
            app.DesignVariablesTable.SelectionType = 'row';
            app.DesignVariablesTable.ColumnEditable = [true false];
            app.DesignVariablesTable.RowStriping = 'off';
            app.DesignVariablesTable.Multiselect = 'off';
            app.DesignVariablesTable.CellEditCallback = createCallbackFcn(app, @DesignVariablesTableCellEdit, true);
            app.DesignVariablesTable.FontSize = 18;
            app.DesignVariablesTable.Position = [276 360 558 174];

            % Create TasksLabel
            app.TasksLabel = uilabel(app.GCPTasksTab);
            app.TasksLabel.HorizontalAlignment = 'center';
            app.TasksLabel.FontSize = 18;
            app.TasksLabel.FontWeight = 'bold';
            app.TasksLabel.Position = [97 423 55 23];
            app.TasksLabel.Text = 'Tasks';

            % Create TasksTable
            app.TasksTable = uitable(app.GCPTasksTab);
            app.TasksTable.ColumnName = {''; 'Task'};
            app.TasksTable.ColumnWidth = {30, 'auto'};
            app.TasksTable.RowName = {};
            app.TasksTable.ColumnSortable = [false false];
            app.TasksTable.SelectionType = 'row';
            app.TasksTable.ColumnEditable = true;
            app.TasksTable.RowStriping = 'off';
            app.TasksTable.Multiselect = 'off';
            app.TasksTable.SelectionChangedFcn = createCallbackFcn(app, @TasksTableSelectionChanged, true);
            app.TasksTable.CellEditCallback = createCallbackFcn(app, @TasksTableCellEdit, true);
            app.TasksTable.FontSize = 18;
            app.TasksTable.Position = [39 176 172 242];

            % Create MoveTaskUpButton
            app.MoveTaskUpButton = uibutton(app.GCPTasksTab, 'push');
            app.MoveTaskUpButton.Icon = fullfile(pathToMLAPP, '..', 'Images', 'ArrowUp.svg');
            app.MoveTaskUpButton.IconAlignment = 'center';
            app.MoveTaskUpButton.BackgroundColor = [0.1294 0.1804 0.4];
            app.MoveTaskUpButton.Position = [220 310 25 25];
            app.MoveTaskUpButton.ButtonPushedFcn = createCallbackFcn(app, @MoveTaskUpButtonPushed, true);
            app.MoveTaskUpButton.Text = '';

            % Create MoveTaskDownButton
            app.MoveTaskDownButton = uibutton(app.GCPTasksTab, 'push');
            app.MoveTaskDownButton.Icon = fullfile(pathToMLAPP, '..', 'Images', 'ArrowDown.svg');
            app.MoveTaskDownButton.IconAlignment = 'center';
            app.MoveTaskDownButton.BackgroundColor = [0.1294 0.1804 0.4];
            app.MoveTaskDownButton.Position = [220 256 25 25];
            app.MoveTaskDownButton.ButtonPushedFcn = createCallbackFcn(app, @MoveTaskDownButtonPushed, true);
            app.MoveTaskDownButton.Text = '';

            % Create TasksStatus
            app.TasksStatus = uiimage(app.GCPTasksTab);
            app.TasksStatus.Visible = 'off';
            app.TasksStatus.Position = [157 419 28 30];
            app.TasksStatus.ImageSource = fullfile(pathToMLAPP, '..', 'Images', 'error.png');

            % Create CostTermsStatus
            app.CostTermsStatus = uiimage(app.GCPTasksTab);
            app.CostTermsStatus.Visible = 'off';
            app.CostTermsStatus.Position = [629 282 28 30];
            app.CostTermsStatus.ImageSource = fullfile(pathToMLAPP, '..', 'Images', 'error.png');

            % Create DesignVariablesStatus
            app.DesignVariablesStatus = uiimage(app.GCPTasksTab);
            app.DesignVariablesStatus.Visible = 'off';
            app.DesignVariablesStatus.Position = [651 539 28 30];
            app.DesignVariablesStatus.ImageSource = fullfile(pathToMLAPP, '..', 'Images', 'error.png');

            % Create NeighborStandardDeviationEditFieldLabel
            app.NeighborStandardDeviationEditFieldLabel = uilabel(app.GCPTasksTab);
            app.NeighborStandardDeviationEditFieldLabel.HorizontalAlignment = 'right';
            app.NeighborStandardDeviationEditFieldLabel.FontSize = 18;
            app.NeighborStandardDeviationEditFieldLabel.FontWeight = 'bold';
            app.NeighborStandardDeviationEditFieldLabel.Position = [276 322 255 23];
            app.NeighborStandardDeviationEditFieldLabel.Text = 'Neighbor Standard Deviation';

            % Create NeighborStandardDeviationEditField
            app.NeighborStandardDeviationEditField = uieditfield(app.GCPTasksTab, 'numeric');
            app.NeighborStandardDeviationEditField.Limits = [0 Inf];
            app.NeighborStandardDeviationEditField.FontSize = 18;
            app.NeighborStandardDeviationEditField.Position = [553 321 100 24];
            app.NeighborStandardDeviationEditField.ValueChangedFcn = createCallbackFcn(app, @NeighborStandardDeviationEditFieldValueChanged, true);
            app.NeighborStandardDeviationEditField.Value = 0.2;

            % Create AdvancedTab
            app.AdvancedTab = uitab(app.TabGroup);
            app.AdvancedTab.BackgroundColor = [0.851 0.851 0.851];

            % Create AdvancedSettingsTable
            app.AdvancedSettingsTable = uitable(app.AdvancedTab);
            app.AdvancedSettingsTable.ColumnName = {'Option'; 'Value'};
            app.AdvancedSettingsTable.RowName = {};
            app.AdvancedSettingsTable.SelectionType = 'row';
            app.AdvancedSettingsTable.ColumnEditable = [false true];
            app.AdvancedSettingsTable.CellEditCallback = createCallbackFcn(app, @AdvancedSettingsTableCellEdit, true);
            app.AdvancedSettingsTable.FontSize = 20;
            app.AdvancedSettingsTable.Position = [121 94 674 407];

            % Create AdvancedSettingsStatus
            app.AdvancedSettingsStatus = uiimage(app.AdvancedTab);
            app.AdvancedSettingsStatus.Visible = 'off';
            app.AdvancedSettingsStatus.Position = [446 507 28 30];
            app.AdvancedSettingsStatus.ImageSource = fullfile(pathToMLAPP, '..', 'Images', 'error.png');

            % Create Mask1
            app.Mask1 = uiimage(app.UIFigure);
            app.Mask1.ScaleMethod = 'fill';
            app.Mask1.Position = [211 644 912 30];
            app.Mask1.ImageSource = fullfile(pathToMLAPP, '..', 'Images', 'greyMask.png');

            % Create GcpImage
            app.GcpImage = uiimage(app.UIFigure);
            app.GcpImage.Position = [1 193 178 420];
            app.GcpImage.ImageSource = fullfile(pathToMLAPP, '..', 'Images', 'gcpFigure.png');

            % Create AdvancedButton
            app.AdvancedButton = uibutton(app.UIFigure, 'push');
            app.AdvancedButton.ButtonPushedFcn = createCallbackFcn(app, @AdvancedButtonPushed, true);
            app.AdvancedButton.BackgroundColor = [0.1294 0.1804 0.4];
            app.AdvancedButton.FontSize = 18;
            app.AdvancedButton.FontColor = [1 1 1];
            app.AdvancedButton.Position = [599 643 100 30];
            app.AdvancedButton.Text = 'Advanced';

            % Create GCPTasksButton
            app.GCPTasksButton = uibutton(app.UIFigure, 'push');
            app.GCPTasksButton.ButtonPushedFcn = createCallbackFcn(app, @GCPTasksButtonPushed, true);
            app.GCPTasksButton.BackgroundColor = [0.1294 0.1804 0.4];
            app.GCPTasksButton.FontSize = 18;
            app.GCPTasksButton.FontColor = [1 1 1];
            app.GCPTasksButton.Position = [488 643 104 30];
            app.GCPTasksButton.Text = 'GCP Tasks';

            % Create ContactSurfacesButton
            app.ContactSurfacesButton = uibutton(app.UIFigure, 'push');
            app.ContactSurfacesButton.ButtonPushedFcn = createCallbackFcn(app, @ContactSurfacesButtonPushed, true);
            app.ContactSurfacesButton.BackgroundColor = [0.1294 0.1804 0.4];
            app.ContactSurfacesButton.FontSize = 18;
            app.ContactSurfacesButton.FontColor = [1 1 1];
            app.ContactSurfacesButton.Position = [328 643 153 30];
            app.ContactSurfacesButton.Text = 'Contact Surfaces';

            % Create InputsButton
            app.InputsButton = uibutton(app.UIFigure, 'push');
            app.InputsButton.ButtonPushedFcn = createCallbackFcn(app, @InputsButtonPushed, true);
            app.InputsButton.BackgroundColor = [0.1294 0.1804 0.4];
            app.InputsButton.FontSize = 18;
            app.InputsButton.FontColor = [1 1 1];
            app.InputsButton.Position = [211 643 110 30];
            app.InputsButton.Text = 'GCP Inputs';

            % Create RcnlLogo
            app.RcnlLogo = uiimage(app.UIFigure);
            app.RcnlLogo.ImageClickedFcn = createCallbackFcn(app, @RcnlLogoImageClicked, true);
            app.RcnlLogo.Position = [11 623 80 80];
            app.RcnlLogo.ImageSource = fullfile(pathToMLAPP, '..', 'Images', 'rcnlIcon.png');

            % Create LoadSettingsFileButton
            app.LoadSettingsFileButton = uibutton(app.UIFigure, 'push');
            app.LoadSettingsFileButton.ButtonPushedFcn = createCallbackFcn(app, @LoadSettingsFileButtonPushed, true);
            app.LoadSettingsFileButton.BackgroundColor = [0.1294 0.1804 0.4];
            app.LoadSettingsFileButton.FontSize = 18;
            app.LoadSettingsFileButton.FontColor = [1 1 1];
            app.LoadSettingsFileButton.Position = [645 23 90 30];
            app.LoadSettingsFileButton.Text = 'Load';

            % Create SaveButton
            app.SaveButton = uibutton(app.UIFigure, 'push');
            app.SaveButton.ButtonPushedFcn = createCallbackFcn(app, @SaveButtonPushed, true);
            app.SaveButton.BackgroundColor = [0.1294 0.1804 0.4];
            app.SaveButton.FontSize = 18;
            app.SaveButton.FontColor = [1 1 1];
            app.SaveButton.Position = [765 23 90 30];
            app.SaveButton.Text = 'Save';

            % Create HelpButton
            app.HelpButton = uibutton(app.UIFigure, 'push');
            app.HelpButton.ButtonPushedFcn = createCallbackFcn(app, @HelpButtonPushed, true);
            app.HelpButton.BackgroundColor = [0.1294 0.1804 0.4];
            app.HelpButton.FontSize = 18;
            app.HelpButton.FontColor = [1 1 1];
            app.HelpButton.Position = [1005 24 90 30];
            app.HelpButton.Text = 'Help';

            % Create RunButton
            app.RunButton = uibutton(app.UIFigure, 'push');
            app.RunButton.ButtonPushedFcn = createCallbackFcn(app, @RunButtonPushed, true);
            app.RunButton.BackgroundColor = [0.1294 0.1804 0.4];
            app.RunButton.FontSize = 18;
            app.RunButton.FontColor = [1 1 1];
            app.RunButton.Enable = 'off';
            app.RunButton.Position = [885 23 90 30];
            app.RunButton.Text = 'Run';

            % Create ResetButton
            app.ResetButton = uibutton(app.UIFigure, 'push');
            app.ResetButton.ButtonPushedFcn = createCallbackFcn(app, @ResetButtonPushed, true);
            app.ResetButton.BackgroundColor = [0.1294 0.1804 0.4];
            app.ResetButton.FontSize = 18;
            app.ResetButton.FontColor = [1 1 1];
            app.ResetButton.Position = [527 23 90 30];
            app.ResetButton.Text = 'Reset';

            % Create ContactSurfaceContextMenu
            app.ContactSurfaceContextMenu = uicontextmenu(app.UIFigure);

            % Create RenameContactSurfaceMenu
            app.RenameContactSurfaceMenu = uimenu(app.ContactSurfaceContextMenu);
            app.RenameContactSurfaceMenu.MenuSelectedFcn = createCallbackFcn(app, @RenameContactSurfaceMenuSelected, true);
            app.RenameContactSurfaceMenu.Text = 'Rename';

            % Create DeleteContactSurfaceMenu
            app.DeleteContactSurfaceMenu = uimenu(app.ContactSurfaceContextMenu);
            app.DeleteContactSurfaceMenu.MenuSelectedFcn = createCallbackFcn(app, @DeleteContactSurfaceMenuSelected, true);
            app.DeleteContactSurfaceMenu.Text = 'Delete';

            % Assign app.ContactSurfaceContextMenu
            app.ContactSurfacesTable.ContextMenu = app.ContactSurfaceContextMenu;

            % Create TaskContextMenu
            app.TaskContextMenu = uicontextmenu(app.UIFigure);

            % Create RenameTaskMenu
            app.RenameTaskMenu = uimenu(app.TaskContextMenu);
            app.RenameTaskMenu.MenuSelectedFcn = createCallbackFcn(app, @RenameTaskMenuSelected, true);
            app.RenameTaskMenu.Text = 'Rename';

            % Create DeleteTaskMenu
            app.DeleteTaskMenu = uimenu(app.TaskContextMenu);
            app.DeleteTaskMenu.MenuSelectedFcn = createCallbackFcn(app, @DeleteTaskMenuSelected, true);
            app.DeleteTaskMenu.Text = 'Delete';

            % Assign app.TaskContextMenu
            app.TasksTable.ContextMenu = app.TaskContextMenu;

            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = GCPBase

            % Create UIFigure and components
            createComponents(app)

            % Register the app with App Designer
            registerApp(app, app.UIFigure)

            % Execute the startup function
            runStartupFcn(app, @startupFcn)

            if nargout == 0
                clear app
            end
        end

        % Code that executes before app deletion
        function delete(app)

            % Delete UIFigure when app is deleted
            delete(app.UIFigure)
        end
    end
end