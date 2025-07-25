# ClinicalChain

A decentralized clinical trial registry and protocol management system for medical research on Stacks blockchain.

## Features

- Clinical trial registration with comprehensive protocol documentation
- Investigator participant management and validation
- Trial phase classification system
- Study type specification and tracking
- Enrollment status management and completion workflow

## Smart Contract Functions

### Public Functions
- `register-trial` - Register new clinical trial with protocol
- `complete-enrollment` - Complete trial enrollment (investigator only)

### Read-Only Functions
- `get-trial` - Get clinical trial details
- `get-investigator` - Get trial investigator information
- `get-total-trials` - Get total registered trials
- `get-enrollment-status` - Get trial enrollment status

## Trial Phases
- Preclinical, Phase I, Phase II, Phase III, Phase IV, Observational

## Study Types
- RCT, Cohort, Case-Control, Cross-Over, Pilot

## Usage

Deploy the contract to create a clinical trial registry where investigators can register studies and track participant enrollment throughout the research process.

## License

MIT