// 🏢 LingoSphere - Team Workspace Service
// Enterprise collaboration service for managing team workspaces and projects

import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/team_workspace_models.dart';

/// Service for managing team workspaces and collaborative projects
class TeamWorkspaceService {
  final http.Client _httpClient;
  final String _baseUrl;
  final Map<String, TeamWorkspace> _workspaceCache = {};
  final Map<String, CollaborativeProject> _projectCache = {};
  final StreamController<WorkspaceEvent> _eventController =
      StreamController.broadcast();

  TeamWorkspaceService({
    http.Client? httpClient,
    String? baseUrl,
  })  : _httpClient = httpClient ?? http.Client(),
        _baseUrl = baseUrl ?? 'https://api.lingosphere.com/v1';

  /// Stream of workspace events for real-time updates
  Stream<WorkspaceEvent> get events => _eventController.stream;

  // WORKSPACE MANAGEMENT

  /// Create a new team workspace
  Future<TeamWorkspace> createWorkspace({
    required String name,
    required String ownerId,
    String? description,
    CollaborationType collaborationType = CollaborationType.team,
  }) async {
    try {
      final workspace = TeamWorkspace.create(
        name: name,
        ownerId: ownerId,
        description: description,
        collaborationType: collaborationType,
      );

      // In a real implementation, this would make an API call
      await _simulateApiCall();

      _workspaceCache[workspace.id] = workspace;

      _eventController.add(WorkspaceEvent.created(workspace));

      return workspace;
    } catch (e) {
      throw WorkspaceException('Failed to create workspace: $e');
    }
  }

  /// Get workspace by ID
  Future<TeamWorkspace?> getWorkspace(String workspaceId) async {
    try {
      // Check cache first
      if (_workspaceCache.containsKey(workspaceId)) {
        return _workspaceCache[workspaceId];
      }

      // In a real implementation, this would make an API call
      await _simulateApiCall();

      // For demo purposes, return null if not in cache
      return null;
    } catch (e) {
      throw WorkspaceException('Failed to get workspace: $e');
    }
  }

  /// Get all workspaces for a user
  Future<List<TeamWorkspace>> getUserWorkspaces(String userId) async {
    try {
      await _simulateApiCall();

      return _workspaceCache.values
          .where((workspace) => workspace.getMember(userId) != null)
          .toList();
    } catch (e) {
      throw WorkspaceException('Failed to get user workspaces: $e');
    }
  }

  /// Update workspace settings
  Future<TeamWorkspace> updateWorkspace({
    required String workspaceId,
    required String userId,
    String? name,
    String? description,
    String? logoUrl,
    WorkspaceSettings? settings,
  }) async {
    try {
      final workspace = await getWorkspace(workspaceId);
      if (workspace == null) {
        throw WorkspaceException('Workspace not found');
      }

      if (!workspace.hasPermission(userId, Permission.editWorkspaceSettings)) {
        throw WorkspaceException('Insufficient permissions');
      }

      final updatedWorkspace = workspace.copyWith(
        name: name,
        description: description,
        logoUrl: logoUrl,
        settings: settings,
        updatedAt: DateTime.now(),
      );

      await _simulateApiCall();

      _workspaceCache[workspaceId] = updatedWorkspace;

      _eventController.add(WorkspaceEvent.updated(updatedWorkspace));

      return updatedWorkspace;
    } catch (e) {
      throw WorkspaceException('Failed to update workspace: $e');
    }
  }

  /// Delete a workspace
  Future<void> deleteWorkspace(String workspaceId, String userId) async {
    try {
      final workspace = await getWorkspace(workspaceId);
      if (workspace == null) {
        throw WorkspaceException('Workspace not found');
      }

      if (!workspace.hasPermission(userId, Permission.deleteWorkspace)) {
        throw WorkspaceException('Insufficient permissions');
      }

      await _simulateApiCall();

      _workspaceCache.remove(workspaceId);

      _eventController.add(WorkspaceEvent.deleted(workspaceId));
    } catch (e) {
      throw WorkspaceException('Failed to delete workspace: $e');
    }
  }

