# جرد ملفات مشروع Archero_fm — المهمة 1.1.1

- المتطلب كما ورد حرفياً: **مراجعة جميع ملفات المشروع الحالية وتحديد وظيفة كل ملف.**
- تاريخ الجرد: 2026-11-14.
- الفرع الذي تمت مراجعته: `feature/visual-overhaul-home-hub`.
- مرجع الشجرة: `82c51c65606fb67bec32f9ea7e1aec9c36eacabd`.
- نطاق الجرد: جميع الملفات المتتبعة في Git ضمن الشجرة عند الجرد الأصلي، وعددها **166 ملفاً**؛ أضيف لاحقاً ملف نظام اللاعب `lib/player_system.dart`. يشمل ذلك ملفات الإعداد وCI والكود والأصول والاختبارات. لا يشمل ملفات build أو cache غير المتتبعة.
- هذا الجرد توثيقي فقط؛ لم تُنقل ملفات ولم يُحذف أو يُعدّل منطق اللعب ضمن المهمة.

## جرد الملفات ووظائفها

### ملفات الجذر والإعدادات (5)

| الملف | الوظيفة |
|---|---|
| `DETAILED_GAME_ROADMAP.md` | القائمة التفصيلية الرسمية للمهمات 1–10؛ نص المتطلبات وترقيمها مرجع ثابت. |
| `MISSION_PROGRESS.md` | سجل تقدم التنفيذ ونقاط الاستئناف والـ commits ونتائج التحقق والفجوات. |
| `ROADMAP.md` | خارطة طريق عامة للمشروع؛ مرجع تخطيطي إضافي ولا تستبدل القائمة التفصيلية الرسمية. |
| `codemagic.yaml` | إعداد Codemagic لبناء/تجهيز التطبيق على منصة CI. |
| `pubspec.yaml` | تعريف حزمة Flutter وقيود Dart والاعتماديات وتسجيل الأصول. |

### سير عمل CI/CD (3)

| الملف | الوظيفة |
|---|---|
| `.github/workflows/android-emulator-qa.yml` | CI لتجهيز Android emulator وتشغيل التحليل والاختبارات والتكامل وحفظ screenshot وlogcat كأدلة. |
| `.github/workflows/build-apk.yml` | CI لبناء APK بعد تجهيز Flutter/Android وتشغيل الفحوصات ورفع artifact. |
| `.github/workflows/flutter-ci.yml` | CI لفحوص Flutter والتحليل والاختبارات على تغييرات المستودع. |

### كود التطبيق lib/ (59)

