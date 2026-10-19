# PL010: OpenParsec backlog and upstream PR follow-up

## Authority and scope

This file is the durable OpenParsec to-do list for the dedicated project at
`~/Development/openparsec`. It moved from the general workspace on 2026-10-19.
The general workspace's plan index links here; maintain this file as the single
planning authority rather than introducing a competing task ledger.

Created on 2026-10-16 (Asia/Hong_Kong), following Telegram thread 17419.
Implementation progress is recorded below as the user selects follow-up work.
Recheck GitHub and local changes before resuming any item. Execute future
work as independently verifiable checkpoints of at most five minutes; split any
larger step before starting it.

Implementation repository: this project root. Existing worktrees under
`.worktree/` belong to their respective PRs; preserve them.

## Communication preference

For future OpenParsec comments and replies, use the `public-reply` skill at
`~/.claude/skills/public-reply/SKILL.md`. Keep replies natural, brief, and directed
to the maintainer. Acknowledgements should usually be one short sentence;
lowercase openings are fine when they fit the thread. Avoid repeating technical
reports when a simple thanks answers the message. This also applies to Asana
comments when using the skill.

## Upstream PR status

The original 2026-10-16 audit covered the two open PRs by `alantangok`, including
ordinary comments, reviews, inline review threads, heads and checks. Rechecked
on 2026-10-17: **both PRs are merged** by `SandiyosDev`; ordinary comments contain
the maintainer's responses. Both have no formal reviews or inline comments.

