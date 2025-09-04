// 🌐 LingoSphere - Enhanced Translation History Screen
// Main history screen integrating search, filters, export, and statistics

import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:provider/provider.dart';
import '../../../shared/theme/app_theme.dart';
import '../../../core/services/history_service.dart';
import '../../../core/services/export_service.dart';
import '../../../core/services/offline_sync_service.dart';
import '../../../core/models/translation_history.dart';
import '../../../core/models/common_models.dart';
import '../controllers/smart_filter_controller.dart';
import '../widgets/advanced_search_widgets.dart';
import '../widgets/history_item_card.dart';
import 'statistics_dashboard.dart';
import 'conflict_resolution_screen.dart';

/// Enhanced history screen with advanced features
class EnhancedHistoryScreen extends StatefulWidget {
  const EnhancedHistoryScreen({super.key});

  @override
  State<EnhancedHistoryScreen> createState() => _EnhancedHistoryScreenState();
}

class _EnhancedHistoryScreenState extends State<EnhancedHistoryScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late SmartFilterController _filterController;
  late AnimationController _fabAnimationController;
  late Animation<double> _fabAnimation;

  bool _showFilters = false;
  bool _isExporting = false;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _filterController = SmartFilterController(context.read<HistoryService>());

    _fabAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fabAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _fabAnimationController, curve: Curves.easeInOut),
    );

    _fabAnimationController.forward();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _filterController.dispose();
    _fabAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          // Search and filters
          _buildSearchSection(),

          // Filter chips (when active)
          if (_showFilters || _filterController.filterState.hasActiveFilters)
            _buildFilterSection(),

          // Sync status indicator
          _buildSyncStatusIndicator(),

          // Content tabs
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildHistoryTab(),
                _buildFavoritesTab(),
                _buildCategoriesTab(),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: _buildFloatingActionButtons(),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text(
        'Translation History',
        style: TextStyle(
          color: AppTheme.white,
          fontWeight: FontWeight.w600,
        ),
      ),
      backgroundColor: AppTheme.gray900,
      iconTheme: const IconThemeData(color: AppTheme.white),
      elevation: 0,
      actions: [
        // Sync status
        Consumer<OfflineSyncService>(
          builder: (context, syncService, child) {
            return IconButton(
              icon: _buildSyncIcon(syncService.syncStatus),
              onPressed: () => _showSyncStatusDialog(syncService),
            );
          },
        ),

        // Statistics
        IconButton(
          icon: const Icon(Icons.analytics_outlined),
          onPressed: _navigateToStatistics,
        ),

        // Export
        IconButton(
          icon: const Icon(Icons.download_outlined),
          onPressed: _showExportOptions,
        ),

        // Menu
        PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert),
          onSelected: _handleMenuAction,
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'conflicts',
              child: Row(
                children: [
                  Icon(Icons.warning_amber_outlined,
                      color: AppTheme.vibrantOrange),
                  SizedBox(width: 12),
                  Text('Resolve Conflicts'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'clear_filters',
              child: Row(
                children: [
                  Icon(Icons.clear_all, color: AppTheme.gray400),
                  SizedBox(width: 12),
                  Text('Clear Filters'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'refresh',
              child: Row(
                children: [
                  Icon(Icons.refresh, color: AppTheme.twitterBlue),
                  SizedBox(width: 12),
                  Text('Refresh'),
                ],
              ),
            ),
          ],
        ),
      ],
      bottom: TabBar(
        controller: _tabController,
        labelColor: AppTheme.vibrantGreen,
        unselectedLabelColor: AppTheme.gray400,
        indicatorColor: AppTheme.vibrantGreen,
        tabs: [
          Tab(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.history, size: 18),
                const SizedBox(width: 8),
                Consumer<SmartFilterController>(
                  builder: (context, controller, child) {
                    return Text('All (${controller.filteredResults.length})');
                  },
                ),
              ],
            ),
          ),
          Tab(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.favorite, size: 18),
                const SizedBox(width: 8),
                Consumer<SmartFilterController>(
                  builder: (context, controller, child) {
                    final favoriteCount = controller.filteredResults
                        .where((item) => item.isFavorite)
                        .length;
                    return Text('Favorites ($favoriteCount)');
                  },
                ),
              ],
            ),
          ),
          const Tab(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.category, size: 18),
                SizedBox(width: 8),
                Text('Categories'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchSection() {
    return Consumer<SmartFilterController>(
      builder: (context, controller, child) {
        return AdvancedSearchBar(
          initialQuery: _searchQuery,
          onQueryChanged: (query) {
            setState(() => _searchQuery = query);
            controller.updateSearchQuery(query);
          },
          onFiltersPressed: () {
            setState(() => _showFilters = !_showFilters);
          },
          hasActiveFilters: controller.filterState.hasActiveFilters,
          isLoading: controller.isLoading,
          onVoiceSearch: _handleVoiceSearch,
        );
      },
    );
  }

  Widget _buildFilterSection() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      height: _showFilters ? null : 0,
      child: Consumer<SmartFilterController>(
        builder: (context, controller, child) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Quick filter presets
                if (_showFilters) ...[
                  const Text(
                    'Quick Filters',
                    style: TextStyle(
                      color: AppTheme.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      CustomFilterChip(
                        label: 'Today',
                        isSelected: _isDateFilterSelected('today'),
                        onTap: () => _applyDateFilter('today'),
                        icon: Icons.today,
                      ),
                      CustomFilterChip(
                        label: 'This Week',
                        isSelected: _isDateFilterSelected('week'),
                        onTap: () => _applyDateFilter('week'),
                        icon: Icons.date_range,
                      ),
                      CustomFilterChip(
                        label: 'High Confidence',
                        isSelected:
                            controller.filterState.confidenceRange.start > 0.8,
                        onTap: () => _applyConfidenceFilter(),
                        icon: Icons.star,
                        color: AppTheme.vibrantOrange,
                      ),
                      CustomFilterChip(
                        label: 'Camera',
                        isSelected: controller.filterState.sources
                            .contains(TranslationSource.camera),
                        onTap: () =>
                            _toggleSourceFilter(TranslationSource.camera),
                        icon: Icons.camera_alt,
                        color: AppTheme.vibrantGreen,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],

                // Active filters
                if (controller.filterState.hasActiveFilters) ...[
                  Row(
                    children: [
                      const Text(
                        'Active Filters',
                        style: TextStyle(
                          color: AppTheme.gray300,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const Spacer(),
                      TextButton(
                        onPressed: controller.clearAllFilters,
                        child: const Text(
                          'Clear All',
                          style: TextStyle(color: AppTheme.errorRed),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  _buildActiveFilters(controller),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildActiveFilters(SmartFilterController controller) {
    final activeFilters = <Widget>[];

    if (controller.filterState.dateRange != null) {
      activeFilters.add(
        CustomFilterChip(
          label: 'Date Range',
          isSelected: true,
          onTap: () => controller.updateDateRange(null),
          icon: Icons.close,
          color: AppTheme.twitterBlue,
        ),
      );
    }

    if (controller.filterState.sourceLanguages.isNotEmpty) {
      activeFilters.add(
        CustomFilterChip(
          label: 'Languages (${controller.filterState.sourceLanguages.length})',
          isSelected: true,
          onTap: () => controller.updateSourceLanguages([]),
          icon: Icons.close,
          color: AppTheme.vibrantGreen,
        ),
      );
    }

    if (controller.filterState.sources.isNotEmpty) {
      activeFilters.add(
        CustomFilterChip(
          label: 'Sources (${controller.filterState.sources.length})',
          isSelected: true,
          onTap: () => controller.updateSources([]),
          icon: Icons.close,
          color: AppTheme.vibrantOrange,
        ),
      );
    }

    return Wrap(
      spacing: 8,
      runSpacing: 4,
      children: activeFilters,
    );
  }

  Widget _buildSyncStatusIndicator() {
    return Consumer<OfflineSyncService>(
      builder: (context, syncService, child) {
        if (syncService.syncStatus == SyncStatus.idle &&
            syncService.conflicts.isEmpty) {
          return const SizedBox.shrink();
        }

        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: _getSyncStatusColor(syncService.syncStatus).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color:
                  _getSyncStatusColor(syncService.syncStatus).withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            children: [
              Icon(
                _getSyncStatusIcon(syncService.syncStatus),
                color: _getSyncStatusColor(syncService.syncStatus),
                size: 16,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _getSyncStatusMessage(syncService),
                  style: TextStyle(
                    color: _getSyncStatusColor(syncService.syncStatus),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              if (syncService.conflicts.isNotEmpty)
                TextButton(
                  onPressed: _navigateToConflictResolution,
                  style: TextButton.styleFrom(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    minimumSize: Size.zero,
                  ),
                  child: Text(
                    'Resolve',
                    style: TextStyle(
                      color: _getSyncStatusColor(syncService.syncStatus),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHistoryTab() {
    return Consumer<SmartFilterController>(
      builder: (context, controller, child) {
        if (controller.isLoading) {
          return const Center(
            child: CircularProgressIndicator(color: AppTheme.vibrantGreen),
          );
        }

        if (controller.error != null) {
          return _buildErrorState(controller.error!, controller.refresh);
        }

        final items = controller.filteredResults;

        if (items.isEmpty) {
          return _buildEmptyState();
        }

        return AnimationLimiter(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: items.length,
            itemBuilder: (context, index) {
              return AnimationConfiguration.staggeredList(
                position: index,
                duration: const Duration(milliseconds: 375),
                child: SlideAnimation(
                  verticalOffset: 50.0,
                  child: FadeInAnimation(
                    child: HistoryItemCard(
                      item: items[index],
                      onTap: () => _showHistoryItemDetails(items[index]),
                      onFavoriteToggle: () => _toggleFavorite(items[index]),
                      onDelete: () => _deleteHistoryItem(items[index]),
                      onEdit: () => _editHistoryItem(items[index]),
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildFavoritesTab() {
    return Consumer<SmartFilterController>(
      builder: (context, controller, child) {
        final favoriteItems = controller.filteredResults
            .where((item) => item.isFavorite)
            .toList();

        if (favoriteItems.isEmpty) {
          return _buildEmptyState(
            icon: Icons.favorite_border,
            title: 'No Favorites Yet',
            message: 'Mark translations as favorites to see them here',
          );
        }

        return AnimationLimiter(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: favoriteItems.length,
            itemBuilder: (context, index) {
              return AnimationConfiguration.staggeredList(
                position: index,
                duration: const Duration(milliseconds: 375),
                child: SlideAnimation(
                  verticalOffset: 50.0,
                  child: FadeInAnimation(
                    child: HistoryItemCard(
                      item: favoriteItems[index],
                      onTap: () =>
                          _showHistoryItemDetails(favoriteItems[index]),
                      onFavoriteToggle: () =>
                          _toggleFavorite(favoriteItems[index]),
                      onDelete: () => _deleteHistoryItem(favoriteItems[index]),
                      onEdit: () => _editHistoryItem(favoriteItems[index]),
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildCategoriesTab() {
    return Consumer<SmartFilterController>(
      builder: (context, controller, child) {
        final categories = <String, List<HistoryEntry>>{};

        for (final item in controller.filteredResults) {
          final category = item.category ?? 'Uncategorized';
          categories.putIfAbsent(category, () => []).add(item);
        }

        if (categories.isEmpty) {
          return _buildEmptyState(
            icon: Icons.category_outlined,
            title: 'No Categories',
            message: 'Categorize your translations to organize them better',
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: categories.length,
          itemBuilder: (context, index) {
            final category = categories.keys.elementAt(index);
            final items = categories[category]!;

            return AnimationConfiguration.staggeredList(
              position: index,
              duration: const Duration(milliseconds: 375),
              child: SlideAnimation(
                verticalOffset: 50.0,
                child: FadeInAnimation(
                  child: _buildCategorySection(category, items),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildCategorySection(String category, List<HistoryEntry> items) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppTheme.gray900,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.gray700),
      ),
      child: ExpansionTile(
        title: Text(
          category,
          style: const TextStyle(
            color: AppTheme.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          '${items.length} translations',
          style: const TextStyle(color: AppTheme.gray400, fontSize: 14),
        ),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppTheme.vibrantGreen.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(
            Icons.folder,
            color: AppTheme.vibrantGreen,
            size: 20,
          ),
        ),
        children: items
            .map((item) => HistoryItemCard(
                  item: item,
                  onTap: () => _showHistoryItemDetails(item),
                  onFavoriteToggle: () => _toggleFavorite(item),
                  onDelete: () => _deleteHistoryItem(item),
                  onEdit: () => _editHistoryItem(item),
                  compact: true,
                ))
            .toList(),
      ),
    );
  }

  Widget _buildEmptyState({
    IconData icon = Icons.history,
    String title = 'No Translation History',
    String message = 'Your translations will appear here',
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 64,
            color: AppTheme.gray600,
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
              color: AppTheme.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: const TextStyle(
              color: AppTheme.gray400,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error, VoidCallback onRetry) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: AppTheme.errorRed,
          ),
          const SizedBox(height: 16),
          Text(
            'Something went wrong',
            style: const TextStyle(
              color: AppTheme.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            error,
            style: const TextStyle(
              color: AppTheme.gray400,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: onRetry,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.vibrantGreen,
            ),
            child: const Text(
              'Retry',
              style: TextStyle(color: AppTheme.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingActionButtons() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ScaleTransition(
          scale: _fabAnimation,
          child: FloatingActionButton.small(
            heroTag: "filter",
            onPressed: _showAdvancedFilters,
            backgroundColor: AppTheme.gray800,
            child: const Icon(Icons.filter_list, color: AppTheme.white),
          ),
        ),
        const SizedBox(height: 12),
        ScaleTransition(
          scale: _fabAnimation,
          child: FloatingActionButton(
            heroTag: "search",
            onPressed: _focusSearchBar,
            backgroundColor: AppTheme.vibrantGreen,
            child: const Icon(Icons.search, color: AppTheme.white),
          ),
        ),
      ],
    );
  }

  Widget _buildSyncIcon(SyncStatus status) {
    switch (status) {
      case SyncStatus.idle:
        return const Icon(Icons.cloud_done_outlined, color: AppTheme.gray400);
      case SyncStatus.syncing:
        return const SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: AppTheme.twitterBlue,
          ),
        );
      case SyncStatus.success:
        return const Icon(Icons.cloud_done, color: AppTheme.vibrantGreen);
      case SyncStatus.error:
        return const Icon(Icons.cloud_off, color: AppTheme.errorRed);
      case SyncStatus.conflict:
        return const Icon(Icons.warning_amber, color: AppTheme.vibrantOrange);
    }
  }

  Color _getSyncStatusColor(SyncStatus status) {
    switch (status) {
      case SyncStatus.idle:
        return AppTheme.gray400;
      case SyncStatus.syncing:
        return AppTheme.twitterBlue;
      case SyncStatus.success:
        return AppTheme.vibrantGreen;
      case SyncStatus.error:
        return AppTheme.errorRed;
      case SyncStatus.conflict:
        return AppTheme.vibrantOrange;
    }
  }

  IconData _getSyncStatusIcon(SyncStatus status) {
    switch (status) {
      case SyncStatus.idle:
        return Icons.cloud_queue;
      case SyncStatus.syncing:
        return Icons.sync;
      case SyncStatus.success:
        return Icons.cloud_done;
      case SyncStatus.error:
        return Icons.cloud_off;
      case SyncStatus.conflict:
        return Icons.warning_amber;
    }
  }

  String _getSyncStatusMessage(OfflineSyncService syncService) {
    switch (syncService.syncStatus) {
      case SyncStatus.idle:
        return 'Ready to sync';
      case SyncStatus.syncing:
        return 'Syncing translations...';
      case SyncStatus.success:
        return 'All translations synced';
      case SyncStatus.error:
        return 'Sync failed - ${syncService.pendingOperationsCount} pending';
      case SyncStatus.conflict:
        return '${syncService.conflicts.length} conflicts need resolution';
    }
  }

  // Event handlers
  void _handleVoiceSearch() {
    // TODO: Implement voice search functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Voice search coming soon!'),
        backgroundColor: AppTheme.twitterBlue,
      ),
    );
  }

  void _handleMenuAction(String action) {
    switch (action) {
      case 'conflicts':
        _navigateToConflictResolution();
        break;
      case 'clear_filters':
        _filterController.clearAllFilters();
        break;
      case 'refresh':
        _filterController.refresh();
        break;
    }
  }

  bool _isDateFilterSelected(String period) {
    final dateRange = _filterController.filterState.dateRange;
    if (dateRange == null) return false;

    final now = DateTime.now();
    switch (period) {
      case 'today':
        final today = DateTime(now.year, now.month, now.day);
        return dateRange.start.isAtSameMomentAs(today);
      case 'week':
        final weekStart = now.subtract(Duration(days: now.weekday - 1));
        return dateRange.start.difference(weekStart).inDays.abs() < 1;
      default:
        return false;
    }
  }

  void _applyDateFilter(String period) {
    final now = DateTime.now();
    DateRange? range;

    switch (period) {
      case 'today':
        range = DateRange(
          start: DateTime(now.year, now.month, now.day),
          end: now,
        );
        break;
      case 'week':
        range = DateRange(
          start: now.subtract(Duration(days: now.weekday - 1)),
          end: now,
        );
        break;
    }

    _filterController.updateDateRange(range);
  }

  void _applyConfidenceFilter() {
    final current = _filterController.filterState.confidenceRange;
    if (current.start > 0.8) {
      _filterController.updateConfidenceRange(const RangeValues(0.0, 1.0));
    } else {
      _filterController.updateConfidenceRange(const RangeValues(0.8, 1.0));
    }
  }

  void _toggleSourceFilter(TranslationSource source) {
    final currentSources =
        List<TranslationSource>.from(_filterController.filterState.sources);
    if (currentSources.contains(source)) {
      currentSources.remove(source);
    } else {
      currentSources.add(source);
    }
    _filterController.updateSources(currentSources);
  }

  void _showAdvancedFilters() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            color: AppTheme.gray900,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: AppTheme.gray600,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const Padding(
                padding: EdgeInsets.all(20),
                child: Text(
                  'Advanced Filters',
                  style: TextStyle(
                    color: AppTheme.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      // TODO: Add advanced filter UI components
                      const Text(
                        'Advanced filter options coming soon...',
                        style: TextStyle(color: AppTheme.gray400),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _focusSearchBar() {
    // TODO: Focus search bar
  }

  void _navigateToStatistics() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => StatisticsDashboard(
          historyService: context.read<HistoryService>(),
        ),
      ),
    );
  }

  void _navigateToConflictResolution() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ConflictResolutionScreen(
          syncService: context.read<OfflineSyncService>(),
        ),
      ),
    );
  }

  void _showExportOptions() async {
    setState(() => _isExporting = true);

    try {
      final exportService = context.read<ExportService>();
      final formats = exportService.getAvailableFormats();

      final selectedFormat = await showModalBottomSheet<ExportFormat>(
        context: context,
        backgroundColor: AppTheme.gray900,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (context) => Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Export Format',
                style: TextStyle(
                  color: AppTheme.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 20),
              ...formats.map((format) => ListTile(
                    leading: Text(
                      exportService.getFormatIcon(format),
                      style: const TextStyle(fontSize: 24),
                    ),
                    title: Text(
                      exportService.getFormatDisplayName(format),
                      style: const TextStyle(color: AppTheme.white),
                    ),
                    subtitle: Text(
                      exportService.getFormatDescription(format),
                      style: const TextStyle(
                          color: AppTheme.gray400, fontSize: 12),
                    ),
                    onTap: () => Navigator.of(context).pop(format),
                  )),
            ],
          ),
        ),
      );

      if (selectedFormat != null) {
        await _performExport(selectedFormat);
      }
    } finally {
      setState(() => _isExporting = false);
    }
  }

  Future<void> _performExport(ExportFormat format) async {
    try {
      final exportService = context.read<ExportService>();
      final items = _filterController.filteredResults;

      const options = ExportOptions(); // Use default options

      final result = await exportService.exportHistory(
        history: items.cast<TranslationHistory>(),
        format: format,
        options: options,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Exported ${result.itemCount} items (${result.fileSizeFormatted})',
            ),
            backgroundColor: AppTheme.vibrantGreen,
            action: SnackBarAction(
              label: 'Share',
              onPressed: () => exportService.shareExport(result),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Export failed: $e'),
            backgroundColor: AppTheme.errorRed,
          ),
        );
      }
    }
  }

  void _showSyncStatusDialog(OfflineSyncService syncService) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.gray900,
        title:
            const Text('Sync Status', style: TextStyle(color: AppTheme.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSyncStatusRow('Status', syncService.syncStatus.name),
            _buildSyncStatusRow('Online', syncService.isOnline ? 'Yes' : 'No'),
            _buildSyncStatusRow(
                'Pending', '${syncService.pendingOperationsCount}'),
            _buildSyncStatusRow('Conflicts', '${syncService.conflicts.length}'),
            if (syncService.syncStats?.lastSyncTime != null)
              _buildSyncStatusRow(
                  'Last Sync',
                  syncService.syncStats!.lastSyncTime
                      .toString()
                      .split('.')
                      .first),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child:
                const Text('Close', style: TextStyle(color: AppTheme.gray400)),
          ),
          if (syncService.isOnline)
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();
                try {
                  await syncService.triggerManualSync();
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Manual sync completed'),
                        backgroundColor: AppTheme.vibrantGreen,
                      ),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Sync failed: $e'),
                        backgroundColor: AppTheme.errorRed,
                      ),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.vibrantGreen),
              child: const Text('Sync Now',
                  style: TextStyle(color: AppTheme.white)),
            ),
        ],
      ),
    );
  }

  Widget _buildSyncStatusRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(
            '$label:',
            style: const TextStyle(color: AppTheme.gray400, fontSize: 14),
          ),
          const SizedBox(width: 8),
          Text(
            value,
            style: const TextStyle(color: AppTheme.white, fontSize: 14),
          ),
        ],
      ),
    );
  }

  void _showHistoryItemDetails(HistoryEntry item) {
    // TODO: Implement history item details dialog
  }

  void _toggleFavorite(HistoryEntry item) async {
    final updatedItem = item.copyWith(isFavorite: !item.isFavorite);
    await context.read<HistoryService>().updateHistory(updatedItem);
    _filterController.refresh();
  }

  void _deleteHistoryItem(HistoryEntry item) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.gray900,
        title: const Text('Delete Translation',
            style: TextStyle(color: AppTheme.white)),
        content: const Text(
          'Are you sure you want to delete this translation?',
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
            child:
                const Text('Delete', style: TextStyle(color: AppTheme.white)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await context.read<HistoryService>().deleteHistory(item.id);
      _filterController.refresh();
    }
  }

  void _editHistoryItem(HistoryEntry item) {
    // TODO: Implement edit history item dialog
  }
}
