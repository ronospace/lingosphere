// 👁️ LingoSphere - Multi-Modal Vision Analysis Widget
// UI component for displaying image analysis and contextual translation enhancements

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/models/vision_ai_models.dart';

class MultiModalVisionWidget extends StatefulWidget {
  final VisionAnalysisResult? analysisResult;
  final ContextEnhancedTranslation? enhancedTranslation;
  final bool isLoading;
  final VoidCallback? onRefresh;
  final VoidCallback? onAnalyzeImage;
  final Function(String)? onTranslationSelected;

  const MultiModalVisionWidget({
    super.key,
    this.analysisResult,
    this.enhancedTranslation,
    this.isLoading = false,
    this.onRefresh,
    this.onAnalyzeImage,
    this.onTranslationSelected,
  });

  @override
  State<MultiModalVisionWidget> createState() => _MultiModalVisionWidgetState();
}

class _MultiModalVisionWidgetState extends State<MultiModalVisionWidget>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedTab = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _selectedTab = _tabController.index;
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildHeader(),
          if (widget.isLoading) _buildLoadingIndicator(),
          if (!widget.isLoading && widget.analysisResult != null) ...[
            _buildTabBar(),
            Expanded(child: _buildTabContent()),
          ],
          if (!widget.isLoading && widget.analysisResult == null)
            _buildEmptyState(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.visibility,
            color: Theme.of(context).colorScheme.onPrimaryContainer,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '👁️ Multi-Modal Vision Analysis',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
            ),
          ),
          if (widget.onRefresh != null)
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: widget.onRefresh,
              tooltip: 'Refresh Analysis',
            ),
          if (widget.onAnalyzeImage != null)
            IconButton(
              icon: const Icon(Icons.add_a_photo),
              onPressed: widget.onAnalyzeImage,
              tooltip: 'Analyze New Image',
            ),
        ],
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return Container(
      height: 200,
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text(
              '🔍 Analyzing image context...',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 8),
            Text(
              'Using GPT-4 Vision + Google Vision APIs',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      color: Theme.of(context).colorScheme.surface,
      child: TabBar(
        controller: _tabController,
        tabs: const [
          Tab(
            icon: Icon(Icons.text_fields),
            text: 'Text & Objects',
          ),
          Tab(
            icon: Icon(Icons.translate),
            text: 'Enhanced Translation',
          ),
          Tab(
            icon: Icon(Icons.insights),
            text: 'Cultural Context',
          ),
          Tab(
            icon: Icon(Icons.analytics),
            text: 'Analysis Stats',
          ),
        ],
        indicatorColor: Theme.of(context).colorScheme.primary,
        labelColor: Theme.of(context).colorScheme.primary,
        unselectedLabelColor:
            Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
      ),
    );
  }

  Widget _buildTabContent() {
    return TabBarView(
      controller: _tabController,
      children: [
        _buildTextAndObjectsTab(),
        _buildEnhancedTranslationTab(),
        _buildCulturalContextTab(),
        _buildAnalysisStatsTab(),
      ],
    );
  }

  Widget _buildTextAndObjectsTab() {
    final result = widget.analysisResult!;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSceneDescription(result.sceneDescription),
          const SizedBox(height: 24),
          if (result.detectedText.isNotEmpty) ...[
            _buildDetectedTextSection(result.detectedText),
            const SizedBox(height: 24),
          ],
          if (result.detectedObjects.isNotEmpty)
            _buildDetectedObjectsSection(result.detectedObjects),
        ],
      ),
    );
  }

  Widget _buildEnhancedTranslationTab() {
    final enhanced = widget.enhancedTranslation;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (enhanced != null) ...[
            _buildTranslationComparison(enhanced),
            const SizedBox(height: 24),
            _buildImprovementsList(enhanced.improvements),
          ] else
            _buildNoEnhancementMessage(),
        ],
      ),
    );
  }

  Widget _buildCulturalContextTab() {
    final result = widget.analysisResult!;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (result.culturalMarkers.isNotEmpty) ...[
            _buildCulturalMarkersSection(result.culturalMarkers),
            const SizedBox(height: 24),
          ],
          if (result.contextualInsights.isNotEmpty) ...[
            _buildContextualInsightsSection(result.contextualInsights),
            const SizedBox(height: 24),
          ],
          if (result.translationSuggestions.isNotEmpty)
            _buildTranslationSuggestionsSection(result.translationSuggestions),
        ],
      ),
    );
  }

  Widget _buildAnalysisStatsTab() {
    final result = widget.analysisResult!;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildConfidenceMetrics(result),
          const SizedBox(height: 24),
          _buildProcessingInfo(result),
          const SizedBox(height: 24),
          _buildLanguageInfo(result),
        ],
      ),
    );
  }

  Widget _buildSceneDescription(String description) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.landscape,
                color: Theme.of(context).colorScheme.onSecondaryContainer,
              ),
              const SizedBox(width: 8),
              Text(
                'Scene Description',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSecondaryContainer,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            description,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ],
      ),
    );
  }

  Widget _buildDetectedTextSection(List<DetectedText> texts) {
    return _buildSection(
      title: 'Detected Text',
      icon: Icons.text_fields,
      child: Column(
        children: texts.map((text) => _buildTextCard(text)).toList(),
      ),
    );
  }

  Widget _buildTextCard(DetectedText text) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          child: Text(
            '${(text.confidence * 100).toInt()}%',
            style: TextStyle(
              fontSize: 10,
              color: Theme.of(context).colorScheme.onPrimaryContainer,
            ),
          ),
        ),
        title: SelectableText(text.text),
        subtitle:
            text.language != null ? Text('Language: ${text.language}') : null,
        trailing: IconButton(
          icon: const Icon(Icons.copy),
          onPressed: () {
            Clipboard.setData(ClipboardData(text: text.text));
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Text copied to clipboard')),
            );
          },
        ),
      ),
    );
  }

  Widget _buildDetectedObjectsSection(List<DetectedObject> objects) {
    return _buildSection(
      title: 'Detected Objects',
      icon: Icons.category,
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: objects.map((obj) => _buildObjectChip(obj)).toList(),
      ),
    );
  }

  Widget _buildObjectChip(DetectedObject object) {
    return Chip(
      label: Text(object.name),
      avatar: CircleAvatar(
        radius: 12,
        backgroundColor: Theme.of(context).colorScheme.primary,
        child: Text(
          '${(object.confidence * 100).toInt()}%',
          style: TextStyle(
            fontSize: 8,
            color: Theme.of(context).colorScheme.onPrimary,
          ),
        ),
      ),
      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
    );
  }

  Widget _buildTranslationComparison(ContextEnhancedTranslation enhanced) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Translation Comparison',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 16),

        // Original Text
        _buildTranslationCard(
          title: 'Original Text',
          content: enhanced.originalText,
          color: Theme.of(context).colorScheme.surfaceVariant,
        ),

        const SizedBox(height: 12),

        // Base Translation
        _buildTranslationCard(
          title: 'Base Translation',
          content: enhanced.baseTranslation,
          color: Theme.of(context).colorScheme.secondaryContainer,
          onSelect: () =>
              widget.onTranslationSelected?.call(enhanced.baseTranslation),
        ),

        const SizedBox(height: 12),

        // Enhanced Translation
        _buildTranslationCard(
          title: '✨ Enhanced Translation',
          content: enhanced.enhancedTranslation,
          color: Theme.of(context).colorScheme.primaryContainer,
          isEnhanced: true,
          onSelect: () =>
              widget.onTranslationSelected?.call(enhanced.enhancedTranslation),
        ),

        const SizedBox(height: 16),

        // Quality Metrics
        Row(
          children: [
            _buildMetricChip(
              'Confidence',
              '${(enhanced.confidence * 100).toInt()}%',
              Colors.blue,
            ),
            const SizedBox(width: 8),
            _buildMetricChip(
              'Context Relevance',
              '${(enhanced.contextRelevance * 100).toInt()}%',
              Colors.green,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTranslationCard({
    required String title,
    required String content,
    required Color color,
    bool isEnhanced = false,
    VoidCallback? onSelect,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
        border: isEnhanced
            ? Border.all(color: Theme.of(context).colorScheme.primary, width: 2)
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
              if (onSelect != null) ...[
                TextButton.icon(
                  onPressed: onSelect,
                  icon: const Icon(Icons.check, size: 16),
                  label: const Text('Use This'),
                  style: TextButton.styleFrom(
                    textStyle: const TextStyle(fontSize: 12),
                  ),
                ),
              ],
              IconButton(
                icon: const Icon(Icons.copy, size: 20),
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: content));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Translation copied to clipboard')),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 8),
          SelectableText(
            content,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ],
      ),
    );
  }

  Widget _buildImprovementsList(List<String> improvements) {
    if (improvements.isEmpty) return const SizedBox.shrink();

    return _buildSection(
      title: 'Contextual Improvements',
      icon: Icons.auto_fix_high,
      child: Column(
        children: improvements
            .map((improvement) => _buildImprovementItem(improvement))
            .toList(),
      ),
    );
  }

  Widget _buildImprovementItem(String improvement) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 6),
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              improvement,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoEnhancementMessage() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.translate,
            size: 64,
            color: Theme.of(context).colorScheme.outline,
          ),
          const SizedBox(height: 16),
          Text(
            'No Enhanced Translation Available',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'Enhanced translations appear here when visual context\nsignificantly improves translation quality.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  Widget _buildCulturalMarkersSection(List<String> markers) {
    return _buildSection(
      title: 'Cultural Markers',
      icon: Icons.public,
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: markers
            .map((marker) => Chip(
                  label: Text(marker),
                  backgroundColor:
                      Theme.of(context).colorScheme.tertiaryContainer,
                ))
            .toList(),
      ),
    );
  }

  Widget _buildContextualInsightsSection(List<String> insights) {
    return _buildSection(
      title: 'Contextual Insights',
      icon: Icons.lightbulb,
      child: Column(
        children:
            insights.map((insight) => _buildInsightItem(insight)).toList(),
      ),
    );
  }

  Widget _buildInsightItem(String insight) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.arrow_forward,
            size: 16,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              insight,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTranslationSuggestionsSection(List<String> suggestions) {
    return _buildSection(
      title: 'Translation Suggestions',
      icon: Icons.tips_and_updates,
      child: Column(
        children: suggestions
            .map((suggestion) => _buildSuggestionCard(suggestion))
            .toList(),
      ),
    );
  }

  Widget _buildSuggestionCard(String suggestion) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Icon(
              Icons.lightbulb_outline,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                suggestion,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConfidenceMetrics(VisionAnalysisResult result) {
    return _buildSection(
      title: 'Analysis Quality',
      icon: Icons.analytics,
      child: Column(
        children: [
          _buildProgressMetric(
            'Overall Confidence',
            result.confidence,
            Colors.blue,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Detected Text',
                  result.detectedText.length.toString(),
                  Icons.text_fields,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'Detected Objects',
                  result.detectedObjects.length.toString(),
                  Icons.category,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProgressMetric(String label, double value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: Theme.of(context).textTheme.bodyMedium),
            Text('${(value * 100).toInt()}%',
                style: Theme.of(context).textTheme.bodyMedium),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: value,
          backgroundColor: color.withValues(alpha: 0.2),
          valueColor: AlwaysStoppedAnimation<Color>(color),
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: Theme.of(context).colorScheme.onSurfaceVariant),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildProcessingInfo(VisionAnalysisResult result) {
    return _buildSection(
      title: 'Processing Information',
      icon: Icons.info,
      child: Column(
        children: [
          _buildInfoRow('Image Path', result.imagePath),
          _buildInfoRow('Source Language', result.sourceLanguage),
          _buildInfoRow('Target Language', result.targetLanguage),
          _buildInfoRow(
              'Processing Time', _formatDateTime(result.processingTime)),
        ],
      ),
    );
  }

  Widget _buildLanguageInfo(VisionAnalysisResult result) {
    final languages = result.detectedText
        .map((text) => text.language)
        .where((lang) => lang != null)
        .toSet()
        .toList();

    if (languages.isEmpty) return const SizedBox.shrink();

    return _buildSection(
      title: 'Detected Languages',
      icon: Icons.language,
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: languages
            .map((lang) => Chip(
                  label: Text(lang!),
                  backgroundColor:
                      Theme.of(context).colorScheme.primaryContainer,
                ))
            .toList(),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
          Expanded(
            child: SelectableText(
              value,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 20),
            const SizedBox(width: 8),
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        child,
      ],
    );
  }

  Widget _buildMetricChip(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color.withValues(alpha: 0.8),
            ),
          ),
          const SizedBox(width: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      height: 300,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add_a_photo,
              size: 64,
              color: Theme.of(context).colorScheme.outline,
            ),
            const SizedBox(height: 16),
            Text(
              'No Vision Analysis Available',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Upload an image to see multi-modal\nvision analysis and enhanced translations.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            if (widget.onAnalyzeImage != null)
              ElevatedButton.icon(
                onPressed: widget.onAnalyzeImage,
                icon: const Icon(Icons.upload),
                label: const Text('Upload Image'),
              ),
          ],
        ),
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')} '
        '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
