# ED247 for Simulink

## Ongoing

### Fixed

- Increase maximum A429 messages in a stream to 512 (was 128)
- MATLAB crash during code generation with SLREALTIME.tlc


## v2.0.0-RC5 - 2021/06/24 - R2020b



## v2.0.0-RC3 - 2021/05/27 - R2020b

### Changed
- Refresh option for Send block (was disabled)

### Fixed
- Read XML : Increase the maximum signals (was 50)
- Read XML : Add defensive code to avoid MATLAB crashes

## v2.0.0-RC2 - 2021/05/20 - R2020b

### Added
- Speedgoat support

## v2.0.0-RC1 - 2021/05/13 - R2019b

### Added
- MATLAB/Simulink Projects to manage source files
- Toolbox packaging to share to end-users

### Changed
- Configuration stored in a text file (.metadata)

### Removed
- Dependencies (ED247, LibXML2) moved outside of the project