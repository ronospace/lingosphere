// 🏢 LingoSphere - Team Workspace Models
// Enterprise collaboration models for shared projects and team management

import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'team_workspace_models.g.dart';

/// User role in a workspace or project
enum UserRole {
  owner,
  admin,
  editor,
  translator,
  reviewer,
  viewer,
  guest,
}

/// Permission levels for various actions
enum Permission {
  // Project permissions
  createProject,
  deleteProject,
  editProjectSettings,
  viewProject,

  // Translation permissions
  createTranslation,
  editTranslation,
  deleteTranslation,
  reviewTranslation,
  approveTranslation,
  publishTranslation,

  // Team permissions
  inviteMembers,
  removeMembers,
  editMemberRoles,
  viewMembers,

  // Workspace permissions
  editWorkspaceSettings,
  deleteWorkspace,
  exportData,
  viewAnalytics,
  manageIntegrations,
}

/// Workspace collaboration type
enum CollaborationType {
  private,
  team,
  organization,
  public,
}

/// Project status in workflow
enum ProjectStatus {
  draft,
  inProgress,
  inReview,
  approved,
  published,
  archived,
}

/// Team workspace containing multiple projects and members
@JsonSerializable()
class TeamWorkspace extends Equatable {
  final String id;
  final String name;
  final String? description;
  final String? logoUrl;
  final CollaborationType collaborationType;
  final String ownerId;
  final List<WorkspaceMember> members;
  final List<String> projectIds;
  final WorkspaceSettings settings;
  final Map<String, dynamic> metadata;
  final DateTime createdAt;
  final DateTime updatedAt;

  const TeamWorkspace({
    required this.id,
    required this.name,
    this.description,
    this.logoUrl,
    required this.collaborationType,
    required this.ownerId,
    required this.members,
    required this.projectIds,
    required this.settings,
    this.metadata = const {},
    required this.createdAt,
    required this.updatedAt,
  });

  factory TeamWorkspace.fromJson(Map<String, dynamic> json) =>
      _$TeamWorkspaceFromJson(json);

  Map<String, dynamic> toJson() => _$TeamWorkspaceToJson(this);

  /// Create a new workspace
  factory TeamWorkspace.create({
    required String name,
    required String ownerId,
    String? description,
    CollaborationType collaborationType = CollaborationType.team,
  }) {
    final now = DateTime.now();
    final workspaceId = 'ws_${now.millisecondsSinceEpoch}';

    return TeamWorkspace(
      id: workspaceId,
      name: name,
      description: description,
      collaborationType: collaborationType,
      ownerId: ownerId,
      members: [
        WorkspaceMember.create(
          userId: ownerId,
          role: UserRole.owner,
          workspaceId: workspaceId,
        ),
      ],
      projectIds: [],
      settings: WorkspaceSettings.defaults(),
      createdAt: now,
      updatedAt: now,
    );
  }

  /// Get member by user ID
  WorkspaceMember? getMember(String userId) {
    try {
      return members.firstWhere((member) => member.userId == userId);
    } catch (e) {
      return null;
    }
  }

  /// Check if user has specific permission
  bool hasPermission(String userId, Permission permission) {
    final member = getMember(userId);
    if (member == null) return false;

    return _rolePermissions[member.role]?.contains(permission) ?? false;
  }

  /// Get all permissions for a user
  Set<Permission> getUserPermissions(String userId) {
    final member = getMember(userId);
    if (member == null) return {};

    return _rolePermissions[member.role] ?? {};
  }

  /// Check if user is owner
  bool isOwner(String userId) => ownerId == userId;

  /// Check if user is admin or owner
  bool isAdminOrOwner(String userId) {
    final member = getMember(userId);
    return member?.role == UserRole.owner || member?.role == UserRole.admin;
  }

  /// Get active members count
  int get activeMembersCount => members.where((m) => m.isActive).length;

  /// Get projects count
  int get projectsCount => projectIds.length;

