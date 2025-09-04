// ⚡ LingoSphere - Real-Time Collaboration Models
// Data models for WebSocket-based real-time collaborative editing

import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

import 'team_workspace_models.dart';

part 'collaboration_models.g.dart';

/// Type of collaborative event
enum CollaborationEventType {
  // User presence
  userJoined,
  userLeft,
  userIdle,
  userActive,

  // Document operations
  textInsert,
  textDelete,
  textReplace,
  formatChange,

  // Translation operations
  translationStart,
  translationUpdate,
  translationComplete,
  translationReview,
  translationApprove,

  // Cursor and selection
  cursorMove,
  selectionChange,

  // Comments and feedback
  commentAdd,
  commentEdit,
  commentDelete,
  commentResolve,

  // Conflict resolution
  conflictDetected,
  conflictResolved,

  // System events
  documentLock,
  documentUnlock,
  heartbeat,
}

/// Priority levels for collaborative events
enum EventPriority {
  low, // Comments, presence updates
  normal, // Text changes, cursor moves
  high, // Conflicts, system events
  critical, // Emergency locks, errors
}

/// Collaborative document state
enum DocumentState {
  idle,
  editing,
  reviewing,
  locked,
  conflicted,
  syncing,
}

/// Real-time collaboration session
@JsonSerializable()
class CollaborationSession extends Equatable {
  final String id;
  final String documentId;
  final String projectId;
  final String workspaceId;
  final List<CollaborationUser> participants;
  final DocumentState state;
  final int version;
  final DateTime createdAt;
  final DateTime lastActivity;
  final Map<String, dynamic> metadata;

  const CollaborationSession({
    required this.id,
    required this.documentId,
    required this.projectId,
    required this.workspaceId,
    required this.participants,
    required this.state,
    required this.version,
    required this.createdAt,
    required this.lastActivity,
    this.metadata = const {},
  });

  factory CollaborationSession.fromJson(Map<String, dynamic> json) =>
      _$CollaborationSessionFromJson(json);

  Map<String, dynamic> toJson() => _$CollaborationSessionToJson(this);

  /// Create a new collaboration session
  factory CollaborationSession.create({
    required String documentId,
    required String projectId,
    required String workspaceId,
  }) {
    final now = DateTime.now();
    return CollaborationSession(
      id: 'session_${now.millisecondsSinceEpoch}',
      documentId: documentId,
      projectId: projectId,
      workspaceId: workspaceId,
      participants: [],
      state: DocumentState.idle,
      version: 1,
      createdAt: now,
      lastActivity: now,
    );
  }

  /// Get active participants count
  int get activeParticipantsCount =>
      participants.where((user) => user.isActive).length;

  /// Check if user is participant
  bool hasUser(String userId) =>
      participants.any((user) => user.userId == userId);

  /// Get user by ID
  CollaborationUser? getUser(String userId) {
    try {
      return participants.firstWhere((user) => user.userId == userId);
    } catch (e) {
      return null;
    }
  }

