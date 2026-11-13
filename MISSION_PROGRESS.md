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

## Accelerated execution strategy

Work in large, coherent, parallelizable workstreams instead of waiting for every small subtask to finish before starting the next. Use independent branches where practical, avoid overlapping edits, integrate in safe batches, resolve conflicts, and run automated checks before merging. Keep pull requests ready for review (not draft); merge only after the relevant checks pass.

### Workstreams

1. **Architecture and code organization** — separate presentation, run/session lifecycle, state, timers, diagnostics, and domain responsibilities.
2. **Player and combat** — movement, aiming, attacks, projectiles, damage, hit feedback, and combat flow.
3. **Enemies and bosses** — spawning, waves, AI, attacks, boss behavior, and defeat/reward flow.
4. **Rooms, stages, and progression flow** — room transitions, stage completion, encounters, and run lifecycle.
5. **Weapons, equipment, and skills** — preserve existing systems and ensure their effects integrate correctly.
6. **Economy and shop** — coins, rewards, purchases, failure handling, and consistency.
7. **Saving and permanent progression** — persistence, upgrades, player data, and safe recovery from failures.
8. **UI and player experience** — menus, HUD, dialogs, navigation, feedback, and usability.
9. **Audio and effects** — sound, visual effects, feedback, resource ownership, and performance.
10. **Quality and release readiness** — automated regression checks, diagnostics, performance review, Android packaging, and final hands-on gameplay validation.

These are execution lanes, not a replacement or renumbering of the original 14-mission / 212-subtask roadmap. Map every change back to the original subtask IDs.

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
