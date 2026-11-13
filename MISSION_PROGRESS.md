# Archero_fm — New Roadmap: Gap Analysis Against the Original Game

Last updated: 2026-11-13

## Source of truth

The following nine sections and their items, as supplied by the user on 2026-11-13, are the active roadmap for the project. This replaces the previous roadmap and its execution structure.

Preserve the section names, item wording, and order. Do not invent, omit, rename, or silently reorder requirements. As work proceeds, add implementation status, files, commits, PRs, and verification evidence under the relevant item without changing the original requirement text.

The goal is to bring Archero_fm toward the depth, variety, polish, and completeness of the original game while preserving the project's existing custom features. Use original or properly licensed assets; do not copy proprietary code or assets.

## ثانياً: شو ناقصنا حتى نوصل لمستوى الأصلية؟

### 1. بنية اللعبة
- فصل main.dart الكبير إلى أنظمة وملفات مستقلة.
- توحيد إدارة الجولات وحالات اللعب.
- تحسين إدارة المؤقتات والأحداث.
- منع تعارض الحفظ والشراء والقتال.

ملاحظة المستخدم: يوجد عمل معماري بهذا الاتجاه في PR رقم 35، لكنه ما زال مفتوحاً وغير مدمج في الفرع الرئيسي.

**ملاحظة تحقق GitHub بتاريخ 2026-11-13:** PR #35 بعنوان “Integrate mission 1 architecture and separation work” حالته مغلق ومندمج بالفعل في الفرع feature/procedural-game-audio-v2. Merge commit: dbed336af0c6b97a619c3081242328578f405d77. لذلك نعتمد حالة GitHub الفعلية، مع بقاء متطلبات هذا القسم قائمة للتحقق من اكتمالها في الكود، ولا نعتبر دمج PR وحده دليلاً على اكتمالها.

PR 35 – فصل بنية اللعبة: https://github.com/fadimatar112211-bit/Archero_fm/pull/35

### 2. اللاعب والقتال
- تحسين إحساس الحركة والاستجابة للمس.
- تطوير نظام التصويب والإطلاق.
- إضافة تنوع أكبر للهجمات.
- تطوير نظام المراوغة والحماية.
- إضافة تفاعلات وتآزرات بين المهارات.
- ضبط توازن الضرر وسرعة الهجوم.

### 3. الأعداء والزعماء
- زيادة أنواع الأعداء وسلوكياتهم.
- جعل لكل عدو طريقة قتال مميزة.
- إضافة هجمات يمكن للاعب توقعها وتفاديها.
- تطوير الزعماء بمراحل وأنماط متعددة.
- تحسين موازنة الصعوبة.

### 4. الغرف والمراحل
وهذا من أكبر النواقص:
- تصميم خرائط وغرف متنوعة فعلياً.
- غرف كنوز ومتاجر وعلاج وتحديات.
- عوائق قابلة للتفاعل.
- تنوع تخطيط الغرف.
- مكافآت واختيارات بين الغرف.
- جعل لكل عالم هوية لعب خاصة، وليس مجرد تغيير ألوان الخلفية.

حتى خطة المشروع نفسها تشير إلى أن الغرف المميزة وغرف الكنز والمتجر والعلاج والتحديات ما زالت بحاجة إلى تنفيذ.

### 5. الأسلحة والمعدات
هذا قسم كبير نحتاج نبنيه:
- أنواع أسلحة مختلفة.
- اختلاف خصائص وسرعة ومدى الهجمات.
- دروع وخوذ وخواتم ومعدات.
- ندرة للمعدات.
- تطوير ودمج وترقية المعدات.
- آثار Relics وتأثيراتها.
- نظام تجهيز ومقارنة المعدات.

### 6. الاقتصاد والمتجر
- متجر متكامل وليس ترقيتي صحة وهجوم فقط.
- مكافآت متنوعة.
- صناديق وموارد.
- أسعار وتكاليف متوازنة.
- مكافآت مرتبطة بالتقدم والإنجازات.
- التحقق من سلامة عمليات الشراء والحفظ.

### 7. الحفظ والتقدم
- نظام تقدم دائم أكثر شمولاً.
- حفظ الأبطال والمعدات والأسلحة.
- حفظ الترقيات والموارد والإنجازات.
- استعادة الجولة والتعامل مع إغلاق التطبيق.
- نظام فتح العوالم والمراحل.
- حماية البيانات من التلف أو ضياع التقدم.

### 8. الواجهة وتجربة اللعب
- واجهة اختيار العوالم.
- تطوير شاشة اختيار الأبطال.
- واجهة المعدات والأسلحة.
- شاشة المهارات والإنجازات.
- إعدادات الصوت والتحكم والاهتزاز.
- شاشات الفوز والخسارة والتقدم.
- تحسين تصميم القوائم والـ HUD.

### 9. الصوت والمؤثرات
- موسيقى مناسبة لكل عالم.
- أصوات مختلفة للأعداء والزعماء.
- مؤثرات الضرب والموت والانفجار.
- مؤثرات المهارات والترقيات.
- مؤثرات بصرية أكثر تنوعاً.
- تحسين تزامن الصوت مع الحركة.

## Delivery target — 2026-11-14

**Primary target: finish the complete game tomorrow, not merely complete as much work as possible.** Treat all nine roadmap sections and every listed requirement as part of the delivery target. Prioritize implementation and integration in parallel, preserve existing custom features, fix issues as they are found, and keep pushing coherent checkpoints to GitHub throughout the work. Do not describe the game as complete until the full feature set is integrated, automated checks pass, and the final Android gameplay validation is completed. The date is the project target, not permission to misrepresent unfinished work as finished.

## Progress tracking rules

- This nine-section list is the sole active roadmap until the user provides a replacement or revision.
- Do not infer that a listed feature is complete merely because a similarly named file or service exists.
- Verify existing implementation before making changes; preserve working behavior and custom features.
- Fix deficiencies discovered during implementation, then run appropriate automated checks (analysis, tests, Android build).
- Reserve comprehensive hands-on Android gameplay validation for the final integrated stage unless the user changes that instruction.
- Keep progress truthful: distinguish implemented, automated-tested, built, and manually gameplay-verified.
- Record exact changed files, commit SHA, PR, CI outcome, remaining gaps, and next action.

## Last verified repository checkpoint

- Repository: fadimatar112211-bit/Archero_fm
- Integration branch: feature/procedural-game-audio-v2
- PR #35 is merged; merge commit dbed336af0c6b97a619c3081242328578f405d77.
- PR #37, “Make game run session own lifecycle and timer disposal”, is merged; merge commit fdccef961097c2fb5cab485624bcf66a47c58c8e.
- PR #37 CI run 43466730871 succeeded: Dart analysis, tests, Android project generation, and Android debug APK build.
- These are historical checkpoints, not proof that all requirements in this new roadmap are complete.

## Current execution batch — Section 5: Weapons and equipment

Status: **PR #39 (weapons/equipment loadouts) and PR #40 (persistent equipment unlocks) are merged. Section 5 remains partially complete; equipment merging, drops, and comparison UI remain open. Current work has moved to special room destinations under Section 4.**

Branch: `feature/roadmap-equipment-and-weapon-progression`

PR: https://github.com/fadimatar112211-bit/Archero_fm/pull/39

Implemented in this batch:
- Four weapon profiles with distinct damage, firing cadence, projectile speed, spread, and bonus-arrow behavior.
- Weapon stats affect normal projectile attacks and the active hero skill.
- A main-menu armory selector equips the selected weapon.
- The equipped weapon is stored in the persistent progression snapshot and restored on startup.
- Invalid weapon IDs safely fall back to the default weapon.
- Focused catalog and persistence tests were added.

Changed files include `lib/weapon_system.dart`, `lib/player_progress.dart`, `lib/progress_store.dart`, `lib/game_progress.dart`, `lib/main.dart`, `lib/main_menu_screen.dart`, `lib/game_screen.dart`, and the related tests.

