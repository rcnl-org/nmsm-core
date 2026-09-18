classdef ObjectSelectionWindow < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure                matlab.ui.Figure
        FilterByEditField       matlab.ui.control.EditField
        FilterByEditFieldLabel  matlab.ui.control.Label
        ObjectTable             matlab.ui.control.Table
        CloseButton             matlab.ui.control.Button
        OKButton                matlab.ui.control.Button
        ContextMenu             matlab.ui.container.ContextMenu
        EnableAllSelectedMenu   matlab.ui.container.Menu
        DisableAllSelectedMenu  matlab.ui.container.Menu
    end

    
    properties (Access = private)
        ParentApp
        MasterObjectNames
        MasterIsEnabled
    end
    
    methods (Access = private)
        
        function syncMasterData(app)
            visibleObjectNames = app.ObjectTable.Data.objectNames;
            unfilteredIndices = ismember(app.MasterObjectNames, ...
                visibleObjectNames);
            app.MasterIsEnabled(unfilteredIndices) = app.ObjectTable.Data.isEnabled;
        end
    end
    

    % Callbacks that handle component events
    methods (Access = private)

        % Code that executes after component creation
        function startupFcn(app, ParentApp, ObjectList, EditedProperty)
            app.ParentApp = ParentApp;

            objectNames = ObjectList(:);
            isEnabled = false(numel(objectNames), 1);

            if ~isempty(EditedProperty)
                isEnabled = ismember(objectNames, EditedProperty);
            end

            app.MasterObjectNames = objectNames;
            app.MasterIsEnabled = isEnabled;


            app.ObjectTable.Data = table(objectNames, isEnabled);

            app.ObjectTable.ColumnEditable = [false true];
            app.ObjectTable.ColumnWidth = {'auto' 100};
            app.ObjectTable.SelectionType = 'row';
        end

        % Button pushed function: OKButton
        function OKButtonPushed(app, event)
            selectedObjects = app.MasterObjectNames(app.MasterIsEnabled);

            app.ParentApp.setSelectedObjects(selectedObjects);

            delete(app.UIFigure);
        end

        % Button pushed function: CloseButton
        function CloseButtonPushed(app, event)
            delete(app.UIFigure);
        end

        % Value changed function: FilterByEditField
        function FilterByEditFieldValueChanged(app, event)
            filterKeyword = app.FilterByEditField.Value;
            
            filteredIndices = contains(app.MasterObjectNames, filterKeyword, ...
                "IgnoreCase",true);

            objectNames = app.MasterObjectNames(filteredIndices);
            isEnabled = app.MasterIsEnabled(filteredIndices);

            app.ObjectTable.Data = table(objectNames, isEnabled);
        end

        % Menu selected function: EnableAllSelectedMenu
        function EnableAllSelectedMenuSelected(app, event)
            selectedRows = app.ObjectTable.Selection;

            app.ObjectTable.Data.isEnabled(selectedRows) = true;

            app.syncMasterData();
        end

        % Menu selected function: DisableAllSelectedMenu
        function DisableAllSelectedMenuSelected(app, event)
            selectedRows = app.ObjectTable.Selection;

            app.ObjectTable.Data.isEnabled(selectedRows) = false;

            app.syncMasterData();
        end

        % Cell edit callback: ObjectTable
        function ObjectTableCellEdit(app, event)
            app.syncMasterData();
        end

        % Callback function
        function EnableAllVisibleCheckBoxValueChanged(app, event)
           app.ObjectTable.Data.isEnabled = true(numel(app.ObjectTable.Data.isEnabled), 1);
           app.syncMasterData();
        end
    end

    % Component initialization
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Create UIFigure and hide until all components are created
            app.UIFigure = uifigure('Visible', 'off');
            app.UIFigure.Color = [0.851 0.851 0.851];
            app.UIFigure.Position = [500 500 479 480];
            app.UIFigure.Name = 'MATLAB App';
            app.UIFigure.WindowStyle = 'modal';

            % Create OKButton
            app.OKButton = uibutton(app.UIFigure, 'push');
            app.OKButton.ButtonPushedFcn = createCallbackFcn(app, @OKButtonPushed, true);
            app.OKButton.BackgroundColor = [0.1294 0.1804 0.4];
            app.OKButton.FontSize = 18;
            app.OKButton.FontColor = [1 1 1];
            app.OKButton.Position = [254 13 85 30];
            app.OKButton.Text = 'OK';

            % Create CloseButton
            app.CloseButton = uibutton(app.UIFigure, 'push');
            app.CloseButton.ButtonPushedFcn = createCallbackFcn(app, @CloseButtonPushed, true);
            app.CloseButton.BackgroundColor = [0.1294 0.1804 0.4];
            app.CloseButton.FontSize = 18;
            app.CloseButton.FontColor = [1 1 1];
            app.CloseButton.Position = [383 13 85 30];
            app.CloseButton.Text = 'Close';

            % Create ObjectTable
            app.ObjectTable = uitable(app.UIFigure);
            app.ObjectTable.ColumnName = {'Object'; 'Enabled'};
            app.ObjectTable.RowName = {};
            app.ObjectTable.CellEditCallback = createCallbackFcn(app, @ObjectTableCellEdit, true);
            app.ObjectTable.Position = [38 53 404 376];

            % Create FilterByEditFieldLabel
            app.FilterByEditFieldLabel = uilabel(app.UIFigure);
            app.FilterByEditFieldLabel.HorizontalAlignment = 'right';
            app.FilterByEditFieldLabel.Position = [97 447 49 22];
            app.FilterByEditFieldLabel.Text = 'Filter By';

            % Create FilterByEditField
            app.FilterByEditField = uieditfield(app.UIFigure, 'text');
            app.FilterByEditField.ValueChangedFcn = createCallbackFcn(app, @FilterByEditFieldValueChanged, true);
            app.FilterByEditField.Position = [161 447 232 22];

            % Create ContextMenu
            app.ContextMenu = uicontextmenu(app.UIFigure);

            % Create EnableAllSelectedMenu
            app.EnableAllSelectedMenu = uimenu(app.ContextMenu);
            app.EnableAllSelectedMenu.MenuSelectedFcn = createCallbackFcn(app, @EnableAllSelectedMenuSelected, true);
            app.EnableAllSelectedMenu.Text = 'Enable All Selected';

            % Create DisableAllSelectedMenu
            app.DisableAllSelectedMenu = uimenu(app.ContextMenu);
            app.DisableAllSelectedMenu.MenuSelectedFcn = createCallbackFcn(app, @DisableAllSelectedMenuSelected, true);
            app.DisableAllSelectedMenu.Text = 'Disable All Selected';
            
            % Assign app.ContextMenu
            app.ObjectTable.ContextMenu = app.ContextMenu;

            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';

            % The window is tall enough that a fixed corner runs off the
            % top of a 1080p display, so center it on whichever screen it
            % lands on before showing it
            movegui(app.UIFigure, 'center');
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = ObjectSelectionWindow(varargin)

            % Create UIFigure and components
            createComponents(app)

            % Register the app with App Designer
            registerApp(app, app.UIFigure)

            % Execute the startup function
            runStartupFcn(app, @(app)startupFcn(app, varargin{:}))

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