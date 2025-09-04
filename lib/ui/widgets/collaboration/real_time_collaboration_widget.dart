// ⚡ LingoSphere - Real-Time Collaboration Widget
// UI component for WebSocket-based collaborative editing with live cursors

import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math' as math;

import '../../../core/models/collaboration_models.dart';
import '../../../core/models/team_workspace_models.dart';
import '../../../core/services/collaboration_service.dart';

class RealTimeCollaborationWidget extends StatefulWidget {
  final CollaborationService collaborationService;
  final String documentId;
  final String projectId;
  final String workspaceId;
  final String currentUserId;
  final String displayName;
  final UserRole userRole;
  final TextEditingController textController;
  final Function(String)? onTextChanged;

  const RealTimeCollaborationWidget({
    super.key,
    required this.collaborationService,
    required this.documentId,
    required this.projectId,
    required this.workspaceId,
    required this.currentUserId,
    required this.displayName,
    required this.userRole,
    required this.textController,
    this.onTextChanged,
  });

  @override
  State<RealTimeCollaborationWidget> createState() =>
      _RealTimeCollaborationWidgetState();
}

class _RealTimeCollaborationWidgetState
    extends State<RealTimeCollaborationWidget> with TickerProviderStateMixin {
  CollaborationSession? _session;
  final List<CollaborationUser> _activeUsers = [];
  final List<CollaborationComment> _comments = [];
  final List<CollaborationConflict> _conflicts = [];
  CollaborationMetrics? _metrics;

  // UI State
  bool _isConnected = false;
  bool _isJoining = false;
  bool _showComments = false;
  bool _showPresence = true;

  // Subscriptions
  StreamSubscription<CollaborationEvent>? _eventSubscription;
  StreamSubscription<CollaborationConflict>? _conflictSubscription;
  StreamSubscription<CollaborationComment>? _commentSubscription;
  StreamSubscription<CollaborationUser>? _presenceSubscription;

  // Animation controllers
  late AnimationController _pulseController;
  late AnimationController _fadeController;

  // Text editing
  int _lastCursorPosition = 0;
  Timer? _cursorUpdateTimer;

  @override
  void initState() {
    super.initState();

    // Initialize animation controllers
    _pulseController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..repeat();

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    // Listen to text changes
    widget.textController.addListener(_handleTextChange);

    // Initialize collaboration
    _initializeCollaboration();
  }

  @override
  void dispose() {
    _eventSubscription?.cancel();
    _conflictSubscription?.cancel();
    _commentSubscription?.cancel();
    _presenceSubscription?.cancel();
    _cursorUpdateTimer?.cancel();
    _pulseController.dispose();
    _fadeController.dispose();
    widget.textController.removeListener(_handleTextChange);
    _leaveSession();
    super.dispose();
  }

  Future<void> _initializeCollaboration() async {
    setState(() => _isJoining = true);

    try {
      // Connect to collaboration service if not connected
      if (!widget.collaborationService.isConnected) {
        await widget.collaborationService.connect(
          serverUrl: 'wss://collaboration.lingosphere.com/ws',
          userId: widget.currentUserId,
        );
      }

      // Join collaboration session
      final session = await widget.collaborationService.joinSession(
        documentId: widget.documentId,
        projectId: widget.projectId,
        workspaceId: widget.workspaceId,
        displayName: widget.displayName,
        role: widget.userRole,
      );

      setState(() {
        _session = session;
        _isConnected = true;
        _activeUsers.clear();
        _activeUsers.addAll(session.participants);
      });

      // Set up event listeners
      _setupEventListeners();

      // Start animations
      _fadeController.forward();
    } catch (e) {
      print('❌ Failed to initialize collaboration: $e');
      _showErrorSnackBar('Failed to join collaboration session');
    } finally {
      setState(() => _isJoining = false);
    }
  }

  void _setupEventListeners() {
    // Listen to collaboration events
    _eventSubscription = widget.collaborationService.events.listen(
      _handleCollaborationEvent,
      onError: (error) => print('❌ Event stream error: $error'),
    );

    // Listen to conflicts
    _conflictSubscription = widget.collaborationService.conflicts.listen(
      _handleConflict,
      onError: (error) => print('❌ Conflict stream error: $error'),
    );

    // Listen to comments
    _commentSubscription = widget.collaborationService.comments.listen(
      _handleComment,
      onError: (error) => print('❌ Comment stream error: $error'),
    );

    // Listen to presence updates
    _presenceSubscription = widget.collaborationService.presence.listen(
      _handlePresence,
      onError: (error) => print('❌ Presence stream error: $error'),
    );
  }

  void _handleCollaborationEvent(CollaborationEvent event) {
    if (!mounted) return;

    switch (event.type) {
      case CollaborationEventType.textInsert:
        _handleTextInsertEvent(event);
        break;
      case CollaborationEventType.textDelete:
        _handleTextDeleteEvent(event);
        break;
      case CollaborationEventType.textReplace:
        _handleTextReplaceEvent(event);
        break;
      case CollaborationEventType.cursorMove:
        _handleCursorMoveEvent(event);
        break;
      case CollaborationEventType.userJoined:
        _handleUserJoinedEvent(event);
        break;
      case CollaborationEventType.userLeft:
        _handleUserLeftEvent(event);
        break;
      default:
        break;
    }

    // Update metrics periodically
    _updateMetrics();
  }

  void _handleTextInsertEvent(CollaborationEvent event) {
    if (event.userId == widget.currentUserId) return;

    final offset = event.data['offset'] as int;
    final text = event.data['text'] as String;

    // Insert text at specified offset
    final currentText = widget.textController.text;
    if (offset <= currentText.length) {
      final newText = currentText.substring(0, offset) +
          text +
          currentText.substring(offset);

      // Update text without triggering our own listener
      widget.textController.removeListener(_handleTextChange);
      widget.textController.text = newText;
      widget.textController.addListener(_handleTextChange);

      widget.onTextChanged?.call(newText);

      _showCollaborationToast(
          '${_getUserDisplayName(event.userId)} added text');
    }
  }

  void _handleTextDeleteEvent(CollaborationEvent event) {
    if (event.userId == widget.currentUserId) return;

    final offset = event.data['offset'] as int;
    final length = event.data['length'] as int;

    // Delete text at specified range
    final currentText = widget.textController.text;
    if (offset < currentText.length && offset + length <= currentText.length) {
      final newText = currentText.substring(0, offset) +
          currentText.substring(offset + length);

      // Update text without triggering our own listener
      widget.textController.removeListener(_handleTextChange);
      widget.textController.text = newText;
      widget.textController.addListener(_handleTextChange);

      widget.onTextChanged?.call(newText);

      _showCollaborationToast(
          '${_getUserDisplayName(event.userId)} deleted text');
    }
  }

  void _handleTextReplaceEvent(CollaborationEvent event) {
    if (event.userId == widget.currentUserId) return;

    final offset = event.data['offset'] as int;
    final length = event.data['length'] as int;
    final newText = event.data['newText'] as String;

    // Replace text at specified range
    final currentText = widget.textController.text;
    if (offset < currentText.length && offset + length <= currentText.length) {
      final updatedText = currentText.substring(0, offset) +
          newText +
          currentText.substring(offset + length);

      // Update text without triggering our own listener
      widget.textController.removeListener(_handleTextChange);
      widget.textController.text = updatedText;
      widget.textController.addListener(_handleTextChange);

      widget.onTextChanged?.call(updatedText);

      _showCollaborationToast(
          '${_getUserDisplayName(event.userId)} replaced text');
    }
  }

  void _handleCursorMoveEvent(CollaborationEvent event) {
    if (event.userId == widget.currentUserId) return;

    // Update user cursor position in the UI
    final cursorData = event.data['cursor'] as Map<String, dynamic>;
    final cursor = CursorPosition.fromJson(cursorData);

    setState(() {
      final userIndex =
          _activeUsers.indexWhere((user) => user.userId == event.userId);
      if (userIndex != -1) {
        _activeUsers[userIndex] =
            _activeUsers[userIndex].updateActivity(cursor: cursor);
      }
    });
  }

  void _handleUserJoinedEvent(CollaborationEvent event) {
    final userData = event.data['user'] as Map<String, dynamic>;
    final user = CollaborationUser.fromJson(userData);

    setState(() {
      _activeUsers.removeWhere((u) => u.userId == user.userId);
      _activeUsers.add(user);
    });

    if (user.userId != widget.currentUserId) {
      _showCollaborationToast('${user.displayName} joined the session');
    }
  }

  void _handleUserLeftEvent(CollaborationEvent event) {
    setState(() {
      _activeUsers.removeWhere((user) => user.userId == event.userId);
    });

    _showCollaborationToast('User left the session');
  }

  void _handleConflict(CollaborationConflict conflict) {
    setState(() {
      _conflicts.add(conflict);
    });

    _showErrorSnackBar('Conflict detected - auto-resolving...');

    // Auto-hide conflict notification after resolution
    Timer(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _conflicts.removeWhere((c) => c.id == conflict.id);
        });
      }
    });
  }

  void _handleComment(CollaborationComment comment) {
    setState(() {
      _comments.add(comment);
    });

    if (comment.userId != widget.currentUserId) {
      _showCollaborationToast(
          'New comment from ${_getUserDisplayName(comment.userId)}');
    }
  }

  void _handlePresence(CollaborationUser user) {
    setState(() {
      final userIndex = _activeUsers.indexWhere((u) => u.userId == user.userId);
      if (userIndex != -1) {
        _activeUsers[userIndex] = user;
      } else {
        _activeUsers.add(user);
      }
    });
  }

  void _handleTextChange() {
    final text = widget.textController.text;
    final cursorPosition = widget.textController.selection.baseOffset;

    // Debounce cursor updates
    _cursorUpdateTimer?.cancel();
    _cursorUpdateTimer = Timer(const Duration(milliseconds: 100), () {
      if (cursorPosition != _lastCursorPosition) {
        _updateCursor(cursorPosition);
        _lastCursorPosition = cursorPosition;
      }
    });
  }

  void _updateCursor(int offset) {
    if (!_isConnected) return;

    // Calculate line and column from offset
    final text = widget.textController.text;
    var line = 0;
    var column = 0;

    for (var i = 0; i < offset && i < text.length; i++) {
      if (text[i] == '\n') {
        line++;
        column = 0;
      } else {
        column++;
      }
    }

    widget.collaborationService.updateCursor(
      line: line,
      column: column,
      offset: offset,
    );
  }

  void _updateMetrics() {
    if (_session == null) return;

    try {
      final metrics =
          widget.collaborationService.getSessionMetrics(_session!.id);
      setState(() => _metrics = metrics);
    } catch (e) {
      // Ignore metrics errors
    }
  }

  Future<void> _leaveSession() async {
    try {
      await widget.collaborationService.leaveSession();
      setState(() {
        _isConnected = false;
        _session = null;
        _activeUsers.clear();
        _comments.clear();
        _conflicts.clear();
      });
    } catch (e) {
      print('❌ Error leaving session: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildCollaborationHeader(),
        if (_isJoining) _buildJoiningIndicator(),
        if (_showComments && _comments.isNotEmpty) _buildCommentsPanel(),
        if (_conflicts.isNotEmpty) _buildConflictBanner(),
        Expanded(child: _buildTextEditor()),
        _buildCollaborationFooter(),
      ],
    );
  }

  Widget _buildCollaborationHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: _isConnected ? Colors.green.shade50 : Colors.orange.shade50,
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
          ),
        ),
      ),
      child: Row(
        children: [
          // Connection status
          AnimatedBuilder(
            animation: _pulseController,
            builder: (context, child) {
              return Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _isConnected
                      ? Colors.green
                          .withValues(alpha: 0.5 + 0.5 * _pulseController.value)
                      : Colors.orange,
                ),
              );
            },
          ),
          const SizedBox(width: 8),

          Text(
            _isConnected ? '⚡ Live Collaboration Active' : '🔄 Connecting...',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: _isConnected
                      ? Colors.green.shade700
                      : Colors.orange.shade700,
                ),
          ),

          const Spacer(),

          // Active users indicator
          if (_showPresence && _activeUsers.isNotEmpty)
            _buildActiveUsersIndicator(),

          // Toggle buttons
          IconButton(
            icon: Icon(_showComments ? Icons.comment : Icons.comment_outlined),
            onPressed: () => setState(() => _showComments = !_showComments),
            tooltip: 'Toggle Comments',
            iconSize: 20,
          ),

          IconButton(
            icon: Icon(_showPresence ? Icons.people : Icons.people_outline),
            onPressed: () => setState(() => _showPresence = !_showPresence),
            tooltip: 'Toggle User Presence',
            iconSize: 20,
          ),
        ],
      ),
    );
  }

  Widget _buildActiveUsersIndicator() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ...(_activeUsers.take(4).map((user) => _buildUserAvatar(user))),
        if (_activeUsers.length > 4) ...[
          const SizedBox(width: 4),
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Theme.of(context).colorScheme.secondary,
            ),
            child: Center(
              child: Text(
                '+${_activeUsers.length - 4}',
                style: TextStyle(
                  fontSize: 10,
                  color: Theme.of(context).colorScheme.onSecondary,
                ),
              ),
            ),
          ),
        ],
        const SizedBox(width: 8),
        Text(
          '${_activeUsers.length} active',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }

  Widget _buildUserAvatar(CollaborationUser user) {
    final isCurrentUser = user.userId == widget.currentUserId;
    final color = _parseColor(user.color);

    return Container(
      margin: const EdgeInsets.only(right: 4),
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withValues(alpha: 0.2),
        border: Border.all(
          color: color,
          width: isCurrentUser ? 2 : 1,
        ),
      ),
      child: Center(
        child: Text(
          user.displayName.isNotEmpty ? user.displayName[0].toUpperCase() : 'U',
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ),
    );
  }

  Widget _buildJoiningIndicator() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          SizedBox(width: 12),
          Text('Joining collaboration session...'),
        ],
      ),
    );
  }

  Widget _buildCommentsPanel() {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant,
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
          ),
        ),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                const Icon(Icons.comment, size: 16),
                const SizedBox(width: 8),
                Text(
                  'Comments (${_comments.length})',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: _addComment,
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text('Add'),
                  style: TextButton.styleFrom(
                    textStyle: const TextStyle(fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              itemCount: _comments.length,
              itemBuilder: (context, index) {
                final comment = _comments[index];
                return _buildCommentItem(comment);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentItem(CollaborationComment comment) {
    final user = _activeUsers.firstWhere(
      (u) => u.userId == comment.userId,
      orElse: () => CollaborationUser.create(
        userId: comment.userId,
        displayName: comment.userId,
        role: UserRole.viewer,
      ),
    );

    return Card(
      margin: const EdgeInsets.only(bottom: 4),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _buildUserAvatar(user),
                const SizedBox(width: 8),
                Text(
                  user.displayName,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                ),
                const Spacer(),
                Text(
                  _formatTime(comment.createdAt),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.outline,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              comment.content,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConflictBanner() {
    return Container(
      padding: const EdgeInsets.all(12),
      color: Colors.red.shade50,
      child: Row(
        children: [
          Icon(Icons.warning, color: Colors.red.shade700, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '⚠️ ${_conflicts.length} conflict(s) detected - auto-resolving...',
              style: TextStyle(
                color: Colors.red.shade700,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          TextButton(
            onPressed: () => setState(() => _conflicts.clear()),
            child:
                Text('Dismiss', style: TextStyle(color: Colors.red.shade700)),
          ),
        ],
      ),
    );
  }

  Widget _buildTextEditor() {
    return Stack(
      children: [
        // Main text editor
        TextField(
          controller: widget.textController,
          maxLines: null,
          expands: true,
          decoration: const InputDecoration(
            border: InputBorder.none,
            contentPadding: EdgeInsets.all(16),
            hintText: 'Start typing to collaborate in real-time...',
          ),
          style: Theme.of(context).textTheme.bodyLarge,
        ),

        // Live cursors overlay
        if (_showPresence) _buildLiveCursorsOverlay(),
      ],
    );
  }

  Widget _buildLiveCursorsOverlay() {
    return Positioned.fill(
      child: IgnorePointer(
        child: CustomPaint(
          painter: LiveCursorsPainter(
            activeUsers: _activeUsers
                .where((user) =>
                    user.userId != widget.currentUserId && user.cursor != null)
                .toList(),
            textStyle: Theme.of(context).textTheme.bodyLarge!,
          ),
        ),
      ),
    );
  }

  Widget _buildCollaborationFooter() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant,
        border: Border(
          top: BorderSide(
            color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
          ),
        ),
      ),
      child: Row(
        children: [
          if (_metrics != null) ...[
            Text(
              '📊 ${_metrics!.totalEvents} events',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(width: 16),
            Text(
              '⚡ ${_metrics!.averageResponseTime.toInt()}ms avg',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            if (_metrics!.conflictsDetected > 0) ...[
              const SizedBox(width: 16),
              Text(
                '⚠️ ${_metrics!.conflictsResolved}/${_metrics!.conflictsDetected} resolved',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ],
          const Spacer(),
          Text(
            'Real-time collaboration powered by WebSocket',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.outline,
                ),
          ),
        ],
      ),
    );
  }

  // HELPER METHODS

  String _getUserDisplayName(String userId) {
    final user = _activeUsers.firstWhere(
      (u) => u.userId == userId,
      orElse: () => CollaborationUser.create(
        userId: userId,
        displayName: userId,
        role: UserRole.viewer,
      ),
    );
    return user.displayName;
  }

  Color _parseColor(String colorString) {
    try {
      return Color(int.parse(colorString.replaceFirst('#', '0xFF')));
    } catch (e) {
      return Theme.of(context).colorScheme.primary;
    }
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${dateTime.day}/${dateTime.month}';
    }
  }

  Future<void> _addComment() async {
    final controller = TextEditingController();

    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Comment'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'Enter your comment...',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text('Add Comment'),
          ),
        ],
      ),
    );

    if (result != null && result.isNotEmpty) {
      try {
        await widget.collaborationService.addComment(content: result);
      } catch (e) {
        _showErrorSnackBar('Failed to add comment: $e');
      }
    }
  }

  void _showCollaborationToast(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 4),
      ),
    );
  }
}

