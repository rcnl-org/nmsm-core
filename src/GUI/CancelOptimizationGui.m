function stop = CancelOptimizationGui(app, x, optimValues, state)

    stop = false;

    if app.cancelOptimization
        stop = true;
    end

    drawnow; % lets GUI process button presses

end