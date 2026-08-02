# Product Source of Truth

This document defines the product direction, interaction model, priorities, and non-negotiable principles of the app.

If implementation, design, or feature decisions conflict with this document, this document wins unless it is explicitly updated.

## 1. Product

A minimal, fast, tactile music player built around Apple Music.

The app is not intended to replicate Apple Music.

It exists to make listening to an existing music library:

* faster,
* simpler,
* more direct,
* more tactile,
* more consistent across devices.

The user already has music.
The app's job is not to help them discover what exists.
The app's job is to make getting to and controlling that music feel effortless.

## 2. Core Product Thesis

The most important element of the entire product is the Pilot.

The Pilot is a persistent playback control surface presented as a compact capsule, primarily positioned at the bottom of the interface.

The rest of the application is built around it.

```text
THE CONTENT TELLS THE USER
WHAT THEY CAN PLAY.

THE PILOT TELLS THE USER
WHAT IS HAPPENING NOW.
```

The Pilot is not:

* a mini player,
* a toolbar,
* a navigation bar,
* an accessory added to content screens.

The Pilot is the primary interaction surface of the app.

## 3. Product Priority

When product decisions conflict, use this hierarchy:

```text
1. PILOT EXPERIENCE
2. PLAYBACK CONTINUITY
3. SPEED OF INTERACTION
4. CONTENT
5. LIBRARY NAVIGATION
6. SECONDARY FEATURES
```

If improving a playlist screen makes the Pilot worse, the Pilot wins.
If visual consistency makes interaction slower, interaction wins.
If adding a feature introduces friction into the core playback experience, the feature loses.

## 4. Primary User

The intended user:

* listens to music frequently,
* already maintains playlists or a music library,
* uses Apple Music,
* understands standard Apple interface patterns,
* is comfortable with common gestures,
* does not need basic interface concepts explained,
* regularly moves between devices.

Typical listening surfaces:

```text
iPhone
iPad
Mac
CarPlay
Apple TV
```

The user does not think:
I am now using the iPhone version of the app.
They think:
I am listening to music.
The product should preserve that mental model.

## 5. Core Experience

The fundamental loop is:

```text
OPEN APP
   ↓
SEE MUSIC
   ↓
PLAY MUSIC
   ↓
CONTROL MUSIC THROUGH PILOT
```

There should be as little friction as possible between intent and playback.
The app should avoid unnecessary intermediate screens, confirmations, modes, and navigation.

## 6. Pilot

### 6.1 Definition

The Pilot is a persistent playback control surface.
It exists independently from individual content screens.

```text
APP
│
├── CONTENT LAYER
│   ├── Playlists
│   ├── Playlist
│   └── future library views
│
└── PILOT LAYER
    ├── current track
    ├── playback state
    ├── playback controls
    └── current listening context
```

Navigation changes.
The Pilot remains.

## 7. Pilot States

The Pilot may progressively reveal controls.
Its conceptual states are:

```text
STANDBY
   ↓
COMPACT
   ↓
EXPANDED
```

These states should feel like transformations of the same physical object.
Do not treat them as unrelated screens.

### 7.1 Standby

Used when there is no active playback context.
The Pilot should either:

* be absent,
* or exist in a clearly inactive state if a future use case requires it.

Do not fill empty space with fake playback UI.

### 7.2 Compact Pilot

Default active state.
Conceptually:

```text
╭─────────────────────────────────────╮
│ artwork   Song title        Play    │
│           Artist                    │
╰─────────────────────────────────────╯
```

Contains only essential information:

```text
TRACK
├── artwork
├── title
└── artist

PLAYBACK
└── play / pause
```

Optional playback progress may be represented subtly.
Do not overload this state.

### 7.3 Expanded Pilot

The Pilot expands to expose richer playback controls.
Conceptually:

```text
        ARTWORK

       Song title
         Artist

     ─────●──────

    Previous
      Play
      Next

 secondary controls
```

Expanded state may contain:

```text
PRIMARY
├── previous
├── play / pause
├── next
└── seek

SECONDARY
├── queue
├── output / AirPlay
├── shuffle
└── repeat
```

Primary actions must visually dominate secondary actions.

## 8. Pilot Interaction Model

The Pilot should support direct manipulation.
Primary interaction language:

```text
PILOT
│
├── tap Play / Pause
│   └── toggle playback
│
├── tap body
│   └── expand
│
├── drag upward
│   └── progressively expand
│
├── drag downward
│   └── progressively collapse
│
├── swipe left
│   └── next track
│
├── swipe right
│   └── previous track
│
└── long press
    └── contextual actions when appropriate
```

Gestures are accelerators.
Critical functions must not depend exclusively on hidden gestures.

## 9. Direct Manipulation

Gestures must respond continuously to the user's finger or pointer.

Bad:

```text
swipe
↓
gesture ends
↓
animation begins
↓
track changes
```

Preferred:

