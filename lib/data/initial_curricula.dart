import '../core/models/learning_models.dart';

class InitialCurriculaData {
  static List<CurriculumDomain> getCurricula() {
    return [
      // المسار الرئيسي الأول: علوم الحاسوب وهندسة البرمجيات (المواد السبع كاملة)
      CurriculumDomain(
        id: 'curriculum_software_dev',
        name: 'علوم الحاسوب وهندسة البرمجيات (Computer Science & SE)',
        code: 'CS-CORE',
        description: 'المسار الشامل المتضمن: هندسة البرمجيات، تحليل النظم، الموبايل، تفاعل الإنسان، مناهج البحث، حوسبة المؤسسات، وأخلاقيات الحوسبة.',
        category: DomainCategory.computing,
        iconName: 'terminal',
        courses: [
          // 1. هندسة البرمجيات
          Course(
            id: 'course_se',
            curriculumId: 'curriculum_software_dev',
            title: 'هندسة البرمجيات (Software Engineering)',
            code: 'CS301',
            description: 'منهجيات Agile، دورة حياة Scrum، إدارة المتطلبات، وضمان الجودة.',
            iconName: 'engineering',
            status: ContentStatus.published,
            modules: [
              CourseModule(
                id: 'mod_agile',
                courseId: 'course_se',
                title: 'إدارة وتطوير المشاريع البرمجية الرشيقة (Agile)',
                description: 'المبادئ الأساسية لسكروم وإدارة الـ Sprints والـ User Stories.',
                orderIndex: 1,
                status: ContentStatus.published,
                lessons: [
                  Lesson(
                    id: 'lesson_scrum_agile',
                    moduleId: 'mod_agile',
                    title: 'أساسيات إطار العمل Scrum في الفرق التقنية',
                    summary: 'أدوار الفريق، دورة السبرنت، والفعاليات الرسمية لضمان التسليم المستمر.',
                    orderIndex: 1,
                    xpReward: 60,
                    status: ContentStatus.published,
                    displayMode: LessonDisplayMode.harmashArticle,
                    articleContent: '''
# مدخل شامل إلى إطار العمل الرشيق Scrum

يُعد إطار **Scrum** أحد أكثر أطر تطوير البرمجيات اعتماداً عالمياً في الشركات التقنية الرائدة. يقوم الإطار على الفلسفة الرشيقة (Agile Manifesto) التي تفضل الاستجابة للتغيير والتعاون المستمر على الالتزام الجامد بالخطط المسبقة.

---

### 1. الركائز النظرية لإطار Scrum
يقوم الإطار على ثلاث ركائز تجريبية (Empirical Pillars):
1. **الشفافية (Transparency):** وضوح كافة جوانب المشروع والمخرجات لجميع أعضاء الفريق وأصحاب المصلحة.
2. **الفحص (Inspection):** المراقبة المستمرة لتقدم العمل نحو هدف السبرنت لاكتشاف أي انحراف مبكراً.
3. **التكيف (Adaptation):** التعديل الفوري للعمليات والخطط عند ظهور أي معوقات برمجية أو تنظيمية.

---

### 2. الأدوار الجوهرية في الفريق (Scrum Roles)
| الدور | المسؤولية الأساسية | الصلاحيات |
| :--- | :--- | :--- |
| **مالك المنتج (Product Owner)** | تعظيم قيمة المنتج وتمثيل العميل | المسؤول الأوحد عن ترتيب أولويات الـ Backlog |
| **سكروم ماستر (Scrum Master)** | حماية الفريق وتسهيل المنهجية | إزالة العوائق وضمان تطبيق ممارسات Scrum |
| **المطورون (Developers)** | بناء الشيفرة وضمان الجودة واختبارها | تقدير الجهد وتحديد كيفية إنجاز المهام تقنياً |

---

### 3. صياغة قصص المستخدمين (User Story Template)
تُكتب المتطلبات لربط الهدف التقني بالقيمة الحقيقية للمستخدم النهائي:
```text
As a [نوع المستخدم أو الدور]
I want to [الميزة أو القدرة البرمجية المطلوبة]
So that [القيمة التجارية أو الفائدة المستفادة]
```

---

### 4. الفعاليات الأربع لدورة الـ Sprint
* **تخطيط السبرنت (Sprint Planning):** تحديد هدف السبرنت وانتقاء المهام.
* **الاجتماع اليومي (Daily Standup):** لقاء مدته 15 دقيقة لتنسيق العمل ومزامنة الجهود.
* **استعراض السبرنت (Sprint Review):** عرض الميزات البرمجية المنجزة للعملاء.
* **تقييم الدروس المستفادة (Sprint Retrospective):** فحص أداء الفريق وتحسين العملية للمرات القادمة.
''',
                    cards: [
                      LessonCard(
                        title: 'ما هو إطار Scrum؟',
                        content: 'إطار عمل تكراري يقسم تطوير المشروع إلى فترات زمنية ثابتة تسمى Sprints مدتها عادة بين أسبوعين إلى شهر.',
                        calloutType: 'info',
                      ),
                      LessonCard(
                        title: 'الأدوار الجوهرية الثلاثة',
                        content: '• مالك المنتج (Product Owner): يمثل العميل ويحدد الأولويات.\n• سكروم ماستر (Scrum Master): يزيل العقبات التنظيمية.\n• المطورون (Developers): ينفذون الشيفرة والاختبارات.',
                        calloutType: 'tip',
                      ),
                      LessonCard(
                        title: 'قالب قصة المستخدم (User Story)',
                        content: 'تكتب المتطلبات لربط الهدف التقني بالقيمة الحقيقية للمستخدم النهائي:',
                        codeSnippet: 'As a [User Role]\nI want to [Capability / Feature]\nSo that [Business Value]',
                        calloutType: 'info',
                      ),
                    ],
                    quizzes: [
                      QuizQuestion(
                        id: 'q_swe_1',
                        type: QuizType.singleChoice,
                        prompt: 'من هو المسؤول في فريق Scrum عن تحديد وترتيب أولويات الـ Product Backlog؟',
                        explanation: 'مالك المنتج هو الشخص الوحيد المخول بترتيب أولويات المتطلبات لتعظيم قيمة المنتج.',
                        source: 'Scrum Guide (Schwaber & Sutherland, 2020)',
                        reviewedBy: 'لجنة المناهج البرمجية',
                        optionsList: [
                          QuizOption(text: 'سكروم ماستر (Scrum Master)', isCorrect: false, whyWrong: 'سكروم ماستر مسؤول عن تسهيل المنهجية وحل العقبات، وليس ترتيب أولويات الأعمال التجارية.'),
                          QuizOption(text: 'مالك المنتج (Product Owner)', isCorrect: true),
                          QuizOption(text: 'مهندس الجودة والاختبار (QA)', isCorrect: false, whyWrong: 'مهندس الجودة يتحقق من استيفاء معايير القبول، ولا يمتلك سلطة تحديد أولويات الميزات.'),
                          QuizOption(text: 'مدير البنية التحتية (DevOps)', isCorrect: false, whyWrong: 'فريق العمليات يختص بالخوادم والنشر السحابي.'),
                        ],
                      ),
                      QuizQuestion(
                        id: 'q_swe_order',
                        type: QuizType.codeOrdering,
                        prompt: 'رتب الفعاليات الأساسية لدورة الـ Sprint بالترتيب الزمني الصحيح:',
                        explanation: 'تبدأ بالتخطيط ثم الاجتماع اليومي ثم عرض المنتج وأخيراً استعراض الدروس المستفادة.',
                        orderItems: [
                          'اجتماع تخطيط السبرنت (Sprint Planning)',
                          'جلسات التطوير والاجتماع اليومي (Daily Standup)',
                          'استعراض ومراجعة المنتج (Sprint Review)',
                          'جلسة تقييم الدروس المستفادة (Sprint Retrospective)',
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),

          // 2. تحليل وتصميم الأنظمة
          Course(
            id: 'course_sad',
            curriculumId: 'curriculum_software_dev',
            title: 'تحليل وتصميم الأنظمة (Systems Analysis & Design)',
            code: 'CS302',
            description: 'نمذجة المتطلبات، مخططات UML، تصميم الكيانات والعلاقات ERD، وتصميم الواجهات المعمارية.',
            iconName: 'account_tree',
            status: ContentStatus.published,
            modules: [
              CourseModule(
                id: 'mod_uml',
                courseId: 'course_sad',
                title: 'مخططات UML ونمذجة النظام الكائني',
                description: 'استخدام Use Case Diagrams و Class Diagrams لتوصيف سلوك وهيكل النظام.',
                orderIndex: 1,
                status: ContentStatus.published,
                lessons: [
                  Lesson(
                    id: 'lesson_usecases',
                    moduleId: 'mod_uml',
                    title: 'مخططات حالات الاستخدام (Use Case Diagrams)',
                    summary: 'تحديد الفاعلين (Actors)، حدود النظام، وعلاقات include و extend.',
                    orderIndex: 1,
                    xpReward: 50,
                    status: ContentStatus.published,
                    displayMode: LessonDisplayMode.harmashArticle,
                    articleContent: '''
# الدليل الشامل لمخططات حالات الاستخدام (Use Case Diagrams)

تُعد مخططات **Use Case** جزءاً جوهرياً من لغة النمذجة الموحدة (UML)، وتُستخدم لتوصيف المتطلبات الوظيفية للنظام من منظور المستخدم الخارجي دون الخوض في تفاصيل الشيفرة البرمجية الداخلية.

---

### 1. المكونات الأساسية للمخطط
* **حدود النظام (System Boundary):** مستطيل يحدد نطاق البرمجية والمسؤوليات التي يقدمها النظام.
* **الفاعلون (Actors):** أي كيان خارجي يتفاعل مع النظام (مستخدم، نظام دفع، خادم خارجي).
* **حالات الاستخدام (Use Cases):** أشكال بيضاوية تصف وظيفة متكاملة تحقق هدفاً للفاعل.

---

### 2. العلاقات بين حالات الاستخدام (Relationships)
| نوع العلاقة | الرمز في المخطط | متى تُستخدم؟ | مثال عملي |
| :--- | :--- | :--- | :--- |
| **التضمين (<<include>>)** | سهم متقطع بكلمة include | وظيفة إلزامية تُنفذ حتماً مع الحالة الأصلية | تسجيل الدخول أثناء إتمام الشراء |
| **التمديد (<<extend>>)** | سهم متقطع بكلمة extend | وظيفة اختيارية أو مشروطة تنفذ عند تحقق شرط | إرسال إشعار SMS في حال تفعيل الميزة |
| **التعميم (Generalization)** | سهم برأس مثلث مفرغ | وراثة وتخصيص لسلوك حالة عامة | الدفع بالبطاقة تخصص لحالة الدفع الإلكتروني |
''',
                    cards: [
                      LessonCard(
                        title: 'الفرق الجوهري بين include و extend',
                        content: '• include: وظيفة إجبارية تُنفَّذ دائماً كجزء من حالة الاستخدام الأصلية (مثل: التحقق من الهوية).\n• extend: سلوك اختياري أو شرطي يُنفَّذ فقط عند تحقق شرط معين (مثل: إرسال تنبيه في حال تجاوز الرصيد).',
                        calloutType: 'info',
                      ),
                    ],
                    quizzes: [
                      QuizQuestion(
                        id: 'q_sad_1',
                        type: QuizType.singleChoice,
                        prompt: 'إذا كانت حالة الاستخدام A تحتوي على علاقة <<include>> إلى B، فما معنى ذلك؟',
                        explanation: 'علاقة include تعني أن B جزء إلزامي يُنفذ حتماً مع تنفيذ A.',
                        optionsList: [
                          QuizOption(text: 'تنفيذ B اختياري ومشروط', isCorrect: false, whyWrong: 'التنفيذ المشروط أو الاختياري هو تعريف علاقة <<extend>> وليس include.'),
                          QuizOption(text: 'تنفيذ B إلزامي دائماً عند تشغيل A', isCorrect: true),
                          QuizOption(text: 'حالة B ترث خصائص A', isCorrect: false, whyWrong: 'الوراثة تُمثل بسهم التعميم Generalization وليس include.'),
                          QuizOption(text: 'حالة B لا علاقة لها إطلاقاً بحالة A', isCorrect: false, whyWrong: 'توجد علاقة اعتمادية صريحة.'),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),

          // 3. برمجة تطبيقات الموبايل
          Course(
            id: 'course_mobile',
            curriculumId: 'curriculum_software_dev',
            title: 'برمجة تطبيقات الموبايل (Mobile App Development)',
            code: 'CS303',
            description: 'معمارية Flutter، إدارة الحالة State Management، التصميم المتجاوب، واستدعاء واجهات البرمجة.',
            iconName: 'smartphone',
            status: ContentStatus.published,
            modules: [
              CourseModule(
                id: 'mod_flutter_state',
                courseId: 'course_mobile',
                title: 'دورة حياة الودجات وإدارة الحالة',
                description: 'الفرق بين StatelessWidget و StatefulWidget وطرق تحديث الشاشة.',
                orderIndex: 1,
                status: ContentStatus.published,
                lessons: [
                  Lesson(
                    id: 'lesson_state_lifecycle',
                    moduleId: 'mod_flutter_state',
                    title: 'دورة حياة ودجات فلاتر وإدارة الأداء',
                    summary: 'متى تُستدعى initState، build، و dispose لحماية الذاكرة من التسريب.',
                    orderIndex: 1,
                    xpReward: 55,
                    status: ContentStatus.published,
                    displayMode: LessonDisplayMode.harmashArticle,
                    articleContent: '''
# دورة حياة ودجات فلاتر وإدارة الذاكرة المتقدمة

في إطار عمل **Flutter**، يُعتبر فهم دورة حياة الودجات ذات الحالة (`StatefulWidget`) الأساس الحاسم لبناء تطبيقات مستقرة، سريعة، وخالية من تسريب الذاكرة (Memory Leaks).

---

### 1. المراحل المتسلسلة لدورة حياة State
1. **`initState()`:** تُستدعى مرة واحدة فقط عند إدراج الودجة في شجرة العناصر. تُستخدم لتهيئة المتغيرات ومسجلات الأحداث (Controllers).
2. **`didChangeDependencies()`:** تُستدعى فوراً بعد `initState` وكلما تغيرت عناصر الـ InheritedWidget المحيطة بها.
3. **`build()`:** دالة البناء المتكررة التي ترسم الواجهة البرمجية. يجب أن تكون دالة نقية وسريعة.
4. **`dispose()`:** تُستدعى عند تدمير الودجة نهائياً من الذاكرة.

---

### 2. المثال المعياري لتنظيف الموارد في Flutter
```dart
class _TimerWidgetState extends State<TimerWidget> {
  late TextEditingController _controller;
  late StreamSubscription _subscription;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    // إغلاق الكنترولر والاشتراكات لمنع تسريب الذاكرة
    _controller.dispose();
    _subscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(controller: _controller);
  }
}
```
''',
                    cards: [
                      LessonCard(
                        title: 'أهمية دالة dispose',
                        content: 'تُستدعى دالة dispose عند إزالة الودجة من شجرة العناصر نهائياً، ويجب استخدامها لإلغاء المشتركات (Controllers & Streams) منعاً لتسريب الذاكرة (Memory Leak).',
                        calloutType: 'warning',
                      ),
                    ],
                    quizzes: [
                      QuizQuestion(
                        id: 'q_mob_1',
                        type: QuizType.singleChoice,
                        prompt: 'ما هي الدالة المسؤولة عن إلغاء Controllers والمؤقتات لمنع تسريب الذاكرة في StatefulWidget؟',
                        explanation: 'دالة dispose هي المحطة الأخيرة في دورة حياة الودجة وتُستخدم لتحرير الموارد.',
                        optionsList: [
                          QuizOption(text: 'initState()', isCorrect: false, whyWrong: 'تُستدعى initState لتهيئة البيانات مرة واحدة عند البداية فقط.'),
                          QuizOption(text: 'build()', isCorrect: false, whyWrong: 'دالة build مسؤولة عن رسم الشاشة ويجب أن تكون نقية ولا تحتوي على تحرير للموارد.'),
                          QuizOption(text: 'dispose()', isCorrect: true),
                          QuizOption(text: 'setState()', isCorrect: false, whyWrong: 'تُستخدم setState لإشعار فلاتر بإعادة رسم الودجة.'),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),

          // 4. تفاعل الإنسان والحاسوب
          Course(
            id: 'course_hci',
            curriculumId: 'curriculum_software_dev',
            title: 'تفاعل الإنسان والحاسوب (HCI & Usability)',
            code: 'CS304',
            description: 'قواعد سهولة الاستخدام، 휴ريستكس نيلسن، تقييم تجربة المستخدم (UX)، ومقياس SUS.',
            iconName: 'palette',
            status: ContentStatus.published,
            modules: [
              CourseModule(
                id: 'mod_heuristics',
                courseId: 'course_hci',
                title: 'قواعد نيلسن العشر لقابلية الاستخدام',
                description: 'المعايير العالمية لتقييم سهولة استخدام الأنظمة الرقمية.',
                orderIndex: 1,
                status: ContentStatus.published,
                lessons: [
                  Lesson(
                    id: 'lesson_nielsen',
                    moduleId: 'mod_heuristics',
                    title: 'الرؤية لحالة النظام (Visibility of System Status)',
                    summary: 'كيف تضمن التغذية الراجعة الفورية راحة المستخدم وتمنع الارتباك.',
                    orderIndex: 1,
                    xpReward: 50,
                    status: ContentStatus.published,
                    displayMode: LessonDisplayMode.harmashArticle,
                    articleContent: '''
# الدليل الشامل لقواعد جاكوب نيلسن في سهولة الاستخدام (Heuristic Evaluation)

وضع العالم **جاكوب نيلسن (Jakob Nielsen)** عشر قواعد استكشافية تُعد المعيار الذهبي عالمياً في تصميم وتقييم واجهات المستخدم وتجربة الاستخدام (UX/UI).

---

### 1. الرؤية لحالة النظام (Visibility of System Status)
* **المفهوم:** يجب أن يكون النظام شفافاً، يخبر المستخدم باستمرار بما يجري في الوقت الفعلي عبر مؤشرات وتغذية راجعة (Feedback) مناسبة ومفهومة.
* **الأهمية البرمجية:** منع المستخدم من تكرار النقر على الأزرار (مثل زر الدفع)، وتفادي الشعور بتجمد التطبيق أو انهياره.

---

### 2. مصفوفة التطبيقات العملية لقواعد نيلسن
| القاعدة | المشكلة التي تعالجها | الحل البرمجي في الواجهات |
| :--- | :--- | :--- |
| **الرؤية لحالة النظام** | ارتباك المستخدم أثناء العمليات الطويلة | شريط تقدم (Progress Bar) أو مؤشر تحميل (Spinner) |
| **التوافق مع العالم الحقيقي** | استخدام مصطلحات تقنية جافة | استخدام كلمات ومفاهيم مألوفة للمستخدم اليومي |
| **حرية وتحكم المستخدم** | اتخاذ إجراء غير مقصود بالخطأ | زر التراجع (Undo) وإلغاء العملية بسلاسة |
| **الاتساق والمعايير** | اختلاف تصميم العناصر في الشاشات | اعتماد نظام تصميم موحد (Design System / Design Tokens) |

---

### 3. مثال برمجي عملي في Flutter لتغذية المستخدم الراجعة
```dart
ElevatedButton(
  onPressed: _isLoading ? null : _handleUpload,
  child: _isLoading
      ? const SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
        )
      : const Text('رفع الملف الآن'),
);
```
''',
                    cards: [
                      LessonCard(
                        title: 'القاعدة الأولى لجاكوب نيلسن',
                        content: 'يجب أن يُبقي النظام مستخدميه على دراية دائمة بما يجري، من خلال تقديم تغذية راجعة ملائمة في الوقت المناسب (مثل أشرطة التحميل والتنبيهات).',
                        calloutType: 'info',
                      ),
                    ],
                    quizzes: [
                      QuizQuestion(
                        id: 'q_hci_1',
                        type: QuizType.singleChoice,
                        prompt: 'أي عنصر في الواجهة يُجسد أفضل تطبيق لقاعدة "الرؤية لحالة النظام"؟',
                        explanation: 'شريط التقدم يعطي المستخدم فكرة واضحة ومستمرة عن المدة المتبقية والعملية الجارية.',
                        optionsList: [
                          QuizOption(text: 'إخفاء الأزرار عند النقر دون إشعار', isCorrect: false, whyWrong: 'إخفاء العناصر بلا توضيح يسبب ارتباكاً ويشعر المستخدم بأن النظام تجمد.'),
                          QuizOption(text: 'عرض مؤشر تقدم (Progress Bar) أثناء رفع ملف', isCorrect: true),
                          QuizOption(text: 'استخدام ألوان صاخبة متعددة', isCorrect: false, whyWrong: 'الألوان الصاخبة تشتت الانتباه ولا تعبر عن حالة النظام.'),
                          QuizOption(text: 'عرض رسالة خطأ برمز رقمي غير مفهوم (مثل Error 0x88)', isCorrect: false, whyWrong: 'الرموز المبهمة تنتهك مبدأ التحدث بلغة المستخدم.'),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),

          // 5. مناهج البحث في الحوسبة
          Course(
            id: 'course_research',
            curriculumId: 'curriculum_software_dev',
            title: 'مناهج البحث في الحوسبة (Research Methods)',
            code: 'CS305',
            description: 'التصميم التجريبي (Pre/Post Test)، جمع البيانات الكمية والنوعية، صياغة الفرضيات، والتحليل الإحصائي.',
            iconName: 'biotech',
            status: ContentStatus.published,
            modules: [
              CourseModule(
                id: 'mod_empirical',
                courseId: 'course_research',
                title: 'الدراسات التجريبية وقياس الأثر البرمجي',
                description: 'تصميم تجارب قياس أداء المتعلمين والمقارنة بين المجموعات التجريبية والضابطة.',
                orderIndex: 1,
                status: ContentStatus.published,
                lessons: [
                  Lesson(
                    id: 'lesson_pre_post',
                    moduleId: 'mod_empirical',
                    title: 'تصميم الاختبار القبلي والبعدي (Pre-test / Post-test)',
                    summary: 'كيفية عزل المتغيرات لقياس فاعلية أسلوب التلعيب بدقة علمية.',
                    orderIndex: 1,
                    xpReward: 50,
                    status: ContentStatus.published,
                    displayMode: LessonDisplayMode.harmashArticle,
                    articleContent: '''
# التصميم التجريبي القبلي والبعدي في أبحاث البرمجيات (Pre/Post Test Design)

يُعتبر منهج **التصميم التجريبي (Empirical Software Engineering)** الأساس العلمي لاختبار الفرضيات البرمجية وقياس فاعلية أدوات التعلم والتقنيات الحديثة بعيداً عن الانطباعات الذاتية.

---

### 1. تصنيف المتغيرات العلمية
1. **المتغير المستقل (Independent Variable):** هو العامل الذي يتحكم فيه الباحث ويغيره عمداً لدراسة أثره (مثل: استخدام نمط البطاقات التفاعلية مقابل القراءة التقليدية).
2. **المتغير التابع (Dependent Variable):** النتيجة أو السلوك الذي يتم قياسه وملاحظته (مثل: سرعة كتابة الكود البرمجي، دقة حل الاختبارات، ونقاط الخبرة XP).
3. **المتغيرات الضابطة (Controlled Variables):** عوامل يتم تثبيتها لمنع التحيز (مثل: مستوى الخبرة المسبقة للمتعلمين، ونوع الجهاز المستخدم).

---

### 2. مصفوفة مقارنة المجموعات
| المجموعة | المعاملة التجريبية (Treatment) | هدف القياس |
| :--- | :--- | :--- |
| **المجموعة التجريبية (Experimental Group)** | استخدام منصة "مَسْرَاء" التفاعلية | قياس التحسن المنسوب للأداة الجديدة |
| **المجموعة الضابطة (Control Group)** | الدراسة بالطريقة التقليدية غير التفاعلية | توفير خط الأساس (Baseline) للمقارنة |
''',
                    cards: [
                      LessonCard(
                        title: 'ما هو المتغير المستقل والمتغير التابع؟',
                        content: '• المتغير المستقل (Independent Variable): ما يغيره الباحث (مثل: استخدام التطبيق التفاعلي مقابل المحاضرة التقليدية).\n• المتغير التابع (Dependent Variable): النتيجة المقاسة (مثل: درجات الطلاب وزمن الإجابة).',
                        calloutType: 'info',
                      ),
                    ],
                    quizzes: [
                      QuizQuestion(
                        id: 'q_res_1',
                        type: QuizType.singleChoice,
                        prompt: 'في دراسة تقيس أثر تطبيق مَسْرَاء (Masra) على سرعة فهم الطلاب، ما هو المتغير المستقل؟',
                        explanation: 'المتغير المستقل هو الأداة أو التدخل التجريبي الذي يطبقه الباحث (التطبيق).',
                        optionsList: [
                          QuizOption(text: 'درجات الطلاب وسرعة إجابتهم', isCorrect: false, whyWrong: 'درجات الطلاب وسرعتهم هي المتغير التابع (النتيجة المقاسة).'),
                          QuizOption(text: 'استخدام تطبيق التعلم التفاعلي', isCorrect: true),
                          QuizOption(text: 'عمر الطلاب وجنسيتهم', isCorrect: false, whyWrong: 'هذه متغيرات ديموغرافية ضابطة وليست المتغير المستقل المفحوص.'),
                          QuizOption(text: 'درجة حرارة القاعة', isCorrect: false, whyWrong: 'عامل بيئي غير مقصود بالدراسة.'),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),

          // 6. حوسبة المؤسسات
          Course(
            id: 'course_enterprise',
            curriculumId: 'curriculum_software_dev',
            title: 'حوسبة المؤسسات (Enterprise Computing)',
            code: 'CS306',
            description: 'معمارية الخدمات المصغرة Microservices، تكامل الأنظمة ERP، وموثوقية المعاملات ACID.',
            iconName: 'corporate_fare',
            status: ContentStatus.published,
            modules: [
              CourseModule(
                id: 'mod_transactions',
                courseId: 'course_enterprise',
                title: 'خصائص المعاملات المصرفية والمؤسسية (ACID)',
                description: 'الذرية والاتساق والعزل والاستمرارية في المعاملات المالية والمؤسسية.',
                orderIndex: 1,
                status: ContentStatus.published,
                lessons: [
                  Lesson(
                    id: 'lesson_acid',
                    moduleId: 'mod_transactions',
                    title: 'مبدأ الذرية (Atomicity) في أنظمة المؤسسات',
                    summary: 'قاعدة الكل أو لا شيء في معالجة العمليات الموزعة.',
                    orderIndex: 1,
                    xpReward: 50,
                    status: ContentStatus.published,
                    displayMode: LessonDisplayMode.harmashArticle,
                    articleContent: '''
# مبادئ ACID وموثوقية المعاملات المؤسسية والمصرفية

في أنظمة المؤسسات الضخمة وقواعد البيانات الموزعة، تضمن قواعد **ACID** سلامة البيانات ومنع أي تلاعب أو تلف في السجلات الحساسة، خصوصاً في العمليات المصرفية ودفاتر الحسابات الرقمية.

---

### 1. الركائز الأربع لمبادئ ACID
| الحرف | المبدأ الإنجليزي | المعنى بالعربية | الأهمية والتطبيق العملي |
| :--- | :--- | :--- | :--- |
| **A** | **Atomicity** | الذرية | العملية وحدة واحدة لا تتجزأ (الكل أو لا شيء - All or Nothing). إذا فشلت أي خطوة يُلغى كل شيء (Rollback). |
| **C** | **Consistency** | الاتساق | نقل قاعدة البيانات دائماً من حالة صحيحة إلى حالة صحيحة أخرى دون كسر القيود والمحددات. |
| **I** | **Isolation** | العزل | المعاملات المتزامنة لا تؤثر على بعضها؛ كأن كلاً منها تعمل وحيدة في النظام لمنع قراءة البيانات غير المكتملة. |
| **D** | **Durability** | الاستمرارية | بمجرد تأكيد المعاملة (Commit)، تحفظ التغييرات في التخزين الدائم ولا تضيع حتى عند انقطاع التيار الكهربائي. |

---

### 2. الكود البرمجي لضمان الذرية في قواعد البيانات
```sql
BEGIN TRANSACTION;
  -- خصم الرصيد من حساب المرسل
  UPDATE accounts SET balance = balance - 500 WHERE id = 'acc_user_1';
  
  -- إيداع الرصيد في حساب المستلم
  UPDATE accounts SET balance = balance + 500 WHERE id = 'acc_user_2';
  
  -- إذا نجحت العمليتان معاً يتم الاعتماد النهائي
COMMIT;
-- في حال حدوث أي خطأ برمجي أو انقطاع شبكة:
-- ROLLBACK;
```
''',
                    cards: [
                      LessonCard(
                        title: 'ماذا تعني الذرية (Atomicity)؟',
                        content: 'إما أن تنفذ العملية بالكامل بجميع خطواتها أو تُلغى بالكامل (Rollback) دون ترك أي أثر ناقص في النظام (All or Nothing).',
                        calloutType: 'info',
                      ),
                    ],
                    quizzes: [
                      QuizQuestion(
                        id: 'q_ent_1',
                        type: QuizType.singleChoice,
                        prompt: 'إذا حدث انقطاع مفاجئ أثناء تحويل بنكي بعد خصم المبلغ وقبل إيداعه، أي مبدأ من ACID يضمن استرجاع المبلغ فوراً؟',
                        explanation: 'مبدأ الذرية (Atomicity) يمنع تجزئة المعاملة المالية ويضمن التراجع التلقائي (Rollback) عند فشل أي خطوة.',
                        optionsList: [
                          QuizOption(text: 'الاستمرارية (Durability)', isCorrect: false, whyWrong: 'الاستمرارية تضمن بقاء البيانات بعد اكتمال المعاملة بنجاح، وليس أثناء انقطاعها في المنتصف.'),
                          QuizOption(text: 'الذرية (Atomicity)', isCorrect: true),
                          QuizOption(text: 'العزل (Isolation)', isCorrect: false, whyWrong: 'العزل يضمن عدم تداخل المعاملات المتزامنة مع بعضها البعض.'),
                          QuizOption(text: 'التسارع (Velocity)', isCorrect: false, whyWrong: 'التسارع ليس من خصائص ACID.'),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),

          // 7. أخلاقيات الحوسبة المهنية
          Course(
            id: 'course_ethics',
            curriculumId: 'curriculum_software_dev',
            title: 'أخلاقيات الحوسبة المهنية (Computing Ethics)',
            code: 'CS307',
            description: 'ميثاق أخلاقيات ACM/IEEE، الخصوصية وحماية البيانات، الملكية الفكرية، والمسؤولية عن الأخطاء البرمجية.',
            iconName: 'gavel',
            status: ContentStatus.published,
            modules: [
              CourseModule(
                id: 'mod_acm_ethics',
                courseId: 'course_ethics',
                title: 'ميثاق الممارسات المهنية للمهندسين البرمجيين',
                description: 'المسؤولية العامة، حماية الخصوصية، والإفصاح عن المخاطر التقنية.',
                orderIndex: 1,
                status: ContentStatus.published,
                lessons: [
                  Lesson(
                    id: 'lesson_whistleblowing',
                    moduleId: 'mod_acm_ethics',
                    title: 'المسؤولية المهنية عند اكتشاف ثغرة خطيرة',
                    summary: 'واجب المهندس الأخلاقي تجاه حماية سلامة وخصوصية المستخدمين فوق أي مصلحة تجارية.',
                    orderIndex: 1,
                    xpReward: 50,
                    status: ContentStatus.published,
                    displayMode: LessonDisplayMode.harmashArticle,
                    articleContent: '''
# الميثاق الأخلاقي لمهندسي البرمجيات والمسؤولية المهنية (ACM/IEEE Code of Ethics)

تتعدى مسؤولية مهندس البرمجيات كتابة كود خالٍ من الأخطاء؛ إذ يحمل المهندس واجباً أخلاقياً لحماية سلامة وخصوصية المجتمع الرقمي ومستخدمي التطبيقات.

---

### 1. المبادئ الجوهرية لميثاق ACM / IEEE
1. **المصلحة العامة أولاً (Public Interest):** يجب أن يوافق مهندسو البرمجيات على أن مصلحة الجمهور وسلامته تعلو دائماً فوق المصالح التجارية الشخصية أو مصالح أصحاب العمل.
2. **العميل وصاحب العمل (Client & Employer):** العمل بأقصى درجات الإخلاص بما يتوافق مع المصلحة العامة.
3. **المنتج الآمن والموثوق (Product):** التأكد من أن البرمجيات تلبي أعلى المعايير المهنية الممكنة قبل طرحها للمستخدمين.

---

### 2. مصفوفة التعامل مع المعضلات الأخلاقية
| الموقف | الإجراء الخاطئ وغير الأخلاقي | الممارسة المهنية السليمة |
| :--- | :--- | :--- |
| **اكتشاف ثغرة تسرب بيانات قبل الإطلاق** | إخفاء الثغرة لعدم تفويت موعد النشر | توثيق الخطر كتابياً وإيقاف النشر حتى ترقيعها |
| **طلب جمع بيانات حساسة بدون علم المستخدم** | تتبع المستخدمين سراً لأغراض إعلانية | الالتزام الصارم بمبدأ الموافقة المسبقة والشفافية |
| **استخدام مكتبات مفتوحة المصدر دون ترخيص** | تجاهل بنود الترخيص وحقوق الملكية | الالتزام بتراخيص البرمجيات ونسب الفضل لأصحابه |
''',
                    cards: [
                      LessonCard(
                        title: 'المصلحة العامة أولاً (Public Interest)',
                        content: 'ينص ميثاق ACM/IEEE بوضوح على أن المطورين يجب أن يضعوا المصلحة العامة وسلامة الأفراد فوق المصلحة الشخصية لمؤسستهم أو عملائهم.',
                        calloutType: 'warning',
                      ),
                    ],
                    quizzes: [
                      QuizQuestion(
                        id: 'q_eth_1',
                        type: QuizType.caseStudy,
                        prompt: 'تحدي دراسة الحالة: اكتشاف ثغرة خصوصية قبل الإطلاق التجاري',
                        caseScenario: 'اكتشف مهندس برمجيات ثغرة أمنية تسرب سجلات المستخدمين الحساسة قبل يوم واحد من إطلاق تطبيق تجاري ضخم. أمره المدير التنفيذي بتجاهل الثغرة لتفادي خسارة الموعد المحدد.',
                        explanation: 'وفق ميثاق الأخلاقيات المهنية ACM، يجب على المهندس الإصرار على توثيق الخطر وإيقاف النشر لمنع الإضرار بالمصلحة العامة للمستخدمين.',
                        optionsList: [
                          QuizOption(text: 'إطاعة أمر المدير فوراً ونشر التطبيق لأن المسؤولية تقع على عاتق الإدارة فقط', isCorrect: false, whyWrong: 'المهندس شريك في المسؤولية المهنية ولا يُعفى أخلاقياً بطاعة أوامر تضر بالمستخدمين عمداً.'),
                          QuizOption(text: 'توثيق الخطر كتابياً والمطالبة بإصلاحه، والتصعيد للجهات المسؤولة لحماية بيانات المستخدمين', isCorrect: true),
                          QuizOption(text: 'بيع الثغرة في السوق السوداء', isCorrect: false, whyWrong: 'جريمة إلكترونية وانتهاك جسيم للقانون والميثاق.'),
                          QuizOption(text: 'مسح الشيفرة البرمجية للمشروع كاملاً من الخادم', isCorrect: false, whyWrong: 'تخريب غير قانوني ولا يحل المشكلة بطريقة مهنية.'),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ],
      ),

      // المسار الثاني البرمجي: تطوير تطبيقات الويب والموبايل (Web & Mobile Track)
      CurriculumDomain(
        id: 'curriculum_web_mobile',
        name: 'مسار تطوير الويب والموبايل (Web & Mobile Engineering)',
        code: 'DEV-TRACK',
        description: 'المسار البرمجي المخصص لتطوير واجهات الويب الحديثة وتطبيقات الهواتف الذكية عبر Flutter و JavaScript.',
        category: DomainCategory.webDevelopment,
        iconName: 'devices',
        courses: [
          Course(
            id: 'course_web_core',
            curriculumId: 'curriculum_web_mobile',
            title: 'أساسيات الويب الحديث ومفاهيم REST APIs',
            code: 'WEB101',
            description: 'معمارية الويب، بروتوكول HTTP، بناء واجهات المستخدم التفاعلية والتعامل مع الخوادم.',
            iconName: 'web',
            status: ContentStatus.published,
            modules: [
              CourseModule(
                id: 'mod_web_http',
                courseId: 'course_web_core',
                title: 'بروتوكول HTTP والتعامل مع RESTful APIs',
                description: 'طرق الطلبات البرمجية GET/POST، رموز الاستجابة، وتنسيق JSON.',
                orderIndex: 1,
                status: ContentStatus.published,
                lessons: [
                  Lesson(
                    id: 'lesson_rest_api',
                    moduleId: 'mod_web_http',
                    title: 'أساسيات معمارية RESTful APIs',
                    summary: 'فهم تبادل البيانات بين العميل والخادم واستخدام أفعال HTTP الصحيحة.',
                    orderIndex: 1,
                    xpReward: 50,
                    status: ContentStatus.published,
                    creatorId: 'admin',
                    displayMode: LessonDisplayMode.harmashArticle,
                    articleContent: '''
# الدليل الشامل لمعمارية واجهات البرمجة RESTful APIs

تُعد معمارية **REST (Representational State Transfer)** الركيزة الأساسية لتطوير تطبيقات الويب والهواتف الحديثة، وتتيح تبادل البيانات بين الخوادم والعملاء بشكل موثوق وخفيف.

---

### 1. خصائص معمارية REST
* **انعدام الحالة (Statelessness):** كل طلب من العميل يحتوي على كافة المعلومات اللازمة لمعالجته؛ الخادم لا يخزن حالة الجلسة بين الطلبات.
* **الاعتماد على الموارد (Resource-Based):** كل معلومة أو كيان (مستخدم، دورة، درس) يُمثَّل برابط فريد (URI).
* **تنسيق JSON القياسي:** تبادل البيانات بهيكل نصي خفيف وسهل القراءة برمجياً.

---

### 2. أفعال HTTP القياسية (HTTP Methods)
| الفعل | المعنى البرمجي | هل هو آمن؟ (Safe) | هل هو متكرر النتيجة؟ (Idempotent) | الاستخدام |
| :--- | :--- | :--- | :--- | :--- |
| **GET** | قراءة واسترجاع | نعم | نعم | جلب قائمة الدروس أو بيانات مستخدم |
| **POST** | إنشاء جديد | لا | لا | تسجيل حساب جديد أو رفع درس جديد |
| **PUT** | استبدال كامل | لا | نعم | تحديث كامل بيانات الدرس القائم |
| **PATCH** | تعديل جزئي | لا | لا | تعديل عنوان الدرس فقط |
| **DELETE** | حذف وإزالة | لا | نعم | إزالة المورد نهائياً من قاعدة البيانات |

---

### 3. تطبيق عملي لاستدعاء واجهة برمجة في Dart / Flutter
```dart
import 'dart:convert';
import 'package:http/http.dart' as http;

Future<List<Course>> fetchCourses() async {
  final url = Uri.parse('https://api.masra.app/v1/courses');
  final response = await http.get(url, headers: {
    'Accept': 'application/json',
  });

  if (response.statusCode == 200) {
    final List<dynamic> data = jsonDecode(response.body);
    return data.map((json) => Course.fromJson(json)).toList();
  } else {
    throw Exception('فشل تحميل المقررات: HTTP \${response.statusCode}');
  }
}
```
''',
                    cards: [
                      LessonCard(
                        title: 'ما هي الـ REST API؟',
                        titleEn: 'What is a REST API?',
                        content: 'نمط معماري لنقل البيانات عبر بروتوكول HTTP يعتمد على موارد محددة (Resources) بمعرفات URI موحدة.',
                        contentEn: 'An architectural style for network communication via HTTP leveraging standard URIs and stateless operations.',
                        calloutType: 'info',
                      ),
                      LessonCard(
                        title: 'أفعال HTTP القياسية',
                        titleEn: 'Standard HTTP Methods',
                        content: '• GET: جلب وقراءة المورد دون تعديل.\n• POST: إنشاء مورد جديد.\n• PUT: استبدال وتحديث المورد كاملاً.\n• DELETE: حذف المورد.',
                        contentEn: '• GET: Read resource.\n• POST: Create new resource.\n• PUT: Full update.\n• DELETE: Remove resource.',
                        codeSnippet: 'fetch("https://api.masra.app/v1/courses")\n  .then(res => res.json())\n  .then(data => console.log(data));',
                        calloutType: 'tip',
                      ),
                    ],
                    quizzes: [
                      QuizQuestion(
                        id: 'q_rest_1',
                        type: QuizType.singleChoice,
                        prompt: 'أي فعل HTTP يُعد الأنسب معمارياً لجلب بيانات قائمة المقررات دون إجراء أي تعديل على الخادم؟',
                        promptEn: 'Which HTTP method is idempotent and intended strictly for reading data without side effects?',
                        explanation: 'طلب GET مخصص للقراءة الصافية ولا يُحدث أي تغيير على حالة الخادم.',
                        explanationEn: 'GET requests are safe and idempotent, intended exclusively for data retrieval.',
                        optionsList: [
                          QuizOption(text: 'POST', isCorrect: false, whyWrong: 'POST مخصص لإنشاء موارد جديدة ويغير حالة الخادم.'),
                          QuizOption(text: 'GET', isCorrect: true),
                          QuizOption(text: 'DELETE', isCorrect: false, whyWrong: 'DELETE يطلب إزالة مورد من الخادم.'),
                          QuizOption(text: 'PATCH', isCorrect: false, whyWrong: 'PATCH مخصص للتعديل الجزئي على مورد موجود.'),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ],
      ),

      // المسار الثالث البرمجي: الخوارزميات وهياكل البيانات (Algorithms & Data Structures)
      CurriculumDomain(
        id: 'curriculum_algorithms',
        name: 'مسار الخوارزميات وهياكل البيانات (Algorithms & Data Structures)',
        code: 'ALGO-CORE',
        description: 'تحليل التعقيد الحسابي Big-O، بنى البيانات الأساسية (Arrays, Trees, Graphs)، وخوارزميات البحث والترتيب.',
        category: DomainCategory.algorithms,
        iconName: 'account_tree',
        courses: [
          Course(
            id: 'course_dsa_basics',
            curriculumId: 'curriculum_algorithms',
            title: 'هياكل البيانات الأساسية وتحليل التعقيد Big-O',
            code: 'DSA201',
            description: 'دراسة المصفوفات، القوائم المترابطة، المداخن والطوابير، وحساب الزمن التجريدي.',
            iconName: 'data_object',
            status: ContentStatus.published,
            modules: [
              CourseModule(
                id: 'mod_complexity',
                courseId: 'course_dsa_basics',
                title: 'مقدمة في تعقيد الخوارزميات (Asymptotic Complexity)',
                description: 'مفهوم Big-O وتحديد زمن التنفيذ في أسوأ الحالات.',
                orderIndex: 1,
                status: ContentStatus.published,
                lessons: [
                  Lesson(
                    id: 'lesson_big_o_intro',
                    moduleId: 'mod_complexity',
                    title: 'أساسيات تحليل Big-O Notation',
                    summary: 'كيف نقيس كفاءة الخوارزميات مع نمو حجم المدخلات N.',
                    orderIndex: 1,
                    xpReward: 60,
                    status: ContentStatus.published,
                    creatorId: 'admin',
                    displayMode: LessonDisplayMode.harmashArticle,
                    articleContent: '''
# الدليل الشامل لتحليل التعقيد الحسابي وخوارزميات Big-O Notation

في علوم الحاسوب، لا نقيس كفاءة الخوارزمية بالثواني لأن سرعة المعالج تختلف بين الأجهزة؛ بل نقيسها بعدد العمليات الأساسية مع نمو حجم المدخلات **N** باستخدام مقياس **Big-O Notation**.

---

### 1. لماذا نستخدم Big-O؟
* **التجريد عن العتاد (Hardware Independence):** قياس رياضي موضوعي خالص.
* **التركيز على أسوأ الحالات (Worst-Case Scenario):** ضمان أن الخوارزمية لن تنهار مهما بلغ حجم البيانات.
* **إهمال الثوابت والحدود الصغرى:** عندما يكون N كبيراً جداً، فإن O(2N + 5) تُبسط رياضياً إلى O(N).

---

### 2. جدول مقارنة التعقيدات الحسابية الشائعة
| الرمز | الاسم الإنجليزي | التقييم | مثال عملي شهير |
| :--- | :--- | :--- | :--- |
| **O(1)** | Constant Time | مثالي وخارق | الوصول لعنصر في مصفوفة بواسطة الـ Index |
| **O(log N)** | Logarithmic Time | ممتاز جداً | البحث الثنائي (Binary Search) في قائمة مرتبة |
| **O(N)** | Linear Time | جيد ومقبول | البحث الخطي أو المرور على كافة العناصر |
| **O(N log N)** | Linearithmic | كفء للترتيب | خوارزمية Merge Sort و Quick Sort |
| **O(N^2)** | Quadratic Time | بطيء وغير محبذ | الحلقات المتداخلة (Bubble Sort) |
| **O(2^N)** | Exponential Time | كارثي | حل مسألة حقيبة الظهر بالبحث الشامل |

---

### 3. أمثلة برمجية مقارنة في Dart
```dart
// 1. O(1) - زمن ثابت لا يتأثر بطول القائمة
int getFirstElement(List<int> numbers) {
  return numbers.isNotEmpty ? numbers[0] : 0;
}

// 2. O(N) - زمن خطي ينمو طردياً مع حجم القائمة
int calculateSum(List<int> numbers) {
  int total = 0;
  for (final n in numbers) {
    total += n;
  }
  return total;
}

// 3. O(N^2) - حلقات متداخلة (احذر منها مع البيانات الضخمة)
bool hasDuplicatePairs(List<int> numbers) {
  for (int i = 0; i < numbers.length; i++) {
    for (int j = i + 1; j < numbers.length; j++) {
      if (numbers[i] == numbers[j]) return true;
    }
  }
  return false;
}
```
''',
                    cards: [
                      LessonCard(
                        title: 'لماذا نهتم بـ Big-O؟',
                        titleEn: 'Why Big-O Notation Matters?',
                        content: 'Big-O يقيس نمو استهلاك الوقت والذاكرة كدالة في حجم المدخلات (N)، بغض النظر عن سرعة المعالج ولغة البرمجة.',
                        contentEn: 'Big-O measures the growth rate of runtime and memory as input size N scales, independent of hardware.',
                        calloutType: 'info',
                      ),
                      LessonCard(
                        title: 'التعقيدات الزمنية الشائعة',
                        titleEn: 'Common Time Complexities',
                        content: '• O(1): زمن ثابت ومثالي.\n• O(log N): بحث ثنائي فعال.\n• O(N): بحث خطي يمر على كل العناصر.\n• O(N^2): تكرار متداخل بطيء.',
                        codeSnippet: '// O(1) Constant Time\nint getFirst(List<int> list) => list[0];\n\n// O(N) Linear Time\nint sumAll(List<int> list) {\n  var sum = 0;\n  for (var num in list) sum += num;\n  return sum;\n}',
                        calloutType: 'tip',
                      ),
                    ],
                    quizzes: [
                      QuizQuestion(
                        id: 'q_algo_1',
                        type: QuizType.singleChoice,
                        prompt: 'ما هو التعقيد الزمني لعملية الوصول إلى عنصر في مصفوفة عادية عبر الفهرس (Index Access)؟',
                        explanation: 'الوصول المباشر بالفهرس في المصفوفة يستغرق زمناً ثابتاً O(1) بفضل الحجز المتتالي في الذاكرة.',
                        optionsList: [
                          QuizOption(text: 'O(1)', isCorrect: true),
                          QuizOption(text: 'O(N)', isCorrect: false, whyWrong: 'O(N) ينطبق على البحث الخطي غير المفهرس، وليس الوصول المباشر.'),
                          QuizOption(text: 'O(log N)', isCorrect: false, whyWrong: 'O(log N) تعقيد البحث الثنائي في مصفوفة مرتبة.'),
                          QuizOption(text: 'O(N^2)', isCorrect: false, whyWrong: 'تعقيد تربيعي مفرط ينتج عن التكرارات المتداخلة.'),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    ];
  }
}
