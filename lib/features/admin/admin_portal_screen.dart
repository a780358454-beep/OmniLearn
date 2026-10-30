import 'package:flutter/material.dart';
import '../shared/role_guard.dart';
import '../../core/services/app_state_service.dart';
import '../../core/services/cloud_sync_service.dart';
import '../../core/i18n/app_translations.dart';
import '../../core/models/learning_models.dart';
import '../../core/design/design_tokens.dart';
import '../../core/widgets/core_components.dart';

class AdminPortalScreen extends StatefulWidget {
  const AdminPortalScreen({Key? key}) : super(key: key);

  @override
  State<AdminPortalScreen> createState() => _AdminPortalScreenState();
}

class _AdminPortalScreenState extends State<AdminPortalScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late TextEditingController _nameController;
  late TextEditingController _taglineController;
  late TextEditingController _cloudEndpointController;
  late String _selectedIcon;
  late int _selectedPrimary;
  late int _selectedAccent;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
    final b = AppStateService.instance.branding;
    _nameController = TextEditingController(text: b.appName);
    _taglineController = TextEditingController(text: b.appTagline);
    _cloudEndpointController = TextEditingController(text: CloudSyncService.instance.endpointUrl);
    _selectedIcon = b.logoIcon;
    _selectedPrimary = b.primaryColorValue;
    _selectedAccent = b.accentColorValue;
  }

  @override
  void dispose() {
    _tabController.dispose();
    _nameController.dispose();
    _taglineController.dispose();
    _cloudEndpointController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!AppStateService.instance.isAdmin) {
      return const ForbiddenScreen();
    }
    final state = AppStateService.instance;
    final i18n = I18nService.instance;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.admin_panel_settings, color: colorScheme.primary, size: 22),
            const SizedBox(width: Space.sm),
            Text(i18n.t('admin_dashboard')),
          ],
        ),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          indicatorColor: colorScheme.primary,
          labelColor: colorScheme.primary,
          unselectedLabelColor: colorScheme.onSurfaceVariant,
          tabs: [
            Tab(icon: const Icon(Icons.brush_rounded), text: i18n.t('branding_settings')),
            Tab(icon: const Icon(Icons.people_alt_rounded), text: i18n.t('user_management')),
            Tab(icon: const Icon(Icons.rule_folder_rounded), text: i18n.t('moderation')),
            Tab(icon: const Icon(Icons.category_rounded), text: i18n.t('curricula_manager')),
            Tab(icon: const Icon(Icons.published_with_changes_rounded), text: i18n.t('content_governance')),
            Tab(icon: const Icon(Icons.cloud_sync_rounded), text: i18n.t('cloud_settings')),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildBrandingTab(state, i18n),
          _buildUsersTab(state, i18n),
          _buildModerationTab(state, i18n),
          _buildCurriculaTab(state, i18n),
          _buildGovernanceTab(state, i18n),
          _buildCloudSyncTab(state, i18n),
        ],
      ),
    );
  }

  // 1. تبويب تخصيص هوية المنصة والمظهر العام
  Widget _buildBrandingTab(AppStateService state, I18nService i18n) {
    final colorScheme = Theme.of(context).colorScheme;

    final colorPresets = [
      {'name': 'Indigo Blue', 'primary': 0xFF4F46E5, 'accent': 0xFF047857},
      {'name': 'Cyber Purple', 'primary': 0xFF7C3AED, 'accent': 0xFF0891B2},
      {'name': 'Emerald Forest', 'primary': 0xFF059669, 'accent': 0xFFD97706},
      {'name': 'Deep Crimson', 'primary': 0xFFBE123C, 'accent': 0xFF0284C7},
    ];

    final iconOptions = [
      {'key': 'terminal', 'icon': Icons.terminal, 'label': 'Terminal'},
      {'key': 'code', 'icon': Icons.code, 'label': 'Code'},
      {'key': 'school', 'icon': Icons.school, 'label': 'School'},
      {'key': 'data_object', 'icon': Icons.data_object, 'label': 'Algorithms'},
      {'key': 'devices', 'icon': Icons.devices_rounded, 'label': 'Web & Mobile'},
      {'key': 'rocket', 'icon': Icons.rocket_launch, 'label': 'Rocket'},
      {'key': 'menu_book', 'icon': Icons.menu_book_rounded, 'label': 'Harmash'},
      {'key': 'bolt', 'icon': Icons.bolt_rounded, 'label': 'Duolingo'},
      {'key': 'hub', 'icon': Icons.hub_rounded, 'label': 'Networks'},
      {'key': 'security', 'icon': Icons.security_rounded, 'label': 'Ethics & Security'},
      {'key': 'smart_toy', 'icon': Icons.smart_toy_rounded, 'label': 'AI & Robotics'},
      {'key': 'psychology', 'icon': Icons.psychology_rounded, 'label': 'Data Structures'},
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(Space.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(title: i18n.t('branding_settings')),
          const SizedBox(height: Space.md),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(Space.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: i18n.t('app_name_label'),
                      prefixIcon: const Icon(Icons.edit_note_rounded),
                    ),
                  ),
                  const SizedBox(height: Space.md),
                  TextField(
                    controller: _taglineController,
                    decoration: InputDecoration(
                      labelText: i18n.t('tagline_label'),
                      prefixIcon: const Icon(Icons.short_text_rounded),
                    ),
                  ),
                  const SizedBox(height: Space.lg),

                  Text(
                    i18n.t('select_icon_hint'),
                    style: AppTypography.label.copyWith(color: colorScheme.onSurfaceVariant),
                  ),
                  const SizedBox(height: Space.sm),
                  Wrap(
                    spacing: Space.md,
                    runSpacing: Space.sm,
                    children: iconOptions.map((opt) {
                      final isSel = _selectedIcon == opt['key'];
                      return ChoiceChip(
                        selected: isSel,
                        label: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(opt['icon'] as IconData, size: 18),
                            const SizedBox(width: Space.xs),
                            Text(opt['label'] as String),
                          ],
                        ),
                        onSelected: (val) {
                          if (val) setState(() => _selectedIcon = opt['key'] as String);
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: Space.lg),

                  Text(
                    i18n.t('select_palette_hint'),
                    style: AppTypography.label.copyWith(color: colorScheme.onSurfaceVariant),
                  ),
                  const SizedBox(height: Space.sm),
                  Wrap(
                    spacing: Space.md,
                    runSpacing: Space.sm,
                    children: colorPresets.map((palette) {
                      final pColor = Color(palette['primary'] as int);
                      final aColor = Color(palette['accent'] as int);
                      final isSel = _selectedPrimary == palette['primary'];
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedPrimary = palette['primary'] as int;
                            _selectedAccent = palette['accent'] as int;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.all(Space.sm),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: isSel ? colorScheme.primary : colorScheme.outlineVariant,
                              width: isSel ? 2 : 1,
                            ),
                            borderRadius: BorderRadius.circular(RadiusTokens.card),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CircleAvatar(backgroundColor: pColor, radius: 10),
                              const SizedBox(width: 4),
                              CircleAvatar(backgroundColor: aColor, radius: 8),
                              const SizedBox(width: Space.sm),
                              Text(palette['name'] as String, style: AppTypography.caption),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: Space.xl),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.check_circle_outline),
                      onPressed: () {
                        state.updateBranding(
                          appName: _nameController.text.trim(),
                          appTagline: _taglineController.text.trim(),
                          logoIcon: _selectedIcon,
                          primaryColorValue: _selectedPrimary,
                          accentColorValue: _selectedAccent,
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(i18n.t('branding_success')),
                            backgroundColor: ColorTokens.success,
                          ),
                        );
                      },
                      label: Text(i18n.t('save_changes')),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 2. تبويب إدارة المستخدمين والصلاحيات
  Widget _buildUsersTab(AppStateService state, I18nService i18n) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateUserDialog(context, state, i18n),
        backgroundColor: colorScheme.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.person_add_alt_1),
        label: Text(i18n.t('create_user')),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(Space.lg),
        itemCount: state.users.length,
        itemBuilder: (ctx, idx) {
          final user = state.users[idx];
          return Card(
            margin: const EdgeInsets.only(bottom: Space.sm),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: colorScheme.primary.withOpacity(0.12),
                child: Text(
                  user.name.isNotEmpty ? user.name[0] : '?',
                  style: TextStyle(color: colorScheme.primary, fontWeight: FontWeight.bold),
                ),
              ),
              title: Text(user.name, style: AppTypography.label),
              subtitle: Text('${user.email} • ${user.role.name}'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Switch(
                    value: user.isActive,
                    activeColor: colorScheme.primary,
                    onChanged: user.id == state.currentUser.id
                        ? null
                        : (val) => state.toggleUserStatus(user.id),
                  ),
                  IconButton(
                    icon: const Icon(Icons.lock_reset, size: 20),
                    tooltip: 'إعادة تعيين كلمة السر',
                    onPressed: () => _showResetPasswordDialog(context, state, user),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // 3. تبويب مراجعة واعتماد مساهمات المجتمع (Moderation)
  Widget _buildModerationTab(AppStateService state, I18nService i18n) {
    final cs = Theme.of(context).colorScheme;
    final pendingLessons = state.getPendingReviewLessons();

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: pendingLessons.isEmpty
          ? EmptyState(
              icon: Icons.verified_user_outlined,
              title: i18n.t('no_pending_contributions'),
              reason: 'كافة المساهمات البرمجية تمت مراجعتها والبت فيها من الإدارة.',
              actionLabel: i18n.t('pull_from_cloud'),
              onAction: () async {
                await state.pullCurriculaFromCloud();
              },
            )
          : ListView.builder(
              padding: const EdgeInsets.all(Space.lg),
              itemCount: pendingLessons.length,
              itemBuilder: (ctx, idx) {
                final lesson = pendingLessons[idx];
                return Card(
                  margin: const EdgeInsets.only(bottom: Space.lg),
                  child: Padding(
                    padding: const EdgeInsets.all(Space.lg),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: Space.sm, vertical: Space.xs),
                              decoration: BoxDecoration(
                                color: ColorTokens.warning.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(RadiusTokens.pill),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.hourglass_empty_rounded, size: 14, color: ColorTokens.warning),
                                  const SizedBox(width: 4),
                                  Text(
                                    i18n.t('status_pending'),
                                    style: AppTypography.caption.copyWith(
                                      color: ColorTokens.warning,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: Space.sm, vertical: 2),
                              decoration: BoxDecoration(
                                color: cs.primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(RadiusTokens.pill),
                              ),
                              child: Text(
                                '+${lesson.xpReward} XP',
                                style: AppTypography.caption.copyWith(
                                  color: cs.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: Space.md),
                        Text(
                          lesson.title,
                          style: AppTypography.title.copyWith(fontSize: 17),
                        ),
                        if (lesson.titleEn != null && lesson.titleEn!.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            lesson.titleEn!,
                            style: AppTypography.caption.copyWith(color: cs.onSurfaceVariant),
                          ),
                        ],
                        const SizedBox(height: Space.sm),
                        Text(
                          lesson.summary,
                          style: AppTypography.bodySmall.copyWith(color: cs.onSurfaceVariant),
                        ),
                        const SizedBox(height: Space.md),
                        Wrap(
                          spacing: Space.md,
                          runSpacing: Space.xs,
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.person_pin_circle_outlined, size: 16, color: cs.primary),
                                const SizedBox(width: Space.xs),
                                Text(
                                  '${i18n.t('author_label')} ${lesson.authorName ?? lesson.creatorId}',
                                  style: AppTypography.caption.copyWith(color: cs.onSurfaceVariant),
                                ),
                              ],
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.collections_bookmark_outlined, size: 16, color: cs.primary),
                                const SizedBox(width: Space.xs),
                                Text(
                                  '${lesson.cards.length} بطاقات • ${lesson.quizzes.length} أسئلة',
                                  style: AppTypography.caption.copyWith(color: cs.onSurfaceVariant),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const Divider(height: 28),

                        // أزرار اتخاذ القرار الثلاثة
                        Wrap(
                          spacing: Space.sm,
                          runSpacing: Space.sm,
                          children: [
                            ElevatedButton.icon(
                              icon: const Icon(Icons.check_circle_outline, size: 18),
                              label: Text(i18n.t('approve_and_publish')),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: ColorTokens.accentGreen,
                                foregroundColor: Colors.white,
                              ),
                              onPressed: () {
                                state.approveLesson(lesson.id);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('تم اعتماد الدرس "${lesson.title}" ونشره ومزامنته سحابياً! 🎉'),
                                    backgroundColor: ColorTokens.success,
                                  ),
                                );
                              },
                            ),
                            OutlinedButton.icon(
                              icon: const Icon(Icons.rate_review_outlined, size: 18),
                              label: Text(i18n.t('request_revision')),
                              style: OutlinedButton.styleFrom(foregroundColor: ColorTokens.warning),
                              onPressed: () => _showRevisionDialog(context, state, lesson, i18n),
                            ),
                            OutlinedButton.icon(
                              icon: const Icon(Icons.cancel_outlined, size: 18),
                              label: Text(i18n.t('reject')),
                              style: OutlinedButton.styleFrom(foregroundColor: ColorTokens.error),
                              onPressed: () => _showRejectDialog(context, state, lesson, i18n),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  void _showRevisionDialog(BuildContext context, AppStateService state, Lesson lesson, I18nService i18n) {
    final commentC = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(i18n.t('request_revision')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('الدرس: ${lesson.title}', style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: Space.md),
            TextField(
              controller: commentC,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: i18n.t('admin_notes_hint'),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(i18n.t('cancel'))),
          ElevatedButton(
            onPressed: () {
              if (commentC.text.trim().isNotEmpty) {
                state.requestLessonRevision(lesson.id, commentC.text.trim());
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('تم إرسال ملاحظات التعديل بنجاح')),
                );
              }
            },
            child: Text(i18n.t('save_changes')),
          ),
        ],
      ),
    );
  }

  void _showRejectDialog(BuildContext context, AppStateService state, Lesson lesson, I18nService i18n) {
    final reasonC = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(i18n.t('reject')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('الدرس: ${lesson.title}', style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: Space.md),
            TextField(
              controller: reasonC,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: i18n.t('reject_reason_hint'),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(i18n.t('cancel'))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: ColorTokens.error, foregroundColor: Colors.white),
            onPressed: () {
              if (reasonC.text.trim().isNotEmpty) {
                state.rejectLesson(lesson.id, reasonC.text.trim());
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('تم رفض الدرس')),
                );
              }
            },
            child: Text(i18n.t('reject')),
          ),
        ],
      ),
    );
  }

  // 4. تبويب إدارة المناهج المستقلة
  Widget _buildCurriculaTab(AppStateService state, I18nService i18n) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddCurriculumDialog(context, state, i18n),
        backgroundColor: colorScheme.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: Text(i18n.t('new_curriculum')),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(Space.lg),
        itemCount: state.curricula.length,
        itemBuilder: (ctx, idx) {
          final cur = state.curricula[idx];
          final isActive = cur.id == state.activeCurriculumId;
          return Card(
            margin: const EdgeInsets.only(bottom: Space.md),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(RadiusTokens.card),
              side: BorderSide(
                color: isActive ? colorScheme.primary : colorScheme.outlineVariant,
                width: isActive ? 2 : 1,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(Space.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(Space.sm),
                        decoration: BoxDecoration(
                          color: colorScheme.primary.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(RadiusTokens.card),
                        ),
                        child: Icon(Icons.menu_book_rounded, color: colorScheme.primary),
                      ),
                      const SizedBox(width: Space.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(cur.name, style: AppTypography.title.copyWith(fontSize: 16)),
                            Text(
                              '${cur.code} • ${cur.category.name}',
                              style: AppTypography.caption.copyWith(color: colorScheme.onSurfaceVariant),
                            ),
                          ],
                        ),
                      ),
                      if (isActive)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: Space.sm, vertical: Space.xs),
                          decoration: BoxDecoration(
                            color: colorScheme.primary.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(RadiusTokens.pill),
                          ),
                          child: Text(
                            i18n.t('active_track_badge'),
                            style: AppTypography.caption.copyWith(
                              color: colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        )
                      else
                        OutlinedButton(
                          onPressed: () => state.setActiveCurriculum(cur.id),
                          child: Text(i18n.t('activate_for_platform'), style: const TextStyle(fontSize: 12)),
                        ),
                    ],
                  ),
                  const SizedBox(height: Space.md),
                  Text(cur.description, style: AppTypography.bodySmall),
                  const SizedBox(height: Space.sm),
                  Text(
                    '${i18n.t('courses_count')} ${cur.courses.length}',
                    style: AppTypography.caption.copyWith(color: colorScheme.primary),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // 5. تبويب حوكمة ونشر المحتوى
  Widget _buildGovernanceTab(AppStateService state, I18nService i18n) {
    final cur = state.activeCurriculum;
    return ListView(
      padding: const EdgeInsets.all(Space.lg),
      children: [
        SectionHeader(title: '${i18n.t('governance_section_title')}: ${cur.name}'),
        const SizedBox(height: Space.sm),
        for (var course in cur.courses)
          for (var module in course.modules)
            for (var lesson in module.lessons)
              Card(
                margin: const EdgeInsets.only(bottom: Space.sm),
                child: Padding(
                  padding: const EdgeInsets.all(Space.md),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(lesson.title, style: AppTypography.label),
                            const SizedBox(height: Space.xs),
                            Text(
                              '${course.title} • ${module.title}',
                              style: AppTypography.caption,
                            ),
                          ],
                        ),
                      ),
                      _buildStatusPill(lesson.status, i18n),
                      const SizedBox(width: Space.sm),
                      PopupMenuButton<ContentStatus>(
                        icon: const Icon(Icons.more_vert_rounded),
                        onSelected: (st) => state.setContentPublishStatus(lessonId: lesson.id, status: st),
                        itemBuilder: (ctx) => [
                          PopupMenuItem(
                            value: ContentStatus.published,
                            child: Row(
                              children: [
                                const Icon(Icons.check_circle, color: ColorTokens.success, size: 18),
                                const SizedBox(width: Space.sm),
                                Text(i18n.t('publish')),
                              ],
                            ),
                          ),
                          PopupMenuItem(
                            value: ContentStatus.suspended,
                            child: Row(
                              children: [
                                const Icon(Icons.pause_circle_filled, color: ColorTokens.error, size: 18),
                                const SizedBox(width: Space.sm),
                                Text(i18n.t('suspend')),
                              ],
                            ),
                          ),
                          PopupMenuItem(
                            value: ContentStatus.inReview,
                            child: Row(
                              children: [
                                const Icon(Icons.pending, color: ColorTokens.warning, size: 18),
                                const SizedBox(width: Space.sm),
                                Text(i18n.t('in_review')),
                              ],
                            ),
                          ),
                          PopupMenuItem(
                            value: ContentStatus.draft,
                            child: Row(
                              children: [
                                const Icon(Icons.edit_note, color: Colors.grey, size: 18),
                                const SizedBox(width: Space.sm),
                                Text(i18n.t('draft')),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
      ],
    );
  }

  Widget _buildStatusPill(ContentStatus status, I18nService i18n) {
    Color color;
    String label;
    switch (status) {
      case ContentStatus.approved:
      case ContentStatus.published:
        color = ColorTokens.success;
        label = i18n.t('publish');
        break;
      case ContentStatus.suspended:
        color = ColorTokens.error;
        label = i18n.t('suspend');
        break;
      case ContentStatus.pendingReview:
      case ContentStatus.inReview:
        color = ColorTokens.warning;
        label = i18n.t('in_review');
        break;
      case ContentStatus.needsRevision:
        color = Colors.orange;
        label = i18n.t('status_needs_revision');
        break;
      case ContentStatus.rejected:
        color = ColorTokens.error;
        label = i18n.t('status_rejected');
        break;
      case ContentStatus.localDraft:
      case ContentStatus.draft:
        color = Colors.grey;
        label = i18n.t('draft');
        break;
      case ContentStatus.archived:
        color = Colors.blueGrey;
        label = 'مؤرشف';
        break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: Space.sm, vertical: Space.xs),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(RadiusTokens.pill),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Text(
        label,
        style: AppTypography.caption.copyWith(color: color, fontWeight: FontWeight.bold),
      ),
    );
  }

  // 6. تبويب الربط والمزامنة السحابية المباشرة
  Widget _buildCloudSyncTab(AppStateService state, I18nService i18n) {
    final cs = Theme.of(context).colorScheme;
    final cloud = CloudSyncService.instance;

    return AnimatedBuilder(
      animation: cloud,
      builder: (context, _) {
        Color statusColor;
        String statusText;
        IconData statusIcon;

        switch (cloud.status) {
          case CloudSyncStatus.synced:
            statusColor = ColorTokens.accentGreen;
            statusText = i18n.t('cloud_synced');
            statusIcon = Icons.check_circle_rounded;
            break;
          case CloudSyncStatus.syncing:
            statusColor = ColorTokens.warning;
            statusText = i18n.t('cloud_syncing');
            statusIcon = Icons.sync_rounded;
            break;
          case CloudSyncStatus.error:
            statusColor = ColorTokens.error;
            statusText = '${i18n.t('cloud_sync_failed')} (${cloud.errorMessage ?? ''})';
            statusIcon = Icons.error_outline_rounded;
            break;
          case CloudSyncStatus.offline:
            statusColor = cs.onSurfaceVariant;
            statusText = i18n.t('cloud_offline');
            statusIcon = Icons.cloud_off_rounded;
            break;
          case CloudSyncStatus.idle:
            statusColor = cs.primary;
            statusText = i18n.t('cloud_connected');
            statusIcon = Icons.cloud_queue_rounded;
            break;
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(Space.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SectionHeader(title: i18n.t('cloud_settings')),
              const SizedBox(height: Space.md),

              // بطاقة حالة الاتصال المباشر
              Container(
                padding: const EdgeInsets.all(Space.lg),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(RadiusTokens.card),
                  border: Border.all(color: statusColor.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Icon(statusIcon, color: statusColor, size: 32),
                    const SizedBox(width: Space.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            i18n.t('cloud_status'),
                            style: AppTypography.caption.copyWith(color: cs.onSurfaceVariant),
                          ),
                          Text(
                            statusText,
                            style: AppTypography.title.copyWith(color: statusColor, fontSize: 15),
                          ),
                          if (cloud.lastSyncTime != null) ...[
                            const SizedBox(height: 4),
                            Text(
                              '${i18n.t('last_synced')}: ${cloud.lastSyncTime!.toLocal().toString().split('.').first}',
                              style: AppTypography.caption.copyWith(fontSize: 11),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: Space.lg),

              // بطاقة إعدادات رابط الخادم
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(Space.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        i18n.t('cloud_endpoint_url'),
                        style: AppTypography.label,
                      ),
                      const SizedBox(height: Space.sm),
                      TextField(
                        controller: _cloudEndpointController,
                        decoration: const InputDecoration(
                          hintText: 'https://api.mycloud.com/curricula.json',
                          prefixIcon: Icon(Icons.link_rounded),
                        ),
                      ),
                      const SizedBox(height: Space.md),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.save_rounded),
                        label: Text(i18n.t('save_endpoint')),
                        onPressed: () async {
                          await cloud.setEndpointUrl(_cloudEndpointController.text);
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(i18n.t('save_changes')),
                                backgroundColor: ColorTokens.success,
                              ),
                            );
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: Space.xl),

              // بطاقة إجراءات الرفع والتحديث المباشر من هاتف المدير
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(Space.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.phone_android_rounded, color: cs.primary),
                          const SizedBox(width: Space.sm),
                          Text(
                            'تحديث الدروس من هاتف المدير',
                            style: AppTypography.title.copyWith(fontSize: 16),
                          ),
                        ],
                      ),
                      const SizedBox(height: Space.xs),
                      Text(
                        'يمكنك رفع الدروس المضافة وتحديث حالة النشر مباشرة لتصل لجميع هواتف الطلاب عبر الإنترنت.',
                        style: AppTypography.bodySmall.copyWith(color: cs.onSurfaceVariant),
                      ),
                      const SizedBox(height: Space.lg),

                      // زر الرفع للسحابة
                      ElevatedButton.icon(
                        icon: const Icon(Icons.cloud_upload_rounded),
                        label: Text(i18n.t('push_to_cloud')),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: cs.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: Space.md),
                        ),
                        onPressed: () async {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(i18n.t('cloud_syncing')), duration: const Duration(seconds: 1)),
                          );
                          final ok = await state.pushCurriculaToCloud();
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(ok ? i18n.t('cloud_upload_success') : i18n.t('cloud_sync_failed')),
                                backgroundColor: ok ? ColorTokens.success : ColorTokens.error,
                              ),
                            );
                          }
                        },
                      ),
                      const SizedBox(height: Space.md),

                      // زر السحب من السحابة
                      OutlinedButton.icon(
                        icon: const Icon(Icons.cloud_download_rounded),
                        label: Text(i18n.t('pull_from_cloud')),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: Space.md),
                        ),
                        onPressed: () async {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(i18n.t('cloud_syncing')), duration: const Duration(seconds: 1)),
                          );
                          final ok = await state.pullCurriculaFromCloud();
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(ok ? i18n.t('cloud_pull_success') : i18n.t('cloud_sync_failed')),
                                backgroundColor: ok ? ColorTokens.success : ColorTokens.warning,
                              ),
                            );
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showCreateUserDialog(BuildContext context, AppStateService state, I18nService i18n) {
    final nameC = TextEditingController();
    final emailC = TextEditingController();
    UserRole selectedRole = UserRole.student;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDState) => AlertDialog(
          title: Text(i18n.t('create_user')),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameC, decoration: InputDecoration(labelText: i18n.t('name'))),
              const SizedBox(height: Space.sm),
              TextField(controller: emailC, decoration: InputDecoration(labelText: i18n.t('email'))),
              const SizedBox(height: Space.sm),
              DropdownButtonFormField<UserRole>(
                value: selectedRole,
                decoration: InputDecoration(labelText: i18n.t('role')),
                items: [
                  DropdownMenuItem(value: UserRole.creator, child: Text(i18n.t('role_creator'))),
                  DropdownMenuItem(value: UserRole.student, child: Text(i18n.t('role_student'))),
                  DropdownMenuItem(value: UserRole.admin, child: Text(i18n.t('role_admin'))),
                ],
                onChanged: (val) {
                  if (val != null) setDState(() => selectedRole = val);
                },
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: Text(i18n.t('cancel'))),
            ElevatedButton(
              onPressed: () async {
                if (nameC.text.isNotEmpty && emailC.text.isNotEmpty) {
                  final result = await state.createUser(
                    name: nameC.text.trim(),
                    email: emailC.text.trim(),
                    role: selectedRole,
                  );
                  if (ctx.mounted) Navigator.pop(ctx);
                  if (context.mounted) {
                    if (result.success) {
                      _showCredentialsDialog(context, state);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(result.message ?? 'فشل الإنشاء')),
                      );
                    }
                  }
                }
              },
              child: Text(i18n.t('create_user')),
            ),
          ],
        ),
      ),
    );
  }

  void _showCredentialsDialog(BuildContext context, AppStateService state) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('بيانات الحساب الجديد'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('انسخ بيانات الدخول وسلّمها للمستخدم:'),
            const SizedBox(height: Space.md),
            SelectableText('اسم المستخدم: ${state.lastCreatedUsername}'),
            const SizedBox(height: Space.xs),
            SelectableText('كلمة السر المؤقتة: ${state.lastCreatedPassword}'),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('تم الحفظ والنسخ'),
          ),
        ],
      ),
    );
  }

  void _showResetPasswordDialog(BuildContext context, AppStateService state, AppUser user) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('إعادة تعيين كلمة السر لـ ${user.name}'),
        content: const Text(
          'سيتم إنشاء كلمة سر عشوائية جديدة وإلزام المستخدم بتغييرها عند أول دخول.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء')),
          ElevatedButton(
            onPressed: () async {
              const tempPass = '123456';
              final res = await state.resetUserPassword(user.id, tempPass);
              if (ctx.mounted) Navigator.pop(ctx);
              if (context.mounted && res.ok) {
                showDialog(
                  context: context,
                  builder: (c) => AlertDialog(
                    title: const Text('كلمة السر الجديدة'),
                    content: const SelectableText('كلمة السر المؤقتة للمستخدم: 123456\n(سيلزم بتغييرها عند أول دخول)'),
                    actions: [
                      ElevatedButton(
                        onPressed: () => Navigator.pop(c),
                        child: const Text('حسناً'),
                      ),
                    ],
                  ),
                );
              }
            },
            child: const Text('إعادة التعيين الآن'),
          ),
        ],
      ),
    );
  }

  void _showAddCurriculumDialog(BuildContext context, AppStateService state, I18nService i18n) {
    final nameC = TextEditingController();
    final codeC = TextEditingController();
    final descC = TextEditingController();
    DomainCategory selectedCat = DomainCategory.computing;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDState) => AlertDialog(
          title: Text(i18n.t('new_curriculum')),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: nameC, decoration: InputDecoration(labelText: i18n.t('name'))),
                const SizedBox(height: Space.sm),
                TextField(controller: codeC, decoration: const InputDecoration(labelText: 'الكود (مثال: CS-TRACK)')),
                const SizedBox(height: Space.sm),
                TextField(controller: descC, maxLines: 2, decoration: const InputDecoration(labelText: 'الوصف')),
                const SizedBox(height: Space.sm),
                DropdownButtonFormField<DomainCategory>(
                  value: selectedCat,
                  decoration: const InputDecoration(labelText: 'التصنيف البرمجي'),
                  items: DomainCategory.values.map((cat) {
                    return DropdownMenuItem(value: cat, child: Text(cat.name));
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) setDState(() => selectedCat = val);
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: Text(i18n.t('cancel'))),
            ElevatedButton(
              onPressed: () {
                if (nameC.text.isNotEmpty) {
                  state.createNewCurriculum(
                    name: nameC.text.trim(),
                    code: codeC.text.trim(),
                    description: descC.text.trim(),
                    category: selectedCat,
                    iconName: 'folder',
                  );
                  Navigator.pop(ctx);
                }
              },
              child: Text(i18n.t('save_changes')),
            ),
          ],
        ),
      ),
    );
  }
}
