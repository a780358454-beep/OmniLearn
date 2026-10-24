# 🌟 OmniLearn Core Engine

نواة ومنصة تعلم برمجي وتقني تفاعلي شاملة ومبنية على معمارية معيارية مستقلة (**Domain-Agnostic Engine**) مستوحاة من أسلوب SoloLearn و Duolingo، مع واجهات كاملة للأدمن والمؤلف والمتعلم، ودعم 7 أنواع من الاختبارات التفاعلية، وتعدد اللغات (عربي / إنجليزي).

رابط المستودع الرسمي: **https://github.com/a780358454-beep/OmniLearn**

---

## 🌟 أبرز ميزات النواة

1. **نواة مجردة وقابلة لإعادة الاستخدام (Modular Core):**
   * يمكن استخدام نفس النواة لتطبيقات أخرى تماماً (مثل تطبيق طبي، تطبيق لغات، أو هندسي) دون تغيير سطر واحد في منطق المحرك.
   * مساران تجريبيان منفصلان تماماً مدمجان في النواة: مسار هندسة البرمجيات ومسار العلوم الطبية لإثبات المعمارية.
2. **لوحة تحكم مدير النظام (Admin Portal):**
   * تخصيص اسم وشعار وأيقونة وباليتة ألوان التطبيق الحية.
   * إنشاء وإدارة حسابات المؤلفين وتحديد الصلاحيات.
   * حوكمة نشر المحتوى: نشر (Publish)، تعليق (Suspend)، مراجعة (In Review)، أو مسودة (Draft).
3. **استوديو المؤلف (Creator Studio):**
   * إنشاء المقررات، الوحدات، والدروس التفاعلية.
   * منشئ اختبارات يدعم **7 أنواع تفاعلية** مختلفة.
   * تصدير واستيراد المناهج بصيغة JSON.
4. **تجربة المتعلم والتلعيب (Learner & Gamification):**
   * مسارات تفاعلية شبيهة بـ SoloLearn.
   * بطاقات شرح مدعومة بأكواد برمجية وملاحظات ذكية.
   * نقاط خبرة (XP)، عداد التتابع اليومي (Streak)، وتغذية راجعة فورية.
5. **نظام لغات أصيل (i18n):**
   * تبديل فوري بين العربية (RTL) والإنجليزية (LTR).
6. **بناء سحابي تلقائي (Zero-Setup Cloud Build):**
   * تم إعداد سير عمل **GitHub Actions** في `.github/workflows/build-apk.yml`.
   * خوادم GitHub تتولى ترجمة وبناء ملف الأندرويد `OmniLearn-release.apk` تلقائياً عند رفع الكود!

---

## 🚀 أمر الرفع المباشر إلى GitHub

لرفع المشروع إلى مستودعك `https://github.com/a780358454-beep/OmniLearn`:

```bash
git config user.email "a780358454@github.com"
git config user.name "a780358454-beep"
git add .
git commit -m "feat: complete OmniLearn core engine with admin, creator, and learner portals"
git branch -M main
git remote add origin https://github.com/a780358454-beep/OmniLearn.git
git push -u origin main
```

---

## 📚 وثائق المشروع المعمارية

* [الدليل المعماري للنواة وطريقة استنساخها (ARCHITECTURE.md)](docs/ARCHITECTURE.md)
* [دليل أنواع الاختبارات السبعة (QUIZ_TYPES_GUIDE.md)](docs/QUIZ_TYPES_GUIDE.md)
* [دليل واستخدامات لوحة تحكم الأدمن (ADMIN_GUIDE.md)](docs/ADMIN_GUIDE.md)
* [خارطة طريق التطوير المستقبلية (ROADMAP.md)](docs/ROADMAP.md)
