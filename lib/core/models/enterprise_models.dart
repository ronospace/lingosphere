// 🏢 LingoSphere - Enterprise Models  
// Comprehensive data models for enterprise collaboration, security, and integration


/// Core Enterprise Models
class Organization {
  final String id;
  final String name;
  final String displayName;
  final OrganizationType type;
  final String domain;
  final List<String> allowedDomains;
  final OrganizationTier tier;
  final OrganizationStatus status;
  final Map<String, dynamic> settings;
  final DateTime createdAt;
  final Map<String, dynamic> metadata;

  Organization({
    required this.id,
    required this.name,
    required this.displayName,
    required this.type,
    required this.domain,
    required this.allowedDomains,
    required this.tier,
    required this.status,
    required this.settings,
    required this.createdAt,
    required this.metadata,
  });

  static Organization empty() => Organization(
    id: '',
    name: '',
    displayName: '',
    type: OrganizationType.business,
    domain: '',
    allowedDomains: [],
    tier: OrganizationTier.basic,
    status: OrganizationStatus.active,
    settings: {},
    createdAt: DateTime.now(),
    metadata: {},
  );
}

class EnterpriseWorkspace {
  final String id;
  final String organizationId;
  final String name;
  final String description;
  final WorkspaceType type;
  final List<String> memberIds;
  final Map<String, WorkspaceRole> memberRoles;
  final WorkspaceSettings settings;
  final List<Channel> channels;
  final List<Project> projects;
  final DateTime createdAt;
  final String createdBy;

  EnterpriseWorkspace({
    required this.id,
    required this.organizationId,
    required this.name,
    required this.description,
    required this.type,
    required this.memberIds,
    required this.memberRoles,
    required this.settings,
    required this.channels,
    required this.projects,
    required this.createdAt,
    required this.createdBy,
  });
}

class Channel {
  final String id;
  final String workspaceId;
  final String name;
  final ChannelType type;
  final ChannelVisibility visibility;
  final String? description;
  final List<String> memberIds;
  final ChannelSettings settings;
  final DateTime createdAt;
  final String createdBy;
  final DateTime? archivedAt;

  Channel({
    required this.id,
    required this.workspaceId,
    required this.name,
    required this.type,
    required this.visibility,
    this.description,
    required this.memberIds,
    required this.settings,
    required this.createdAt,
    required this.createdBy,
    this.archivedAt,
  });
}

class Project {
  final String id;
  final String workspaceId;
  final String name;
  final String description;
  final ProjectStatus status;
  final String? projectManagerId;
  final List<String> teamMemberIds;
  final Map<String, ProjectRole> memberRoles;
  final List<ProjectTask> tasks;
  final List<ProjectMilestone> milestones;
  final DateTime startDate;
  final DateTime? endDate;
  final Map<String, dynamic> metadata;

  Project({
    required this.id,
    required this.workspaceId,
    required this.name,
    required this.description,
    required this.status,
    this.projectManagerId,
    required this.teamMemberIds,
    required this.memberRoles,
    required this.tasks,
    required this.milestones,
    required this.startDate,
    this.endDate,
    required this.metadata,
  });
}

class ProjectTask {
  final String id;
  final String projectId;
  final String title;
  final String description;
  final TaskStatus status;
  final TaskPriority priority;
  final String? assigneeId;
  final DateTime? dueDate;
  final List<String> dependencies;
  final Map<String, dynamic> customFields;
  final DateTime createdAt;
  final String createdBy;

  ProjectTask({
    required this.id,
    required this.projectId,
    required this.title,
    required this.description,
    required this.status,
    required this.priority,
    this.assigneeId,
    this.dueDate,
    required this.dependencies,
    required this.customFields,
    required this.createdAt,
    required this.createdBy,
  });
}

class ProjectMilestone {
  final String id;
  final String projectId;
  final String title;
  final String description;
  final DateTime targetDate;
  final DateTime? achievedDate;
  final MilestoneStatus status;
  final List<String> linkedTaskIds;

