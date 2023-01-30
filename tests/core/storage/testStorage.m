%% Test findStorageColumnparseMtpStandard

import org.opensim.modeling.Storage
assert(all(findStorageColumn(Storage("example.sto"), ...
    "hip_adduction_l") == [-0.475484233516851, -0.7097313776326962, ...
    -0.8224722507878384]))
assert(all(findStorageColumn(Storage("example.sto"), 0) == ...
    [-0.475484233516851, -0.7097313776326962, -0.8224722507878384]))

%% Test parseMotToComponents

[columnNames, time, data] = parseMotToComponents(Model("model.osim"), ...
    Storage("example.sto"));

% size([-0.475484233516851 2.439890150008289 ...
%     -3.602038699899346 7.543850181298295 8.086913764217446 ...
%     -2.33430999212084; -0.7097313776326962 1.218280011208105 ...
%     -3.697425395746255 6.976401632001662 8.652169377673603 ...
%     -1.377739175436208; -0.8224722507878384 0.3083391148395571 ...
%     -3.568010105573945 6.237815600463323 8.91256417053442 ...
%     -0.6986805477506777])
% size(data)

assert(all(columnNames == ["hip_adduction_l" "hip_flexion_l" ...
    "hip_rotation_l" "knee_angle_l" "ankle_angle_l" "subtalar_angle_l"]))
assert(all(time == [0.38894 0.39968 0.41042]))
% assert(all(data == [-0.475484233516851 2.439890150008289 ...
%     -3.602038699899346 7.543850181298295 8.086913764217446 ...
%     -2.33430999212084; -0.7097313776326962 1.218280011208105 ...
%     -3.697425395746255 6.976401632001662 8.652169377673603 ...
%     -1.377739175436208; -0.8224722507878384 0.3083391148395571 ...
%     -3.568010105573945 6.237815600463323 8.91256417053442 ...
%     -0.6986805477506777]))