/// Custom painter for live cursors overlay
class LiveCursorsPainter extends CustomPainter {
  final List<CollaborationUser> activeUsers;
  final TextStyle textStyle;

  LiveCursorsPainter({
    required this.activeUsers,
    required this.textStyle,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (final user in activeUsers) {
      if (user.cursor == null) continue;

      final cursor = user.cursor!;
      final color = _parseColor(user.color);

      // Calculate cursor position (simplified - in real implementation
      // you'd need proper text metrics)
      final x = cursor.column * 8.0; // Approximate character width
      final y = cursor.line * 20.0; // Approximate line height

      // Draw cursor line
      final paint = Paint()
        ..color = color
        ..strokeWidth = 2;

      canvas.drawLine(
        Offset(x, y),
        Offset(x, y + 20),
        paint,
      );

      // Draw user label
      final textPainter = TextPainter(
        text: TextSpan(
          text: user.displayName,
          style: TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      );

      textPainter.layout();

      // Draw label background
      final labelRect = Rect.fromLTWH(
        x,
        y - 20,
        textPainter.width + 8,
        16,
      );

      canvas.drawRRect(
        RRect.fromRectAndRadius(labelRect, const Radius.circular(4)),
        Paint()..color = color,
      );

      // Draw label text
      textPainter.paint(canvas, Offset(x + 4, y - 18));
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;

  Color _parseColor(String colorString) {
    try {
      return Color(int.parse(colorString.replaceFirst('#', '0xFF')));
    } catch (e) {
      return Colors.blue;
    }
  }
}