| الملف | الوظيفة |
|---|---|
| `lib/achievement_system.dart` | منطق تعريف الإنجازات، شروط فتحها ومكافآتها واستحقاقها. |
| `lib/audio_service.dart` | خدمة تشغيل وإدارة المؤثرات/الموسيقى الصوتية وإعدادات الصوت. |
| `lib/boss_combat.dart` | قواعد منطق قتال الزعماء ومراحل/نتائج هجماتهم. |
| `lib/boss_movement.dart` | قرارات حركة الزعيم المستقلة، بما فيها اندفاعة الشحن وتأثير مرحلة الزعيم والغضب. |
| `lib/boss_projectiles.dart` | إنشاء/حركة/قواعد مقذوفات الزعماء. |
| `lib/boss_spawn.dart` | إنشاء كيان الزعيم وخصائصه الأساسية بمعزل عن مولّد موجات الأعداء العاديين. |
| `lib/coin_collection.dart` | قواعد التقاط العملات وحساب نواتج الجمع. |
| `lib/combat_collision.dart` | حسابات كشف التصادم بين عناصر القتال. |
| `lib/combat_damage.dart` | قواعد حساب الضرر وتطبيقه على أطراف القتال. |
| `lib/combat_effects.dart` | تعريف/إدارة تأثيرات القتال المؤقتة. |
| `lib/combat_stats.dart` | إحصاءات القتال ومعدلاته الأساسية. |
| `lib/combat_targeting.dart` | اختيار أهداف اللاعب وترتيبها/تحديد الأقرب. |
| `lib/combat_timing.dart` | ثوابت وقواعد توقيت الهجمات والقتال. |
| `lib/enemy_ai.dart` | قرارات وسلوك الذكاء الاصطناعي للأعداء. |
| `lib/enemy_attack_rules.dart` | قواعد أنماط وهجمات الأعداء. |
| `lib/enemy_hit_resolution.dart` | تحديد نتيجة إصابة العدو وتطبيق آثارها. |
| `lib/enemy_projectile_motion.dart` | حساب حركة مقذوفات الأعداء. |
| `lib/enemy_spawn.dart` | توليد موجات الأعداء العاديين فقط وتحديد خصائص/أماكن ظهورهم. |
| `lib/equipment_system.dart` | تعريف المعدات وخصائصها وامتلاكها وتجهيزها. |
| `lib/game_actor_widgets.dart` | عناصر واجهة عرض اللاعب والأعداء والعملات والمقذوفات داخل الساحة. |
| `lib/game_arena_view.dart` | واجهة عرض الساحة؛ تستقبل حالة للقراءة وتبلغ تفاعلات المستخدم عبر callbacks. |
| `lib/game_diagnostics.dart` | تجميع/تسجيل أخطاء التطبيق والتشخيص. |
| `lib/game_overlay_widgets.dart` | عناصر HUD وطبقات الإيقاف المؤقت والعروض فوق ساحة اللعب. |
| `lib/game_painters.dart` | رسّامات Flutter المخصصة للساحة والشخصيات والمؤثرات والبيئة. |
| `lib/game_progress.dart` | حالة/بيانات التقدم العامة المشتركة بين الشاشات. |
| `lib/game_render_rules.dart` | قواعد مساعدة للرسم والعرض وتطبيع قيم الواجهة. |
| `lib/game_run_checkpoint_adapter.dart` | تحويل حالة الجولة إلى checkpoint قابل للتخزين والعكس مع التحقق من سلامته. |
| `lib/game_run_lifecycle.dart` | آلة حالات دورة الجولة (نشطة/متوقفة/مكافأة/موت/انتهاء). |
| `lib/game_run_session.dart` | حاوية/منسق جلسة الجولة وحالتها. |
| `lib/game_run_state.dart` | نموذج حالة الجولة وبياناتها المتغيرة. |
| `lib/game_screen.dart` | منسق شاشة اللعب وحلقة المحاكاة وربط أنظمة اللعب والعرض. |
| `lib/game_settings.dart` | إعدادات اللعبة وتخزين/تحميل تفضيلات الصوت والاهتزاز. |
| `lib/game_settings_screen.dart` | واجهة تغيير إعدادات اللعبة. |
| `lib/game_timers.dart` | تنظيم المؤقتات/عدادات التحديث الخاصة باللعبة. |
| `lib/hero_rules.dart` | قواعد الأبطال وخصائصهم وسلوكهم. |
| `lib/hero_selection_screen.dart` | واجهة اختيار الأبطال والتحقق من الإتاحة. |
| `lib/main.dart` | نقطة تشغيل Flutter، تهيئة الأخطاء والإعدادات والتقدم ثم تشغيل التطبيق. |
| `lib/main_menu_screen.dart` | القائمة الرئيسية/مركز اللعبة واختصارات الأقسام والموارد والمتجر والعتاد. |
| `lib/player_attack.dart` | قواعد هجوم اللاعب وإطلاق الهجمات. |
| `lib/player_movement.dart` | قواعد حركة اللاعب وحدودها/المراوغة. |
| `lib/player_progress.dart` | نموذج تقدم اللاعب وبياناته الدائمة. |
| `lib/player_projectiles.dart` | قواعد مقذوفات اللاعب وحركتها. |
| `lib/player_system.dart` | واجهة/حدّ موحد لنظام اللاعب: إعداد البطل، الحركة، اختيار الهدف، إنشاء سهام اللاعب وتحديثها؛ يخفي تفاصيل هندسة القتال عن شاشة اللعبة. |
| `lib/procedural_audio.dart` | توليد/تعريف الصوت الإجرائي دون ملفات صوتية ثابتة. |
| `lib/progress_store.dart` | طبقة حفظ/تحميل تقدم اللاعب والموارد والمعدات والإنجازات مع تسلسل الكتابة. |
| `lib/resource_economy.dart` | قواعد موارد اللعبة ومحفظتها وتغير أرصدتها. |
| `lib/room_flow.dart` | قواعد الانتقال وتدفق الغرف. |
| `lib/room_layout.dart` | تعريف تخطيط الغرف ومواقع عناصرها. |
| `lib/run_checkpoint.dart` | نموذج checkpoint للجولة وواجهة تخزينه. |
| `lib/shop_economy.dart` | قواعد أسعار المتجر وشراء الترقيات والتحقق من الرصيد. |
| `lib/skill_selection_dialog.dart` | واجهة اختيار مكافأة/مهارة الجولة. |
| `lib/skill_system.dart` | تعريف المهارات وتأثيراتها وتآزرها وترقيتها. |
| `lib/special_room_dialog.dart` | واجهة اختيار/عرض خيارات الغرف الخاصة. |
| `lib/special_room_system.dart` | قواعد وأنواع الغرف الخاصة ومكافآتها. |
| `lib/stage_flow.dart` | قواعد تدفق المراحل والانتقال بينها. |
| `lib/weapon_system.dart` | تعريف الأسلحة وخصائصها وسلوك تجهيزها. |
| `lib/world_progression.dart` | قواعد فتح العوالم والتقدم بينها. |
| `lib/world_rules.dart` | قواعد اللعب المرتبطة بالعالم/المرحلة. |
| `lib/world_selection_screen.dart` | واجهة اختيار العالم والمرحلة. |
| `lib/world_theme.dart` | بيانات الهوية البصرية وألوان العوالم وربط المراحل بها. |

