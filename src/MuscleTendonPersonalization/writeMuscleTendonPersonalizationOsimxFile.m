% This function is part of the NMSM Pipeline, see file for full license.
%
% This function prints out the optimized muscle tendon parameters in an
% osimx file
%
% (string, 2D matrix, string) -> (None) 
% Prints MuscleTendonPersonalization results in osimx file

% ----------------------------------------------------------------------- %
% The NMSM Pipeline is a toolkit for model personalization and treatment  %
% optimization of neuromusculoskeletal models through OpenSim. See        %
% nmsm.rice.edu and the NOTICE file for more information. The             %
% NMSM Pipeline is developed at Rice University and supported by the US   %
% National Institutes of Health (R01 EB030520).                           %
%                                                                         %
% Copyright (c) 2021 Rice University and the Authors                      %
% Author(s): Marleny Vega                                                 %
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

function writeMuscleTendonPersonalizationOsimxFile(modelFileName, ...
    optimizedParams, muscleModelFileName)

model = Model(modelFileName);
muscleColumnNames = getMusclesInOrder(model);

MTP.OpenSimDocument.Attributes.Version = '40000';
MTP.OpenSimDocument.OsimxModel.Attributes.name = replace(model.getName.toCharArray',".","_dot_");
MTP.OpenSimDocument.OsimxModel.associated_osim_model.Comment = 'Full path of the associated osim model';
MTP.OpenSimDocument.OsimxModel.associated_osim_model.Text = modelFileName;
MTP.OpenSimDocument.OsimxModel.MTPMuscleSet.Comment = ['Optimized muscle ' ...
    'parameters'];
for i = 1:size(muscleColumnNames, 2)
    MTP.OpenSimDocument.OsimxModel.MTPMuscleSet.objects.RCNLMuscle{i}. ...
        Attributes.name = muscleColumnNames{i};
    MTP.OpenSimDocument.OsimxModel.MTPMuscleSet.objects.RCNLMuscle{i}. ...
        electromechanical_delay.Comment = ['Optimized ' ...
        'electronmechanical delay'];
    MTP.OpenSimDocument.OsimxModel.MTPMuscleSet.objects.RCNLMuscle{i}. ...
        electromechanical_delay.Text = num2str(optimizedParams(1, i));
    MTP.OpenSimDocument.OsimxModel.MTPMuscleSet.objects.RCNLMuscle{i}. ...
        activation_time_constant.Comment = ['Optimized activation ' ...
        'time constant'];
    MTP.OpenSimDocument.OsimxModel.MTPMuscleSet.objects.RCNLMuscle{i}. ...
        activation_time_constant.Text = num2str(optimizedParams(2, i));
    MTP.OpenSimDocument.OsimxModel.MTPMuscleSet.objects.RCNLMuscle{i}. ...
        activation_nonlinearity_constant.Comment = ['Optimized ' ...
        'activation nonlinearity constant'];
    MTP.OpenSimDocument.OsimxModel.MTPMuscleSet.objects.RCNLMuscle{i}. ...
        activation_nonlinearity_constant.Text = num2str( ...
        optimizedParams(3, i));
    MTP.OpenSimDocument.OsimxModel.MTPMuscleSet.objects.RCNLMuscle{i}. ...
        emg_scale_factor.Comment = 'Optimized EMG scaling factor';
    MTP.OpenSimDocument.OsimxModel.MTPMuscleSet.objects.RCNLMuscle{i}. ...
        emg_scale_factor.Text = num2str(optimizedParams(4, i));
    MTP.OpenSimDocument.OsimxModel.MTPMuscleSet.objects.RCNLMuscle{i}. ...
        optimal_fiber_length_scale_factor.Comment = ['Optimized ' ...
        'optimal fiber length scaling factor'];
    MTP.OpenSimDocument.OsimxModel.MTPMuscleSet.objects.RCNLMuscle{i}. ...
        optimal_fiber_length_scale_factor.Text = num2str( ...
        optimizedParams(5, i));
    MTP.OpenSimDocument.OsimxModel.MTPMuscleSet.objects.RCNLMuscle{i}. ...
        slack_tendon_length_scale_factor.Comment = ['Optimized ' ...
        'slack tendon length scaling factor'];
    MTP.OpenSimDocument.OsimxModel.MTPMuscleSet.objects.RCNLMuscle{i}. ...
        slack_tendon_length_scale_factor.Text = num2str( ...
        optimizedParams(6, i));
end
MTP.OpenSimDocument.OsimxModel.MTPMuscleSet.groups = '';
struct2xml_modified(MTP,muscleModelFileName)
copyfile(muscleModelFileName, fullfile(strrep(muscleModelFileName, ...
    'xml','osimx')))
delete(muscleModelFileName) 
end