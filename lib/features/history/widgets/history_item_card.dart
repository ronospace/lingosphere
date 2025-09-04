// 🌐 LingoSphere - History Item Card Widget
// Individual card widget for displaying translation history entries

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../shared/theme/app_theme.dart';
import '../../../core/models/common_models.dart';
import '../../../core/services/history_service.dart';

/// Individual history item card widget
class HistoryItemCard extends StatelessWidget {
  final HistoryEntry item;
  final VoidCallback? onTap;
  final VoidCallback? onFavoriteToggle;
  final VoidCallback? onDelete;
  final VoidCallback? onEdit;
  final VoidCallback? onShare;
  final bool compact;

  const HistoryItemCard({
    super.key,
    required this.item,
    this.onTap,
    this.onFavoriteToggle,
    this.onDelete,
    this.onEdit,
    this.onShare,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: compact ? 8 : 12),
      decoration: BoxDecoration(
        color: AppTheme.gray900,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: item.isFavorite
              ? AppTheme.vibrantGreen.withValues(alpha: 0.3)
              : AppTheme.gray700,
          width: item.isFavorite ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.black.withValues(alpha: 0.2),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(compact ? 12 : 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row with metadata
              _buildHeader(),

              if (!compact) ...[
                const SizedBox(height: 12),

                // Original text
                _buildTextSection(
                  'Original',
                  item.originalText,
                  item.sourceLanguage,
                ),

                const SizedBox(height: 8),

                // Translation
                _buildTextSection(
                  'Translation',
                  item.translatedText,
                  item.targetLanguage,
                  isTranslation: true,
                ),
              ] else ...[
                const SizedBox(height: 8),
                _buildCompactContent(),
              ],

              if (!compact) ...[
                const SizedBox(height: 12),

                // Footer with actions
                _buildFooter(),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        // Language indicators
        _buildLanguageBadge(item.sourceLanguage, AppTheme.twitterBlue),
        const SizedBox(width: 8),
        Icon(
          Icons.arrow_forward,
          color: AppTheme.gray400,
          size: 16,
        ),
        const SizedBox(width: 8),
        _buildLanguageBadge(item.targetLanguage, AppTheme.vibrantGreen),

        const Spacer(),

        // Confidence indicator
        if (item.confidence > 0) ...[
          _buildConfidenceIndicator(),
          const SizedBox(width: 8),
        ],

        // Favorite toggle
        if (onFavoriteToggle != null)
          GestureDetector(
            onTap: onFavoriteToggle,
            child: Icon(
              item.isFavorite ? Icons.favorite : Icons.favorite_border,
              color: item.isFavorite ? AppTheme.errorRed : AppTheme.gray400,
              size: 20,
            ),
          ),

        // More options menu
        if (!compact) _buildMoreMenu(),
      ],
    );
  }

  Widget _buildLanguageBadge(String language, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Text(
        language.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildConfidenceIndicator() {
    Color color;
    IconData icon;

    if (item.confidence >= 0.8) {
      color = AppTheme.vibrantGreen;
      icon = Icons.verified;
    } else if (item.confidence >= 0.6) {
      color = AppTheme.vibrantOrange;
      icon = Icons.help;
    } else {
      color = AppTheme.errorRed;
      icon = Icons.warning;
    }

    return Tooltip(
      message: 'Confidence: ${(item.confidence * 100).toStringAsFixed(1)}%',
      child: Icon(
        icon,
        color: color,
        size: 16,
      ),
    );
  }

  Widget _buildMoreMenu() {
    return PopupMenuButton<String>(
      icon: Icon(Icons.more_vert, color: AppTheme.gray400, size: 20),
      onSelected: _handleMenuAction,
      color: AppTheme.gray800,
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: 'copy_original',
          child: Row(
            children: [
              Icon(Icons.copy, color: AppTheme.twitterBlue, size: 18),
              SizedBox(width: 12),
              Text('Copy Original', style: TextStyle(color: AppTheme.white)),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'copy_translation',
          child: Row(
            children: [
              Icon(Icons.copy, color: AppTheme.vibrantGreen, size: 18),
              SizedBox(width: 12),
              Text('Copy Translation', style: TextStyle(color: AppTheme.white)),
            ],
          ),
        ),
        if (onShare != null)
          const PopupMenuItem(
            value: 'share',
            child: Row(
              children: [
                Icon(Icons.share, color: AppTheme.gray400, size: 18),
                SizedBox(width: 12),
                Text('Share', style: TextStyle(color: AppTheme.white)),
              ],
            ),
          ),
        if (onEdit != null)
          const PopupMenuItem(
            value: 'edit',
            child: Row(
              children: [
                Icon(Icons.edit, color: AppTheme.vibrantOrange, size: 18),
                SizedBox(width: 12),
                Text('Edit', style: TextStyle(color: AppTheme.white)),
              ],
            ),
          ),
        if (onDelete != null)
          const PopupMenuItem(
            value: 'delete',
            child: Row(
              children: [
                Icon(Icons.delete, color: AppTheme.errorRed, size: 18),
                SizedBox(width: 12),
                Text('Delete', style: TextStyle(color: AppTheme.white)),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildTextSection(
    String label,
    String text,
    String language, {
    bool isTranslation = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: const TextStyle(
                color: AppTheme.gray400,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            const Spacer(),
            GestureDetector(
              onTap: () => _copyToClipboard(text),
              child: Icon(
                Icons.copy,
                color: AppTheme.gray400,
                size: 14,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          text,
          style: TextStyle(
            color: isTranslation ? AppTheme.vibrantGreen : AppTheme.white,
            fontSize: 16,
            fontWeight: isTranslation ? FontWeight.w600 : FontWeight.w400,
            height: 1.3,
          ),
        ),
      ],
    );
  }

  Widget _buildCompactContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          item.originalText,
          style: const TextStyle(
            color: AppTheme.white,
            fontSize: 14,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),
        Text(
          item.translatedText,
          style: const TextStyle(
            color: AppTheme.vibrantGreen,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildFooter() {
    return Row(
      children: [
        // Timestamp
        Icon(Icons.schedule, color: AppTheme.gray500, size: 14),
        const SizedBox(width: 4),
        Text(
          _formatTimestamp(item.timestamp),
          style: const TextStyle(
            color: AppTheme.gray500,
            fontSize: 12,
          ),
        ),

        // Source indicator
        const SizedBox(width: 12),
        _buildSourceIndicator(item.translationSource.name),

        // Category tag
        if (item.category != null) ...[
          const SizedBox(width: 12),
          _buildCategoryTag(item.category!),
        ],

        // Usage count indicator (not available in HistoryEntry)
        // Keeping this comment for future implementation

        const Spacer(),

        // Quick actions
        _buildQuickActions(),
      ],
    );
  }

  Widget _buildSourceIndicator(String source) {
    IconData icon;
    Color color;

    switch (source.toLowerCase()) {
      case 'camera':
      case 'ocr':
        icon = Icons.camera_alt;
        color = AppTheme.vibrantGreen;
        break;
      case 'voice':
      case 'speech':
        icon = Icons.mic;
        color = AppTheme.twitterBlue;
        break;
      case 'image':
        icon = Icons.image;
        color = AppTheme.vibrantOrange;
        break;
      case 'file':
        icon = Icons.insert_drive_file;
        color = AppTheme.errorRed;
        break;
      default:
        icon = Icons.text_fields;
        color = AppTheme.gray400;
    }

    return Tooltip(
      message: 'Source: ${source.toUpperCase()}',
      child: Icon(
        icon,
        color: color,
        size: 14,
      ),
    );
  }

  Widget _buildCategoryTag(String category) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: AppTheme.gray700,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        category,
        style: const TextStyle(
          color: AppTheme.gray300,
          fontSize: 10,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildUsageIndicator(int count) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.repeat, color: AppTheme.gray500, size: 12),
        const SizedBox(width: 2),
        Text(
          '$count',
          style: const TextStyle(
            color: AppTheme.gray500,
            fontSize: 10,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActions() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Copy translation
        GestureDetector(
          onTap: () => _copyToClipboard(item.translatedText),
          child: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: AppTheme.vibrantGreen.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(
              Icons.copy,
              color: AppTheme.vibrantGreen,
              size: 16,
            ),
          ),
        ),

        if (onShare != null) ...[
          const SizedBox(width: 8),
          GestureDetector(
            onTap: onShare,
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppTheme.twitterBlue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(
                Icons.share,
                color: AppTheme.twitterBlue,
                size: 16,
              ),
            ),
          ),
        ],
      ],
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 30) {
      return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    // Note: In a real app, you'd show a snackbar or toast here
  }

  void _handleMenuAction(String action) {
    switch (action) {
      case 'copy_original':
        _copyToClipboard(item.originalText);
        break;
      case 'copy_translation':
        _copyToClipboard(item.translatedText);
        break;
      case 'share':
        onShare?.call();
        break;
      case 'edit':
        onEdit?.call();
        break;
      case 'delete':
        onDelete?.call();
        break;
    }
  }
}