### الأصول assets/ (41)

| الملف | الوظيفة |
|---|---|
| `assets/arrow.svg` | رسم سهم اللاعب بصيغة متجهية. |
| `assets/boss.svg` | رسم الزعيم بصيغة متجهية. |
| `assets/coin.svg` | رسم العملة بصيغة متجهية. |
| `assets/enemy_melee.svg` | رسم العدو القريب بصيغة متجهية. |
| `assets/enemy_ranged.svg` | رسم العدو بعيد المدى بصيغة متجهية. |
| `assets/fireball.svg` | رسم المقذوف الناري بصيغة متجهية. |
| `assets/home_hub_scene.svg` | مشهد SVG البيئي لخلفية مركز القائمة الرئيسية بصيغة متجهية. |
| `assets/player.svg` | الرسم الثابت الأساسي للاعب بصيغة متجهية. |
| `assets/spritesheets/boss_attack.svg` | إطارات حركة/أنيميشن للعدو أو الزعيم: الهجوم، وتُستخدم لعرض الإطارات المتتابعة. |
| `assets/spritesheets/boss_death.svg` | إطارات حركة/أنيميشن للعدو أو الزعيم: الموت، وتُستخدم لعرض الإطارات المتتابعة. |
| `assets/spritesheets/boss_walk.svg` | إطارات حركة/أنيميشن للعدو أو الزعيم: المشي، وتُستخدم لعرض الإطارات المتتابعة. |
| `assets/spritesheets/enemy_death.svg` | إطارات حركة/أنيميشن للعدو أو الزعيم: الموت، وتُستخدم لعرض الإطارات المتتابعة. |
| `assets/spritesheets/enemy_melee.svg` | إطارات حركة/أنيميشن للعدو أو الزعيم: إطارات الشخصية، وتُستخدم لعرض الإطارات المتتابعة. |
| `assets/spritesheets/enemy_melee_attack.svg` | إطارات حركة/أنيميشن للعدو أو الزعيم: الهجوم، وتُستخدم لعرض الإطارات المتتابعة. |
| `assets/spritesheets/enemy_ranged.svg` | إطارات حركة/أنيميشن للعدو أو الزعيم: إطارات الشخصية، وتُستخدم لعرض الإطارات المتتابعة. |
| `assets/spritesheets/enemy_runner.svg` | إطارات حركة/أنيميشن للعدو أو الزعيم: إطارات الشخصية، وتُستخدم لعرض الإطارات المتتابعة. |
| `assets/spritesheets/enemy_runner_attack.svg` | إطارات حركة/أنيميشن للعدو أو الزعيم: الهجوم، وتُستخدم لعرض الإطارات المتتابعة. |
| `assets/spritesheets/enemy_runner_death.svg` | إطارات حركة/أنيميشن للعدو أو الزعيم: الموت، وتُستخدم لعرض الإطارات المتتابعة. |
| `assets/spritesheets/enemy_stalker.svg` | إطارات حركة/أنيميشن للعدو أو الزعيم: إطارات الشخصية، وتُستخدم لعرض الإطارات المتتابعة. |
| `assets/spritesheets/enemy_stalker_attack.svg` | إطارات حركة/أنيميشن للعدو أو الزعيم: الهجوم، وتُستخدم لعرض الإطارات المتتابعة. |
| `assets/spritesheets/enemy_stalker_death.svg` | إطارات حركة/أنيميشن للعدو أو الزعيم: الموت، وتُستخدم لعرض الإطارات المتتابعة. |
| `assets/spritesheets/enemy_tank.svg` | إطارات حركة/أنيميشن للعدو أو الزعيم: إطارات الشخصية، وتُستخدم لعرض الإطارات المتتابعة. |
| `assets/spritesheets/enemy_tank_attack.svg` | إطارات حركة/أنيميشن للعدو أو الزعيم: الهجوم، وتُستخدم لعرض الإطارات المتتابعة. |
| `assets/spritesheets/enemy_tank_death.svg` | إطارات حركة/أنيميشن للعدو أو الزعيم: الموت، وتُستخدم لعرض الإطارات المتتابعة. |
| `assets/spritesheets/player_attack.svg` | إطارات حركة/أنيميشن للبطل: الهجوم، وتُستخدم لعرض الإطارات المتتابعة. |
| `assets/spritesheets/player_death.svg` | إطارات حركة/أنيميشن للبطل: الموت، وتُستخدم لعرض الإطارات المتتابعة. |
| `assets/spritesheets/player_flame_attack.svg` | إطارات حركة/أنيميشن للبطل: الهجوم، وتُستخدم لعرض الإطارات المتتابعة. |
| `assets/spritesheets/player_flame_death.svg` | إطارات حركة/أنيميشن للبطل: الموت، وتُستخدم لعرض الإطارات المتتابعة. |
| `assets/spritesheets/player_flame_idle.svg` | إطارات حركة/أنيميشن للبطل: الوقوف والخمول، وتُستخدم لعرض الإطارات المتتابعة. |
| `assets/spritesheets/player_flame_walk.svg` | إطارات حركة/أنيميشن للبطل: المشي، وتُستخدم لعرض الإطارات المتتابعة. |
| `assets/spritesheets/player_idle.svg` | إطارات حركة/أنيميشن للبطل: الوقوف والخمول، وتُستخدم لعرض الإطارات المتتابعة. |
| `assets/spritesheets/player_shadow_attack.svg` | إطارات حركة/أنيميشن للبطل: الهجوم، وتُستخدم لعرض الإطارات المتتابعة. |
| `assets/spritesheets/player_shadow_death.svg` | إطارات حركة/أنيميشن للبطل: الموت، وتُستخدم لعرض الإطارات المتتابعة. |
| `assets/spritesheets/player_shadow_idle.svg` | إطارات حركة/أنيميشن للبطل: الوقوف والخمول، وتُستخدم لعرض الإطارات المتتابعة. |
| `assets/spritesheets/player_shadow_walk.svg` | إطارات حركة/أنيميشن للبطل: المشي، وتُستخدم لعرض الإطارات المتتابعة. |
| `assets/spritesheets/player_storm_attack.svg` | إطارات حركة/أنيميشن للبطل: الهجوم، وتُستخدم لعرض الإطارات المتتابعة. |
| `assets/spritesheets/player_storm_death.svg` | إطارات حركة/أنيميشن للبطل: الموت، وتُستخدم لعرض الإطارات المتتابعة. |
| `assets/spritesheets/player_storm_idle.svg` | إطارات حركة/أنيميشن للبطل: الوقوف والخمول، وتُستخدم لعرض الإطارات المتتابعة. |
| `assets/spritesheets/player_storm_walk.svg` | إطارات حركة/أنيميشن للبطل: المشي، وتُستخدم لعرض الإطارات المتتابعة. |
| `assets/spritesheets/player_walk.svg` | إطارات حركة/أنيميشن للبطل: المشي، وتُستخدم لعرض الإطارات المتتابعة. |
| `assets/wall.svg` | رسم حاجز/جدار البيئة بصيغة متجهية. |

