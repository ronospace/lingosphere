// 🏢 LingoSphere - Team Workspace Widget
// UI component for managing team workspaces and collaborative projects

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/models/team_workspace_models.dart';
import '../../../core/services/team_workspace_service.dart';

class TeamWorkspaceWidget extends StatefulWidget {
  final String currentUserId;
  final TeamWorkspaceService workspaceService;
  final Function(CollaborativeProject)? onProjectSelected;
  final Function(TeamWorkspace)? onWorkspaceSelected;

  const TeamWorkspaceWidget({
    super.key,
    required this.currentUserId,
    required this.workspaceService,
    this.onProjectSelected,
    this.onWorkspaceSelected,
  });

  @override
  State<TeamWorkspaceWidget> createState() => _TeamWorkspaceWidgetState();
}

class _TeamWorkspaceWidgetState extends State<TeamWorkspaceWidget>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<TeamWorkspace> _workspaces = [];
  TeamWorkspace? _selectedWorkspace;
  List<CollaborativeProject> _projects = [];
  bool _isLoading = false;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadWorkspaces();

    // Listen to workspace events
    widget.workspaceService.events.listen(_handleWorkspaceEvent);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadWorkspaces() async {
    setState(() => _isLoading = true);

    try {
      final workspaces = await widget.workspaceService.getUserWorkspaces(
        widget.currentUserId,
      );

      setState(() {
        _workspaces = workspaces;
        if (_workspaces.isNotEmpty && _selectedWorkspace == null) {
          _selectedWorkspace = _workspaces.first;
          _loadProjects();
        }
      });
    } catch (e) {
      _showErrorSnackBar('Failed to load workspaces: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadProjects() async {
    if (_selectedWorkspace == null) return;

    try {
      final projects = await widget.workspaceService.getWorkspaceProjects(
        _selectedWorkspace!.id,
      );

      setState(() => _projects = projects);
    } catch (e) {
      _showErrorSnackBar('Failed to load projects: $e');
    }
  }

  void _handleWorkspaceEvent(WorkspaceEvent event) {
    switch (event.runtimeType) {
      case WorkspaceCreated:
        _loadWorkspaces();
        break;
      case WorkspaceUpdated:
        _loadWorkspaces();
        break;
      case WorkspaceDeleted:
        _loadWorkspaces();
        break;
      case ProjectCreated:
        _loadProjects();
        break;
      case ProjectStatusUpdated:
        _loadProjects();
        break;
      case MemberJoined:
      case MemberRemoved:
      case MemberRoleUpdated:
        _loadWorkspaces();
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildHeader(),
          if (_isLoading && _workspaces.isEmpty)
            const Expanded(
              child: Center(child: CircularProgressIndicator()),
            )
          else if (_workspaces.isEmpty)
            _buildEmptyState()
          else ...[
            _buildWorkspaceSelector(),
            const Divider(),
            _buildTabBar(),
            Expanded(child: _buildTabContent()),
          ],
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.business,
            color: Theme.of(context).colorScheme.onPrimaryContainer,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '🏢 Team Workspaces',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _showCreateWorkspaceDialog,
            tooltip: 'Create Workspace',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadWorkspaces,
            tooltip: 'Refresh',
          ),
        ],
      ),
    );
  }

  Widget _buildWorkspaceSelector() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Selected Workspace',
            style: Theme.of(context).textTheme.labelLarge,
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<TeamWorkspace>(
            value: _selectedWorkspace,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            items: _workspaces.map((workspace) {
              return DropdownMenuItem(
                value: workspace,
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 12,
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      child: Text(
                        workspace.name.isNotEmpty
                            ? workspace.name[0].toUpperCase()
                            : 'W',
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).colorScheme.onPrimary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            workspace.name,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          Text(
                            '${workspace.activeMembersCount} members • ${workspace.projectsCount} projects',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
            onChanged: (workspace) {
              setState(() {
                _selectedWorkspace = workspace;
                _projects = [];
              });
              if (workspace != null) {
                _loadProjects();
                widget.onWorkspaceSelected?.call(workspace);
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      color: Theme.of(context).colorScheme.surface,
      child: TabBar(
        controller: _tabController,
        tabs: const [
          Tab(
            icon: Icon(Icons.folder),
            text: 'Projects',
          ),
          Tab(
            icon: Icon(Icons.people),
            text: 'Members',
          ),
          Tab(
            icon: Icon(Icons.settings),
            text: 'Settings',
          ),
        ],
        indicatorColor: Theme.of(context).colorScheme.primary,
        labelColor: Theme.of(context).colorScheme.primary,
        unselectedLabelColor:
            Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
      ),
    );
  }

  Widget _buildTabContent() {
    if (_selectedWorkspace == null) {
      return const Center(
        child: Text('Please select a workspace'),
      );
    }

    return TabBarView(
      controller: _tabController,
      children: [
        _buildProjectsTab(),
        _buildMembersTab(),
        _buildSettingsTab(),
      ],
    );
  }

  Widget _buildProjectsTab() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: const InputDecoration(
                    hintText: 'Search projects...',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) => setState(() => _searchQuery = value),
                ),
              ),
              const SizedBox(width: 16),
              ElevatedButton.icon(
                onPressed:
                    _canCreateProject() ? _showCreateProjectDialog : null,
                icon: const Icon(Icons.add),
                label: const Text('New Project'),
              ),
            ],
          ),
        ),
        Expanded(
          child: _projects.isEmpty
              ? _buildEmptyProjectsState()
              : _buildProjectsList(),
        ),
      ],
    );
  }

  Widget _buildProjectsList() {
    final filteredProjects = _projects
        .where((project) =>
            _searchQuery.isEmpty ||
            project.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            (project.description
                    ?.toLowerCase()
                    .contains(_searchQuery.toLowerCase()) ??
                false))
        .toList();

    if (filteredProjects.isEmpty) {
      return const Center(
        child: Text('No projects match your search'),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: filteredProjects.length,
      itemBuilder: (context, index) {
        final project = filteredProjects[index];
        return _buildProjectCard(project);
      },
    );
  }

  Widget _buildProjectCard(CollaborativeProject project) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: () => widget.onProjectSelected?.call(project),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      project.name,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  _buildStatusChip(project.status),
                ],
              ),
              if (project.description != null) ...[
                const SizedBox(height: 8),
                Text(
                  project.description!,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withValues(alpha: 0.7),
                      ),
                ),
              ],
              const SizedBox(height: 16),

              // Progress bar
              Row(
                children: [
                  Expanded(
                    child: LinearProgressIndicator(
                      value: project.completionPercentage,
                      backgroundColor: Theme.of(context)
                          .colorScheme
                          .outline
                          .withValues(alpha: 0.2),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${(project.completionPercentage * 100).toInt()}%',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Project details
              Wrap(
                spacing: 16,
                runSpacing: 8,
                children: [
                  _buildProjectDetail(
                    Icons.language,
                    '${project.sourceLanguage} → ${project.targetLanguages.length} languages',
                  ),
                  _buildProjectDetail(
                    Icons.people,
                    '${project.members.length} members',
                  ),
                  _buildProjectDetail(
                    Icons.translate,
                    '${project.translationIds.length} translations',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(ProjectStatus status) {
    final colors = _getStatusColors(status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: colors['background'],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        _getStatusDisplayName(status),
        style: TextStyle(
          fontSize: 12,
          color: colors['text'],
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildProjectDetail(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 16,
          color: Theme.of(context).colorScheme.primary,
        ),
        const SizedBox(width: 4),
        Text(
          text,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }

  Widget _buildMembersTab() {
    final workspace = _selectedWorkspace!;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  '${workspace.members.length} Members',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              if (_canInviteMembers())
                ElevatedButton.icon(
                  onPressed: _showInviteMemberDialog,
                  icon: const Icon(Icons.person_add),
                  label: const Text('Invite'),
                ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: workspace.members.length,
            itemBuilder: (context, index) {
              final member = workspace.members[index];
              return _buildMemberCard(member);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildMemberCard(WorkspaceMember member) {
    final workspace = _selectedWorkspace!;
    final isCurrentUser = member.userId == widget.currentUserId;
    final canEditRoles = workspace.hasPermission(
        widget.currentUserId, Permission.editMemberRoles);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          child: Text(
            member.userId.substring(0, 1).toUpperCase(),
            style: TextStyle(
              color: Theme.of(context).colorScheme.onPrimaryContainer,
            ),
          ),
        ),
        title: Row(
          children: [
            Text(member.userId),
            if (isCurrentUser) ...[
              const SizedBox(width: 8),
              const Chip(
                label: Text('You'),
                visualDensity: VisualDensity.compact,
              ),
            ],
            if (workspace.ownerId == member.userId) ...[
              const SizedBox(width: 8),
              const Chip(
                label: Text('Owner'),
                visualDensity: VisualDensity.compact,
              ),
            ],
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Role: ${_getRoleDisplayName(member.role)}'),
            if (member.lastActiveAt != null)
              Text(
                'Last active: ${_formatDate(member.lastActiveAt!)}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
          ],
        ),
        trailing: !isCurrentUser && canEditRoles
            ? PopupMenuButton(
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'changeRole',
                    child: Text('Change Role'),
                  ),
                  if (workspace.ownerId != member.userId)
                    const PopupMenuItem(
                      value: 'remove',
                      child: Text('Remove Member'),
                    ),
                ],
                onSelected: (value) {
                  if (value == 'changeRole') {
                    _showChangeRoleDialog(member);
                  } else if (value == 'remove') {
                    _removeMember(member);
                  }
                },
              )
            : null,
      ),
    );
  }

  Widget _buildSettingsTab() {
    final workspace = _selectedWorkspace!;
    final canEditSettings = workspace.hasPermission(
      widget.currentUserId,
      Permission.editWorkspaceSettings,
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Workspace Settings',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 24),

          // Basic Information
          _buildSettingsSection(
            'Basic Information',
            [
              _buildSettingsItem('Name', workspace.name, canEditSettings),
              _buildSettingsItem('Description',
                  workspace.description ?? 'No description', canEditSettings),
              _buildSettingsItem(
                  'Type',
                  _getCollaborationTypeDisplayName(
                      workspace.collaborationType)),
            ],
          ),

          const SizedBox(height: 24),

          // Collaboration Settings
          _buildSettingsSection(
            'Collaboration Settings',
            [
              _buildToggleItem('Public Workspace', workspace.settings.isPublic,
                  canEditSettings),
              _buildToggleItem('Allow Guest Access',
                  workspace.settings.allowGuestAccess, canEditSettings),
              _buildToggleItem('Require Approval',
                  workspace.settings.requireApproval, canEditSettings),
            ],
          ),

          const SizedBox(height: 24),

          // Limits
          _buildSettingsSection(
            'Limits',
            [
              _buildSettingsItem(
                  'Max Members', '${workspace.settings.maxMembers}'),
              _buildSettingsItem(
                  'Max Projects', '${workspace.settings.maxProjects}'),
            ],
          ),

          const SizedBox(height: 24),

          // Features
          _buildSettingsSection(
            'Features',
            workspace.settings.features.entries
                .map((entry) => _buildToggleItem(
                      _getFeatureDisplayName(entry.key),
                      entry.value,
                      canEditSettings,
                    ))
                .toList(),
          ),

          const SizedBox(height: 32),

          // Danger Zone
          if (workspace.isOwner(widget.currentUserId)) ...[
            Divider(color: Colors.red.withValues(alpha: 0.3)),
            const SizedBox(height: 16),
            Text(
              'Danger Zone',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.red,
                  ),
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: _deleteWorkspace,
              icon: const Icon(Icons.delete, color: Colors.red),
              label: const Text('Delete Workspace'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                side: const BorderSide(color: Colors.red),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSettingsSection(String title, List<Widget> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: items,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsItem(String label, String value,
      [bool canEdit = false]) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
          if (canEdit)
            IconButton(
              icon: const Icon(Icons.edit, size: 16),
              onPressed: () => _editWorkspaceSetting(label, value),
            ),
        ],
      ),
    );
  }

  Widget _buildToggleItem(String label, bool value, [bool canEdit = false]) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ),
          Switch(
            value: value,
            onChanged: canEdit
                ? (newValue) => _toggleWorkspaceSetting(label, newValue)
                : null,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Expanded(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.business,
              size: 64,
              color: Theme.of(context).colorScheme.outline,
            ),
            const SizedBox(height: 16),
            Text(
              'No Workspaces Yet',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Create your first workspace to start\ncollaborating with your team.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _showCreateWorkspaceDialog,
              icon: const Icon(Icons.add),
              label: const Text('Create Workspace'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyProjectsState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.folder_open,
            size: 64,
            color: Theme.of(context).colorScheme.outline,
          ),
          const SizedBox(height: 16),
          Text(
            'No Projects Yet',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'Create your first project to start\ncollaborative translations.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),
          if (_canCreateProject())
            ElevatedButton.icon(
              onPressed: _showCreateProjectDialog,
              icon: const Icon(Icons.add),
              label: const Text('Create Project'),
            ),
        ],
      ),
    );
  }

  // DIALOG METHODS

  Future<void> _showCreateWorkspaceDialog() async {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();
    var collaborationType = CollaborationType.team;

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create Workspace'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Workspace Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description (optional)',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<CollaborationType>(
              value: collaborationType,
              decoration: const InputDecoration(
                labelText: 'Type',
                border: OutlineInputBorder(),
              ),
              items: CollaborationType.values.map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Text(_getCollaborationTypeDisplayName(type)),
                );
              }).toList(),
              onChanged: (value) =>
                  collaborationType = value ?? CollaborationType.team,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Create'),
          ),
        ],
      ),
    );

    if (result == true && nameController.text.isNotEmpty) {
      try {
        await widget.workspaceService.createWorkspace(
          name: nameController.text,
          ownerId: widget.currentUserId,
          description: descriptionController.text.isEmpty
              ? null
              : descriptionController.text,
          collaborationType: collaborationType,
        );

        _showSuccessSnackBar('Workspace created successfully');
        _loadWorkspaces();
      } catch (e) {
        _showErrorSnackBar('Failed to create workspace: $e');
      }
    }
  }

  Future<void> _showCreateProjectDialog() async {
    if (_selectedWorkspace == null) return;

    final nameController = TextEditingController();
    final descriptionController = TextEditingController();
    var sourceLanguage = 'en';
    final targetLanguages = <String>['es'];

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create Project'),
        content: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Project Name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description (optional)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: sourceLanguage,
                      decoration: const InputDecoration(
                        labelText: 'Source Language',
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'en', child: Text('English')),
                        DropdownMenuItem(value: 'es', child: Text('Spanish')),
                        DropdownMenuItem(value: 'fr', child: Text('French')),
                        DropdownMenuItem(value: 'de', child: Text('German')),
                      ],
                      onChanged: (value) => sourceLanguage = value ?? 'en',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border:
                      Border.all(color: Theme.of(context).colorScheme.outline),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Target Languages',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: targetLanguages
                          .map((lang) => Chip(
                                label: Text(_getLanguageName(lang)),
                                onDeleted: targetLanguages.length > 1
                                    ? () => setState(
                                        () => targetLanguages.remove(lang))
                                    : null,
                              ))
                          .toList(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Create'),
          ),
        ],
      ),
    );

    if (result == true && nameController.text.isNotEmpty) {
      try {
        await widget.workspaceService.createProject(
          workspaceId: _selectedWorkspace!.id,
          name: nameController.text,
          createdBy: widget.currentUserId,
          sourceLanguage: sourceLanguage,
          targetLanguages: targetLanguages,
          description: descriptionController.text.isEmpty
              ? null
              : descriptionController.text,
        );

        _showSuccessSnackBar('Project created successfully');
        _loadProjects();
      } catch (e) {
        _showErrorSnackBar('Failed to create project: $e');
      }
    }
  }

  Future<void> _showInviteMemberDialog() async {
    if (_selectedWorkspace == null) return;

    final emailController = TextEditingController();
    var selectedRole = UserRole.translator;

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Invite Member'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                labelText: 'Email Address',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<UserRole>(
              value: selectedRole,
              decoration: const InputDecoration(
                labelText: 'Role',
                border: OutlineInputBorder(),
              ),
              items: UserRole.values.map((role) {
                return DropdownMenuItem(
                  value: role,
                  child: Text(_getRoleDisplayName(role)),
                );
              }).toList(),
              onChanged: (value) => selectedRole = value ?? UserRole.translator,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Send Invitation'),
          ),
        ],
      ),
    );

    if (result == true && emailController.text.isNotEmpty) {
      try {
        await widget.workspaceService.inviteUser(
          workspaceId: _selectedWorkspace!.id,
          invitedBy: widget.currentUserId,
          email: emailController.text,
          role: selectedRole,
        );

        _showSuccessSnackBar('Invitation sent successfully');
      } catch (e) {
        _showErrorSnackBar('Failed to send invitation: $e');
      }
    }
  }

  Future<void> _showChangeRoleDialog(WorkspaceMember member) async {
    var newRole = member.role;

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Change Role: ${member.userId}'),
        content: DropdownButtonFormField<UserRole>(
          value: newRole,
          decoration: const InputDecoration(
            labelText: 'New Role',
            border: OutlineInputBorder(),
          ),
          items: UserRole.values.map((role) {
            return DropdownMenuItem(
              value: role,
              child: Text(_getRoleDisplayName(role)),
            );
          }).toList(),
          onChanged: (value) => newRole = value ?? member.role,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Change Role'),
          ),
        ],
      ),
    );

    if (result == true && newRole != member.role) {
      try {
        await widget.workspaceService.updateMemberRole(
          workspaceId: _selectedWorkspace!.id,
          userId: widget.currentUserId,
          targetUserId: member.userId,
          newRole: newRole,
        );

        _showSuccessSnackBar('Member role updated successfully');
        _loadWorkspaces();
      } catch (e) {
        _showErrorSnackBar('Failed to update member role: $e');
      }
    }
  }

  // HELPER METHODS

  bool _canCreateProject() {
    return _selectedWorkspace?.hasPermission(
          widget.currentUserId,
          Permission.createProject,
        ) ??
        false;
  }

  bool _canInviteMembers() {
    return _selectedWorkspace?.hasPermission(
          widget.currentUserId,
          Permission.inviteMembers,
        ) ??
        false;
  }

  Map<String, Color> _getStatusColors(ProjectStatus status) {
    switch (status) {
      case ProjectStatus.draft:
        return {
          'background': Colors.grey.shade100,
          'text': Colors.grey.shade700
        };
      case ProjectStatus.inProgress:
        return {
          'background': Colors.blue.shade100,
          'text': Colors.blue.shade700
        };
      case ProjectStatus.inReview:
        return {
          'background': Colors.orange.shade100,
          'text': Colors.orange.shade700
        };
      case ProjectStatus.approved:
        return {
          'background': Colors.green.shade100,
          'text': Colors.green.shade700
        };
      case ProjectStatus.published:
        return {
          'background': Colors.purple.shade100,
          'text': Colors.purple.shade700
        };
      case ProjectStatus.archived:
        return {
          'background': Colors.grey.shade200,
          'text': Colors.grey.shade600
        };
    }
  }

  String _getStatusDisplayName(ProjectStatus status) {
    switch (status) {
      case ProjectStatus.draft:
        return 'Draft';
      case ProjectStatus.inProgress:
        return 'In Progress';
      case ProjectStatus.inReview:
        return 'In Review';
      case ProjectStatus.approved:
        return 'Approved';
      case ProjectStatus.published:
        return 'Published';
      case ProjectStatus.archived:
        return 'Archived';
    }
  }

  String _getRoleDisplayName(UserRole role) {
    switch (role) {
      case UserRole.owner:
        return 'Owner';
      case UserRole.admin:
        return 'Admin';
      case UserRole.editor:
        return 'Editor';
      case UserRole.translator:
        return 'Translator';
      case UserRole.reviewer:
        return 'Reviewer';
      case UserRole.viewer:
        return 'Viewer';
      case UserRole.guest:
        return 'Guest';
    }
  }

  String _getCollaborationTypeDisplayName(CollaborationType type) {
    switch (type) {
      case CollaborationType.private:
        return 'Private';
      case CollaborationType.team:
        return 'Team';
      case CollaborationType.organization:
        return 'Organization';
      case CollaborationType.public:
        return 'Public';
    }
  }

  String _getFeatureDisplayName(String feature) {
    switch (feature) {
      case 'realTimeCollaboration':
        return 'Real-time Collaboration';
      case 'aiAssistance':
        return 'AI Assistance';
      case 'versionControl':
        return 'Version Control';
      case 'qualityAssurance':
        return 'Quality Assurance';
      case 'analytics':
        return 'Analytics';
      default:
        return feature;
    }
  }

  String _getLanguageName(String code) {
    switch (code) {
      case 'en':
        return 'English';
      case 'es':
        return 'Spanish';
      case 'fr':
        return 'French';
      case 'de':
        return 'German';
      case 'it':
        return 'Italian';
      case 'pt':
        return 'Portuguese';
      case 'ru':
        return 'Russian';
      case 'zh':
        return 'Chinese';
      case 'ja':
        return 'Japanese';
      case 'ko':
        return 'Korean';
      default:
        return code.toUpperCase();
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  Future<void> _editWorkspaceSetting(String label, String value) async {
    // Implementation for editing workspace settings
    _showInfoSnackBar('Workspace settings editing not yet implemented');
  }

  Future<void> _toggleWorkspaceSetting(String label, bool value) async {
    // Implementation for toggling workspace settings
    _showInfoSnackBar('Workspace settings toggle not yet implemented');
  }

  Future<void> _removeMember(WorkspaceMember member) async {
    if (_selectedWorkspace == null) return;

    try {
      await widget.workspaceService.removeMember(
        workspaceId: _selectedWorkspace!.id,
        userId: widget.currentUserId,
        targetUserId: member.userId,
      );

      _showSuccessSnackBar('Member removed successfully');
      _loadWorkspaces();
    } catch (e) {
      _showErrorSnackBar('Failed to remove member: $e');
    }
  }

  Future<void> _deleteWorkspace() async {
    if (_selectedWorkspace == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Workspace'),
        content: const Text(
          'Are you sure you want to delete this workspace? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await widget.workspaceService.deleteWorkspace(
          _selectedWorkspace!.id,
          widget.currentUserId,
        );

        _showSuccessSnackBar('Workspace deleted successfully');
        _loadWorkspaces();
      } catch (e) {
        _showErrorSnackBar('Failed to delete workspace: $e');
      }
    }
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showInfoSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}
