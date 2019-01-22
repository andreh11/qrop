# Changelog

All notable changes to this project will be documented in this file.

## Unreleased

### Added
  - Keyboard shortcuts for the most common actions (see user guide in the wiki
   for more details).
  - *Settings* − Add restart snackbar.
  - *Planting form* − Add a checkbox for duration fields to enable or disable
    date calculation from durations. Add setting options to enable or disable
    durations by default and to hide duration fields.
  - *Plantings view* − Show an icon for greenhouse crops.
  - *Field map* − After dragging a planting over a location which has
    sublocations for some time, it will expand if it is collapsed.
  - *Database* − Migration framework: start to cleanly migrate database schemas,
    setting a database version and writing a SQL script for each new database
    version. Each script will applied successively to reach the latest version.

### Changed
  - Update French translation.

### Fixed
  - *Planting view* - Properly set greenhouse checkbox state.
  - *Plantings view* − Timegraph end harvest bar drawing (add one week).
  - *Planting form* − Date update bug which prevented proper duration update.
  - Properly clean database before reset.

## 0.1.1 - 2019-01-10

### Fixed
  - AppImage building.

## 0.1 - 2019-01-09

First public release.