Integration fix in this follow-up: both shop purchase paths preserve the equipped weapon ID, preventing a health/attack upgrade from silently resetting the selected weapon.

Equipment progression merged in PR #39 (merge commit `4c99d228b4e7612c74b9fafdaa65b2ecd4583050`):
- Added four persistent equipment slots: armor, helmet, ring, and relic.
- Added three profile tiers per slot with Arabic rarity labels and distinct bonuses.
- Equipment stats affect max health, attack power, incoming damage reduction, critical chance, coin pickup radius, and coin rewards.
- Added main-menu equipment selectors and persistence/restore for all four slots.
- Added catalog aggregation and invalid-ID fallback tests.

PR #39 is closed and merged. PR #40 is also merged as commit `13995e8acb6f4c0a6225b71cb97e21cba34868a4`; GitHub Actions runs `43478693258` and `43478703732` both completed successfully, including Dart analysis, all Flutter tests, Android project generation, and Android debug APK build. These merges do not complete Section 5.

Branch: `feature/roadmap-room-layouts-and-hazards`

Implemented in this batch:
- Added deterministic, viewport-independent room layout data with four floor-plan variants.
- Added a world-specific environmental hazard type for each of the six existing worlds.
- Integrated room props and hazard visuals into the arena painter.
- Added an active hazard damage zone; the player's existing movement/dodge window can avoid its periodic damage.
- Added focused room-layout tests and painter/view regression coverage.

Changed files:
- `lib/room_layout.dart` (new)
- `lib/game_screen.dart`
- `lib/game_arena_view.dart`
- `lib/game_painters.dart`
- `test/room_layout_test.dart` (new)
- `test/arena_painter_test.dart`
- `test/game_arena_view_test.dart`

Verification: first CI run 43471488889 failed at Dart analysis because a room-prop painter passed a Rect where an RRect was required; corrected in a follow-up. The rerun's historical status should be treated separately from final gameplay validation. Do not mark this section complete. These room variants and hazards are an initial gameplay slice; boss-gated treasure, merchant, healing, and challenge destinations are now implemented in PR #41. Separate room maps, obstacle collision/pathfinding, and deeper world-specific mechanics remain outstanding.

### Follow-up PR #40 — equipment acquisition and progression

Branch: `feature/equipment-upgrades-and-progression`

Implemented in this follow-up:
- Persistent owned-equipment inventory encoded as a validated 12-bit mask (three tiers across four equipment slots).
- New accounts start with the base item in each slot; the next tier unlocks for 180 coins and the top tier for 450 coins after the previous tier is owned.
- Unlocking equips the new item immediately; save failure rolls back both currency and ownership/equipment state.
- Legacy saves automatically retain already-equipped items as owned, avoiding loss of previously selected gear.
- Shop purchases preserve the equipment ownership mask.

Tests added for sequential unlock rules, ownership migration, and persistence. CI runs `43478693258` and `43478703732` passed Dart analysis, the full Flutter test suite, Android project generation, and Android debug APK build. PR #40 merged as `13995e8acb6f4c0a6225b71cb97e21cba34868a4`.

Remaining in Section 5: equipment merging/duplicate shards, broader loot acquisition and drops, inventory comparison UI, and further equipment balance. Section 6's full economy, chests/resources, achievement rewards, and Section 7's remaining progression requirements still need implementation. Delivery target remains the complete playable game on 2026-11-14.
### Follow-up PR #41 — special room destinations and rewards

Branch: `feature/special-room-destinations-and-rewards`

Implemented:
- After every boss room (every fifth stage), the player chooses one of four destinations before the next combat room: treasure, merchant, healing sanctuary, or challenge.
- Treasure grants 120 coins.
- Healing restores 40% of maximum HP, capped at maximum health.
- Merchant offers a paid +15% run attack boost for 80 coins or a healing potion restoring 30% maximum HP for 50 coins; insufficient funds do not mutate player values.
- Challenge adds two tougher enemies from a higher-stage wave to the next room; clearing that room awards 150 bonus coins.
- Special room selection has its own exclusive run-lifecycle phase: combat actions and simulation time remain locked until a destination is chosen.
- Added unit and widget tests for room options, merchant purchase rules, dialog selection, and lifecycle locking.

Changed files: `lib/special_room_system.dart`, `lib/special_room_dialog.dart`, `lib/game_run_lifecycle.dart`, `lib/game_run_state.dart`, `lib/game_screen.dart`, and related tests.

PR #41 is merged into `feature/procedural-game-audio-v2` as commit `81cdd3b947003b0cefa54541b0d948ecbf448c80`. CI runs `43482791474` and `43482784424` both succeeded on the final PR head, including Dart analysis, full Flutter tests, Android project generation, and Android debug APK build. This is an initial special-room choice/reward loop; separate room maps, interactable shop/treasure props, and deeper challenge-room mechanics remain open.

### Follow-up — Section 6: persistent resources and reward chests

Branch: `feature/persistent-resources-and-chest-economy-integrated`

Status: PR #42 merged into `feature/procedural-game-audio-v2` as commit `77a2347cbf264e8d2e5760209148bd70b7b34aff`. Final-head CI runs `43488128681` and `43488116406` both completed successfully, including Dart analysis, full Flutter tests, Android project generation, and Android debug APK build.

Implemented in this batch:
- Added persistent player balances for gems, chest keys, and equipment shards.
- Extended `PlayerProgress` serialization/copying and startup restoration for all three resource balances and the persistent unlocked-hero mask.
- Extended `ProgressStore` defaults, bounds validation, and complete-snapshot writes to include the new resources.
- Added two chest tiers: a supply chest costing one key and a relic chest costing two keys, each with bounded randomized coin, gem, and equipment-shard rewards.
- Added two ways to obtain keys: 180 coins or 5 gems.
- Chest openings and key purchases persist the full wallet snapshot before committing the in-memory balance; insufficient balances and storage failures leave the wallet unchanged.
- Added wallet and chest controls to the main menu, including resource counters, purchase buttons, disabled states, and reward feedback.
- Serialized chest/key, shop upgrade, weapon selection, equipment selection, and equipment unlock UI transactions to prevent overlapping full-wallet snapshots from overwriting one another.
- Preserved resource balances and unlocked-hero ownership through health and attack shop purchases.
- Hardened weapon/equipment selection and unlock flows so sound playback errors do not incorrectly roll back already-saved purchases or equipment changes.
- Added model, persistence, transaction, equipment shard unlock, hero unlock, and widget tests covering defaults, round trips, normalization, bounded chest rewards, insufficient balances, save failure rollback, shard costs/prerequisites, persistent hero unlock purchases, and the visible chest wallet.

Files changed:
- `lib/hero_selection_screen.dart`
- `lib/player_progress.dart`
- `lib/progress_store.dart`
- `lib/game_progress.dart`
- `lib/main.dart`
- `lib/main_menu_screen.dart`
- `lib/resource_economy.dart` (new)
- `test/player_progress_test.dart`
- `test/progress_store_test.dart`
- `test/resource_economy_test.dart` (new)
- `test/widget_test.dart`

Equipment shards now unlock equipment tiers as an alternative to coins (8 shards for tier 1, 20 for tier 2), with tier prerequisites and save-failure rollback. Remaining in Section 6: shard-based crafting/merging and duplicate conversion, gem sinks beyond keys, economy balancing against real run rewards, and further reward tables. Achievement-linked rewards are now implemented in the current follow-up branch. The new chest economy is an initial functional slice, not a complete economy.

Section 7 progress: persistent hero unlocks are now implemented. The starter hero remains unlocked; the other three heroes can be unlocked for 50/75/100 gems. Unlocks and gem deductions are saved in the same complete progression snapshot, failed saves roll back the purchase, and locked heroes cannot start a run. Section 7 update: achievement persistence/rewards and mid-run checkpoint save/restore are now merged and CI-validated; physical Android resume testing remains pending. World/stage unlock gates are being implemented in the current branch, and stronger corruption recovery remains open.