  /// Copy with updated fields
  TeamWorkspace copyWith({
    String? name,
    String? description,
    String? logoUrl,
    CollaborationType? collaborationType,
    List<WorkspaceMember>? members,
    List<String>? projectIds,
    WorkspaceSettings? settings,
    Map<String, dynamic>? metadata,
    DateTime? updatedAt,
  }) {
    return TeamWorkspace(
      id: id,
      name: name ?? this.name,
      description: description ?? this.description,
      logoUrl: logoUrl ?? this.logoUrl,
      collaborationType: collaborationType ?? this.collaborationType,
      ownerId: ownerId,
      members: members ?? this.members,
      projectIds: projectIds ?? this.projectIds,
      settings: settings ?? this.settings,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        logoUrl,
        collaborationType,
        ownerId,
        members,
        projectIds,
        settings,
        metadata,
        createdAt,
        updatedAt,
      ];
}

/// Member of a workspace with role and permissions
@JsonSerializable()
class WorkspaceMember extends Equatable {
  final String id;
  final String userId;
  final String workspaceId;
  final UserRole role;
  final bool isActive;
  final DateTime joinedAt;
  final DateTime? lastActiveAt;
  final String? invitedBy;
  final Map<String, dynamic> preferences;

  const WorkspaceMember({
    required this.id,
    required this.userId,
    required this.workspaceId,
    required this.role,
    required this.isActive,
    required this.joinedAt,
    this.lastActiveAt,
    this.invitedBy,
    this.preferences = const {},
  });

  factory WorkspaceMember.fromJson(Map<String, dynamic> json) =>
      _$WorkspaceMemberFromJson(json);

  Map<String, dynamic> toJson() => _$WorkspaceMemberToJson(this);

  /// Create a new workspace member
  factory WorkspaceMember.create({
    required String userId,
    required String workspaceId,
    required UserRole role,
    String? invitedBy,
  }) {
    final now = DateTime.now();

    return WorkspaceMember(
      id: 'wm_${now.millisecondsSinceEpoch}_${userId.hashCode}',
      userId: userId,
      workspaceId: workspaceId,
      role: role,
      isActive: true,
      joinedAt: now,
      lastActiveAt: now,
      invitedBy: invitedBy,
    );
  }

  /// Update last active time
  WorkspaceMember updateLastActive() {
    return copyWith(lastActiveAt: DateTime.now());
  }

  /// Copy with updated fields
  WorkspaceMember copyWith({
    UserRole? role,
    bool? isActive,
    DateTime? lastActiveAt,
    Map<String, dynamic>? preferences,
  }) {
    return WorkspaceMember(
      id: id,
      userId: userId,
      workspaceId: workspaceId,
      role: role ?? this.role,
      isActive: isActive ?? this.isActive,
      joinedAt: joinedAt,
      lastActiveAt: lastActiveAt ?? this.lastActiveAt,
      invitedBy: invitedBy,
      preferences: preferences ?? this.preferences,
    );
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        workspaceId,
        role,
        isActive,
        joinedAt,
        lastActiveAt,
        invitedBy,
        preferences,
      ];
}

/// Collaborative translation project
@JsonSerializable()
class CollaborativeProject extends Equatable {
  final String id;
  final String workspaceId;
  final String name;
  final String? description;
  final String sourceLanguage;
  final List<String> targetLanguages;
  final ProjectStatus status;
  final String createdBy;
  final List<ProjectMember> members;
  final List<String> translationIds;
  final ProjectSettings settings;
  final WorkflowSettings workflow;
  final Map<String, dynamic> metadata;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? completedAt;

  const CollaborativeProject({
    required this.id,
    required this.workspaceId,
    required this.name,
    this.description,
    required this.sourceLanguage,
    required this.targetLanguages,
    required this.status,
    required this.createdBy,
    required this.members,
    required this.translationIds,
    required this.settings,
    required this.workflow,
    this.metadata = const {},
    required this.createdAt,
    required this.updatedAt,
    this.completedAt,
  });

  factory CollaborativeProject.fromJson(Map<String, dynamic> json) =>
      _$CollaborativeProjectFromJson(json);

  Map<String, dynamic> toJson() => _$CollaborativeProjectToJson(this);

