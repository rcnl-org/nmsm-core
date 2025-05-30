# Changelog

## v1.4.1 - 2025-05-30
### Fixed
- Reorder states when parsing initial values to account for initial/tracked quantities having a different order than the current states.
- Surrogate model now reads from surrogate_model_coordinate_list to choose whether a joint should be varied or not. 

### Changes
- All plotting functions have a central formatting function getPlottingParams()
- Synergy plotting function now plots synergy weights
- Added an option to plot joint positions in velocities in degrees or radians (useRadians=0 for degrees, 1 for radians)
- plotNcpResultsFromSettingsFile() now plots synergy controls
- The GUI now recognizes cost and constraint term fields <axes> and <sequence>
- The GUI now recognizes synergy Treatment Optimization fields load_surrogate_model, save_surrogate_model, synergy_vector_normalization_method, and synergy_vector_normalization_value

## v1.4.0 - 2025-04-24

### Added
- This release includes the first version of the NMSM Pipeline GUI for OpenSim. This allows users to create settings files compatible with all tools through the OpenSim GUI
	- Steps for installing the GUI are included in the `How to Install.pdf` document
- For GUI compatibility, Treatment Optimization cost and constraint terms using various components can now be formed on lists of components
	- Example: two coordinate tracking terms with `<coordinate>` elements can be combined into a single term with a space-separated `<coordinate_list>`
- Ground Contact Personalization (GCP) supports force plate rotation adjustment alongside the existing force plate electrical center location adjustment
- Many new cost and constraint terms have been added to Treatment Optimization tools
	- These include constraint forms of previously existing cost terms as well as terms based on new quantities such as body orientation and center of pressure
	- For the full list, review the documents `Cost Terms.pdf` and `Constraint Terms.pdf` included with this release
- Terms like marker or body orientation tracking that depend on axes now take an `<axes>` element where users specify some combination of X, Y, and Z
- Cost and constraint terms using external loads (including center of pressure) support a `<time_ranges>` element to limit the range of a term's application
	- Times are given as normalized time ranges, such as `<time_ranges>0.2 0.6</time_ranges>`, which would only apply a cost or constraint from 20% to 60% of a motion
	- This may be useful in cases such as constraining a vertical force to be close to zero only when a foot is required to be out of contact
	- Multiple time ranges may be used on a single term by giving multiple time pairs (Example: `<time_ranges>0 0.2 0.6 1</time_ranges>` to apply a term in the opposite of the above example range)
- Design Optimization (DO) supports user-defined constraint terms, with similar functionality available to user-defined cost terms
	- User-defined constraint terms have the signature `function constraintValue = function_name(values, modeledValues, inputs, costTerm)`
	- User-defined constraints can be either `path` or `terminal`, similar to how user-defined cost functions are `continuous` or `discrete`
- GCP and Treatment Optimiation save copies of optimized ground reactions in a center of pressure format for easy visualization in the OpenSim GUI


### Fixed
- Optimized ground reactions from GCP are saved with the column order expected by the OpenSim GUI
- .osimx files created by Model Personalization tools are printed with correct indentation for readability
- JMP safely handles absolute file paths given in the <output_model_file> element
- plotTreatmentOptimizationJointVelocities properly normalizes splined data points


### Changed
- On Windows machines, GCP is five to ten times faster by using precompiled functions for point kinematics analyses
- GCP handles motions that lift contact elements high above the ground more accurately with vertical force curve adjustments
- Treatment Optimization is significantly faster due to more efficent point kinematics analyses and improved indexing of modeled data
	- Speed is particularly improved for models with external loads


## v1.3.2 - 2024-10-28

### Added
- Treatment Optimization plotting function `plotTreatmentOptimizationResultsFromSettingsFile()` can optionally take an override results directory as a second argument to plot results from a directory other than the one in the given settings file


### Fixed
- Neural Control Personalization plots requiring multiple plot windows will correctly format overflow windows to match the first
- Prescribed coordinates in Design Optimization are saved to results correctly for free final time problems


### Changed
- Updated calls to the MATLAB `size()` function to prevent compatibility warning messages on MATLAB R2024a and newer


## v1.3.1 - 2024-10-01

