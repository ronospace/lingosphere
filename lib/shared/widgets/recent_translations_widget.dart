// 🌐 LingoSphere - Recent Translations Widget
// Interactive widget for browsing and managing recent translations

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../../../shared/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/models/translation_entry.dart';
import '../../../shared/widgets/sharing/quick_share_button.dart';
import '../../../core/services/history_service.dart';

/// Filter options for translations
enum TranslationFilter { all, text, voice, camera, favorites }

/// Sort options for translations
enum TranslationSort { newest, oldest, alphabetical, mostUsed }

/// Interactive recent translations widget with advanced filtering and actions
class RecentTranslationsWidget extends ConsumerStatefulWidget {
  final int? maxItems;
  final bool showHeader;
  final bool showSearch;
  final bool showFilters;
  final VoidCallback? onViewAll;
  final Function(TranslationEntry)? onTranslationTap;

  const RecentTranslationsWidget({
    super.key,
    this.maxItems,
    this.showHeader = true,
    this.showSearch = false,
    this.showFilters = false,
    this.onViewAll,
    this.onTranslationTap,
  });

  @override
  ConsumerState<RecentTranslationsWidget> createState() =>
      _RecentTranslationsWidgetState();
}

class _RecentTranslationsWidgetState
    extends ConsumerState<RecentTranslationsWidget>
    with TickerProviderStateMixin {
  late AnimationController _listAnimationController;
  late AnimationController _filterAnimationController;
  late TextEditingController _searchController;

  TranslationFilter _selectedFilter = TranslationFilter.all;
  TranslationSort _selectedSort = TranslationSort.newest;
  String _searchQuery = '';
  bool _showFilters = false;

  // Mock data - replace with actual service data
  final List<TranslationEntry> _allTranslations = [
    TranslationEntry(
      id: '1',
      sourceText: 'Hello, how are you today?',
      translatedText: 'Hola, ¿cómo estás hoy?',
      sourceLanguage: 'en',
      targetLanguage: 'es',
      timestamp: DateTime.now().subtract(const Duration(minutes: 15)),
      type: TranslationMethod.text,
      isFavorite: true,
    ),
    TranslationEntry(
      id: '2',
      sourceText: 'Je voudrais un café, s\'il vous plaît',
      translatedText: 'I would like a coffee, please',
      sourceLanguage: 'fr',
      targetLanguage: 'en',
      timestamp: DateTime.now().subtract(const Duration(hours: 1)),
      type: TranslationMethod.voice,
      isFavorite: false,
    ),
    TranslationEntry(
      id: '3',
      sourceText: '今日は良い天気ですね',
      translatedText: 'The weather is nice today',
      sourceLanguage: 'ja',
      targetLanguage: 'en',
      timestamp: DateTime.now().subtract(const Duration(hours: 2)),
      type: TranslationMethod.camera,
      isFavorite: false,
    ),
    TranslationEntry(
      id: '4',
      sourceText: 'Guten Morgen! Wie geht es Ihnen?',
      translatedText: 'Good morning! How are you?',
      sourceLanguage: 'de',
      targetLanguage: 'en',
      timestamp: DateTime.now().subtract(const Duration(hours: 3)),
      type: TranslationMethod.text,
      isFavorite: true,
    ),
    TranslationEntry(
      id: '5',
      sourceText: 'Dove posso trovare un buon ristorante?',
      translatedText: 'Where can I find a good restaurant?',
      sourceLanguage: 'it',
      targetLanguage: 'en',
      timestamp: DateTime.now().subtract(const Duration(hours: 5)),
      type: TranslationMethod.voice,
      isFavorite: false,
    ),
    TranslationEntry(
      id: '6',
      sourceText: '请问最近的地铁站在哪里？',
      translatedText: 'Where is the nearest subway station?',
      sourceLanguage: 'zh',
      targetLanguage: 'en',
      timestamp: DateTime.now().subtract(const Duration(days: 1)),
      type: TranslationMethod.camera,
      isFavorite: true,
    ),
  ];

  List<TranslationEntry> _filteredTranslations = [];

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _filteredTranslations = List.from(_allTranslations);
    _applyFilters();
  }

  @override
  void dispose() {
    _listAnimationController.dispose();
    _filterAnimationController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _initializeControllers() {
    _listAnimationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _filterAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _searchController = TextEditingController();

    _listAnimationController.forward();
  }

  void _applyFilters() {
    setState(() {
      _filteredTranslations = _allTranslations.where((translation) {
        // Apply type filter
        bool matchesFilter = true;
        switch (_selectedFilter) {
          case TranslationFilter.text:
            matchesFilter = translation.type == TranslationMethod.text;
            break;
          case TranslationFilter.voice:
            matchesFilter = translation.type == TranslationMethod.voice;
            break;
          case TranslationFilter.camera:
            matchesFilter = translation.type == TranslationMethod.camera;
            break;
          case TranslationFilter.favorites:
            matchesFilter = translation.isFavorite;
            break;
          case TranslationFilter.all:
            matchesFilter = true;
            break;
        }

        // Apply search filter
        if (_searchQuery.isNotEmpty) {
          matchesFilter = matchesFilter &&
              (translation.sourceText
                      .toLowerCase()
                      .contains(_searchQuery.toLowerCase()) ||
                  translation.translatedText
                      .toLowerCase()
                      .contains(_searchQuery.toLowerCase()));
        }

        return matchesFilter;
      }).toList();

      // Apply sorting
      switch (_selectedSort) {
        case TranslationSort.newest:
          _filteredTranslations
              .sort((a, b) => b.timestamp.compareTo(a.timestamp));
          break;
        case TranslationSort.oldest:
          _filteredTranslations
              .sort((a, b) => a.timestamp.compareTo(b.timestamp));
          break;
        case TranslationSort.alphabetical:
          _filteredTranslations
              .sort((a, b) => a.sourceText.compareTo(b.sourceText));
          break;
        case TranslationSort.mostUsed:
          // Mock implementation - in real app, sort by usage count
          break;
      }

      // Apply max items limit
      if (widget.maxItems != null &&
          _filteredTranslations.length > widget.maxItems!) {
        _filteredTranslations =
            _filteredTranslations.take(widget.maxItems!).toList();
      }
    });

    // Restart list animation
    _listAnimationController.reset();
    _listAnimationController.forward();
  }

  void _toggleFilters() {
    setState(() {
      _showFilters = !_showFilters;
    });

    if (_showFilters) {
      _filterAnimationController.forward();
    } else {
      _filterAnimationController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.showHeader) _buildHeader(),
        if (widget.showSearch) _buildSearchBar(),
        if (widget.showFilters) _buildFiltersSection(),
        const SizedBox(height: 16),
        _buildTranslationsList(),
      ],
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          const Text(
            'Recent Translations',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppTheme.gray900,
              fontFamily: AppTheme.headingFontFamily,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppTheme.primaryBlue.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '${_filteredTranslations.length}',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppTheme.primaryBlue,
              ),
            ),
          ),
          const Spacer(),
          if (widget.showFilters)
            IconButton(
              onPressed: _toggleFilters,
              icon: AnimatedRotation(
                turns: _showFilters ? 0.5 : 0,
                duration: const Duration(milliseconds: 300),
                child: const Icon(Icons.tune),
              ),
              tooltip: 'Filters',
            ),
          if (widget.onViewAll != null)
            TextButton(
              onPressed: widget.onViewAll,
              child: const Text('View all'),
            ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: TextField(
        controller: _searchController,
        onChanged: (query) {
          _searchQuery = query;
          _applyFilters();
        },
        decoration: InputDecoration(
          hintText: 'Search translations...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  onPressed: () {
                    _searchController.clear();
                    _searchQuery = '';
                    _applyFilters();
                  },
                  icon: const Icon(Icons.clear),
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: AppTheme.gray100,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }

  Widget _buildFiltersSection() {
    return AnimatedBuilder(
      animation: _filterAnimationController,
      builder: (context, child) {
        return SizeTransition(
          sizeFactor: _filterAnimationController,
          child: Container(
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: AppTheme.gray50,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.gray200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildFilterChips(),
                const SizedBox(height: 12),
                _buildSortOptions(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildFilterChips() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Filter by Type',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppTheme.gray700,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: TranslationFilter.values.map((filter) {
            final isSelected = _selectedFilter == filter;
            return FilterChip(
              label: Text(_getFilterLabel(filter)),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) {
                  setState(() {
                    _selectedFilter = filter;
                  });
                  _applyFilters();
                }
              },
              selectedColor: AppTheme.primaryBlue.withValues(alpha: 0.2),
              backgroundColor: AppTheme.white,
              labelStyle: TextStyle(
                color: isSelected ? AppTheme.primaryBlue : AppTheme.gray600,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
              side: BorderSide(
                color: isSelected ? AppTheme.primaryBlue : AppTheme.gray300,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildSortOptions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Sort by',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppTheme.gray700,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: TranslationSort.values.map((sort) {
            final isSelected = _selectedSort == sort;
            return ChoiceChip(
              label: Text(_getSortLabel(sort)),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) {
                  setState(() {
                    _selectedSort = sort;
                  });
                  _applyFilters();
                }
              },
              selectedColor: AppTheme.accentTeal.withValues(alpha: 0.2),
              backgroundColor: AppTheme.white,
              labelStyle: TextStyle(
                color: isSelected ? AppTheme.accentTeal : AppTheme.gray600,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
              side: BorderSide(
                color: isSelected ? AppTheme.accentTeal : AppTheme.gray300,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildTranslationsList() {
    if (_filteredTranslations.isEmpty) {
      return _buildEmptyState();
    }

    return AnimatedBuilder(
      animation: _listAnimationController,
      builder: (context, child) {
        return AnimationLimiter(
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _filteredTranslations.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              return AnimationConfiguration.staggeredList(
                position: index,
                duration: const Duration(milliseconds: 375),
                child: SlideAnimation(
                  verticalOffset: 50.0,
                  child: FadeInAnimation(
                    child: _buildTranslationCard(_filteredTranslations[index]),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildTranslationCard(TranslationEntry translation) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () => widget.onTranslationTap?.call(translation),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTranslationHeader(translation),
              const SizedBox(height: 12),
              _buildTranslationContent(translation),
              const SizedBox(height: 12),
              _buildTranslationActions(translation),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTranslationHeader(TranslationEntry translation) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: _getTypeColor(translation.type).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            _getTypeIcon(translation.type),
            size: 16,
            color: _getTypeColor(translation.type),
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: AppTheme.primaryBlue.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            '${_getLanguageName(translation.sourceLanguage)} → ${_getLanguageName(translation.targetLanguage)}',
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppTheme.primaryBlue,
            ),
          ),
        ),
        const Spacer(),
        Text(
          _formatTimestamp(translation.timestamp),
          style: const TextStyle(
            fontSize: 12,
            color: AppTheme.gray500,
          ),
        ),
        if (translation.isFavorite) ...[
          const SizedBox(width: 8),
          const Icon(
            Icons.favorite,
            size: 16,
            color: AppTheme.errorRed,
          ),
        ],
      ],
    );
  }

  Widget _buildTranslationContent(TranslationEntry translation) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          translation.sourceText,
          style: const TextStyle(
            fontSize: 14,
            color: AppTheme.gray700,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 8),
        Text(
          translation.translatedText,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppTheme.gray900,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildTranslationActions(TranslationEntry translation) {
    return Row(
      children: [
        _buildActionButton(
          icon: Icons.copy,
          tooltip: 'Copy translation',
          onPressed: () => _copyToClipboard(translation.translatedText),
        ),
        const SizedBox(width: 16),
        QuickShareButton.forTranslation(
          translation: translation,
          size: QuickShareSize.small,
          primaryColor: AppTheme.gray600,
          tooltip: 'Share translation',
        ),
        const SizedBox(width: 16),
        _buildActionButton(
          icon: translation.isFavorite ? Icons.favorite : Icons.favorite_border,
          tooltip: translation.isFavorite
              ? 'Remove from favorites'
              : 'Add to favorites',
          color: translation.isFavorite ? AppTheme.errorRed : AppTheme.gray600,
          onPressed: () => _toggleFavorite(translation),
        ),
        const SizedBox(width: 16),
        _buildActionButton(
          icon: Icons.replay,
          tooltip: 'Translate again',
          onPressed: () => _translateAgain(translation),
        ),
        const Spacer(),
        Text(
          translation.type.name.toUpperCase(),
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: _getTypeColor(translation.type),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String tooltip,
    required VoidCallback onPressed,
    Color? color,
  }) {
    return Tooltip(
      message: tooltip,
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(icon, size: 20),
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(),
        color: color ?? AppTheme.gray600,
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(32),
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppTheme.gray50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.gray200),
      ),
      child: Column(
        children: [
          Icon(
            _searchQuery.isNotEmpty ? Icons.search_off : Icons.translate,
            size: 48,
            color: AppTheme.gray400,
          ),
          const SizedBox(height: 16),
          Text(
            _searchQuery.isNotEmpty
                ? 'No translations found'
                : 'No recent translations',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppTheme.gray600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _searchQuery.isNotEmpty
                ? 'Try adjusting your search or filters'
                : 'Start translating to see your history here',
            style: const TextStyle(
              fontSize: 14,
              color: AppTheme.gray500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // Helper methods
  String _getFilterLabel(TranslationFilter filter) {
    switch (filter) {
      case TranslationFilter.all:
        return 'All';
      case TranslationFilter.text:
        return 'Text';
      case TranslationFilter.voice:
        return 'Voice';
      case TranslationFilter.camera:
        return 'Camera';
      case TranslationFilter.favorites:
        return 'Favorites';
    }
  }

  String _getSortLabel(TranslationSort sort) {
    switch (sort) {
      case TranslationSort.newest:
        return 'Newest';
      case TranslationSort.oldest:
        return 'Oldest';
      case TranslationSort.alphabetical:
        return 'A-Z';
      case TranslationSort.mostUsed:
        return 'Most Used';
    }
  }

  IconData _getTypeIcon(TranslationMethod type) {
    switch (type) {
      case TranslationMethod.voice:
        return Icons.mic;
      case TranslationMethod.camera:
      case TranslationMethod.image:
        return Icons.camera_alt;
      case TranslationMethod.document:
        return Icons.description;
      default:
        return Icons.translate;
    }
  }

  Color _getTypeColor(TranslationMethod type) {
    switch (type) {
      case TranslationMethod.voice:
        return AppTheme.vibrantGreen;
      case TranslationMethod.camera:
      case TranslationMethod.image:
        return AppTheme.accentTeal;
      case TranslationMethod.document:
        return AppTheme.warningAmber;
      default:
        return AppTheme.primaryBlue;
    }
  }

  String _getLanguageName(String code) {
    return AppConstants.supportedLanguages[code] ?? code.toUpperCase();
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${(difference.inDays / 7).floor()}w ago';
    }
  }

  // Action methods
  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Copied to clipboard'),
        backgroundColor: AppTheme.successGreen,
        duration: Duration(seconds: 1),
      ),
    );
  }

  void _toggleFavorite(TranslationEntry translation) {
    HapticFeedback.lightImpact();
    setState(() {
      // Find the translation in the list and create a new copy with updated favorite status
      final index = _allTranslations.indexWhere((t) => t.id == translation.id);
      if (index != -1) {
        _allTranslations[index] =
            translation.copyWith(isFavorite: !translation.isFavorite);
      }
    });
    _applyFilters(); // Refresh the list to reflect changes
    // TODO: Update in history service
  }

  void _translateAgain(TranslationEntry translation) {
    // TODO: Navigate to appropriate translation screen with pre-filled content
    HapticFeedback.lightImpact();
  }
}