### Follow-up — Section 7: persistent hero unlocks

Implemented in merged PR #42:
- Added a validated four-hero ownership bitmask to `PlayerProgress` and `ProgressStore`, including legacy-safe defaults that keep the starter hero unlocked.
- Added startup restoration and full-snapshot save support for unlocked heroes.
- Added hero selection lock states and gem prices: 50 gems for the flame hero, 75 for the shadow hero, and 100 for the storm hero.
- Locked heroes cannot enter a run. The selected hero becomes available immediately after a successful persistent unlock.
- Gem deductions and ownership changes are saved together; a storage failure restores the previous balance and ownership mask.
- Kept hero ownership intact through chest purchases, equipment actions, and health/attack shop upgrades.
- Added tests for ownership-mask normalization, persistence, and the successful hero unlock UI flow.

Remaining in Section 7: physical-device verification of mid-run checkpoint resume, world/stage unlock gates (current implementation batch pending CI), and stronger save corruption recovery.


### Follow-up PR #43 — persistent achievements and reward claims

Branch: `feature/persistent-achievements-and-reward-claims`

Status: PR #43 is merged into `feature/procedural-game-audio-v2` as merge commit `80c55b2b0f1e49b304c223515f11b149c337c7fc`. Final CI run `43493906694` succeeded, including Dart analysis, Flutter tests, Android project generation, and Android debug APK build.

Implemented:
- Added persistent lifetime counters for defeated enemies, defeated bosses, opened reward chests, and completed runs.
- Added a 10-achievement milestone catalog covering combat kills, boss defeats, chest openings, stage progression, and completed runs.
- Added persistent one-time reward claim bits so an achievement reward cannot be collected twice.
- Added rewards in coins, gems, and equipment shards.
- Added a full achievements board to the main menu showing milestone requirements, progress counters, locked/ready/claimed states, and claim buttons.
- Achievement claims save the complete progression snapshot (wallet balances and claim bit together) before updating in-memory balances; a storage failure leaves the reward claimable and does not grant unpersisted currency.
- Enemy and boss counters update on defeats; room progression persists combat counters, run completion persists run totals, and both in-run and menu reward chests count toward chest milestones.
- Extended PlayerProgress, ProgressStore, startup restoration, and all main-menu shop/wallet save paths to preserve achievement counters and claim flags.
- Added model/persistence tests, achievement threshold and one-time claim tests, and a widget test for persistent reward claiming.

Changed files:
- `lib/achievement_system.dart` (new)
- `lib/player_progress.dart`
- `lib/progress_store.dart`
- `lib/game_progress.dart`
- `lib/main.dart`
- `lib/game_screen.dart`
- `lib/main_menu_screen.dart`
- `test/achievement_system_test.dart` (new)
- `test/player_progress_test.dart`
- `test/progress_store_test.dart`
- `test/progress_store_failure_test.dart`
- `test/widget_test.dart`

Remaining in Section 7: physical-device verification of mid-run checkpoint resume, world/stage unlock gates (current implementation batch pending CI), and stronger save corruption recovery. The achievement system is an initial persistent milestone set; more progression goals and reward tuning remain open.


## Session checkpoint — 2026-11-13 (latest verified state)

This checkpoint was added after reviewing GitHub PRs #41, #42, and #43 and the current contents of this progress file. Use it as the resume point next session; do not repeat the completed work listed above.

### Verified PR states
- PR #41, “Add boss-gated special room choices and rewards”: **merged** into `feature/procedural-game-audio-v2` on 2026-11-13. Merge commit: `81cdd3b947003b0cefa54541b0d948ecbf448c80`. Final-head CI runs `43482791474` and `43482784424` succeeded (Dart analysis, Flutter tests, Android project generation, Android debug APK build).
- PR #42, “Add persistent resource wallet and reward chests”: **merged** into `feature/procedural-game-audio-v2` on 2026-11-13. Merge commit: `77a2347cbf264e8d2e5760209148bd70b7b34aff`. Final-head CI runs `43488128681` and `43488116406` succeeded (Dart analysis, Flutter tests, Android project generation, Android debug APK build).
- PR #43, “Add persistent achievements and one-time reward claims”: **merged** into `feature/procedural-game-audio-v2`. Final head: `a863e898f075a80eaf8fb5d8333fd916d2f23f55`; merge commit: `80c55b2b0f1e49b304c223515f11b149c337c7fc`. Final CI run `43493906694` completed successfully: Dart analysis, full Flutter tests, Android project generation, and Android debug APK build.

### Exact resume point
- The latest implementation batch is PR #43: persistent achievements and one-time reward claims (details and changed-file list are recorded in the section above).
- The next action is to review PR #43's latest diff and CI result, then merge it only after confirming the checks are green and the branch/base integration is safe. After merge, verify the integrated branch state and record the merge commit here.
- After PR #43, continue Section 7 with mid-run checkpoint save/restore, then world/stage unlock gates, and stronger save-corruption recovery. Keep Section 7 marked partial until these requirements are implemented and verified.
- Other still-open requirements remain as recorded in the nine-section roadmap above; merging PRs #41–#43 does not mean the full game is complete.

### Progress-recording rule for future sessions
After every coherent implementation batch, update this `MISSION_PROGRESS.md` in the active working branch with: roadmap section/item, what changed, exact files, tests and build results, CI run IDs and outcomes, PR number/state, merge commit (if merged), remaining gaps, and the exact next action. Keep statuses evidence-based (implemented, tested, built, manually gameplay-verified are distinct). Before stopping a session, write a fresh “Session checkpoint” so the next session can resume without asking the user to reconstruct the history.


## Session checkpoint — 2026-11-13 (after PR #43 merge; active-run checkpoint implementation underway)

### Verified integration
- PR #43 is merged into `feature/procedural-game-audio-v2` as `80c55b2b0f1e49b304c223515f11b149c337c7fc`.
- Final-head Flutter CI run `43493906694` succeeded. The Android debug APK build completed successfully after the earlier analysis, test, and Android project-generation steps passed.
- PR #43 is no longer open. Its achievement system is integrated; the nine-section roadmap remains incomplete.

### Section 7 — mid-run checkpoint save/restore (implementation branch)
Branch: `feature/mid-run-checkpoint-integrated`, based directly on PR #43 merge commit.

Implemented in the current unvalidated batch:
- Added a versioned JSON checkpoint model with defensive decoding and a dedicated SharedPreferences store.
- Added a run-state adapter that captures/restores hero-independent combat state: stage, player stats/position, score, skill selections and synergies, enemies, player arrows, enemy projectiles, coins, combat effects, defeated sprites, room-hazard cooldown.
- Added periodic five-second checkpoint saves while the run is active/paused, plus a save on app backgrounding.
- Added a main-menu “resume saved run” action and a restore constructor path for GameRunSession.
- Clear the checkpoint when a new run starts or a run ends; clear it at stage-reward transitions and write a fresh checkpoint after the reward choice resolves.
- Added model/storage and run-state adapter tests.

Files changed:
- `lib/run_checkpoint.dart` (new)
- `lib/game_run_checkpoint_adapter.dart` (new)
- `lib/game_run_session.dart`
- `lib/game_screen.dart`
- `lib/main_menu_screen.dart`
- `lib/hero_selection_screen.dart`
- `test/run_checkpoint_test.dart` (new)
- `test/game_run_checkpoint_adapter_test.dart` (new)

Verification status at the first checkpoint: implementation had not yet been validated by GitHub Actions and no physical Android device test had been performed. PR #44 has since been opened; see the newer checkpoint below for its current CI state. Treat the feature as in progress, not complete.