  // MEMBER MANAGEMENT

  /// Invite a user to workspace
  Future<WorkspaceInvitation> inviteUser({
    required String workspaceId,
    required String invitedBy,
    required String email,
    required UserRole role,
  }) async {
    try {
      final workspace = await getWorkspace(workspaceId);
      if (workspace == null) {
        throw WorkspaceException('Workspace not found');
      }

      if (!workspace.hasPermission(invitedBy, Permission.inviteMembers)) {
        throw WorkspaceException('Insufficient permissions to invite members');
      }

      final invitation = WorkspaceInvitation.create(
        workspaceId: workspaceId,
        invitedBy: invitedBy,
        email: email,
        role: role,
      );

      await _simulateApiCall();

      _eventController.add(WorkspaceEvent.memberInvited(invitation));

      return invitation;
    } catch (e) {
      throw WorkspaceException('Failed to invite user: $e');
    }
  }

  /// Accept workspace invitation
  Future<TeamWorkspace> acceptInvitation({
    required String invitationToken,
    required String userId,
  }) async {
    try {
      // In a real implementation, validate the token and get invitation
      await _simulateApiCall();

      // For demo purposes, simulate adding member to a workspace
      final workspaceId = 'demo_workspace';
      final workspace = await getWorkspace(workspaceId);

      if (workspace != null) {
        final newMember = WorkspaceMember.create(
          userId: userId,
          workspaceId: workspaceId,
          role: UserRole.translator,
        );

        final updatedWorkspace = workspace.copyWith(
          members: [...workspace.members, newMember],
          updatedAt: DateTime.now(),
        );

        _workspaceCache[workspaceId] = updatedWorkspace;

        _eventController.add(WorkspaceEvent.memberJoined(newMember));

        return updatedWorkspace;
      }

      throw WorkspaceException('Workspace not found');
    } catch (e) {
      throw WorkspaceException('Failed to accept invitation: $e');
    }
  }

  /// Update member role
  Future<TeamWorkspace> updateMemberRole({
    required String workspaceId,
    required String userId,
    required String targetUserId,
    required UserRole newRole,
  }) async {
    try {
      final workspace = await getWorkspace(workspaceId);
      if (workspace == null) {
        throw WorkspaceException('Workspace not found');
      }

      if (!workspace.hasPermission(userId, Permission.editMemberRoles)) {
        throw WorkspaceException('Insufficient permissions');
      }

      final updatedMembers = workspace.members.map((member) {
        if (member.userId == targetUserId) {
          return member.copyWith(role: newRole);
        }
        return member;
      }).toList();

      final updatedWorkspace = workspace.copyWith(
        members: updatedMembers,
        updatedAt: DateTime.now(),
      );

      await _simulateApiCall();

      _workspaceCache[workspaceId] = updatedWorkspace;

      _eventController.add(
          WorkspaceEvent.memberRoleUpdated(workspaceId, targetUserId, newRole));

      return updatedWorkspace;
    } catch (e) {
      throw WorkspaceException('Failed to update member role: $e');
    }
  }

  /// Remove member from workspace
  Future<TeamWorkspace> removeMember({
    required String workspaceId,
    required String userId,
    required String targetUserId,
  }) async {
    try {
      final workspace = await getWorkspace(workspaceId);
      if (workspace == null) {
        throw WorkspaceException('Workspace not found');
      }

      if (!workspace.hasPermission(userId, Permission.removeMembers)) {
        throw WorkspaceException('Insufficient permissions');
      }

      if (workspace.ownerId == targetUserId) {
        throw WorkspaceException('Cannot remove workspace owner');
      }

      final updatedMembers = workspace.members
          .where((member) => member.userId != targetUserId)
          .toList();

      final updatedWorkspace = workspace.copyWith(
        members: updatedMembers,
        updatedAt: DateTime.now(),
      );

      await _simulateApiCall();

      _workspaceCache[workspaceId] = updatedWorkspace;

      _eventController
          .add(WorkspaceEvent.memberRemoved(workspaceId, targetUserId));

      return updatedWorkspace;
    } catch (e) {
      throw WorkspaceException('Failed to remove member: $e');
    }
  }

