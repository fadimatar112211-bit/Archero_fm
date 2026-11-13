# Archero_fm — Mission Progress & Accelerated Delivery Plan

Last updated: 2026-11-13  
Target: deliver the most complete, stable, fully playable release possible by **2026-11-14 (tomorrow)**. This is an aggressive target, not a guarantee; actual completion depends on the remaining implementation scope and CI/device issues.

## Source-of-truth rules

- Preserve the user's original roadmap exactly: **14 main missions and 212 subtasks**. Do not reorder, rename, replace, invent, or silently remove roadmap items.
- The full verbatim text of all 14 missions / 212 subtasks must be imported from the user's original source when available. Until then, do not reconstruct missing items from guesses.
- Mark a subtask complete only after implementation and appropriate verification. A passing build alone does not prove gameplay completeness.
- Preserve all existing custom game features and balance. Do not remove or materially change them without the user's approval.
- Do not claim a feature, mission, test, merge, or release is complete unless the repository and verification evidence support that claim.
- The comprehensive hands-on Android gameplay test is reserved for the end of the implementation cycle, as requested. Use automated analysis, unit/widget tests, and Android builds during development; these are not substitutes for final hands-on playtesting.
- Fix discovered deficiencies promptly rather than merely recording them.

## Exactly five execution tracks — the complete game scope

The project is managed through **five tracks only**. The original 14 missions and 212 subtasks remain the authoritative checklist, but they are no longer treated as separate execution lanes. Every original subtask must be assigned to one primary track and retain its original ID for traceability. No task may be omitted, duplicated as separate work, renamed, or invented.

### Track 1 — Architecture and technical foundation
Owns the internal structure that makes the whole game maintainable and reliable:
- code organization and separation of Flutter presentation from game/domain logic;
- run/session state, lifecycle, timers, resource ownership, and transitions between systems;
- shared systems, data models, diagnostics, logging, error handling, and safe failure recovery;
- integration boundaries and technical foundations used by every other track.

### Track 2 — Gameplay, player, combat, enemies, and equipment
Owns the moment-to-moment playable experience:
- player controls, movement, aiming, attacks, projectiles, damage, health, and defeat;
- enemy spawning, waves, behavior, attacks, bosses, and combat encounters;
- weapons, equipment, skills, abilities, upgrades that affect combat, and balancing;
- combat feedback and all gameplay mechanics needed for a complete playable run.

### Track 3 — World, rooms, stages, content, and progression flow
Owns where the player goes and how a run unfolds:
- room generation/layout, room rules, doors, transitions, and encounter sequencing;
- stages, chapters, maps, progression gates, completion/failure flow, and replay flow;
- chests, rewards and content placement where tied to room/stage progression;
- end-to-end continuity from starting a run through completing or losing it.

### Track 4 — Economy, saving, rewards, and permanent player progression
Owns the game's resource and long-term progression loop:
- coins, currencies, drops, rewards, costs, purchases, shops, and transaction failure handling;
- player profile/data, save/load, persistence, recovery, and data integrity;
- permanent upgrades, progression systems, unlocks, and reward accounting;
- consistency between gameplay rewards, shop spending, and saved progression.

### Track 5 — Interface, experience, audio/visuals, quality, and release
Owns how the game is presented, understood, felt, and validated:
- HUD, menus, dialogs, settings, navigation, onboarding, and usability;
- music, sound effects, animation, particles, visual effects, and presentation polish;
- accessibility/readability and player feedback;
- automated tests, regression coverage, performance, crash fixes, Android packaging/builds, and final hands-on Android gameplay validation.