  ProjectMilestone({
    required this.id,
    required this.projectId,
    required this.title,
    required this.description,
    required this.targetDate,
    this.achievedDate,
    required this.status,
    required this.linkedTaskIds,
  });
}

class EnterpriseUser {
  final String id;
  final String organizationId;
  final String email;
  final String displayName;
  final String? firstName;
  final String? lastName;
  final UserRole role;
  final UserStatus status;
  final List<String> departmentIds;
  final String? managerId;
  final List<Permission> permissions;
  final Map<String, dynamic> profile;
  final DateTime createdAt;
  final DateTime? lastLoginAt;

  EnterpriseUser({
    required this.id,
    required this.organizationId,
    required this.email,
    required this.displayName,
    this.firstName,
    this.lastName,
    required this.role,
    required this.status,
    required this.departmentIds,
    this.managerId,
    required this.permissions,
    required this.profile,
    required this.createdAt,
    this.lastLoginAt,
  });
}

class Department {
  final String id;
  final String organizationId;
  final String name;
  final String description;
  final String? headId;
  final List<String> memberIds;
  final String? parentDepartmentId;
  final List<String> childDepartmentIds;
  final Map<String, dynamic> settings;

  Department({
    required this.id,
    required this.organizationId,
    required this.name,
    required this.description,
    this.headId,
    required this.memberIds,
    this.parentDepartmentId,
    required this.childDepartmentIds,
    required this.settings,
  });
}

class SecurityPolicy {
  final String id;
  final String organizationId;
  final String name;
  final PolicyType type;
  final PolicySeverity severity;
  final Map<String, dynamic> rules;
  final List<String> affectedRoles;
  final bool isActive;
  final DateTime createdAt;
  final String createdBy;
  final DateTime? lastModifiedAt;

  SecurityPolicy({
    required this.id,
    required this.organizationId,
    required this.name,
    required this.type,
    required this.severity,
    required this.rules,
    required this.affectedRoles,
    required this.isActive,
    required this.createdAt,
    required this.createdBy,
    this.lastModifiedAt,
  });
}

class AccessControl {
  final String resourceId;
  final ResourceType resourceType;
  final String userId;
  final List<Permission> permissions;
  final AccessLevel accessLevel;
  final DateTime grantedAt;
  final String grantedBy;
  final DateTime? expiresAt;
  final Map<String, dynamic> conditions;

  AccessControl({
    required this.resourceId,
    required this.resourceType,
    required this.userId,
    required this.permissions,
    required this.accessLevel,
    required this.grantedAt,
    required this.grantedBy,
    this.expiresAt,
    required this.conditions,
  });
}

class AuditLog {
  final String id;
  final String organizationId;
  final String userId;
  final AuditAction action;
  final String resourceId;
  final ResourceType resourceType;
  final Map<String, dynamic> details;
  final String? ipAddress;
  final String? userAgent;
  final DateTime timestamp;
  final AuditResult result;

  AuditLog({
    required this.id,
    required this.organizationId,
    required this.userId,
    required this.action,
    required this.resourceId,
    required this.resourceType,
    required this.details,
    this.ipAddress,
    this.userAgent,
    required this.timestamp,
    required this.result,
  });
}

class ComplianceReport {
  final String id;
  final String organizationId;
  final ComplianceType type;
  final ReportPeriod period;
  final DateTime periodStart;
  final DateTime periodEnd;
  final Map<String, ComplianceMetric> metrics;
  final List<ComplianceViolation> violations;
  final ComplianceStatus status;
  final DateTime generatedAt;
  final String generatedBy;

  ComplianceReport({
    required this.id,
    required this.organizationId,
    required this.type,
    required this.period,
    required this.periodStart,
    required this.periodEnd,
    required this.metrics,
    required this.violations,
    required this.status,
    required this.generatedAt,
    required this.generatedBy,
  });
}