  /// Create a new project
  factory CollaborativeProject.create({
    required String workspaceId,
    required String name,
    required String createdBy,
    required String sourceLanguage,
    required List<String> targetLanguages,
    String? description,
  }) {
    final now = DateTime.now();
    final projectId = 'proj_${now.millisecondsSinceEpoch}';

    return CollaborativeProject(
      id: projectId,
      workspaceId: workspaceId,
      name: name,
      description: description,
      sourceLanguage: sourceLanguage,
      targetLanguages: targetLanguages,
      status: ProjectStatus.draft,
      createdBy: createdBy,
      members: [
        ProjectMember.create(
          userId: createdBy,
          projectId: projectId,
          role: UserRole.owner,
        ),
      ],
      translationIds: [],
      settings: ProjectSettings.defaults(),
      workflow: WorkflowSettings.defaults(),
      createdAt: now,
      updatedAt: now,
    );
  }

  /// Get member by user ID
  ProjectMember? getMember(String userId) {
    try {
      return members.firstWhere((member) => member.userId == userId);
    } catch (e) {
      return null;
    }
  }

  /// Get completion percentage
  double get completionPercentage {
    if (translationIds.isEmpty) return 0.0;

    // This would need to be calculated based on actual translation completion
    // For now, return based on status
    switch (status) {
      case ProjectStatus.draft:
        return 0.0;
      case ProjectStatus.inProgress:
        return 0.3;
      case ProjectStatus.inReview:
        return 0.8;
      case ProjectStatus.approved:
        return 0.95;
      case ProjectStatus.published:
        return 1.0;
      case ProjectStatus.archived:
        return 1.0;
    }
  }

  /// Check if project is active
  bool get isActive => status != ProjectStatus.archived;

