import 'package:flutter/material.dart';
import '../../core/services/app_state_service.dart';
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
  late String _selectedIcon;
  late int _selectedPrimary;
  late int _selectedAccent;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    final b = AppStateService.instance.branding;
    _nameController = TextEditingController(text: b.appName);
    _taglineController = TextEditingController(text: b.appTagline);
    _selectedIcon = b.logoIcon;
    _selectedPrimary = b.primaryColorValue;
    _selectedAccent = b.accentColorValue;
  }

  @override
  void dispose() {
    _tabController.dispose();
    _nameController.dispose();
    _taglineController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
            Tab(icon: const Icon(Icons.category_rounded), text: i18n.t('curricula_manager')),
            Tab(icon: const Icon(Icons.published_with_changes_rounded), text: i18n.t('content_governance')),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildBrandingTab(state, i18n),
          _buildUsersTab(state, i18n),
          _buildCurriculaTab(state, i18n),
          _buildGovernanceTab(state, i18n),
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
      {'key': 'local_hospital', 'icon': Icons.local_hospital, 'label': 'Medical'},
      {'key': 'rocket', 'icon': Icons.rocket_launch, 'label': 'Rocket'},
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
                      prefixIcon: const Icon(Icons.badge_outlined),
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
                  const SizedBox(height: Space.xl),

                  Text(
                    i18n.t('select_icon_hint'),
                    style: AppTypography.label.copyWith(color: colorScheme.onSurface),
                  ),
                  const SizedBox(height: Space.sm),
                  Wrap(
                    spacing: Space.sm,
                    children: iconOptions.map((opt) {
                      final isSelected = _selectedIcon == opt['key'];
                      return ChoiceChip(
                        selected: isSelected,
                        label: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(opt['icon'] as IconData, size: 18),
                            const SizedBox(width: Space.xs),
                            Text(opt['label'] as String),
                          ],
                        ),
                        selectedColor: colorScheme.primary,
                        onSelected: (val) {
                          if (val) setState(() => _selectedIcon = opt['key'] as String);
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: Space.xl),

                  Text(
                    i18n.t('select_palette_hint'),
                    style: AppTypography.label.copyWith(color: colorScheme.onSurface),
                  ),
                  const SizedBox(height: Space.sm),
                  Wrap(
                    spacing: Space.md,
                    runSpacing: Space.sm,
                    children: colorPresets.map((preset) {
                      final pVal = preset['primary'] as int;
                      final aVal = preset['accent'] as int;
                      final isSelected = _selectedPrimary == pVal;
                      return InkWell(
                        onTap: () {
                          setState(() {
                            _selectedPrimary = pVal;
                            _selectedAccent = aVal;
                          });
                        },
                        borderRadius: BorderRadius.circular(RadiusTokens.card),
                        child: Container(
                          padding: const EdgeInsets.all(Space.sm),
                          decoration: BoxDecoration(
                            color: colorScheme.surfaceContainerLow,
                            borderRadius: BorderRadius.circular(RadiusTokens.card),
                            border: Border.all(
                              color: isSelected ? colorScheme.primary : colorScheme.outlineVariant,
                              width: isSelected ? 2 : 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CircleAvatar(backgroundColor: Color(pVal), radius: 10),
                              const SizedBox(width: Space.xs),
                              CircleAvatar(backgroundColor: Color(aVal), radius: 6),
                              const SizedBox(width: Space.sm),
                              Text(preset['name'] as String, style: AppTypography.caption),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: Space.xxl),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
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
                      icon: const Icon(Icons.check_circle_outline),
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

  // 2. تبويب إدارة المستخدمين والمؤلفين
  Widget _buildUsersTab(AppStateService state, I18nService i18n) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateUserDialog(context, state, i18n),
        backgroundColor: colorScheme.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.person_add),
        label: Text(i18n.t('create_user')),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(Space.lg),
        itemCount: state.users.length,
        separatorBuilder: (_, __) => const SizedBox(height: Space.sm),
        itemBuilder: (ctx, index) {
          final u = state.users[index];
          return Card(
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: colorScheme.primary.withOpacity(0.15),
                child: Icon(Icons.person, color: colorScheme.primary),
              ),
              title: Text(u.name, style: AppTypography.label),
              subtitle: Text(
                '${u.email} • ${u.role.name.toUpperCase()} • XP: ${u.xp}',
                style: AppTypography.caption.copyWith(color: colorScheme.onSurfaceVariant),
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Switch(
                    value: u.isActive,
                    activeColor: ColorTokens.success,
                    onChanged: (val) => state.toggleUserStatus(u.id),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: ColorTokens.error, size: 20),
                    onPressed: () {
                      final success = state.deleteUser(u.id);
                      if (!success) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('لا يمكن حذف آخر مدير نظام متبقٍ!'),
                            backgroundColor: ColorTokens.error,
                          ),
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // 3. تبويب إدارة المناهج المستقلة
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

  // 4. تبويب حوكمة ونشر المحتوى
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
      case ContentStatus.published:
        color = ColorTokens.success;
        label = i18n.t('publish');
        break;
      case ContentStatus.suspended:
        color = ColorTokens.error;
        label = i18n.t('suspend');
        break;
      case ContentStatus.inReview:
        color = ColorTokens.warning;
        label = i18n.t('in_review');
        break;
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
      child: Text(label, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold)),
    );
  }

  void _showCreateUserDialog(BuildContext context, AppStateService state, I18nService i18n) {
    final nameC = TextEditingController();
    final emailC = TextEditingController();
    UserRole selectedRole = UserRole.creator;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDState) => AlertDialog(
          title: Text(i18n.t('create_user')),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameC, decoration: InputDecoration(labelText: i18n.t('name'))),
              const SizedBox(height: Space.md),
              TextField(controller: emailC, decoration: InputDecoration(labelText: i18n.t('email'))),
              const SizedBox(height: Space.md),
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
              onPressed: () {
                if (nameC.text.isNotEmpty && emailC.text.isNotEmpty) {
                  state.createUser(
                    name: nameC.text.trim(),
                    email: emailC.text.trim(),
                    role: selectedRole,
                  );
                  Navigator.pop(ctx);
                }
              },
              child: Text(i18n.t('create_user')),
            ),
          ],
        ),
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
                TextField(controller: nameC, decoration: const InputDecoration(labelText: 'اسم التخصص / المسار')),
                const SizedBox(height: Space.sm),
                TextField(controller: codeC, decoration: const InputDecoration(labelText: 'رمز المسار')),
                const SizedBox(height: Space.sm),
                TextField(controller: descC, decoration: const InputDecoration(labelText: 'الوصف')),
                const SizedBox(height: Space.md),
                DropdownButtonFormField<DomainCategory>(
                  value: selectedCat,
                  decoration: const InputDecoration(labelText: 'المجال'),
                  items: DomainCategory.values.map((cat) {
                    return DropdownMenuItem(value: cat, child: Text(cat.name.toUpperCase()));
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
