function plotTorques(torqueVals, jointNames, inputs, params)
figure;
for i = 1:inputs.nJoints
    subplot(4, 4, i)
    plot(inputs.NCPtimePercent, inputs.IDmomentVals(:, i), 'k-', ...
        inputs.NCPtimePercent, torqueVals(:, i));
    hold all
    if rem(i, 4) == 1
        ylabel('Joint Torque (Nm)');
    end
    title(jointNames{i})
    if i == 4
        legend('ID', 'NCP');
    end
end
end
