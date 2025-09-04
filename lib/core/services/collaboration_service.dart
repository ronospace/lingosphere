// ⚡ LingoSphere - Real-Time Collaboration Service
// WebSocket-based real-time collaborative editing engine with conflict resolution

import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;

import '../models/collaboration_models.dart';
import '../models/team_workspace_models.dart';

/// Real-time collaboration service with WebSocket integration
class CollaborationService {
  WebSocketChannel? _channel;
  final Map<String, CollaborationSession> _sessions = {};
  final Map<String, CollaborationConflict> _conflicts = {};
  final Map<String, List<CollaborationEvent>> _eventHistory = {};
  final Map<String, Timer> _heartbeatTimers = {};

  // Event streams
  final StreamController<CollaborationEvent> _eventController =
      StreamController.broadcast();
  final StreamController<CollaborationConflict> _conflictController =
      StreamController.broadcast();
  final StreamController<CollaborationComment> _commentController =
      StreamController.broadcast();
  final StreamController<CollaborationUser> _presenceController =
      StreamController.broadcast();

  String? _currentUserId;
  String? _currentSessionId;
  bool _isConnected = false;
  int _reconnectAttempts = 0;
  static const int _maxReconnectAttempts = 5;

  /// Stream of collaboration events
  Stream<CollaborationEvent> get events => _eventController.stream;

  /// Stream of conflict notifications
  Stream<CollaborationConflict> get conflicts => _conflictController.stream;

  /// Stream of comment updates
  Stream<CollaborationComment> get comments => _commentController.stream;

  /// Stream of user presence updates
  Stream<CollaborationUser> get presence => _presenceController.stream;

  /// Check if service is connected
  bool get isConnected => _isConnected;

  /// Get current session
  CollaborationSession? get currentSession =>
      _currentSessionId != null ? _sessions[_currentSessionId] : null;

  // CONNECTION MANAGEMENT

  /// Connect to collaboration server
  Future<void> connect({
    required String serverUrl,
    required String userId,
    String? authToken,
  }) async {
    try {
      _currentUserId = userId;

      final uri = Uri.parse(serverUrl).replace(queryParameters: {
        'userId': userId,
        if (authToken != null) 'token': authToken,
      });

      _channel = WebSocketChannel.connect(uri);

      // Set up message handling
      _channel!.stream.listen(
        _handleMessage,
        onError: _handleError,
        onDone: _handleDisconnect,
      );

      _isConnected = true;
      _reconnectAttempts = 0;

      print('✅ Connected to collaboration server');
    } catch (e) {
      print('❌ Failed to connect: $e');
      await _attemptReconnect();
    }
  }

  /// Disconnect from collaboration server
  Future<void> disconnect() async {
    _isConnected = false;
    _currentSessionId = null;

    // Cancel heartbeat timers
    for (final timer in _heartbeatTimers.values) {
      timer.cancel();
    }
    _heartbeatTimers.clear();

    // Close WebSocket
    await _channel?.sink.close(status.goingAway);
    _channel = null;

    print('🔌 Disconnected from collaboration server');
  }

  // SESSION MANAGEMENT

  /// Join a collaboration session
  Future<CollaborationSession> joinSession({
    required String documentId,
    required String projectId,
    required String workspaceId,
    required String displayName,
    required UserRole role,
    String? avatarUrl,
  }) async {
    if (!_isConnected || _currentUserId == null) {
      throw CollaborationException('Not connected to server');
    }

    // Create or get existing session
    var session = _sessions[documentId];
    if (session == null) {
      session = CollaborationSession.create(
        documentId: documentId,
        projectId: projectId,
        workspaceId: workspaceId,
      );
      _sessions[documentId] = session;
    }

    // Create collaboration user
    final user = CollaborationUser.create(
      userId: _currentUserId!,
      displayName: displayName,
      avatarUrl: avatarUrl,
      role: role,
    );

    // Add user to session
    final updatedParticipants =
        List<CollaborationUser>.from(session.participants);
    updatedParticipants.removeWhere((u) => u.userId == _currentUserId);
    updatedParticipants.add(user);

    session = session.copyWith(
      participants: updatedParticipants,
      lastActivity: DateTime.now(),
    );
    _sessions[documentId] = session;
    _currentSessionId = session.id;

    // Send join event to other participants
    final joinEvent = CollaborationEvent.userJoined(
      sessionId: session.id,
      user: user,
      version: session.version,
    );

    _sendEvent(joinEvent);
    _startHeartbeat(session.id);

    return session;
  }

