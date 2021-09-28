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
	params.excludedMarkers = ["Sternum", "Top.Head"]
	params.markerWeights = struct("R.Acromium", 10.0, "L.Acromium", 0.1)
	params.coordinateTasks = struct("mtp_angle_r", struct("weight", 1000.0), ...
									"mtp_angle_l", struct("weight", 100.0))
	params.accuracy = 1.0