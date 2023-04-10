%% Check struct2xml

x.XmlDocument.Attributes.Version = 'Version';
x.XmlDocument.XmlName.Attributes.name = 'Attribute Name';
x.XmlDocument.XmlName.PropertyOne.Comment = 'Some Comment';
x.XmlDocument.XmlName.PropertyOne.Text = 'Some Text';
x.XmlDocument.XmlName.Element{1}.Attributes.name = 'Attribute Name';
x.XmlDocument.XmlName.Element{1}.element_name.Comment = 'Some Comment';
x.XmlDocument.XmlName.Element{1}.element_name.Text = 'Some Text';
x.XmlDocument.XmlName.Element{2}.Attributes.name = 'Attribute Name';
x.XmlDocument.XmlName.Element{2}.element_name.Comment = 'Some Comment';
x.XmlDocument.XmlName.Element{2}.element_name.Text = 'Some Text';
assertNoException(struct2xml(x, "test.xml"));

%% Check osimx save

optimizedParams.electromechanicalDelays = [0.5];
optimizedParams.activationTimeConstants = [0.6];
optimizedParams.activationNonlinearityConstants = [0.5];
optimizedParams.emgScaleFactors = [0.6];
optimizedParams.optimalFiberLengthScaleFactors = [0.5];
optimizedParams.tendonSlackLengthScaleFactors = [0.6];

% writeMuscleTendonPersonalizationOsimxFile( ...
%     "arm26_one_muscle.osim", optimizedParams, "BRA", 'simple_model.osimx');

%% Check osimx parse and rewrite

osimx = parseOsimxFile("full_model.osimx");
newOsimx = buildOsimxFromOsimxStruct(osimx);
writeOsimxFile(newOsimx, "full_model2.osimx");
osimx2 = parseOsimxFile("full_model2.osimx");
assert(isequal(osimx, osimx2));

