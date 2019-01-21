# Changelog

All notable changes to this project will be documented in this file.

## Unreleased

### Added
  - *Field map* − After dragging a planting over a location which has
    sublocations for some time, it will expand if it is collapsed.
  - *Database* − Migration framework: start to cleanly migrate database schemas,
    setting a database version and writing a SQL script for each new database
    version. Each script will applied successively to reach the latest version.

### Fixed
  - Timegraph end harvest bar drawing (add one week).
  - Date update bug which prevented proper duration update.
  - Properly clean database before reset.

## 0.1.1 - 2019-01-10

### Fixed
  - AppImage building.

## 0.1 - 2019-01-09

First public release.
