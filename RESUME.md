# RESUME — session handoff

Read **this + PRODUCT.md** (product source of truth) and you're caught up. Terse on purpose: **do not re-explore anything under DONE** — it is settled.

## Status — 2026-08-02
Working MVP baseline **on device. Music PLAYS.** Clean MusicKit rewrite is committed. Next real work = the Pilot.

## DONE — settled, do NOT re-derive
- Playback works via MusicKit `ApplicationMusicPlayer`.
- **The long "error 2" saga is SOLVED.** Cause: an old mock engine kept an active `AVAudioSession` (`.playback`) that fought the out-of-process system player → `MPMusicPlayerControllerErrorDomain error 2`. Fix: the app touches **no** `AVAudioSession`/`AVAudioPlayer` at all. Ruled out and NOT the cause (don't revisit): subscription, `playParameters`, provisioning / wildcard-vs-explicit profile, debugger launch, `SKCloudServiceController` capabilities.
- MVP flow done: auth → library playlists (loading/empty/error/retry) → playlist detail (Play + tap-to-play) → docked mini player → Now Playing (progress + seek, prev/play/next).

## Architecture — `App/`, XcodeGen, no DesignSystem, no asset catalog
- `App.swift` — @main + RootView: auth switch, mini-player overlay, NowPlaying sheet.
- `Auth/` — `MusicAuthModel` (authorization), `AuthGateView`.
- `Player/PlayerModel.swift` — the core. `ApplicationMusicPlayer` wrapper; a 400ms poll ticker mirrors state; `play(tracks:startingAt:)`, `togglePlayPause`, `skipToNext/Previous`, `seek`.
- `Library/` — `LibraryView` (playlists), `PlaylistDetailView` (tracks).
- `NowPlaying/` — `MiniPlayerBar`, `NowPlayingView`.
- `Shared/ArtworkView.swift` — MusicKit `ArtworkImage`.
- `project.yml` = source of truth; `.xcodeproj` git-ignored → `xcodegen generate`.

## Commands
```
xcodegen generate
xcodebuild -project BetterPlayer.xcodeproj -scheme BetterPlayer \
  -destination 'platform=iOS,id=B0AD521B-2BB6-5998-B447-F924D68DCF44' \
  -derivedDataPath build/DD -allowProvisioningUpdates build
xcrun devicectl device install app --device B0AD521B-2BB6-5998-B447-F924D68DCF44 \
  build/DD/Build/Products/Debug-iphoneos/BetterPlayer.app
```
- Playback test: **cold-launch from the home screen**, do NOT `devicectl process launch`.
- bundle `pl.konbini.betterplayer` · team `96A754WM9L` · device UDID `B0AD521B-2BB6-5998-B447-F924D68DCF44`.

## Rules
Greet "Konbini". Chat PL, code/docs EN. **Ask before push.** Conserve tokens, no subagents. **PRODUCT.md wins** every product conflict.

## Session cwd caveat
Claude Code session root is often `…/tanabata`; the shell resets there. Always operate on `/Users/konbinipolska/Projects/better-player` with absolute paths.

## NEXT — the Pilot (PRODUCT.md §2, top priority)
Today's mini-player + NowPlaying are plain placeholders. Build the real **Pilot**: ONE persistent capsule with `Standby → Compact → Expanded` as a single morphing object (`matchedGeometryEffect`), direct-manipulation gestures — drag up/down = expand/collapse (finger-tracking, interruptible), swipe L/R = next/prev (interruptible, reversible, velocity-aware, haptic at commit), tap body = expand, tap button = play/pause. Interaction **quality** must be validated, not just "works".

## Maintenance
Update this file's Status/DONE/NEXT after each push. Keep it compressed — append only what a fresh session must know; don't narrate solved work.
