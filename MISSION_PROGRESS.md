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

Section 7 progress: persistent hero unlocks are now implemented. The starter hero remains unlocked; the other three heroes can be unlocked for 50/75/100 gems. Unlocks and gem deductions are saved in the same complete progression snapshot, failed saves roll back the purchase, and locked heroes cannot start a run. Remaining in Section 7: save/restore the active run, achievement persistence/rewards (implemented in the current follow-up branch but awaiting merge), world/stage unlock gates, and stronger corruption recovery.


### Follow-up — Section 7: persistent hero unlocks

Implemented in merged PR #42:
- Added a validated four-hero ownership bitmask to `PlayerProgress` and `ProgressStore`, including legacy-safe defaults that keep the starter hero unlocked.
- Added startup restoration and full-snapshot save support for unlocked heroes.
- Added hero selection lock states and gem prices: 50 gems for the flame hero, 75 for the shadow hero, and 100 for the storm hero.
- Locked heroes cannot enter a run. The selected hero becomes available immediately after a successful persistent unlock.
- Gem deductions and ownership changes are saved together; a storage failure restores the previous balance and ownership mask.
- Kept hero ownership intact through chest purchases, equipment actions, and health/attack shop upgrades.
- Added tests for ownership-mask normalization, persistence, and the successful hero unlock UI flow.

Remaining in Section 7: mid-run checkpoint save/restore, achievements and reward claims, world/stage unlock gates, and stronger save corruption recovery.


### Follow-up PR #43 — persistent achievements and reward claims

Branch: `feature/persistent-achievements-and-reward-claims`

Status: implementation and tests are committed on this branch. Latest-head CI is running; PR creation and merge are pending successful validation.

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

Remaining in Section 7: mid-run checkpoint save/restore, world/stage unlock gates, and stronger save corruption recovery. The achievement system is an initial persistent milestone set; more progression goals and reward tuning remain open.


## Session checkpoint — 2026-11-13 (latest verified state)

This checkpoint was added after reviewing GitHub PRs #41, #42, and #43 and the current contents of this progress file. Use it as the resume point next session; do not repeat the completed work listed above.

### Verified PR states
- PR #41, “Add boss-gated special room choices and rewards”: **merged** into `feature/procedural-game-audio-v2` on 2026-11-13. Merge commit: `81cdd3b947003b0cefa54541b0d948ecbf448c80`. Final-head CI runs `43482791474` and `43482784424` succeeded (Dart analysis, Flutter tests, Android project generation, Android debug APK build).
- PR #42, “Add persistent resource wallet and reward chests”: **merged** into `feature/procedural-game-audio-v2` on 2026-11-13. Merge commit: `77a2347cbf264e8d2e5760209148bd70b7b34aff`. Final-head CI runs `43488128681` and `43488116406` succeeded (Dart analysis, Flutter tests, Android project generation, Android debug APK build).
- PR #43, “Add persistent achievements and one-time reward claims”: **open, not merged** at this checkpoint. Branch: `feature/persistent-achievements-and-reward-claims`. Head commit: `9be87b14d4a93e2244d4b55d23e264e406510aa3`. The two GitHub Actions check runs on this head (`43491077166` and `43491060914`) are completed successfully. PR #43 changes 14 files, including the achievement implementation, persistence integration, tests, and this progress file. Do not describe PR #43 as merged until GitHub confirms the merge.

### Exact resume point
- The latest implementation batch is PR #43: persistent achievements and one-time reward claims (details and changed-file list are recorded in the section above).
- The next action is to review PR #43's latest diff and CI result, then merge it only after confirming the checks are green and the branch/base integration is safe. After merge, verify the integrated branch state and record the merge commit here.
- After PR #43, continue Section 7 with mid-run checkpoint save/restore, then world/stage unlock gates, and stronger save-corruption recovery. Keep Section 7 marked partial until these requirements are implemented and verified.
- Other still-open requirements remain as recorded in the nine-section roadmap above; merging PRs #41–#43 does not mean the full game is complete.

### Progress-recording rule for future sessions
After every coherent implementation batch, update this `MISSION_PROGRESS.md` in the active working branch with: roadmap section/item, what changed, exact files, tests and build results, CI run IDs and outcomes, PR number/state, merge commit (if merged), remaining gaps, and the exact next action. Keep statuses evidence-based (implemented, tested, built, manually gameplay-verified are distinct). Before stopping a session, write a fresh “Session checkpoint” so the next session can resume without asking the user to reconstruct the history.