class ComplianceMetric {
  final String name;
  final double value;
  final String unit;
  final double threshold;
  final bool isCompliant;
  final String? description;

  ComplianceMetric({
    required this.name,
    required this.value,
    required this.unit,
    required this.threshold,
    required this.isCompliant,
    this.description,
  });
}

class ComplianceViolation {
  final String id;
  final ViolationType type;
  final ViolationSeverity severity;
  final String description;
  final String resourceId;
  final ResourceType resourceType;
  final DateTime detectedAt;
  final ViolationStatus status;
  final String? remedialAction;
  final DateTime? resolvedAt;

  ComplianceViolation({
    required this.id,
    required this.type,
    required this.severity,
    required this.description,
    required this.resourceId,
    required this.resourceType,
    required this.detectedAt,
    required this.status,
    this.remedialAction,
    this.resolvedAt,
  });
}

class IntegrationConfig {
  final String id;
  final String organizationId;
  final IntegrationType type;
  final String name;
  final IntegrationStatus status;
  final Map<String, dynamic> configuration;
  final Map<String, String> credentials;
  final List<String> enabledFeatures;
  final DateTime createdAt;
  final String createdBy;
  final DateTime? lastSyncAt;
  final Map<String, dynamic> syncStatus;

  IntegrationConfig({
    required this.id,
    required this.organizationId,
    required this.type,
    required this.name,
    required this.status,
    required this.configuration,
    required this.credentials,
    required this.enabledFeatures,
    required this.createdAt,
    required this.createdBy,
    this.lastSyncAt,
    required this.syncStatus,
  });
}

class WorkflowDefinition {
  final String id;
  final String organizationId;
  final String name;
  final String description;
  final WorkflowTrigger trigger;
  final List<WorkflowStep> steps;
  final Map<String, dynamic> conditions;
  final bool isActive;
  final DateTime createdAt;
  final String createdBy;
  final int version;

  WorkflowDefinition({
    required this.id,
    required this.organizationId,
    required this.name,
    required this.description,
    required this.trigger,
    required this.steps,
    required this.conditions,
    required this.isActive,
    required this.createdAt,
    required this.createdBy,
    required this.version,
  });
}

class WorkflowExecution {
  final String id;
  final String workflowId;
  final String triggeredBy;
  final DateTime startedAt;
  final DateTime? completedAt;
  final WorkflowStatus status;
  final Map<String, WorkflowStepResult> stepResults;
  final String? errorMessage;
  final Map<String, dynamic> context;

  WorkflowExecution({
    required this.id,
    required this.workflowId,
    required this.triggeredBy,
    required this.startedAt,
    this.completedAt,
    required this.status,
    required this.stepResults,
    this.errorMessage,
    required this.context,
  });
}

class WorkflowStep {
  final String id;
  final String name;
  final StepType type;
  final Map<String, dynamic> configuration;
  final List<String> dependencies;
  final int order;
  final bool isRequired;

  WorkflowStep({
    required this.id,
    required this.name,
    required this.type,
    required this.configuration,
    required this.dependencies,
    required this.order,
    required this.isRequired,
  });
}

class WorkflowStepResult {
  final String stepId;
  final StepStatus status;
  final DateTime startedAt;
  final DateTime? completedAt;
  final Map<String, dynamic> output;
  final String? errorMessage;

  WorkflowStepResult({
    required this.stepId,
    required this.status,
    required this.startedAt,
    this.completedAt,
    required this.output,
    this.errorMessage,
  });
}

class EnterpriseSettings {
  final String organizationId;
  final SecuritySettings security;
  final CollaborationSettings collaboration;
  final IntegrationSettings integrations;
  final ComplianceSettings compliance;
  final NotificationSettings notifications;
  final Map<String, dynamic> customSettings;
  final DateTime lastUpdatedAt;
  final String lastUpdatedBy;

