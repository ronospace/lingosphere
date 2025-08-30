// 🌐 LingoSphere - Translation History Screen
// Complete history management with search, filters, and organization

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../../../shared/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';

class TranslationHistoryScreen extends ConsumerStatefulWidget {
  const TranslationHistoryScreen({super.key});

  @override
  ConsumerState<TranslationHistoryScreen> createState() => _TranslationHistoryScreenState();
}

class _TranslationHistoryScreenState extends ConsumerState<TranslationHistoryScreen>
    with TickerProviderStateMixin {
  late TextEditingController _searchController;
  late AnimationController _filterAnimationController;
  late TabController _tabController;
  
  String _selectedFilter = 'all';
  String _selectedSort = 'recent';
  bool _showFilters = false;
  bool _isSelectionMode = false;
  Set<String> _selectedItems = {};

  final List<HistoryTranslation> _allTranslations = [
    HistoryTranslation(
      id: '1',
      originalText: 'Hello, how are you?',
      translatedText: 'Hola, ¿cómo estás?',
      sourceLanguage: 'en',
      targetLanguage: 'es',
      timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
      confidence: 0.95,
      isFavorite: true,
      tags: ['greeting', 'casual'],
    ),
    HistoryTranslation(
      id: '2',
      originalText: 'Where is the nearest restaurant?',
      translatedText: '最寄りのレストランはどこですか？',
      sourceLanguage: 'en',
      targetLanguage: 'ja',
      timestamp: DateTime.now().subtract(const Duration(hours: 2)),
      confidence: 0.92,
      isFavorite: false,
      tags: ['travel', 'food'],
    ),
    HistoryTranslation(
      id: '3',
      originalText: 'Je voudrais réserver une table',
      translatedText: 'I would like to book a table',
      sourceLanguage: 'fr',
      targetLanguage: 'en',
      timestamp: DateTime.now().subtract(const Duration(days: 1)),
      confidence: 0.98,
      isFavorite: true,
      tags: ['restaurant', 'formal'],
    ),
    HistoryTranslation(
      id: '4',
      originalText: 'Good morning, team',
      translatedText: 'Guten Morgen, Team',
      sourceLanguage: 'en',
      targetLanguage: 'de',
      timestamp: DateTime.now().subtract(const Duration(days: 2)),
      confidence: 0.89,
      isFavorite: false,
      tags: ['business', 'greeting'],
    ),
  ];

  List<HistoryTranslation> get _filteredTranslations {
    var filtered = _allTranslations.where((translation) {
      // Text search
      if (_searchController.text.isNotEmpty) {
        final query = _searchController.text.toLowerCase();
        if (!translation.originalText.toLowerCase().contains(query) &&
            !translation.translatedText.toLowerCase().contains(query)) {
          return false;
        }
      }

      // Filter by type
      switch (_selectedFilter) {
        case 'favorites':
          return translation.isFavorite;
        case 'recent':
          return translation.timestamp.isAfter(DateTime.now().subtract(const Duration(days: 7)));
        case 'confident':
          return translation.confidence >= 0.9;
        default:
          return true;
      }
    }).toList();

    // Sort
    switch (_selectedSort) {
      case 'recent':
        filtered.sort((a, b) => b.timestamp.compareTo(a.timestamp));
        break;
      case 'oldest':
        filtered.sort((a, b) => a.timestamp.compareTo(b.timestamp));
        break;
      case 'confidence':
        filtered.sort((a, b) => b.confidence.compareTo(a.confidence));
        break;
      case 'alphabetical':
        filtered.sort((a, b) => a.originalText.compareTo(b.originalText));
        break;
    }

    return filtered;
  }

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _filterAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _tabController = TabController(length: 2, vsync: this);
    _searchController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _searchController.dispose();
    _filterAnimationController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.gray50,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildSearchBar(),
          _buildFilterBar(),
          Expanded(child: _buildContent()),
        ],
      ),
      floatingActionButton: _isSelectionMode ? null : _buildFAB(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Text(
        _isSelectionMode ? '${_selectedItems.length} selected' : 'Translation History',
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          color: AppTheme.primaryBlue,
        ),
      ),
      backgroundColor: AppTheme.white,
      elevation: 0,
      systemOverlayStyle: SystemUiOverlayStyle.dark,
      actions: [
        if (_isSelectionMode) ...[
          IconButton(
            icon: const Icon(Icons.favorite_border),
            onPressed: _toggleFavoriteSelected,
            tooltip: 'Add to Favorites',
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: _deleteSelected,
            tooltip: 'Delete Selected',
          ),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: _exitSelectionMode,
            tooltip: 'Cancel',
          ),
        ] else ...[
          IconButton(
            icon: Icon(_showFilters ? Icons.filter_list_off : Icons.filter_list),
            onPressed: _toggleFilters,
            tooltip: 'Filters',
          ),
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: _showMoreOptions,
          ),
        ],
      ],
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: AppTheme.white,
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search translations...',
          prefixIcon: const Icon(Icons.search, color: AppTheme.gray500),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, color: AppTheme.gray500),
                  onPressed: () {
                    _searchController.clear();
                    setState(() {});
                  },
                )
              : null,
          filled: true,
          fillColor: AppTheme.gray50,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _buildFilterBar() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      height: _showFilters ? 120 : 0,
      child: Container(
        color: AppTheme.white,
        child: _showFilters
            ? Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    const Divider(height: 1),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        const Text('Filter:', style: TextStyle(fontWeight: FontWeight.w600)),
                        const SizedBox(width: 16),
                        Expanded(child: _buildFilterChips()),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Text('Sort:', style: TextStyle(fontWeight: FontWeight.w600)),
                        const SizedBox(width: 16),
                        Expanded(child: _buildSortChips()),
                      ],
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              )
            : null,
      ),
    );
  }

  Widget _buildFilterChips() {
    final filters = [
      ('all', 'All'),
      ('favorites', 'Favorites'),
      ('recent', 'Recent'),
      ('confident', 'High Quality'),
    ];

    return Wrap(
      spacing: 8,
      children: filters.map((filter) {
        final isSelected = _selectedFilter == filter.$1;
        return FilterChip(
          label: Text(filter.$2),
          selected: isSelected,
          onSelected: (_) => setState(() => _selectedFilter = filter.$1),
          backgroundColor: AppTheme.gray100,
          selectedColor: AppTheme.primaryBlue.withOpacity(0.1),
          checkmarkColor: AppTheme.primaryBlue,
        );
      }).toList(),
    );
  }

  Widget _buildSortChips() {
    final sorts = [
      ('recent', 'Recent'),
      ('oldest', 'Oldest'),
      ('confidence', 'Quality'),
      ('alphabetical', 'A-Z'),
    ];

    return Wrap(
      spacing: 8,
      children: sorts.map((sort) {
        final isSelected = _selectedSort == sort.$1;
        return FilterChip(
          label: Text(sort.$2),
          selected: isSelected,
          onSelected: (_) => setState(() => _selectedSort = sort.$1),
          backgroundColor: AppTheme.gray100,
          selectedColor: AppTheme.accentTeal.withOpacity(0.1),
          checkmarkColor: AppTheme.accentTeal,
        );
      }).toList(),
    );
  }

  Widget _buildContent() {
    return TabBarView(
      controller: _tabController,
      children: [
        _buildHistoryList(),
        _buildFavoritesList(),
      ],
    );
  }

  Widget _buildHistoryList() {
    final translations = _filteredTranslations;

    if (translations.isEmpty) {
      return _buildEmptyState();
    }

    return AnimationLimiter(
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: translations.length,
        itemBuilder: (context, index) {
          return AnimationConfiguration.staggeredList(
            position: index,
            duration: const Duration(milliseconds: 375),
            child: SlideAnimation(
              verticalOffset: 50.0,
              child: FadeInAnimation(
                child: _buildHistoryCard(translations[index]),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFavoritesList() {
    final favorites = _allTranslations.where((t) => t.isFavorite).toList();

    if (favorites.isEmpty) {
      return _buildEmptyFavoritesState();
    }

    return AnimationLimiter(
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: favorites.length,
        itemBuilder: (context, index) {
          return AnimationConfiguration.staggeredList(
            position: index,
            duration: const Duration(milliseconds: 375),
            child: SlideAnimation(
              verticalOffset: 50.0,
              child: FadeInAnimation(
                child: _buildHistoryCard(favorites[index]),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHistoryCard(HistoryTranslation translation) {
    final isSelected = _selectedItems.contains(translation.id);
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: isSelected ? 4 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isSelected ? const BorderSide(color: AppTheme.primaryBlue, width: 2) : BorderSide.none,
      ),
      child: InkWell(
        onTap: () => _isSelectionMode ? _toggleSelection(translation.id) : _openTranslation(translation),
        onLongPress: () => _enterSelectionMode(translation.id),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryBlue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${AppConstants.supportedLanguages[translation.sourceLanguage]?.substring(0, 2).toUpperCase() ?? translation.sourceLanguage.toUpperCase()} → ${AppConstants.supportedLanguages[translation.targetLanguage]?.substring(0, 2).toUpperCase() ?? translation.targetLanguage.toUpperCase()}',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.primaryBlue,
                      ),
                    ),
                  ),
                  const Spacer(),
                  if (translation.isFavorite)
                    const Icon(Icons.favorite, color: AppTheme.errorRed, size: 16),
                  const SizedBox(width: 8),
                  Text(
                    _formatTimestamp(translation.timestamp),
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppTheme.gray500,
                    ),
                  ),
                  if (_isSelectionMode) ...[
                    const SizedBox(width: 12),
                    Icon(
                      isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
                      color: isSelected ? AppTheme.primaryBlue : AppTheme.gray400,
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 12),
              Text(
                translation.originalText,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppTheme.gray700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                translation.translatedText,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.gray900,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    Icons.verified,
                    size: 16,
                    color: _getConfidenceColor(translation.confidence),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${(translation.confidence * 100).toInt()}%',
                    style: TextStyle(
                      fontSize: 12,
                      color: _getConfidenceColor(translation.confidence),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Spacer(),
                  Row(
                    children: [
                      _buildActionButton(
                        Icons.copy,
                        'Copy',
                        () => _copyTranslation(translation.translatedText),
                      ),
                      const SizedBox(width: 8),
                      _buildActionButton(
                        Icons.share,
                        'Share',
                        () => _shareTranslation(translation),
                      ),
                      const SizedBox(width: 8),
                      _buildActionButton(
                        translation.isFavorite ? Icons.favorite : Icons.favorite_border,
                        translation.isFavorite ? 'Unfavorite' : 'Favorite',
                        () => _toggleFavorite(translation.id),
                      ),
                    ],
                  ),
                ],
              ),
              if (translation.tags.isNotEmpty) ...[
                const SizedBox(height: 8),
                Wrap(
                  spacing: 4,
                  children: translation.tags.map((tag) => Chip(
                    label: Text(
                      tag,
                      style: const TextStyle(fontSize: 10),
                    ),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    backgroundColor: AppTheme.gray100,
                    side: BorderSide.none,
                  )).toList(),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton(IconData icon, String tooltip, VoidCallback onPressed) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(6),
        child: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: AppTheme.gray100,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(icon, size: 16, color: AppTheme.gray600),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.translate,
            size: 64,
            color: AppTheme.gray400,
          ),
          const SizedBox(height: 16),
          const Text(
            'No translations found',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: AppTheme.gray700,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Your translation history will appear here',
            style: TextStyle(
              color: AppTheme.gray500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyFavoritesState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.favorite_border,
            size: 64,
            color: AppTheme.gray400,
          ),
          const SizedBox(height: 16),
          const Text(
            'No favorites yet',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: AppTheme.gray700,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Tap the heart icon to save translations',
            style: TextStyle(
              color: AppTheme.gray500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFAB() {
    return FloatingActionButton.extended(
      onPressed: _exportHistory,
      icon: const Icon(Icons.download),
      label: const Text('Export'),
      backgroundColor: AppTheme.vibrantGreen,
      foregroundColor: AppTheme.white,
    );
  }

  // Action methods
  void _toggleFilters() {
    setState(() => _showFilters = !_showFilters);
    if (_showFilters) {
      _filterAnimationController.forward();
    } else {
      _filterAnimationController.reverse();
    }
  }

  void _enterSelectionMode(String id) {
    setState(() {
      _isSelectionMode = true;
      _selectedItems.add(id);
    });
  }

  void _exitSelectionMode() {
    setState(() {
      _isSelectionMode = false;
      _selectedItems.clear();
    });
  }

  void _toggleSelection(String id) {
    setState(() {
      if (_selectedItems.contains(id)) {
        _selectedItems.remove(id);
      } else {
        _selectedItems.add(id);
      }

      if (_selectedItems.isEmpty) {
        _isSelectionMode = false;
      }
    });
  }

  void _toggleFavorite(String id) {
    setState(() {
      final translation = _allTranslations.firstWhere((t) => t.id == id);
      translation.isFavorite = !translation.isFavorite;
    });
  }

  void _toggleFavoriteSelected() {
    setState(() {
      for (final id in _selectedItems) {
        final translation = _allTranslations.firstWhere((t) => t.id == id);
        translation.isFavorite = true;
      }
    });
    _exitSelectionMode();
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Added to favorites'),
        backgroundColor: AppTheme.vibrantGreen,
      ),
    );
  }

  void _deleteSelected() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete translations'),
        content: Text('Delete ${_selectedItems.length} selected translations?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _allTranslations.removeWhere((t) => _selectedItems.contains(t.id));
              });
              _exitSelectionMode();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Translations deleted'),
                  backgroundColor: AppTheme.errorRed,
                ),
              );
            },
            child: const Text('Delete', style: TextStyle(color: AppTheme.errorRed)),
          ),
        ],
      ),
    );
  }

  void _copyTranslation(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Copied to clipboard'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  void _shareTranslation(HistoryTranslation translation) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Share feature coming soon!'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  void _openTranslation(HistoryTranslation translation) {
    Navigator.pushNamed(
      context,
      '/translation',
      arguments: {
        'initialText': translation.originalText,
        'sourceLanguage': translation.sourceLanguage,
        'targetLanguage': translation.targetLanguage,
      },
    );
  }

  void _exportHistory() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Export feature coming soon!'),
        backgroundColor: AppTheme.primaryBlue,
      ),
    );
  }

  void _showMoreOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.clear_all),
              title: const Text('Clear All History'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.backup),
              title: const Text('Backup to Cloud'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.import_export),
              title: const Text('Import from File'),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
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
      return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
    }
  }

  Color _getConfidenceColor(double confidence) {
    if (confidence >= 0.9) return AppTheme.successGreen;
    if (confidence >= 0.7) return AppTheme.warningAmber;
    return AppTheme.errorRed;
  }
}

class HistoryTranslation {
  final String id;
  final String originalText;
  final String translatedText;
  final String sourceLanguage;
  final String targetLanguage;
  final DateTime timestamp;
  final double confidence;
  bool isFavorite;
  final List<String> tags;

  HistoryTranslation({
    required this.id,
    required this.originalText,
    required this.translatedText,
    required this.sourceLanguage,
    required this.targetLanguage,
    required this.timestamp,
    required this.confidence,
    this.isFavorite = false,
    this.tags = const [],
  });
}