### Rules for assigning the original 212 subtasks
- Assign each original subtask to exactly one primary track according to its main deliverable; cross-track dependencies are recorded as references, not duplicate task entries.
- Keep original mission/subtask IDs (for example, 1.1–1.16) unchanged in commits, PR descriptions, and this file.
- Preserve all 14 original mission titles and all 212 descriptions verbatim in the canonical checklist. The currently available repository checkpoint contains the exact text of Mission 1 (16 subtasks), but not the complete verbatim text of Missions 2–14. Do not fabricate those descriptions or claim that a detailed 212-row mapping has been completed until the original source text is recovered and each ID is mapped.
- The five tracks are the only execution/reporting lanes. The 14 missions and 212 subtasks remain the source checklist underneath them, not additional tracks.

## Priority order under the accelerated deadline

1. Make the core game loop and all existing essential features work end-to-end.
2. Ensure combat, enemies, rooms, stages, rewards, and progression are correctly connected.
3. Ensure saving, purchases, and failure paths are reliable.
4. Complete the required UI and content paths; preserve custom features.
5. Fix known crashes, lifecycle/timer leaks, and high-impact performance problems.
6. Polish lower-priority visuals/audio only after essential functionality is secure.
7. Run final comprehensive hands-on Android gameplay testing, fix discovered blockers, and produce a truthful release-readiness report.

Do not sacrifice correctness or silently omit roadmap items just to meet the target date. If the full scope cannot responsibly be completed by the target, report exactly what is complete, what remains, and why.

## Current verified checkpoint

- Repository: `fadimatar112211-bit/Archero_fm`
- Integration/base branch: `feature/procedural-game-audio-v2`
- Architecture work branch: `feature/mission-1-full-architecture`
- PR #37, “Make game run session own lifecycle and timer disposal”: **merged** on 2026-11-13.
- Merge commit: `fdccef961097c2fb5cab485624bcf66a47c58c8e`
- PR #37 head commit: `d89d9868b723a67d6fdcaddf784c5cfeb73ebd37`
- CI run `43466730871`: **success** — Dart analysis, tests, Android project generation, and Android debug APK build all completed successfully.
- This PR delivers a lifecycle/timer-ownership slice only. It does **not** mean Mission 1 is complete.

## Mission 1 — Separate game structure and organize code

Original title: **فصل بنية اللعبة وتنظيم الكود**

Status: **In progress — not complete.**  
Scope: 16 subtasks. Do not mark the mission complete until all 16 are implemented, integrated, and appropriately verified.

- [ ] 1.1 فصل منطق اللعبة عن واجهة Flutter.
- [ ] 1.2 فصل إدارة حالة الجولة عن `main.dart`.
- [ ] 1.3 فصل دورة حياة الجولة.
- [ ] 1.4 فصل نظام حركة اللاعب.
- [ ] 1.5 فصل نظام إطلاق السهام.
- [ ] 1.6 فصل منطق إصابة الأعداء وهزيمتهم.
- [ ] 1.7 فصل منطق هجمات الأعداء.
- [ ] 1.8 فصل توليد الأعداء وموجاتهم.
- [ ] 1.9 فصل جمع العملات والمكافآت.
- [ ] 1.10 فصل إدارة المقذوفات والمؤثرات.
- [ ] 1.11 فصل نظام الغرف وانتقال اللاعب.
- [ ] 1.12 فصل بيانات اللاعب والتقدم الدائم.
- [ ] 1.13 نظام تسجيل الأخطاء والتشخيص.
- [ ] 1.14 معالجة فشل الحفظ والشراء.
- [ ] 1.15 مراجعة المؤقتات وتحرير الموارد.
- [ ] 1.16 اختبار الأنظمة بشكل مستقل.

Note: PR #37 contributes to lifecycle/timer ownership and has passing automated CI, but the remaining responsibilities still need real extraction/integration from the game screen and other owners. Existing service files or superficial imports alone do not satisfy a separation task.

## Checkpoint update protocol

After every substantial integrated batch:
- Record exact original subtask IDs affected.
- Record files changed, branch, PR number, commit SHA, and merge status.
- Record the exact automated checks and their results.
- Record remaining gaps and the concrete next implementation action.
- Update this file so a new conversation can resume from the latest repository state without repeating completed work.