### الاختبارات test/ (59)

| الملف | الوظيفة |
|---|---|
| `test/achievement_system_test.dart` | اختبارات آلية لوحدة/ميزة achievement system؛ تتحقق من السلوك المحدد في حالات الاختبار. |
| `test/arena_painter_test.dart` | اختبارات آلية لوحدة/ميزة arena painter؛ تتحقق من السلوك المحدد في حالات الاختبار. |
| `test/audio_service_test.dart` | اختبارات آلية لوحدة/ميزة audio service؛ تتحقق من السلوك المحدد في حالات الاختبار. |
| `test/boss_combat_test.dart` | اختبارات آلية لوحدة/ميزة boss combat؛ تتحقق من السلوك المحدد في حالات الاختبار. |
| `test/boss_projectiles_test.dart` | اختبارات آلية لوحدة/ميزة boss projectiles؛ تتحقق من السلوك المحدد في حالات الاختبار. |
| `test/boss_movement_test.dart` | اختبارات قرارات حركة الزعيم المستقلة وتدرج السرعة حسب المرحلة والغضب. |
| `test/boss_spawn_test.dart` | اختبارات إنشاء الزعيم وخصائصه وتدرج صحته وسرعته بمعزل عن موجات الأعداء. |
| `test/coin_collection_test.dart` | اختبارات آلية لوحدة/ميزة coin collection؛ تتحقق من السلوك المحدد في حالات الاختبار. |
| `test/combat_collision_test.dart` | اختبارات آلية لوحدة/ميزة combat collision؛ تتحقق من السلوك المحدد في حالات الاختبار. |
| `test/combat_damage_test.dart` | اختبارات آلية لوحدة/ميزة combat damage؛ تتحقق من السلوك المحدد في حالات الاختبار. |
| `test/combat_effects_test.dart` | اختبارات آلية لوحدة/ميزة combat effects؛ تتحقق من السلوك المحدد في حالات الاختبار. |
| `test/combat_stats_test.dart` | اختبارات آلية لوحدة/ميزة combat stats؛ تتحقق من السلوك المحدد في حالات الاختبار. |
| `test/combat_targeting_test.dart` | اختبارات آلية لوحدة/ميزة combat targeting؛ تتحقق من السلوك المحدد في حالات الاختبار. |
| `test/combat_timing_test.dart` | اختبارات آلية لوحدة/ميزة combat timing؛ تتحقق من السلوك المحدد في حالات الاختبار. |
| `test/enemy_ai_test.dart` | اختبارات آلية لوحدة/ميزة enemy ai؛ تتحقق من السلوك المحدد في حالات الاختبار. |
| `test/enemy_attack_rules_test.dart` | اختبارات آلية لوحدة/ميزة enemy attack rules؛ تتحقق من السلوك المحدد في حالات الاختبار. |
| `test/enemy_hit_resolution_test.dart` | اختبارات آلية لوحدة/ميزة enemy hit resolution؛ تتحقق من السلوك المحدد في حالات الاختبار. |
| `test/enemy_projectile_motion_test.dart` | اختبارات آلية لوحدة/ميزة enemy projectile motion؛ تتحقق من السلوك المحدد في حالات الاختبار. |
| `test/enemy_spawn_test.dart` | اختبارات آلية لوحدة/ميزة enemy spawn؛ تتحقق من السلوك المحدد في حالات الاختبار. |
| `test/equipment_system_test.dart` | اختبارات آلية لوحدة/ميزة equipment system؛ تتحقق من السلوك المحدد في حالات الاختبار. |
| `test/game_arena_view_test.dart` | اختبارات آلية لوحدة/ميزة game arena view؛ تتحقق من السلوك المحدد في حالات الاختبار. |
| `test/game_diagnostics_test.dart` | اختبارات آلية لوحدة/ميزة game diagnostics؛ تتحقق من السلوك المحدد في حالات الاختبار. |
| `test/game_progress_test.dart` | اختبارات آلية لوحدة/ميزة game progress؛ تتحقق من السلوك المحدد في حالات الاختبار. |
| `test/game_render_rules_test.dart` | اختبارات آلية لوحدة/ميزة game render rules؛ تتحقق من السلوك المحدد في حالات الاختبار. |
| `test/game_run_checkpoint_adapter_test.dart` | اختبارات آلية لوحدة/ميزة game run checkpoint adapter؛ تتحقق من السلوك المحدد في حالات الاختبار. |
| `test/game_run_lifecycle_test.dart` | اختبارات آلية لوحدة/ميزة game run lifecycle؛ تتحقق من السلوك المحدد في حالات الاختبار. |
| `test/game_run_session_test.dart` | اختبارات آلية لوحدة/ميزة game run session؛ تتحقق من السلوك المحدد في حالات الاختبار. |
| `test/game_run_state_test.dart` | اختبارات آلية لوحدة/ميزة game run state؛ تتحقق من السلوك المحدد في حالات الاختبار. |
| `test/game_settings_screen_test.dart` | اختبارات آلية لوحدة/ميزة game settings screen؛ تتحقق من السلوك المحدد في حالات الاختبار. |
| `test/game_settings_test.dart` | اختبارات آلية لوحدة/ميزة game settings؛ تتحقق من السلوك المحدد في حالات الاختبار. |
| `test/game_timers_test.dart` | اختبارات آلية لوحدة/ميزة game timers؛ تتحقق من السلوك المحدد في حالات الاختبار. |
| `test/gameplay_scenarios_test.dart` | اختبارات آلية لوحدة/ميزة gameplay scenarios؛ تتحقق من السلوك المحدد في حالات الاختبار. |
| `test/hero_rules_test.dart` | اختبارات آلية لوحدة/ميزة hero rules؛ تتحقق من السلوك المحدد في حالات الاختبار. |
| `test/player_attack_test.dart` | اختبارات آلية لوحدة/ميزة player attack؛ تتحقق من السلوك المحدد في حالات الاختبار. |
| `test/player_movement_test.dart` | اختبارات آلية لوحدة/ميزة player movement؛ تتحقق من السلوك المحدد في حالات الاختبار. |
| `test/player_progress_test.dart` | اختبارات آلية لوحدة/ميزة player progress؛ تتحقق من السلوك المحدد في حالات الاختبار. |
| `test/player_projectiles_test.dart` | اختبارات آلية لوحدة/ميزة player projectiles؛ تتحقق من السلوك المحدد في حالات الاختبار. |
| `test/procedural_audio_test.dart` | اختبارات آلية لوحدة/ميزة procedural audio؛ تتحقق من السلوك المحدد في حالات الاختبار. |
| `test/progress_store_failure_test.dart` | اختبارات آلية لوحدة/ميزة progress store failure؛ تتحقق من السلوك المحدد في حالات الاختبار. |
| `test/progress_store_test.dart` | اختبارات آلية لوحدة/ميزة progress store؛ تتحقق من السلوك المحدد في حالات الاختبار. |
| `test/resource_economy_test.dart` | اختبارات آلية لوحدة/ميزة resource economy؛ تتحقق من السلوك المحدد في حالات الاختبار. |
| `test/room_flow_test.dart` | اختبارات آلية لوحدة/ميزة room flow؛ تتحقق من السلوك المحدد في حالات الاختبار. |
| `test/room_layout_test.dart` | اختبارات آلية لوحدة/ميزة room layout؛ تتحقق من السلوك المحدد في حالات الاختبار. |
| `test/run_checkpoint_test.dart` | اختبارات آلية لوحدة/ميزة run checkpoint؛ تتحقق من السلوك المحدد في حالات الاختبار. |
| `test/shop_economy_test.dart` | اختبارات آلية لوحدة/ميزة shop economy؛ تتحقق من السلوك المحدد في حالات الاختبار. |
| `test/shop_purchase_commit_test.dart` | اختبارات آلية لوحدة/ميزة shop purchase commit؛ تتحقق من السلوك المحدد في حالات الاختبار. |
| `test/shop_test.dart` | اختبارات آلية لوحدة/ميزة shop؛ تتحقق من السلوك المحدد في حالات الاختبار. |
| `test/skill_selection_dialog_test.dart` | اختبارات آلية لوحدة/ميزة skill selection dialog؛ تتحقق من السلوك المحدد في حالات الاختبار. |
| `test/skill_system_test.dart` | اختبارات آلية لوحدة/ميزة skill system؛ تتحقق من السلوك المحدد في حالات الاختبار. |
| `test/skill_upgrade_resolution_test.dart` | اختبارات آلية لوحدة/ميزة skill upgrade resolution؛ تتحقق من السلوك المحدد في حالات الاختبار. |
| `test/special_room_dialog_test.dart` | اختبارات آلية لوحدة/ميزة special room dialog؛ تتحقق من السلوك المحدد في حالات الاختبار. |
| `test/special_room_system_test.dart` | اختبارات آلية لوحدة/ميزة special room system؛ تتحقق من السلوك المحدد في حالات الاختبار. |
| `test/stage_completion_resolution_test.dart` | اختبارات آلية لوحدة/ميزة stage completion resolution؛ تتحقق من السلوك المحدد في حالات الاختبار. |
| `test/stage_flow_test.dart` | اختبارات آلية لوحدة/ميزة stage flow؛ تتحقق من السلوك المحدد في حالات الاختبار. |
| `test/weapon_system_test.dart` | اختبارات آلية لوحدة/ميزة weapon system؛ تتحقق من السلوك المحدد في حالات الاختبار. |
| `test/widget_test.dart` | اختبارات آلية لوحدة/ميزة widget؛ تتحقق من السلوك المحدد في حالات الاختبار. |
| `test/world_progression_test.dart` | اختبارات آلية لوحدة/ميزة world progression؛ تتحقق من السلوك المحدد في حالات الاختبار. |
| `test/world_rules_test.dart` | اختبارات آلية لوحدة/ميزة world rules؛ تتحقق من السلوك المحدد في حالات الاختبار. |
| `test/world_selection_screen_test.dart` | اختبارات آلية لوحدة/ميزة world selection screen؛ تتحقق من السلوك المحدد في حالات الاختبار. |
| `test/world_theme_test.dart` | اختبارات آلية لوحدة/ميزة world theme؛ تتحقق من السلوك المحدد في حالات الاختبار. |

