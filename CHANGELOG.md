# Changelog

## v1.2.0 - 2024-05-09

### Added
- MTP can now use translational coordinates spanned by muscles.
- Added a plotting function to show the distribution of spring stiffnesses in GCP.

### Fixed
- Fixed a bug where Treatment Optimization tracking terms were using the wrong time array
- MTP now properly saves passive model moments when input passive moment data has multiple columns with non-zero data.
- Fixed a bug with plotting JMP results where the marker names ordering was not respected.
- Fixed a bug with GCP damping terms not being applied correctly.
- Fixed a bug where the wrong muscle tendon length file was parsed in Treatment Optimization.
- Fixed a bug with the incorrect time array being used for the initial guess and dependency finding steps of Treatment Optimization.

### Changed
- Treatment Optimization now no longer splines results back to the initial time points, instead using the collocation time points as the final results. This reduces numerical inconsistencies between the tracking and verification steps.
- Some Treatment Optimization plotting functions have been improved.
- The surrogate model has been sped up.
- The surrogate model now uses an independent data directory. A script has been added (`src/SurrogateModelCreation/surrogateKinematicsScript.m`) to generate Latin hypercube sample (LHS) kinematics for the surrogate model. This improves accuracy when finding novel motion.
- .sto file parsing has been sped up.
- Improved the quality of the Treatment Optimization initial guess.
- Changed the way Treatment Optimization results are saved to make VO easier.

### Changes
- MTP, NCP, & GCP plots with multiple lines now follow the color convention: blue for experimental/tracked data, and orange for modeled data.

## v1.1.0 - 2024-03-10

### Added
- Joint Model Personalization (JMP) tasks can contain a `<marker_list>` explicitly naming markers to track
- Plotting functions for Muscle Tendon Personalization (MTP)
- Plotting function for overall variability accounted for (VAF) and activation RMS error for Neural Control Personalization (NCP)
- Treatment Optimization can use both torque and synergy controllers, as well as both types in the same Model
- Treatment Optimization can modify a subset of model coordinates, taking prescribed values from input data for others
- Synergy-driven Treatment Optimization can optionally adjust synergy vectors
- Synergy-driven Treatment Optimization tools automatically create surrogate polynomial muscle models instead of requiring a separate tool
- Design Optimization can solve open/free final time problems
- New Treatment Optimization cost terms: 
	- Marker position tracking
	- Joint power minimization
	- Joint energy generation goal
	- Joint energy absorption goal
	- Propulsive impulse goal
	- Braking impulse goal
	- Muscle activation minimization
	- External torque control minimization
	- Whole body angular momentum minimization
	- Relative walking speed goal
	- Relative metabolic cost per time
	- Relative metabolic cost per distance traveled
- New Treatment Optimization constraint terms: 
	- Initial state position
	- Limit muscle activation
	- Limit normalized fiber Length
	- Synergy weight sum
- Plotting functions for Treatment Optimization results


### Fixed
- JMP preserves all joint parameters through multiple tasks
- Muscle-Tendon Length Initialization tracks passive data with extra muscle analysis files present
- NCP accurately tracks joint moments with multiple synergy groups


### Changed
- Ground Contact Personalization (GCP) defines a contact surfaces with a `<hindfoot_body>` instead of a `<toes_coordinate>` or `<toes_joint>` in XML
- Treatment Optimization (Tracking, Verification, and Design Optimization) settings have changed significantly due to changes to how states and controls are handled
- Treatment Optimization uses GCV splines to fit data instead of B-splines
- Treatment Optimization includes coordinate accelerations in controls instead of coordinate jerks
