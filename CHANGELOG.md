# Changelog

All notable changes to this project will be documented in this file.

## Unreleased

### Added
  - Add print output for crop plan, task calendar, field map, harvests, seed and
    transplant lists.
  - Add a view for seed and planting lists to make it easier to order them.
  - *Planting view* - Shift selection of planting intervals with mouse or keyboard.
  - *Field map* − Add button show family or crop color.
  - Basic note taking feature for plantings.
  - Harvest page.
  - Standardized beds mode: user can now define a standard bed length, and use
    this length as a unit for planting lengths.
  - *Field map* − Add greenhouse filter mode to only show greenhouse locations
    and plantings. Add a new shortcut for this mode (Ctrl+G).
  - *Field map* − Add a button to show planting conflicts on a location.
    Clicking on the button will open a menu select a conflicting planting and
    either edit, unassign or split the planting if there is remaining space on
    the location.
  - *Field map* − Add an “assign to block” feature: when dropping a planting on
   a location which has sublocations, assign the planting to the sublocations,
    checking for available space if planting conflicts aren't authorized.
  - *Field map* − Add option to allow planting conflicts on the same location.
  - *Field map* − Add option to show full name of locations.

### Changed
  - *Planting form* : it is now possible to bulk edit keywords.
  - The year now begins with winter instead of spring.
  - *Timeline* − For week date format, don't show year indicators < and > anymore.

### Fixed
  - *Planting form* : when (bulk) editing planting(s), if the length, the number 
    of rows or the in-row spacing have changed, recompute the number of plants 
    needed for each planting.
  - *Planting view/form*: when creating a planting for which locations has been 
    selected, the locations are now immediately visible in the planting view.
  - *Planting form*: fields are now always visible when nagivating with tab.
  - Deployment error  on Linux.

## 0.1.2 − 2019-01-23

### Added
  - *Field map* − Add button, menu and shortcuts to expand/collapse location level.
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
  - *Field map* − Attach show/hide button to the plantings pane.
  - Update French translation.

### Fixed
  - *Planting view* - Properly set greenhouse checkbox state.
  - *Plantings view* − Timegraph end harvest bar drawing (add one week).
  - *Planting form* − Date update bug which prevented proper duration update.
  - ComboBox: fix popup scrollbar.
  - Properly clean database before reset.

## 0.1.1 - 2019-01-10

### Fixed
  - AppImage building.

## 0.1 - 2019-01-09

First public release.