### Exact next actions
1. Review the checkpoint code for edge cases and run-state correctness; add integration/widget coverage where useful.
2. Open a PR against `feature/procedural-game-audio-v2` and wait for Dart analysis, all Flutter tests, Android project generation, and Android debug APK build.
3. Fix any CI failures before merging.
4. After merge, verify the resume flow and update this file with the exact merge SHA and CI run IDs.
5. Continue Section 7 with world/stage unlock gates, then stronger save-corruption recovery. Keep all other roadmap requirements open until implemented and verified.


## Session checkpoint — 2026-11-13 (latest; PR #44 open)

### Current repository state
- PR #43 remains merged into `feature/procedural-game-audio-v2` as merge commit `80c55b2b0f1e49b304c223515f11b149c337c7fc`.
- PR #44, “Add persistent mid-run checkpoint save and resume”, is **open and not merged**.
- PR #44 base: `feature/procedural-game-audio-v2`.
- PR #44 head branch: `feature/mid-run-checkpoint-integrated`.
- Latest PR #44 head SHA after wallet-source-of-truth hardening and progress-log update: `698c40e08bd01cc4231cfe49dc6f711132bb448c`.
- Earlier run `43496064493` (run 817) was cancelled during the Android debug APK step after setup, dependency installation, Dart analysis, tests, and Android project generation had passed. Workflow run `43497017111` (run 823) was created for the code-only head and is superseded by the latest-head workflow run `43497110206` (run 825) for head `698c40e08bd01cc4231cfe49dc6f711132bb448c`; the latter was in progress at the time this checkpoint was written. Do not merge PR #44 until this latest-head run completes successfully.
- No successful CI conclusion has yet been confirmed for the latest PR #44 head. Physical-device gameplay validation has not been performed.

### PR #44 implementation contents
- Versioned JSON checkpoint model and defensive decoding.
- Serialized SharedPreferences save/load/clear operations to prevent stale writes racing with clears.
- Snapshot adapter captures/restores player position and stats, stage/score, selected skills and synergies, enemies, arrows, enemy projectiles, pickups, effects, defeated sprites, room hazard cooldown.
- Snapshot entity maps are copied so the saved checkpoint is not a live mutable view of gameplay collections.
- Periodic five-second saves and app-background save.
- Main-menu resume button, with checkpoint validation before offering resume.
- Clear checkpoint on fresh-run start, run completion, and stage reward/special-room transitions; persist a fresh checkpoint after reward resolution.
- Tests cover serialization, malformed/unsupported payloads, persistence lifecycle, corrupted storage, state round-trip, and invalid run-state rejection.

### Changed files in PR #44
- `lib/run_checkpoint.dart`
- `lib/game_run_checkpoint_adapter.dart`
- `lib/game_run_session.dart`
- `lib/game_screen.dart`
- `lib/main_menu_screen.dart`
- `lib/hero_selection_screen.dart`
- `test/run_checkpoint_test.dart`
- `test/game_run_checkpoint_adapter_test.dart`
- `MISSION_PROGRESS.md`

### Wallet consistency hardening (latest code change)
- Removed wallet balance from the active-run checkpoint payload and restore path. The player progression store remains the single source of truth for persistent coins.
- Updated `lib/game_run_checkpoint_adapter.dart`, `lib/game_screen.dart`, and `test/game_run_checkpoint_adapter_test.dart`.
- Reason: a checkpoint can be older than a later saved shop purchase or wallet update; restoring its wallet value could roll back legitimate spending or overwrite newer persisted progression.
- Commit: `7f991ef65dfaf4f1241cdd85a2e51e421e3e074c`.

### Exact next actions
1. Poll latest-head workflow run `43497110206` until it completes and inspect every job/step, especially Dart analysis, Flutter tests, Android project generation, and Android debug APK build.
2. If any check fails, inspect logs, fix the underlying issue on `feature/mid-run-checkpoint-integrated`, and wait for a green run on the new head SHA.
3. Review PR #44 diff and verify mergeability against the current base; merge only after all required checks pass.
4. After merge, record exact merge commit and successful CI run IDs here.
5. Perform physical-device resume testing when an Android build/device is available; do not mark gameplay verified before this.
6. Continue Section 7 with world/stage unlock gates, then stronger save-corruption recovery.

Keep all other roadmap requirements open until implemented and verified. Never treat PR creation, code presence, or an in-progress workflow as completion.


## Session checkpoint — 2026-11-13 (PR #44 merged; world/stage progression UI in progress)

### Section 7 — mid-run checkpoint save/restore: merged and CI-validated
- PR #44, “Add persistent mid-run checkpoint save and resume”, has been merged into `feature/procedural-game-audio-v2`.
- Merge commit: `d48b1219158d9ea2556adc87f4cbcf93388c5fc5`.
- Final-head commit tested: `024e33ecc91d8157e595a4894dfbd5ba618fc23e`.
- Final CI run `43497196443` (run 827) completed successfully. Verified steps: Flutter setup, dependency installation, Dart analysis, full Flutter tests, Android project generation, and Android debug APK build.
- Manual Android device validation of pause/background/force-close/resume behavior remains outstanding; do not mark the feature as manually gameplay-verified.
- The checkpoint does not overwrite persistent wallet coins; the player progression store remains the source of truth.

### Section 7 — world/stage unlock gates: implementation branch
- Branch: `feature/world-stage-progression`, created from the validated PR #44 head.
- Added `WorldStageProgression` as a pure rules model for six worlds with ten stages each. It clamps saved progress to stages 1–60, unlocks each next stage only as progression advances, and opens the next world at its first stage after the previous world is cleared.
- Added `WorldSelectionScreen`: all six world identities are visible; locked worlds/stages remain locked; only unlocked stages can be selected; the player's saved best stage is the default selection; starting a selected stage clears any previous run checkpoint before opening a fresh run.
- Replaced the old “new run / continue at best stage” dialog after hero selection with the actual world/stage selection screen.
- Added model boundary tests and widget tests for unlocked-world display, default stage selection, and rejection of a locked stage tap.

Files added/changed in this batch:
- `lib/world_progression.dart` (new)
- `lib/world_selection_screen.dart` (new)
- `lib/hero_selection_screen.dart`
- `test/world_progression_test.dart` (new)
- `test/world_selection_screen_test.dart` (new)
- `MISSION_PROGRESS.md`

Current verification state: world/stage implementation is committed to the feature branch but has not yet been validated by CI. Do not merge it until the new PR's Dart analysis, complete Flutter test suite, Android project generation, and Android debug APK build all pass. Physical Android UI/gameplay validation remains outstanding.

### Exact next actions
1. Open PR from `feature/world-stage-progression` into `feature/procedural-game-audio-v2`.
2. Run and inspect all CI checks on the exact latest head; fix failures before merge.
3. After CI passes, merge and record the merge SHA and run ID.
4. Continue Section 7 with stronger save-corruption recovery (including invalid payload handling, safe defaults, and preserving valid progress where possible).
5. Later, perform hands-on Android validation of checkpoint resume and world/stage selection; do not claim manual verification prematurely.
6. Keep the nine-section roadmap open; the project is not complete.


### Section 7 — save-corruption recovery hardening (added to PR #45)
- Progression reads now isolate a wrong-typed/corrupt SharedPreferences entry to that one key instead of allowing it to throw out of the whole profile load. Valid coins, gems, stage progress, counters, and equipment data in other keys remain available.
- Invalid optional run-checkpoint JSON and checkpoints stored under the wrong preference type are now discarded from the checkpoint key only. They do not affect the separately stored player progression.
- Added regression tests proving that valid progression survives a wrong-typed best-stage key, malformed checkpoint text is removed, and a wrong-typed checkpoint entry is removed without touching the wallet.
- Updated files: `lib/progress_store.dart`, `lib/run_checkpoint.dart`, `test/progress_store_test.dart`, `test/run_checkpoint_test.dart`.
- These changes are implementation-only until the latest PR #45 CI run succeeds; no manual device validation has been performed.