  EnterpriseSettings({
    required this.organizationId,
    required this.security,
    required this.collaboration,
    required this.integrations,
    required this.compliance,
    required this.notifications,
    required this.customSettings,
    required this.lastUpdatedAt,
    required this.lastUpdatedBy,
  });
}

class SecuritySettings {
  final bool ssoRequired;
  final bool mfaRequired;
  final int passwordMinLength;
  final bool passwordComplexityRequired;
  final Duration sessionTimeout;
  final List<String> allowedIpRanges;
  final bool auditLoggingEnabled;
  final EncryptionSettings encryption;

  SecuritySettings({
    required this.ssoRequired,
    required this.mfaRequired,
    required this.passwordMinLength,
    required this.passwordComplexityRequired,
    required this.sessionTimeout,
    required this.allowedIpRanges,
    required this.auditLoggingEnabled,
    required this.encryption,
  });
}

class EncryptionSettings {
  final bool encryptAtRest;
  final bool encryptInTransit;
  final String algorithm;
  final int keyLength;
  final Duration keyRotationInterval;

  EncryptionSettings({
    required this.encryptAtRest,
    required this.encryptInTransit,
    required this.algorithm,
    required this.keyLength,
    required this.keyRotationInterval,
  });
}

class CollaborationSettings {
  final bool guestAccessEnabled;
  final bool externalSharingEnabled;
  final int maxMembersPerWorkspace;
  final int maxChannelsPerWorkspace;
  final bool realTimeCollaborationEnabled;
  final bool versionControlEnabled;

  CollaborationSettings({
    required this.guestAccessEnabled,
    required this.externalSharingEnabled,
    required this.maxMembersPerWorkspace,
    required this.maxChannelsPerWorkspace,
    required this.realTimeCollaborationEnabled,
    required this.versionControlEnabled,
  });
}

class IntegrationSettings {
  final bool thirdPartyIntegrationsEnabled;
  final List<IntegrationType> allowedIntegrations;
  final bool webhooksEnabled;
  final bool apiAccessEnabled;
  final Map<String, dynamic> rateLimits;

  IntegrationSettings({
    required this.thirdPartyIntegrationsEnabled,
    required this.allowedIntegrations,
    required this.webhooksEnabled,
    required this.apiAccessEnabled,
    required this.rateLimits,
  });
}

class ComplianceSettings {
  final bool gdprCompliance;
  final bool hipaaCompliance;
  final bool soxCompliance;
  final Duration dataRetentionPeriod;
  final bool automaticDeletionEnabled;
  final List<String> complianceOfficerIds;

  ComplianceSettings({
    required this.gdprCompliance,
    required this.hipaaCompliance,
    required this.soxCompliance,
    required this.dataRetentionPeriod,
    required this.automaticDeletionEnabled,
    required this.complianceOfficerIds,
  });
}

class NotificationSettings {
  final bool emailNotificationsEnabled;
  final bool pushNotificationsEnabled;
  final bool slackNotificationsEnabled;
  final bool teamsNotificationsEnabled;
  final Map<String, bool> notificationPreferences;

  NotificationSettings({
    required this.emailNotificationsEnabled,
    required this.pushNotificationsEnabled,
    required this.slackNotificationsEnabled,
    required this.teamsNotificationsEnabled,
    required this.notificationPreferences,
  });
}

/// Utility Classes
class Permission {
  final String id;
  final String name;
  final String description;
  final ResourceType resourceType;
  final List<String> actions;
  final Map<String, dynamic> conditions;

  Permission({
    required this.id,
    required this.name,
    required this.description,
    required this.resourceType,
    required this.actions,
    required this.conditions,
  });
}

class WorkspaceSettings {
  final bool isPublic;
  final bool allowGuestAccess;
  final bool requireInviteApproval;
  final List<String> defaultChannels;
  final Map<String, dynamic> customFields;

  WorkspaceSettings({
    required this.isPublic,
    required this.allowGuestAccess,
    required this.requireInviteApproval,
    required this.defaultChannels,
    required this.customFields,
  });
}

