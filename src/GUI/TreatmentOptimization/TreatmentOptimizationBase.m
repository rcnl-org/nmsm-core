classdef TreatmentOptimizationBase < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure                        matlab.ui.Figure
        ResetButton                     matlab.ui.control.Button
        RunButton                       matlab.ui.control.Button
        HelpButton                      matlab.ui.control.Button
        SaveButton                      matlab.ui.control.Button
        LoadSettingsFileButton          matlab.ui.control.Button
        RcnlLogo                        matlab.ui.control.Image
        InputsButton                    matlab.ui.control.Button
        SolverSettingsButton            matlab.ui.control.Button
        ControllersButton               matlab.ui.control.Button
        CostTermsButton                 matlab.ui.control.Button
        ConstraintTermsButton           matlab.ui.control.Button
        AdvancedButton                  matlab.ui.control.Button
        MTPImage                        matlab.ui.control.Image
        Mask1                           matlab.ui.control.Image
        TabGroup                        matlab.ui.container.TabGroup
        InputsTab                       matlab.ui.container.Tab
        ToolSelectionDropDown           matlab.ui.control.DropDown
        ToolSelectionDropDownLabel      matlab.ui.control.Label
        InitialGuessDirectoryLabel        matlab.ui.control.Label
        InitialGuessDirectoryEditField          matlab.ui.control.EditField
        InitialGuessDirectorySearchButton        matlab.ui.control.Button
        InitialGuessDirectoryStatus             matlab.ui.control.Image
        TaskPrefixesStatus              matlab.ui.control.Image
        TrialPrefixEditField            matlab.ui.control.EditField
        TrialPrefixEditFieldLabel       matlab.ui.control.Label
        CoordinateListEditButton        matlab.ui.control.Button
        CoordinateListStatus            matlab.ui.control.Image
        ResultsDirectoryEditField       matlab.ui.control.EditField
        ResultsDirectoryEditFieldLabel  matlab.ui.control.Label
        ResultsDirectorySearchButton    matlab.ui.control.Button
        ResultsDirectoryStatus          matlab.ui.control.Image
        StatesCoordinatesListTextAreaLabel  matlab.ui.control.Label
        StatesCoordinatesListTextArea   matlab.ui.control.TextArea
        TrackedQuantitiesDirectoryLabel  matlab.ui.control.Label
        TrackedQuantitiesDirectoryStatus matlab.ui.control.Image
        TrackedQuantitiesDirectoryEditField   matlab.ui.control.EditField
        TrackedQuantitiesSearchButton   matlab.ui.control.Button
        InputOsimxFileStatus            matlab.ui.control.Image
        InputOsimxFileEditField         matlab.ui.control.EditField
        InputOsimxFileEditFieldLabel    matlab.ui.control.Label
        InputOsimxFileSearchButton      matlab.ui.control.Button
        InputModelFileStatus            matlab.ui.control.Image
        InputModelFileEditField         matlab.ui.control.EditField
        InputModelFileEditFieldLabel    matlab.ui.control.Label
        InputModelFileSearchButton      matlab.ui.control.Button
        ControllersTab                  matlab.ui.container.Tab
        TorqueControlsButton            matlab.ui.control.Button
        SynergyControlsButton           matlab.ui.control.Button
        UserDefinedControlsButton       matlab.ui.control.Button
        Mask1_2                         matlab.ui.control.Image
        ControllersTabGroup             matlab.ui.container.TabGroup
        TorqueTab                       matlab.ui.container.Tab
        TorqueControllerAdvancedSettingsStatus  matlab.ui.control.Image
        TorqueControllerAdvancedSettings  matlab.ui.control.Label
        TorqueAdvancedSettingsTable     matlab.ui.control.Table
        CoordinatesListTextAreaLabel    matlab.ui.control.Label
        TorqueControllerCoordinateList  matlab.ui.control.TextArea
        TorqueControllerCoordianteListStatus  matlab.ui.control.Image
        TorqueControllerCoordinateEditButton  matlab.ui.control.Button
        UseRCNLTorqueControllerCheckBox  matlab.ui.control.CheckBox
        SynergyTab                      matlab.ui.container.Tab
        SurrogateModelAdvancedSettingsStatus  matlab.ui.control.Image
        SurrogateModelAdvancedSettingsLabel  matlab.ui.control.Label
        SurrogateModelAdvancedSettingsTable  matlab.ui.control.Table
        MuscleActivationsFileStatus     matlab.ui.control.Image
        MuscleActivationsFileSearchButton  matlab.ui.control.Button
        MuscleActivationsFileEditField  matlab.ui.control.EditField
        MuscleActivationsFileEditFieldLabel  matlab.ui.control.Label
        SurrogateModelFileNameSearchButton  matlab.ui.control.Button
        SurrogateModelDataDirectorySearchButton  matlab.ui.control.Button
        SurrogateModelFileNameEditField  matlab.ui.control.EditField
        SurrogateModelFileNameEditFieldLabel  matlab.ui.control.Label
        SurrogateModelFileNameStatus    matlab.ui.control.Image
        SurrogateModelDataDirectoryEditField  matlab.ui.control.EditField
        SurrogateModelDataDirectoryEditFieldLabel  matlab.ui.control.Label
        SurrogateModelDataDirectoryStatus  matlab.ui.control.Image
        SynergyControllerAdvancedSettingsStatus  matlab.ui.control.Image
        MuscleControllerAdvancedSettingsStatus  matlab.ui.control.Image
        MuscleControllerAdvancedSettingsLabel  matlab.ui.control.Label
        MuscleControllerAdvancedSettingsTable  matlab.ui.control.Table
        MuscleControllerMuscleList      matlab.ui.control.TextArea
        SurrogateModelCoordinatesListLabel_2  matlab.ui.control.Label
        MuscleControllerMuscleListEditButton  matlab.ui.control.Button
        SynergyControllerAdvancedSettingsLabel  matlab.ui.control.Label
        SynergyControllerAdvancedSettingsTable  matlab.ui.control.Table
        OptimizeSynergyVectorsCheckBox  matlab.ui.control.CheckBox
        SynergyVectorNormalizationMethodDropDown  matlab.ui.control.DropDown
        SynergyVectorNormalizationMethodLabel  matlab.ui.control.Label
        UseRCNLMuscleControllerCheckBox  matlab.ui.control.CheckBox
        SurrogateModelCoordinatesList   matlab.ui.control.TextArea
        SurrogateModelCoordinatesListLabel  matlab.ui.control.Label
        SurrogateModelCoordinatesListStatus  matlab.ui.control.Image
        MuscleControllerMuscleListStatus  matlab.ui.control.Image
        SynergyControllerStatus         matlab.ui.control.Image
        MuscleControllerStatus          matlab.ui.control.Image
        SurrogateModelCoordinatesListEditButton  matlab.ui.control.Button
        UseRCNLSynergyControllerCheckBox  matlab.ui.control.CheckBox
        UserDefinedTab                  matlab.ui.container.Tab
        CostTermsTab                    matlab.ui.container.Tab
        MiscellaneousCostTermParametersStatus  matlab.ui.control.Image
        MiscellaneousCostTermParametersLabel  matlab.ui.control.Label
        MiscellaneousCostTermParametersTable  matlab.ui.control.Table
        ErrorCenterEditField            matlab.ui.control.NumericEditField
        ErrorCenterEditFieldLabel       matlab.ui.control.Label
        MaxAllowableErrorEditField      matlab.ui.control.NumericEditField
        MaxAllowableErrorEditFieldLabel  matlab.ui.control.Label
        CostTermsListStatus             matlab.ui.control.Image
        CostTermsListLabel              matlab.ui.control.Label
        CostTermComponentListStatus     matlab.ui.control.Image
        CostTermTypeStatus              matlab.ui.control.Image
        CostTermComponentListEditButton  matlab.ui.control.Button
        CostTermComponentListTextArea   matlab.ui.control.TextArea
        ComponentListTextAreaLabel      matlab.ui.control.Label
        CostTermTypeDropDown            matlab.ui.control.DropDown
        CostTermTypeDropDownLabel       matlab.ui.control.Label
        CostTermsListTable              matlab.ui.control.Table
        ConstraintTermsTab              matlab.ui.container.Tab
        MinErrorEditField               matlab.ui.control.NumericEditField
        MinErrorEditFieldLabel          matlab.ui.control.Label
        MaxErrorField                   matlab.ui.control.NumericEditField
        MaxErrroLabel                   matlab.ui.control.Label
        ConstraintTermComponentListEditButton  matlab.ui.control.Button
        ConstraintTermComponentListTextArea  matlab.ui.control.TextArea
        ConstraintTermComponentListTextAreaLabel    matlab.ui.control.Label
        ConstraintTermTypeDropDown      matlab.ui.control.DropDown
        ConstraintTermTypeDropDownLabel  matlab.ui.control.Label
        MiscellaneousConstraintTermParametersStatus  matlab.ui.control.Image
        MiscellaneousConstraintTermParametersLabel  matlab.ui.control.Label
        MiscellaneousConstraintTermParametersTable  matlab.ui.control.Table
        ConstraintTermsListStatus       matlab.ui.control.Image
        ConstraintTermsListLabel        matlab.ui.control.Label
        ConstraintTermComponentListStatus  matlab.ui.control.Image
        ConstraintTermTypeStatus        matlab.ui.control.Image
        ConstraintTermsListTable        matlab.ui.control.Table
        SolverSettingsTab               matlab.ui.container.Tab
        SolverSettingsStatus            matlab.ui.control.Image
        SolverSettingsLabel             matlab.ui.control.Label
        SolverSettingsTable             matlab.ui.control.Table
        MakeDefaultSettingsFileButton   matlab.ui.control.Button
        SolverSelectionDropDown         matlab.ui.control.DropDown
        SolverSelectionDropDownLabel    matlab.ui.control.Label
        SolverSettingsFileEditField     matlab.ui.control.EditField
        SolverSettingsFileLabel         matlab.ui.control.Label
        SolverSettingsFileSearchButton  matlab.ui.control.Button
        SolverSettingsFileStatus        matlab.ui.control.Image
        AdvancedTab                     matlab.ui.container.Tab
        AdvancedParamsStatus  matlab.ui.control.Image
        AdvancedParamsTable             matlab.ui.control.Table
        TreatmentOptimizationLabel      matlab.ui.control.Label
        ContextMenu                     matlab.ui.container.ContextMenu
        RenameMenu                      matlab.ui.container.Menu
        CopyMenu                        matlab.ui.container.Menu
        DeleteMenu                      matlab.ui.container.Menu
        ConstraintTermContextMenu       matlab.ui.container.ContextMenu
        ConstraintTermRenameMenu        matlab.ui.container.Menu
        ConstraintTermCopyMenu          matlab.ui.container.Menu
        ConstraintTermDeleteMenu        matlab.ui.container.Menu
        MiscCostParameterContextMenu    matlab.ui.container.ContextMenu
        MiscCostParameterRenameMenu     matlab.ui.container.Menu
        MiscCostParameterDeleteMenu     matlab.ui.container.Menu
        MiscConstraintParameterContextMenu  matlab.ui.container.ContextMenu
        MiscConstraintParameterRenameMenu   matlab.ui.container.Menu
        MiscConstraintParameterDeleteMenu   matlab.ui.container.Menu
    end


    properties (Access = private, SetObservable)
        input_model_file string = "";
        input_osimx_file string = "";
        tracked_quantities_directory string = "";
        initial_guess_directory string = "";
        results_directory string = "";
        coordinate_list string = [];
        trial_prefix string = "";
        selected_tool string = "Tracking Optimization";

        model_markers string = [];
        model_joints string = [];
        model_bodies string = [];
        model_coordinates string = [];
        model_groups string = [];
        model_muscles string = [];

        % Column labels parsed from the tracked quantities directory. These
        % determine which components may be selected in the GUI.
        tracked_coordinate_labels string = [];
        tracked_load_labels string = [];
        tracked_emg_labels string = [];
        tracked_grf_labels string = [];
        tracked_moment_arm_coordinates string = [];
        tracked_moment_arm_muscles string = [];
        tracked_trial_names string = [];

        osimx_synergy_groups cell = {};

        costTerms cell = cell(0);
        costTermIndex double = 1;

        constraintTerms cell = cell(0);
        constraintTermIndex double = 1;

        TorqueController handle = RCNLTorqueControllerClass();
        SynergyController handle = RCNLSynergyControllerClass();
        MuscleController handle = RCNLMuscleControllerClass();
        MuscleModel handle = RCNLMuscleModelClass();

        % Text, not numbers, because these mix true/false with scalars,
        % with an optional blank, and with a pair of numbers -- the same
        % reason gpopsSettingValues is text
        advancedSettingValues string = [];

        % The optimal control solver settings live in their own XML file,
        % referenced from the tool settings file. Values are held as text
        % because GPOPS mixes enumerations with numbers.
        solver_settings_file string = "";
        solver_type string = "GPOPS-II";
        gpopsSettingValues string = [];

        objectSelectionType string = "";  % Used to filter in setSelectedObjects
        currentSettingsFile string = "";
        settingsDirectory string = "";  % Base for paths read from a file

        inputModelValid logical = false;
        trackedQuantitiesValid logical = false;
        initialGuessValid logical = false;
        resultsDirectoryValid logical = false;
        trialPrefixValid logical = false;
        coordinateListValid logical = false;
        torqueCoordinateListValid logical = true;  % Only checked when the torque controller is on
        muscleListValid logical = true;  % Only checked when the muscle controller is on
        surrogateCoordinateListValid logical = true;  % Only checked for muscle based controls
        surrogateDataDirectoryValid logical = true;  % Only checked for muscle based controls
        muscleActivationsValid logical = true;  % A bad path only; absent activations are a warning
        osimxValid logical = true;  % Optional unless a synergy controller is used
        costTermsValid logical = false;
        constraintTermsValid logical = true;  % An empty set is allowed
        solverSettingsValid logical = false;
        advancedSettingsValid logical = true;
    end

    properties (Constant, Access = private)
        % Trailing invitation row on the misc parameter tables, shown only
        % for user defined terms
        miscParameterAddRowText = "Add a new parameter"

        % Written as direct children of the tool element. The defaults are
        % the alternates the parsers fall back to, so a generated file
        % behaves exactly like omitting every element.
        advancedSettingNames = ...
            ["joint_position_range_scale_factor"
            "joint_velocity_range_scale_factor"
            "joint_acceleration_range_scale_factor"
            "joint_jerk_range_scale_factor"
            "joint_position_minimum_range"
            "joint_velocity_minimum_range"
            "joint_acceleration_minimum_range"
            "joint_jerk_minimum_range"
            "experimental_bspline_cutoff_frequency"
            "first_order_control_dynamics_filter_time_constant"
            "use_first_order_control_dynamics_filter"
            "use_jerk_controls"
            "normalize_cost_by_term_type"
            "final_time_range"]

        % Text so that true/false reach getBooleanLogicFromField as the
        % literal it compares against; a numeric 1 would read as false
        defaultAdvancedSettingValues = ...
            ["2"
            "1.5"
            "1"
            "1"
            "0"
            "0"
            "0"
            "0"
            "6"
            "1"
            "false"
            "false"
            "false"
            ""]

        % How each value is validated. The minimum_range settings default
        % to 0, so they are nonnegative rather than positive. "range" is
        % optional and blank means the element is not written at all.
        advancedSettingKinds = ...
            ["positive"
            "positive"
            "positive"
            "positive"
            "nonnegative"
            "nonnegative"
            "nonnegative"
            "nonnegative"
            "positive"
            "positive"
            "boolean"
            "boolean"
            "boolean"
            "range"]

        % "" means every tool reads the setting. Only parseDesignSettings,
        % in parseDesignOptimizationSettingsTree, reads final_time_range.
        advancedSettingTools = ...
            [""
            ""
            ""
            ""
            ""
            ""
            ""
            ""
            ""
            ""
            ""
            ""
            ""
            "Design Optimization"]

        % The GPOPS solver settings, in the order GpopsReference.xml uses.
        % The defaults are the alternates parseGpopsSolverSettings falls
        % back to, so a generated file behaves exactly like omitting every
        % element. gpopsSettingOptions lists the allowed values for the
        % enumerated settings and is "" where any number is accepted.
        gpopsSettingNames = ...
            ["setup_derivatives_supplier"
            "setup_derivatives_level"
            "setup_derivatives_dependencies"
            "setup_derivatives_step_size"
            "setup_scales_method"
            "setup_method"
            "setup_mesh_method"
            "setup_mesh_tolerance"
            "setup_mesh_max_iterations"
            "setup_mesh_colpoints_min"
            "setup_mesh_colpoints_max"
            "setup_mesh_splitmult"
            "setup_mesh_curveratio"
            "setup_mesh_R"
            "setup_mesh_sigma"
            "setup_mesh_phase_intervals"
            "setup_mesh_phase_colpoints_per_Interval"
            "setup_nlp_solver"
            "setup_nlp_linear_solver"
            "setup_nlp_tolerance"
            "setup_nlp_max_iterations"
            "setup_display_level"
            "integral_bound"]

        defaultGpopsSettingValues = ...
            ["sparseFD"
            "first"
            "sparse"
            "1e-08"
            "none"
            "RPM-Differentiation"
            "hp-PattersonRao"
            "0.01"
            "10"
            "3"
            "10"
            "1.2"
            "2"
            "1.2"
            "0.5"
            "6"
            "10"
            "ipopt"
            "ma57"
            "0.001"
            "20000"
            "2"
            "1"]

        gpopsSettingOptions = { ...
            ["sparseFD" "sparseBD" "sparseCD" "adigator"]
            ["first" "second"]
            ["full" "sparse" "sparseNaN"]
            ""
            ["none" "automatic-bounds" "automatic-guess" ...
            "automatic-guessUpdate" "automatic-hybrid" ...
            "automatic-hybridUpdate" "defined"]
            ["RPM-Differentiation" "RPM-Integration"]
            ["none" "hp-PattersonRao" "hp-DarbyRao" "hp-LiuRao" ...
            "hp-LiuRao-Legendre"]
            ""
            ""
            ""
            ""
            ""
            ""
            ""
            ""
            ""
            ""
            ["snopt" "ipopt"]
            ["mumps" "ma57"]
            ""
            ""
            ["0" "1" "2"]
            ""}
    end

    properties (Access = private)  % listener handles
        InputModelFileListener
        OsimXFileListener
        TrackedQuantitiesDirectoryListener
        InitialGuessDirectoryListener
        ResultsDirectoryListener
        CoordinateListListener
        trialPrefixListener
        selectedToolListener
        advancedSettingsListener
        selectedTabListener
        controllersTabListener

        TorqueEnabledListener
        TorqueCoordinateListListener
        SynergyEnabledListener
        OptimizeSynergyVectorsListener
        SynergyNormalizationMethodListener
        MuscleEnabledListener
        MuscleListListener
        MuscleModelCoordinateListListener
        MuscleModelDataDirectoryListener
        MuscleModelFileNameListener
        MuscleModelActivationsFileListener
        costTermIndexListener
        constraintTermIndexListener
        solverSettingsFileListener
        gpopsSettingsListener
    end

    
    methods (Access = private) % listener methods
        function makeListeners(app)
            app.InputModelFileListener = addlistener(app, ...
                'input_model_file', 'PostSet', ...
                @(src,event)InputModelFileListenerFunction(app));

            app.OsimXFileListener = addlistener(app, ...
                'input_osimx_file', 'PostSet', ...
                @(src,event)OsimXFileListenerFunction(app));

            app.TrackedQuantitiesDirectoryListener = addlistener(app, ...
                'tracked_quantities_directory', 'PostSet', ...
                @(src,event)TrackedQuantitiesDirectoryListenerFunction(app));

            app.InitialGuessDirectoryListener = addlistener(app, ...
                'initial_guess_directory', 'PostSet', ...
                @(src,event)InitialGuessDirectoryListenerFunction(app));

            app.ResultsDirectoryListener = addlistener(app, ...
                'results_directory', 'PostSet', ...
                @(src,event)ResultsDirectoryListenerFunction(app));

            app.CoordinateListListener = addlistener(app, ...
                'coordinate_list', 'PostSet', ...
                @(src,event)CoordinateListListenerFunction(app));

            app.trialPrefixListener = addlistener(app, ...
                'trial_prefix', 'PostSet', ...
                @(src,event)trialPrefixListenerFunction(app));

            app.selectedToolListener = addlistener(app, ...
                'selected_tool', 'PostSet', ...
                @(src,event)selectedToolListenerFunction(app));

            app.advancedSettingsListener = addlistener(app, ...
                'advancedSettingValues', 'PostSet', ...
                @(src, event)refreshAdvancedSettingsTable(app));

            app.selectedTabListener = addlistener(app.TabGroup, ...
                'SelectedTab', 'PostSet', ...
                @(src, event)formatTabButtons(app));

            app.controllersTabListener = addlistener(app.ControllersTabGroup, ...
                'SelectedTab', 'PostSet', ...
                @(src, event)formatControllersTabButtons(app));

            app.TorqueEnabledListener = addlistener(app.TorqueController, ...
                'is_enabled', 'PostSet', ...
                @(src,event)TorqueEnabledListenerFunction(app));

            app.TorqueCoordinateListListener = addlistener(app.TorqueController, ...
                'coordinate_list', 'PostSet', ...
                @(src,event)TorqueCoordinateListListenerFunction(app));

            app.SynergyEnabledListener = addlistener(app.SynergyController, ...
                'is_enabled', 'PostSet', ...
                @(src,event)SynergyEnabledListenerFunction(app));

            app.OptimizeSynergyVectorsListener = addlistener(app.SynergyController, ...
                'optimize_synergy_vectors', 'PostSet', ...
                @(src,event)OptimizeSynergyVectorsListenerFunction(app));

            app.SynergyNormalizationMethodListener = addlistener(app.SynergyController, ...
                'synergy_vector_normalization_method', 'PostSet', ...
                @(src,event)SynergyNormalizationMethodListenerFunction(app));

            app.MuscleEnabledListener = addlistener(app.MuscleController, ...
                'is_enabled', 'PostSet', ...
                @(src,event)MuscleEnabledListenerFunction(app));

            app.MuscleListListener = addlistener(app.MuscleController, ...
                'muscle_list', 'PostSet', ...
                @(src,event)MuscleListListenerFunction(app));

            app.MuscleModelCoordinateListListener = addlistener(app.MuscleModel, ...
                'coordinate_list', 'PostSet', ...
                @(src,event)MuscleModelCoordinateListListenerFunction(app));

            app.MuscleModelDataDirectoryListener = addlistener(app.MuscleModel, ...
                'data_directory', 'PostSet', ...
                @(src,event)MuscleModelDataDirectoryListenerFunction(app));

            app.MuscleModelFileNameListener = addlistener(app.MuscleModel, ...
                'file_name', 'PostSet', ...
                @(src,event)MuscleModelFileNameListenerFunction(app));

            app.MuscleModelActivationsFileListener = addlistener(app.MuscleModel, ...
                'muscle_activations_file', 'PostSet', ...
                @(src,event)MuscleModelActivationsFileListenerFunction(app));

            app.costTermIndexListener = addlistener(app, ...
                'costTermIndex', 'PostSet', ...
                @(src,event)costTermIndexListenerFunction(app));

            app.constraintTermIndexListener = addlistener(app, ...
                'constraintTermIndex', 'PostSet', ...
                @(src,event)constraintTermIndexListenerFunction(app));

            app.solverSettingsFileListener = addlistener(app, ...
                'solver_settings_file', 'PostSet', ...
                @(src,event)solverSettingsFileListenerFunction(app));

            app.gpopsSettingsListener = addlistener(app, ...
                'gpopsSettingValues', 'PostSet', ...
                @(src,event)refreshSolverSettingsTable(app));
        end

        function InputModelFileListenerFunction(app)
            app.InputModelFileEditField.Value = getRelativePath( ...
                app.input_model_file);
            % validateInputModelFile parses the model as part of validating
            app.validateInputModelFile();
            app.validateInputOsimxFile();
            app.updateTabControls();
        end

        function OsimXFileListenerFunction(app)
            app.InputOsimxFileEditField.Value = getRelativePath( ...
                app.input_osimx_file);
            app.validateInputOsimxFile();
            app.updateTabControls();
        end

        function TrackedQuantitiesDirectoryListenerFunction(app)
            app.TrackedQuantitiesDirectoryEditField.Value = getRelativePath( ...
                app.tracked_quantities_directory);
            app.tracked_trial_names = app.refreshTrackedQuantitiesData();
            if strcmp(app.trial_prefix, "") && ...
                    ~isempty(app.tracked_trial_names)
                % Setting the prefix refreshes the data through its listener
                app.trial_prefix = app.tracked_trial_names(1);
                return
            end
            app.validateTrackedQuantitiesDirectory();
            app.validateTrialPrefix();
            app.updateTabControls();
        end

        function InitialGuessDirectoryListenerFunction(app)
            app.InitialGuessDirectoryEditField.Value = getRelativePath( ...
                app.initial_guess_directory);
            app.validateInitialGuessDirectory();
            app.updateTabControls();
        end

        function ResultsDirectoryListenerFunction(app)
            app.ResultsDirectoryEditField.Value = getRelativePath( ...
                app.results_directory);
            app.validateResultsDirectory();
            app.updateTabControls();
        end

        function CoordinateListListenerFunction(app)
            app.StatesCoordinatesListTextArea.Value = ...
                strjoin(app.coordinate_list, ", ");
            app.validateCoordinateList();
            % Torque coordinates are checked against the states list
            app.validateTorqueCoordinateList();
            app.updateTabControls();
        end

        function trialPrefixListenerFunction(app)
            app.TrialPrefixEditField.Value = app.trial_prefix;
            app.tracked_trial_names = app.refreshTrackedQuantitiesData();
            app.validateTrackedQuantitiesDirectory();
            app.validateTrialPrefix();
            app.updateTabControls();
        end

        function trialNames = refreshTrackedQuantitiesData(app)
            trialNames = parseTreatmentOptimizationDataDirectoryGui(app, ...
                app.tracked_quantities_directory, app.trial_prefix);
        end

        function selectedToolListenerFunction(app)
            app.ToolSelectionDropDown.Value = app.selected_tool;
            % The set of valid term types depends on the tool
            app.refreshCostTermTypeItems();
            app.validateCostTerms();
            app.refreshConstraintTermTypeItems();
            app.validateConstraintTerms();
            % final_time_range is only read by Design Optimization, so the
            % advanced table gains and loses that row with the tool
            app.refreshAdvancedSettingsTable();
            app.updateTabControls();
        end

        % Row order follows advancedSettingNames, minus any setting the
        % selected tool does not read, so the table never offers a setting
        % that would do nothing
        function rows = advancedSettingRows(app)
            keep = arrayfun(@(i)app.isAdvancedSettingUsed(i), ...
                (1 : numel(app.advancedSettingNames))');
            rows = find(keep);
        end

        function used = isAdvancedSettingUsed(app, index)
            tool = app.advancedSettingTools(index);
            used = strcmp(tool, "") || strcmp(tool, app.selected_tool);
        end

        function refreshAdvancedSettingsTable(app)
            rows = app.advancedSettingRows();
            Options = app.advancedSettingNames(rows);
            Values = app.advancedSettingValues(rows);
            app.AdvancedParamsTable.Data = table(Options, Values);
            app.validateAdvancedSettings();
        end

        function solverSettingsFileListenerFunction(app)
            app.SolverSettingsFileEditField.Value = getRelativePath( ...
                app.solver_settings_file);
            app.loadSolverSettingsFile();
            app.validateSolverSettings();
        end

        function refreshSolverSettingsTable(app)
            Options = app.gpopsSettingNames;
            Values = app.gpopsSettingValues;
            app.SolverSettingsTable.Data = table(Options, Values);
            app.validateSolverSettings();
        end

        function formatTabButtons(app)
            if ~isvalid(app) || ~isvalid(app.TabGroup)
                return
            end
            updateTabButtonStyles(app.TabGroup.SelectedTab, ...
                [app.InputsTab, app.ControllersTab, app.CostTermsTab, ...
                app.ConstraintTermsTab, app.SolverSettingsTab, ...
                app.AdvancedTab], ...
                [app.InputsButton, app.ControllersButton, ...
                app.CostTermsButton, app.ConstraintTermsButton, ...
                app.SolverSettingsButton, app.AdvancedButton]);
        end

        function formatControllersTabButtons(app)
            if ~isvalid(app) || ~isvalid(app.ControllersTabGroup)
                return
            end
            updateTabButtonStyles(app.ControllersTabGroup.SelectedTab, ...
                [app.TorqueTab, app.SynergyTab, app.UserDefinedTab], ...
                [app.TorqueControlsButton, app.SynergyControlsButton, ...
                app.UserDefinedControlsButton]);
        end

        function TorqueEnabledListenerFunction(app)
            app.UseRCNLTorqueControllerCheckBox.Value = strcmp( ...
                app.TorqueController.is_enabled, 'true');
            % The coordinate list is only required while the controller is on
            app.validateTorqueCoordinateList();
            % The set of valid term types depends on the controllers
            app.refreshCostTermTypeItems();
            app.validateCostTerms();
            app.refreshConstraintTermTypeItems();
            app.validateConstraintTerms();
            app.updateTabControls();
        end

        function TorqueCoordinateListListenerFunction(app)
            app.TorqueControllerCoordinateList.Value = ...
                strjoin(app.TorqueController.coordinate_list, ", ");
            app.validateTorqueCoordinateList();
            app.updateTabControls();
        end

        function SynergyEnabledListenerFunction(app)
            app.UseRCNLSynergyControllerCheckBox.Value = strcmp( ...
                app.SynergyController.is_enabled, 'true');
            % The osimx file is only required when synergies are used, and
            % muscle based controls require extra tracked data folders
            app.validateInputOsimxFile();
            app.validateTrackedQuantitiesDirectory();
            % Synergy controls run off the surrogate model
            app.validateSurrogateCoordinateList();
            app.validateSurrogateDataDirectory();
            app.refreshCostTermTypeItems();
            app.validateCostTerms();
            app.refreshConstraintTermTypeItems();
            app.validateConstraintTerms();
            app.updateTabControls();
        end

        function OptimizeSynergyVectorsListenerFunction(app)
            app.OptimizeSynergyVectorsCheckBox.Value = strcmp( ...
                app.SynergyController.optimize_synergy_vectors, 'true');
        end

        function SynergyNormalizationMethodListenerFunction(app)
            app.SynergyVectorNormalizationMethodDropDown.Value = ...
                char(app.SynergyController.synergy_vector_normalization_method);
        end

        function MuscleEnabledListenerFunction(app)
            app.UseRCNLMuscleControllerCheckBox.Value = strcmp( ...
                app.MuscleController.is_enabled, 'true');
            % Muscle based controls require extra tracked data folders
            app.validateTrackedQuantitiesDirectory();
            % The muscle list is only required while the controller is on,
            % and muscle controls also run off the surrogate model
            app.validateMuscleList();
            app.validateSurrogateCoordinateList();
            app.validateSurrogateDataDirectory();
            app.refreshCostTermTypeItems();
            app.validateCostTerms();
            app.refreshConstraintTermTypeItems();
            app.validateConstraintTerms();
            app.updateTabControls();
        end

        function MuscleListListenerFunction(app)
            app.MuscleControllerMuscleList.Value = ...
                strjoin(app.MuscleController.muscle_list, ", ");
            app.validateMuscleList();
            app.updateTabControls();
        end

        function MuscleModelCoordinateListListenerFunction(app)
            app.SurrogateModelCoordinatesList.Value = ...
                strjoin(app.MuscleModel.coordinate_list, ", ");
            app.validateSurrogateCoordinateList();
            app.updateTabControls();
        end

        function MuscleModelDataDirectoryListenerFunction(app)
            app.SurrogateModelDataDirectoryEditField.Value = ...
                getRelativePath(app.MuscleModel.data_directory);
            app.validateSurrogateDataDirectory();
            app.updateTabControls();
        end

        function MuscleModelFileNameListenerFunction(app)
            app.SurrogateModelFileNameEditField.Value = ...
                getRelativePath(app.MuscleModel.file_name);
        end

        function MuscleModelActivationsFileListenerFunction(app)
            app.MuscleActivationsFileEditField.Value = ...
                getRelativePath(app.MuscleModel.muscle_activations_file);
            app.validateMuscleActivationsFile();
        end

        function updateTorqueAdvancedSettingsTable(app)
            updateParameterTableGui(app.TorqueController, ...
                app.TorqueAdvancedSettingsTable);
        end

        function updateSynergyAdvancedSettingsTable(app)
            updateParameterTableGui(app.SynergyController, ...
                app.SynergyControllerAdvancedSettingsTable);
        end

        function updateMuscleAdvancedSettingsTable(app)
            updateParameterTableGui(app.MuscleController, ...
                app.MuscleControllerAdvancedSettingsTable);
        end

        function updateSurrogateModelAdvancedSettingsTable(app)
            updateParameterTableGui(app.MuscleModel, ...
                app.SurrogateModelAdvancedSettingsTable);
        end
    end

    methods (Access = private) % validation methods
        function validateAllFields(app)
            app.validateInputModelFile();
            app.validateInputOsimxFile();
            app.validateTrackedQuantitiesDirectory();
            app.validateInitialGuessDirectory();
            app.validateResultsDirectory();
            app.validateTrialPrefix();
            app.validateCoordinateList();
            app.validateTorqueCoordinateList();
            app.validateMuscleList();
            app.validateSurrogateCoordinateList();
            app.validateSurrogateDataDirectory();
            app.validateCostTerms();
            app.validateConstraintTerms();
            app.validateSolverSettings();
            app.validateAdvancedSettings();
            app.updateTabControls();
        end

        function validateInputModelFile(app)
            app.inputModelValid = validateRequiredFieldGui( ...
                app.input_model_file, "Input model file is required.", ...
                app.InputModelFileEditField, app.InputModelFileStatus, ...
                app.InputModelFileStatus, ...
                @(value, field, icon)validateOsimFileGui(app, value, ...
                field, icon));
        end

        function validateInputOsimxFile(app)
            % The osimx file supplies the synergy groups, so it is only
            % required when the synergy controller is used
            if app.isControllerEnabled(app.SynergyController)
                app.osimxValid = validateRequiredFieldGui( ...
                    app.input_osimx_file, ...
                    "An osimx file is required for synergy controls.", ...
                    app.InputOsimxFileEditField, app.InputOsimxFileStatus, ...
                    app.InputOsimxFileStatus, ...
                    @(value, field, icon)app.validateOsimxFile(value, ...
                    field, icon));
                return
            end
            if strcmp(app.input_osimx_file, "")
                app.osimx_synergy_groups = {};
                setGuiFieldStatus(app.InputOsimxFileEditField, ...
                    app.InputOsimxFileStatus, "none");
                app.osimxValid = true;
                return
            end
            app.osimxValid = app.validateOsimxFile(app.input_osimx_file, ...
                app.InputOsimxFileEditField, app.InputOsimxFileStatus);
        end

        function isValid = validateOsimxFile(app, value, field, icon)
            app.osimx_synergy_groups = {};
            % The osimx file is parsed against the model, so the model must
            % be in place first
            if strcmp(app.input_model_file, "")
                throwGuiError("Select an input model file before the " + ...
                    "osimx file.", field, icon);
                isValid = false;
                return
            end
            if ~app.inputModelValid
                throwGuiError("The osimx file cannot be parsed until the " + ...
                    "input model file is valid.", field, icon);
                isValid = false;
                return
            end
            [errorFlag, message] = parseOsimxFileGui(app, value, ...
                app.input_model_file);
            if errorFlag
                throwGuiError(message, field, icon);
                isValid = false;
                return
            end
            if app.isControllerEnabled(app.SynergyController) && ...
                    isempty(app.osimx_synergy_groups)
                throwGuiError("The given osimx file does not contain " + ...
                    "synergy groups.", field, icon);
                isValid = false;
                return
            end
            clearGuiError(field, icon);
            isValid = true;
        end

        function validateTrackedQuantitiesDirectory(app)
            app.trackedQuantitiesValid = validateRequiredFieldGui( ...
                app.tracked_quantities_directory, ...
                "Tracked quantities directory is required.", ...
                app.TrackedQuantitiesDirectoryEditField, app.TrackedQuantitiesDirectoryStatus, ...
                app.TrackedQuantitiesDirectoryStatus, ...
                @(value, field, icon)validateDataDirectoryGui(value, ...
                ["IKData", "IDData"], field, icon));
        end

        function validateInitialGuessDirectory(app)
            app.initialGuessValid = validateRequiredFieldGui( ...
                app.initial_guess_directory, ...
                "Initial guess directory is required.", ...
                app.InitialGuessDirectoryEditField, app.InitialGuessDirectoryStatus, ...
                app.InitialGuessDirectoryStatus, ...
                @(value, field, icon)validateDataDirectoryGui(value, ...
                string([]), field, icon));
        end

        % A run writes here, so an existing directory is only a warning
        % about overwriting rather than an error
        function validateResultsDirectory(app)
            app.resultsDirectoryValid = validateRequiredFieldGui( ...
                app.results_directory, "Results directory is required.", ...
                app.ResultsDirectoryEditField, app.ResultsDirectoryStatus, ...
                app.ResultsDirectoryStatus, @validateResultsDirectoryGui);
        end

        function validateTrialPrefix(app)
            if strcmp(app.trial_prefix, "")
                setGuiFieldStatus(app.TrialPrefixEditField, ...
                    app.TaskPrefixesStatus, "required", ...
                    "A trial prefix is required.");
                app.trialPrefixValid = false;
                return
            end
            if ~isempty(app.tracked_trial_names) && ...
                    ~any(strcmp(app.tracked_trial_names, app.trial_prefix))
                setGuiFieldStatus(app.TrialPrefixEditField, ...
                    app.TaskPrefixesStatus, "error", ...
                    "No data was found for this trial in the tracked " + ...
                    "quantities directory.");
                app.trialPrefixValid = false;
                return
            end
            setGuiFieldStatus(app.TrialPrefixEditField, ...
                app.TaskPrefixesStatus, "none");
            app.trialPrefixValid = true;
        end

        function validateCoordinateList(app)
            app.coordinateListValid = ~isEmptyStringList(app.coordinate_list);
            if app.coordinateListValid
                setGuiFieldStatus([], app.CoordinateListStatus, "none");
            else
                setGuiFieldStatus([], app.CoordinateListStatus, "required", ...
                    "At least one states coordinate must be selected.");
            end
        end

        function validateTorqueCoordinateList(app)
            % Torque controls are optional, so the list is only required
            % once the controller is switched on
            if ~app.isControllerEnabled(app.TorqueController)
                setGuiFieldStatus([], ...
                    app.TorqueControllerCoordianteListStatus, "none");
                app.torqueCoordinateListValid = true;
                return
            end
            if isEmptyStringList(app.TorqueController.coordinate_list)
                setGuiFieldStatus([], ...
                    app.TorqueControllerCoordianteListStatus, "required", ...
                    "At least one torque coordinate must be selected.");
                app.torqueCoordinateListValid = false;
                return
            end
            % A torque control drives one of the states, so a coordinate
            % missing from the states list cannot be controlled
            missing = setdiff(app.TorqueController.coordinate_list, ...
                app.coordinate_list, 'stable');
            missing = missing(~strcmp(missing, ""));
            if ~isempty(missing)
                setGuiFieldStatus([], ...
                    app.TorqueControllerCoordianteListStatus, "error", ...
                    "These coordinates are not in the states coordinate " + ...
                    "list: " + strjoin(missing, ", ") + ".");
                app.torqueCoordinateListValid = false;
                return
            end
            setGuiFieldStatus([], ...
                app.TorqueControllerCoordianteListStatus, "none");
            app.torqueCoordinateListValid = true;
        end

        function validateMuscleList(app)
            % Only the muscle controller takes an explicit muscle list;
            % synergy controls get their muscles from the synergy groups
            if ~app.isControllerEnabled(app.MuscleController)
                setGuiFieldStatus([], ...
                    app.MuscleControllerMuscleListStatus, "none");
                app.muscleListValid = true;
                return
            end
            app.muscleListValid = ...
                ~isEmptyStringList(app.MuscleController.muscle_list);
            if app.muscleListValid
                setGuiFieldStatus([], ...
                    app.MuscleControllerMuscleListStatus, "none");
            else
                setGuiFieldStatus([], ...
                    app.MuscleControllerMuscleListStatus, "required", ...
                    "At least one muscle must be selected for muscle " + ...
                    "controls.");
            end
        end

        function validateSurrogateCoordinateList(app)
            % The surrogate model backs both muscle and synergy controls
            if ~app.usesMuscleBasedControls()
                setGuiFieldStatus([], ...
                    app.SurrogateModelCoordinatesListStatus, "none");
                app.surrogateCoordinateListValid = true;
                return
            end
            app.surrogateCoordinateListValid = ...
                ~isEmptyStringList(app.MuscleModel.coordinate_list);
            if app.surrogateCoordinateListValid
                setGuiFieldStatus([], ...
                    app.SurrogateModelCoordinatesListStatus, "none");
            else
                setGuiFieldStatus([], ...
                    app.SurrogateModelCoordinatesListStatus, "required", ...
                    "At least one surrogate model coordinate must be " + ...
                    "selected for muscle or synergy controls.");
            end
        end

        function validateSurrogateDataDirectory(app)
            if ~app.usesMuscleBasedControls()
                setGuiFieldStatus(app.SurrogateModelDataDirectoryEditField, ...
                    app.SurrogateModelDataDirectoryStatus, "none");
                app.surrogateDataDirectoryValid = true;
                return
            end
            % parseSurrogateModelData reads MAData and IKData from this
            % directory, not from the tracked quantities directory
            app.surrogateDataDirectoryValid = validateRequiredFieldGui( ...
                app.MuscleModel.data_directory, ...
                "A surrogate model data directory is required for " + ...
                "muscle or synergy controls.", ...
                app.SurrogateModelDataDirectoryEditField, ...
                app.SurrogateModelDataDirectoryStatus, ...
                app.SurrogateModelDataDirectoryStatus, ...
                @(value, field, icon)validateDataDirectoryGui(value, ...
                ["MAData", "IKData"], field, icon));
        end

        % Initial muscle activations are optional. parseMuscleExperimentalData
        % reads <initialGuess>/<trial>_combinedActivations.sto first, tops it
        % up from <muscle_activations_file>, then fills whatever is still
        % missing with initial_activation_value. Only a path that does not
        % exist is an error; finding no activations at all is a warning.
        function validateMuscleActivationsFile(app)
            if ~app.usesMuscleBasedControls()
                setGuiFieldStatus(app.MuscleActivationsFileEditField, ...
                    app.MuscleActivationsFileStatus, "none");
                app.muscleActivationsValid = true;
                return
            end
            if ~strcmp(app.MuscleModel.muscle_activations_file, "")
                app.muscleActivationsValid = validateFileExistsGui( ...
                    app.MuscleModel.muscle_activations_file, ...
                    app.MuscleActivationsFileEditField, ...
                    app.MuscleActivationsFileStatus);
                return
            end
            app.muscleActivationsValid = true;
            if app.hasCombinedActivationsFile()
                setGuiFieldStatus(app.MuscleActivationsFileEditField, ...
                    app.MuscleActivationsFileStatus, "none");
                return
            end
            setGuiFieldStatus(app.MuscleActivationsFileEditField, ...
                app.MuscleActivationsFileStatus, "warning", ...
                "No initial muscle activations were found. Every muscle " + ...
                "will start at the muscle model's initial_activation_value.");
        end

        function hasFile = hasCombinedActivationsFile(app)
            hasFile = false;
            if strcmp(app.initial_guess_directory, "") || ...
                    strcmp(app.trial_prefix, "")
                return
            end
            hasFile = isfile(fullfile(app.initial_guess_directory, ...
                app.trial_prefix + "_combinedActivations.sto"));
        end

        function isEnabled = isControllerEnabled(~, controller)
            isEnabled = strcmp(controller.is_enabled, 'true');
        end

        function usesMuscles = usesMuscleBasedControls(app)
            usesMuscles = app.isControllerEnabled(app.SynergyController) || ...
                app.isControllerEnabled(app.MuscleController);
        end

        function isReady = inputsReady(app)
            isReady = app.inputModelValid && app.trackedQuantitiesValid && ...
                app.initialGuessValid && app.resultsDirectoryValid && ...
                app.trialPrefixValid && app.coordinateListValid;
        end

        function isReady = controllersReady(app)
            isReady = false;
            torqueEnabled = app.isControllerEnabled(app.TorqueController);
            synergyEnabled = app.isControllerEnabled(app.SynergyController);
            muscleEnabled = app.isControllerEnabled(app.MuscleController);
            if ~any([torqueEnabled synergyEnabled muscleEnabled])
                return
            end
            if torqueEnabled && ~app.torqueCoordinateListValid
                return
            end
            if muscleEnabled && ~app.muscleListValid
                return
            end
            if synergyEnabled && (~app.osimxValid || ...
                    isempty(app.osimx_synergy_groups))
                return
            end
            % Initial muscle activations are deliberately not checked here:
            % parseMuscleExperimentalData falls back to
            % initial_activation_value, so their absence is only a warning
            if app.usesMuscleBasedControls()
                if ~app.surrogateCoordinateListValid || ...
                        ~app.surrogateDataDirectoryValid
                    return
                end
            end
            isReady = true;
        end

        function validateSynergyControllerStatus(app)
            if ~app.isControllerEnabled(app.SynergyController)
                setGuiFieldStatus([], app.SynergyControllerStatus, "none");
                return
            end
            missing = string([]);
            if ~app.osimxValid || isempty(app.osimx_synergy_groups)
                missing(end + 1) = "an osimx file containing synergy groups";
            end
            missing = [missing, app.missingSurrogateRequirements()];
            app.showControllerRequirements(app.SynergyControllerStatus, ...
                "synergy", missing);
        end

        function validateMuscleControllerStatus(app)
            if ~app.isControllerEnabled(app.MuscleController)
                setGuiFieldStatus([], app.MuscleControllerStatus, "none");
                return
            end
            missing = string([]);
            if ~app.muscleListValid
                missing(end + 1) = "a muscle list";
            end
            missing = [missing, app.missingSurrogateRequirements()];
            app.showControllerRequirements(app.MuscleControllerStatus, ...
                "muscle", missing);
        end

        function missing = missingSurrogateRequirements(app)
            % Both muscle based controllers run off the surrogate model.
            % The MAData and IKData folders it reads are checked as part of
            % the surrogate model data directory itself.
            missing = string([]);
            if ~app.surrogateCoordinateListValid
                missing(end + 1) = "a surrogate model coordinate list";
            end
            if ~app.surrogateDataDirectoryValid
                missing(end + 1) = "a surrogate model data directory " + ...
                    "containing MAData and IKData";
            end
        end

        function showControllerRequirements(~, icon, name, missing)
            if isempty(missing)
                setGuiFieldStatus([], icon, "none");
                return
            end
            % A string array puts each requirement on its own tooltip line
            setGuiFieldStatus([], icon, "required", ...
                ["The " + name + " controller still needs:", ...
                "  - " + missing]);
        end

        function updateTabControls(app)
            % These summarize the checks the terms tabs are gated on, so
            % they are refreshed wherever the gate is
            app.validateSynergyControllerStatus();
            app.validateMuscleControllerStatus();
            app.validateMuscleActivationsFile();
            % The inputs, solver settings and advanced tabs are always open
            inputsAreReady = app.inputsReady();
            app.ControllersButton.Enable = inputsAreReady;
            termsReady = inputsAreReady && app.controllersReady();
            app.CostTermsButton.Enable = termsReady;
            app.ConstraintTermsButton.Enable = termsReady;
            % The Advanced tab is always open, so nothing else stops a bad
            % advanced value from reaching the solver
            app.RunButton.Enable = termsReady && app.costTermsValid && ...
                app.constraintTermsValid && app.solverSettingsValid && ...
                app.muscleActivationsValid && app.advancedSettingsValid;
        end

        function list = filteredSelectionList(~, modelList, trackedList)
            % Only components present in the tracked data may be selected
            if isEmptyStringList(trackedList) || isEmptyStringList(modelList)
                list = string([]);
                return
            end
            list = intersect(modelList, trackedList, 'stable');
        end
    end

    methods (Access = private) % cost term methods
        function toolName = selectedToolName(app)
            switch app.selected_tool
                case "Verification Optimization"
                    toolName = "VerificationOptimization";
                case "Design Optimization"
                    toolName = "DesignOptimization";
                otherwise
                    toolName = "TrackingOptimization";
            end
        end

        function types = enabledControllerTypes(app)
            types = [app.isControllerEnabled(app.TorqueController), ...
                app.isControllerEnabled(app.SynergyController), ...
                app.isControllerEnabled(app.MuscleController), ...
                false];
        end

        % Why a term's type cannot be used, or "" when it is fine. A type
        % the registry offers for another tool is reported separately from
        % one blocked by the controller selection, because the fix differs.
        % Switching tools on a loaded settings file is the usual cause.
        % Severity is "required" when something still needs filling in and
        % "error" when what the term holds cannot work, or "" when it is
        % fine. Incomplete terms are shown blue, broken ones red.
        function [severity, reason] = termTypeProblem(app, type, ...
                available, withAllControllers)
            severity = "";
            reason = "";
            if isEmptyStringList(type)
                severity = "required";
                reason = "no type is selected";
                return
            end
            if any(strcmp(available, type))
                return
            end
            if any(strcmp(withAllControllers, type))
                severity = "error";
                reason = "type '" + type + "' requires a controller that " + ...
                    "is not enabled";
                return
            end
            severity = "error";
            reason = "type '" + type + "' is not available for " + ...
                app.selected_tool;
        end

        function [severity, reason] = costTermProblem(app, costTerm, ...
                available, withAllControllers)
            [severity, reason] = app.termTypeProblem(costTerm.type, ...
                available, withAllControllers);
            if ~strcmp(severity, "")
                return
            end
            if costTerm.max_allowable_error <= 0
                severity = "error";
                reason = "the max allowable error must be greater than zero";
                return
            end
            if strcmp(costTerm.type, "user_defined")
                [severity, reason] = app.userDefinedTermProblem( ...
                    costTerm.miscParams, "cost_term_type", ...
                    ["continuous" "discrete"]);
                return
            end
            if ~isEmptyStringList(costTerm.componentElement) && ...
                    isEmptyStringList(costTerm.componentList)
                severity = "required";
                reason = "no components are selected";
            end
        end

        function [severity, reason] = constraintTermProblem(app, ...
                constraintTerm, available, withAllControllers)
            [severity, reason] = app.termTypeProblem(constraintTerm.type, ...
                available, withAllControllers);
            if ~strcmp(severity, "")
                return
            end
            if constraintTerm.min_error > constraintTerm.max_error
                severity = "error";
                reason = "the min error is greater than the max error";
                return
            end
            if strcmp(constraintTerm.type, "user_defined")
                [severity, reason] = app.userDefinedTermProblem( ...
                    constraintTerm.miscParams, "constraint_term_type", ...
                    ["path" "terminal"]);
                return
            end
            if ~isEmptyStringList(constraintTerm.componentElement) && ...
                    isEmptyStringList(constraintTerm.componentList)
                severity = "required";
                reason = "no components are selected";
            end
        end

        % A user defined term is described entirely by its parameters.
        % makeMaxAllowableError and parseRcnlConstraintTermSet throw on
        % anything outside the allowed phase values.
        function [severity, reason] = userDefinedTermProblem(~, ...
                miscParams, typeField, allowedValues)
            severity = "";
            reason = "";
            if ~isfield(miscParams, 'function_name') || ...
                    isEmptyStringList(miscParams.function_name)
                severity = "required";
                reason = "a function name is required";
                return
            end
            if ~isfield(miscParams, typeField) || ...
                    isEmptyStringList(miscParams.(typeField))
                severity = "required";
                reason = "a " + typeField + " is required";
                return
            end
            if ~any(strcmpi(miscParams.(typeField), allowedValues))
                severity = "error";
                reason = typeField + " must be one of: " + ...
                    strjoin(allowedValues, ", ");
            end
        end

        % Fills a misc parameter table and puts it in the right editing
        % mode. A user defined term is described entirely by these
        % parameters, so it gets an invitation row and an editable name
        % column; every other type shows exactly what its metadata
        % declares. ColumnEditable is per column rather than per row, so
        % the rows that must not change are grayed here and refused in
        % applyMiscParameterEdit.
        function refreshMiscParameterTable(app, uiTable, term, ...
                typeParams, statusIcon)
            if isempty(term)
                uiTable.Data = table();
                uiTable.ColumnEditable = [false true];
                removeStyle(uiTable);
                setGuiFieldStatus([], statusIcon, "none");
                return
            end
            isUserDefined = strcmp(term.type, "user_defined");
            addRowText = "";
            if isUserDefined
                addRowText = app.miscParameterAddRowText;
            end
            updateMiscParameterTableGui(term.miscParams, uiTable, ...
                addRowText);
            uiTable.ColumnEditable = [isUserDefined true];
            % Styles are index based and outlive a Data assignment, so the
            % old ones have to go before a shorter list is styled
            removeStyle(uiTable);
            if ~isUserDefined
                setGuiFieldStatus([], statusIcon, "none");
                return
            end
            params = string(fieldnames(term.miscParams));
            for i = 1 : numel(params)
                if any(strcmp(typeParams, params(i)))
                    addStyle(uiTable, uistyle('FontColor', ...
                        [0.4 0.4 0.4]), 'cell', [i 1]);
                end
            end
            addStyle(uiTable, uistyle('FontColor', [0.4 0.4 0.4], ...
                'FontAngle', 'italic'), 'row', numel(params) + 1);
            app.showMiscParameterStatus(statusIcon, term.miscParams);
        end

        % toStruct drops a parameter with no value, so a blank one would
        % vanish on save. Say so rather than lose it quietly. This is
        % display only; a half typed parameter must not lock the Run
        % button the way a validation failure would.
        function showMiscParameterStatus(~, icon, miscParams)
            names = string(fieldnames(miscParams));
            blank = string([]);
            for i = 1 : numel(names)
                if isEmptyStringList(miscParams.(names(i)))
                    blank(end + 1) = "  - " + names(i); %#ok<AGROW>
                end
            end
            if isempty(blank)
                setGuiFieldStatus([], icon, "none");
            else
                setGuiFieldStatus([], icon, "required", ...
                    ["These parameters have no value and will not be " + ...
                    "saved:", blank]);
            end
        end

        % isvarname covers both the dynamic field name requirement and
        % what makes a legal XML element name, so one test does for both
        function problem = miscParameterNameProblem(~, name, existing, ...
                reserved)
            problem = "";
            if isEmptyStringList(name)
                problem = "A parameter name cannot be blank. Use " + ...
                    "Delete from the right click menu to remove a " + ...
                    "parameter.";
            elseif ~isvarname(char(name))
                problem = """" + name + """ is not a valid parameter " + ...
                    "name. Use a letter followed by letters, digits, " + ...
                    "or underscores.";
            elseif any(strcmp(existing, name))
                problem = "A parameter named """ + name + """ " + ...
                    "already exists.";
            elseif any(strcmp(reserved, name))
                problem = """" + name + """ is reserved by the " + ...
                    "settings file format and cannot be used as a " + ...
                    "parameter name.";
            end
        end

        % Drops named parameters, used to stop the parameters a type
        % declared from following the term to a type that does not
        function s = withoutParams(~, s, names)
            for i = 1 : numel(names)
                if isfield(s, names(i))
                    s = rmfield(s, names(i));
                end
            end
        end

        % A struct field cannot be renamed in place, and rebuilding in
        % field order is what keeps the table from reshuffling
        function s = renamedStructField(~, s, oldName, newName)
            names = string(fieldnames(s));
            rebuilt = struct();
            for i = 1 : numel(names)
                if strcmp(names(i), oldName)
                    rebuilt.(newName) = s.(names(i));
                else
                    rebuilt.(names(i)) = s.(names(i));
                end
            end
            s = rebuilt;
        end

        % Applies one misc table edit and returns the message to show when
        % it is refused. The caller always re-renders, which is what
        % restores the add row and undoes a rejected edit.
        function problem = applyMiscParameterEdit(app, term, event, ...
                typeParams, reserved)
            problem = "";
            params = string(fieldnames(term.miscParams));
            row = event.Indices(1);
            column = event.Indices(2);
            newData = strtrim(string(event.NewData));
            isAddRow = row > numel(params);
            if column == 2
                % The add row has no parameter to hold a value yet
                if ~isAddRow
                    term.miscParams.(params(row)) = newData;
                end
                return
            end
            if isAddRow
                % Clearing the invitation text is not an attempt to add
                if isEmptyStringList(newData)
                    return
                end
                problem = app.miscParameterNameProblem(newData, params, ...
                    reserved);
                if strcmp(problem, "")
                    term.miscParams.(newData) = "";
                end
                return
            end
            if strcmp(newData, params(row))
                return
            end
            if any(strcmp(typeParams, params(row)))
                problem = """" + params(row) + """ is part of the " + ...
                    term.type + " term type and cannot be renamed.";
                return
            end
            problem = app.miscParameterNameProblem(newData, params, ...
                reserved);
            if strcmp(problem, "")
                term.miscParams = app.renamedStructField( ...
                    term.miscParams, params(row), newData);
            end
        end

        function reportMiscParameterProblem(app, message)
            uialert(app.UIFigure, string(message), ...
                "Invalid parameter name");
        end

        function row = selectedMiscRow(~, uiTable)
            row = 0;
            if ~isempty(uiTable.Selection)
                row = uiTable.Selection(1);
            end
        end

        % Only a parameter the user added can be renamed or deleted: not
        % the add row, not the ones the type declares, and nothing at all
        % on a built in type
        function editable = isEditableMiscRow(~, term, typeParams, row)
            editable = false;
            if isempty(term) || ~strcmp(term.type, "user_defined")
                return
            end
            params = string(fieldnames(term.miscParams));
            editable = row >= 1 && row <= numel(params) && ...
                ~any(strcmp(typeParams, params(row)));
        end

        % Incomplete terms are blue, terms that cannot work at all are red
        function highlightTermRows(~, listTable, incomplete, broken)
            for i = incomplete
                addStyle(listTable, uistyle('BackgroundColor', ...
                    [0.68 0.82 1.00]), 'row', i);
            end
            for i = broken
                addStyle(listTable, uistyle('BackgroundColor', ...
                    [1.00 0.67 0.67]), 'row', i);
            end
        end

        % A term with a component element but nothing chosen yet is
        % incomplete rather than wrong, so it shows the required icon
        function showComponentListStatus(~, icon, hasComponents, list)
            if hasComponents && isEmptyStringList(list)
                setGuiFieldStatus([], icon, "required", ...
                    "At least one component must be selected.");
            else
                setGuiFieldStatus([], icon, "none");
            end
        end

        % Terms loaded from a file may carry no name attribute
        function label = termLabel(~, term, index, prefix)
            label = term.name;
            if isEmptyStringList(label)
                label = prefix + " " + num2str(index);
            end
        end

        % Cost term types available for the current tool and controllers
        function [types, metadata] = availableCostTermTypes(app, ...
                controllerTypes)
            if nargin < 2
                controllerTypes = app.enabledControllerTypes();
            end
            if ~any(controllerTypes)
                types = string([]);
                metadata = struct('type', {}, 'componentElement', {}, ...
                    'usesErrorCenter', {}, 'miscParams', {});
                return
            end
            toolName = app.selectedToolName();
            [~, continuousTypes, ~, continuousMeta] = ...
                generateCostTermStruct("continuous", controllerTypes, ...
                toolName);
            [~, discreteTypes, ~, discreteMeta] = ...
                generateCostTermStruct("discrete", controllerTypes, ...
                toolName);
            types = [continuousTypes, discreteTypes];
            metadata = [continuousMeta, discreteMeta];
            % user_defined appears in both phases
            [types, keep] = unique(types, 'stable');
            metadata = metadata(keep);
        end

        % Metadata for one type, searching every tool and controller so
        % that a type the current selection does not offer, such as one
        % from a loaded settings file, still resolves
        function metadata = costTermMetadataForType(~, type)
            metadata = [];
            tools = ["TrackingOptimization" "VerificationOptimization" ...
                "DesignOptimization"];
            for toolName = tools
                for phase = ["continuous" "discrete"]
                    [~, types, ~, allMetadata] = generateCostTermStruct( ...
                        phase, [true true true true], toolName);
                    index = find(strcmp(types, type), 1);
                    if ~isempty(index)
                        metadata = allMetadata(index);
                        return
                    end
                end
            end
        end

        function costTerm = selectedCostTerm(app)
            costTerm = [];
            if isempty(app.costTerms) || ...
                    app.costTermIndex > numel(app.costTerms)
                return
            end
            costTerm = app.costTerms{app.costTermIndex};
        end

        function createCostTerm(app)
            costTerm = TreatmentOptimizationCostTermClass();
            types = app.availableCostTermTypes();
            if ~isempty(types)
                costTerm.type = types(1);
            end
            app.costTerms{end + 1} = costTerm;
            costTerm.name = "Cost Term " + num2str(numel(app.costTerms));
            costTerm.index = numel(app.costTerms);
            app.applyCostTermType(costTerm, costTerm.type);
            app.costTermIndex = numel(app.costTerms);
            app.updateCostTermsTable();
        end

        % Applies a type's metadata to a term, reseeding the component
        % list and the parameters the new type accepts
        function applyCostTermType(app, costTerm, type)
            % Read before the type changes: these belong to the type being
            % left, not to the user
            previousParams = app.costTermTypeParams(costTerm);
            costTerm.type = type;
            metadata = app.costTermMetadataForType(type);
            if isempty(metadata)
                costTerm.componentElement = "";
                costTerm.uses_error_center = false;
                costTerm.componentList = string([]);
                costTerm.miscParams = struct();
                return
            end
            costTerm.componentElement = metadata.componentElement;
            costTerm.uses_error_center = metadata.usesErrorCenter;
            costTerm.componentList = string([]);
            existing = costTerm.miscParams;
            % A user defined term's extra parameters are the user's, so
            % they survive a round trip through another type. A built in
            % type takes only what its metadata declares, because the name
            % column is locked there and an extra could never be removed.
            if strcmp(type, "user_defined")
                costTerm.miscParams = app.mergeMiscParams( ...
                    metadata.miscParams, app.withoutParams(existing, ...
                    setdiff(previousParams, metadata.miscParams)));
                return
            end
            costTerm.miscParams = struct();
            for i = 1 : numel(metadata.miscParams)
                param = metadata.miscParams(i);
                if isfield(existing, param)
                    costTerm.miscParams.(param) = existing.(param);
                else
                    costTerm.miscParams.(param) = "";
                end
            end
        end

        function deleteCostTerm(app, deletionIndex)
            [app.costTerms, newIndex] = removeTaskFromList( ...
                app.costTerms, deletionIndex, app.costTermIndex);
            app.costTermIndex = newIndex;
            app.updateCostTermsTable();
            app.showSelectedCostTerm();
        end

        function updateCostTermsTable(app)
            updateTaskListTableGui(app.CostTermsListTable, ...
                app.costTerms, "Add a new cost term");
            app.validateCostTerms();
        end

        function costTermIndexListenerFunction(app)
            if ~isvalid(app) || isempty(app.costTerms)
                return
            end
            app.CostTermsListTable.Selection = app.costTermIndex;
            app.showSelectedCostTerm();
        end

        % Loads the selected term into the detail widgets on the right
        function showSelectedCostTerm(app)
            costTerm = app.selectedCostTerm();
            if isempty(costTerm)
                % Clearing Items also clears Value; assigning an empty
                % Value on its own is rejected once Items is populated
                app.CostTermTypeDropDown.Items = {};
                app.CostTermComponentListTextArea.Value = '';
                app.refreshMiscCostParameterTable();
                app.setCostTermDetailsEnabled(false, false, false);
                setGuiFieldStatus([], app.CostTermComponentListStatus, ...
                    "none");
                return
            end
            app.refreshCostTermTypeItems();
            if any(strcmp(app.CostTermTypeDropDown.Items, costTerm.type))
                app.CostTermTypeDropDown.Value = char(costTerm.type);
            end
            app.CostTermComponentListTextArea.Value = ...
                strjoin(costTerm.componentList, ", ");
            app.MaxAllowableErrorEditField.Value = ...
                costTerm.max_allowable_error;
            app.ErrorCenterEditField.Value = costTerm.error_center;
            app.refreshMiscCostParameterTable();
            % User defined terms are configured entirely through the
            % miscellaneous parameters table
            isUserDefined = strcmp(costTerm.type, "user_defined");
            hasComponents = ~isUserDefined && ...
                ~isEmptyStringList(costTerm.componentElement);
            app.setCostTermDetailsEnabled(hasComponents, ...
                ~isUserDefined, ~isUserDefined && costTerm.uses_error_center);
            app.showComponentListStatus(app.CostTermComponentListStatus, ...
                hasComponents, costTerm.componentList);
        end

        function setCostTermDetailsEnabled(app, componentsOn, errorOn, ...
                errorCenterOn)
            app.CostTermComponentListTextArea.Enable = componentsOn;
            app.CostTermComponentListEditButton.Enable = componentsOn;
            app.MaxAllowableErrorEditField.Enable = errorOn;
            app.ErrorCenterEditField.Enable = errorCenterOn;
        end

        % The parameters a type declares are exactly the ones the user may
        % not rename or delete. Reading them from the metadata keeps this
        % right if generateCostTermStruct ever changes the set.
        function names = costTermTypeParams(app, costTerm)
            names = string([]);
            if isempty(costTerm)
                return
            end
            metadata = app.costTermMetadataForType(costTerm.type);
            if ~isempty(metadata)
                names = string(metadata.miscParams);
            end
        end

        % Names a misc parameter cannot take, because the term class
        % handles them itself and loadFromStruct would never give them back
        function reserved = costTermReservedNames(~, costTerm)
            reserved = [TreatmentOptimizationCostTermClass.knownElements, ...
                "name"];
            if ~isempty(costTerm)
                reserved = [reserved, string(costTerm.componentElement)];
            end
            reserved = reserved(~strcmp(reserved, ""));
        end

        function refreshMiscCostParameterTable(app)
            costTerm = app.selectedCostTerm();
            app.refreshMiscParameterTable( ...
                app.MiscellaneousCostTermParametersTable, costTerm, ...
                app.costTermTypeParams(costTerm), ...
                app.MiscellaneousCostTermParametersStatus);
        end

        function refreshCostTermTypeItems(app)
            types = app.availableCostTermTypes();
            costTerm = app.selectedCostTerm();
            % Keep a loaded term's type visible even if the current
            % controller selection would not offer it
            if ~isempty(costTerm) && ~isEmptyStringList(costTerm.type) && ...
                    ~any(strcmp(types, costTerm.type))
                types = [types, costTerm.type];
            end
            app.CostTermTypeDropDown.Items = cellstr(types);
        end

        % The component list source depends on which element the type
        % uses. Cost and constraint terms name the same elements.
        function list = termComponentSource(app, componentElement)
            switch componentElement
                case "coordinate_list"
                    list = app.coordinate_list;
                case "load_list"
                    list = app.tracked_load_labels;
                case "marker_list"
                    list = app.model_markers;
                case {"body_list", "hindfoot_body_list"}
                    list = app.model_bodies;
                case {"force_list", "moment_list"}
                    list = app.tracked_grf_labels;
                case "muscle_list"
                    list = app.model_muscles;
                case "synergy_list"
                    list = app.synergyNames();
                case "controller_list"
                    list = app.controllerNames();
                otherwise
                    list = string([]);
            end
        end

        % Terms name individual synergies as "<group name>_<index>", the
        % form findSynergyIndexByLabel and the synergy control labels use
        function names = synergyNames(app)
            names = string([]);
            for i = 1 : numel(app.osimx_synergy_groups)
                group = app.osimx_synergy_groups{i};
                if ~isfield(group, 'muscleGroupName') || ...
                        ~isfield(group, 'numSynergies')
                    continue
                end
                for synergy = 1 : group.numSynergies
                    names(end + 1) = string(group.muscleGroupName) + ...
                        "_" + num2str(synergy);
                end
            end
        end

        function names = controllerNames(app)
            names = string([]);
            if app.isControllerEnabled(app.TorqueController)
                names = [names, app.TorqueController.coordinate_list];
            end
            if app.isControllerEnabled(app.SynergyController)
                names = [names, app.synergyNames()];
            end
            if app.isControllerEnabled(app.MuscleController)
                names = [names, app.MuscleController.muscle_list];
            end
            names = unique(names, 'stable');
        end

        function validateCostTerms(app)
            removeStyle(app.CostTermsListTable);
            available = app.availableCostTermTypes();
            withAllControllers = app.availableCostTermTypes( ...
                [true true true true]);
            incomplete = [];
            broken = [];
            problems = string([]);
            hasEnabled = false;
            for i = 1 : numel(app.costTerms)
                costTerm = app.costTerms{i};
                if ~strcmp(costTerm.is_enabled, 'true')
                    continue
                end
                hasEnabled = true;
                [severity, reason] = app.costTermProblem(costTerm, ...
                    available, withAllControllers);
                if strcmp(severity, "")
                    continue
                end
                if strcmp(severity, "error")
                    broken(end + 1) = i;
                else
                    incomplete(end + 1) = i;
                end
                problems(end + 1) = "  - " + ...
                    app.termLabel(costTerm, i, "Cost Term") + ": " + reason;
            end
            app.highlightTermRows(app.CostTermsListTable, incomplete, broken);
            app.costTermsValid = hasEnabled && isempty(incomplete) && ...
                isempty(broken);
            if ~hasEnabled
                setGuiFieldStatus([], app.CostTermsListStatus, "required", ...
                    "At least one cost term must be added and enabled.");
            elseif ~isempty(broken)
                setGuiFieldStatus([], app.CostTermsListStatus, "error", ...
                    ["Highlighted cost terms cannot be used:", problems]);
            elseif ~isempty(incomplete)
                setGuiFieldStatus([], app.CostTermsListStatus, "required", ...
                    ["Highlighted cost terms are incomplete:", problems]);
            else
                setGuiFieldStatus([], app.CostTermsListStatus, "none");
            end
        end

        % Constraint term types available for the current tool and
        % controllers. Path and terminal terms share one list, since
        % parseRcnlConstraintTermSet sorts them apart by type.
        function [types, metadata] = availableConstraintTermTypes(app, ...
                controllerTypes)
            if nargin < 2
                controllerTypes = app.enabledControllerTypes();
            end
            if ~any(controllerTypes)
                types = string([]);
                metadata = struct('type', {}, 'componentElement', {}, ...
                    'phase', {}, 'miscParams', {});
                return
            end
            toolName = app.selectedToolName();
            [~, pathTypes, ~, pathMeta] = generateConstraintTermStruct( ...
                "path", controllerTypes, toolName);
            [~, terminalTypes, ~, terminalMeta] = ...
                generateConstraintTermStruct("terminal", ...
                controllerTypes, toolName);
            types = [pathTypes, terminalTypes];
            metadata = [pathMeta, terminalMeta];
            % user_defined appears in both phases
            [types, keep] = unique(types, 'stable');
            metadata = metadata(keep);
        end

        % Metadata for one type, searching every tool and controller so
        % that a type the current selection does not offer, such as one
        % from a loaded settings file, still resolves
        function metadata = constraintTermMetadataForType(~, type)
            metadata = [];
            tools = ["TrackingOptimization" "VerificationOptimization" ...
                "DesignOptimization"];
            for toolName = tools
                for phase = ["path" "terminal"]
                    [~, types, ~, allMetadata] = ...
                        generateConstraintTermStruct(phase, ...
                        [true true true true], toolName);
                    index = find(strcmp(types, type), 1);
                    if ~isempty(index)
                        metadata = allMetadata(index);
                        return
                    end
                end
            end
        end

        function constraintTerm = selectedConstraintTerm(app)
            constraintTerm = [];
            if isempty(app.constraintTerms) || ...
                    app.constraintTermIndex > numel(app.constraintTerms)
                return
            end
            constraintTerm = app.constraintTerms{app.constraintTermIndex};
        end

        function createConstraintTerm(app)
            constraintTerm = TreatmentOptimizationConstraintTermClass();
            types = app.availableConstraintTermTypes();
            if ~isempty(types)
                constraintTerm.type = types(1);
            end
            app.constraintTerms{end + 1} = constraintTerm;
            constraintTerm.name = "Constraint Term " + ...
                num2str(numel(app.constraintTerms));
            constraintTerm.index = numel(app.constraintTerms);
            app.applyConstraintTermType(constraintTerm, ...
                constraintTerm.type);
            app.constraintTermIndex = numel(app.constraintTerms);
            app.updateConstraintTermsTable();
        end

        % Applies a type's metadata to a term, reseeding the component
        % list and the parameters the new type accepts
        function applyConstraintTermType(app, constraintTerm, type)
            % Read before the type changes: these belong to the type being
            % left, not to the user
            previousParams = app.constraintTermTypeParams(constraintTerm);
            constraintTerm.type = type;
            metadata = app.constraintTermMetadataForType(type);
            constraintTerm.componentList = string([]);
            if isempty(metadata)
                constraintTerm.componentElement = "";
                constraintTerm.miscParams = struct();
                return
            end
            constraintTerm.componentElement = metadata.componentElement;
            existing = constraintTerm.miscParams;
            % A user defined term's extra parameters are the user's, so
            % they survive a round trip through another type. A built in
            % type takes only what its metadata declares, because the name
            % column is locked there and an extra could never be removed.
            if strcmp(type, "user_defined")
                constraintTerm.miscParams = app.mergeMiscParams( ...
                    metadata.miscParams, app.withoutParams(existing, ...
                    setdiff(previousParams, metadata.miscParams)));
                return
            end
            constraintTerm.miscParams = struct();
            for i = 1 : numel(metadata.miscParams)
                param = metadata.miscParams(i);
                if isfield(existing, param)
                    constraintTerm.miscParams.(param) = existing.(param);
                else
                    constraintTerm.miscParams.(param) = "";
                end
            end
        end

        function deleteConstraintTerm(app, deletionIndex)
            [app.constraintTerms, newIndex] = removeTaskFromList( ...
                app.constraintTerms, deletionIndex, ...
                app.constraintTermIndex);
            app.constraintTermIndex = newIndex;
            app.updateConstraintTermsTable();
            app.showSelectedConstraintTerm();
        end

        function updateConstraintTermsTable(app)
            updateTaskListTableGui(app.ConstraintTermsListTable, ...
                app.constraintTerms, "Add a new constraint term");
            app.validateConstraintTerms();
        end

        function constraintTermIndexListenerFunction(app)
            if ~isvalid(app) || isempty(app.constraintTerms)
                return
            end
            app.ConstraintTermsListTable.Selection = ...
                app.constraintTermIndex;
            app.showSelectedConstraintTerm();
        end

        % Loads the selected term into the detail widgets on the right
        function showSelectedConstraintTerm(app)
            constraintTerm = app.selectedConstraintTerm();
            if isempty(constraintTerm)
                % Clearing Items also clears Value; assigning an empty
                % Value on its own is rejected once Items is populated
                app.ConstraintTermTypeDropDown.Items = {};
                app.ConstraintTermComponentListTextArea.Value = '';
                app.refreshMiscConstraintParameterTable();
                app.setConstraintTermDetailsEnabled(false, false);
                setGuiFieldStatus([], ...
                    app.ConstraintTermComponentListStatus, "none");
                return
            end
            app.refreshConstraintTermTypeItems();
            if any(strcmp(app.ConstraintTermTypeDropDown.Items, ...
                    constraintTerm.type))
                app.ConstraintTermTypeDropDown.Value = ...
                    char(constraintTerm.type);
            end
            app.ConstraintTermComponentListTextArea.Value = ...
                strjoin(constraintTerm.componentList, ", ");
            app.MaxErrorField.Value = constraintTerm.max_error;
            app.MinErrorEditField.Value = constraintTerm.min_error;
            app.refreshMiscConstraintParameterTable();

            % A user defined term is described entirely by its parameters
            isUserDefined = strcmp(constraintTerm.type, "user_defined");
            hasComponents = ~isUserDefined && ...
                ~isEmptyStringList(constraintTerm.componentElement);
            app.setConstraintTermDetailsEnabled(hasComponents, ...
                ~isUserDefined);
            app.showComponentListStatus( ...
                app.ConstraintTermComponentListStatus, hasComponents, ...
                constraintTerm.componentList);
        end

        function setConstraintTermDetailsEnabled(app, componentsOn, ...
                errorsOn)
            app.ConstraintTermComponentListTextArea.Enable = componentsOn;
            app.ConstraintTermComponentListEditButton.Enable = componentsOn;
            app.MaxErrorField.Enable = errorsOn;
            app.MinErrorEditField.Enable = errorsOn;
        end

        % The parameters a type declares are exactly the ones the user may
        % not rename or delete
        function names = constraintTermTypeParams(app, constraintTerm)
            names = string([]);
            if isempty(constraintTerm)
                return
            end
            metadata = app.constraintTermMetadataForType( ...
                constraintTerm.type);
            if ~isempty(metadata)
                names = string(metadata.miscParams);
            end
        end

        function reserved = constraintTermReservedNames(~, constraintTerm)
            reserved = [ ...
                TreatmentOptimizationConstraintTermClass.knownElements, ...
                "name"];
            if ~isempty(constraintTerm)
                reserved = [reserved, ...
                    string(constraintTerm.componentElement)];
            end
            reserved = reserved(~strcmp(reserved, ""));
        end

        function refreshMiscConstraintParameterTable(app)
            constraintTerm = app.selectedConstraintTerm();
            app.refreshMiscParameterTable( ...
                app.MiscellaneousConstraintTermParametersTable, ...
                constraintTerm, ...
                app.constraintTermTypeParams(constraintTerm), ...
                app.MiscellaneousConstraintTermParametersStatus);
        end

        function refreshConstraintTermTypeItems(app)
            types = app.availableConstraintTermTypes();
            constraintTerm = app.selectedConstraintTerm();
            % Keep a loaded term's type visible even if the current
            % controller selection would not offer it
            if ~isempty(constraintTerm) && ...
                    ~isEmptyStringList(constraintTerm.type) && ...
                    ~any(strcmp(types, constraintTerm.type))
                types = [types, constraintTerm.type];
            end
            app.ConstraintTermTypeDropDown.Items = cellstr(types);
        end

        function validateConstraintTerms(app)
            removeStyle(app.ConstraintTermsListTable);
            available = app.availableConstraintTermTypes();
            withAllControllers = app.availableConstraintTermTypes( ...
                [true true true true]);
            incomplete = [];
            broken = [];
            problems = string([]);
            for i = 1 : numel(app.constraintTerms)
                constraintTerm = app.constraintTerms{i};
                if ~strcmp(constraintTerm.is_enabled, 'true')
                    continue
                end
                [severity, reason] = app.constraintTermProblem( ...
                    constraintTerm, available, withAllControllers);
                if strcmp(severity, "")
                    continue
                end
                if strcmp(severity, "error")
                    broken(end + 1) = i;
                else
                    incomplete(end + 1) = i;
                end
                problems(end + 1) = "  - " + app.termLabel( ...
                    constraintTerm, i, "Constraint Term") + ": " + reason;
            end
            app.highlightTermRows(app.ConstraintTermsListTable, ...
                incomplete, broken);
            % Unlike cost terms, an empty constraint set is legal
            app.constraintTermsValid = isempty(incomplete) && isempty(broken);
            if ~isempty(broken)
                setGuiFieldStatus([], app.ConstraintTermsListStatus, ...
                    "error", ["Highlighted constraint terms cannot be " + ...
                    "used:", problems]);
            elseif ~isempty(incomplete)
                setGuiFieldStatus([], app.ConstraintTermsListStatus, ...
                    "required", ["Highlighted constraint terms are " + ...
                    "incomplete:", problems]);
            else
                setGuiFieldStatus([], app.ConstraintTermsListStatus, ...
                    "none");
            end
        end

        function index = gpopsSettingIndex(app, name)
            index = find(strcmp(app.gpopsSettingNames, name), 1);
        end

        function value = gpopsSettingValue(app, name)
            value = app.gpopsSettingValues(app.gpopsSettingIndex(name));
        end

        % Reads the referenced solver settings file into the table. The
        % file is a separate artifact from the tool settings file, named by
        % <optimal_control_solver_settings_file> when the tool runs.
        function loadSolverSettingsFile(app)
            if strcmp(app.solver_settings_file, "")
                return
            end
            if ~isfile(app.solver_settings_file)
                return
            end
            settings = app.readSolverSettingsTree();
            if isempty(settings)
                return
            end
            if isfield(settings, 'CasadiSettings')
                app.solver_type = "Casadi";
                app.SolverSelectionDropDown.Value = 'Casadi';
                app.applySolverType();
                return
            end
            if ~isfield(settings, 'GpopsSettings')
                return
            end
            app.solver_type = "GPOPS-II";
            app.SolverSelectionDropDown.Value = 'GPOPS-II';
            app.applySolverType();
            gpops = settings.GpopsSettings;
            % Absent elements keep the default, matching how
            % parseGpopsSolverSettings falls back. An element written
            % empty, as <setup_mesh_method/>, carries no value either, so
            % it keeps the default rather than putting a blank in the
            % table; toGuiText reads both shapes.
            values = app.defaultGpopsSettingValues;
            for i = 1 : numel(app.gpopsSettingNames)
                name = app.gpopsSettingNames(i);
                if ~isfield(gpops, name)
                    continue
                end
                text = toGuiText(gpops.(name));
                if ~strcmp(text, "")
                    values(i) = text;
                end
            end
            app.gpopsSettingValues = values;
        end

        % Returns the OptimalControlSolverSettings node, or [] with the
        % field status already set when the file cannot be read
        function settings = readSolverSettingsTree(app)
            settings = [];
            try
                tree = xml2struct(app.solver_settings_file);
                verifyVersion(tree, "OptimalControlSolverSettings");
            catch exception
                throwGuiError(string(exception.message), ...
                    app.SolverSettingsFileEditField, ...
                    app.SolverSettingsFileStatus);
                return
            end
            if ~isfield(tree.NMSMPipelineDocument, ...
                    'OptimalControlSolverSettings')
                throwGuiError("The file has no " + ...
                    "<OptimalControlSolverSettings> element.", ...
                    app.SolverSettingsFileEditField, ...
                    app.SolverSettingsFileStatus);
                return
            end
            settings = ...
                tree.NMSMPipelineDocument.OptimalControlSolverSettings;
        end

        % Casadi settings are not editable here yet. uitable Enable takes
        % only the literal on/off strings, unlike most other components.
        function applySolverType(app)
            isGpops = strcmp(app.solver_type, "GPOPS-II");
            if isGpops
                app.SolverSettingsTable.Enable = 'on';
            else
                app.SolverSettingsTable.Enable = 'off';
            end
            app.MakeDefaultSettingsFileButton.Enable = isGpops;
        end

        function tree = gpopsSettingsTree(app)
            tree = struct();
            tree.Attributes.name = 'default';
            for i = 1 : numel(app.gpopsSettingNames)
                tree.GpopsSettings.(app.gpopsSettingNames(i)) = ...
                    convertStringsToChars(app.gpopsSettingValues(i));
            end
        end

        % validateAdvancedSettingsGui is not reused here: it rejects
        % anything <= 0, but the minimum_range settings legitimately
        % default to 0, and JMP/MTP/NCP depend on that rule unchanged.
        function validateAdvancedSettings(app)
            removeStyle(app.AdvancedParamsTable);
            app.AdvancedParamsTable.Tooltip = '';
            rows = app.advancedSettingRows();
            messages = strings(0, 1);
            for row = 1 : numel(rows)
                [isValid, reason] = app.advancedSettingProblem(rows(row));
                if isValid
                    continue
                end
                % addStyle indexes the view, so the loop counter is used
                % here rather than the index into advancedSettingNames
                addStyle(app.AdvancedParamsTable, ...
                    uistyle('BackgroundColor', [1.00 0.67 0.67]), ...
                    'row', row);
                messages(end + 1) = app.advancedSettingNames(rows(row)) + ...
                    ": " + reason; %#ok<AGROW>
            end
            app.advancedSettingsValid = isempty(messages);
            if app.advancedSettingsValid
                setGuiFieldStatus([], app.AdvancedParamsStatus, "none");
                return
            end
            message = strjoin(messages, newline);
            app.AdvancedParamsTable.Tooltip = message;
            setGuiFieldStatus([], app.AdvancedParamsStatus, "error", ...
                message);
        end

        function [isValid, reason] = advancedSettingProblem(app, index)
            isValid = true;
            reason = "";
            value = strtrim(app.advancedSettingValues(index));
            switch app.advancedSettingKinds(index)
                case "boolean"
                    % getBooleanLogicFromField compares the text to 'true'
                    isValid = any(strcmp(["true" "false"], value));
                    reason = "must be true or false";
                case "range"
                    if strlength(value) == 0
                        return  % optional; blank is not written at all
                    end
                    numbers = str2double(split(value))';
                    % (1) is the lower final time bound, (2) becomes maxTime
                    isValid = numel(numbers) == 2 && ...
                        all(isfinite(numbers)) && numbers(2) > numbers(1);
                    reason = "must be two increasing numbers, or blank";
                case "positive"
                    number = str2double(value);
                    isValid = ~isnan(number) && number > 0;
                    reason = "must be a positive number";
                case "nonnegative"
                    number = str2double(value);
                    isValid = ~isnan(number) && number >= 0;
                    reason = "must be zero or a positive number";
            end
        end

        function validateSolverSettings(app)
            removeStyle(app.SolverSettingsTable);
            if ~strcmp(app.solver_type, "GPOPS-II")
                app.solverSettingsValid = false;
                setGuiFieldStatus([], app.SolverSettingsStatus, "error", ...
                    "Only the GPOPS-II solver is supported so far.");
                return
            end
            invalid = [];
            for i = 1 : numel(app.gpopsSettingNames)
                if ~app.isGpopsSettingValid(i)
                    invalid(end + 1) = i;
                end
            end
            for i = invalid
                addStyle(app.SolverSettingsTable, ...
                    uistyle('BackgroundColor', [1.00 0.67 0.67]), 'row', i);
            end
            app.solverSettingsValid = isempty(invalid);
            if isempty(invalid)
                setGuiFieldStatus([], app.SolverSettingsStatus, "none");
            else
                setGuiFieldStatus([], app.SolverSettingsStatus, "error", ...
                    "Highlighted settings are not valid values.");
            end
        end

        % Enumerated settings must name one of their options; the rest must
        % be numbers, held to the ranges GpopsReference.xml states outright
        function isValid = isGpopsSettingValid(app, index)
            value = app.gpopsSettingValues(index);
            options = app.gpopsSettingOptions{index};
            if ~isEmptyStringList(options)
                isValid = any(strcmp(options, value));
                return
            end
            number = str2double(value);
            if isnan(number)
                isValid = false;
                return
            end
            isValid = true;
            % setupGpopsSettings skips the mesh refinement settings when no
            % mesh method is chosen, so their ranges do not apply either
            if app.isUnusedMeshSetting(index)
                return
            end
            switch app.gpopsSettingNames(index)
                case "setup_derivatives_step_size"
                    isValid = number > 0;
                case "setup_mesh_tolerance"
                    isValid = number > 0 && number < 1;
                case "setup_mesh_max_iterations"
                    isValid = number >= 0 && mod(number, 1) == 0;
                case "setup_mesh_colpoints_min"
                    isValid = number > 2 && mod(number, 1) == 0;
                case "setup_mesh_colpoints_max"
                    isValid = mod(number, 1) == 0 && number >= str2double( ...
                        app.gpopsSettingValue("setup_mesh_colpoints_min"));
                case {"setup_mesh_splitmult", "setup_mesh_curveratio", ...
                        "setup_mesh_R"}
                    isValid = number > 1;
                case "setup_mesh_sigma"
                    isValid = number > 0;
                case {"setup_mesh_phase_intervals", ...
                        "setup_mesh_phase_colpoints_per_Interval", ...
                        "setup_nlp_max_iterations", "integral_bound"}
                    isValid = number > 0 && mod(number, 1) == 0;
                case "setup_nlp_tolerance"
                    isValid = number > 0;
            end
        end

        % The tool element name is what findToolName keys off to decide
        % which tool a settings file drives
        function name = toolElementName(app)
            name = app.selectedToolName() + "Tool";
        end

        function settingsTree = makeSettingsStruct(app, settingsFileName)
            settingsPath = fileparts(settingsFileName);

            settingsTree.input_model_file = getRelativePath( ...
                app.input_model_file, settingsPath);
            settingsTree.input_osimx_file = getRelativePath( ...
                app.input_osimx_file, settingsPath);
            settingsTree.tracked_quantities_directory = getRelativePath( ...
                app.tracked_quantities_directory, settingsPath);
            settingsTree.initial_guess_directory = getRelativePath( ...
                app.initial_guess_directory, settingsPath);
            settingsTree.results_directory = getRelativePath( ...
                app.results_directory, settingsPath);
            settingsTree.optimal_control_solver_settings_file = ...
                getRelativePath(app.solver_settings_file, settingsPath);
            settingsTree.trial_name = app.trial_prefix;
            settingsTree.states_coordinate_list = app.coordinate_list;

            % Written as text so a boolean reaches getBooleanLogicFromField
            % as the literal 'true'/'false' it compares against. A blank
            % optional setting is omitted entirely: an empty or NaN
            % final_time_range would make isfield(inputs,"finalTimeRange")
            % true and corrupt the time bounds in
            % setupTreatmentOptimizationBounds.
            for i = 1 : length(app.advancedSettingNames)
                if ~app.isAdvancedSettingUsed(i)
                    continue
                end
                value = strtrim(app.advancedSettingValues(i));
                if strlength(value) == 0
                    continue
                end
                settingsTree.(app.advancedSettingNames(i)) = value;
            end

            % A controller is on exactly when its element is present
            if app.isControllerEnabled(app.TorqueController)
                settingsTree.RCNLTorqueController = ...
                    app.TorqueController.toStruct();
            end
            if app.isControllerEnabled(app.SynergyController)
                settingsTree.RCNLSynergyController = ...
                    app.SynergyController.toStruct();
            end
            if app.isControllerEnabled(app.MuscleController)
                settingsTree.RCNLMuscleController = ...
                    app.MuscleController.toStruct();
            end
            % parseMuscleSettings only runs for the muscle based controllers
            if app.isControllerEnabled(app.SynergyController) || ...
                    app.isControllerEnabled(app.MuscleController)
                settingsTree.RCNLMuscleModel = app.MuscleModel.toStruct();
            end

            settingsTree.RCNLCostTermSet = struct("RCNLCostTerm", cell(1));
            for i = 1 : numel(app.costTerms)
                settingsTree.RCNLCostTermSet.RCNLCostTerm{i} = ...
                    app.costTerms{i}.toStruct();
            end
            settingsTree.RCNLConstraintTermSet = ...
                struct("RCNLConstraintTerm", cell(1));
            for i = 1 : numel(app.constraintTerms)
                settingsTree.RCNLConstraintTermSet ...
                    .RCNLConstraintTerm{i} = ...
                    app.constraintTerms{i}.toStruct();
            end

            settingsTree = formatGuiDataForXml(settingsTree);
        end

        % findToolName decides the tool from which element is present, so
        % the GUI has to look for all three before it can check the version
        function toolElement = findSettingsToolElement(app, ...
                settingsFileName)
            toolElement = "";
            try
                tree = xml2struct(settingsFileName);
            catch exception
                app.reportLoadFailure(exception.message);
                return
            end
            if ~isfield(tree, 'NMSMPipelineDocument')
                app.reportLoadFailure("The file is not an " + ...
                    "<NMSMPipelineDocument>.");
                return
            end
            candidates = ["TrackingOptimizationTool"
                "VerificationOptimizationTool"
                "DesignOptimizationTool"];
            found = candidates(isfield(tree.NMSMPipelineDocument, ...
                candidates));
            if isempty(found)
                app.reportLoadFailure("The file holds none of the " + ...
                    "Treatment Optimization tool elements.");
                return
            end
            try
                verifyVersion(tree, found(1));
            catch exception
                app.reportLoadFailure(exception.message);
                return
            end
            toolElement = found(1);
        end

        function reportLoadFailure(app, message)
            uialert(app.UIFigure, string(message), ...
                "Unable to load settings file");
        end

        function name = toolDisplayName(~, toolElement)
            switch toolElement
                case "VerificationOptimizationTool"
                    name = "Verification Optimization";
                case "DesignOptimizationTool"
                    name = "Design Optimization";
                otherwise
                    name = "Tracking Optimization";
            end
        end

        function applyInputSettings(app, settingsTree)
            % The model has to land before the osimx file, which is parsed
            % against it
            app.input_model_file = app.settingsPath(settingsTree, ...
                'input_model_file');
            app.tracked_quantities_directory = app.settingsPath( ...
                settingsTree, 'tracked_quantities_directory');
            app.initial_guess_directory = app.settingsPath(settingsTree, ...
                'initial_guess_directory');
            app.results_directory = app.settingsPath(settingsTree, ...
                'results_directory');
            if isfield(settingsTree, 'trial_name')
                app.trial_prefix = toGuiText(settingsTree.trial_name);
            end
            app.input_osimx_file = app.settingsPath(settingsTree, ...
                'input_osimx_file');
            app.solver_settings_file = app.settingsPath(settingsTree, ...
                'optimal_control_solver_settings_file');
            if isfield(settingsTree, 'states_coordinate_list')
                app.coordinate_list = toGuiStringList( ...
                    settingsTree.states_coordinate_list);
            end
        end

        % Stored paths are relative to the settings file's own directory
        function value = settingsPath(app, settingsTree, field)
            value = "";
            if ~isfield(settingsTree, field)
                return
            end
            value = toGuiText(settingsTree.(field));
            if strcmp(value, "")
                return
            end
            if ~isAbsolutePath(value)
                value = fullfile(app.settingsDirectory, value);
            end
            value = string(GetFullPath(value));
        end

        function applyAdvancedSettings(app, settingsTree)
            values = app.advancedSettingValues;
            for i = 1 : length(app.advancedSettingNames)
                name = app.advancedSettingNames(i);
                if ~isfield(settingsTree, name)
                    continue  % an older file simply keeps the default
                end
                text = app.advancedSettingText(settingsTree.(name));
                if strlength(text) == 0
                    continue
                end
                % getBooleanLogicFromField is case sensitive, so a file
                % holding True was being read as false by the backend.
                % Normalizing here makes it mean what the user wrote.
                if strcmp(app.advancedSettingKinds(i), "boolean") && ...
                        any(strcmpi(["true" "false"], text))
                    text = lower(text);
                end
                values(i) = text;
            end
            app.advancedSettingValues = values;
        end

        % formatXmlDataForGui has already turned "0.5 1.5" into a double
        % array and "false" into a string, so both shapes arrive here and
        % both have to come back out as one piece of text
        function text = advancedSettingText(~, value)
            if isstruct(value) && isfield(value, 'Text')
                value = value.Text;
            end
            if isnumeric(value) || islogical(value)
                parts = arrayfun(@(v)string(num2str(v, '%.10g')), ...
                    double(value(:))');
            else
                parts = string(value(:))';
            end
            text = strtrim(strjoin(parts, " "));
        end

        function applyControllerSettings(app, settingsTree)
            if isfield(settingsTree, 'RCNLTorqueController')
                app.TorqueController.loadFromStruct( ...
                    settingsTree.RCNLTorqueController);
            end
            if isfield(settingsTree, 'RCNLSynergyController')
                app.SynergyController.loadFromStruct( ...
                    settingsTree.RCNLSynergyController);
            end
            if isfield(settingsTree, 'RCNLMuscleController')
                app.MuscleController.loadFromStruct( ...
                    settingsTree.RCNLMuscleController);
            end
            if isfield(settingsTree, 'RCNLMuscleModel')
                app.MuscleModel.loadFromStruct( ...
                    settingsTree.RCNLMuscleModel);
            end
            app.updateTorqueAdvancedSettingsTable();
            app.updateSynergyAdvancedSettingsTable();
            app.updateMuscleAdvancedSettingsTable();
            app.updateSurrogateModelAdvancedSettingsTable();
        end

        function applyCostTermSettings(app, settingsTree)
            terms = app.settingsTermList(settingsTree, ...
                'RCNLCostTermSet', 'RCNLCostTerm');
            app.costTerms = cell(0);
            for i = 1 : numel(terms)
                costTerm = TreatmentOptimizationCostTermClass();
                type = app.settingsTermType(terms{i});
                metadata = app.costTermMetadataForType(type);
                componentElement = "";
                if ~isempty(metadata)
                    componentElement = metadata.componentElement;
                end
                costTerm.loadFromStruct(terms{i}, componentElement);
                if ~isempty(metadata)
                    costTerm.uses_error_center = metadata.usesErrorCenter;
                    costTerm.miscParams = app.mergeMiscParams( ...
                        metadata.miscParams, costTerm.miscParams);
                end
                if isEmptyStringList(costTerm.name)
                    costTerm.name = "Cost Term " + num2str(i);
                end
                costTerm.index = i;
                app.costTerms{i} = costTerm;
            end
            app.costTermIndex = 1;
            app.updateCostTermsTable();
            app.showSelectedCostTerm();
        end

        function applyConstraintTermSettings(app, settingsTree)
            terms = app.settingsTermList(settingsTree, ...
                'RCNLConstraintTermSet', 'RCNLConstraintTerm');
            app.constraintTerms = cell(0);
            for i = 1 : numel(terms)
                constraintTerm = ...
                    TreatmentOptimizationConstraintTermClass();
                type = app.settingsTermType(terms{i});
                metadata = app.constraintTermMetadataForType(type);
                componentElement = "";
                if ~isempty(metadata)
                    componentElement = metadata.componentElement;
                end
                constraintTerm.loadFromStruct(terms{i}, componentElement);
                if ~isempty(metadata)
                    constraintTerm.miscParams = app.mergeMiscParams( ...
                        metadata.miscParams, constraintTerm.miscParams);
                end
                if isEmptyStringList(constraintTerm.name)
                    constraintTerm.name = "Constraint Term " + num2str(i);
                end
                constraintTerm.index = i;
                app.constraintTerms{i} = constraintTerm;
            end
            app.constraintTermIndex = 1;
            app.updateConstraintTermsTable();
            app.showSelectedConstraintTerm();
        end

        % xml2struct yields a bare struct for a single entry and a cell
        % array for several, and the set element may be absent or empty
        function terms = settingsTermList(~, settingsTree, setName, ...
                termName)
            terms = {};
            if ~isfield(settingsTree, setName)
                return
            end
            set = settingsTree.(setName);
            if ~isstruct(set) || ~isfield(set, termName)
                return
            end
            terms = set.(termName);
            if isstruct(terms)
                terms = {terms};
            elseif ~iscell(terms)
                terms = {};
            end
            terms = terms(~cellfun(@isempty, terms));
        end

        % A saved term only carries the parameters that had values, so a
        % loaded term is refilled with everything its type accepts. Any
        % element the GUI does not know about is kept on the end.
        function merged = mergeMiscParams(~, allowed, loaded)
            merged = struct();
            for i = 1 : numel(allowed)
                param = allowed(i);
                if isfield(loaded, param)
                    merged.(param) = loaded.(param);
                else
                    merged.(param) = "";
                end
            end
            names = fieldnames(loaded);
            for i = 1 : numel(names)
                if ~isfield(merged, names{i})
                    merged.(names{i}) = loaded.(names{i});
                end
            end
        end

        function type = settingsTermType(~, term)
            type = "";
            if isfield(term, 'type')
                type = toGuiText(term.type);
            end
        end

        function isUnused = isUnusedMeshSetting(app, index)
            refinementSettings = ["setup_mesh_tolerance"
                "setup_mesh_max_iterations"
                "setup_mesh_colpoints_min"
                "setup_mesh_colpoints_max"
                "setup_mesh_splitmult"
                "setup_mesh_curveratio"
                "setup_mesh_R"
                "setup_mesh_sigma"];
            isUnused = any(strcmp(refinementSettings, ...
                app.gpopsSettingNames(index))) && ...
                strcmp(app.gpopsSettingValue("setup_mesh_method"), "none");
        end
    end

    methods (Access = public)
        % The settings file entry points are public so the Run button and
        % scripted callers can drive them without a file dialog
        % TreatmentOptimizationRun dispatches on this rather than mapping
        % the tool dropdown's display name a second time
        function name = selectedToolElement(app)
            name = app.toolElementName();
        end

        function saveSettingsFile(app, settingsFileName)
            app.currentSettingsFile = settingsFileName;
            saveGuiSettings(settingsFileName, app.toolElementName(), ...
                app.makeSettingsStruct(settingsFileName));
        end

        function loadSettingsFile(app, settingsFileName)
            toolElement = app.findSettingsToolElement(settingsFileName);
            if strcmp(toolElement, "")
                return
            end
            app.resetAllFields();
            app.currentSettingsFile = settingsFileName;
            % Stored paths are relative to the settings file's own
            % directory, so work from there, as MTP/NCP/JMP do. Going
            % through GetFullPath first keeps fileparts from returning ""
            % when the caller passes a bare file name, which cd rejects.
            app.settingsDirectory = string(fileparts( ...
                GetFullPath(settingsFileName)));
            cd(app.settingsDirectory);
            settingsTree = loadGuiSettings(settingsFileName, toolElement);

            app.selected_tool = app.toolDisplayName(toolElement);
            app.applyInputSettings(settingsTree);
            app.applyAdvancedSettings(settingsTree);
            app.applyControllerSettings(settingsTree);
            app.applyCostTermSettings(settingsTree);
            app.applyConstraintTermSettings(settingsTree);
            app.validateAllFields();
        end

        function setSelectedObjects(app, objects)
            % Function to assign objects selected by ObjectSelectionWindow
            switch app.objectSelectionType
                case 'coordinate'
                    app.coordinate_list = objects;
                case 'torqueCoordinate'
                    app.TorqueController.coordinate_list = objects;
                case 'surrogateCoordinate'
                    app.MuscleModel.coordinate_list = objects;
                case 'muscle'
                    app.MuscleController.muscle_list = objects;
                case 'constraintTermComponent'
                    constraintTerm = app.selectedConstraintTerm();
                    if ~isempty(constraintTerm)
                        constraintTerm.componentList = objects;
                        app.showSelectedConstraintTerm();
                        app.validateConstraintTerms();
                    end
                case 'costTermComponent'
                    costTerm = app.selectedCostTerm();
                    if ~isempty(costTerm)
                        costTerm.componentList = objects;
                        app.showSelectedCostTerm();
                        app.validateCostTerms();
                        app.updateTabControls();
                    end
            end
        end

        function setModelMarkers(app, markers)
            app.model_markers = markers;
        end

        function setModelJoints(app, joints)
            app.model_joints = joints;
        end

        function setModelBodies(app, bodies)
            app.model_bodies = bodies;
        end

        function setModelCoordinates(app, coordinates)
            app.model_coordinates = coordinates;
        end

        function setModelGroups(app, groups)
            app.model_groups = groups;
        end

        function setModelMuscles(app, muscles)
            app.model_muscles = muscles;
        end

        function setTrackedCoordinateLabels(app, labels)
            app.tracked_coordinate_labels = labels;
        end

        function setTrackedLoadLabels(app, labels)
            app.tracked_load_labels = labels;
        end

        function setTrackedEmgLabels(app, labels)
            app.tracked_emg_labels = labels;
        end

        function setTrackedGrfLabels(app, labels)
            app.tracked_grf_labels = labels;
        end

        function setTrackedMomentArmCoordinates(app, coordinates)
            app.tracked_moment_arm_coordinates = coordinates;
        end

        function setTrackedMomentArmMuscles(app, muscles)
            app.tracked_moment_arm_muscles = muscles;
        end

        function setOsimxSynergyGroups(app, synergyGroups)
            app.osimx_synergy_groups = synergyGroups;
        end
    end


    % Callbacks that handle component events
    methods (Access = private)

        % Code that executes after component creation
        function startupFcn(app)
            % Reconstruct fresh instances so this app doesn't share
            % handle objects with the default property-value cache
            app.TorqueController = RCNLTorqueControllerClass();
            app.SynergyController = RCNLSynergyControllerClass();
            app.MuscleController = RCNLMuscleControllerClass();
            app.MuscleModel = RCNLMuscleModelClass();

            app.makeListeners()
            app.advancedSettingValues = app.defaultAdvancedSettingValues;
            app.gpopsSettingValues = app.defaultGpopsSettingValues;
            app.updateTorqueAdvancedSettingsTable();
            app.updateSynergyAdvancedSettingsTable();
            app.updateMuscleAdvancedSettingsTable();
            app.updateSurrogateModelAdvancedSettingsTable();
            app.updateCostTermsTable();
            app.updateConstraintTermsTable();
            % Marks every required field so the user can see what is needed
            app.validateAllFields();
            app.formatTabButtons()
            app.formatControllersTabButtons()
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
            % The tools read a settings file, so an unsaved session has to
            % be written somewhere before it can run
            if strcmp(app.currentSettingsFile, "")
                [file, path] = uiputfile('*.xml', "Save XML Settings File");
                % User hit "Cancel"
                if isequal(file, 0)
                    return
                end
                app.currentSettingsFile = fullfile(path, file);
            end
            app.saveSettingsFile(app.currentSettingsFile);
            TreatmentOptimizationRun(app, app.currentSettingsFile);
        end

        % Button pushed function: HelpButton
        function HelpButtonPushed(app, event)
            web("https://nmsm.rice.edu/")
        end

        % Button pushed function: ResetButton
        function ResetButtonPushed(app, event)
            app.resetAllFields();
        end

        % Image clicked function: RcnlLogo
        function RcnlLogoImageClicked(app, event)
            web("https://nmsm.rice.edu/")
        end

        % Button pushed function: InputsButton
        function InputsButtonPushed(app, event)
            app.TabGroup.SelectedTab = app.InputsTab;
        end

        % Button pushed function: SolverSettingsButton
        function SolverSettingsButtonPushed(app, event)
            app.TabGroup.SelectedTab = app.SolverSettingsTab;
        end

        % Button pushed function: ControllersButton
        function ControllersButtonPushed(app, event)
            app.TabGroup.SelectedTab = app.ControllersTab;
        end

        % Button pushed function: CostTermsButton
        function CostTermsButtonPushed(app, event)
            app.TabGroup.SelectedTab = app.CostTermsTab;
        end

        % Button pushed function: ConstraintTermsButton
        function ConstraintTermsButtonPushed(app, event)
            app.TabGroup.SelectedTab = app.ConstraintTermsTab;
        end

        % Button pushed function: AdvancedButton
        function AdvancedButtonPushed(app, event)
            app.TabGroup.SelectedTab = app.AdvancedTab;
        end

        % Button pushed function: TorqueControlsButton
        function TorqueControlsButtonPushed(app, event)
            app.ControllersTabGroup.SelectedTab = app.TorqueTab;
        end

        % Button pushed function: SynergyControlsButton
        function SynergyControlsButtonPushed(app, event)
            app.ControllersTabGroup.SelectedTab = app.SynergyTab;
        end

        % Button pushed function: UserDefinedControlsButton
        function UserDefinedControlsButtonPushed(app, event)
            app.ControllersTabGroup.SelectedTab = app.UserDefinedTab;
        end

        % Value changed function: InputModelFileEditField
        function InputModelFileEditFieldValueChanged(app, event)
            app.input_model_file = ...
                getPathFieldValue(app.InputModelFileEditField);
        end

        % Button pushed function: InputModelFileSearchButton
        function InputModelFileSearchButtonPushed(app, event)
            [file, path] = uigetfile('*.osim', "Select an OpenSim Model File");
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
            [file, path] = uigetfile('*.osimx', "Select an Osimx Model File");
            % User hit "Cancel"
            if isequal(file, 0)
                return
            end
            app.input_osimx_file = fullfile(path, file);
        end

        % Value changed function: InputDataEditField
        function InputDataEditFieldValueChanged(app, event)
            app.tracked_quantities_directory = ...
                getPathFieldValue(app.TrackedQuantitiesDirectoryEditField);
        end

        % Button pushed function: TrackedQuantitiesSearchButton
        function TrackedQuantitiesSearchButtonPushed(app, event)
            folder = uigetdir("Select your tracked quantities data folder");
            % User hit "Cancel"
            if isequal(folder, 0)
                return
            end
            app.tracked_quantities_directory = folder;
        end

        % Value changed function: MTPResultsDirEditField
        function MTPResultsDirEditFieldValueChanged(app, event)
            app.initial_guess_directory = ...
                getPathFieldValue(app.InitialGuessDirectoryEditField);
        end

        % Button pushed function: InitialGuessSearchButton
        function InitialGuessSearchButtonPushed(app, event)
            folder = uigetdir("Select your initial guess folder");
            % User hit "Cancel"
            if isequal(folder, 0)
                return
            end
            app.initial_guess_directory = folder;
        end

        % Value changed function: ResultsDirectoryEditField
        function ResultsDirectoryEditFieldValueChanged(app, event)
            app.results_directory = ...
                getPathFieldValue(app.ResultsDirectoryEditField);
        end

        % Button pushed function: ResultsDirectorySearchButton
        function ResultsDirectorySearchButtonPushed(app, event)
            folder = uigetdir("Select a folder to store your results");
            % User hit "Cancel"
            if isequal(folder, 0)
                return
            end
            app.results_directory = folder;
        end

        % Button pushed function: CoordinateListEditButton
        function CoordinateListEditButtonPushed(app, event)
            app.objectSelectionType = 'coordinate';
            ObjectSelectionWindow(app, app.filteredSelectionList( ...
                app.model_coordinates, app.tracked_coordinate_labels), ...
                app.coordinate_list)
        end

        % Value changed function: TrialPrefixEditField
        function TrialPrefixEditFieldValueChanged(app, event)
            app.trial_prefix = app.TrialPrefixEditField.Value;
        end

        % Value changed function: ToolSelectionDropDown
        function ToolSelectionDropDownValueChanged(app, event)
            app.selected_tool = app.ToolSelectionDropDown.Value;
        end

        % Value changed function: UseRCNLTorqueControllerCheckBox
        function UseRCNLTorqueControllerCheckBoxValueChanged(app, event)
            app.TorqueController.is_enabled = ...
                boolToString(app.UseRCNLTorqueControllerCheckBox.Value);
        end

        % Button pushed function: TorqueControllerCoordinateEditButton
        function TorqueControllerCoordinateEditButtonPushed(app, event)
            app.objectSelectionType = 'torqueCoordinate';
            % Inverse dynamics labels are named <coordinate>_moment/_force
            loadCoordinates = erase(erase(app.tracked_load_labels, ...
                '_moment'), '_force');
            ObjectSelectionWindow(app, app.filteredSelectionList( ...
                app.coordinate_list, loadCoordinates), ...
                app.TorqueController.coordinate_list)
        end

        % Cell edit callback: TorqueAdvancedSettingsTable
        function TorqueAdvancedSettingsTableCellEdit(app, event)
            app.TorqueController.setParameterValueByIndex( ...
                event.Indices(1), str2double(event.NewData));
        end

        % Value changed function: UseRCNLSynergyControllerCheckBox
        function UseRCNLSynergyControllerCheckBoxValueChanged(app, event)
            app.SynergyController.is_enabled = ...
                boolToString(app.UseRCNLSynergyControllerCheckBox.Value);
        end

        % Value changed function: OptimizeSynergyVectorsCheckBox
        function OptimizeSynergyVectorsCheckBoxValueChanged(app, event)
            app.SynergyController.optimize_synergy_vectors = ...
                boolToString(app.OptimizeSynergyVectorsCheckBox.Value);
        end

        % Value changed function: SynergyVectorNormalizationMethodDropDown
        function SynergyVectorNormalizationMethodDropDownValueChanged(app, event)
            app.SynergyController.synergy_vector_normalization_method = ...
                app.SynergyVectorNormalizationMethodDropDown.Value;
        end

        % Button pushed function: SurrogateModelCoordinatesListEditButton
        function SurrogateModelCoordinatesListEditButtonPushed(app, event)
            app.objectSelectionType = 'surrogateCoordinate';
            ObjectSelectionWindow(app, app.model_coordinates, ...
                app.MuscleModel.coordinate_list)
        end

        % Cell edit callback: SynergyControllerAdvancedSettingsTable
        function SynergyControllerAdvancedSettingsTableCellEdit(app, event)
            app.SynergyController.setParameterValueByIndex( ...
                event.Indices(1), str2double(event.NewData));
        end

        % Button pushed function: MuscleControllerMuscleListEditButton
        function MuscleControllerMuscleListEditButtonPushed(app, event)
            app.objectSelectionType = 'muscle';
            ObjectSelectionWindow(app, app.filteredSelectionList( ...
                app.model_muscles, app.tracked_moment_arm_muscles), ...
                app.MuscleController.muscle_list)
        end

        % Cell edit callback: MuscleControllerAdvancedSettingsTable
        function MuscleControllerAdvancedSettingsTableCellEdit(app, event)
            app.MuscleController.setParameterValueByIndex( ...
                event.Indices(1), str2double(event.NewData));
        end

        % Value changed function: UseRCNLMuscleControllerCheckBox
        function UseRCNLMuscleControllerCheckBoxValueChanged(app, event)
            app.MuscleController.is_enabled = ...
                boolToString(app.UseRCNLMuscleControllerCheckBox.Value);
        end

        % Value changed function: SurrogateModelDataDirectoryEditField
        function SurrogateModelDataDirectoryEditFieldValueChanged(app, event)
            app.MuscleModel.data_directory = ...
                getPathFieldValue(app.SurrogateModelDataDirectoryEditField);
        end

        % Button pushed function: SurrogateModelDataDirectorySearchButton
        function SurrogateModelDataDirectorySearchButtonPushed(app, event)
            folder = uigetdir("Select your surrogate model data folder");
            % User hit "Cancel"
            if isequal(folder, 0)
                return
            end
            app.MuscleModel.data_directory = folder;
        end

        % Value changed function: SurrogateModelFileNameEditField
        function SurrogateModelFileNameEditFieldValueChanged(app, event)
            app.MuscleModel.file_name = ...
                getPathFieldValue(app.SurrogateModelFileNameEditField);
        end

        % Button pushed function: SurrogateModelFileNameSearchButton
        function SurrogateModelFileNameSearchButtonPushed(app, event)
            [file, path] = uigetfile('*.mat', "Select a Surrogate Model File");
            % User hit "Cancel"
            if isequal(file, 0)
                return
            end
            app.MuscleModel.file_name = fullfile(path, file);
        end

        % Value changed function: MuscleActivationsFileEditField
        function MuscleActivationsFileEditFieldValueChanged(app, event)
            app.MuscleModel.muscle_activations_file = ...
                getPathFieldValue(app.MuscleActivationsFileEditField);
        end

        % Button pushed function: MuscleActivationsFileSearchButton
        function MuscleActivationsFileSearchButtonPushed(app, event)
            [file, path] = uigetfile('*.sto', "Select a Muscle Activations File");
            % User hit "Cancel"
            if isequal(file, 0)
                return
            end
            app.MuscleModel.muscle_activations_file = fullfile(path, file);
        end

        % Cell edit callback: SurrogateModelAdvancedSettingsTable
        function SurrogateModelAdvancedSettingsTableCellEdit(app, event)
            index = event.Indices(1);
            if isRcnlParameterBoolean(app.MuscleModel, index)
                text = lower(strtrim(string(event.NewData)));
                if any(strcmp(["true" "false"], text))
                    app.MuscleModel.setParameterValueByIndex(index, ...
                        convertStringsToChars(text));
                end
            else
                app.MuscleModel.setParameterValueByIndex(index, ...
                    str2double(event.NewData));
            end
            % This table has no PostSet listener, so the redraw that snaps
            % a rejected edit back has to be explicit
            app.updateSurrogateModelAdvancedSettingsTable();
        end

        % Cell edit callback: AdvancedParamsTable
        function AdvancedParamsTableCellEdit(app, event)
            rows = app.advancedSettingRows();
            % The table can hide a row, so the view index has to be mapped
            % back onto advancedSettingNames
            index = rows(event.Indices(1));
            text = strtrim(string(event.NewData));
            % Stored lower case whatever the user typed, because
            % getBooleanLogicFromField compares against 'true' exactly
            if strcmp(app.advancedSettingKinds(index), "boolean") && ...
                    any(strcmpi(["true" "false"], text))
                text = lower(text);
            end
            % Assigning the property fires PostSet, which redraws and
            % revalidates, so a bad value is shown back and flagged
            app.advancedSettingValues(index) = text;
        end

        % Selection changed function: CostTermsListTable
        function CostTermsListTableSelectionChanged(app, event)
            selection = app.CostTermsListTable.Selection;
            if isempty(selection)
                return
            end
            if selection == height(app.CostTermsListTable.Data)
                app.createCostTerm(); % last row adds a new cost term
            else
                app.costTermIndex = selection;
                app.showSelectedCostTerm();
            end
        end

        % Cell edit callback: CostTermsListTable
        function CostTermsListTableCellEdit(app, event)
            rowIndex = event.Indices(1);
            if rowIndex > numel(app.costTerms)
                app.updateCostTermsTable(); % restore the add row
                return
            end
            app.costTermIndex = rowIndex;
            if event.Indices(2) == 1
                app.costTerms{rowIndex}.is_enabled = ...
                    boolToString(event.NewData);
            else
                app.costTerms{rowIndex}.name = string(event.NewData);
            end
            app.updateCostTermsTable();
            app.updateTabControls();
        end

        % Value changed function: CostTermTypeDropDown
        function CostTermTypeDropDownValueChanged(app, event)
            costTerm = app.selectedCostTerm();
            if isempty(costTerm)
                return
            end
            app.applyCostTermType(costTerm, ...
                string(app.CostTermTypeDropDown.Value));
            app.showSelectedCostTerm();
            app.validateCostTerms();
            app.updateTabControls();
        end

        % Button pushed function: CostTermComponentListEditButton
        function CostTermComponentListEditButtonPushed(app, event)
            costTerm = app.selectedCostTerm();
            if isempty(costTerm)
                return
            end
            app.objectSelectionType = 'costTermComponent';
            ObjectSelectionWindow(app, app.termComponentSource( ...
                costTerm.componentElement), costTerm.componentList)
        end

        % Value changed function: MaxAllowableErrorEditField
        function MaxAllowableErrorEditFieldValueChanged(app, event)
            costTerm = app.selectedCostTerm();
            if isempty(costTerm)
                return
            end
            costTerm.max_allowable_error = ...
                app.MaxAllowableErrorEditField.Value;
            app.validateCostTerms();
            app.updateTabControls();
        end

        % Value changed function: ErrorCenterEditField
        function ErrorCenterEditFieldValueChanged(app, event)
            costTerm = app.selectedCostTerm();
            if isempty(costTerm)
                return
            end
            costTerm.error_center = app.ErrorCenterEditField.Value;
        end

        % Cell edit callback: MiscellaneousCostTermParametersTable
        function MiscellaneousCostTermParametersTableCellEdit(app, event)
            costTerm = app.selectedCostTerm();
            if isempty(costTerm)
                return
            end
            problem = app.applyMiscParameterEdit(costTerm, event, ...
                app.costTermTypeParams(costTerm), ...
                app.costTermReservedNames(costTerm));
            % Re-rendering is what draws the add row below a new parameter
            % and snaps a refused edit back to the stored name
            app.refreshMiscCostParameterTable();
            if ~strcmp(problem, "")
                app.reportMiscParameterProblem(problem);
            end
            app.validateCostTerms();
            app.updateTabControls();
        end

        % Menu selected function: RenameMenu
        function RenameMenuSelected(app, event)
            costTerm = app.selectedCostTerm();
            if isempty(costTerm)
                return
            end
            newName = inputdlg("Rename cost term:", "Rename", [1 40], ...
                {char(costTerm.name)});
            if isempty(newName)
                return
            end
            costTerm.name = string(newName{1});
            app.updateCostTermsTable();
        end

        % Menu selected function: CopyMenu
        function CopyMenuSelected(app, event)
            costTerm = app.selectedCostTerm();
            if isempty(costTerm)
                return
            end
            source = costTerm.toStruct();
            componentElement = costTerm.componentElement;
            app.createCostTerm();
            copied = app.costTerms{app.costTermIndex};
            copied.loadFromStruct(source, componentElement);
            % toStruct omits a parameter with no value, so refill the
            % type's own parameters the way a loaded term is refilled
            copied.miscParams = app.mergeMiscParams( ...
                app.costTermTypeParams(copied), copied.miscParams);
            copied.name = "Copy of " + costTerm.name;
            copied.index = app.costTermIndex;
            app.updateCostTermsTable();
            app.showSelectedCostTerm();
        end

        % Context menu opening function: MiscCostParameterContextMenu
        function MiscCostParameterContextMenuOpening(app, event)
            costTerm = app.selectedCostTerm();
            on = app.isEditableMiscRow(costTerm, ...
                app.costTermTypeParams(costTerm), app.selectedMiscRow( ...
                app.MiscellaneousCostTermParametersTable));
            app.MiscCostParameterRenameMenu.Enable = on;
            app.MiscCostParameterDeleteMenu.Enable = on;
        end

        % Menu selected function: MiscCostParameterRenameMenu
        function MiscCostParameterRenameMenuSelected(app, event)
            costTerm = app.selectedCostTerm();
            row = app.selectedMiscRow( ...
                app.MiscellaneousCostTermParametersTable);
            % The selection can change between the menu opening and this,
            % so the guard is repeated rather than trusted from Enable
            if ~app.isEditableMiscRow(costTerm, ...
                    app.costTermTypeParams(costTerm), row)
                return
            end
            params = string(fieldnames(costTerm.miscParams));
            answer = inputdlg("Rename parameter:", "Rename", [1 40], ...
                {char(params(row))});
            if isempty(answer)
                return
            end
            newName = strtrim(string(answer{1}));
            if strcmp(newName, params(row))
                return
            end
            problem = app.miscParameterNameProblem(newName, params, ...
                app.costTermReservedNames(costTerm));
            if ~strcmp(problem, "")
                app.reportMiscParameterProblem(problem);
                return
            end
            costTerm.miscParams = app.renamedStructField( ...
                costTerm.miscParams, params(row), newName);
            app.refreshMiscCostParameterTable();
            app.validateCostTerms();
            app.updateTabControls();
        end

        % Menu selected function: MiscCostParameterDeleteMenu
        function MiscCostParameterDeleteMenuSelected(app, event)
            costTerm = app.selectedCostTerm();
            row = app.selectedMiscRow( ...
                app.MiscellaneousCostTermParametersTable);
            if ~app.isEditableMiscRow(costTerm, ...
                    app.costTermTypeParams(costTerm), row)
                return
            end
            params = string(fieldnames(costTerm.miscParams));
            costTerm.miscParams = rmfield(costTerm.miscParams, ...
                params(row));
            app.refreshMiscCostParameterTable();
            app.validateCostTerms();
            app.updateTabControls();
        end

        % Menu selected function: DeleteMenu
        function DeleteMenuSelected(app, event)
            app.deleteCostTerm(app.CostTermsListTable.Selection);
        end

        % Selection changed function: ConstraintTermsListTable
        function ConstraintTermsListTableSelectionChanged(app, event)
            selection = app.ConstraintTermsListTable.Selection;
            if isempty(selection)
                return
            end
            if selection == height(app.ConstraintTermsListTable.Data)
                app.createConstraintTerm(); % last row adds a new term
            else
                app.constraintTermIndex = selection;
                app.showSelectedConstraintTerm();
            end
        end

        % Cell edit callback: ConstraintTermsListTable
        function ConstraintTermsListTableCellEdit(app, event)
            rowIndex = event.Indices(1);
            if rowIndex > numel(app.constraintTerms)
                app.updateConstraintTermsTable(); % restore the add row
                return
            end
            app.constraintTermIndex = rowIndex;
            if event.Indices(2) == 1
                app.constraintTerms{rowIndex}.is_enabled = ...
                    boolToString(event.NewData);
            else
                app.constraintTerms{rowIndex}.name = string(event.NewData);
            end
            app.updateConstraintTermsTable();
            app.updateTabControls();
        end

        % Value changed function: ConstraintTermTypeDropDown
        function ConstraintTermTypeDropDownValueChanged(app, event)
            constraintTerm = app.selectedConstraintTerm();
            if isempty(constraintTerm)
                return
            end
            app.applyConstraintTermType(constraintTerm, ...
                string(app.ConstraintTermTypeDropDown.Value));
            app.showSelectedConstraintTerm();
            app.validateConstraintTerms();
            app.updateTabControls();
        end

        % Button pushed function: ConstraintTermComponentListEditButton
        function ConstraintTermComponentListEditButtonPushed(app, event)
            constraintTerm = app.selectedConstraintTerm();
            if isempty(constraintTerm)
                return
            end
            app.objectSelectionType = 'constraintTermComponent';
            ObjectSelectionWindow(app, app.termComponentSource( ...
                constraintTerm.componentElement), ...
                constraintTerm.componentList)
        end

        % Value changed function: MaxErrorField
        function MaxErrorFieldValueChanged(app, event)
            constraintTerm = app.selectedConstraintTerm();
            if isempty(constraintTerm)
                return
            end
            constraintTerm.max_error = app.MaxErrorField.Value;
            app.validateConstraintTerms();
            app.updateTabControls();
        end

        % Value changed function: MinErrorEditField
        function MinErrorEditFieldValueChanged(app, event)
            constraintTerm = app.selectedConstraintTerm();
            if isempty(constraintTerm)
                return
            end
            constraintTerm.min_error = app.MinErrorEditField.Value;
            app.validateConstraintTerms();
            app.updateTabControls();
        end

        % Cell edit callback: MiscellaneousConstraintTermParametersTable
        function MiscellaneousConstraintTermParametersTableCellEdit(app, ...
                event)
            constraintTerm = app.selectedConstraintTerm();
            if isempty(constraintTerm)
                return
            end
            problem = app.applyMiscParameterEdit(constraintTerm, event, ...
                app.constraintTermTypeParams(constraintTerm), ...
                app.constraintTermReservedNames(constraintTerm));
            % Re-rendering is what draws the add row below a new parameter
            % and snaps a refused edit back to the stored name
            app.refreshMiscConstraintParameterTable();
            if ~strcmp(problem, "")
                app.reportMiscParameterProblem(problem);
            end
            app.validateConstraintTerms();
            app.updateTabControls();
        end

        % Menu selected function: ConstraintTermRenameMenu
        function ConstraintTermRenameMenuSelected(app, event)
            constraintTerm = app.selectedConstraintTerm();
            if isempty(constraintTerm)
                return
            end
            newName = inputdlg("Rename constraint term:", "Rename", ...
                [1 40], {char(constraintTerm.name)});
            if isempty(newName)
                return
            end
            constraintTerm.name = string(newName{1});
            app.updateConstraintTermsTable();
        end

        % Menu selected function: ConstraintTermCopyMenu
        function ConstraintTermCopyMenuSelected(app, event)
            constraintTerm = app.selectedConstraintTerm();
            if isempty(constraintTerm)
                return
            end
            source = constraintTerm.toStruct();
            componentElement = constraintTerm.componentElement;
            app.createConstraintTerm();
            copied = app.constraintTerms{app.constraintTermIndex};
            copied.loadFromStruct(source, componentElement);
            % toStruct omits a parameter with no value, so refill the
            % type's own parameters the way a loaded term is refilled
            copied.miscParams = app.mergeMiscParams( ...
                app.constraintTermTypeParams(copied), copied.miscParams);
            copied.name = "Copy of " + constraintTerm.name;
            copied.index = app.constraintTermIndex;
            app.updateConstraintTermsTable();
            app.showSelectedConstraintTerm();
        end

        % Context menu opening function: MiscConstraintParameterContextMenu
        function MiscConstraintParameterContextMenuOpening(app, event)
            constraintTerm = app.selectedConstraintTerm();
            on = app.isEditableMiscRow(constraintTerm, ...
                app.constraintTermTypeParams(constraintTerm), ...
                app.selectedMiscRow( ...
                app.MiscellaneousConstraintTermParametersTable));
            app.MiscConstraintParameterRenameMenu.Enable = on;
            app.MiscConstraintParameterDeleteMenu.Enable = on;
        end

        % Menu selected function: MiscConstraintParameterRenameMenu
        function MiscConstraintParameterRenameMenuSelected(app, event)
            constraintTerm = app.selectedConstraintTerm();
            row = app.selectedMiscRow( ...
                app.MiscellaneousConstraintTermParametersTable);
            % The selection can change between the menu opening and this,
            % so the guard is repeated rather than trusted from Enable
            if ~app.isEditableMiscRow(constraintTerm, ...
                    app.constraintTermTypeParams(constraintTerm), row)
                return
            end
            params = string(fieldnames(constraintTerm.miscParams));
            answer = inputdlg("Rename parameter:", "Rename", [1 40], ...
                {char(params(row))});
            if isempty(answer)
                return
            end
            newName = strtrim(string(answer{1}));
            if strcmp(newName, params(row))
                return
            end
            problem = app.miscParameterNameProblem(newName, params, ...
                app.constraintTermReservedNames(constraintTerm));
            if ~strcmp(problem, "")
                app.reportMiscParameterProblem(problem);
                return
            end
            constraintTerm.miscParams = app.renamedStructField( ...
                constraintTerm.miscParams, params(row), newName);
            app.refreshMiscConstraintParameterTable();
            app.validateConstraintTerms();
            app.updateTabControls();
        end

        % Menu selected function: MiscConstraintParameterDeleteMenu
        function MiscConstraintParameterDeleteMenuSelected(app, event)
            constraintTerm = app.selectedConstraintTerm();
            row = app.selectedMiscRow( ...
                app.MiscellaneousConstraintTermParametersTable);
            if ~app.isEditableMiscRow(constraintTerm, ...
                    app.constraintTermTypeParams(constraintTerm), row)
                return
            end
            params = string(fieldnames(constraintTerm.miscParams));
            constraintTerm.miscParams = rmfield( ...
                constraintTerm.miscParams, params(row));
            app.refreshMiscConstraintParameterTable();
            app.validateConstraintTerms();
            app.updateTabControls();
        end

        % Menu selected function: ConstraintTermDeleteMenu
        function ConstraintTermDeleteMenuSelected(app, event)
            app.deleteConstraintTerm( ...
                app.ConstraintTermsListTable.Selection);
        end

        % Value changed function: SolverSettingsFileEditField
        function SolverSettingsFileEditFieldValueChanged(app, event)
            app.solver_settings_file = ...
                getPathFieldValue(app.SolverSettingsFileEditField);
        end

        % Button pushed function: SolverSettingsFileSearchButton
        function SolverSettingsFileSearchButtonPushed(app, event)
            [file, path] = uigetfile('*.xml', ...
                "Select a Solver Settings File");
            % User hit "Cancel"
            if isequal(file, 0)
                return
            end
            app.solver_settings_file = fullfile(path, file);
        end

        % Value changed function: SolverSelectionDropDown
        function SolverSelectionDropDownValueChanged(app, event)
            app.solver_type = string(app.SolverSelectionDropDown.Value);
            app.applySolverType();
            app.validateSolverSettings();
            app.updateTabControls();
        end

        % Cell edit callback: SolverSettingsTable
        function SolverSettingsTableCellEdit(app, event)
            rowIndex = event.Indices(1);
            if rowIndex > numel(app.gpopsSettingValues)
                return
            end
            values = app.gpopsSettingValues;
            values(rowIndex) = string(event.NewData);
            app.gpopsSettingValues = values;
            app.updateTabControls();
        end

        % Button pushed function: MakeDefaultSettingsFileButton
        function MakeDefaultSettingsFileButtonPushed(app, event)
            [file, path] = uiputfile('*.xml', ...
                "Save Solver Settings File");
            % User hit "Cancel"
            if isequal(file, 0)
                return
            end
            fileName = fullfile(path, file);
            saveGuiSettings(fileName, "OptimalControlSolverSettings", ...
                app.gpopsSettingsTree());
            % Point the field at what was just written so the two agree
            app.solver_settings_file = fileName;
        end

        function resetAllFields(app)
            app.input_model_file = "";
            app.input_osimx_file = "";
            app.tracked_quantities_directory = "";
            app.initial_guess_directory = "";
            app.results_directory = "";
            app.coordinate_list = string([]);
            app.trial_prefix = "";
            app.selected_tool = "Tracking Optimization";

            app.model_markers = string([]);
            app.model_joints = string([]);
            app.model_bodies = string([]);
            app.model_coordinates = string([]);
            app.model_groups = string([]);
            app.model_muscles = string([]);

            app.tracked_coordinate_labels = string([]);
            app.tracked_load_labels = string([]);
            app.tracked_emg_labels = string([]);
            app.tracked_grf_labels = string([]);
            app.tracked_moment_arm_coordinates = string([]);
            app.tracked_moment_arm_muscles = string([]);
            app.tracked_trial_names = string([]);
            app.osimx_synergy_groups = {};

            app.costTerms = cell(0);
            app.costTermIndex = 1;
            app.updateCostTermsTable();
            app.showSelectedCostTerm();

            app.constraintTerms = cell(0);
            app.constraintTermIndex = 1;
            app.updateConstraintTermsTable();
            app.showSelectedConstraintTerm();

            app.TorqueController.reset();
            app.SynergyController.reset();
            app.MuscleController.reset();
            app.MuscleModel.reset();
            app.updateTorqueAdvancedSettingsTable();
            app.updateSynergyAdvancedSettingsTable();
            app.updateMuscleAdvancedSettingsTable();
            app.updateSurrogateModelAdvancedSettingsTable();

            app.objectSelectionType = "";
            app.currentSettingsFile = "";

            app.advancedSettingValues = app.defaultAdvancedSettingValues;

            app.solver_settings_file = "";
            app.SolverSettingsFileEditField.Value = '';
            app.solver_type = "GPOPS-II";
            app.SolverSelectionDropDown.Value = 'GPOPS-II';
            app.applySolverType();
            app.gpopsSettingValues = app.defaultGpopsSettingValues;
            setGuiFieldStatus(app.SolverSettingsFileEditField, ...
                app.SolverSettingsFileStatus, "none");

            app.validateAllFields();
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
            app.UIFigure.Position = [500 500 1149 961];
            app.UIFigure.Name = 'MATLAB App';

            % Create TreatmentOptimizationLabel
            app.TreatmentOptimizationLabel = uilabel(app.UIFigure);
            app.TreatmentOptimizationLabel.HorizontalAlignment = 'center';
            app.TreatmentOptimizationLabel.FontSize = 25;
            app.TreatmentOptimizationLabel.FontWeight = 'bold';
            app.TreatmentOptimizationLabel.Position = [1 922 978 40];
            app.TreatmentOptimizationLabel.Text = 'Treatment Optimization';

            % Create TabGroup
            app.TabGroup = uitabgroup(app.UIFigure);
            app.TabGroup.Position = [211 73 939 843];

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
            app.InputModelFileSearchButton.Position = [750 700 31 30];
            app.InputModelFileSearchButton.Text = '';

            % Create InputModelFileEditFieldLabel
            app.InputModelFileEditFieldLabel = uilabel(app.InputsTab);
            app.InputModelFileEditFieldLabel.HorizontalAlignment = 'right';
            app.InputModelFileEditFieldLabel.FontSize = 18;
            app.InputModelFileEditFieldLabel.FontWeight = 'bold';
            app.InputModelFileEditFieldLabel.Position = [68 700 140 30];
            app.InputModelFileEditFieldLabel.Text = 'Input Model File';

            % Create InputModelFileEditField
            app.InputModelFileEditField = uieditfield(app.InputsTab, 'text');
            app.InputModelFileEditField.FontSize = 16;
            app.InputModelFileEditField.ValueChangedFcn = createCallbackFcn(app, @InputModelFileEditFieldValueChanged, true);
            app.InputModelFileEditField.Position = [219 700 521 30];

            % Create InputModelFileStatus
            app.InputModelFileStatus = uiimage(app.InputsTab);
            app.InputModelFileStatus.Visible = 'off';
            app.InputModelFileStatus.Position = [791 700 28 30];
            app.InputModelFileStatus.ImageSource = fullfile(pathToMLAPP, '..', 'Images', 'error.png');

            % Create InputOsimxFileSearchButton
            app.InputOsimxFileSearchButton = uibutton(app.InputsTab, 'push');
            app.InputOsimxFileSearchButton.ButtonPushedFcn = createCallbackFcn(app, @InputOsimxFileSearchButtonPushed, true);
            app.InputOsimxFileSearchButton.Icon = fullfile(pathToMLAPP, '..', 'Images', 'folderIcon.svg');
            app.InputOsimxFileSearchButton.VerticalAlignment = 'bottom';
            app.InputOsimxFileSearchButton.BackgroundColor = [0.1294 0.1804 0.4];
            app.InputOsimxFileSearchButton.Position = [750 651 31 30];
            app.InputOsimxFileSearchButton.Text = '';

            % Create InputOsimxFileEditFieldLabel
            app.InputOsimxFileEditFieldLabel = uilabel(app.InputsTab);
            app.InputOsimxFileEditFieldLabel.HorizontalAlignment = 'right';
            app.InputOsimxFileEditFieldLabel.FontSize = 18;
            app.InputOsimxFileEditFieldLabel.FontWeight = 'bold';
            app.InputOsimxFileEditFieldLabel.Position = [63 651 145 30];
            app.InputOsimxFileEditFieldLabel.Text = 'Input Osimx File';

            % Create InputOsimxFileEditField
            app.InputOsimxFileEditField = uieditfield(app.InputsTab, 'text');
            app.InputOsimxFileEditField.FontSize = 16;
            app.InputOsimxFileEditField.ValueChangedFcn = createCallbackFcn(app, @InputOsimxFileEditFieldValueChanged, true);
            app.InputOsimxFileEditField.Position = [219 651 521 30];

            % Create InputOsimxFileStatus
            app.InputOsimxFileStatus = uiimage(app.InputsTab);
            app.InputOsimxFileStatus.Visible = 'off';
            app.InputOsimxFileStatus.Position = [791 651 28 30];
            app.InputOsimxFileStatus.ImageSource = fullfile(pathToMLAPP, '..', 'Images', 'error.png');

            % Create TrackedQuantitiesSearchButton
            app.TrackedQuantitiesSearchButton = uibutton(app.InputsTab, 'push');
            app.TrackedQuantitiesSearchButton.ButtonPushedFcn = createCallbackFcn(app, @TrackedQuantitiesSearchButtonPushed, true);
            app.TrackedQuantitiesSearchButton.Icon = fullfile(pathToMLAPP, '..', 'Images', 'folderIcon.svg');
            app.TrackedQuantitiesSearchButton.VerticalAlignment = 'bottom';
            app.TrackedQuantitiesSearchButton.BackgroundColor = [0.1294 0.1804 0.4];
            app.TrackedQuantitiesSearchButton.Position = [750 601 31 30];
            app.TrackedQuantitiesSearchButton.Text = '';

            % Create InputDataEditField
            app.TrackedQuantitiesDirectoryEditField = uieditfield(app.InputsTab, 'text');
            app.TrackedQuantitiesDirectoryEditField.FontSize = 16;
            app.TrackedQuantitiesDirectoryEditField.ValueChangedFcn = createCallbackFcn(app, @InputDataEditFieldValueChanged, true);
            app.TrackedQuantitiesDirectoryEditField.Position = [219 601 521 30];

            % Create InputDataStatus
            app.TrackedQuantitiesDirectoryStatus = uiimage(app.InputsTab);
            app.TrackedQuantitiesDirectoryStatus.Visible = 'off';
            app.TrackedQuantitiesDirectoryStatus.Position = [791 601 28 30];
            app.TrackedQuantitiesDirectoryStatus.ImageSource = fullfile(pathToMLAPP, '..', 'Images', 'error.png');

            % Create TrackedQuantitiesDirectoryLabel
            app.TrackedQuantitiesDirectoryLabel = uilabel(app.InputsTab);
            app.TrackedQuantitiesDirectoryLabel.HorizontalAlignment = 'right';
            app.TrackedQuantitiesDirectoryLabel.FontSize = 18;
            app.TrackedQuantitiesDirectoryLabel.FontWeight = 'bold';
            app.TrackedQuantitiesDirectoryLabel.Position = [38 594 168 44];
            app.TrackedQuantitiesDirectoryLabel.Text = {'Tracked Quantities'; 'Directory'};

            % Create StatesCoordinatesListTextArea
            app.StatesCoordinatesListTextArea = uitextarea(app.InputsTab);
            app.StatesCoordinatesListTextArea.Editable = 'off';
            app.StatesCoordinatesListTextArea.FontSize = 18;
            app.StatesCoordinatesListTextArea.Position = [219 25 521 410];

            % Create StatesCoordinatesListTextAreaLabel
            app.StatesCoordinatesListTextAreaLabel = uilabel(app.InputsTab);
            app.StatesCoordinatesListTextAreaLabel.HorizontalAlignment = 'right';
            app.StatesCoordinatesListTextAreaLabel.FontSize = 18;
            app.StatesCoordinatesListTextAreaLabel.FontWeight = 'bold';
            app.StatesCoordinatesListTextAreaLabel.Position = [2 225 207 23];
            app.StatesCoordinatesListTextAreaLabel.Text = 'States Coordinates List';

            % Create CoordinateListStatus
            app.CoordinateListStatus = uiimage(app.InputsTab);
            app.CoordinateListStatus.Visible = 'off';
            app.CoordinateListStatus.Position = [851 225 28 30];
            app.CoordinateListStatus.ImageSource = fullfile(pathToMLAPP, '..', 'Images', 'error.png');

            % Create CoordinateListEditButton
            app.CoordinateListEditButton = uibutton(app.InputsTab, 'push');
            app.CoordinateListEditButton.ButtonPushedFcn = createCallbackFcn(app, @CoordinateListEditButtonPushed, true);
            app.CoordinateListEditButton.BackgroundColor = [0.1294 0.1804 0.4];
            app.CoordinateListEditButton.FontSize = 18;
            app.CoordinateListEditButton.FontColor = [1 1 1];
            app.CoordinateListEditButton.Position = [750 225 91 30];
            app.CoordinateListEditButton.Text = 'Edit';

            % Create TrialPrefixEditFieldLabel
            app.TrialPrefixEditFieldLabel = uilabel(app.InputsTab);
            app.TrialPrefixEditFieldLabel.HorizontalAlignment = 'right';
            app.TrialPrefixEditFieldLabel.FontSize = 18;
            app.TrialPrefixEditFieldLabel.FontWeight = 'bold';
            app.TrialPrefixEditFieldLabel.Position = [110 507 97 23];
            app.TrialPrefixEditFieldLabel.Text = 'Trial Prefix';

            % Create TrialPrefixEditField
            app.TrialPrefixEditField = uieditfield(app.InputsTab, 'text');
            app.TrialPrefixEditField.ValueChangedFcn = createCallbackFcn(app, @TrialPrefixEditFieldValueChanged, true);
            app.TrialPrefixEditField.FontSize = 18;
            app.TrialPrefixEditField.Position = [219 503 521 30];

            % Create TaskPrefixesStatus
            app.TaskPrefixesStatus = uiimage(app.InputsTab);
            app.TaskPrefixesStatus.Visible = 'off';
            app.TaskPrefixesStatus.Position = [791 503 28 30];
            app.TaskPrefixesStatus.ImageSource = fullfile(pathToMLAPP, '..', 'Images', 'error.png');

            % Create ResultsDirectoryEditFieldLabel
            app.ResultsDirectoryEditFieldLabel = uilabel(app.InputsTab);
            app.ResultsDirectoryEditFieldLabel.HorizontalAlignment = 'right';
            app.ResultsDirectoryEditFieldLabel.FontSize = 18;
            app.ResultsDirectoryEditFieldLabel.FontWeight = 'bold';
            app.ResultsDirectoryEditFieldLabel.Position = [40 454 168 30];
            app.ResultsDirectoryEditFieldLabel.Text = 'Results Directory';

            % Create ResultsDirectoryEditField
            app.ResultsDirectoryEditField = uieditfield(app.InputsTab, 'text');
            app.ResultsDirectoryEditField.ValueChangedFcn = createCallbackFcn(app, @ResultsDirectoryEditFieldValueChanged, true);
            app.ResultsDirectoryEditField.FontSize = 16;
            app.ResultsDirectoryEditField.Position = [219 454 521 30];

            % Create ResultsDirectorySearchButton
            app.ResultsDirectorySearchButton = uibutton(app.InputsTab, 'push');
            app.ResultsDirectorySearchButton.ButtonPushedFcn = createCallbackFcn(app, @ResultsDirectorySearchButtonPushed, true);
            app.ResultsDirectorySearchButton.Icon = fullfile(pathToMLAPP, '..', 'Images', 'folderIcon.svg');
            app.ResultsDirectorySearchButton.VerticalAlignment = 'bottom';
            app.ResultsDirectorySearchButton.BackgroundColor = [0.1294 0.1804 0.4];
            app.ResultsDirectorySearchButton.Position = [750 454 31 30];
            app.ResultsDirectorySearchButton.Text = '';

            % Create ResultsDirectoryStatus
            app.ResultsDirectoryStatus = uiimage(app.InputsTab);
            app.ResultsDirectoryStatus.Visible = 'off';
            app.ResultsDirectoryStatus.Position = [791 454 28 30];
            app.ResultsDirectoryStatus.ImageSource = fullfile(pathToMLAPP, '..', 'Images', 'error.png');

            % Create MTPResultsDirStatus
            app.InitialGuessDirectoryStatus = uiimage(app.InputsTab);
            app.InitialGuessDirectoryStatus.Visible = 'off';
            app.InitialGuessDirectoryStatus.Position = [791 552 28 30];
            app.InitialGuessDirectoryStatus.ImageSource = fullfile(pathToMLAPP, '..', 'Images', 'error.png');

            % Create InitialGuessSearchButton
            app.InitialGuessDirectorySearchButton = uibutton(app.InputsTab, 'push');
            app.InitialGuessDirectorySearchButton.ButtonPushedFcn = createCallbackFcn(app, @InitialGuessSearchButtonPushed, true);
            app.InitialGuessDirectorySearchButton.Icon = fullfile(pathToMLAPP, '..', 'Images', 'folderIcon.svg');
            app.InitialGuessDirectorySearchButton.VerticalAlignment = 'bottom';
            app.InitialGuessDirectorySearchButton.BackgroundColor = [0.1294 0.1804 0.4];
            app.InitialGuessDirectorySearchButton.Position = [750 552 31 30];
            app.InitialGuessDirectorySearchButton.Text = '';

            % Create MTPResultsDirEditField
            app.InitialGuessDirectoryEditField = uieditfield(app.InputsTab, 'text');
            app.InitialGuessDirectoryEditField.FontSize = 16;
            app.InitialGuessDirectoryEditField.ValueChangedFcn = createCallbackFcn(app, @MTPResultsDirEditFieldValueChanged, true);
            app.InitialGuessDirectoryEditField.Position = [219 552 521 30];

            % Create MTPResultsDirectoryLabel
            app.InitialGuessDirectoryLabel = uilabel(app.InputsTab);
            app.InitialGuessDirectoryLabel.HorizontalAlignment = 'right';
            app.InitialGuessDirectoryLabel.FontSize = 18;
            app.InitialGuessDirectoryLabel.FontWeight = 'bold';
            app.InitialGuessDirectoryLabel.Position = [11 552 198 30];
            app.InitialGuessDirectoryLabel.Text = 'Initial Guess Directory';

            % Create ToolSelectionDropDownLabel
            app.ToolSelectionDropDownLabel = uilabel(app.InputsTab);
            app.ToolSelectionDropDownLabel.HorizontalAlignment = 'right';
            app.ToolSelectionDropDownLabel.FontSize = 24;
            app.ToolSelectionDropDownLabel.FontWeight = 'bold';
            app.ToolSelectionDropDownLabel.Position = [41 761 167 32];
            app.ToolSelectionDropDownLabel.Text = 'Tool Selection';

            % Create ToolSelectionDropDown
            app.ToolSelectionDropDown = uidropdown(app.InputsTab);
            app.ToolSelectionDropDown.Items = {'Tracking Optimization', 'Verification Optimization', 'Design Optimization'};
            app.ToolSelectionDropDown.ValueChangedFcn = createCallbackFcn(app, @ToolSelectionDropDownValueChanged, true);
            app.ToolSelectionDropDown.FontSize = 20;
            app.ToolSelectionDropDown.FontWeight = 'bold';
            app.ToolSelectionDropDown.Position = [219 758 521 36];
            app.ToolSelectionDropDown.Value = 'Tracking Optimization';

            % Create ControllersTab
            app.ControllersTab = uitab(app.TabGroup);
            app.ControllersTab.BackgroundColor = [0.851 0.851 0.851];

            % Create ControllersTabGroup
            app.ControllersTabGroup = uitabgroup(app.ControllersTab);
            app.ControllersTabGroup.Position = [0 1 939 818];

            % Create TorqueTab
            app.TorqueTab = uitab(app.ControllersTabGroup);
            app.TorqueTab.Title = 'Tab';
            app.TorqueTab.BackgroundColor = [0.851 0.851 0.851];

            % Create UseRCNLTorqueControllerCheckBox
            app.UseRCNLTorqueControllerCheckBox = uicheckbox(app.TorqueTab);
            app.UseRCNLTorqueControllerCheckBox.ValueChangedFcn = createCallbackFcn(app, @UseRCNLTorqueControllerCheckBoxValueChanged, true);
            app.UseRCNLTorqueControllerCheckBox.Text = 'Use RCNL Torque Controller';
            app.UseRCNLTorqueControllerCheckBox.FontSize = 18;
            app.UseRCNLTorqueControllerCheckBox.FontWeight = 'bold';
            app.UseRCNLTorqueControllerCheckBox.Position = [321 739 268 22];

            % Create TorqueControllerCoordinateEditButton
            app.TorqueControllerCoordinateEditButton = uibutton(app.TorqueTab, 'push');
            app.TorqueControllerCoordinateEditButton.ButtonPushedFcn = createCallbackFcn(app, @TorqueControllerCoordinateEditButtonPushed, true);
            app.TorqueControllerCoordinateEditButton.BackgroundColor = [0.1294 0.1804 0.4];
            app.TorqueControllerCoordinateEditButton.FontSize = 18;
            app.TorqueControllerCoordinateEditButton.FontColor = [1 1 1];
            app.TorqueControllerCoordinateEditButton.Position = [621 621 91 30];
            app.TorqueControllerCoordinateEditButton.Text = 'Edit';

            % Create TorqueControllerCoordianteListStatus
            app.TorqueControllerCoordianteListStatus = uiimage(app.TorqueTab);
            app.TorqueControllerCoordianteListStatus.Visible = 'off';
            app.TorqueControllerCoordianteListStatus.Position = [728 621 28 30];
            app.TorqueControllerCoordianteListStatus.ImageSource = fullfile(pathToMLAPP, '..', 'Images', 'error.png');

            % Create TorqueControllerCoordinateList
            app.TorqueControllerCoordinateList = uitextarea(app.TorqueTab);
            app.TorqueControllerCoordinateList.Editable = 'off';
            app.TorqueControllerCoordinateList.FontSize = 18;
            app.TorqueControllerCoordinateList.Position = [159 557 447 160];

            % Create CoordinatesListTextAreaLabel
            app.CoordinatesListTextAreaLabel = uilabel(app.TorqueTab);
            app.CoordinatesListTextAreaLabel.HorizontalAlignment = 'right';
            app.CoordinatesListTextAreaLabel.FontSize = 18;
            app.CoordinatesListTextAreaLabel.FontWeight = 'bold';
            app.CoordinatesListTextAreaLabel.Position = [2 626 147 23];
            app.CoordinatesListTextAreaLabel.Text = 'Coordinates List';

            % Create TorqueAdvancedSettingsTable
            app.TorqueAdvancedSettingsTable = uitable(app.TorqueTab);
            app.TorqueAdvancedSettingsTable.ColumnName = {'Parameter'; 'Value'};
            app.TorqueAdvancedSettingsTable.RowName = {};
            app.TorqueAdvancedSettingsTable.SelectionType = 'row';
            app.TorqueAdvancedSettingsTable.ColumnEditable = [false true];
            app.TorqueAdvancedSettingsTable.ColumnWidth = {'auto', 100};
            app.TorqueAdvancedSettingsTable.CellEditCallback = createCallbackFcn(app, @TorqueAdvancedSettingsTableCellEdit, true);
            app.TorqueAdvancedSettingsTable.FontSize = 15;
            app.TorqueAdvancedSettingsTable.Position = [160 278 526 208];

            % Create TorqueControllerAdvancedSettings
            app.TorqueControllerAdvancedSettings = uilabel(app.TorqueTab);
            app.TorqueControllerAdvancedSettings.HorizontalAlignment = 'right';
            app.TorqueControllerAdvancedSettings.FontSize = 18;
            app.TorqueControllerAdvancedSettings.FontWeight = 'bold';
            app.TorqueControllerAdvancedSettings.Position = [58 360 91 44];
            app.TorqueControllerAdvancedSettings.Text = {'Advanced'; 'Settings'};

            % Create TorqueControllerAdvancedSettingsStatus
            app.TorqueControllerAdvancedSettingsStatus = uiimage(app.TorqueTab);
            app.TorqueControllerAdvancedSettingsStatus.Visible = 'off';
            app.TorqueControllerAdvancedSettingsStatus.Position = [727 370 28 30];
            app.TorqueControllerAdvancedSettingsStatus.ImageSource = fullfile(pathToMLAPP, '..', 'Images', 'error.png');

            % Create SynergyTab
            app.SynergyTab = uitab(app.ControllersTabGroup);
            app.SynergyTab.Title = 'Tab2';
            app.SynergyTab.BackgroundColor = [0.851 0.851 0.851];

            % Create UseRCNLSynergyControllerCheckBox
            app.UseRCNLSynergyControllerCheckBox = uicheckbox(app.SynergyTab);
            app.UseRCNLSynergyControllerCheckBox.ValueChangedFcn = createCallbackFcn(app, @UseRCNLSynergyControllerCheckBoxValueChanged, true);
            app.UseRCNLSynergyControllerCheckBox.Text = 'Use RCNL Synergy Controller';
            app.UseRCNLSynergyControllerCheckBox.FontSize = 18;
            app.UseRCNLSynergyControllerCheckBox.FontWeight = 'bold';
            app.UseRCNLSynergyControllerCheckBox.Position = [24 757 280 22];

            % Create SynergyControllerStatus
            app.SynergyControllerStatus = uiimage(app.SynergyTab);
            app.SynergyControllerStatus.Visible = 'off';
            app.SynergyControllerStatus.Position = [312 753 28 30];
            app.SynergyControllerStatus.ImageSource = fullfile(pathToMLAPP, '..', 'Images', 'error.png');

            % Create SurrogateModelCoordinatesListEditButton
            app.SurrogateModelCoordinatesListEditButton = uibutton(app.SynergyTab, 'push');
            app.SurrogateModelCoordinatesListEditButton.ButtonPushedFcn = createCallbackFcn(app, @SurrogateModelCoordinatesListEditButtonPushed, true);
            app.SurrogateModelCoordinatesListEditButton.BackgroundColor = [0.1294 0.1804 0.4];
            app.SurrogateModelCoordinatesListEditButton.FontSize = 18;
            app.SurrogateModelCoordinatesListEditButton.FontColor = [1 1 1];
            app.SurrogateModelCoordinatesListEditButton.Position = [725 392 91 30];
            app.SurrogateModelCoordinatesListEditButton.Text = 'Edit';

            % Create SurrogateModelCoordinatesListStatus
            app.SurrogateModelCoordinatesListStatus = uiimage(app.SynergyTab);
            app.SurrogateModelCoordinatesListStatus.Visible = 'off';
            app.SurrogateModelCoordinatesListStatus.Position = [821 392 28 30];
            app.SurrogateModelCoordinatesListStatus.ImageSource = fullfile(pathToMLAPP, '..', 'Images', 'error.png');

            % Create SurrogateModelCoordinatesListLabel
            app.SurrogateModelCoordinatesListLabel = uilabel(app.SynergyTab);
            app.SurrogateModelCoordinatesListLabel.HorizontalAlignment = 'right';
            app.SurrogateModelCoordinatesListLabel.FontSize = 18;
            app.SurrogateModelCoordinatesListLabel.FontWeight = 'bold';
            app.SurrogateModelCoordinatesListLabel.Position = [35 385 147 44];
            app.SurrogateModelCoordinatesListLabel.Text = {'Surrogate Model'; 'Coordinates List'};

            % Create SurrogateModelCoordinatesList
            app.SurrogateModelCoordinatesList = uitextarea(app.SynergyTab);
            app.SurrogateModelCoordinatesList.Editable = 'off';
            app.SurrogateModelCoordinatesList.FontSize = 18;
            app.SurrogateModelCoordinatesList.Position = [192 365 515 84];

            % Create UseRCNLMuscleControllerCheckBox
            app.UseRCNLMuscleControllerCheckBox = uicheckbox(app.SynergyTab);
            app.UseRCNLMuscleControllerCheckBox.ValueChangedFcn = createCallbackFcn(app, @UseRCNLMuscleControllerCheckBoxValueChanged, true);
            app.UseRCNLMuscleControllerCheckBox.Text = 'Use RCNL Muscle Controller';
            app.UseRCNLMuscleControllerCheckBox.FontSize = 18;
            app.UseRCNLMuscleControllerCheckBox.FontWeight = 'bold';
            app.UseRCNLMuscleControllerCheckBox.Position = [477 756 270 22];

            % Create MuscleControllerStatus
            app.MuscleControllerStatus = uiimage(app.SynergyTab);
            app.MuscleControllerStatus.Visible = 'off';
            app.MuscleControllerStatus.Position = [755 752 28 30];
            app.MuscleControllerStatus.ImageSource = fullfile(pathToMLAPP, '..', 'Images', 'error.png');

            % Create SynergyVectorNormalizationMethodLabel
            app.SynergyVectorNormalizationMethodLabel = uilabel(app.SynergyTab);
            app.SynergyVectorNormalizationMethodLabel.HorizontalAlignment = 'right';
            app.SynergyVectorNormalizationMethodLabel.FontSize = 18;
            app.SynergyVectorNormalizationMethodLabel.FontWeight = 'bold';
            app.SynergyVectorNormalizationMethodLabel.Position = [15 660 199 44];
            app.SynergyVectorNormalizationMethodLabel.Text = {'Synergy Vector '; 'Normalization Method '};

            % Create SynergyVectorNormalizationMethodDropDown
            app.SynergyVectorNormalizationMethodDropDown = uidropdown(app.SynergyTab);
            app.SynergyVectorNormalizationMethodDropDown.Items = {'Sum', 'Magnitude'};
            app.SynergyVectorNormalizationMethodDropDown.ValueChangedFcn = createCallbackFcn(app, @SynergyVectorNormalizationMethodDropDownValueChanged, true);
            app.SynergyVectorNormalizationMethodDropDown.FontSize = 18;
            app.SynergyVectorNormalizationMethodDropDown.FontWeight = 'bold';
            app.SynergyVectorNormalizationMethodDropDown.Position = [223 669 123 24];
            app.SynergyVectorNormalizationMethodDropDown.Value = 'Magnitude';

            % Create OptimizeSynergyVectorsCheckBox
            app.OptimizeSynergyVectorsCheckBox = uicheckbox(app.SynergyTab);
            app.OptimizeSynergyVectorsCheckBox.ValueChangedFcn = createCallbackFcn(app, @OptimizeSynergyVectorsCheckBoxValueChanged, true);
            app.OptimizeSynergyVectorsCheckBox.Text = 'Optimize Synergy Vectors';
            app.OptimizeSynergyVectorsCheckBox.FontSize = 18;
            app.OptimizeSynergyVectorsCheckBox.FontWeight = 'bold';
            app.OptimizeSynergyVectorsCheckBox.Position = [24 715 246 22];

            % Create SynergyControllerAdvancedSettingsTable
            app.SynergyControllerAdvancedSettingsTable = uitable(app.SynergyTab);
            app.SynergyControllerAdvancedSettingsTable.ColumnName = {'Parameter'; 'Value'};
            app.SynergyControllerAdvancedSettingsTable.RowName = {};
            app.SynergyControllerAdvancedSettingsTable.SelectionType = 'row';
            app.SynergyControllerAdvancedSettingsTable.ColumnEditable = [false true];
            app.SynergyControllerAdvancedSettingsTable.ColumnWidth = {'auto', 100};
            app.SynergyControllerAdvancedSettingsTable.CellEditCallback = createCallbackFcn(app, @SynergyControllerAdvancedSettingsTableCellEdit, true);
            app.SynergyControllerAdvancedSettingsTable.FontSize = 15;
            app.SynergyControllerAdvancedSettingsTable.Position = [16 470 441 146];

            % Create SynergyControllerAdvancedSettingsLabel
            app.SynergyControllerAdvancedSettingsLabel = uilabel(app.SynergyTab);
            app.SynergyControllerAdvancedSettingsLabel.HorizontalAlignment = 'center';
            app.SynergyControllerAdvancedSettingsLabel.FontSize = 18;
            app.SynergyControllerAdvancedSettingsLabel.FontWeight = 'bold';
            app.SynergyControllerAdvancedSettingsLabel.Position = [17 623 440 23];
            app.SynergyControllerAdvancedSettingsLabel.Text = 'Advanced Settings';

            % Create MuscleControllerMuscleListEditButton
            app.MuscleControllerMuscleListEditButton = uibutton(app.SynergyTab, 'push');
            app.MuscleControllerMuscleListEditButton.ButtonPushedFcn = createCallbackFcn(app, @MuscleControllerMuscleListEditButtonPushed, true);
            app.MuscleControllerMuscleListEditButton.BackgroundColor = [0.1294 0.1804 0.4];
            app.MuscleControllerMuscleListEditButton.FontSize = 18;
            app.MuscleControllerMuscleListEditButton.FontColor = [1 1 1];
            app.MuscleControllerMuscleListEditButton.Position = [833 672 91 30];
            app.MuscleControllerMuscleListEditButton.Text = 'Edit';

            % Create SurrogateModelCoordinatesListLabel_2
            app.SurrogateModelCoordinatesListLabel_2 = uilabel(app.SynergyTab);
            app.SurrogateModelCoordinatesListLabel_2.HorizontalAlignment = 'center';
            app.SurrogateModelCoordinatesListLabel_2.FontSize = 18;
            app.SurrogateModelCoordinatesListLabel_2.FontWeight = 'bold';
            app.SurrogateModelCoordinatesListLabel_2.Position = [481 730 327 23];
            app.SurrogateModelCoordinatesListLabel_2.Text = 'Muscle List';

            % Create MuscleControllerMuscleListStatus
            app.MuscleControllerMuscleListStatus = uiimage(app.SynergyTab);
            app.MuscleControllerMuscleListStatus.Visible = 'off';
            app.MuscleControllerMuscleListStatus.Position = [708 727 28 30];
            app.MuscleControllerMuscleListStatus.ImageSource = fullfile(pathToMLAPP, '..', 'Images', 'error.png');

            % Create MuscleControllerMuscleList
            app.MuscleControllerMuscleList = uitextarea(app.SynergyTab);
            app.MuscleControllerMuscleList.Editable = 'off';
            app.MuscleControllerMuscleList.FontSize = 18;
            app.MuscleControllerMuscleList.Position = [481 648 327 78];

            % Create MuscleControllerAdvancedSettingsTable
            app.MuscleControllerAdvancedSettingsTable = uitable(app.SynergyTab);
            app.MuscleControllerAdvancedSettingsTable.ColumnName = {'Parameter'; 'Value'};
            app.MuscleControllerAdvancedSettingsTable.RowName = {};
            app.MuscleControllerAdvancedSettingsTable.SelectionType = 'row';
            app.MuscleControllerAdvancedSettingsTable.ColumnEditable = [false true];
            app.MuscleControllerAdvancedSettingsTable.ColumnWidth = {'auto', 100};
            app.MuscleControllerAdvancedSettingsTable.CellEditCallback = createCallbackFcn(app, @MuscleControllerAdvancedSettingsTableCellEdit, true);
            app.MuscleControllerAdvancedSettingsTable.FontSize = 15;
            app.MuscleControllerAdvancedSettingsTable.Position = [481 470 442 146];

            % Create MuscleControllerAdvancedSettingsLabel
            app.MuscleControllerAdvancedSettingsLabel = uilabel(app.SynergyTab);
            app.MuscleControllerAdvancedSettingsLabel.HorizontalAlignment = 'center';
            app.MuscleControllerAdvancedSettingsLabel.FontSize = 18;
            app.MuscleControllerAdvancedSettingsLabel.FontWeight = 'bold';
            app.MuscleControllerAdvancedSettingsLabel.Position = [481 623 442 23];
            app.MuscleControllerAdvancedSettingsLabel.Text = 'Advanced Settings';

            % Create MuscleControllerAdvancedSettingsStatus
            app.MuscleControllerAdvancedSettingsStatus = uiimage(app.SynergyTab);
            app.MuscleControllerAdvancedSettingsStatus.Visible = 'off';
            app.MuscleControllerAdvancedSettingsStatus.Position = [798 619 28 30];
            app.MuscleControllerAdvancedSettingsStatus.ImageSource = fullfile(pathToMLAPP, '..', 'Images', 'error.png');

            % Create SynergyControllerAdvancedSettingsStatus
            app.SynergyControllerAdvancedSettingsStatus = uiimage(app.SynergyTab);
            app.SynergyControllerAdvancedSettingsStatus.Visible = 'off';
            app.SynergyControllerAdvancedSettingsStatus.Position = [332 619 28 30];
            app.SynergyControllerAdvancedSettingsStatus.ImageSource = fullfile(pathToMLAPP, '..', 'Images', 'error.png');

            % Create SurrogateModelDataDirectoryStatus
            app.SurrogateModelDataDirectoryStatus = uiimage(app.SynergyTab);
            app.SurrogateModelDataDirectoryStatus.Visible = 'off';
            app.SurrogateModelDataDirectoryStatus.Position = [819 314 28 30];
            app.SurrogateModelDataDirectoryStatus.ImageSource = fullfile(pathToMLAPP, '..', 'Images', 'error.png');

            % Create SurrogateModelDataDirectoryEditFieldLabel
            app.SurrogateModelDataDirectoryEditFieldLabel = uilabel(app.SynergyTab);
            app.SurrogateModelDataDirectoryEditFieldLabel.HorizontalAlignment = 'right';
            app.SurrogateModelDataDirectoryEditFieldLabel.FontSize = 18;
            app.SurrogateModelDataDirectoryEditFieldLabel.FontWeight = 'bold';
            app.SurrogateModelDataDirectoryEditFieldLabel.Position = [35 307 147 44];
            app.SurrogateModelDataDirectoryEditFieldLabel.Text = {'Surrogate Model'; 'Data Directory'};

            % Create SurrogateModelDataDirectoryEditField
            app.SurrogateModelDataDirectoryEditField = uieditfield(app.SynergyTab, 'text');
            app.SurrogateModelDataDirectoryEditField.ValueChangedFcn = createCallbackFcn(app, @SurrogateModelDataDirectoryEditFieldValueChanged, true);
            app.SurrogateModelDataDirectoryEditField.Position = [192 314 576 30];

            % Create SurrogateModelFileNameStatus
            app.SurrogateModelFileNameStatus = uiimage(app.SynergyTab);
            app.SurrogateModelFileNameStatus.Visible = 'off';
            app.SurrogateModelFileNameStatus.Position = [820 261 28 30];
            app.SurrogateModelFileNameStatus.ImageSource = fullfile(pathToMLAPP, '..', 'Images', 'error.png');

            % Create SurrogateModelFileNameEditFieldLabel
            app.SurrogateModelFileNameEditFieldLabel = uilabel(app.SynergyTab);
            app.SurrogateModelFileNameEditFieldLabel.HorizontalAlignment = 'right';
            app.SurrogateModelFileNameEditFieldLabel.FontSize = 18;
            app.SurrogateModelFileNameEditFieldLabel.FontWeight = 'bold';
            app.SurrogateModelFileNameEditFieldLabel.Position = [36 254 147 44];
            app.SurrogateModelFileNameEditFieldLabel.Text = {'Surrogate Model'; 'File Name'};

            % Create SurrogateModelFileNameEditField
            app.SurrogateModelFileNameEditField = uieditfield(app.SynergyTab, 'text');
            app.SurrogateModelFileNameEditField.ValueChangedFcn = createCallbackFcn(app, @SurrogateModelFileNameEditFieldValueChanged, true);
            app.SurrogateModelFileNameEditField.Position = [193 261 575 30];

            % Create SurrogateModelDataDirectorySearchButton
            app.SurrogateModelDataDirectorySearchButton = uibutton(app.SynergyTab, 'push');
            app.SurrogateModelDataDirectorySearchButton.ButtonPushedFcn = createCallbackFcn(app, @SurrogateModelDataDirectorySearchButtonPushed, true);
            app.SurrogateModelDataDirectorySearchButton.Icon = fullfile(pathToMLAPP, '..', 'Images', 'folderIcon.svg');
            app.SurrogateModelDataDirectorySearchButton.VerticalAlignment = 'bottom';
            app.SurrogateModelDataDirectorySearchButton.BackgroundColor = [0.1294 0.1804 0.4];
            app.SurrogateModelDataDirectorySearchButton.Position = [783 314 31 30];
            app.SurrogateModelDataDirectorySearchButton.Text = '';

            % Create SurrogateModelFileNameSearchButton
            app.SurrogateModelFileNameSearchButton = uibutton(app.SynergyTab, 'push');
            app.SurrogateModelFileNameSearchButton.ButtonPushedFcn = createCallbackFcn(app, @SurrogateModelFileNameSearchButtonPushed, true);
            app.SurrogateModelFileNameSearchButton.Icon = fullfile(pathToMLAPP, '..', 'Images', 'folderIcon.svg');
            app.SurrogateModelFileNameSearchButton.VerticalAlignment = 'bottom';
            app.SurrogateModelFileNameSearchButton.BackgroundColor = [0.1294 0.1804 0.4];
            app.SurrogateModelFileNameSearchButton.Position = [784 261 31 30];
            app.SurrogateModelFileNameSearchButton.Text = '';

            % Create MuscleActivationsFileEditFieldLabel
            app.MuscleActivationsFileEditFieldLabel = uilabel(app.SynergyTab);
            app.MuscleActivationsFileEditFieldLabel.HorizontalAlignment = 'right';
            app.MuscleActivationsFileEditFieldLabel.FontSize = 18;
            app.MuscleActivationsFileEditFieldLabel.FontWeight = 'bold';
            app.MuscleActivationsFileEditFieldLabel.Position = [17 204 167 44];
            app.MuscleActivationsFileEditFieldLabel.Text = {'Muscle Activations'; 'File'};

            % Create MuscleActivationsFileEditField
            app.MuscleActivationsFileEditField = uieditfield(app.SynergyTab, 'text');
            app.MuscleActivationsFileEditField.ValueChangedFcn = createCallbackFcn(app, @MuscleActivationsFileEditFieldValueChanged, true);
            app.MuscleActivationsFileEditField.Position = [194 211 574 30];

            % Create MuscleActivationsFileSearchButton
            app.MuscleActivationsFileSearchButton = uibutton(app.SynergyTab, 'push');
            app.MuscleActivationsFileSearchButton.ButtonPushedFcn = createCallbackFcn(app, @MuscleActivationsFileSearchButtonPushed, true);
            app.MuscleActivationsFileSearchButton.Icon = fullfile(pathToMLAPP, '..', 'Images', 'folderIcon.svg');
            app.MuscleActivationsFileSearchButton.VerticalAlignment = 'bottom';
            app.MuscleActivationsFileSearchButton.BackgroundColor = [0.1294 0.1804 0.4];
            app.MuscleActivationsFileSearchButton.Position = [785 211 31 30];
            app.MuscleActivationsFileSearchButton.Text = '';

            % Create MuscleActivationsFileStatus
            app.MuscleActivationsFileStatus = uiimage(app.SynergyTab);
            app.MuscleActivationsFileStatus.Visible = 'off';
            app.MuscleActivationsFileStatus.Position = [821 211 28 30];
            app.MuscleActivationsFileStatus.ImageSource = fullfile(pathToMLAPP, '..', 'Images', 'error.png');

            % Create SurrogateModelAdvancedSettingsTable
            app.SurrogateModelAdvancedSettingsTable = uitable(app.SynergyTab);
            app.SurrogateModelAdvancedSettingsTable.ColumnName = {'Parameter'; 'Value'};
            app.SurrogateModelAdvancedSettingsTable.RowName = {};
            app.SurrogateModelAdvancedSettingsTable.SelectionType = 'row';
            app.SurrogateModelAdvancedSettingsTable.ColumnEditable = [false true];
            app.SurrogateModelAdvancedSettingsTable.ColumnWidth = {'auto', 100};
            app.SurrogateModelAdvancedSettingsTable.CellEditCallback = createCallbackFcn(app, @SurrogateModelAdvancedSettingsTableCellEdit, true);
            app.SurrogateModelAdvancedSettingsTable.FontSize = 15;
            app.SurrogateModelAdvancedSettingsTable.Position = [174 20 571 146];

            % Create SurrogateModelAdvancedSettingsLabel
            app.SurrogateModelAdvancedSettingsLabel = uilabel(app.SynergyTab);
            app.SurrogateModelAdvancedSettingsLabel.HorizontalAlignment = 'center';
            app.SurrogateModelAdvancedSettingsLabel.FontSize = 18;
            app.SurrogateModelAdvancedSettingsLabel.FontWeight = 'bold';
            app.SurrogateModelAdvancedSettingsLabel.Position = [174 173 571 23];
            app.SurrogateModelAdvancedSettingsLabel.Text = 'Advanced Settings';

            % Create SurrogateModelAdvancedSettingsStatus
            app.SurrogateModelAdvancedSettingsStatus = uiimage(app.SynergyTab);
            app.SurrogateModelAdvancedSettingsStatus.Visible = 'off';
            app.SurrogateModelAdvancedSettingsStatus.Position = [555 169 28 30];
            app.SurrogateModelAdvancedSettingsStatus.ImageSource = fullfile(pathToMLAPP, '..', 'Images', 'error.png');

            % Create UserDefinedTab
            app.UserDefinedTab = uitab(app.ControllersTabGroup);
            app.UserDefinedTab.Title = 'Tab4';
            app.UserDefinedTab.BackgroundColor = [0.851 0.851 0.851];

            % Create Mask1_2
            app.Mask1_2 = uiimage(app.ControllersTab);
            app.Mask1_2.ScaleMethod = 'fill';
            app.Mask1_2.Position = [0 788 939 30];
            app.Mask1_2.ImageSource = fullfile(pathToMLAPP, '..', 'Images', 'greyMask.png');

            % Create UserDefinedControlsButton
            app.UserDefinedControlsButton = uibutton(app.ControllersTab, 'push');
            app.UserDefinedControlsButton.ButtonPushedFcn = createCallbackFcn(app, @UserDefinedControlsButtonPushed, true);
            app.UserDefinedControlsButton.WordWrap = 'on';
            app.UserDefinedControlsButton.BackgroundColor = [0.1294 0.1804 0.4];
            app.UserDefinedControlsButton.FontSize = 18;
            app.UserDefinedControlsButton.FontColor = [1 1 1];
            app.UserDefinedControlsButton.Position = [270 785 125 31];
            app.UserDefinedControlsButton.Text = 'User-defined';

            % Create SynergyControlsButton
            app.SynergyControlsButton = uibutton(app.ControllersTab, 'push');
            app.SynergyControlsButton.ButtonPushedFcn = createCallbackFcn(app, @SynergyControlsButtonPushed, true);
            app.SynergyControlsButton.WordWrap = 'on';
            app.SynergyControlsButton.BackgroundColor = [0.1294 0.1804 0.4];
            app.SynergyControlsButton.FontSize = 18;
            app.SynergyControlsButton.FontColor = [1 1 1];
            app.SynergyControlsButton.Position = [116 785 148 31];
            app.SynergyControlsButton.Text = 'Synergy/Muscle';

            % Create TorqueControlsButton
            app.TorqueControlsButton = uibutton(app.ControllersTab, 'push');
            app.TorqueControlsButton.ButtonPushedFcn = createCallbackFcn(app, @TorqueControlsButtonPushed, true);
            app.TorqueControlsButton.WordWrap = 'on';
            app.TorqueControlsButton.BackgroundColor = [0.1294 0.1804 0.4];
            app.TorqueControlsButton.FontSize = 18;
            app.TorqueControlsButton.FontColor = [1 1 1];
            app.TorqueControlsButton.Position = [1 785 110 31];
            app.TorqueControlsButton.Text = 'Torque';

            % Create CostTermsTab
            app.CostTermsTab = uitab(app.TabGroup);
            app.CostTermsTab.BackgroundColor = [0.851 0.851 0.851];

            % Create CostTermsListTable
            app.CostTermsListTable = uitable(app.CostTermsTab);
            app.CostTermsListTable.ColumnName = {''; 'Cost Term'};
            app.CostTermsListTable.ColumnWidth = {30, 'auto'};
            app.CostTermsListTable.RowName = {};
            app.CostTermsListTable.ColumnEditable = [true true];
            app.CostTermsListTable.CellEditCallback = createCallbackFcn(app, @CostTermsListTableCellEdit, true);
            app.CostTermsListTable.SelectionChangedFcn = createCallbackFcn(app, @CostTermsListTableSelectionChanged, true);
            app.CostTermsListTable.SelectionType = 'row';
            app.CostTermsListTable.Multiselect = 'off';
            app.CostTermsListTable.RowStriping = 'off';
            app.CostTermsListTable.Position = [25 24 380 725];
            app.CostTermsListTable.FontSize = 18;

            % Create CostTermTypeDropDownLabel
            app.CostTermTypeDropDownLabel = uilabel(app.CostTermsTab);
            app.CostTermTypeDropDownLabel.HorizontalAlignment = 'center';
            app.CostTermTypeDropDownLabel.FontSize = 18;
            app.CostTermTypeDropDownLabel.FontWeight = 'bold';
            app.CostTermTypeDropDownLabel.Position = [437 753 475 23];
            app.CostTermTypeDropDownLabel.Text = 'Cost Term Type';

            % Create CostTermTypeDropDown
            app.CostTermTypeDropDown = uidropdown(app.CostTermsTab);
            app.CostTermTypeDropDown.Items = {};
            app.CostTermTypeDropDown.Editable = 'on';
            app.CostTermTypeDropDown.ValueChangedFcn = createCallbackFcn(app, @CostTermTypeDropDownValueChanged, true);
            app.CostTermTypeDropDown.FontSize = 16;
            app.CostTermTypeDropDown.Position = [435 717 479 32];
            app.CostTermTypeDropDown.Value = {};

            % Create ComponentListTextAreaLabel
            app.ComponentListTextAreaLabel = uilabel(app.CostTermsTab);
            app.ComponentListTextAreaLabel.HorizontalAlignment = 'center';
            app.ComponentListTextAreaLabel.FontSize = 18;
            app.ComponentListTextAreaLabel.FontWeight = 'bold';
            app.ComponentListTextAreaLabel.Position = [435 680 378 23];
            app.ComponentListTextAreaLabel.Text = 'Component List';

            % Create CostTermComponentListTextArea
            app.CostTermComponentListTextArea = uitextarea(app.CostTermsTab);
            app.CostTermComponentListTextArea.FontSize = 18;
            app.CostTermComponentListTextArea.FontWeight = 'bold';
            app.CostTermComponentListTextArea.Position = [435 404 378 272];
            app.CostTermComponentListTextArea.Editable = "off";

            % Create CostTermComponentListEditButton
            app.CostTermComponentListEditButton = uibutton(app.CostTermsTab, 'push');
            app.CostTermComponentListEditButton.ButtonPushedFcn = createCallbackFcn(app, @CostTermComponentListEditButtonPushed, true);
            app.CostTermComponentListEditButton.BackgroundColor = [0.1294 0.1804 0.4];
            app.CostTermComponentListEditButton.FontSize = 18;
            app.CostTermComponentListEditButton.FontColor = [1 1 1];
            app.CostTermComponentListEditButton.Position = [823 538 91 30];
            app.CostTermComponentListEditButton.Text = 'Edit';

            % Create CostTermTypeStatus
            app.CostTermTypeStatus = uiimage(app.CostTermsTab);
            app.CostTermTypeStatus.Visible = 'off';
            app.CostTermTypeStatus.Position = [747 749 28 30];
            app.CostTermTypeStatus.ImageSource = fullfile(pathToMLAPP, '..', 'Images', 'error.png');

            % Create CostTermComponentListStatus
            app.CostTermComponentListStatus = uiimage(app.CostTermsTab);
            app.CostTermComponentListStatus.Visible = 'off';
            app.CostTermComponentListStatus.Position = [700 677 28 30];
            app.CostTermComponentListStatus.ImageSource = fullfile(pathToMLAPP, '..', 'Images', 'error.png');

            % Create CostTermsListLabel
            app.CostTermsListLabel = uilabel(app.CostTermsTab);
            app.CostTermsListLabel.HorizontalAlignment = 'center';
            app.CostTermsListLabel.FontSize = 18;
            app.CostTermsListLabel.FontWeight = 'bold';
            app.CostTermsListLabel.Position = [25 753 380 23];
            app.CostTermsListLabel.Text = 'Cost Terms';

            % Create CostTermsListStatus
            app.CostTermsListStatus = uiimage(app.CostTermsTab);
            app.CostTermsListStatus.Visible = 'off';
            app.CostTermsListStatus.Position = [271 749 28 30];
            app.CostTermsListStatus.ImageSource = fullfile(pathToMLAPP, '..', 'Images', 'error.png');

            % Create MaxAllowableErrorEditFieldLabel
            app.MaxAllowableErrorEditFieldLabel = uilabel(app.CostTermsTab);
            app.MaxAllowableErrorEditFieldLabel.HorizontalAlignment = 'right';
            app.MaxAllowableErrorEditFieldLabel.FontSize = 18;
            app.MaxAllowableErrorEditFieldLabel.FontWeight = 'bold';
            app.MaxAllowableErrorEditFieldLabel.Position = [435 340 220 30];
            app.MaxAllowableErrorEditFieldLabel.Text = 'Max Allowable Error';

            % Create MaxAllowableErrorEditField
            app.MaxAllowableErrorEditField = uieditfield(app.CostTermsTab, 'numeric');
            app.MaxAllowableErrorEditField.Limits = [1e-08 Inf];
            app.MaxAllowableErrorEditField.ValueChangedFcn = createCallbackFcn(app, @MaxAllowableErrorEditFieldValueChanged, true);
            app.MaxAllowableErrorEditField.FontSize = 16;
            app.MaxAllowableErrorEditField.FontWeight = 'bold';
            app.MaxAllowableErrorEditField.Position = [665 340 120 30];
            app.MaxAllowableErrorEditField.Value = 1;

            % Create ErrorCenterEditFieldLabel
            app.ErrorCenterEditFieldLabel = uilabel(app.CostTermsTab);
            app.ErrorCenterEditFieldLabel.HorizontalAlignment = 'right';
            app.ErrorCenterEditFieldLabel.FontSize = 18;
            app.ErrorCenterEditFieldLabel.FontWeight = 'bold';
            app.ErrorCenterEditFieldLabel.Position = [435 294 220 30];
            app.ErrorCenterEditFieldLabel.Text = 'Error Center';

            % Create ErrorCenterEditField
            app.ErrorCenterEditField = uieditfield(app.CostTermsTab, 'numeric');
            app.ErrorCenterEditField.ValueChangedFcn = createCallbackFcn(app, @ErrorCenterEditFieldValueChanged, true);
            app.ErrorCenterEditField.FontSize = 16;
            app.ErrorCenterEditField.FontWeight = 'bold';
            app.ErrorCenterEditField.Position = [665 294 120 30];
            app.ErrorCenterEditField.Value = 0;

            % Create MiscellaneousCostTermParametersTable
            app.MiscellaneousCostTermParametersTable = uitable(app.CostTermsTab);
            app.MiscellaneousCostTermParametersTable.ColumnName = {'Parameter'; 'Value'};
            app.MiscellaneousCostTermParametersTable.RowName = {};
            app.MiscellaneousCostTermParametersTable.SelectionType = 'row';
            app.MiscellaneousCostTermParametersTable.Multiselect = 'off';
            app.MiscellaneousCostTermParametersTable.ColumnEditable = [false true];
            app.MiscellaneousCostTermParametersTable.CellEditCallback = createCallbackFcn(app, @MiscellaneousCostTermParametersTableCellEdit, true);
            app.MiscellaneousCostTermParametersTable.FontSize = 15;
            app.MiscellaneousCostTermParametersTable.Position = [435 27 479 208];

            % Create MiscellaneousCostTermParametersLabel
            app.MiscellaneousCostTermParametersLabel = uilabel(app.CostTermsTab);
            app.MiscellaneousCostTermParametersLabel.HorizontalAlignment = 'center';
            app.MiscellaneousCostTermParametersLabel.FontSize = 18;
            app.MiscellaneousCostTermParametersLabel.FontWeight = 'bold';
            app.MiscellaneousCostTermParametersLabel.Position = [437 241 475 30];
            app.MiscellaneousCostTermParametersLabel.Text = 'Miscellaneous Cost Term Parameters';

            % Create MiscellaneousCostTermParametersStatus
            app.MiscellaneousCostTermParametersStatus = uiimage(app.CostTermsTab);
            app.MiscellaneousCostTermParametersStatus.Visible = 'off';
            app.MiscellaneousCostTermParametersStatus.Position = [841 241 28 30];
            app.MiscellaneousCostTermParametersStatus.ImageSource = fullfile(pathToMLAPP, '..', 'Images', 'error.png');

            % Create ConstraintTermsTab
            app.ConstraintTermsTab = uitab(app.TabGroup);
            app.ConstraintTermsTab.BackgroundColor = [0.851 0.851 0.851];

            % Create ConstraintTermsListTable
            app.ConstraintTermsListTable = uitable(app.ConstraintTermsTab);
            app.ConstraintTermsListTable.ColumnName = {''; 'Constraint Term'};
            app.ConstraintTermsListTable.ColumnWidth = {30, 'auto'};
            app.ConstraintTermsListTable.RowName = {};
            app.ConstraintTermsListTable.ColumnEditable = [true true];
            app.ConstraintTermsListTable.CellEditCallback = createCallbackFcn(app, @ConstraintTermsListTableCellEdit, true);
            app.ConstraintTermsListTable.SelectionChangedFcn = createCallbackFcn(app, @ConstraintTermsListTableSelectionChanged, true);
            app.ConstraintTermsListTable.SelectionType = 'row';
            app.ConstraintTermsListTable.Multiselect = 'off';
            app.ConstraintTermsListTable.RowStriping = 'off';
            app.ConstraintTermsListTable.Position = [25 24 380 725];
            app.ConstraintTermsListTable.FontSize = 18;

            % Create ConstraintTermTypeStatus
            app.ConstraintTermTypeStatus = uiimage(app.ConstraintTermsTab);
            app.ConstraintTermTypeStatus.Visible = 'off';
            app.ConstraintTermTypeStatus.Position = [774 749 28 30];
            app.ConstraintTermTypeStatus.ImageSource = fullfile(pathToMLAPP, '..', 'Images', 'error.png');

            % Create ConstraintTermComponentListStatus
            app.ConstraintTermComponentListStatus = uiimage(app.ConstraintTermsTab);
            app.ConstraintTermComponentListStatus.Visible = 'off';
            app.ConstraintTermComponentListStatus.Position = [700 677 28 30];
            app.ConstraintTermComponentListStatus.ImageSource = fullfile(pathToMLAPP, '..', 'Images', 'error.png');

            % Create ConstraintTermsListLabel
            app.ConstraintTermsListLabel = uilabel(app.ConstraintTermsTab);
            app.ConstraintTermsListLabel.HorizontalAlignment = 'center';
            app.ConstraintTermsListLabel.FontSize = 18;
            app.ConstraintTermsListLabel.FontWeight = 'bold';
            app.ConstraintTermsListLabel.Position = [25 753 380 23];
            app.ConstraintTermsListLabel.Text = 'Constraint Terms';

            % Create ConstraintTermsListStatus
            app.ConstraintTermsListStatus = uiimage(app.ConstraintTermsTab);
            app.ConstraintTermsListStatus.Visible = 'off';
            app.ConstraintTermsListStatus.Position = [297 749 28 30];
            app.ConstraintTermsListStatus.ImageSource = fullfile(pathToMLAPP, '..', 'Images', 'error.png');

            % Create MiscellaneousConstraintTermParametersTable
            app.MiscellaneousConstraintTermParametersTable = uitable(app.ConstraintTermsTab);
            app.MiscellaneousConstraintTermParametersTable.ColumnName = {'Parameter'; 'Value'};
            app.MiscellaneousConstraintTermParametersTable.RowName = {};
            app.MiscellaneousConstraintTermParametersTable.SelectionType = 'row';
            app.MiscellaneousConstraintTermParametersTable.Multiselect = 'off';
            app.MiscellaneousConstraintTermParametersTable.ColumnEditable = [false true];
            app.MiscellaneousConstraintTermParametersTable.CellEditCallback = createCallbackFcn(app, @MiscellaneousConstraintTermParametersTableCellEdit, true);
            app.MiscellaneousConstraintTermParametersTable.FontSize = 15;
            app.MiscellaneousConstraintTermParametersTable.Position = [435 27 479 208];

            % Create MiscellaneousConstraintTermParametersLabel
            app.MiscellaneousConstraintTermParametersLabel = uilabel(app.ConstraintTermsTab);
            app.MiscellaneousConstraintTermParametersLabel.HorizontalAlignment = 'center';
            app.MiscellaneousConstraintTermParametersLabel.FontSize = 18;
            app.MiscellaneousConstraintTermParametersLabel.FontWeight = 'bold';
            app.MiscellaneousConstraintTermParametersLabel.Position = [437 241 475 30];
            app.MiscellaneousConstraintTermParametersLabel.Text = 'Miscellaneous Constraint Term Parameters';

            % Create MiscellaneousConstraintTermParametersStatus
            app.MiscellaneousConstraintTermParametersStatus = uiimage(app.ConstraintTermsTab);
            app.MiscellaneousConstraintTermParametersStatus.Visible = 'off';
            app.MiscellaneousConstraintTermParametersStatus.Position = [841 241 28 30];
            app.MiscellaneousConstraintTermParametersStatus.ImageSource = fullfile(pathToMLAPP, '..', 'Images', 'error.png');

            % Create ConstraintTermTypeDropDownLabel
            app.ConstraintTermTypeDropDownLabel = uilabel(app.ConstraintTermsTab);
            app.ConstraintTermTypeDropDownLabel.HorizontalAlignment = 'center';
            app.ConstraintTermTypeDropDownLabel.FontSize = 18;
            app.ConstraintTermTypeDropDownLabel.FontWeight = 'bold';
            app.ConstraintTermTypeDropDownLabel.Position = [437 753 475 23];
            app.ConstraintTermTypeDropDownLabel.Text = 'Constraint Term Type';

            % Create ConstraintTermTypeDropDown
            app.ConstraintTermTypeDropDown = uidropdown(app.ConstraintTermsTab);
            app.ConstraintTermTypeDropDown.Items = {};
            app.ConstraintTermTypeDropDown.Editable = 'on';
            app.ConstraintTermTypeDropDown.ValueChangedFcn = createCallbackFcn(app, @ConstraintTermTypeDropDownValueChanged, true);
            app.ConstraintTermTypeDropDown.FontSize = 16;
            app.ConstraintTermTypeDropDown.Position = [435 717 479 32];
            app.ConstraintTermTypeDropDown.Value = {};

            % Create ConstraintTermComponentListTextAreaLabel
            app.ConstraintTermComponentListTextAreaLabel = uilabel(app.ConstraintTermsTab);
            app.ConstraintTermComponentListTextAreaLabel.HorizontalAlignment = 'center';
            app.ConstraintTermComponentListTextAreaLabel.FontSize = 18;
            app.ConstraintTermComponentListTextAreaLabel.FontWeight = 'bold';
            app.ConstraintTermComponentListTextAreaLabel.Position = [435 680 378 23];
            app.ConstraintTermComponentListTextAreaLabel.Text = 'Component List';

            % Create ConstraintTermComponentListTextArea
            app.ConstraintTermComponentListTextArea = uitextarea(app.ConstraintTermsTab);
            app.ConstraintTermComponentListTextArea.FontSize = 18;
            app.ConstraintTermComponentListTextArea.FontWeight = 'bold';
            app.ConstraintTermComponentListTextArea.Position = [435 404 378 272];
            app.ConstraintTermComponentListTextArea.Editable = "off";

            % Create ConstraintTermComponentListEditButton
            app.ConstraintTermComponentListEditButton = uibutton(app.ConstraintTermsTab, 'push');
            app.ConstraintTermComponentListEditButton.ButtonPushedFcn = createCallbackFcn(app, @ConstraintTermComponentListEditButtonPushed, true);
            app.ConstraintTermComponentListEditButton.BackgroundColor = [0.1294 0.1804 0.4];
            app.ConstraintTermComponentListEditButton.FontSize = 18;
            app.ConstraintTermComponentListEditButton.FontColor = [1 1 1];
            app.ConstraintTermComponentListEditButton.Position = [823 538 91 30];
            app.ConstraintTermComponentListEditButton.Text = 'Edit';

            % Create MaxErrroLabel
            app.MaxErrroLabel = uilabel(app.ConstraintTermsTab);
            app.MaxErrroLabel.HorizontalAlignment = 'right';
            app.MaxErrroLabel.FontSize = 18;
            app.MaxErrroLabel.FontWeight = 'bold';
            app.MaxErrroLabel.Position = [435 340 220 30];
            app.MaxErrroLabel.Text = 'Max Error';

            % Create MaxErrorField
            app.MaxErrorField = uieditfield(app.ConstraintTermsTab, 'numeric');
            app.MaxErrorField.ValueChangedFcn = createCallbackFcn(app, @MaxErrorFieldValueChanged, true);
            app.MaxErrorField.FontSize = 16;
            app.MaxErrorField.FontWeight = 'bold';
            app.MaxErrorField.Position = [665 340 120 30];
            app.MaxErrorField.Value = 1;

            % Create MinErrorEditFieldLabel
            app.MinErrorEditFieldLabel = uilabel(app.ConstraintTermsTab);
            app.MinErrorEditFieldLabel.HorizontalAlignment = 'right';
            app.MinErrorEditFieldLabel.FontSize = 18;
            app.MinErrorEditFieldLabel.FontWeight = 'bold';
            app.MinErrorEditFieldLabel.Position = [435 294 220 30];
            app.MinErrorEditFieldLabel.Text = 'Min Error';

            % Create MinErrorEditField
            app.MinErrorEditField = uieditfield(app.ConstraintTermsTab, 'numeric');
            app.MinErrorEditField.ValueChangedFcn = createCallbackFcn(app, @MinErrorEditFieldValueChanged, true);
            app.MinErrorEditField.FontSize = 16;
            app.MinErrorEditField.FontWeight = 'bold';
            app.MinErrorEditField.Position = [665 294 120 30];
            app.MinErrorEditField.Value = -1;

            % Create SolverSettingsTab
            app.SolverSettingsTab = uitab(app.TabGroup);
            app.SolverSettingsTab.BackgroundColor = [0.851 0.851 0.851];

            % Create SolverSettingsFileStatus
            app.SolverSettingsFileStatus = uiimage(app.SolverSettingsTab);
            app.SolverSettingsFileStatus.Visible = 'off';
            app.SolverSettingsFileStatus.Position = [716 652 28 30];
            app.SolverSettingsFileStatus.ImageSource = fullfile(pathToMLAPP, '..', 'Images', 'error.png');

            % Create SolverSettingsFileSearchButton
            app.SolverSettingsFileSearchButton = uibutton(app.SolverSettingsTab, 'push');
            app.SolverSettingsFileSearchButton.ButtonPushedFcn = createCallbackFcn(app, @SolverSettingsFileSearchButtonPushed, true);
            app.SolverSettingsFileSearchButton.Icon = fullfile(pathToMLAPP, '..', 'Images', 'folderIcon.svg');
            app.SolverSettingsFileSearchButton.VerticalAlignment = 'bottom';
            app.SolverSettingsFileSearchButton.BackgroundColor = [0.1294 0.1804 0.4];
            app.SolverSettingsFileSearchButton.Position = [676 652 31 30];
            app.SolverSettingsFileSearchButton.Text = '';

            % Create SolverSettingsFileLabel
            app.SolverSettingsFileLabel = uilabel(app.SolverSettingsTab);
            app.SolverSettingsFileLabel.HorizontalAlignment = 'right';
            app.SolverSettingsFileLabel.FontSize = 18;
            app.SolverSettingsFileLabel.FontWeight = 'bold';
            app.SolverSettingsFileLabel.Position = [34 652 172 30];
            app.SolverSettingsFileLabel.Text = 'Solver Settings File';

            % Create SolverSettingsFileEditField
            app.SolverSettingsFileEditField = uieditfield(app.SolverSettingsTab, 'text');
            app.SolverSettingsFileEditField.ValueChangedFcn = createCallbackFcn(app, @SolverSettingsFileEditFieldValueChanged, true);
            app.SolverSettingsFileEditField.Position = [216 652 450 30];

            % Create SolverSelectionDropDownLabel
            app.SolverSelectionDropDownLabel = uilabel(app.SolverSettingsTab);
            app.SolverSelectionDropDownLabel.HorizontalAlignment = 'right';
            app.SolverSelectionDropDownLabel.FontSize = 24;
            app.SolverSelectionDropDownLabel.FontWeight = 'bold';
            app.SolverSelectionDropDownLabel.Position = [33 719 193 32];
            app.SolverSelectionDropDownLabel.Text = 'Solver Selection';

            % Create SolverSelectionDropDown
            app.SolverSelectionDropDown = uidropdown(app.SolverSettingsTab);
            app.SolverSelectionDropDown.Items = {'GPOPS-II', 'Casadi'};
            app.SolverSelectionDropDown.ValueChangedFcn = createCallbackFcn(app, @SolverSelectionDropDownValueChanged, true);
            app.SolverSelectionDropDown.FontSize = 20;
            app.SolverSelectionDropDown.FontWeight = 'bold';
            app.SolverSelectionDropDown.Position = [237 716 449 36];
            app.SolverSelectionDropDown.Value = 'GPOPS-II';

            % Create MakeDefaultSettingsFileButton
            app.MakeDefaultSettingsFileButton = uibutton(app.SolverSettingsTab, 'push');
            app.MakeDefaultSettingsFileButton.ButtonPushedFcn = createCallbackFcn(app, @MakeDefaultSettingsFileButtonPushed, true);
            app.MakeDefaultSettingsFileButton.BackgroundColor = [0.1294 0.1804 0.4];
            app.MakeDefaultSettingsFileButton.FontSize = 18;
            app.MakeDefaultSettingsFileButton.FontColor = [1 1 1];
            app.MakeDefaultSettingsFileButton.Position = [41 580 154 52];
            app.MakeDefaultSettingsFileButton.Text = {'Save Solver'; 'Settings File'};

            % Create SolverSettingsTable
            app.SolverSettingsTable = uitable(app.SolverSettingsTab);
            app.SolverSettingsTable.ColumnName = {'Parameter'; 'Value'};
            app.SolverSettingsTable.RowName = {};
            app.SolverSettingsTable.SelectionType = 'row';
            app.SolverSettingsTable.ColumnEditable = [false true];
            app.SolverSettingsTable.ColumnWidth = {'auto', 100};
            app.SolverSettingsTable.CellEditCallback = createCallbackFcn(app, @SolverSettingsTableCellEdit, true);
            app.SolverSettingsTable.FontSize = 15;
            app.SolverSettingsTable.Position = [113 49 544 457];

            % Create SolverSettingsLabel
            app.SolverSettingsLabel = uilabel(app.SolverSettingsTab);
            app.SolverSettingsLabel.HorizontalAlignment = 'center';
            app.SolverSettingsLabel.FontSize = 18;
            app.SolverSettingsLabel.FontWeight = 'bold';
            app.SolverSettingsLabel.Position = [113 509 542 30];
            app.SolverSettingsLabel.Text = 'Solver Settings';

            % Create SolverSettingsStatus
            app.SolverSettingsStatus = uiimage(app.SolverSettingsTab);
            app.SolverSettingsStatus.Visible = 'off';
            app.SolverSettingsStatus.Position = [462 509 28 30];
            app.SolverSettingsStatus.ImageSource = fullfile(pathToMLAPP, '..', 'Images', 'error.png');

            % Create AdvancedTab
            app.AdvancedTab = uitab(app.TabGroup);
            app.AdvancedTab.Title = 'Tab';
            app.AdvancedTab.BackgroundColor = [0.851 0.851 0.851];

            % Create AdvancedParamsTable
            app.AdvancedParamsTable = uitable(app.AdvancedTab);
            app.AdvancedParamsTable.ColumnName = {'Parameter'; 'Value'};
            app.AdvancedParamsTable.RowName = {};
            app.AdvancedParamsTable.SelectionType = 'row';
            app.AdvancedParamsTable.ColumnEditable = [false true];
            app.AdvancedParamsTable.ColumnWidth = {'auto', 120};
            app.AdvancedParamsTable.CellEditCallback = createCallbackFcn(app, @AdvancedParamsTableCellEdit, true);
            app.AdvancedParamsTable.FontSize = 15;
            % Wide enough for first_order_control_dynamics_filter_time_constant
            app.AdvancedParamsTable.Position = [70 177 800 476];

            % Create AdvancedParamsStatus
            app.AdvancedParamsStatus = uiimage(app.AdvancedTab);
            app.AdvancedParamsStatus.Visible = 'off';
            app.AdvancedParamsStatus.Position = [380 661 28 30];
            app.AdvancedParamsStatus.ImageSource = fullfile(pathToMLAPP, '..', 'Images', 'error.png');

            % Create Mask1
            app.Mask1 = uiimage(app.UIFigure);
            app.Mask1.ScaleMethod = 'fill';
            app.Mask1.Position = [211 891 938 30];
            app.Mask1.ImageSource = fullfile(pathToMLAPP, '..', 'Images', 'greyMask.png');

            % Create MTPImage
            app.MTPImage = uiimage(app.UIFigure);
            app.MTPImage.Position = [1 442 178 420];

            % Create AdvancedButton
            app.AdvancedButton = uibutton(app.UIFigure, 'push');
            app.AdvancedButton.ButtonPushedFcn = createCallbackFcn(app, @AdvancedButtonPushed, true);
            app.AdvancedButton.BackgroundColor = [0.1294 0.1804 0.4];
            app.AdvancedButton.FontSize = 18;
            app.AdvancedButton.FontColor = [1 1 1];
            app.AdvancedButton.Position = [855 892 110 30];
            app.AdvancedButton.Text = 'Advanced';

            % Create ConstraintTermsButton
            app.ConstraintTermsButton = uibutton(app.UIFigure, 'push');
            app.ConstraintTermsButton.ButtonPushedFcn = createCallbackFcn(app, @ConstraintTermsButtonPushed, true);
            app.ConstraintTermsButton.BackgroundColor = [0.1294 0.1804 0.4];
            app.ConstraintTermsButton.FontSize = 18;
            app.ConstraintTermsButton.FontColor = [1 1 1];
            app.ConstraintTermsButton.Position = [550 892 151 30];
            app.ConstraintTermsButton.Text = 'Constraint Terms';

            % Create CostTermsButton
            app.CostTermsButton = uibutton(app.UIFigure, 'push');
            app.CostTermsButton.ButtonPushedFcn = createCallbackFcn(app, @CostTermsButtonPushed, true);
            app.CostTermsButton.BackgroundColor = [0.1294 0.1804 0.4];
            app.CostTermsButton.FontSize = 18;
            app.CostTermsButton.FontColor = [1 1 1];
            app.CostTermsButton.Position = [437 891 106 30];
            app.CostTermsButton.Text = 'Cost Terms';

            % Create ControllersButton
            app.ControllersButton = uibutton(app.UIFigure, 'push');
            app.ControllersButton.ButtonPushedFcn = createCallbackFcn(app, @ControllersButtonPushed, true);
            app.ControllersButton.BackgroundColor = [0.1294 0.1804 0.4];
            app.ControllersButton.FontSize = 18;
            app.ControllersButton.FontColor = [1 1 1];
            app.ControllersButton.Position = [328 892 102 30];
            app.ControllersButton.Text = 'Controllers';

            % Create SolverSettingsButton
            app.SolverSettingsButton = uibutton(app.UIFigure, 'push');
            app.SolverSettingsButton.ButtonPushedFcn = createCallbackFcn(app, @SolverSettingsButtonPushed, true);
            app.SolverSettingsButton.BackgroundColor = [0.1294 0.1804 0.4];
            app.SolverSettingsButton.FontSize = 18;
            app.SolverSettingsButton.FontColor = [1 1 1];
            app.SolverSettingsButton.Position = [708 892 140 30];
            app.SolverSettingsButton.Text = 'Solver Settings';

            % Create InputsButton
            app.InputsButton = uibutton(app.UIFigure, 'push');
            app.InputsButton.ButtonPushedFcn = createCallbackFcn(app, @InputsButtonPushed, true);
            app.InputsButton.BackgroundColor = [0.1294 0.1804 0.4];
            app.InputsButton.FontSize = 18;
            app.InputsButton.FontColor = [1 1 1];
            app.InputsButton.Position = [211 892 110 30];
            app.InputsButton.Text = 'Inputs';

            % Create RcnlLogo
            app.RcnlLogo = uiimage(app.UIFigure);
            app.RcnlLogo.ImageClickedFcn = createCallbackFcn(app, @RcnlLogoImageClicked, true);
            app.RcnlLogo.Position = [11 872 80 80];
            app.RcnlLogo.ImageSource = fullfile(pathToMLAPP, '..', 'Images', 'rcnlIcon.png');

            % Create LoadSettingsFileButton
            app.LoadSettingsFileButton = uibutton(app.UIFigure, 'push');
            app.LoadSettingsFileButton.ButtonPushedFcn = createCallbackFcn(app, @LoadSettingsFileButtonPushed, true);
            app.LoadSettingsFileButton.BackgroundColor = [0.1294 0.1804 0.4];
            app.LoadSettingsFileButton.FontSize = 18;
            app.LoadSettingsFileButton.FontColor = [1 1 1];
            app.LoadSettingsFileButton.Position = [673 26 90 30];
            app.LoadSettingsFileButton.Text = 'Load';

            % Create SaveButton
            app.SaveButton = uibutton(app.UIFigure, 'push');
            app.SaveButton.ButtonPushedFcn = createCallbackFcn(app, @SaveButtonPushed, true);
            app.SaveButton.BackgroundColor = [0.1294 0.1804 0.4];
            app.SaveButton.FontSize = 18;
            app.SaveButton.FontColor = [1 1 1];
            app.SaveButton.Position = [793 26 90 30];
            app.SaveButton.Text = 'Save';

            % Create HelpButton
            app.HelpButton = uibutton(app.UIFigure, 'push');
            app.HelpButton.ButtonPushedFcn = createCallbackFcn(app, @HelpButtonPushed, true);
            app.HelpButton.BackgroundColor = [0.1294 0.1804 0.4];
            app.HelpButton.FontSize = 18;
            app.HelpButton.FontColor = [1 1 1];
            app.HelpButton.Position = [1033 27 90 30];
            app.HelpButton.Text = 'Help';

            % Create RunButton
            app.RunButton = uibutton(app.UIFigure, 'push');
            app.RunButton.ButtonPushedFcn = createCallbackFcn(app, @RunButtonPushed, true);
            app.RunButton.BackgroundColor = [0.1294 0.1804 0.4];
            app.RunButton.FontSize = 18;
            app.RunButton.FontColor = [1 1 1];
            app.RunButton.Enable = 'off';
            app.RunButton.Position = [913 26 90 30];
            app.RunButton.Text = 'Run';

            % Create ResetButton
            app.ResetButton = uibutton(app.UIFigure, 'push');
            app.ResetButton.ButtonPushedFcn = createCallbackFcn(app, @ResetButtonPushed, true);
            app.ResetButton.BackgroundColor = [0.1294 0.1804 0.4];
            app.ResetButton.FontSize = 18;
            app.ResetButton.FontColor = [1 1 1];
            app.ResetButton.Position = [555 26 90 30];
            app.ResetButton.Text = 'Reset';

            % Create ContextMenu
            app.ContextMenu = uicontextmenu(app.UIFigure);

            % Create RenameMenu
            app.RenameMenu = uimenu(app.ContextMenu);
            app.RenameMenu.MenuSelectedFcn = createCallbackFcn(app, @RenameMenuSelected, true);
            app.RenameMenu.Text = 'Rename';

            % Create CopyMenu
            app.CopyMenu = uimenu(app.ContextMenu);
            app.CopyMenu.MenuSelectedFcn = createCallbackFcn(app, @CopyMenuSelected, true);
            app.CopyMenu.Text = 'Copy';

            % Create DeleteMenu
            app.DeleteMenu = uimenu(app.ContextMenu);
            app.DeleteMenu.MenuSelectedFcn = createCallbackFcn(app, @DeleteMenuSelected, true);
            app.DeleteMenu.Text = 'Delete';

            % Assign app.ContextMenu
            app.CostTermsListTable.ContextMenu = app.ContextMenu;

            % Create ConstraintTermContextMenu
            app.ConstraintTermContextMenu = uicontextmenu(app.UIFigure);

            % Create ConstraintTermRenameMenu
            app.ConstraintTermRenameMenu = uimenu(app.ConstraintTermContextMenu);
            app.ConstraintTermRenameMenu.MenuSelectedFcn = createCallbackFcn(app, @ConstraintTermRenameMenuSelected, true);
            app.ConstraintTermRenameMenu.Text = 'Rename';

            % Create ConstraintTermCopyMenu
            app.ConstraintTermCopyMenu = uimenu(app.ConstraintTermContextMenu);
            app.ConstraintTermCopyMenu.MenuSelectedFcn = createCallbackFcn(app, @ConstraintTermCopyMenuSelected, true);
            app.ConstraintTermCopyMenu.Text = 'Copy';

            % Create ConstraintTermDeleteMenu
            app.ConstraintTermDeleteMenu = uimenu(app.ConstraintTermContextMenu);
            app.ConstraintTermDeleteMenu.MenuSelectedFcn = createCallbackFcn(app, @ConstraintTermDeleteMenuSelected, true);
            app.ConstraintTermDeleteMenu.Text = 'Delete';

            % Assign app.ConstraintTermContextMenu
            app.ConstraintTermsListTable.ContextMenu = app.ConstraintTermContextMenu;

            % Create MiscCostParameterContextMenu
            app.MiscCostParameterContextMenu = uicontextmenu(app.UIFigure);
            app.MiscCostParameterContextMenu.ContextMenuOpeningFcn = createCallbackFcn(app, @MiscCostParameterContextMenuOpening, true);

            % Create MiscCostParameterRenameMenu
            app.MiscCostParameterRenameMenu = uimenu(app.MiscCostParameterContextMenu);
            app.MiscCostParameterRenameMenu.MenuSelectedFcn = createCallbackFcn(app, @MiscCostParameterRenameMenuSelected, true);
            app.MiscCostParameterRenameMenu.Text = 'Rename';

            % Create MiscCostParameterDeleteMenu
            app.MiscCostParameterDeleteMenu = uimenu(app.MiscCostParameterContextMenu);
            app.MiscCostParameterDeleteMenu.MenuSelectedFcn = createCallbackFcn(app, @MiscCostParameterDeleteMenuSelected, true);
            app.MiscCostParameterDeleteMenu.Text = 'Delete';

            % Assign app.MiscCostParameterContextMenu
            app.MiscellaneousCostTermParametersTable.ContextMenu = app.MiscCostParameterContextMenu;

            % Create MiscConstraintParameterContextMenu
            app.MiscConstraintParameterContextMenu = uicontextmenu(app.UIFigure);
            app.MiscConstraintParameterContextMenu.ContextMenuOpeningFcn = createCallbackFcn(app, @MiscConstraintParameterContextMenuOpening, true);

            % Create MiscConstraintParameterRenameMenu
            app.MiscConstraintParameterRenameMenu = uimenu(app.MiscConstraintParameterContextMenu);
            app.MiscConstraintParameterRenameMenu.MenuSelectedFcn = createCallbackFcn(app, @MiscConstraintParameterRenameMenuSelected, true);
            app.MiscConstraintParameterRenameMenu.Text = 'Rename';

            % Create MiscConstraintParameterDeleteMenu
            app.MiscConstraintParameterDeleteMenu = uimenu(app.MiscConstraintParameterContextMenu);
            app.MiscConstraintParameterDeleteMenu.MenuSelectedFcn = createCallbackFcn(app, @MiscConstraintParameterDeleteMenuSelected, true);
            app.MiscConstraintParameterDeleteMenu.Text = 'Delete';

            % Assign app.MiscConstraintParameterContextMenu
            app.MiscellaneousConstraintTermParametersTable.ContextMenu = app.MiscConstraintParameterContextMenu;

            % The window is tall enough that a fixed corner runs off the
            % top of a 1080p display, so center it on whichever screen it
            % lands on before showing it
            movegui(app.UIFigure, 'center');

            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = TreatmentOptimizationBase

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