  /// Leave current collaboration session
  Future<void> leaveSession() async {
    if (_currentSessionId == null) return;

    final session = _sessions[_currentSessionId];
    if (session != null) {
      // Remove user from session
      final updatedParticipants = session.participants
          .where((user) => user.userId != _currentUserId)
          .toList();

      final updatedSession = session.copyWith(
        participants: updatedParticipants,
        lastActivity: DateTime.now(),
      );
      _sessions[_currentSessionId!] = updatedSession;

      // Send leave event
      final leaveEvent = CollaborationEvent.create(
        sessionId: session.id,
        userId: _currentUserId!,
        type: CollaborationEventType.userLeft,
        data: {},
        version: session.version,
      );

      _sendEvent(leaveEvent);
    }

    // Stop heartbeat
    _heartbeatTimers[_currentSessionId]?.cancel();
    _heartbeatTimers.remove(_currentSessionId);

    _currentSessionId = null;
  }

  // TEXT OPERATIONS

  /// Insert text at specified offset
  Future<void> insertText({
    required int offset,
    required String text,
  }) async {
    await _performTextOperation(
      type: CollaborationEventType.textInsert,
      data: {
        'offset': offset,
        'text': text,
        'length': text.length,
      },
    );
  }

  /// Delete text at specified range
  Future<void> deleteText({
    required int offset,
    required int length,
    required String deletedText,
  }) async {
    await _performTextOperation(
      type: CollaborationEventType.textDelete,
      data: {
        'offset': offset,
        'length': length,
        'deletedText': deletedText,
      },
    );
  }

  /// Replace text in specified range
  Future<void> replaceText({
    required int offset,
    required int length,
    required String oldText,
    required String newText,
  }) async {
    await _performTextOperation(
      type: CollaborationEventType.textReplace,
      data: {
        'offset': offset,
        'length': length,
        'oldText': oldText,
        'newText': newText,
      },
    );
  }

  // CURSOR AND SELECTION

  /// Update cursor position
  Future<void> updateCursor({
    required int line,
    required int column,
    required int offset,
  }) async {
    if (_currentSessionId == null || _currentUserId == null) return;

    final cursor = CursorPosition.at(
      line: line,
      column: column,
      offset: offset,
    );

    final session = _sessions[_currentSessionId!];
    if (session != null) {
      final cursorEvent = CollaborationEvent.cursorMove(
        sessionId: session.id,
        userId: _currentUserId!,
        cursor: cursor,
        version: session.version,
      );

      _sendEvent(cursorEvent);

      // Update user's cursor in session
      _updateUserInSession(
        session.id,
        _currentUserId!,
        (user) => user.updateActivity(cursor: cursor),
      );
    }
  }

  /// Update text selection
  Future<void> updateSelection({
    required int startOffset,
    required int endOffset,
    required String selectedText,
    required String fullText,
  }) async {
    if (_currentSessionId == null || _currentUserId == null) return;

    final selection = TextSelection.fromOffsets(
      startOffset: startOffset,
      endOffset: endOffset,
      selectedText: selectedText,
      fullText: fullText,
    );

    final session = _sessions[_currentSessionId!];
    if (session != null) {
      final selectionEvent = CollaborationEvent.create(
        sessionId: session.id,
        userId: _currentUserId!,
        type: CollaborationEventType.selectionChange,
        data: {
          'selection': selection.toJson(),
        },
        version: session.version,
      );

      _sendEvent(selectionEvent);

      // Update user's selection in session
      _updateUserInSession(
        session.id,
        _currentUserId!,
        (user) => user.updateActivity(selection: selection),
      );
    }
  }