### Latest PR #45 CI history
- An early run on the initial world-picker draft failed Dart analysis. The failure exposed a const-expression issue in the world-count model, a literal escaped newline in the world list expression, and use of unsupported test-view setup methods. These were corrected in follow-up commits.
- Do not treat the earlier failed/cancelled runs as validation. Only the final workflow run for the exact latest head SHA can qualify the batch.


## Session checkpoint — 2026-11-13 (PR #45 merged; Section 7 automated implementation complete)

### Section 7 — world/stage selection and save recovery
- PR #45, “Add world/stage selection and harden save recovery”, merged into `feature/procedural-game-audio-v2`.
- Merge commit: `cd176d670f8c5ca92cca6375685eb3faf46e9516`.
- Final tested head: `3152ce56db437407c1e0af9633a36be13e314a80`.
- Final CI run: `43499311117` (run 864), conclusion **success** on that exact head.
- Verified job steps: Flutter setup, dependency installation, Dart analysis, full Flutter tests, Android project generation, and Android debug APK build all passed.
- The PR adds six-world/60-stage progression, Arabic world/stage selection, locked-stage interaction rules, independent recovery of wrong-typed progression values, and removal of malformed/wrong-typed optional run checkpoints without resetting valid wallet data.
- Changed files in PR #45: `lib/world_progression.dart`, `lib/world_selection_screen.dart`, `lib/hero_selection_screen.dart`, `lib/progress_store.dart`, `lib/run_checkpoint.dart`, `test/world_progression_test.dart`, `test/world_selection_screen_test.dart`, `test/progress_store_test.dart`, `test/run_checkpoint_test.dart`, and `MISSION_PROGRESS.md`.
- No physical Android device validation has been performed. World/stage selection and checkpoint resume are CI/build-validated only, not manually gameplay-verified.
- Section 7's listed implementation work is now present and CI-validated. Keep the physical-device validation gap explicit; do not call it complete as a fully verified player experience until tested on Android.

### Exact next actions
1. Audit Section 8 against the actual integrated screens and HUD; do not assume the existing screens satisfy the listed requirements just because files exist.
2. Prioritize the largest concrete missing Section 8 slice and implement it on a new feature branch from merge commit `cd176d670f8c5ca92cca6375685eb3faf46e9516`.
3. Add focused widget/model tests, update this file, open a PR, and require successful analysis, full Flutter tests, Android project generation, and debug APK build on the exact final head before merging.
4. Continue the remaining Section 8 and Section 9 requirements, then return for hands-on Android validation of checkpoint resume, world/stage selection, menus, combat, and progression.
5. Keep all remaining requirements in Sections 1–6, 8, and 9 open until implemented and verified. The game is not complete.


## Section 8 — initial persistent audio settings slice (implementation branch)
- Branch: `feature/game-settings-audio-haptics`, based on the integrated PR #45 merge.
- Added a dedicated app-settings store separate from player progression. The audio-enabled preference defaults safely to on, persists across launches, and recovers from a wrong-typed preference without blocking startup.
- Added an Arabic settings screen with a persistent master sound-effects toggle and linked it from the main menu.
- Routed the central `playRealSound` function through the saved audio preference, so disabling sound suppresses all game sound effects without changing gameplay or progression.
- Added unit tests for default settings, persistence/reload, and malformed preference recovery.
- Files added: `lib/game_settings.dart`, `lib/game_settings_screen.dart`, `test/game_settings_test.dart`.
- Files updated: `lib/main.dart`, `lib/main_menu_screen.dart`, `lib/game_progress.dart`.
- Verification is pending GitHub Actions on the final PR head. No Android device validation has been performed.
- This is only the first slice of Section 8: control customization, vibration, equipment/weapon dedicated screens, and further menu/HUD/win-loss progression polish remain open.

### Exact next actions
1. Run Dart analysis, the full Flutter test suite, Android project generation, and Android debug APK build for this branch; fix every failure on the branch's latest head.
2. Merge only after all required checks pass on the exact final head.
3. Continue Section 8 with real control/vibration settings and improved dedicated equipment/weapon screens; then continue Section 9 audio/music and effects variety. Do not mark either section complete based on this settings slice.


### Section 8 follow-up — functional vibration preference
- Extended the separate settings store with a persistent vibration toggle, default enabled and independently recoverable if its stored value has the wrong type.
- Added an Arabic vibration switch to the settings screen.
- Integrated optional Flutter haptic feedback on actual player damage (enemy projectile and boss area attack) and active-skill use. Haptics respect the saved toggle; failures from unsupported device/platform haptic channels are safely ignored.
- Expanded unit coverage for defaults, persistence, malformed values, and isolation between the audio and vibration keys.
- Added a widget test covering both settings controls and persistence of the vibration switch.
- Changed: `lib/game_settings.dart`, `lib/game_settings_screen.dart`, `lib/game_screen.dart`, `test/game_settings_test.dart`, `test/game_settings_screen_test.dart`.
- The original PR #46 CI run `43500542198` remained reported as in progress at Android debug APK build for head `46a66725f39f8ea85bb19277a7f73e47b8c12ff6`; it is not evidence for these newer commits. The updated branch must receive and pass a fresh full CI run before merge.
- Physical-device haptic behavior has not been manually validated; actual vibration depends on device hardware and OS settings.

### Exact next actions
1. Verify the new branch head and its newly triggered CI. Investigate the stale prior run separately; do not merge based on its earlier passing analysis/tests.
2. Require a fresh successful Dart analysis, full Flutter tests (including new widget test), Android project generation, and debug APK build on the exact current head.
3. Merge PR #46 only after all required checks pass.
4. Continue Section 8 by auditing the equipment/weapon selection and comparison experience, then HUD and win/loss progression; keep the original roadmap requirements open until verified.


### CI correction
- Fresh CI run `43501608553` on head `268218b32826bc89aaf3d6d9dd42e5d026c0d94c` failed during Dart analysis because `HapticFeedback` was not imported into `game_screen.dart`.
- Corrected by importing `HapticFeedback` from Flutter's services library in commit `ab461ca5b88ae98326baa129f87d4474766bd159`.
- A new full CI run on the corrected latest head is required; the failed run is not a validation pass.


## Session checkpoint — 2026-11-13 (PR #46 merged; continue Section 8)

### Section 8 — persistent audio and vibration settings
- PR #46, “Add persistent in-game audio settings”, has been merged into `feature/procedural-game-audio-v2`.
- Merge commit: `4e8b65f5af8678cebe3c05c8bf96323a16fe5b91`.
- Final tested PR head: `dd73a177ad25950ba2dbcf95994d428c8d34b3c6`.
- Final-head GitHub Actions run `43501788658` (run 890) completed successfully on that exact SHA. Dart analysis, the full Flutter test suite, Android project generation, and Android debug APK build all passed.
- Integrated functionality: persistent master sound-effects toggle; persistent vibration toggle; Arabic settings screen linked from the main menu; haptic feedback on player damage and active-skill use; malformed preference recovery; unit and widget tests.
- No physical Android device validation has been performed. Actual vibration and in-game behavior still require hands-on validation; do not describe them as manually verified.
- The PR is merged; there is no outstanding PR #46 work.

### Exact resume point
1. Audit the integrated Section 8 experience against the original requirements, starting with weapon/equipment selection, comparison, and whether a dedicated loadout screen is needed.
2. Inspect the actual integrated code and tests before changing anything; identify the largest concrete gap and implement one coherent slice.
3. Continue with HUD, win/loss/progression screens, and control customization as needed; keep each batch tested and recorded here.
4. Then continue Section 9: world-specific music, enemy/boss sounds, combat/death/explosion/skill/upgrade effects, and audio timing/variety.
5. Require successful analysis, full Flutter tests, Android project generation, and debug APK build on each final PR head before merging.
6. Physical Android gameplay validation remains outstanding across settings, haptics, checkpoint resume, world/stage selection, menus, combat, and progression. The game remains incomplete until all nine roadmap sections and final device validation are done.


