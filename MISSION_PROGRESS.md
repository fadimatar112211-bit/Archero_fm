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

## Next action

Audit the current repository against the nine sections, identify the highest-impact concrete gaps, and implement them in coherent batches while updating this file.
