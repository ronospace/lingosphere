// 🌐 LingoSphere - Conflict Resolution Screen
// UI for resolving sync conflicts with visual comparison and merge options

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../shared/theme/app_theme.dart';
import '../../../core/services/offline_sync_service.dart';
import '../../../core/models/translation_history.dart';
import '../../../core/models/translation_entry.dart';
import '../../../core/models/common_models.dart';
import '../../../core/services/history_service.dart';
import '../widgets/history_item_card.dart';

/// Conflict resolution screen for handling sync conflicts
class ConflictResolutionScreen extends StatefulWidget {
  final OfflineSyncService syncService;

  const ConflictResolutionScreen({
    super.key,
    required this.syncService,
  });

  @override
  State<ConflictResolutionScreen> createState() =>
      _ConflictResolutionScreenState();
}

class _ConflictResolutionScreenState extends State<ConflictResolutionScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  int _currentConflictIndex = 0;
  bool _isResolving = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      appBar: _buildAppBar(),
      body: Consumer<OfflineSyncService>(
        builder: (context, syncService, child) {
          final conflicts = syncService.conflicts;

          if (conflicts.isEmpty) {
            return _buildNoConflictsState();
          }

          return _buildConflictResolution(conflicts);
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Consumer<OfflineSyncService>(
        builder: (context, syncService, child) {
          final conflictCount = syncService.conflicts.length;
          return Text(
            'Resolve Conflicts${conflictCount > 0 ? ' ($conflictCount)' : ''}',
            style: const TextStyle(
              color: AppTheme.white,
              fontWeight: FontWeight.w600,
            ),
          );
        },
      ),
      backgroundColor: AppTheme.gray900,
      iconTheme: const IconThemeData(color: AppTheme.white),
      elevation: 0,
      actions: [
        Consumer<OfflineSyncService>(
          builder: (context, syncService, child) {
            final conflicts = syncService.conflicts;
            if (conflicts.isEmpty) return const SizedBox.shrink();

            return PopupMenuButton<String>(
              onSelected: (value) => _handleMenuAction(value, conflicts),
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'use_all_local',
                  child: Row(
                    children: [
                      Icon(Icons.phone_android,
                          color: AppTheme.twitterBlue, size: 18),
                      SizedBox(width: 12),
                      Text('Use All Local',
                          style: TextStyle(color: AppTheme.white)),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'use_all_remote',
                  child: Row(
                    children: [
                      Icon(Icons.cloud, color: AppTheme.vibrantGreen, size: 18),
                      SizedBox(width: 12),
                      Text('Use All Remote',
                          style: TextStyle(color: AppTheme.white)),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'clear_all',
                  child: Row(
                    children: [
                      Icon(Icons.clear_all, color: AppTheme.errorRed, size: 18),
                      SizedBox(width: 12),
                      Text('Clear All',
                          style: TextStyle(color: AppTheme.white)),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildNoConflictsState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.check_circle_outline,
            size: 80,
            color: AppTheme.vibrantGreen,
          ),
          const SizedBox(height: 24),
          const Text(
            'All Conflicts Resolved!',
            style: TextStyle(
              color: AppTheme.white,
              fontSize: 24,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Your translation history is fully synchronized.',
            style: TextStyle(
              color: AppTheme.gray400,
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () => Navigator.of(context).pop(),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.vibrantGreen,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            icon: const Icon(Icons.arrow_back, color: AppTheme.white),
            label: const Text(
              'Back to History',
              style: TextStyle(color: AppTheme.white, fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConflictResolution(List<SyncConflict> conflicts) {
    final conflict = conflicts[_currentConflictIndex];

    return Column(
      children: [
        // Conflict navigation
        _buildConflictNavigation(conflicts),

        // Conflict info
        _buildConflictInfo(conflict),

        // Comparison view
        Expanded(
          child: _buildComparisonView(conflict),
        ),

        // Resolution actions
        _buildResolutionActions(conflict),
      ],
    );
  }

  Widget _buildConflictNavigation(List<SyncConflict> conflicts) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.gray900,
        border: Border(
          bottom: BorderSide(color: AppTheme.gray700, width: 1),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: _currentConflictIndex > 0
                ? () => setState(() => _currentConflictIndex--)
                : null,
            icon: Icon(
              Icons.chevron_left,
              color:
                  _currentConflictIndex > 0 ? AppTheme.white : AppTheme.gray600,
            ),
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Conflict ${_currentConflictIndex + 1} of ${conflicts.length}',
                    style: const TextStyle(
                      color: AppTheme.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.vibrantOrange.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      conflicts[_currentConflictIndex].conflictReason,
                      style: const TextStyle(
                        color: AppTheme.vibrantOrange,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          IconButton(
            onPressed: _currentConflictIndex < conflicts.length - 1
                ? () => setState(() => _currentConflictIndex++)
                : null,
            icon: Icon(
              Icons.chevron_right,
              color: _currentConflictIndex < conflicts.length - 1
                  ? AppTheme.white
                  : AppTheme.gray600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConflictInfo(SyncConflict conflict) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.vibrantOrange.withValues(alpha: 0.1),
        border: Border(
          bottom: BorderSide(color: AppTheme.gray700, width: 1),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.warning_amber,
            color: AppTheme.vibrantOrange,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Sync Conflict Detected',
                  style: TextStyle(
                    color: AppTheme.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Both local and remote versions were modified. Choose which version to keep.',
                  style: TextStyle(
                    color: AppTheme.gray300,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Conflict time: ${_formatDateTime(conflict.conflictTime)}',
                  style: TextStyle(
                    color: AppTheme.gray400,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildComparisonView(SyncConflict conflict) {
    return Container(
      child: Column(
        children: [
          // Version selector tabs
          TabBar(
            controller: _tabController,
            labelColor: AppTheme.vibrantGreen,
            unselectedLabelColor: AppTheme.gray400,
            indicatorColor: AppTheme.vibrantGreen,
            tabs: [
              Tab(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.phone_android, size: 18),
                    const SizedBox(width: 8),
                    Text('Local Version'),
                  ],
                ),
              ),
              Tab(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.cloud, size: 18),
                    const SizedBox(width: 8),
                    Text('Remote Version'),
                  ],
                ),
              ),
            ],
          ),

          // Version content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildVersionView(conflict.localVersion, isLocal: true),
                _buildVersionView(conflict.remoteVersion, isLocal: false),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVersionView(TranslationHistory version,
      {required bool isLocal}) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Version header
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color:
                      (isLocal ? AppTheme.twitterBlue : AppTheme.vibrantGreen)
                          .withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color:
                        (isLocal ? AppTheme.twitterBlue : AppTheme.vibrantGreen)
                            .withValues(alpha: 0.5),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isLocal ? Icons.phone_android : Icons.cloud,
                      color: isLocal
                          ? AppTheme.twitterBlue
                          : AppTheme.vibrantGreen,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      isLocal ? 'Local Device' : 'Remote Server',
                      style: TextStyle(
                        color: isLocal
                            ? AppTheme.twitterBlue
                            : AppTheme.vibrantGreen,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Text(
                'Modified: ${_formatDateTime(version.lastModified ?? version.timestamp)}',
                style: const TextStyle(
                  color: AppTheme.gray400,
                  fontSize: 12,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Translation card
          Expanded(
            child: SingleChildScrollView(
              child: HistoryItemCard(
                item: _convertTranslationHistoryToHistoryEntry(version),
                compact: false,
              ),
            ),
          ),

          // Differences highlight
          _buildDifferencesSection(version, isLocal),
        ],
      ),
    );
  }

  Widget _buildDifferencesSection(TranslationHistory version, bool isLocal) {
    // This would show specific differences between versions
    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.gray800,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.gray600),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Version Details',
            style: const TextStyle(
              color: AppTheme.white,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          _buildDetailRow('Favorite Status', version.isFavorite ? 'Yes' : 'No'),
          _buildDetailRow('Usage Count', '${version.usageCount}'),
          _buildDetailRow('Confidence',
              '${(version.confidence * 100).toStringAsFixed(1)}%'),
          if (version.notes != null) _buildDetailRow('Notes', version.notes!),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Text(
            '$label:',
            style: const TextStyle(
              color: AppTheme.gray400,
              fontSize: 12,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: AppTheme.white,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResolutionActions(SyncConflict conflict) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.gray900,
        border: Border(
          top: BorderSide(color: AppTheme.gray700, width: 1),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _isResolving
                      ? null
                      : () => _resolveConflict(
                          conflict, ConflictResolution.useLocal),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.twitterBlue,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  icon: const Icon(Icons.phone_android, color: AppTheme.white),
                  label: const Text(
                    'Use Local',
                    style: TextStyle(
                        color: AppTheme.white, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _isResolving
                      ? null
                      : () => _resolveConflict(
                          conflict, ConflictResolution.useRemote),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.vibrantGreen,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  icon: const Icon(Icons.cloud, color: AppTheme.white),
                  label: const Text(
                    'Use Remote',
                    style: TextStyle(
                        color: AppTheme.white, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed:
                      _isResolving ? null : () => _showMergeDialog(conflict),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: AppTheme.vibrantOrange),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  icon: Icon(Icons.merge, color: AppTheme.vibrantOrange),
                  label: Text(
                    'Merge Versions',
                    style: TextStyle(
                      color: AppTheme.vibrantOrange,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _isResolving ? null : () => _skipConflict(),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: AppTheme.gray400),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  icon: Icon(Icons.skip_next, color: AppTheme.gray400),
                  label: Text(
                    'Skip for Now',
                    style: TextStyle(
                      color: AppTheme.gray400,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
          if (_isResolving) ...[
            const SizedBox(height: 16),
            const CircularProgressIndicator(color: AppTheme.vibrantGreen),
          ],
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  void _handleMenuAction(String action, List<SyncConflict> conflicts) async {
    switch (action) {
      case 'use_all_local':
        await _resolveAllConflicts(ConflictResolution.useLocal);
        break;
      case 'use_all_remote':
        await _resolveAllConflicts(ConflictResolution.useRemote);
        break;
      case 'clear_all':
        await _clearAllConflicts();
        break;
    }
  }

  Future<void> _resolveConflict(
      SyncConflict conflict, ConflictResolution resolution) async {
    setState(() => _isResolving = true);

    try {
      await widget.syncService.resolveConflict(conflict.id, resolution);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Conflict resolved using ${resolution.name} version'),
            backgroundColor: AppTheme.vibrantGreen,
          ),
        );

        // Move to next conflict or go back if this was the last one
        final remainingConflicts = widget.syncService.conflicts;
        if (remainingConflicts.isEmpty) {
          Navigator.of(context).pop();
        } else if (_currentConflictIndex >= remainingConflicts.length) {
          setState(() => _currentConflictIndex = remainingConflicts.length - 1);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to resolve conflict: $e'),
            backgroundColor: AppTheme.errorRed,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isResolving = false);
      }
    }
  }

  Future<void> _resolveAllConflicts(ConflictResolution resolution) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.gray900,
        title: Text(
          'Resolve All Conflicts',
          style: const TextStyle(color: AppTheme.white),
        ),
        content: Text(
          'This will resolve all conflicts using the ${resolution.name} version. This action cannot be undone.',
          style: const TextStyle(color: AppTheme.gray300),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child:
                const Text('Cancel', style: TextStyle(color: AppTheme.gray400)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.vibrantGreen),
            child: const Text('Resolve All',
                style: TextStyle(color: AppTheme.white)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() => _isResolving = true);

      try {
        final conflicts = List<SyncConflict>.from(widget.syncService.conflicts);
        for (final conflict in conflicts) {
          await widget.syncService.resolveConflict(conflict.id, resolution);
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  'All conflicts resolved using ${resolution.name} versions'),
              backgroundColor: AppTheme.vibrantGreen,
            ),
          );
          Navigator.of(context).pop();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to resolve conflicts: $e'),
              backgroundColor: AppTheme.errorRed,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isResolving = false);
        }
      }
    }
  }

  Future<void> _clearAllConflicts() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.gray900,
        title: const Text(
          'Clear All Conflicts',
          style: TextStyle(color: AppTheme.white),
        ),
        content: const Text(
          'This will clear all conflicts without resolving them. The conflicting translations will remain unsynced.',
          style: TextStyle(color: AppTheme.gray300),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child:
                const Text('Cancel', style: TextStyle(color: AppTheme.gray400)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.errorRed),
            child: const Text('Clear All',
                style: TextStyle(color: AppTheme.white)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await widget.syncService.clearResolvedConflicts();
      if (mounted) {
        Navigator.of(context).pop();
      }
    }
  }

  void _showMergeDialog(SyncConflict conflict) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.gray900,
        title: const Text('Merge Versions',
            style: TextStyle(color: AppTheme.white)),
        content: const Text(
          'Manual merging is not yet implemented. Please choose to use either the local or remote version.',
          style: TextStyle(color: AppTheme.gray300),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK',
                style: TextStyle(color: AppTheme.vibrantGreen)),
          ),
        ],
      ),
    );
  }

  void _skipConflict() {
    if (_currentConflictIndex < widget.syncService.conflicts.length - 1) {
      setState(() => _currentConflictIndex++);
    } else {
      Navigator.of(context).pop();
    }
  }

  /// Convert TranslationHistory to HistoryEntry for widget compatibility
  HistoryEntry _convertTranslationHistoryToHistoryEntry(
      TranslationHistory translationHistory) {
    // Get the most recent entry or create a default one
    final mostRecent = translationHistory.entries.isNotEmpty
        ? translationHistory.entries.last
        : null;

    return HistoryEntry(
      id: translationHistory.id,
      originalText: mostRecent?.sourceText ?? translationHistory.originalText,
      translatedText:
          mostRecent?.translatedText ?? translationHistory.translatedText,
      sourceLanguage:
          mostRecent?.sourceLanguage ?? translationHistory.sourceLanguage,
      targetLanguage:
          mostRecent?.targetLanguage ?? translationHistory.targetLanguage,
      translationSource:
          _mapTranslationMethodToEngineSource(mostRecent?.type) ??
              TranslationEngineSource.manual,
      confidence: translationHistory.confidence,
      timestamp: translationHistory.timestamp,
      isFavorite: translationHistory.isFavorite,
      category: translationHistory
          .name, // Use name field instead of category which doesn't exist
      notes: translationHistory.notes,
    );
  }

  /// Helper method to convert TranslationMethod to TranslationEngineSource
  TranslationEngineSource? _mapTranslationMethodToEngineSource(
      TranslationMethod? method) {
    if (method == null) return null;
    switch (method) {
      case TranslationMethod.text:
        return TranslationEngineSource.text;
      case TranslationMethod.voice:
        return TranslationEngineSource.voice;
      case TranslationMethod.camera:
        return TranslationEngineSource.camera;
      case TranslationMethod.image:
        return TranslationEngineSource.camera;
      case TranslationMethod.document:
        return TranslationEngineSource.file;
    }
  }
}