  // TRANSLATION OPERATIONS

  /// Start translation process
  Future<void> startTranslation({
    required String sourceText,
    required String sourceLanguage,
    required String targetLanguage,
  }) async {
    await _performTranslationOperation(
      type: CollaborationEventType.translationStart,
      data: {
        'sourceText': sourceText,
        'sourceLanguage': sourceLanguage,
        'targetLanguage': targetLanguage,
      },
    );
  }

  /// Update translation in progress
  Future<void> updateTranslation({
    required String translationId,
    required String partialTranslation,
    required double progress,
  }) async {
    await _performTranslationOperation(
      type: CollaborationEventType.translationUpdate,
      data: {
        'translationId': translationId,
        'partialTranslation': partialTranslation,
        'progress': progress,
      },
    );
  }

  /// Complete translation
  Future<void> completeTranslation({
    required String translationId,
    required String finalTranslation,
    required double confidence,
  }) async {
    await _performTranslationOperation(
      type: CollaborationEventType.translationComplete,
      data: {
        'translationId': translationId,
        'finalTranslation': finalTranslation,
        'confidence': confidence,
      },
    );
  }

  // COMMENTS AND FEEDBACK

  /// Add comment to document
  Future<CollaborationComment> addComment({
    required String content,
    TextSelection? anchor,
    List<String>? mentions,
  }) async {
    if (_currentSessionId == null || _currentUserId == null) {
      throw CollaborationException('No active session');
    }

    final session = _sessions[_currentSessionId!];
    if (session == null) {
      throw CollaborationException('Session not found');
    }

    final comment = CollaborationComment.create(
      sessionId: session.id,
      documentId: session.documentId,
      userId: _currentUserId!,
      content: content,
      anchor: anchor,
      mentions: mentions,
    );

    final commentEvent = CollaborationEvent.create(
      sessionId: session.id,
      userId: _currentUserId!,
      type: CollaborationEventType.commentAdd,
      data: {
        'comment': comment.toJson(),
      },
      version: session.version,
    );

    _sendEvent(commentEvent);
    _commentController.add(comment);

    return comment;
  }

  /// Resolve comment
  Future<void> resolveComment(String commentId) async {
    if (_currentSessionId == null || _currentUserId == null) return;

    final session = _sessions[_currentSessionId!];
    if (session != null) {
      final resolveEvent = CollaborationEvent.create(
        sessionId: session.id,
        userId: _currentUserId!,
        type: CollaborationEventType.commentResolve,
        data: {
          'commentId': commentId,
        },
        version: session.version,
      );

      _sendEvent(resolveEvent);
    }
  }

  // CONFLICT RESOLUTION

  /// Detect potential conflicts between operations
  CollaborationConflict? detectConflict(
    CollaborationEvent event1,
    CollaborationEvent event2,
  ) {
    // Check if events are from different users
    if (event1.userId == event2.userId) return null;

    // Check if events are text operations that might conflict
    final textOps = [
      CollaborationEventType.textInsert,
      CollaborationEventType.textDelete,
      CollaborationEventType.textReplace,
    ];

    if (!textOps.contains(event1.type) || !textOps.contains(event2.type)) {
      return null;
    }

    // Get operation ranges
    final range1 = _getOperationRange(event1);
    final range2 = _getOperationRange(event2);

    // Check for overlap
    if (_rangesOverlap(range1, range2)) {
      return CollaborationConflict.create(
        sessionId: event1.sessionId,
        conflictingEvents: [event1, event2],
        conflictType: 'text_operation_conflict',
        conflictData: {
          'range1': range1,
          'range2': range2,
        },
      );
    }

    return null;
  }

