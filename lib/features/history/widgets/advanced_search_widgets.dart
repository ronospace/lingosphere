// 🌐 LingoSphere - Advanced Search UI Components
// Search bars, filter chips, date pickers, and category selectors for translation history

import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../../../shared/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/services/history_service.dart';
import '../../../core/models/common_models.dart';

/// Advanced search bar with voice input and filters
class AdvancedSearchBar extends StatefulWidget {
  final String? initialQuery;
  final VoidCallback? onVoiceSearch;
  final ValueChanged<String> onQueryChanged;
  final VoidCallback? onFiltersPressed;
  final bool hasActiveFilters;
  final bool isLoading;

  const AdvancedSearchBar({
    super.key,
    this.initialQuery,
    this.onVoiceSearch,
    required this.onQueryChanged,
    this.onFiltersPressed,
    this.hasActiveFilters = false,
    this.isLoading = false,
  });

  @override
  State<AdvancedSearchBar> createState() => _AdvancedSearchBarState();
}

class _AdvancedSearchBarState extends State<AdvancedSearchBar>
    with TickerProviderStateMixin {
  late TextEditingController _controller;
  late AnimationController _loadingController;
  late Animation<double> _loadingAnimation;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialQuery);
    _loadingController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _loadingAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _loadingController, curve: Curves.easeInOut),
    );

    if (widget.isLoading) {
      _loadingController.repeat();
    }
  }

  @override
  void didUpdateWidget(AdvancedSearchBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isLoading != oldWidget.isLoading) {
      if (widget.isLoading) {
        _loadingController.repeat();
      } else {
        _loadingController.stop();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _loadingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.gray900,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _isExpanded ? AppTheme.vibrantGreen : AppTheme.gray700,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.black.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Search icon or loading indicator
                SizedBox(
                  width: 24,
                  height: 24,
                  child: widget.isLoading
                      ? RotationTransition(
                          turns: _loadingAnimation,
                          child: const Icon(
                            Icons.refresh,
                            color: AppTheme.vibrantGreen,
                            size: 20,
                          ),
                        )
                      : const Icon(
                          Icons.search,
                          color: AppTheme.gray400,
                          size: 20,
                        ),
                ),
                const SizedBox(width: 12),

                // Search input field
                Expanded(
                  child: TextField(
                    controller: _controller,
                    style: const TextStyle(
                      color: AppTheme.white,
                      fontSize: 16,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Search translations...',
                      hintStyle: TextStyle(
                        color: AppTheme.gray400,
                        fontSize: 16,
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                    ),
                    onChanged: widget.onQueryChanged,
                    onTap: () => setState(() => _isExpanded = true),
                    onEditingComplete: () =>
                        setState(() => _isExpanded = false),
                  ),
                ),

                // Voice search button
                if (widget.onVoiceSearch != null) ...[
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: widget.onVoiceSearch,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppTheme.vibrantGreen.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.mic,
                        color: AppTheme.vibrantGreen,
                        size: 18,
                      ),
                    ),
                  ),
                ],

                // Filters button
                if (widget.onFiltersPressed != null) ...[
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: widget.onFiltersPressed,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: widget.hasActiveFilters
                            ? AppTheme.vibrantGreen.withValues(alpha: 0.2)
                            : AppTheme.gray700.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Stack(
                        children: [
                          Icon(
                            Icons.tune,
                            color: widget.hasActiveFilters
                                ? AppTheme.vibrantGreen
                                : AppTheme.gray400,
                            size: 18,
                          ),
                          if (widget.hasActiveFilters)
                            Positioned(
                              right: 0,
                              top: 0,
                              child: Container(
                                width: 6,
                                height: 6,
                                decoration: const BoxDecoration(
                                  color: AppTheme.errorRed,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Filter chip for various filter options
class CustomFilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final IconData? icon;
  final Color? color;
  final String? count;

  const CustomFilterChip({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.icon,
    this.color,
    this.count,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(right: 8, bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? (color ?? AppTheme.vibrantGreen).withValues(alpha: 0.2)
              : AppTheme.gray800,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? (color ?? AppTheme.vibrantGreen)
                : AppTheme.gray600,
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 16,
                color: isSelected
                    ? (color ?? AppTheme.vibrantGreen)
                    : AppTheme.gray400,
              ),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: TextStyle(
                color: isSelected
                    ? (color ?? AppTheme.vibrantGreen)
                    : AppTheme.gray300,
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
            if (count != null) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: isSelected
                      ? (color ?? AppTheme.vibrantGreen)
                      : AppTheme.gray600,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  count!,
                  style: TextStyle(
                    color: isSelected ? AppTheme.white : AppTheme.gray300,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Language selector with search functionality
class LanguageSelector extends StatefulWidget {
  final List<String> selectedLanguages;
  final ValueChanged<List<String>> onSelectionChanged;
  final String title;

  const LanguageSelector({
    super.key,
    required this.selectedLanguages,
    required this.onSelectionChanged,
    this.title = 'Languages',
  });

  @override
  State<LanguageSelector> createState() => _LanguageSelectorState();
}

class _LanguageSelectorState extends State<LanguageSelector> {
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<MapEntry<String, String>> get _filteredLanguages {
    final languages = AppConstants.supportedLanguages.entries.toList();
    if (_searchQuery.isEmpty) return languages;

    return languages
        .where((entry) =>
            entry.value.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            entry.key.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 400,
      decoration: const BoxDecoration(
        color: AppTheme.gray900,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: AppTheme.gray700, width: 1),
              ),
            ),
            child: Row(
              children: [
                Text(
                  widget.title,
                  style: const TextStyle(
                    color: AppTheme.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                if (widget.selectedLanguages.isNotEmpty)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.vibrantGreen.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${widget.selectedLanguages.length} selected',
                      style: const TextStyle(
                        color: AppTheme.vibrantGreen,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                const SizedBox(width: 12),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close, color: AppTheme.white),
                ),
              ],
            ),
          ),

          // Search bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              style: const TextStyle(color: AppTheme.white),
              decoration: InputDecoration(
                hintText: 'Search languages...',
                hintStyle: TextStyle(color: AppTheme.gray400),
                prefixIcon: Icon(Icons.search, color: AppTheme.gray400),
                filled: true,
                fillColor: AppTheme.gray800,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (value) => setState(() => _searchQuery = value),
            ),
          ),

          // Language list
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _filteredLanguages.length,
              itemBuilder: (context, index) {
                final language = _filteredLanguages[index];
                final isSelected =
                    widget.selectedLanguages.contains(language.key);

                return CheckboxListTile(
                  value: isSelected,
                  onChanged: (selected) {
                    final newSelection =
                        List<String>.from(widget.selectedLanguages);
                    if (selected == true) {
                      newSelection.add(language.key);
                    } else {
                      newSelection.remove(language.key);
                    }
                    widget.onSelectionChanged(newSelection);
                  },
                  title: Text(
                    language.value,
                    style: const TextStyle(
                      color: AppTheme.white,
                      fontSize: 16,
                    ),
                  ),
                  subtitle: Text(
                    language.key.toUpperCase(),
                    style: TextStyle(
                      color: AppTheme.gray400,
                      fontSize: 12,
                    ),
                  ),
                  activeColor: AppTheme.vibrantGreen,
                  checkColor: AppTheme.white,
                  controlAffinity: ListTileControlAffinity.trailing,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// Date range picker for filtering by date
class DateRangePicker extends StatefulWidget {
  final DateRange? selectedRange;
  final ValueChanged<DateRange?> onRangeChanged;

  const DateRangePicker({
    super.key,
    this.selectedRange,
    required this.onRangeChanged,
  });

  @override
  State<DateRangePicker> createState() => _DateRangePickerState();
}

class _DateRangePickerState extends State<DateRangePicker> {
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void initState() {
    super.initState();
    _startDate = widget.selectedRange?.start;
    _endDate = widget.selectedRange?.end;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: AppTheme.gray900,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              const Text(
                'Select Date Range',
                style: TextStyle(
                  color: AppTheme.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close, color: AppTheme.white),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Quick selection buttons
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildQuickSelectButton('Today', () => _selectToday()),
              _buildQuickSelectButton('Yesterday', () => _selectYesterday()),
              _buildQuickSelectButton('Last 7 days', () => _selectLastDays(7)),
              _buildQuickSelectButton(
                  'Last 30 days', () => _selectLastDays(30)),
              _buildQuickSelectButton('This month', () => _selectThisMonth()),
              _buildQuickSelectButton('Clear', () => _clearSelection()),
            ],
          ),

          const SizedBox(height: 24),

          // Date selection
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'From',
                      style: TextStyle(
                        color: AppTheme.gray400,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: () => _selectStartDate(context),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppTheme.gray800,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppTheme.gray600),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.calendar_today,
                                color: AppTheme.gray400, size: 18),
                            const SizedBox(width: 8),
                            Text(
                              _startDate != null
                                  ? _formatDate(_startDate!)
                                  : 'Select date',
                              style: TextStyle(
                                color: _startDate != null
                                    ? AppTheme.white
                                    : AppTheme.gray400,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'To',
                      style: TextStyle(
                        color: AppTheme.gray400,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: () => _selectEndDate(context),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppTheme.gray800,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppTheme.gray600),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.calendar_today,
                                color: AppTheme.gray400, size: 18),
                            const SizedBox(width: 8),
                            Text(
                              _endDate != null
                                  ? _formatDate(_endDate!)
                                  : 'Select date',
                              style: TextStyle(
                                color: _endDate != null
                                    ? AppTheme.white
                                    : AppTheme.gray400,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Apply button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _startDate != null && _endDate != null
                  ? () {
                      widget.onRangeChanged(DateRange(
                        start: _startDate!,
                        end: _endDate!,
                      ));
                      Navigator.of(context).pop();
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.vibrantGreen,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Apply Date Range',
                style: TextStyle(
                  color: AppTheme.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),

          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildQuickSelectButton(String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: AppTheme.gray800,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppTheme.gray600),
        ),
        child: Text(
          label,
          style: const TextStyle(
            color: AppTheme.gray300,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  void _selectToday() {
    final now = DateTime.now();
    setState(() {
      _startDate = DateTime(now.year, now.month, now.day);
      _endDate = DateTime(now.year, now.month, now.day, 23, 59, 59);
    });
  }

  void _selectYesterday() {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    setState(() {
      _startDate = DateTime(yesterday.year, yesterday.month, yesterday.day);
      _endDate =
          DateTime(yesterday.year, yesterday.month, yesterday.day, 23, 59, 59);
    });
  }

  void _selectLastDays(int days) {
    final now = DateTime.now();
    final start = now.subtract(Duration(days: days - 1));
    setState(() {
      _startDate = DateTime(start.year, start.month, start.day);
      _endDate = DateTime(now.year, now.month, now.day, 23, 59, 59);
    });
  }

  void _selectThisMonth() {
    final now = DateTime.now();
    setState(() {
      _startDate = DateTime(now.year, now.month, 1);
      _endDate = DateTime(now.year, now.month + 1, 0, 23, 59, 59);
    });
  }

  void _clearSelection() {
    setState(() {
      _startDate = null;
      _endDate = null;
    });
    widget.onRangeChanged(null);
    Navigator.of(context).pop();
  }

  Future<void> _selectStartDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: ColorScheme.dark(
            primary: AppTheme.vibrantGreen,
            surface: AppTheme.gray800,
            onSurface: AppTheme.white,
          ),
        ),
        child: child!,
      ),
    );

    if (picked != null) {
      setState(() => _startDate = picked);
    }
  }

  Future<void> _selectEndDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _endDate ?? DateTime.now(),
      firstDate: _startDate ?? DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: ColorScheme.dark(
            primary: AppTheme.vibrantGreen,
            surface: AppTheme.gray800,
            onSurface: AppTheme.white,
          ),
        ),
        child: child!,
      ),
    );

    if (picked != null) {
      setState(() => _endDate =
          DateTime(picked.year, picked.month, picked.day, 23, 59, 59));
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

/// Confidence slider for filtering by confidence level
class ConfidenceSlider extends StatefulWidget {
  final RangeValues confidenceRange;
  final ValueChanged<RangeValues> onChanged;

  const ConfidenceSlider({
    super.key,
    required this.confidenceRange,
    required this.onChanged,
  });

  @override
  State<ConfidenceSlider> createState() => _ConfidenceSliderState();
}

class _ConfidenceSliderState extends State<ConfidenceSlider> {
  late RangeValues _currentValues;

  @override
  void initState() {
    super.initState();
    _currentValues = widget.confidenceRange;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Confidence Level',
          style: TextStyle(
            color: AppTheme.gray400,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Text(
              '${(_currentValues.start * 100).round()}%',
              style: const TextStyle(
                color: AppTheme.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            Expanded(
              child: RangeSlider(
                values: _currentValues,
                min: 0.0,
                max: 1.0,
                divisions: 100,
                activeColor: AppTheme.vibrantGreen,
                inactiveColor: AppTheme.gray600,
                onChanged: (values) {
                  setState(() => _currentValues = values);
                  widget.onChanged(values);
                },
                labels: RangeLabels(
                  '${(_currentValues.start * 100).round()}%',
                  '${(_currentValues.end * 100).round()}%',
                ),
              ),
            ),
            Text(
              '${(_currentValues.end * 100).round()}%',
              style: const TextStyle(
                color: AppTheme.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// Sort options selector
class SortSelector extends StatelessWidget {
  final HistorySortBy currentSort;
  final ValueChanged<HistorySortBy> onSortChanged;

  const SortSelector({
    super.key,
    required this.currentSort,
    required this.onSortChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: AppTheme.gray900,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              const Text(
                'Sort By',
                style: TextStyle(
                  color: AppTheme.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close, color: AppTheme.white),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Sort options
          ...HistorySortBy.values.map((sortBy) => _buildSortOption(sortBy)),
        ],
      ),
    );
  }

  Widget _buildSortOption(HistorySortBy sortBy) {
    final isSelected = currentSort == sortBy;

    return GestureDetector(
      onTap: () => onSortChanged(sortBy),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.vibrantGreen.withValues(alpha: 0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: isSelected ? Border.all(color: AppTheme.vibrantGreen) : null,
        ),
        child: Row(
          children: [
            Icon(
              _getSortIcon(sortBy),
              color: isSelected ? AppTheme.vibrantGreen : AppTheme.gray400,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                _getSortLabel(sortBy),
                style: TextStyle(
                  color: isSelected ? AppTheme.vibrantGreen : AppTheme.white,
                  fontSize: 16,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check,
                color: AppTheme.vibrantGreen,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }

  IconData _getSortIcon(HistorySortBy sortBy) {
    switch (sortBy) {
      case HistorySortBy.dateAsc:
        return Icons.arrow_upward;
      case HistorySortBy.dateDesc:
        return Icons.arrow_downward;
      case HistorySortBy.confidenceAsc:
        return Icons.trending_up;
      case HistorySortBy.confidenceDesc:
        return Icons.trending_down;
      case HistorySortBy.alphabetical:
        return Icons.sort_by_alpha;
      case HistorySortBy.source:
        return Icons.category;
    }
  }

  String _getSortLabel(HistorySortBy sortBy) {
    switch (sortBy) {
      case HistorySortBy.dateAsc:
        return 'Date (Oldest first)';
      case HistorySortBy.dateDesc:
        return 'Date (Newest first)';
      case HistorySortBy.confidenceAsc:
        return 'Confidence (Low to High)';
      case HistorySortBy.confidenceDesc:
        return 'Confidence (High to Low)';
      case HistorySortBy.alphabetical:
        return 'Alphabetical';
      case HistorySortBy.source:
        return 'Translation Source';
    }
  }
}