## Android APK distribution pipeline — 2026-11-13
- Updated `.github/workflows/build-apk.yml` on `feature/procedural-game-audio-v2` in commit `afdabcbbe02ab0d793ea848f982d97dfa87d3238`.
- The workflow now runs on pushes to the integrated development branch, on manual `workflow_dispatch`, and on version tags matching `v*`.
- Each successful run installs Flutter/Java, regenerates the Android project, resolves dependencies, runs Dart analysis and the full Flutter test suite, installs the required Android NDK, builds a **release APK**, and uploads it as a GitHub Actions artifact for 30 days.
- Pushing a version tag such as `v0.1.0` additionally publishes a GitHub Release and attaches `app-release.apk` to it.
- This is an unsigned development APK (no production signing key has been configured). It can be sideloaded for testing; production Play Store distribution and seamless signed upgrades need a protected signing setup later.
- PR #47 remains open and its loadout-screen tests were failing on the last observed run. The APK pipeline is intentionally attached to the validated integration branch, not the unmerged PR branch, so it does not package that unvalidated feature.
- **Verification pending:** the new workflow has not yet completed on the latest integration head. Do not share a download as ready until a fresh run succeeds and its artifact/release asset is confirmed.
- Physical Android gameplay validation remains outstanding; successful APK build is not a substitute for device testing.

### Exact resume point
1. Trigger/check the new `Build Android APK` workflow on `feature/procedural-game-audio-v2`; verify analysis, tests, NDK installation, release APK build, and artifact upload all pass on the exact current head.
2. If successful, retrieve the artifact from Actions (or publish the first version tag after reviewing the build) and provide the user the direct download path.
3. Continue repairing PR #47 independently; do not include its changes in the downloadable integrated build until CI passes and it is merged.
4. Keep the nine-section game roadmap and hands-on Android validation open; this distribution workflow does not mean the game is complete.


## Visual overhaul batch — illustrated hero home hub (in progress)