  // PROJECT MANAGEMENT

  /// Create a new collaborative project
  Future<CollaborativeProject> createProject({
    required String workspaceId,
    required String name,
    required String createdBy,
    required String sourceLanguage,
    required List<String> targetLanguages,
    String? description,
  }) async {
    try {
      final workspace = await getWorkspace(workspaceId);
      if (workspace == null) {
        throw WorkspaceException('Workspace not found');
      }

      if (!workspace.hasPermission(createdBy, Permission.createProject)) {
        throw WorkspaceException('Insufficient permissions to create project');
      }

      final project = CollaborativeProject.create(
        workspaceId: workspaceId,
        name: name,
        createdBy: createdBy,
        sourceLanguage: sourceLanguage,
        targetLanguages: targetLanguages,
        description: description,
      );

      await _simulateApiCall();

      _projectCache[project.id] = project;

      // Update workspace with new project
      final updatedWorkspace = workspace.copyWith(
        projectIds: [...workspace.projectIds, project.id],
        updatedAt: DateTime.now(),
      );
      _workspaceCache[workspaceId] = updatedWorkspace;

      _eventController.add(WorkspaceEvent.projectCreated(project));

      return project;
    } catch (e) {
      throw WorkspaceException('Failed to create project: $e');
    }
  }

  /// Get project by ID
  Future<CollaborativeProject?> getProject(String projectId) async {
    try {
      if (_projectCache.containsKey(projectId)) {
        return _projectCache[projectId];
      }

      await _simulateApiCall();
      return null;
    } catch (e) {
      throw WorkspaceException('Failed to get project: $e');
    }
  }

  /// Get all projects in a workspace
  Future<List<CollaborativeProject>> getWorkspaceProjects(
      String workspaceId) async {
    try {
      await _simulateApiCall();

      return _projectCache.values
          .where((project) => project.workspaceId == workspaceId)
          .toList();
    } catch (e) {
      throw WorkspaceException('Failed to get workspace projects: $e');
    }
  }

  /// Update project status
  Future<CollaborativeProject> updateProjectStatus({
    required String projectId,
    required String userId,
    required ProjectStatus newStatus,
  }) async {
    try {
      final project = await getProject(projectId);
      if (project == null) {
        throw WorkspaceException('Project not found');
      }

      final workspace = await getWorkspace(project.workspaceId);
      if (workspace == null) {
        throw WorkspaceException('Workspace not found');
      }

      // Check if user has permission for this status change
      final member = project.getMember(userId);
      if (member == null) {
        throw WorkspaceException('User is not a project member');
      }

      final allowedRoles = project.workflow.statusPermissions[newStatus] ?? [];
      if (!allowedRoles.contains(member.role)) {
        throw WorkspaceException('Insufficient permissions for status change');
      }

      final updatedProject = project.copyWith(
        status: newStatus,
        updatedAt: DateTime.now(),
        completedAt:
            newStatus == ProjectStatus.published ? DateTime.now() : null,
      );

      await _simulateApiCall();

      _projectCache[projectId] = updatedProject;

      _eventController
          .add(WorkspaceEvent.projectStatusUpdated(projectId, newStatus));

      return updatedProject;
    } catch (e) {
      throw WorkspaceException('Failed to update project status: $e');
    }
  }