class ChannelSettings {
  final bool allowFileSharing;
  final bool allowExternalSharing;
  final bool enableTranslation;
  final List<String> allowedFileTypes;
  final int maxFileSize;
  final bool enableEncryption;

  ChannelSettings({
    required this.allowFileSharing,
    required this.allowExternalSharing,
    required this.enableTranslation,
    required this.allowedFileTypes,
    required this.maxFileSize,
    required this.enableEncryption,
  });
}

/// Enums
enum OrganizationType { 
  business, 
  enterprise, 
  government, 
  educational, 
  nonprofit 
}

enum OrganizationTier { 
  basic, 
  professional, 
  enterprise, 
  custom 
}

enum OrganizationStatus { 
  active, 
  suspended, 
  trial, 
  expired 
}

enum WorkspaceType { 
  general, 
  project, 
  department, 
  temporary 
}

enum ChannelType { 
  public, 
  private, 
  direct, 
  announcement 
}

enum ChannelVisibility { 
  public, 
  private, 
  restricted 
}

enum ProjectStatus { 
  planning, 
  active, 
  onHold, 
  completed, 
  cancelled 
}

enum TaskStatus { 
  todo, 
  inProgress, 
  review, 
  done, 
  blocked 
}

enum TaskPriority { 
  low, 
  normal, 
  high, 
  urgent 
}

enum MilestoneStatus { 
  planned, 
  inProgress, 
  achieved, 
  missed 
}

enum UserRole { 
  guest, 
  member, 
  admin, 
  owner, 
  superAdmin 
}

enum UserStatus { 
  active, 
  inactive, 
  suspended, 
  invited 
}

enum WorkspaceRole { 
  viewer, 
  contributor, 
  moderator, 
  admin 
}

enum ProjectRole { 
  observer, 
  contributor, 
  lead, 
  manager 
}

enum PolicyType { 
  security, 
  privacy, 
  compliance, 
  access, 
  retention 
}

enum PolicySeverity { 
  low, 
  medium, 
  high, 
  critical 
}

enum ResourceType { 
  organization, 
  workspace, 
  channel, 
  project, 
  task, 
  document, 
  user 
}

enum AccessLevel { 
  none, 
  read, 
  write, 
  admin, 
  owner 
}

enum AuditAction { 
  create, 
  read, 
  update, 
  delete, 
  login, 
  logout, 
  invite, 
  remove 
}

enum AuditResult { 
  success, 
  failure, 
  partial 
}

enum ComplianceType { 
  gdpr, 
  hipaa, 
  sox, 
  pci, 
  custom 
}

enum ReportPeriod { 
  daily, 
  weekly, 
  monthly, 
  quarterly, 
  yearly 
}

enum ComplianceStatus { 
  compliant, 
  nonCompliant, 
  pending, 
  unknown 
}

enum ViolationType { 
  dataAccess, 
  dataRetention, 
  unauthorizedAccess, 
  policyViolation, 
  securityBreach 
}

enum ViolationSeverity { 
  low, 
  medium, 
  high, 
  critical 
}

enum ViolationStatus { 
  open, 
  investigating, 
  resolved, 
  dismissed 
}

enum IntegrationType { 
  slack, 
  teams, 
  jira, 
  confluence, 
  salesforce, 
  office365, 
  googleWorkspace, 
  github, 
  custom 
}

enum IntegrationStatus { 
  inactive, 
  active, 
  error, 
  syncing 
}

enum WorkflowTrigger { 
  manual, 
  scheduled, 
  event, 
  webhook, 
  apiCall 
}

enum WorkflowStatus { 
  pending, 
  running, 
  completed, 
  failed, 
  cancelled 
}

enum StepType { 
  action, 
  condition, 
  notification, 
  integration, 
  approval, 
  delay 
}

enum StepStatus { 
  pending, 
  running, 
  completed, 
  failed, 
  skipped 
}
