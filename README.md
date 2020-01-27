# Campus
Social Media app for a college

# Building
The project uses Cocoapods. Before building run "pod install" in the project directory and use the Workspace

## Notable Cocoapods
1. ViewDeck - the side menu
2. RKNotificationHub - Notification badges for UIViews
3. IQKeyboardManagerSwift - Automatically moves text fields above the keyboard

## Technical Debt
1. Requests are not paged - everything is requested and expected as one (potentially huge) JSON
2. Massive Storyboard - The project started much simpler in scope and was implemented within a single storyboard with segues. It suddenly received a bunch of extra requirements towards the end which were crammed inside the same Storyboard. Can be optimized by either braking it down or better, moving some of the reused controllers to nibs
3. Very little caching


# TODOs
1. Search the project for 'TODO:' to get some ideas for further improvement

## Credits
Josh Naylor - zetplaner@gmail.com