  /// Add member to project
  Future<CollaborativeProject> addProjectMember({
    required String projectId,
    required String userId,
    required String targetUserId,
    required UserRole role,
    List<String> assignedLanguages = const [],
  }) async {
    try {
      final project = await getProject(projectId);
      if (project == null) {
        throw WorkspaceException('Project not found');
      }

      final workspace = await getWorkspace(project.workspaceId);
      if (workspace == null ||
          !workspace.hasPermission(userId, Permission.inviteMembers)) {
        throw WorkspaceException('Insufficient permissions');
      }

      final newMember = ProjectMember.create(
        userId: targetUserId,
        projectId: projectId,
        role: role,
        assignedLanguages: assignedLanguages,
      );

      final updatedProject = project.copyWith(
        members: [...project.members, newMember],
        updatedAt: DateTime.now(),
      );

      await _simulateApiCall();

      _projectCache[projectId] = updatedProject;

      _eventController.add(WorkspaceEvent.projectMemberAdded(newMember));

      return updatedProject;
    } catch (e) {
      throw WorkspaceException('Failed to add project member: $e');
    }
  }

  // ANALYTICS AND REPORTING

  /// Get workspace analytics
  Future<WorkspaceAnalytics> getWorkspaceAnalytics(String workspaceId) async {
    try {
      final workspace = await getWorkspace(workspaceId);
      if (workspace == null) {
        throw WorkspaceException('Workspace not found');
      }

      final projects = await getWorkspaceProjects(workspaceId);

      await _simulateApiCall();

      return WorkspaceAnalytics(
        workspaceId: workspaceId,
        totalMembers: workspace.members.length,
        activeMembers: workspace.activeMembersCount,
        totalProjects: projects.length,
        activeProjects: projects.where((p) => p.isActive).length,
        completedProjects:
            projects.where((p) => p.status == ProjectStatus.published).length,
        averageCompletionTime: _calculateAverageCompletionTime(projects),
        memberActivityStats: _calculateMemberActivityStats(workspace.members),
        projectStatusDistribution:
            _calculateProjectStatusDistribution(projects),
        translationStats: _calculateTranslationStats(projects),
        generatedAt: DateTime.now(),
      );
    } catch (e) {
      throw WorkspaceException('Failed to get workspace analytics: $e');
    }
  }

  /// Get project analytics
  Future<ProjectAnalytics> getProjectAnalytics(String projectId) async {
    try {
      final project = await getProject(projectId);
      if (project == null) {
        throw WorkspaceException('Project not found');
      }

      await _simulateApiCall();

      return ProjectAnalytics(
        projectId: projectId,
        completionPercentage: project.completionPercentage,
        totalTranslations: project.translationIds.length,
        completedTranslations:
            (project.translationIds.length * project.completionPercentage)
                .round(),
        memberContributions: _calculateMemberContributions(project.members),
        languageProgress: _calculateLanguageProgress(project.targetLanguages),
        qualityMetrics: _calculateQualityMetrics(),
        timeToComplete: project.completedAt != null
            ? project.completedAt!.difference(project.createdAt)
            : null,
        generatedAt: DateTime.now(),
      );
    } catch (e) {
      throw WorkspaceException('Failed to get project analytics: $e');
    }
  }

  // UTILITY METHODS

  /// Check if user has permission in workspace
  Future<bool> hasWorkspacePermission({
    required String workspaceId,
    required String userId,
    required Permission permission,
  }) async {
    try {
      final workspace = await getWorkspace(workspaceId);
      return workspace?.hasPermission(userId, permission) ?? false;
    } catch (e) {
      return false;
    }
  }

  /// Get user's role in workspace
  Future<UserRole?> getUserRole(String workspaceId, String userId) async {
    try {
      final workspace = await getWorkspace(workspaceId);
      return workspace?.getMember(userId)?.role;
    } catch (e) {
      return null;
    }
  }

  /// Search workspaces
  Future<List<TeamWorkspace>> searchWorkspaces({
    required String userId,
    String? query,
    List<CollaborationType>? types,
  }) async {
    try {
      await _simulateApiCall();

      var workspaces = await getUserWorkspaces(userId);

      if (query != null && query.isNotEmpty) {
        workspaces = workspaces
            .where((workspace) =>
                workspace.name.toLowerCase().contains(query.toLowerCase()) ||
                (workspace.description
                        ?.toLowerCase()
                        .contains(query.toLowerCase()) ??
                    false))
            .toList();
      }

      if (types != null && types.isNotEmpty) {
        workspaces = workspaces
            .where((workspace) => types.contains(workspace.collaborationType))
            .toList();
      }

      return workspaces;
    } catch (e) {
      throw WorkspaceException('Failed to search workspaces: $e');
    }
  }