### Added
- Marker tracking in Treatment Optimization (TO) can be used to track a subset of directions in the ground frame (default x, y, and z directions)
	- To change the included subset, add `<axes>true true true</axes>` with the first, second, or third entry set to `false` for an excluded direction
- TO synergy vectors can be used and saved normalized by either sum or magnitude of a given value (default sum to 1)
	- Inside the `<RCNLSynergyController>`, add `<synergy_vector_normalization_method>` set to `sum` or `magnitude` and add `<synergy_vector_normalization_value>` set to the desired vector sum or magnitude
- The root directory now includes installation instructions for the pipeline (`How to Install.pdf`)


### Fixed
- TO runs using point kinematics will no longer crash with OpenSim 4.5.1 linked to MATLAB
- TO marker tracking will track multiple markers correctly at the same time


### Changed
- Optimizing synergy vectors during TO is significantly faster
- TO plotting functions will automatically convert rotational input quantities from degrees when comparing to radians


## v1.3.0 - 2024-09-23

### Added
- Joint Model Personalization can scale point constraints with bodies
- Individual Muscle-Tendon Personalization (MTP) design variables can be included or excluded
- MTP supports a series of `<MTPTask>`s, setting up multiple-stage optimizations with individual sets of design variables and cost terms
- Plotting function `plotMtpHillTypeMuscleParamsCompare()` can compare sets of muscle parameters optimized by MTP
- Ground Contact Personalization (GCP) can optimize a change in experimental electrical center values to correct for force plate errors and produce ground reaction moments more consistent with physical models
	- Individual electrical center shift dimensions can be added as design variables `<electricalCenterX>`, `<electricalCenterY>`, and `<electricalCenterZ>`
	- Electrical center adjustment can be regularized with the `electrical_center_shift` cost term
	- An updated version of the experimental ground reactions file will be saved with the new electrical center
- GCP saves updated full-body kinematics and modeled ground reactions with modified foot motion if all `<GCPContactSurface>`s have the same time range
- GCP kinematic periodicity relative to experimental motion can be enforced with the new `kinematic_periodicity` cost term
- Model personalization plot windows have titles indicating the data displayed
- Treatment Optimization (TO) now uses a `tracked_quantities_directory` for experimental data or data to track and an `initial_guess_directory` for initial values
	- Missing intial guess values will be copied from tracked quantities, and missing quantities to track will be copied from initial guess data if available
- TO states and controls can optionally have minimum search bounds set in addition to search scale factors
	- Fields ending in `scale_factor` have an equivalent `minimum_range`
- TO cost calculations can be normalized within individual cost term types instead of by the total number of cost terms by setting the optional `<normalize_cost_by_term_type>` to true 
- New TO cost terms: 
	- Controller shape tracking
	- Controller minimization
	- Scaled controller tracking
		- Adding a `<scale_factor>` to a `controller_tracking` cost term will track a scaled version of the reference control
- User-defined TO model functions can be used to modify either an element of the OpenSim model or part of the states or controls
	- This allows users to create their own rules for modifying states or controls with custom parameters or feedback mechanisms before model dynamics are calculated
- TO joint velocities can be plotted with the `plotTreatmentOptimizationJointVelocities()` function
- New plotting functions for all tools will plot relevant results from settings files when run in the same directory as the settings file. Functions include:
	- `plotJmpResultsFromSettingsFile()`
	- `plotMtpResultsFromSettingsFile()`
	- `plotNcpResultsFromSettingsFile()`
	- `plotGcpResultsFromSettingsFile()`
	- `plotTreatmentOptimizationResultsFromSettingsFile()`
- Using the OpenSim 4.5.1 API linked with MATLAB is now supported


### Fixed
- MTP plots can properly display absolute length adjustments from Muscle-Tendon Length Initialization
- GCP updates tracked experimental ground reaction moments to use the modified spring resting length for consistency


### Changed
- GCP rotation tracking allowable error should now be given in radians to be consistent with TO cost terms
- Plot visuals have been improved and made more consistent between tools with new MATLAB grid features
- TO computes metabolic cost with a MATLAB implementation of a Bhargava metabolic cost model


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