```text
finger moves
↓
interface moves with it
↓
threshold becomes perceptible
↓
user commits or cancels
```

The interface should feel physically connected to the input.

## 10. Track Switching

Swipe-to-change-track is a signature interaction.
It should behave approximately like:

```text
CURRENT TRACK
     │
     │ drag left
     ▼
CURRENT TRACK MOVES LEFT
NEXT TRACK APPEARS FROM RIGHT
     │
     ├── release before threshold
     │   └── cancel + spring back
     │
     └── cross threshold
         ├── haptic feedback
         ├── commit change
         └── next track settles into position
```

Same logic in the opposite direction for previous track.
The transition must be:

* interruptible,
* reversible before commit,
* visually continuous,
* responsive to gesture velocity,
* accompanied by subtle haptic feedback at the commit threshold where supported.

## 11. Expansion

The Pilot should not normally open a disconnected Now Playing screen.
Instead:

```text
COMPACT PILOT
      │
      │ drag / tap
      ▼
PILOT EXPANDS
      │
      ├── artwork grows
      ├── metadata moves
      ├── controls appear
      └── content recedes
```

Expansion and collapse should preserve visual object continuity.
The user should always understand where the expanded player came from.

## 12. Motion

Animation exists to communicate structure and causality.
Motion should answer:

```text
Where did this element come from?

Where is it going?

What did my gesture do?
```

Motion must not exist merely to decorate the interface.
Avoid:

* arbitrary bouncing,
* decorative transitions,
* excessive spring effects,
* animation that delays input.

The interface must always feel faster than its animations.

## 13. Haptics

Use haptics deliberately.
Good uses:

```text
track-change threshold
playback state toggle
pilot expansion snap point
important state confirmation
```

Bad use:

```text
haptic on every tap
```

Haptics should indicate meaningful state changes, not acknowledge that glass was touched.

## 14. Interface Philosophy

The UI should be:

```text
FAST
QUIET
TACTILE
PREDICTABLE
SMART
DIRECT
```

It should not be:

```text
BUSY
DECORATIVE
GAMIFIED
LOUD
OVERDESIGNED
DISCOVERY-DRIVEN
```

Minimalism is not itself the goal.
Minimalism is the result of removing everything that slows the user down.

## 15. Smart, Not Clever

Interactions should exploit existing user expectations.

Good:

```text
swipe artwork left
→ next track
```

Bad:

```text
custom obscure gesture
→ next track
```

Good:

```text
drag player upward
→ expand player
```

Bad:

```text
hidden button with non-obvious meaning
→ open controls
```

The ideal reaction is:
Of course it works like that.
Not:
How was I supposed to know that?

## 16. Content Layer

Content exists to feed the playback experience.
Current MVP content structure:

```text
APP
│
├── AUTHORIZATION
│   └── Connect Apple Music
│
├── PLAYLISTS
│   └── PLAYLIST
│       └── TRACKS
│
└── PILOT
```

No Home screen is required.
After authorization, the user should land directly on playlists.

## 17. MVP Navigation

```text
LAUNCH
│
├── authorization required
│   └── CONNECT APPLE MUSIC
│       └── PLAYLISTS
│
└── already authorized
    └── PLAYLISTS
        │
        ├── tap playlist
        │   └── PLAYLIST
        │       │
        │       ├── Play
        │       │   └── playback starts
        │       │
        │       └── tap track
        │           └── playback starts from track
        │
        └── PILOT
            │
            ├── Play / Pause
            ├── Next
            ├── Previous
            ├── Expand
            ├── Collapse
            └── Seek
```

The Pilot is not owned by the playlist screen.
It persists across content navigation.

## 18. No Discovery

The current product intentionally does not include:

```text
Home
Discover
Browse
Recommendations
For You
Radio
Charts
New Releases
Editorial
```

Do not create placeholders for them.
Do not build navigation in anticipation of them.
If they ever become necessary, they will be added deliberately.

## 19. Progressive Disclosure

Only expose controls when they become useful.
Example:

```text
COMPACT PILOT
├── track
└── play / pause

EXPANDED PILOT
├── track
├── previous
├── play / pause
├── next
├── seek
└── secondary controls
```

Do not permanently display actions merely because they exist.

## 20. Platform Philosophy

The Pilot must feel like the same product across:

```text
iPhone
iPad
Mac
CarPlay
Apple TV
```

"Same" means:

* same mental model,
* same control hierarchy,
* same terminology,
* same playback state,
* same interaction principles,
* recognizable visual identity.

It does not mean forcing identical pixels or gestures onto every platform.
Each platform must respect its native interaction model.

## 21. iPhone

Reference implementation of the Pilot.
Primary input:

```text
touch
```

Priorities:

```text
thumb reach
gestures
direct manipulation
one-handed use
```

The Pilot should normally live near the bottom of the screen.

## 22. iPad

Same conceptual Pilot.
Avoid stretching the control surface across the entire display simply because space exists.
The Pilot should remain a deliberate, contained object.
Primary input:

```text
touch
pointer
keyboard where appropriate
```

## 23. Mac

Preserve Pilot hierarchy.
Adapt input to:

```text
pointer
trackpad
keyboard
```

Possible Mac-specific enhancements:

```text
hover
keyboard shortcuts
richer pointer feedback
```

Do not make core actions depend on hover.

## 24. Apple TV

Preserve:

```text
Pilot identity
control hierarchy
playback state
```

Adapt interaction to:

```text
focus
remote
directional navigation
select
```

Do not force touchscreen interaction metaphors onto tvOS.

## 25. CarPlay

CarPlay is constrained by Apple's platform UI and templates.
The goal is not pixel-identical reproduction of the custom Pilot.
The goal is preservation of the same playback mental model:

```text
current track
playback state
previous
play / pause
next
queue/context where allowed
```

Native CarPlay behavior takes priority over visual consistency.
Safety and platform rules override custom interaction ambitions.

## 26. Playback Continuity

Playback should feel like one continuous session across the product.
Conceptually:

```text
MUSIC SESSION
│
├── current track
├── current queue / playlist
├── playback position
├── playback state
└── output context
```

Views are temporary.
The listening session is persistent.

## 27. Cross-Device Direction

Long-term product direction:

```text
iPhone
   ↕
iPad
   ↕
Mac
   ↕
CarPlay
   ↕
Apple TV
```

Changing devices should not force the user to rebuild their listening context.
The ideal experience is:

```text
CONTINUE
```

not:

```text
FIND PLAYLIST
→ FIND TRACK
→ FIND POSITION
→ RESUME
```

Exact technical implementation may evolve.
The product requirement does not.

## 28. System Playback Surfaces

The app should treat system playback surfaces as extensions of the same listening session where technically possible.
Examples:

```text
Lock Screen
Control Center
Dynamic Island
CarPlay
AirPlay destinations
```

These surfaces should represent the same current playback state as the in-app Pilot.

## 29. Navigation vs Playback

Navigation and playback are separate systems.
The Pilot must never become a dumping ground for application navigation.
Do not put:

```text
Home
Search
Library
Profile
Settings
```

inside the Pilot.
Pilot controls playback.
Content UI handles navigation.

## 30. Thumb-First Design

On touch devices, frequent controls should be easy to reach.
Highest-priority actions:

```text
Play / Pause
Next
Previous
Expand Pilot
Collapse Pilot
```

Real one-handed usage matters more than screenshot composition.

## 31. Accessibility

Gesture-first does not mean gesture-only.
Critical actions require accessible equivalents.
Support:

* VoiceOver,
* Dynamic Type where appropriate,
* sufficient hit targets,
* keyboard controls on relevant platforms,
* system accessibility settings,
* reduced motion behavior.

A user must not lose essential functionality because they cannot perform a custom gesture.

## 32. Performance Principle

Interaction latency is a product issue.
The Pilot must react immediately to input.
Avoid architectures where:

```text
gesture
→ network/state delay
→ visual response
```

Prefer:

```text
gesture
→ immediate local visual response
→ state reconciliation
```

The UI should never feel like a remote control sending commands to another layer.
It should feel like direct manipulation of playback.

## 33. Current MVP

The current MVP exists to validate the complete core loop.
Required:

```text
Apple Music authorization
↓
load playlists
↓
open playlist
↓
load tracks
↓
play playlist
↓
play selected track
↓
persistent Pilot
↓
play / pause
↓
previous / next
↓
expanded Pilot
↓
seek
```

Do not expand scope until this flow feels correct.
"Works" is not enough for the Pilot.
The interaction quality itself must be validated.

## 34. Current Non-Goals

Do not implement unless this document is explicitly changed:

```text
Discovery
Recommendations
Editorial content
Social features
Music news
Radio
Charts
Artist discovery
Album discovery feeds
Gamification
Custom recommendation algorithms
```

Do not build empty architecture purely to prepare for these features.

## 35. Decision Framework

Before adding or changing anything, ask:

```text
1. Does this shorten the path to music?

2. Does this make playback easier to control?

3. Does it preserve or improve the Pilot?

4. Does it behave the way an experienced Apple user would expect?

5. Can the user understand the interaction from feedback alone?

6. Does it preserve listening context?

7. Is this actually necessary?
```

If the answer to question 7 is no:
do not add it.

## 36. Product Quality Test

The Pilot succeeds when the user:

```text
does not need to search for it
does not need to think about how to use it
can operate it with muscle memory
can predict its gestures
can cancel gestures naturally
feels immediate response under the finger
understands every state transition
trusts that it represents the real playback state
```

The ideal result is that the user eventually stops noticing the interface.
They simply control the music.

## 37. Final Product Principle

```text
THE APP IS BUILT AROUND THE PILOT.

NOT THE OTHER WAY AROUND.
```

When in doubt:
make the Pilot better, remove friction, preserve context, and delete everything else.