  // PRIVATE HELPER METHODS

  Future<void> _simulateApiCall() async {
    // Simulate network latency
    await Future.delayed(const Duration(milliseconds: 200));
  }

  Duration _calculateAverageCompletionTime(
      List<CollaborativeProject> projects) {
    final completedProjects =
        projects.where((p) => p.completedAt != null).toList();

    if (completedProjects.isEmpty) return Duration.zero;

    final totalDuration = completedProjects.fold<Duration>(
      Duration.zero,
      (sum, project) =>
          sum + project.completedAt!.difference(project.createdAt),
    );

    return Duration(
      milliseconds: totalDuration.inMilliseconds ~/ completedProjects.length,
    );
  }

  Map<String, int> _calculateMemberActivityStats(
      List<WorkspaceMember> members) {
    final now = DateTime.now();
    var active = 0;
    var recentlyActive = 0;
    var inactive = 0;

    for (final member in members) {
      if (!member.isActive) {
        inactive++;
        continue;
      }

      final lastActive = member.lastActiveAt ?? member.joinedAt;
      final daysSinceActive = now.difference(lastActive).inDays;

      if (daysSinceActive <= 1) {
        active++;
      } else if (daysSinceActive <= 7) {
        recentlyActive++;
      } else {
        inactive++;
      }
    }

    return {
      'active': active,
      'recentlyActive': recentlyActive,
      'inactive': inactive,
    };
  }

  Map<ProjectStatus, int> _calculateProjectStatusDistribution(
      List<CollaborativeProject> projects) {
    final distribution = <ProjectStatus, int>{};

    for (final status in ProjectStatus.values) {
      distribution[status] = 0;
    }

    for (final project in projects) {
      distribution[project.status] = (distribution[project.status] ?? 0) + 1;
    }

    return distribution;
  }

  Map<String, dynamic> _calculateTranslationStats(
      List<CollaborativeProject> projects) {
    var totalTranslations = 0;
    var completedTranslations = 0;
    final languageStats = <String, int>{};

    for (final project in projects) {
      totalTranslations += project.translationIds.length;
      completedTranslations +=
          (project.translationIds.length * project.completionPercentage)
              .round();

      for (final language in project.targetLanguages) {
        languageStats[language] = (languageStats[language] ?? 0) + 1;
      }
    }

    return {
      'total': totalTranslations,
      'completed': completedTranslations,
      'languages': languageStats,
    };
  }

  Map<String, int> _calculateMemberContributions(List<ProjectMember> members) {
    // Simulate member contributions
    final contributions = <String, int>{};

    for (final member in members) {
      // In a real implementation, this would be based on actual translation data
      contributions[member.userId] = (member.assignedLanguages.length * 10) +
          (DateTime.now().difference(member.joinedAt).inDays);
    }

    return contributions;
  }

  Map<String, double> _calculateLanguageProgress(List<String> languages) {
    final progress = <String, double>{};

    for (final language in languages) {
      // Simulate progress - in real implementation, calculate from actual data
      progress[language] = 0.3 + (language.hashCode % 70) / 100.0;
    }

    return progress;
  }

  Map<String, double> _calculateQualityMetrics() {
    return {
      'averageQuality': 0.85,
      'reviewApprovalRate': 0.92,
      'errorRate': 0.08,
      'consistencyScore': 0.88,
    };
  }

  void dispose() {
    _eventController.close();
    _httpClient.close();
  }
}

/// Workspace analytics data
class WorkspaceAnalytics {
  final String workspaceId;
  final int totalMembers;
  final int activeMembers;
  final int totalProjects;
  final int activeProjects;
  final int completedProjects;
  final Duration averageCompletionTime;
  final Map<String, int> memberActivityStats;
  final Map<ProjectStatus, int> projectStatusDistribution;
  final Map<String, dynamic> translationStats;
  final DateTime generatedAt;