Branch: `feature/visual-overhaul-home-hub`, based on the integrated game branch (through PR #46; PR #47 is intentionally not included).

Implemented in this first visual integration slice:
- Replaced the generic gamepad/icon masthead with a dedicated illustrated home-hub scene, layered environmental backdrop, framed presentation, central hero artwork, and live resource counters.
- Added visible left/right quick-navigation controls: **العتاد** scrolls to the existing equipment section and **المتجر** scrolls to the existing upgrade shop section. Existing shop, inventory, chest, achievement, settings, and stage-start flows remain in the same main menu and are not discarded.
- Registered the new vector environment artwork in Flutter assets and reused the project's current player SVG as the central character pending the full character-art replacement/animation pass.
- Added stable section keys and a managed scroll controller for the hub shortcuts.

Changed files:
- `assets/home_hub_scene.svg` (new)
- `pubspec.yaml`
- `lib/main_menu_screen.dart`
- `MISSION_PROGRESS.md`

Verification status: code has been committed to the feature branch; CI/Flutter analysis, full tests, Android build, and device visual review are still pending. This is a first integrated hub redesign slice, **not** completion of the requested visual overhaul. The next visual batch must replace/upgrade the in-game player/enemy/boss art and connect the existing sprite animation assets, then improve biome floor tiles, props, projectiles, equipment display, and combat VFX. Keep all gameplay systems intact.


### Hero grounding / anti-floating pass
- Updated `PlayerActorSpriteWidget` to anchor the hero at the arena position and remove continuous idle bobbing, idle rotation, and idle scale pulsing that made the character appear to hover.
- Walking now uses a very small bottom-aligned step bounce only while the movement window is active; attack motion remains subtle and bottom-aligned.
- Switched the player sprite frame to a 4-tick cadence while walking so the walk cycle is more visible during short touch drags.
- Commit: `147fc81d2d545fd204354259ebf4a86c1144c8be`.
- Flutter CI run `43512851070` was queued on this exact commit at checkpoint time. Device-side visual verification remains pending.


## Android Emulator QA automation — first implementation

- Added `.github/workflows/android-emulator-qa.yml`.
- On pushes to feature/main/fix branches, pull requests, and manual dispatch, CI now provisions an Android 35 Google APIs x86_64 Pixel 6 emulator.
- Pipeline generates the Android runner project, installs Flutter dependencies, runs Dart analysis, runs all unit/widget tests, then launches the app through Flutter's integration-test driver on the emulator.
- Added `integration_test/app_smoke_test.dart` to launch `ArcheroSoundApp` and verify the main-menu title and wallet are visible.
- Workflow uploads emulator screenshot and logcat evidence as a 14-day artifact, including on failures when files were captured.
- This is automated launch/UI smoke coverage, not yet automated full gameplay. Next extension: deterministic gameplay test hooks/scenarios for player movement, enemy approach/attacks, boss phases, and combat outcomes, then screenshot checkpoints for arena/loadout/shop.
- Actual first workflow execution and artifact review are pending; do not claim emulator testing has passed until the run completes successfully.


## Android Emulator QA — gameplay-route expansion

- First automated run exposed a stale main-menu widget assertion: the test expected the old `ARCHERO: SOUND EDITION` title after the home-hub redesign. Updated it to the actual `ARCHERO · SOUND EDITION` title; no assertion was weakened.
- Expanded `integration_test/app_smoke_test.dart` to launch the real app, open hero selection, choose the unlocked starter hero, enter world/stage selection, start stage 1, verify the live arena and pause control, perform a touch drag, activate the special-skill control, and assert no Flutter exception.
- Changed the emulator workflow to capture a screenshot and logcat even when the integration test fails, preserving debugging evidence.
- Emulator test execution still pending on the latest commits. It will not be marked passed until the new run completes.


## Deterministic gameplay scenario batch — in progress

Branch: `feature/visual-overhaul-home-hub`

Implemented and pushed:
- Added a stable `player-actor` widget key to the actual rendered hero sprite so automated UI tests can measure its position.
- Upgraded `integration_test/app_smoke_test.dart`: the Android route now records the hero's rendered center before and after a touch drag and asserts measurable horizontal and vertical movement, instead of merely performing a gesture.
- Added `test/gameplay_scenarios_test.dart` with deterministic outcome scenarios using the same pure gameplay resolvers used by `GameScreen`:
  - bounded player movement and dodge-window activation;
  - arrow advancement and enemy collision followed by a deterministic critical hit and HP calculation;
  - survival versus lethal enemy damage, coin-drop and score outcomes;
  - player projectile damage, dodge protection, and invulnerability;
  - lethal player damage through dying to game-over lifecycle;
  - boss health thresholds, phase-specific volley size/damage, and fan projectile directions.

Commits on this branch:
- `de31683da812def3389c7f5826f5552cc41ed4d6` — stable rendered player actor key.
- `49d222c3f8b0ef5326e5b6790a9d078bf2bd8ac4` — measured drag assertion in emulator integration test.
- `e06028eefcdbe8abde14f2cb3582d166bae7deef` — initial deterministic scenario suite.
- `0a74747d49eb3f853ee76c0400ab9c2780f7127b` — corrected survival-vs-lethal expectations in scenario suite.

Verification:
- The earlier Android Emulator QA run `43514468588` was still running its emulator integration step on the older commit `529c9ab66ae61e4622c11e48e55fc541fd2d098b`; it does not include the new measured-position assertion or scenario suite.
- Unit/widget tests and Android emulator validation for the latest commits are **pending**. Do not mark this batch verified until CI runs on the latest branch head and the emulator job passes.
- The deterministic suite verifies the combat/lifecycle resolver outcomes in isolation; it is not a substitute for full end-to-end enemy-hit/death/boss gameplay automation. Next work: expose minimal read-only diagnostic state or deterministic test fixtures at the GameScreen boundary, then drive those real game-loop outcomes in integration tests without changing production balance or weakening assertions.

### Exact resume point
1. Check the CI runs triggered by commit `0a74747d49eb3f853ee76c0400ab9c2780f7127b`; inspect and fix any failing scenario or integration assertion.
2. Confirm the Android emulator test measures actual rendered hero movement and review the uploaded screenshot/logcat artifact.
3. Add deterministic GameScreen-level scenarios for enemy projectile impact, player death animation/game-over, and boss phase/volley transitions; keep test-only controls isolated from release gameplay.
4. Update this file with exact latest SHA, run IDs, outcomes, and remaining gaps before moving to the next gameplay batch.


## القائمة التفصيلية الرسمية للمهمات

تم حفظ القائمة التفصيلية الكاملة التي أرسلها المستخدم بتاريخ 2026-11-14 في الملف DETAILED_GAME_ROADMAP.md، وتشمل الأقسام 1 إلى 10 وجميع البنود الفرعية وترقيمها كما وردت، بما في ذلك الاختبارات النهائية وضمان الجودة. هذا الملف هو المرجع التفصيلي المعتمد للتنفيذ. يجب تحديث حالة البنود فيه أو تسجيلها في هذا الملف دون تغيير نص المتطلبات أو ترقيمها.


## المهمة 1.1.1 — مراجعة جميع ملفات المشروع الحالية وتحديد وظيفة كل ملف

الحالة: 🟢 مكتملة توثيقياً.

- تمت مراجعة شجرة Git الحالية على الفرع `feature/visual-overhaul-home-hub` عند commit المرجعي `82c51c65606fb67bec32f9ea7e1aec9c36eacabd`.
- شمل الجرد جميع الملفات المتتبعة وعددها **166 ملفاً**: إعدادات الجذر، 3 ملفات CI/CD، كود `lib/`، الأصول الرسومية، الاختبارات، الاختبار التكاملي، وإعداد iOS.
- أُنشئ `PROJECT_FILE_INVENTORY.md` وفيه جدول يحدد وظيفة كل ملف، مع ملاحظات بنيوية ومخاطر/نقاط تحتاج انتباهاً.
- Commit الجرد: `777b1ad651624c8a7a6f434c01091535ac66db10`.
- لم تُجرَ أي إعادة هيكلة أو تغييرات على منطق اللعب ضمن هذا البند.
- لم تُعلن نتائج اختبارات أو CI على أنها ناجحة؛ الجرد وثائقي، وتشغيل CI ليس شرطاً لإثبات وظيفة كل ملف.
- أبرز الملاحظات: `lib/main.dart` أصبح نقطة دخول رفيعة؛ `game_screen.dart` ما زال منسق الجولة الكبير؛ وحدات العرض والقتال والحفظ والاقتصاد مفصولة بدرجات متفاوتة؛ تسجيل الأصول في `pubspec.yaml` انتقائي؛ و`ios/Runner/Info.plist` شبه فارغ (بايت واحد).

رابط الجرد: https://github.com/fadimatar112211-bit/Archero_fm/blob/feature/visual-overhaul-home-hub/PROJECT_FILE_INVENTORY.md

**نطاق التنفيذ:** اكتمل 1.1.1 فقط. لم يبدأ 1.1.2 ولم تُغيّر حالته.


## المهمة 1.1.2 — فصل أنظمة اللاعب عن نظام القتال

الحالة: 🟡 نُفّذ الفصل المعماري الأولي؛ التحقق الآلي من أحدث commit قيد الانتظار.

- أُضيف `lib/player_system.dart` كواجهة نطاق موحدة لنظام اللاعب، وتجمع الوصول إلى ملف البطل وإحصاءات بدء الجولة، وحركة اللاعب، واختيار الهدف، وإنشاء رمية الأسهم، وتحديث مقذوفات اللاعب.
- أصبحت شاشة اللعب `lib/game_screen.dart` تستدعي `PlayerSystem` بدلاً من استيراد تفاصيل `hero_rules.dart` و`player_movement.dart` و`player_attack.dart` و`player_projectiles.dart` و`combat_targeting.dart` و`combat_collision.dart` مباشرة.
- أخفى الحدّ الجديد أنواع هندسة القتال `CombatPoint` و`CombatCircle` عن شاشة اللعبة؛ أصبحت واجهة اللاعب تتعامل مع `PlayerTarget` و`PlayerArrowState` و`PlayerArrowUpdate`.
- بقيت حسابات الضرر والتصادم المشتركة وقواعد توقيت القتال ضمن وحدات القتال، ولم تُنقل إلى نظام اللاعب. كما بقيت واجهات اللعبة وسلوك الأبطال والأسلحة والمعدات والاقتصاد دون حذف أو تغيير مقصود.
- أُضيف `test/player_system_test.dart` لاختبار تهيئة البطل والحركة واختيار الهدف وإنشاء الأسهم وتحديثها/تصادمها.
- حُدّث `PROJECT_FILE_INVENTORY.md` ليشمل ملف نظام اللاعب الجديد والاختبار.

Commits:
- `54b17f261e71be0e459abb7ccca11086ff61428f` — إضافة واجهة نظام اللاعب.
- `59bf87d48254ede6677cc3303d3be946007d53b2` — توصيل شاشة اللعب بواجهة نظام اللاعب.
- `474b7ceece056766f31fb2c5c66851b5f642d966` — إصلاح تأهيل اعتماديات هندسة القتال داخل الواجهة.
- `5dd6a2fb19173327c4b37804f806ca727c65cb05` — اختبارات واجهة نظام اللاعب.
- `8570606dc966b8fc67d2647b05fe7d7967e87f83` — تحديث جرد الملفات.

**معيار الإغلاق:** لا تُعلن المهمة مكتملة نهائياً إلا بعد نجاح تحليل Dart واختبارات Flutter على أحدث commit، ومراجعة عدم وجود استيرادات مباشرة من تفاصيل اللاعب/هندسة القتال في `game_screen.dart`.


### تحقق إضافي للمهمة 1.1.2 — 2026-11-14

- تمت مراجعة imports ومراجع `game_screen.dart` بعد آخر commit: لا يستورد الشاشة أيّاً من `hero_rules.dart` أو `player_movement.dart` أو `player_attack.dart` أو `player_projectiles.dart` أو `combat_targeting.dart` أو `combat_collision.dart`، ولا تستخدم أنواع `CombatPoint`/`CombatCircle` أو دوال الحساب الداخلية مباشرة. جميع نقاط الاتصال الست الخاصة بالبطل/الحركة/التصويب/السهام تمر عبر `PlayerSystem`.
- تحقق ساكن من حالات الاختبار الأربع المضافة: قيم ملف البطل والإحصاءات، حدود السحب ونافذة المراوغة، اختيار الهدف وتكوين volley، وتقدم السهم واكتشاف الاصطدام.
- CI على آخر commit وقت التحديث `1cec1204649940d8358d95a66fefed3c800bdc78`: Flutter CI run `43522963763` ما زال قيد التنفيذ عند خطوة الاختبارات؛ Android Emulator QA run `43522963831` ما زال قيد التنفيذ عند الاختبارات. لذلك لا توجد نتيجة نجاح نهائية بعد، ولا نغلق البند قبل ظهورها.
- روابط المتابعة: https://github.com/fadimatar112211-bit/Archero_fm/actions/runs/43522963763 و https://github.com/fadimatar112211-bit/Archero_fm/actions/runs/43522963831


## اتفاقية أسلوب التنفيذ والتحقق — 2026-11-14

تم الاتفاق على اعتماد تحقق مرحلي أسرع من دون تقليل الجودة:
- بعد كل بند فرعي: مراجعة الكود، تحليل Dart والفحوص الساكنة، واختبارات الوحدة المستهدفة المرتبطة بالتعديل؛ لا يُشغّل المحاكي تلقائياً بعد كل بند.
- بعد كل مجموعة مترابطة: اختبارات تكامل مناسبة للتحقق من تفاعل الأنظمة.
- اختبار Android Emulator عند اكتمال مجموعة كبيرة ذات تغييرات مؤثرة على التشغيل/الواجهات/التفاعل، أو عندما يكون ضرورياً لإثبات سلوك لا تغطيه الاختبارات الأخرى.
- بعد كل مهمة رئيسية: تحقق شامل مناسب لنطاقها، مع المحاكي عند الحاجة.
- قبل إعلان الجاهزية النهائية للعبة: اختبار شامل لمسارات اللعب الأساسية والتقدم والواجهات على المحاكي/الأجهزة المستهدفة وتوثيق الأدلة.
- لا تُضعف الاختبارات لتسريع العمل، ولا يُعد نجاح التحليل أو اختبارات الوحدة أو بناء APK وحده إثباتاً لنجاح تجربة اللعب الفعلية.
- تُجمع التغييرات الصغيرة المترابطة لتقليل تكرار تشغيل المحاكي، مع إصلاح أي فشل حقيقي قبل البناء عليه.

### نتيجة التحقق الحالية للمهمة 1.1.2
- Commit الإصلاح: `91def16058cc59b03c65da0664dbf519c5ebb6e2` (تصحيح اتجاهات التوقع في اختبار رشقة الزعيم؛ لم يتغير منطق القتال).
- Flutter CI: التشغيلان `43523460948` و`43523468168` اكتملَا بنجاح على SHA نفسه؛ التحليل والاختبارات وبناء Android debug APK نجحت.
- Android Emulator QA: التشغيلان `43523467923` و`43523460818` ما زالا قيد التنفيذ عند خطوة تشغيل التطبيق على المحاكي؛ خطوات التحليل واختبارات الوحدة والواجهات نجحت بالفعل.
- وفق الاتفاقية الجديدة، لا يُشترط تشغيل المحاكي لكل بند فرعي. ننتظر نتيجة التشغيل الحالي لأنه بدأ بالفعل، ثم يُعتمد مستوى الاختبار المطلوب لكل دفعة بحسب طبيعة التغيير.
- لا يُسجّل نجاح اختبار المحاكي قبل اكتماله بنتيجة `success`.


## المهمة 1.1.3 — فصل نظام الأعداء عن نظام الزعماء (قيد التنفيذ)

بدأ التنفيذ على الفرع `feature/visual-overhaul-home-hub` انطلاقاً من commit `3e61f1a55a128d1cad992f8055d0405c793eaa6a`.

الدفعة الأولى:
- فصل إنشاء كيان الزعيم إلى `lib/boss_spawn.dart عبر `createBossForStage`، وأصبح `lib/enemy_spawn.dart` مسؤولاً عن موجات الأعداء العاديين فقط.
- أُضيف توجيه إنشاء المرحلة في `GameScreen` بحيث يختار مولّد الزعيم أو مولّد الأعداء حسب نوع المرحلة، مع الحفاظ على مسار موجات التحدي.
- أُضيفت اختبارات منفصلة لإنشاء الزعيم، وعُدلت اختبارات مولّد الأعداء لتثبت أنه لا ينشئ زعيماً.
- حُدّث جرد الملفات ليشمل ملف إنشاء الزعيم واختباره.

ما تبقى لإكمال 1.1.3:
- فصل قرارات حركة الزعيم عن ذكاء الأعداء العاديين.
- فصل قواعد هجمات الزعيم وضرر التلامس والهجوم المساحي عن `EnemyAttackRules`.
- فصل دورة تحديث الزعيم ومقذوفاته عن حلقة تحديث الأعداء في `GameScreen` مع إبقاء واجهات العرض وحالة الجولة متوافقة.
- إضافة اختبارات تغطي تفاعل دورة الزعيم مع اللاعب ومراحل الزعيم، ثم مراجعة التكامل بين النظامين.

التحقق:
- لم تُشغّل اختبارات Flutter بعد لهذه الدفعة؛ يلزم تشغيل التحليل والاختبارات المستهدفة قبل اعتمادها.
- وفق اتفاقية التحقق المرحلي، لا يُطلب Android Emulator بعد هذه الدفعة الصغيرة؛ يُجمع مع تحقق مجموعة التغييرات المتكاملة أو عند الحاجة لإثبات سلوك لا تغطيه الاختبارات الآلية.
- لا تُعتبر المهمة 1.1.3 مكتملة، ولا يتغير نص القائمة التفصيلية أو ترقيمها.


### ضبط تشغيل Android Emulator حسب اتفاقية التحقق المرحلي
- عُدّل `.github/workflows/android-emulator-qa.yml` ليعمل عبر `workflow_dispatch` فقط؛ لم يعد يبدأ تلقائياً مع كل push أو تحديث PR.
- تبقى Flutter CI والتحليل والاختبارات الآلية تعمل تلقائياً، ويُشغّل المحاكي يدوياً عند اكتمال مجموعة مترابطة أو مهمة رئيسية/عندما يلزم إثبات سلوك فعلي.
- هذا التعديل يطبق الاتفاقية المتفق عليها ويمنع تكرار اختبار المحاكي لكل بند صغير.


### استكمال المهمة 1.1.3 — فصل حركة الزعيم والتحقق من فشل الدفعة الأولى

- اكتُشف فشل Flutter CI رقم 43526188017 واختبار Android QA رقم 43526188031 على commit 133a207؛ التحليل نجح لكن الاختبارات فشلت بسبب بقاء اختبار قديم داخل enemy_spawn_test يتوقع أن موجة الأعداء تعيد زعيماً في المرحلة 15، وهو سلوك أزيل عمداً عند فصل مولّد الزعيم.
- نُقل التحقق من صحة HP والسرعة المتدرجة للزعيم إلى test/boss_spawn_test.dart (حيث كان الاختبار المكافئ موجوداً بالفعل)، وحُذف التوقع المتعارض من test/enemy_spawn_test.dart. Commit: 4dfd191f9fdb32f2ca4b620c1aa491e9524b37da.
- فُصلت قرارات حركة الزعيم عن enemy_ai.dart إلى lib/boss_movement.dart، وأصبحت enemy_ai.dart تحوي سلوك الأعداء العاديين فقط. GameScreen يوجّه حركة الزعيم إلى decideBossMovement وحركة بقية الأنواع إلى decideEnemyMovement. Commits: b079990560928bace2b8e22949f08531bede5350، 76b0e9dfda4a870fd9c844f759b002da3ecd909b، 3276eef30a26e989fd6f422caac782b71cb312db.
- أُضيفت اختبارات مستقلة لحركة الزعيم في test/boss_movement_test.dart، وحُدّثت اختبارات enemy_ai لاختبار الأنواع العادية فقط. Commits: bdda8ad86febdd2a2203ae30e75141aa7e53f5ac و f4191ee46007b1a18f1dab44b5aefd1967e6815f.
- Flutter CI على commit bdda8ad86febdd2a2203ae30e75141aa7e53f5ac بدأ (run 43526757888)؛ لم تكن نتيجته النهائية معروفة عند آخر تحديث. يلزم التأكد من أحدث تشغيل بعد آخر commit.
- لم يُشغّل Android Emulator؛ التغييرات ما زالت ضمن دفعة إعادة هيكلة واختبارات وحدة، وفق الاتفاقية لا يُشغّل المحاكي بعد كل بند صغير.
- ما يزال ضمن 1.1.3 فصل قواعد هجمات الزعيم وضرر التلامس/الهجوم المساحي عن EnemyAttackRules، ثم عزل دورة تحديث الزعيم ومقذوفاته عن حلقة الأعداء، وإضافة اختبارات تكامل للنظامين. المهمة غير مكتملة.
