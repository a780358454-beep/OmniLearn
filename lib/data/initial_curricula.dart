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
                        prompt: 'في دراسة تقيس أثر تطبيق OmniLearn على سرعة فهم الطلاب، ما هو المتغير المستقل؟',
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

      // المسار الثاني المنفصل تماماً: العلوم الطبية والصحية (Medical Sciences Track)
      CurriculumDomain(
        id: 'curriculum_medical',
        name: 'العلوم الطبية والإسعاف السريري (Medical Sciences)',
        code: 'MED-CORE',
        description: 'منهج سريري وتدريبي مستقل لحالات الإسعاف، التقييم الطبي السريع، والإنعاش القلبي.',
        category: DomainCategory.medical,
        iconName: 'local_hospital',
        courses: [
          Course(
            id: 'course_firstaid',
            curriculumId: 'curriculum_medical',
            title: 'بروتوكولات الإسعاف والطوارئ (Emergency First Aid)',
            code: 'MED-101',
            description: 'الإنعاش القلبي الرئوي CPR، فرز الإصابات، والتعامل مع الحالات الحرجة.',
            iconName: 'healing',
            status: ContentStatus.published,
            modules: [
              CourseModule(
                id: 'mod_cpr',
                courseId: 'course_firstaid',
                title: 'بروتوكول الإنعاش القلبي الرئوي (Adult CPR)',
                description: 'الخطوات المعتمدة لإنقاذ مصاب توقف القلب والتنفس.',
                orderIndex: 1,
                status: ContentStatus.published,
                lessons: [
                  Lesson(
                    id: 'lesson_cpr_core',
                    moduleId: 'mod_cpr',
                    title: 'الإنعاش القلبي الرئوي الأساسي (BLS)',
                    summary: 'التأكد من الأمان، فحص الوعي، طلب النجدة، والبدء بالضغطات.',
                    orderIndex: 1,
                    xpReward: 50,
                    status: ContentStatus.published,
                    cards: [
                      LessonCard(
                        title: 'أمان المسعف أولاً (Scene Safety)',
                        content: 'قبل الاقتراب من المصاب، تأكد أولاً أن المكان آمن لك وللمصاب من أي خطر كالحريق أو الكهرباء أو الغازات.',
                        calloutType: 'warning',
                      ),
                    ],
                    quizzes: [
                      QuizQuestion(
                        id: 'q_med_1',
                        type: QuizType.singleChoice,
                        prompt: 'ما هو المعدل المعياري العالمي لعدد الضغطات الصدرية في الدقيقة أثناء الإنعاش للبالغين؟',
                        explanation: 'توصيات جمعية القلب الأمريكية (AHA) تحدد 100 إلى 120 ضغطة في الدقيقة.',
                        source: 'American Heart Association (AHA) Guidelines, 2020',
                        reviewedBy: 'د. سارة (استشارية طب الطوارئ)',
                        optionsList: [
                          QuizOption(text: '40 إلى 60 ضغطة في الدقيقة', isCorrect: false, whyWrong: 'معدل بطيء جداً لا يكفي لضخ الدم الكافي للدماغ والأعضاء الحيوية.'),
                          QuizOption(text: '70 إلى 80 ضغطة في الدقيقة', isCorrect: false, whyWrong: 'معدل أقل من التوصيات الطبية المعتمدة للإنعاش.'),
                          QuizOption(text: '100 إلى 120 ضغطة في الدقيقة', isCorrect: true),
                          QuizOption(text: '160 إلى 200 ضغطة في الدقيقة', isCorrect: false, whyWrong: 'سرعة مفرطة تمنع امتلاء حجرات القلب بالدم بين الضغطات.'),
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
