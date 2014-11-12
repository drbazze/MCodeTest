MCodeTest Application

Key features:
1. Search in itunes tracks + error handling
2. Image downloading in background + cache
3. Smooth table scroll with image downloads in background (threading)
4. Playable tracks
5. Variable animations through phone settings (settings bundle)
6. Alerts for network events

Strategy:
1. MVC with little KVO
2. Download images in background thread. If the user scroll the table and an image is not downloaded yet, then cancel the operation.
3. Addign some UX (animations, player)
4. Addign some UI (backgrounds, colors)

Further development opportunities:
1. Offline mode and reachability events
2. Core data result saves for offline mode
3. Orderable results
4. More customizations through settings
5. Universal app