  /// Resolve conflict using operational transformation
  Future<OperationalTransform> resolveConflict(
    CollaborationConflict conflict,
  ) async {
    if (conflict.conflictingEvents.length != 2) {
      throw CollaborationException(
          'Can only resolve conflicts between 2 events');
    }

    final event1 = conflict.conflictingEvents[0];
    final event2 = conflict.conflictingEvents[1];

    // Apply operational transformation
    final transformedEvent = _applyOperationalTransform(event1, event2);

    final transform = OperationalTransform.create(
      originalEvent: event2,
      transformedEvent: transformedEvent,
      transformationType: _getTransformationType(event1.type, event2.type),
    );

    // Mark conflict as resolved
    final resolvedConflict = conflict.resolve(transform);
    _conflicts[conflict.id] = resolvedConflict;

    // Send conflict resolution event
    final resolutionEvent = CollaborationEvent.create(
      sessionId: conflict.sessionId,
      userId: 'system',
      type: CollaborationEventType.conflictResolved,
      data: {
        'conflictId': conflict.id,
        'transform': transform.toJson(),
      },
      version: _sessions[conflict.sessionId]?.version ?? 1,
    );

    _sendEvent(resolutionEvent);

    return transform;
  }

  // ANALYTICS AND METRICS

  /// Get collaboration metrics for session
  CollaborationMetrics getSessionMetrics(String sessionId) {
    final session = _sessions[sessionId];
    final eventHistory = _eventHistory[sessionId] ?? [];
    final conflicts = _conflicts.values
        .where((conflict) => conflict.sessionId == sessionId)
        .toList();

    if (session == null) {
      throw CollaborationException('Session not found');
    }

    // Calculate event type counts
    final eventTypeCounts = <String, int>{};
    for (final event in eventHistory) {
      final typeName = event.type.name;
      eventTypeCounts[typeName] = (eventTypeCounts[typeName] ?? 0) + 1;
    }

    // Calculate user activity counts
    final userActivityCounts = <String, int>{};
    for (final event in eventHistory) {
      userActivityCounts[event.userId] =
          (userActivityCounts[event.userId] ?? 0) + 1;
    }

    // Calculate average response time
    final responseTimes = <Duration>[];
    for (var i = 1; i < eventHistory.length; i++) {
      responseTimes.add(
        eventHistory[i].timestamp.difference(eventHistory[i - 1].timestamp),
      );
    }

    final averageResponseTime = responseTimes.isNotEmpty
        ? responseTimes
                .fold<Duration>(Duration.zero, (a, b) => a + b)
                .inMilliseconds /
            responseTimes.length.toDouble()
        : 0.0;

    return CollaborationMetrics(
      sessionId: sessionId,
      totalEvents: eventHistory.length,
      totalParticipants: session.participants.length,
      activeParticipants: session.activeParticipantsCount,
      conflictsDetected: conflicts.length,
      conflictsResolved: conflicts.where((c) => c.isResolved).length,
      averageResponseTime: averageResponseTime,
      eventTypeCounts: eventTypeCounts,
      userActivityCounts: userActivityCounts,
      generatedAt: DateTime.now(),
    );
  }

  // PRIVATE METHODS

  /// Handle incoming WebSocket message
  void _handleMessage(dynamic message) {
    try {
      final data = jsonDecode(message.toString()) as Map<String, dynamic>;
      final event = CollaborationEvent.fromJson(data);

      // Add to event history
      final sessionEvents = _eventHistory[event.sessionId] ?? [];
      sessionEvents.add(event);
      _eventHistory[event.sessionId] = sessionEvents;

      // Check for conflicts
      _checkForConflicts(event, sessionEvents);

      // Update session state
      _updateSessionFromEvent(event);

      // Emit event
      _eventController.add(event);
    } catch (e) {
      print('❌ Error handling message: $e');
    }
  }

  /// Handle WebSocket error
  void _handleError(error) {
    print('❌ WebSocket error: $error');
    _isConnected = false;
    _attemptReconnect();
  }

  /// Handle WebSocket disconnect
  void _handleDisconnect() {
    print('🔌 WebSocket disconnected');
    _isConnected = false;
    _attemptReconnect();
  }