  const WorkspaceAnalytics({
    required this.workspaceId,
    required this.totalMembers,
    required this.activeMembers,
    required this.totalProjects,
    required this.activeProjects,
    required this.completedProjects,
    required this.averageCompletionTime,
    required this.memberActivityStats,
    required this.projectStatusDistribution,
    required this.translationStats,
    required this.generatedAt,
  });
}

/// Project analytics data
class ProjectAnalytics {
  final String projectId;
  final double completionPercentage;
  final int totalTranslations;
  final int completedTranslations;
  final Map<String, int> memberContributions;
  final Map<String, double> languageProgress;
  final Map<String, double> qualityMetrics;
  final Duration? timeToComplete;
  final DateTime generatedAt;

  const ProjectAnalytics({
    required this.projectId,
    required this.completionPercentage,
    required this.totalTranslations,
    required this.completedTranslations,
    required this.memberContributions,
    required this.languageProgress,
    required this.qualityMetrics,
    this.timeToComplete,
    required this.generatedAt,
  });
}

/// Workspace events for real-time updates
abstract class WorkspaceEvent {
  const WorkspaceEvent();

  factory WorkspaceEvent.created(TeamWorkspace workspace) = WorkspaceCreated;
  factory WorkspaceEvent.updated(TeamWorkspace workspace) = WorkspaceUpdated;
  factory WorkspaceEvent.deleted(String workspaceId) = WorkspaceDeleted;
  factory WorkspaceEvent.memberInvited(WorkspaceInvitation invitation) =
      MemberInvited;
  factory WorkspaceEvent.memberJoined(WorkspaceMember member) = MemberJoined;
  factory WorkspaceEvent.memberRemoved(String workspaceId, String userId) =
      MemberRemoved;
  factory WorkspaceEvent.memberRoleUpdated(
      String workspaceId, String userId, UserRole role) = MemberRoleUpdated;
  factory WorkspaceEvent.projectCreated(CollaborativeProject project) =
      ProjectCreated;
  factory WorkspaceEvent.projectStatusUpdated(
      String projectId, ProjectStatus status) = ProjectStatusUpdated;
  factory WorkspaceEvent.projectMemberAdded(ProjectMember member) =
      ProjectMemberAdded;
}

class WorkspaceCreated extends WorkspaceEvent {
  final TeamWorkspace workspace;
  const WorkspaceCreated(this.workspace);
}

class WorkspaceUpdated extends WorkspaceEvent {
  final TeamWorkspace workspace;
  const WorkspaceUpdated(this.workspace);
}

class WorkspaceDeleted extends WorkspaceEvent {
  final String workspaceId;
  const WorkspaceDeleted(this.workspaceId);
}

class MemberInvited extends WorkspaceEvent {
  final WorkspaceInvitation invitation;
  const MemberInvited(this.invitation);
}

class MemberJoined extends WorkspaceEvent {
  final WorkspaceMember member;
  const MemberJoined(this.member);
}

class MemberRemoved extends WorkspaceEvent {
  final String workspaceId;
  final String userId;
  const MemberRemoved(this.workspaceId, this.userId);
}

class MemberRoleUpdated extends WorkspaceEvent {
  final String workspaceId;
  final String userId;
  final UserRole role;
  const MemberRoleUpdated(this.workspaceId, this.userId, this.role);
}

class ProjectCreated extends WorkspaceEvent {
  final CollaborativeProject project;
  const ProjectCreated(this.project);
}

class ProjectStatusUpdated extends WorkspaceEvent {
  final String projectId;
  final ProjectStatus status;
  const ProjectStatusUpdated(this.projectId, this.status);
}

class ProjectMemberAdded extends WorkspaceEvent {
  final ProjectMember member;
  const ProjectMemberAdded(this.member);
}

/// Exception thrown by workspace operations
class WorkspaceException implements Exception {
  final String message;
  const WorkspaceException(this.message);

  @override
  String toString() => 'WorkspaceException: $message';
}
