// 🧠 LingoSphere - Neural Conversation Insights Widget
// UI component for displaying advanced neural conversation intelligence

import 'package:flutter/material.dart';
import '../../core/models/neural_conversation_models.dart';

/// Widget to display neural conversation insights with visual feedback
class NeuralConversationInsightsWidget extends StatelessWidget {
  final NeuralConversationContext? context;
  final bool isLoading;
  final VoidCallback? onRefresh;

  const NeuralConversationInsightsWidget({
    super.key,
    this.context,
    this.isLoading = false,
    this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (this.context == null) {
      return _buildEmptyState();
    }

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 16),
            _buildConversationStatus(),
            const SizedBox(height: 16),
            _buildEmotionalInsights(),
            const SizedBox(height: 16),
            _buildQualityMetrics(),
            const SizedBox(height: 16),
            _buildTopicEvolution(),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.psychology,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No Neural Insights Available',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Start a conversation to see advanced AI analysis',
              style: TextStyle(
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Row(
          children: [
            Icon(Icons.psychology, color: Colors.blue),
            SizedBox(width: 8),
            Text(
              'Neural Conversation Insights',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        if (onRefresh != null)
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: onRefresh,
            tooltip: 'Refresh Insights',
          ),
      ],
    );
  }

  Widget _buildConversationStatus() {
    final conversationContext = context!;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _getPhaseColor(conversationContext.currentState.phase)
            .withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: _getPhaseColor(conversationContext.currentState.phase),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            _getPhaseIcon(conversationContext.currentState.phase),
            color: _getPhaseColor(conversationContext.currentState.phase),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Conversation Phase: ${_getPhaseLabel(conversationContext.currentState.phase)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${conversationContext.conversationLength} turns • ${conversationContext.currentState.mode.name} mode',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          _buildEngagementIndicator(
              conversationContext.currentState.engagement),
        ],
      ),
    );
  }

  Widget _buildEngagementIndicator(double engagement) {
    final color = engagement >= 0.7
        ? Colors.green
        : engagement >= 0.4
            ? Colors.orange
            : Colors.red;

    return Column(
      children: [
        Icon(Icons.favorite, color: color, size: 16),
        const SizedBox(height: 2),
        Text(
          '${(engagement * 100).round()}%',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildEmotionalInsights() {
    final emotionalFlow = context!.emotionalFlow;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.purple.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.mood, color: Colors.purple),
              SizedBox(width: 8),
              Text(
                'Emotional Analysis',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: Colors.purple,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildEmotionCard(
                  'Current Mood',
                  _getMoodLabel(emotionalFlow.overallMood),
                  _getMoodIcon(emotionalFlow.overallMood),
                  _getMoodColor(emotionalFlow.overallMood),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildEmotionCard(
                  'Stability',
                  '${((1 - emotionalFlow.emotionalVolatility) * 100).round()}%',
                  Icons.timeline,
                  emotionalFlow.emotionalVolatility < 0.3
                      ? Colors.green
                      : emotionalFlow.emotionalVolatility < 0.6
                          ? Colors.orange
                          : Colors.red,
                ),
              ),
            ],
          ),
          if (emotionalFlow.milestones.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              'Recent Milestones: ${emotionalFlow.milestones.length}',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEmotionCard(
      String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: color,
              fontSize: 14,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQualityMetrics() {
    final metrics = context!.metrics;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.green.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.analytics, color: Colors.green),
              SizedBox(width: 8),
              Text(
                'Quality Metrics',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: Colors.green,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildMetricBar(
                  'Coherence',
                  metrics.coherenceScore,
                  Colors.blue,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildMetricBar(
                  'Translation Quality',
                  metrics.translationQuality,
                  Colors.purple,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildMetricBar(
                  'Cultural Adaptation',
                  metrics.culturalAdaptation,
                  Colors.orange,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildOverallScoreCard(metrics.overallScore),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricBar(String label, double value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              '${(value * 100).round()}%',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        LinearProgressIndicator(
          value: value,
          backgroundColor: color.withValues(alpha: 0.2),
          valueColor: AlwaysStoppedAnimation<Color>(color),
        ),
      ],
    );
  }

  Widget _buildOverallScoreCard(double score) {
    final color = score >= 0.8
        ? Colors.green
        : score >= 0.6
            ? Colors.orange
            : Colors.red;

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Text(
            'Overall',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
          Text(
            '${(score * 100).round()}%',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopicEvolution() {
    final topics = context!.topicEvolution;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.teal.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.topic, color: Colors.teal),
              SizedBox(width: 8),
              Text(
                'Topic Evolution',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: Colors.teal,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (topics.currentTopics.isNotEmpty) ...[
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: topics.currentTopics.map((topic) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.teal.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.teal.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Text(
                    topic,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.teal,
                    ),
                  ),
                );
              }).toList(),
            ),
          ] else ...[
            Text(
              'No active topics detected',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
            ),
          ],
          if (topics.topicHistory.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              '${topics.topicHistory.length} topic transitions',
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey[500],
              ),
            ),
          ],
        ],
      ),
    );
  }

  // Helper methods for styling
  Color _getPhaseColor(ConversationPhase phase) {
    switch (phase) {
      case ConversationPhase.opening:
        return Colors.green;
      case ConversationPhase.building:
        return Colors.blue;
      case ConversationPhase.peak:
        return Colors.orange;
      case ConversationPhase.resolution:
        return Colors.purple;
      case ConversationPhase.closing:
        return Colors.grey;
    }
  }

  IconData _getPhaseIcon(ConversationPhase phase) {
    switch (phase) {
      case ConversationPhase.opening:
        return Icons.play_arrow;
      case ConversationPhase.building:
        return Icons.trending_up;
      case ConversationPhase.peak:
        return Icons.whatshot;
      case ConversationPhase.resolution:
        return Icons.check_circle;
      case ConversationPhase.closing:
        return Icons.stop;
    }
  }

  String _getPhaseLabel(ConversationPhase phase) {
    switch (phase) {
      case ConversationPhase.opening:
        return 'Opening';
      case ConversationPhase.building:
        return 'Building';
      case ConversationPhase.peak:
        return 'Peak';
      case ConversationPhase.resolution:
        return 'Resolution';
      case ConversationPhase.closing:
        return 'Closing';
    }
  }

  String _getMoodLabel(ConversationMood mood) {
    switch (mood) {
      case ConversationMood.collaborative:
        return 'Collaborative';
      case ConversationMood.tense:
        return 'Tense';
      case ConversationMood.friendly:
        return 'Friendly';
      case ConversationMood.professional:
        return 'Professional';
      case ConversationMood.emotional:
        return 'Emotional';
      case ConversationMood.analytical:
        return 'Analytical';
    }
  }

  IconData _getMoodIcon(ConversationMood mood) {
    switch (mood) {
      case ConversationMood.collaborative:
        return Icons.handshake;
      case ConversationMood.tense:
        return Icons.warning;
      case ConversationMood.friendly:
        return Icons.sentiment_very_satisfied;
      case ConversationMood.professional:
        return Icons.business;
      case ConversationMood.emotional:
        return Icons.favorite;
      case ConversationMood.analytical:
        return Icons.analytics;
    }
  }

  Color _getMoodColor(ConversationMood mood) {
    switch (mood) {
      case ConversationMood.collaborative:
        return Colors.green;
      case ConversationMood.tense:
        return Colors.red;
      case ConversationMood.friendly:
        return Colors.blue;
      case ConversationMood.professional:
        return Colors.indigo;
      case ConversationMood.emotional:
        return Colors.pink;
      case ConversationMood.analytical:
        return Colors.teal;
    }
  }
}