  /// Attempt to reconnect to server
  Future<void> _attemptReconnect() async {
    if (_reconnectAttempts >= _maxReconnectAttempts) {
      print('❌ Max reconnection attempts reached');
      return;
    }

    _reconnectAttempts++;
    final delay = Duration(seconds: pow(2, _reconnectAttempts).toInt());

    print('🔄 Attempting reconnection in ${delay.inSeconds} seconds...');

    await Future.delayed(delay);

    // Try to reconnect (would need stored connection parameters)
    // This is simplified - in practice you'd store connection details
  }

  /// Send event to server
  void _sendEvent(CollaborationEvent event) {
    if (!_isConnected || _channel == null) return;

    try {
      final message = jsonEncode(event.toJson());
      _channel!.sink.add(message);
    } catch (e) {
      print('❌ Error sending event: $e');
    }
  }

  /// Perform text operation
  Future<void> _performTextOperation({
    required CollaborationEventType type,
    required Map<String, dynamic> data,
  }) async {
    if (_currentSessionId == null || _currentUserId == null) return;

    final session = _sessions[_currentSessionId!];
    if (session != null) {
      final event = CollaborationEvent.create(
        sessionId: session.id,
        userId: _currentUserId!,
        type: type,
        data: data,
        version: session.version + 1,
      );

      // Increment session version
      final updatedSession = session.copyWith(
        version: session.version + 1,
        lastActivity: DateTime.now(),
      );
      _sessions[_currentSessionId!] = updatedSession;

      _sendEvent(event);
    }
  }

  /// Perform translation operation
  Future<void> _performTranslationOperation({
    required CollaborationEventType type,
    required Map<String, dynamic> data,
  }) async {
    if (_currentSessionId == null || _currentUserId == null) return;

    final session = _sessions[_currentSessionId!];
    if (session != null) {
      final event = CollaborationEvent.create(
        sessionId: session.id,
        userId: _currentUserId!,
        type: type,
        data: data,
        version: session.version,
      );

      _sendEvent(event);
    }
  }

  /// Start heartbeat for session
  void _startHeartbeat(String sessionId) {
    _heartbeatTimers[sessionId]?.cancel();

    _heartbeatTimers[sessionId] = Timer.periodic(
      const Duration(seconds: 30),
      (timer) {
        if (_isConnected && _currentUserId != null) {
          final heartbeatEvent = CollaborationEvent.create(
            sessionId: sessionId,
            userId: _currentUserId!,
            type: CollaborationEventType.heartbeat,
            priority: EventPriority.critical,
            data: {'timestamp': DateTime.now().toIso8601String()},
            version: _sessions[sessionId]?.version ?? 1,
          );

          _sendEvent(heartbeatEvent);
        }
      },
    );
  }

  /// Update user in session
  void _updateUserInSession(
    String sessionId,
    String userId,
    CollaborationUser Function(CollaborationUser) updater,
  ) {
    final session = _sessions[sessionId];
    if (session == null) return;

    final updatedParticipants = session.participants.map((user) {
      if (user.userId == userId) {
        return updater(user);
      }
      return user;
    }).toList();

    final updatedSession = session.copyWith(
      participants: updatedParticipants,
      lastActivity: DateTime.now(),
    );

    _sessions[sessionId] = updatedSession;
  }

  /// Check for conflicts in event history
  void _checkForConflicts(
    CollaborationEvent newEvent,
    List<CollaborationEvent> eventHistory,
  ) {
    // Check against recent events for potential conflicts
    final recentEvents = eventHistory
        .where((event) =>
            event.timestamp.difference(newEvent.timestamp).abs().inSeconds < 5)
        .toList();

    for (final event in recentEvents) {
      final conflict = detectConflict(event, newEvent);
      if (conflict != null) {
        _conflicts[conflict.id] = conflict;
        _conflictController.add(conflict);

        // Attempt automatic resolution
        resolveConflict(conflict);
      }
    }
  }