  /// Copy with updated fields
  CollaborationSession copyWith({
    List<CollaborationUser>? participants,
    DocumentState? state,
    int? version,
    DateTime? lastActivity,
    Map<String, dynamic>? metadata,
  }) {
    return CollaborationSession(
      id: id,
      documentId: documentId,
      projectId: projectId,
      workspaceId: workspaceId,
      participants: participants ?? this.participants,
      state: state ?? this.state,
      version: version ?? this.version,
      createdAt: createdAt,
      lastActivity: lastActivity ?? DateTime.now(),
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  List<Object?> get props => [
        id,
        documentId,
        projectId,
        workspaceId,
        participants,
        state,
        version,
        createdAt,
        lastActivity,
        metadata,
      ];
}

/// User participating in collaborative editing
@JsonSerializable()
class CollaborationUser extends Equatable {
  final String userId;
  final String displayName;
  final String? avatarUrl;
  final UserRole role;
  final bool isActive;
  final DateTime joinedAt;
  final DateTime lastSeen;
  final CursorPosition? cursor;
  final TextSelection? selection;
  final String color; // User's assigned color for visual identification
  final Map<String, dynamic> metadata;

  const CollaborationUser({
    required this.userId,
    required this.displayName,
    this.avatarUrl,
    required this.role,
    required this.isActive,
    required this.joinedAt,
    required this.lastSeen,
    this.cursor,
    this.selection,
    required this.color,
    this.metadata = const {},
  });

  factory CollaborationUser.fromJson(Map<String, dynamic> json) =>
      _$CollaborationUserFromJson(json);

  Map<String, dynamic> toJson() => _$CollaborationUserToJson(this);

  /// Create a new collaboration user
  factory CollaborationUser.create({
    required String userId,
    required String displayName,
    String? avatarUrl,
    required UserRole role,
    String? color,
  }) {
    final now = DateTime.now();
    return CollaborationUser(
      userId: userId,
      displayName: displayName,
      avatarUrl: avatarUrl,
      role: role,
      isActive: true,
      joinedAt: now,
      lastSeen: now,
      color: color ?? _generateUserColor(userId),
    );
  }

  /// Update user activity
  CollaborationUser updateActivity({
    bool? isActive,
    CursorPosition? cursor,
    TextSelection? selection,
  }) {
    return copyWith(
      isActive: isActive ?? this.isActive,
      cursor: cursor,
      selection: selection,
      lastSeen: DateTime.now(),
    );
  }

  /// Copy with updated fields
  CollaborationUser copyWith({
    String? displayName,
    String? avatarUrl,
    UserRole? role,
    bool? isActive,
    DateTime? lastSeen,
    CursorPosition? cursor,
    TextSelection? selection,
    Map<String, dynamic>? metadata,
  }) {
    return CollaborationUser(
      userId: userId,
      displayName: displayName ?? this.displayName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      role: role ?? this.role,
      isActive: isActive ?? this.isActive,
      joinedAt: joinedAt,
      lastSeen: lastSeen ?? this.lastSeen,
      cursor: cursor ?? this.cursor,
      selection: selection ?? this.selection,
      color: color,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  List<Object?> get props => [
        userId,
        displayName,
        avatarUrl,
        role,
        isActive,
        joinedAt,
        lastSeen,
        cursor,
        selection,
        color,
        metadata,
      ];
}

/// Cursor position in document
@JsonSerializable()
class CursorPosition extends Equatable {
  final int line;
  final int column;
  final int offset;
  final DateTime timestamp;

  const CursorPosition({
    required this.line,
    required this.column,
    required this.offset,
    required this.timestamp,
  });

  factory CursorPosition.fromJson(Map<String, dynamic> json) =>
      _$CursorPositionFromJson(json);

  Map<String, dynamic> toJson() => _$CursorPositionToJson(this);

  /// Create cursor at specific position
  factory CursorPosition.at({
    required int line,
    required int column,
    required int offset,
  }) {
    return CursorPosition(
      line: line,
      column: column,
      offset: offset,
      timestamp: DateTime.now(),
    );
  }

  @override
  List<Object?> get props => [line, column, offset, timestamp];
}

/// Text selection range
@JsonSerializable()
class TextSelection extends Equatable {
  final int startOffset;
  final int endOffset;
  final int startLine;
  final int startColumn;
  final int endLine;
  final int endColumn;
  final String selectedText;
  final DateTime timestamp;

  const TextSelection({
    required this.startOffset,
    required this.endOffset,
    required this.startLine,
    required this.startColumn,
    required this.endLine,
    required this.endColumn,
    required this.selectedText,
    required this.timestamp,
  });

  factory TextSelection.fromJson(Map<String, dynamic> json) =>
      _$TextSelectionFromJson(json);

  Map<String, dynamic> toJson() => _$TextSelectionToJson(this);

  /// Create selection from offsets
  factory TextSelection.fromOffsets({
    required int startOffset,
    required int endOffset,
    required String selectedText,
    required String fullText,
  }) {
    final startPos = _offsetToLineColumn(fullText, startOffset);
    final endPos = _offsetToLineColumn(fullText, endOffset);

    return TextSelection(
      startOffset: startOffset,
      endOffset: endOffset,
      startLine: startPos.line,
      startColumn: startPos.column,
      endLine: endPos.line,
      endColumn: endPos.column,
      selectedText: selectedText,
      timestamp: DateTime.now(),
    );
  }

  /// Get selection length
  int get length => endOffset - startOffset;

  /// Check if selection is empty
  bool get isEmpty => length == 0;

  /// Check if selection contains offset
  bool contains(int offset) => offset >= startOffset && offset <= endOffset;

  @override
  List<Object?> get props => [
        startOffset,
        endOffset,
        startLine,
        startColumn,
        endLine,
        endColumn,
        selectedText,
        timestamp,
      ];
}

/// Real-time collaboration event
@JsonSerializable()
class CollaborationEvent extends Equatable {
  final String id;
  final String sessionId;
  final String userId;
  final CollaborationEventType type;
  final EventPriority priority;
  final Map<String, dynamic> data;
  final int version;
  final DateTime timestamp;
  final String? conflictId;

  const CollaborationEvent({
    required this.id,
    required this.sessionId,
    required this.userId,
    required this.type,
    required this.priority,
    required this.data,
    required this.version,
    required this.timestamp,
    this.conflictId,
  });

  factory CollaborationEvent.fromJson(Map<String, dynamic> json) =>
      _$CollaborationEventFromJson(json);

  Map<String, dynamic> toJson() => _$CollaborationEventToJson(this);

  /// Create a new collaboration event
  factory CollaborationEvent.create({
    required String sessionId,
    required String userId,
    required CollaborationEventType type,
    EventPriority? priority,
    required Map<String, dynamic> data,
    required int version,
    String? conflictId,
  }) {
    final now = DateTime.now();
    return CollaborationEvent(
      id: 'event_${now.microsecondsSinceEpoch}',
      sessionId: sessionId,
      userId: userId,
      type: type,
      priority: priority ?? _getDefaultPriority(type),
      data: data,
      version: version,
      timestamp: now,
      conflictId: conflictId,
    );
  }

  /// Create text insertion event
  factory CollaborationEvent.textInsert({
    required String sessionId,
    required String userId,
    required int offset,
    required String text,
    required int version,
  }) {
    return CollaborationEvent.create(
      sessionId: sessionId,
      userId: userId,
      type: CollaborationEventType.textInsert,
      data: {
        'offset': offset,
        'text': text,
        'length': text.length,
      },
      version: version,
    );
  }

  /// Create text deletion event
  factory CollaborationEvent.textDelete({
    required String sessionId,
    required String userId,
    required int offset,
    required int length,
    required String deletedText,
    required int version,
  }) {
    return CollaborationEvent.create(
      sessionId: sessionId,
      userId: userId,
      type: CollaborationEventType.textDelete,
      data: {
        'offset': offset,
        'length': length,
        'deletedText': deletedText,
      },
      version: version,
    );
  }

  /// Create cursor move event
  factory CollaborationEvent.cursorMove({
    required String sessionId,
    required String userId,
    required CursorPosition cursor,
    required int version,
  }) {
    return CollaborationEvent.create(
      sessionId: sessionId,
      userId: userId,
      type: CollaborationEventType.cursorMove,
      priority: EventPriority.low,
      data: {
        'cursor': cursor.toJson(),
      },
      version: version,
    );
  }

  /// Create user presence event
  factory CollaborationEvent.userJoined({
    required String sessionId,
    required CollaborationUser user,
    required int version,
  }) {
    return CollaborationEvent.create(
      sessionId: sessionId,
      userId: user.userId,
      type: CollaborationEventType.userJoined,
      priority: EventPriority.normal,
      data: {
        'user': user.toJson(),
      },
      version: version,
    );
  }

  @override
  List<Object?> get props => [
        id,
        sessionId,
        userId,
        type,
        priority,
        data,
        version,
        timestamp,
        conflictId,
      ];
}

/// Operational transformation for resolving conflicts
@JsonSerializable()
class OperationalTransform extends Equatable {
  final String id;
  final CollaborationEvent originalEvent;
  final CollaborationEvent transformedEvent;
  final String transformationType;
  final Map<String, dynamic> transformData;
  final DateTime timestamp;

  const OperationalTransform({
    required this.id,
    required this.originalEvent,
    required this.transformedEvent,
    required this.transformationType,
    required this.transformData,
    required this.timestamp,
  });

  factory OperationalTransform.fromJson(Map<String, dynamic> json) =>
      _$OperationalTransformFromJson(json);

  Map<String, dynamic> toJson() => _$OperationalTransformToJson(this);

  /// Create operational transform
  factory OperationalTransform.create({
    required CollaborationEvent originalEvent,
    required CollaborationEvent transformedEvent,
    required String transformationType,
    Map<String, dynamic>? transformData,
  }) {
    return OperationalTransform(
      id: 'ot_${DateTime.now().microsecondsSinceEpoch}',
      originalEvent: originalEvent,
      transformedEvent: transformedEvent,
      transformationType: transformationType,
      transformData: transformData ?? {},
      timestamp: DateTime.now(),
    );
  }

  @override
  List<Object?> get props => [
        id,
        originalEvent,
        transformedEvent,
        transformationType,
        transformData,
        timestamp,
      ];
}

/// Conflict detection and resolution data
@JsonSerializable()
class CollaborationConflict extends Equatable {
  final String id;
  final String sessionId;
  final List<CollaborationEvent> conflictingEvents;
  final String conflictType;
  final Map<String, dynamic> conflictData;
  final bool isResolved;
  final OperationalTransform? resolution;
  final DateTime detectedAt;
  final DateTime? resolvedAt;

  const CollaborationConflict({
    required this.id,
    required this.sessionId,
    required this.conflictingEvents,
    required this.conflictType,
    required this.conflictData,
    required this.isResolved,
    this.resolution,
    required this.detectedAt,
    this.resolvedAt,
  });

  factory CollaborationConflict.fromJson(Map<String, dynamic> json) =>
      _$CollaborationConflictFromJson(json);

  Map<String, dynamic> toJson() => _$CollaborationConflictToJson(this);

  /// Create a new conflict
  factory CollaborationConflict.create({
    required String sessionId,
    required List<CollaborationEvent> conflictingEvents,
    required String conflictType,
    Map<String, dynamic>? conflictData,
  }) {
    return CollaborationConflict(
      id: 'conflict_${DateTime.now().microsecondsSinceEpoch}',
      sessionId: sessionId,
      conflictingEvents: conflictingEvents,
      conflictType: conflictType,
      conflictData: conflictData ?? {},
      isResolved: false,
      detectedAt: DateTime.now(),
    );
  }

  /// Resolve conflict with transformation
  CollaborationConflict resolve(OperationalTransform resolution) {
    return copyWith(
      isResolved: true,
      resolution: resolution,
      resolvedAt: DateTime.now(),
    );
  }

  /// Copy with updated fields
  CollaborationConflict copyWith({
    bool? isResolved,
    OperationalTransform? resolution,
    DateTime? resolvedAt,
  }) {
    return CollaborationConflict(
      id: id,
      sessionId: sessionId,
      conflictingEvents: conflictingEvents,
      conflictType: conflictType,
      conflictData: conflictData,
      isResolved: isResolved ?? this.isResolved,
      resolution: resolution ?? this.resolution,
      detectedAt: detectedAt,
      resolvedAt: resolvedAt ?? this.resolvedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        sessionId,
        conflictingEvents,
        conflictType,
        conflictData,
        isResolved,
        resolution,
        detectedAt,
        resolvedAt,
      ];
}

/// Real-time comment for collaborative feedback
@JsonSerializable()
class CollaborationComment extends Equatable {
  final String id;
  final String sessionId;
  final String documentId;
  final String userId;
  final String content;
  final TextSelection? anchor;
  final List<String> mentions;
  final bool isResolved;
  final List<CollaborationComment> replies;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final DateTime? resolvedAt;
  final Map<String, dynamic> metadata;

  const CollaborationComment({
    required this.id,
    required this.sessionId,
    required this.documentId,
    required this.userId,
    required this.content,
    this.anchor,
    required this.mentions,
    required this.isResolved,
    required this.replies,
    required this.createdAt,
    this.updatedAt,
    this.resolvedAt,
    this.metadata = const {},
  });

  factory CollaborationComment.fromJson(Map<String, dynamic> json) =>
      _$CollaborationCommentFromJson(json);

  Map<String, dynamic> toJson() => _$CollaborationCommentToJson(this);

  /// Create a new comment
  factory CollaborationComment.create({
    required String sessionId,
    required String documentId,
    required String userId,
    required String content,
    TextSelection? anchor,
    List<String>? mentions,
  }) {
    return CollaborationComment(
      id: 'comment_${DateTime.now().microsecondsSinceEpoch}',
      sessionId: sessionId,
      documentId: documentId,
      userId: userId,
      content: content,
      anchor: anchor,
      mentions: mentions ?? [],
      isResolved: false,
      replies: [],
      createdAt: DateTime.now(),
    );
  }

  /// Add reply to comment
  CollaborationComment addReply(CollaborationComment reply) {
    return copyWith(replies: [...replies, reply]);
  }

  /// Resolve comment
  CollaborationComment resolve() {
    return copyWith(
      isResolved: true,
      resolvedAt: DateTime.now(),
    );
  }

  /// Copy with updated fields
  CollaborationComment copyWith({
    String? content,
    bool? isResolved,
    List<CollaborationComment>? replies,
    DateTime? updatedAt,
    DateTime? resolvedAt,
  }) {
    return CollaborationComment(
      id: id,
      sessionId: sessionId,
      documentId: documentId,
      userId: userId,
      content: content ?? this.content,
      anchor: anchor,
      mentions: mentions,
      isResolved: isResolved ?? this.isResolved,
      replies: replies ?? this.replies,
      createdAt: createdAt,
      updatedAt: updatedAt,
      resolvedAt: resolvedAt,
      metadata: metadata,
    );
  }

  @override
  List<Object?> get props => [
        id,
        sessionId,
        documentId,
        userId,
        content,
        anchor,
        mentions,
        isResolved,
        replies,
        createdAt,
        updatedAt,
        resolvedAt,
        metadata,
      ];
}

/// Collaboration statistics and metrics
@JsonSerializable()
class CollaborationMetrics extends Equatable {
  final String sessionId;
  final int totalEvents;
  final int totalParticipants;
  final int activeParticipants;
  final int conflictsDetected;
  final int conflictsResolved;
  final double averageResponseTime;
  final Map<String, int> eventTypeCounts;
  final Map<String, int> userActivityCounts;
  final DateTime generatedAt;

  const CollaborationMetrics({
    required this.sessionId,
    required this.totalEvents,
    required this.totalParticipants,
    required this.activeParticipants,
    required this.conflictsDetected,
    required this.conflictsResolved,
    required this.averageResponseTime,
    required this.eventTypeCounts,
    required this.userActivityCounts,
    required this.generatedAt,
  });

  factory CollaborationMetrics.fromJson(Map<String, dynamic> json) =>
      _$CollaborationMetricsFromJson(json);

  Map<String, dynamic> toJson() => _$CollaborationMetricsToJson(this);

  /// Calculate conflict resolution rate
  double get conflictResolutionRate {
    return conflictsDetected > 0 ? conflictsResolved / conflictsDetected : 0.0;
  }

  /// Get most active user
  String? get mostActiveUser {
    if (userActivityCounts.isEmpty) return null;

    return userActivityCounts.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;
  }

  @override
  List<Object?> get props => [
        sessionId,
        totalEvents,
        totalParticipants,
        activeParticipants,
        conflictsDetected,
        conflictsResolved,
        averageResponseTime,
        eventTypeCounts,
        userActivityCounts,
        generatedAt,
      ];
}

// HELPER FUNCTIONS

/// Generate a consistent color for a user based on their ID
String _generateUserColor(String userId) {
  final colors = [
    '#FF6B6B',
    '#4ECDC4',
    '#45B7D1',
    '#96CEB4',
    '#FFEAA7',
    '#DDA0DD',
    '#98D8C8',
    '#F7DC6F',
    '#BB8FCE',
    '#85C1E9',
    '#F8C471',
    '#82E0AA',
    '#F1948A',
    '#85C1E9',
    '#D7BDE2',
  ];

  final hash = userId.hashCode.abs();
  return colors[hash % colors.length];
}

/// Get default priority for event type
EventPriority _getDefaultPriority(CollaborationEventType type) {
  switch (type) {
    case CollaborationEventType.userJoined:
    case CollaborationEventType.userLeft:
    case CollaborationEventType.userIdle:
    case CollaborationEventType.userActive:
    case CollaborationEventType.commentAdd:
    case CollaborationEventType.commentEdit:
    case CollaborationEventType.commentDelete:
      return EventPriority.low;

    case CollaborationEventType.textInsert:
    case CollaborationEventType.textDelete:
    case CollaborationEventType.textReplace:
    case CollaborationEventType.formatChange:
    case CollaborationEventType.cursorMove:
    case CollaborationEventType.selectionChange:
    case CollaborationEventType.translationStart:
    case CollaborationEventType.translationUpdate:
    case CollaborationEventType.translationComplete:
      return EventPriority.normal;

    case CollaborationEventType.translationReview:
    case CollaborationEventType.translationApprove:
    case CollaborationEventType.commentResolve:
    case CollaborationEventType.documentLock:
    case CollaborationEventType.documentUnlock:
      return EventPriority.high;

    case CollaborationEventType.conflictDetected:
    case CollaborationEventType.conflictResolved:
    case CollaborationEventType.heartbeat:
      return EventPriority.critical;
  }
}

/// Convert text offset to line and column position
({int line, int column}) _offsetToLineColumn(String text, int offset) {
  if (offset < 0 || offset > text.length) {
    return (line: 0, column: 0);
  }

  var line = 0;
  var column = 0;

  for (var i = 0; i < offset; i++) {
    if (text[i] == '\n') {
      line++;
      column = 0;
    } else {
      column++;
    }
  }

  return (line: line, column: column);
}
