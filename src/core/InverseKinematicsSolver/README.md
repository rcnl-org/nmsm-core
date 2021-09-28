The makeInverseKinematicsSolver function takes inputs and params to create the
correct InverseKinematicSolver for use.

The arguments include:
model - the loaded Model for use with the Solver
markerFileName - the string filename of the marker data
params - struct of parameters for the IKSolver

params:
	excludedMarkers - 1D array of strings (names)
	markerWeights - struct of marker names as field and weights as values
					only include non-'one' valued marker weights
	coordinateTasks - struct of coordinates as fields and a struct as values
					  the inner struct has attribute field/value pairs
	accuracy - number - the accuracy of the IKSolver 
	
example arguments:

IKSolver = makeInverseKinematicsSolver(Model(modelfilename), markerfilename, params)
	
example params:
	params.excludedMarkers = ["marker1", "marker4"]
	params.markerWeights = struct("marker3", 10.0, "marker2", 0.1)
	params.coordinateTasks = struct("coordinate1", struct("weight", 1000.0), ...
									"coordinate2", struct("weight", 100.0))
	params.accuracy = 1.0