  /// Update session from event
  void _updateSessionFromEvent(CollaborationEvent event) {
    final session = _sessions[event.sessionId];
    if (session == null) return;

    switch (event.type) {
      case CollaborationEventType.userJoined:
        final userData = event.data['user'] as Map<String, dynamic>;
        final user = CollaborationUser.fromJson(userData);
        final updatedParticipants =
            List<CollaborationUser>.from(session.participants);
        updatedParticipants.removeWhere((u) => u.userId == user.userId);
        updatedParticipants.add(user);

        _sessions[event.sessionId] = session.copyWith(
          participants: updatedParticipants,
          lastActivity: DateTime.now(),
        );
        _presenceController.add(user);
        break;

      case CollaborationEventType.userLeft:
        final updatedParticipants = session.participants
            .where((user) => user.userId != event.userId)
            .toList();

        _sessions[event.sessionId] = session.copyWith(
          participants: updatedParticipants,
          lastActivity: DateTime.now(),
        );
        break;

      case CollaborationEventType.cursorMove:
        final cursorData = event.data['cursor'] as Map<String, dynamic>;
        final cursor = CursorPosition.fromJson(cursorData);

        _updateUserInSession(
          event.sessionId,
          event.userId,
          (user) => user.updateActivity(cursor: cursor),
        );
        break;

      default:
        // Update last activity for any event
        _sessions[event.sessionId] = session.copyWith(
          lastActivity: DateTime.now(),
        );
        break;
    }
  }

  /// Get operation range from event
  ({int start, int end}) _getOperationRange(CollaborationEvent event) {
    final offset = event.data['offset'] as int? ?? 0;

    switch (event.type) {
      case CollaborationEventType.textInsert:
        final length = event.data['length'] as int? ?? 0;
        return (start: offset, end: offset + length);

      case CollaborationEventType.textDelete:
        final length = event.data['length'] as int? ?? 0;
        return (start: offset, end: offset + length);

      case CollaborationEventType.textReplace:
        final length = event.data['length'] as int? ?? 0;
        return (start: offset, end: offset + length);

      default:
        return (start: offset, end: offset);
    }
  }

  /// Check if two ranges overlap
  bool _rangesOverlap(
    ({int start, int end}) range1,
    ({int start, int end}) range2,
  ) {
    return range1.start < range2.end && range2.start < range1.end;
  }

  /// Apply operational transformation
  CollaborationEvent _applyOperationalTransform(
    CollaborationEvent event1,
    CollaborationEvent event2,
  ) {
    // Simplified operational transformation
    // In practice, this would be much more complex

    final offset1 = event1.data['offset'] as int? ?? 0;
    final offset2 = event2.data['offset'] as int? ?? 0;

    if (offset1 <= offset2) {
      // Event1 comes before Event2, adjust Event2's offset
      final adjustment = _getOffsetAdjustment(event1);
      final adjustedData = Map<String, dynamic>.from(event2.data);
      adjustedData['offset'] = offset2 + adjustment;

      return CollaborationEvent.create(
        sessionId: event2.sessionId,
        userId: event2.userId,
        type: event2.type,
        priority: event2.priority,
        data: adjustedData,
        version: event2.version,
      );
    } else {
      // Event2 comes before Event1, no adjustment needed
      return event2;
    }
  }

  /// Get offset adjustment for operational transform
  int _getOffsetAdjustment(CollaborationEvent event) {
    switch (event.type) {
      case CollaborationEventType.textInsert:
        return event.data['length'] as int? ?? 0;
      case CollaborationEventType.textDelete:
        return -(event.data['length'] as int? ?? 0);
      case CollaborationEventType.textReplace:
        final oldLength = event.data['length'] as int? ?? 0;
        final newText = event.data['newText'] as String? ?? '';
        return newText.length - oldLength;
      default:
        return 0;
    }
  }

  /// Get transformation type name
  String _getTransformationType(
    CollaborationEventType type1,
    CollaborationEventType type2,
  ) {
    return '${type1.name}_${type2.name}_transform';
  }

  /// Clean up resources
  void dispose() {
    disconnect();
    _eventController.close();
    _conflictController.close();
    _commentController.close();
    _presenceController.close();
  }
}

/// Exception thrown by collaboration service
class CollaborationException implements Exception {
  final String message;
  const CollaborationException(this.message);

  @override
  String toString() => 'CollaborationException: $message';
}
