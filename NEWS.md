# ctsApp 0.2.0

## New Features
- **Default simulation results**: Added pregenerated default simulation results for faster initial app loading and demonstration purposes
- **Input simulation saving/loading**: Users can now save and load simulation input configurations for reuse
- **Enhanced snapshot import logic**: Improved compound, formulation, and protocol snapshot import functionality with better error handling and user experience

## Improvements
- **Plotly visualization enhancements**: Significantly improved interactive plots for DDI and PK results with better styling, responsiveness, and user interaction
- **Demographics plots**: Enhanced summary plots with improved demographics visualization and styling
- **Results plot styling**: Better visual presentation of simulation results with improved colors, layouts, and formatting
- **PK parameters information**: Added detailed information display for pharmacokinetic parameters in results
- **Summary interface**: Streamlined summary panel by removing unnecessary header elements

## Bug Fixes
- Fixed PK parameters calculation and display issues
- Improved error handling in snapshot import processes
- Enhanced input validation for simulation parameters

# ctsApp 0.1.0

- Initial alpha release of the ctsApp Shiny application for clinical trial simulation of drug-drug interactions (DDIs).
- Features an interactive interface to the cts framework, focused on oral contraceptive DDI scenarios.
- Supports selection and configuration of both "victim" and "perpetrator" compounds from curated models.
- Allows detailed customization of dosing protocols (oral, IV, single/multiple dosing) and formulations for each compound.
- Enables definition of population parameters for individual or population-based simulations.
- Provides control over simulation parameters such as duration and output resolution.
- One-click simulation execution integrating all user-defined settings.
- Summary panel displays a comprehensive overview of all selected simulation building blocks.
- Results are presented in tabbed panels, including pharmacokinetic profiles and DDI analysis.
- Includes About section and links to documentation, code repository, issue reporting, and contact.
