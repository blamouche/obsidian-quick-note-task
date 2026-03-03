# Contract: Folder Affordance Without Decorative Icon

## Scope
- Applies to UI surfaces showing destination folder selection/change controls.

## Required Outcomes
- Decorative folder icon is not displayed in targeted windows.
- Action remains explicit via text label and/or clear command wording.
- User can still select or change destination without extra steps.

## Blocked Outcomes
- Removing the icon must not remove or hide the folder action.
- Removing the icon must not reduce discoverability of destination settings.

## Regression Guarantees
- Destination picker flow remains unchanged.
- Invalid/missing destination recovery flow remains unchanged.
- Capture and settings flows keep their existing functional completion paths.
