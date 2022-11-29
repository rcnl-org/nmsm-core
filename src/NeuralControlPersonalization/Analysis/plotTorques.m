function plotTorques(jointNames, inputs, params)
muscleJointMoments = zeros(inputs.nPts, inputs.nJoints);
% net moment
for i = 1:inputs.nPts
    for j = 1:inputs.nJoints
        for k = 1:inputs.numMuscles
            FMT = calcMuscleTendonForce(aVals(i, k), ...
                inputs.muscleTendonLength(i, k), ...
                inputs.muscleTendonVelocity(i, k), k, inputs);
            r = inputs.rVals(i, k, j);
            muscleJointMoments(i, j) = muscleJointMoments(i, j) + r * FMT;
        end
    end
end
figure;
for i = 1:inputs.nJoints
    subplot(4, 4, i)
    plot(inputs.NCPtimePercent, inputs.IDmomentVals(:, i), 'k-', ...
        inputs.NCPtimePercent, muscleJointMoments(:, i));
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