| PR | Submitted head | Verified state | Outstanding work |
| --- | --- | --- | --- |
| [#100: Opt-in menu edge swipe](https://github.com/hugeBlack/OpenParsec/pull/100) | `7117aed` | Merged 2026-10-17 01:45:13 UTC | Full-screen-only scope accepted; Slide Over/windowed behavior remains a known limitation |
| [#97: Fractional scroll accumulation](https://github.com/hugeBlack/OpenParsec/pull/97) | `892e7be` | Merged 2026-10-17 01:45:06 UTC | Discrete wheel validation remains unconfirmed; separate settings follow-up remains local |

Merge status was verified from GitHub's `MERGED` state and merge timestamps,
not inferred from a closed or mergeable state. Short thanks were posted and
read back on [#97](https://github.com/hugeBlack/OpenParsec/pull/97#issuecomment-6229004392)
and [#100](https://github.com/hugeBlack/OpenParsec/pull/100#issuecomment-6229004619).

## PR #100: Merged; full-screen-only scope accepted

Source: [maintainer review](https://github.com/hugeBlack/OpenParsec/pull/100#issuecomment-5766573944).
Implemented and pushed as `7117aed` on 2026-10-16. The existing worktree is clean.
[Initial review reply](https://github.com/hugeBlack/OpenParsec/pull/100#issuecomment-6218835208) recorded pending testing; the subsequent manual results below supersede that pending status.

- [x] **OP100-01: Make menu edge swipe opt-in and default it off.** Both settings
  declarations default to Off; Off registers no recognizer. Existing Left/Right
  values remain 0/1 and Off is appended as 2. Settings UI offers all three choices.
- [x] **OP100-02: Remove the touch-begin delay.** Removed the explicit
  `delaysTouchesBegan = true`. Extracted registration/handler checks pass; physical
  edge-drag feel remains part of OP100-05.
- [x] **OP100-03: Reuse `getHostUserData()`.** The menu callback calls the existing
  method rather than copying its two requests. Source wiring and build pass.
- [x] **OP100-04: Move `MenuSwipeEdge` to the shared settings enums in
  `ParsecSDKBridge.swift`.** No project-file changes were needed.
- [x] **OP100-05: Characterize right-side Slide Over and windowed behavior on a
  physical iPad.** User manually tested delivered build 1.4.0 (225), reporting:
  full-screen OpenParsec works; with Slide Over enabled and its window on the
  right the edge menu does not activate; windowed OpenParsec also does not
  activate it. This is a recorded full-screen-only limitation, not a compatibility
  pass. The specific edge preference and ordinary drag timing were not separately
  reported. [Manual results reported upstream](https://github.com/hugeBlack/OpenParsec/pull/100#issuecomment-6219130947).
  Wi-Fi XCTest attempts had failed; these results are from the user's manual test.
  The signed package is in
  `build/pr100-7117aed-20261016/`.
  It tests main + #100, without the separate build 224 scroll fixes.
- [x] **OP100-06: Complete code/CI QA, update the PR and reply to the review.**
  Nineteen scoped source/behavior checks passed with test doubles, the unsigned
  Release device build passed, and [CI archive/IPA packaging passed](https://github.com/hugeBlack/OpenParsec/actions/runs/38923341136).
  CI merge `9e37c2` has main `b49c720` and PR head `7117aed` as parents.
  Artifact digest and signed build 225 integrity were verified. PR title/body
  and review reply were updated and read back. Manual mode characterization is
  recorded under OP100-05; the resulting limitation is tracked under OP100-07.


- [x] **OP100-07: Resolve the full-screen-only scope with the maintainer.**
  [SandiyosDev accepted full-screen-only behavior because the option defaults
  off and confirmed the merge](https://github.com/hugeBlack/OpenParsec/pull/100#issuecomment-6228257319).
  Their 2.0 plan includes a left-edge swipe to restore a hidden menu overlay,
  building on this change. This is the maintainer's future plan, not additional
  implementation assigned to Alan. Slide Over/windowed behavior remains a known
  limitation; acceptance does not mean those modes now work.

## Priority 2: Finish existing scroll follow-up

- [x] **OP97-01: Check for maintainer response or merge on #97.** Merged by
  `SandiyosDev`; [the maintainer thanked Alan for narrowing the PR to the
  accumulator](https://github.com/hugeBlack/OpenParsec/pull/97#issuecomment-6228249999).
- [ ] **OP97-02: Validate a physical discrete mouse wheel when available.**
  Record positive/negative ticks, both axes where supported, and fine deltas.
  Existing Magic Keyboard feedback is not evidence for a discrete mouse wheel.
- [ ] **OPSCROLL-01: Prepare the existing sensitivity/reverse-setting fix for a
  separate upstream proposal.** Local commit `b319a30` on
  `alan/fix/gcmouse-scroll-settings` is tested but not pushed or submitted as a PR.
  Start by reviewing its minimal diff against the intended upstream base and
  assessing default/discrete-wheel behavior. Keep it separate from #97.

Completed evidence:

- [x] #97 narrowed to fractional accumulation only, with its original axis and
  integer-delta behavior preserved; requested scope changes answered.
- [x] #97 callback harness (18 assertions), Release build/static analysis and CI
  build/IPA packaging passed.
- [x] User reported build 223 appeared to remove jumpy/skipping Magic Keyboard
  scrolling; user confirmed build 224 fixed the existing settings issue.
- [x] Local settings fix passed 84 callback assertions, Release build and signed
  IPA verification. This is separate from #97's contents and CI evidence.
- [x] [Device results and two distinct feel suggestions were reported to #97](https://github.com/hugeBlack/OpenParsec/pull/97#issuecomment-6218387360).

## Future research: Two distinct scrolling behaviors

These are separate backlog items, not additional acceptance criteria for #97.
The user requested recording them for later research and a potential separate
PR or PRs. Decide the eventual PR split after evaluating the behaviors.

- [ ] **OPACCEL-01: Research scroll acceleration / velocity response.** During
  finger movement, slow gestures should allow fine control and faster swipes
  should produce stronger scrolling. This differs from a fixed sensitivity
  multiplier. First checkpoint: capture a bounded slow/fast gesture comparison
  and identify whether client deltas or host handling already apply acceleration.
  Record the evidence before selecting a curve or proposing implementation.
- [ ] **OPINERTIA-01: Research inertial / momentum scrolling.** After release,
  scrolling should coast and gradually decelerate rather than stop abruptly.
  First checkpoint: compare a short Magic Keyboard release trace with the
  existing touchscreen behavior. Record gesture-end detection and whether input
  already contains momentum before selecting a decay model or proposing code.

Fractional accumulation preserves small input deltas. Acceleration changes the
response while moving. Inertia controls continued movement after release. Keep
these three concepts distinct in tests, settings and future PR descriptions.

[The #97 scope review](https://github.com/hugeBlack/OpenParsec/pull/97#issuecomment-5766613994)
accepts only the fractional accumulator in that PR. It is not evidence of a
permanent project-wide ban on acceleration or inertia. Discuss future behavior
separately and avoid changing existing users' direction or wheel behavior by
default without an agreed design.

## Test environment and resume evidence

- User's device: iPad Air (5th generation), `iPad13,17`, 64 GB, iPadOS 26.6
  (`23G71`), with Magic Keyboard trackpad. Device model/OS were read directly and
  cross-checked with Xcode. Do not publish serial numbers or device UDIDs.
- GitHub review/check snapshots: `tmp/imported-system/openparsec-todo-20261016/`. These are
  supporting snapshots; this plan and public
  source links are the durable record.
- Build 224 delivery manifest:
  `build/scroll-settings-b319a30-20261016/manifest.json`
  relative to this project root. Existing implementation memories:
  `openparsec/pr97-fractional-scroll-20261016` and
  `openparsec/scroll-settings-20261016` in the implementation project.
- Next actionable implementation item: **OPSCROLL-01**, review the existing
  separate settings fix before proposing it upstream when the user selects it.
  Both merge follow-ups are complete. Physical discrete-wheel validation,
  acceleration research, and inertia research remain on the backlog.