  /// Get status display name
  String get statusDisplayName {
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

  /// Copy with updated fields
  CollaborativeProject copyWith({
    String? name,
    String? description,
    List<String>? targetLanguages,
    ProjectStatus? status,
    List<ProjectMember>? members,
    List<String>? translationIds,
    ProjectSettings? settings,
    WorkflowSettings? workflow,
    Map<String, dynamic>? metadata,
    DateTime? updatedAt,
    DateTime? completedAt,
  }) {
    return CollaborativeProject(
      id: id,
      workspaceId: workspaceId,
      name: name ?? this.name,
      description: description ?? this.description,
      sourceLanguage: sourceLanguage,
      targetLanguages: targetLanguages ?? this.targetLanguages,
      status: status ?? this.status,
      createdBy: createdBy,
      members: members ?? this.members,
      translationIds: translationIds ?? this.translationIds,
      settings: settings ?? this.settings,
      workflow: workflow ?? this.workflow,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
      completedAt: completedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        workspaceId,
        name,
        description,
        sourceLanguage,
        targetLanguages,
        status,
        createdBy,
        members,
        translationIds,
        settings,
        workflow,
        metadata,
        createdAt,
        updatedAt,
        completedAt,
      ];
}

/// Member of a specific project
@JsonSerializable()
class ProjectMember extends Equatable {
  final String id;
  final String userId;
  final String projectId;
  final UserRole role;
  final List<String> assignedLanguages;
  final bool isActive;
  final DateTime joinedAt;
  final DateTime? lastActiveAt;

  const ProjectMember({
    required this.id,
    required this.userId,
    required this.projectId,
    required this.role,
    required this.assignedLanguages,
    required this.isActive,
    required this.joinedAt,
    this.lastActiveAt,
  });

  factory ProjectMember.fromJson(Map<String, dynamic> json) =>
      _$ProjectMemberFromJson(json);

  Map<String, dynamic> toJson() => _$ProjectMemberToJson(this);

  /// Create a new project member
  factory ProjectMember.create({
    required String userId,
    required String projectId,
    required UserRole role,
    List<String> assignedLanguages = const [],
  }) {
    final now = DateTime.now();

    return ProjectMember(
      id: 'pm_${now.millisecondsSinceEpoch}_${userId.hashCode}',
      userId: userId,
      projectId: projectId,
      role: role,
      assignedLanguages: assignedLanguages,
      isActive: true,
      joinedAt: now,
      lastActiveAt: now,
    );
  }

  /// Copy with updated fields
  ProjectMember copyWith({
    UserRole? role,
    List<String>? assignedLanguages,
    bool? isActive,
    DateTime? lastActiveAt,
  }) {
    return ProjectMember(
      id: id,
      userId: userId,
      projectId: projectId,
      role: role ?? this.role,
      assignedLanguages: assignedLanguages ?? this.assignedLanguages,
      isActive: isActive ?? this.isActive,
      joinedAt: joinedAt,
      lastActiveAt: lastActiveAt ?? this.lastActiveAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        projectId,
        role,
        assignedLanguages,
        isActive,
        joinedAt,
        lastActiveAt,
      ];
}

/// Workspace configuration settings
@JsonSerializable()
class WorkspaceSettings extends Equatable {
  final bool isPublic;
  final bool allowGuestAccess;
  final bool requireApproval;
  final int maxMembers;
  final int maxProjects;
  final List<String> allowedDomains;
  final Map<String, bool> features;
  final NotificationSettings notifications;
  final IntegrationSettings integrations;

  const WorkspaceSettings({
    required this.isPublic,
    required this.allowGuestAccess,
    required this.requireApproval,
    required this.maxMembers,
    required this.maxProjects,
    required this.allowedDomains,
    required this.features,
    required this.notifications,
    required this.integrations,
  });

  factory WorkspaceSettings.fromJson(Map<String, dynamic> json) =>
      _$WorkspaceSettingsFromJson(json);

  Map<String, dynamic> toJson() => _$WorkspaceSettingsToJson(this);

  /// Create default settings
  factory WorkspaceSettings.defaults() {
    return WorkspaceSettings(
      isPublic: false,
      allowGuestAccess: true,
      requireApproval: false,
      maxMembers: 50,
      maxProjects: 100,
      allowedDomains: [],
      features: {
        'realTimeCollaboration': true,
        'aiAssistance': true,
        'versionControl': true,
        'qualityAssurance': true,
        'analytics': true,
      },
      notifications: NotificationSettings.defaults(),
      integrations: IntegrationSettings.defaults(),
    );
  }

  /// Copy with updated fields
  WorkspaceSettings copyWith({
    bool? isPublic,
    bool? allowGuestAccess,
    bool? requireApproval,
    int? maxMembers,
    int? maxProjects,
    List<String>? allowedDomains,
    Map<String, bool>? features,
    NotificationSettings? notifications,
    IntegrationSettings? integrations,
  }) {
    return WorkspaceSettings(
      isPublic: isPublic ?? this.isPublic,
      allowGuestAccess: allowGuestAccess ?? this.allowGuestAccess,
      requireApproval: requireApproval ?? this.requireApproval,
      maxMembers: maxMembers ?? this.maxMembers,
      maxProjects: maxProjects ?? this.maxProjects,
      allowedDomains: allowedDomains ?? this.allowedDomains,
      features: features ?? this.features,
      notifications: notifications ?? this.notifications,
      integrations: integrations ?? this.integrations,
    );
  }

  @override
  List<Object?> get props => [
        isPublic,
        allowGuestAccess,
        requireApproval,
        maxMembers,
        maxProjects,
        allowedDomains,
        features,
        notifications,
        integrations,
      ];
}

/// Project-specific settings
@JsonSerializable()
class ProjectSettings extends Equatable {
  final bool autoAssignTranslators;
  final bool requireReview;
  final int minReviewers;
  final bool allowMachineTranslation;
  final double qualityThreshold;
  final Map<String, dynamic> customFields;

  const ProjectSettings({
    required this.autoAssignTranslators,
    required this.requireReview,
    required this.minReviewers,
    required this.allowMachineTranslation,
    required this.qualityThreshold,
    required this.customFields,
  });

  factory ProjectSettings.fromJson(Map<String, dynamic> json) =>
      _$ProjectSettingsFromJson(json);

  Map<String, dynamic> toJson() => _$ProjectSettingsToJson(this);

  /// Create default settings
  factory ProjectSettings.defaults() {
    return const ProjectSettings(
      autoAssignTranslators: true,
      requireReview: true,
      minReviewers: 1,
      allowMachineTranslation: true,
      qualityThreshold: 0.8,
      customFields: {},
    );
  }

  @override
  List<Object?> get props => [
        autoAssignTranslators,
        requireReview,
        minReviewers,
        allowMachineTranslation,
        qualityThreshold,
        customFields,
      ];
}

/// Workflow configuration for project
@JsonSerializable()
class WorkflowSettings extends Equatable {
  final List<ProjectStatus> workflow;
  final Map<ProjectStatus, List<UserRole>> statusPermissions;
  final bool enableAutoProgress;
  final Map<String, dynamic> automationRules;

  const WorkflowSettings({
    required this.workflow,
    required this.statusPermissions,
    required this.enableAutoProgress,
    required this.automationRules,
  });

  factory WorkflowSettings.fromJson(Map<String, dynamic> json) =>
      _$WorkflowSettingsFromJson(json);

  Map<String, dynamic> toJson() => _$WorkflowSettingsToJson(this);

  /// Create default workflow
  factory WorkflowSettings.defaults() {
    return WorkflowSettings(
      workflow: [
        ProjectStatus.draft,
        ProjectStatus.inProgress,
        ProjectStatus.inReview,
        ProjectStatus.approved,
        ProjectStatus.published,
      ],
      statusPermissions: {
        ProjectStatus.draft: [UserRole.owner, UserRole.admin, UserRole.editor],
        ProjectStatus.inProgress: [
          UserRole.owner,
          UserRole.admin,
          UserRole.editor,
          UserRole.translator
        ],
        ProjectStatus.inReview: [
          UserRole.owner,
          UserRole.admin,
          UserRole.reviewer
        ],
        ProjectStatus.approved: [UserRole.owner, UserRole.admin],
        ProjectStatus.published: [UserRole.owner, UserRole.admin],
      },
      enableAutoProgress: true,
      automationRules: {},
    );
  }

  @override
  List<Object?> get props => [
        workflow,
        statusPermissions,
        enableAutoProgress,
        automationRules,
      ];
}

/// Notification preferences
@JsonSerializable()
class NotificationSettings extends Equatable {
  final bool emailNotifications;
  final bool pushNotifications;
  final bool projectUpdates;
  final bool memberActivity;
  final bool translationCompleted;
  final bool reviewRequests;

  const NotificationSettings({
    required this.emailNotifications,
    required this.pushNotifications,
    required this.projectUpdates,
    required this.memberActivity,
    required this.translationCompleted,
    required this.reviewRequests,
  });

  factory NotificationSettings.fromJson(Map<String, dynamic> json) =>
      _$NotificationSettingsFromJson(json);

  Map<String, dynamic> toJson() => _$NotificationSettingsToJson(this);

  /// Create default notification settings
  factory NotificationSettings.defaults() {
    return const NotificationSettings(
      emailNotifications: true,
      pushNotifications: true,
      projectUpdates: true,
      memberActivity: false,
      translationCompleted: true,
      reviewRequests: true,
    );
  }

  @override
  List<Object?> get props => [
        emailNotifications,
        pushNotifications,
        projectUpdates,
        memberActivity,
        translationCompleted,
        reviewRequests,
      ];
}

/// Integration settings for external tools
@JsonSerializable()
class IntegrationSettings extends Equatable {
  final bool slackIntegration;
  final bool githubIntegration;
  final bool jiraIntegration;
  final Map<String, Map<String, dynamic>> integrationConfigs;

  const IntegrationSettings({
    required this.slackIntegration,
    required this.githubIntegration,
    required this.jiraIntegration,
    required this.integrationConfigs,
  });

  factory IntegrationSettings.fromJson(Map<String, dynamic> json) =>
      _$IntegrationSettingsFromJson(json);

  Map<String, dynamic> toJson() => _$IntegrationSettingsToJson(this);

  /// Create default integration settings
  factory IntegrationSettings.defaults() {
    return const IntegrationSettings(
      slackIntegration: false,
      githubIntegration: false,
      jiraIntegration: false,
      integrationConfigs: {},
    );
  }

  @override
  List<Object?> get props => [
        slackIntegration,
        githubIntegration,
        jiraIntegration,
        integrationConfigs,
      ];
}

/// Workspace invitation
@JsonSerializable()
class WorkspaceInvitation extends Equatable {
  final String id;
  final String workspaceId;
  final String invitedBy;
  final String email;
  final UserRole role;
  final String token;
  final DateTime expiresAt;
  final DateTime createdAt;
  final bool isAccepted;
  final DateTime? acceptedAt;

  const WorkspaceInvitation({
    required this.id,
    required this.workspaceId,
    required this.invitedBy,
    required this.email,
    required this.role,
    required this.token,
    required this.expiresAt,
    required this.createdAt,
    required this.isAccepted,
    this.acceptedAt,
  });

  factory WorkspaceInvitation.fromJson(Map<String, dynamic> json) =>
      _$WorkspaceInvitationFromJson(json);

  Map<String, dynamic> toJson() => _$WorkspaceInvitationToJson(this);

  /// Create a new invitation
  factory WorkspaceInvitation.create({
    required String workspaceId,
    required String invitedBy,
    required String email,
    required UserRole role,
  }) {
    final now = DateTime.now();
    final token = 'inv_${now.millisecondsSinceEpoch}_${email.hashCode}';

    return WorkspaceInvitation(
      id: 'invitation_${now.millisecondsSinceEpoch}',
      workspaceId: workspaceId,
      invitedBy: invitedBy,
      email: email,
      role: role,
      token: token,
      expiresAt: now.add(const Duration(days: 7)), // 7 days to accept
      createdAt: now,
      isAccepted: false,
    );
  }

  /// Check if invitation is expired
  bool get isExpired => DateTime.now().isAfter(expiresAt);

  /// Check if invitation is valid
  bool get isValid => !isAccepted && !isExpired;

  @override
  List<Object?> get props => [
        id,
        workspaceId,
        invitedBy,
        email,
        role,
        token,
        expiresAt,
        createdAt,
        isAccepted,
        acceptedAt,
      ];
}

/// Role-based permissions mapping
const Map<UserRole, Set<Permission>> _rolePermissions = {
  UserRole.owner: {
    // All permissions for workspace owner
    Permission.createProject,
    Permission.deleteProject,
    Permission.editProjectSettings,
    Permission.viewProject,
    Permission.createTranslation,
    Permission.editTranslation,
    Permission.deleteTranslation,
    Permission.reviewTranslation,
    Permission.approveTranslation,
    Permission.publishTranslation,
    Permission.inviteMembers,
    Permission.removeMembers,
    Permission.editMemberRoles,
    Permission.viewMembers,
    Permission.editWorkspaceSettings,
    Permission.deleteWorkspace,
    Permission.exportData,
    Permission.viewAnalytics,
    Permission.manageIntegrations,
  },
  UserRole.admin: {
    Permission.createProject,
    Permission.deleteProject,
    Permission.editProjectSettings,
    Permission.viewProject,
    Permission.createTranslation,
    Permission.editTranslation,
    Permission.deleteTranslation,
    Permission.reviewTranslation,
    Permission.approveTranslation,
    Permission.publishTranslation,
    Permission.inviteMembers,
    Permission.removeMembers,
    Permission.editMemberRoles,
    Permission.viewMembers,
    Permission.exportData,
    Permission.viewAnalytics,
    Permission.manageIntegrations,
  },
  UserRole.editor: {
    Permission.createProject,
    Permission.editProjectSettings,
    Permission.viewProject,
    Permission.createTranslation,
    Permission.editTranslation,
    Permission.reviewTranslation,
    Permission.inviteMembers,
    Permission.viewMembers,
    Permission.viewAnalytics,
  },
  UserRole.translator: {
    Permission.viewProject,
    Permission.createTranslation,
    Permission.editTranslation,
    Permission.viewMembers,
  },
  UserRole.reviewer: {
    Permission.viewProject,
    Permission.reviewTranslation,
    Permission.approveTranslation,
    Permission.viewMembers,
  },
  UserRole.viewer: {
    Permission.viewProject,
    Permission.viewMembers,
  },
  UserRole.guest: {
    Permission.viewProject,
  },
};
