MCodeTest Application
=====================

Key features:
- Search in itunes tracks + error handling
- Image downloading in background + cache
- Smooth table scroll with image downloads in background (threading)
- Playable tracks
- Variable animations through phone settings (settings bundle)
- Alerts for network events

Strategy:
- MVC with little KVO
- Download images in background thread. If the user scroll the table and an image is not downloaded yet, then cancel the operation.
- Addign some UX (animations, player)
- Addign some UI (backgrounds, colors)

Further development opportunities:
- Offline mode and reachability events
- Core data result saves for offline mode
- Orderable results
- More customizations through settings
- Universal app
