# Better Player

A radically minimal, native Apple Music player for iOS. Its reason to exist: a
best-in-class **scrub interaction on the mini-player pill** (flick to change
track, press-and-hold to seek with a video-player-style vertical speed
multiplier) plus a drastically simplified, "terminal × iOS 18" design.

> Working title. Apple Music only for now; the architecture keeps a
> provider seam so Spotify (and Apple/Spotify/**Mixed** playlists) can be added
> later without a rewrite.

## Requirements

- Xcode 26+ (iOS 17 deployment target)
- [XcodeGen](https://github.com/yonipeter/XcodeGen) (`brew install xcodegen`)
- An Apple Developer account signed into Xcode, and an active Apple Music
  subscription for on-device playback testing.

## Getting started

```bash
xcodegen generate       # regenerate BetterPlayer.xcodeproj from project.yml
open BetterPlayer.xcodeproj
```

The `BetterPlayer.xcodeproj` is generated (git-ignored); **`project.yml` is the
source of truth**. Re-run `xcodegen generate` after adding files or changing
build settings.

## Layout

```
project.yml                     XcodeGen spec (source of truth)
App/                            iOS app target
  Core/                         provider seam (MusicProvider)
  Features/                     Playlists · Search · NowPlaying (+ the pill)
Packages/
  DesignSystem/                 tokens + components — the single source of truth
```

## Design system

`DesignSystem` is a standalone Swift package (builds & tests headless):

```bash
cd Packages/DesignSystem && swift test
```

## Status

Phase 0 (scaffold) — project builds and runs a three-tab shell with the static
mini-player pill. See the plan for the full roadmap.