### الاختبارات التكاملية (1)

| الملف | الوظيفة |
|---|---|
| `integration_test/app_smoke_test.dart` | اختبار تكاملي يشغّل التطبيق عبر مسار واجهة حقيقي ويتحقق من رحلة الاستخدام. |

### منصة iOS (1)

| الملف | الوظيفة |
|---|---|
| `ios/Runner/Info.plist` | ملف إعدادات معلومات تطبيق iOS؛ حجمه بايت واحد فقط في هذا الفرع ويبدو شبه فارغ/غير مكتمل. |

## تحديث بعد تنفيذ المهمة 1.1.2

أُضيف `lib/player_system.dart` كحدّ واضح لنظام اللاعب، وأضيف `test/player_system_test.dart` لاختبار واجهته. هذان الملفان أُضيفا بعد لقطة الجرد الأصلية ذات 166 ملفاً.

## نتائج المراجعة والملاحظات

1. نقطة الدخول `lib/main.dart` أصبحت رفيعة نسبياً: تهيئة Flutter ومعالجة الأخطاء وتحميل الإعدادات/التقدم ثم تشغيل التطبيق؛ لم تعد تجمع كامل منطق اللعب كما في البنية الأقدم.
2. `lib/game_screen.dart` هو منسق الجولة وحلقة اللعب، ويعتمد على وحدات مستقلة للحركة والقتال والأعداء والمقذوفات والغرف والمراحل والحفظ.
3. واجهة الساحة مفصولة إلى `game_arena_view.dart` وعناصر الممثلين وHUD والرسّامات؛ فصل العرض لا يعني أن كل منطق اللعبة أصبح مستقلاً بالكامل، ويجب التحقق من حدود المسؤوليات عند تنفيذ 1.1.2 وما بعدها.
4. يوجد فصل واضح لأنظمة الاقتصاد والمتجر، الأسلحة والمعدات، المهارات، الإنجازات، تقدم العالم، إعدادات اللعبة، والحفظ.
5. `ProgressStore` يتضمن تسلسلاً للكتابات المتداخلة وتطبيعاً للقيم؛ توجد اختبارات فشل للحفظ، لكن وجود الاختبارات لا يثبت نجاحها على هذا الـ SHA دون تشغيل CI.
6. ملف `pubspec.yaml` يسجل مجلد `assets/spritesheets/` وأصول SVG محددة منفردة، ولا يسجل `assets/` كله كمسار شامل؛ لذلك يجب التأكد من أن كل أصل مستخدم مسجل صراحة أو ضمن مجلد مسجل.
7. `ios/Runner/Info.plist` حجمه بايت واحد فقط؛ هذا مؤشر واضح إلى أن إعداد iOS غير مكتمل ويحتاج إصلاحاً/تحققاً عند العمل على دعم iOS.
8. يوجد أكثر من workflow: بناء APK، Flutter CI، وAndroid Emulator QA. وجود workflow لا يعني أن آخر تشغيل ناجح؛ تُراجع نتائج الـ runs المرتبطة بأحدث commit قبل اعتمادها.
9. ملفات SVG في `assets/` أصول منفردة، أما ملفات `assets/spritesheets/` فهي لوحات إطارات تستخدم للرسوم المتحركة. الوصف أعلاه يحدد دور كل أصل من اسمه ونوعه؛ لا يدّعي تدقيقاً فنياً لكل مسار SVG أو مطابقة بصرية للمرجع.
10. أوصاف بعض الاختبارات مبنية على الوحدة المقابلة واسم ملف الاختبار؛ التحقق من كل assertion ونتيجة التنفيذ يظل من مهام التحقق والاختبارات، وليس شرطاً لتوثيق وظيفة الملف على مستوى الوحدة.

## حدود هذا الإنجاز

- اكتمل جرد كل الملفات المتتبعة في شجرة الفرع المحدد وتوثيق وظيفة كل ملف.
- لم تُنفذ إعادة هيكلة، ولم تُغيّر سلوكيات اللعبة، ولم تُعتبر الاختبارات ناجحة دون نتائج CI مؤكدة.
- هذا الإنجاز يخص **1.1.1 فقط** ولا يعني اكتمال 1.1.2 أو أي بند لاحق.
