// 🌐 LingoSphere - Share Dialog
// Beautiful sharing interface with platform-specific options

import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../../../core/services/native_sharing_service.dart';
import '../../../core/models/translation_entry.dart';
import '../../theme/app_theme.dart';

/// Share dialog widget with platform selection
class ShareDialog extends StatefulWidget {
  final ShareContent content;
  final String? title;
  final List<SharingPlatform>? availablePlatforms;
  final Function(ShareResult)? onShareCompleted;

  const ShareDialog({
    super.key,
    required this.content,
    this.title,
    this.availablePlatforms,
    this.onShareCompleted,
  });

  /// Show share dialog for translation
  static Future<void> showForTranslation({
    required BuildContext context,
    required TranslationEntry translation,
    bool includeMetadata = true,
    bool includeFormatting = true,
    Function(ShareResult)? onCompleted,
  }) async {
    final sharingService = NativeSharingService();

    final shareContent = ShareContent(
      type: ShareContentType.translation,
      text: 'Preparing translation...',
      subject: 'Translation from LingoSphere',
      metadata: {
        'translation_id': translation.id,
        'source_language': translation.sourceLanguage,
        'target_language': translation.targetLanguage,
      },
    );

    await showDialog<void>(
      context: context,
      builder: (context) => ShareDialog(
        content: shareContent,
        title: 'Share Translation',
        onShareCompleted: onCompleted,
      ),
    );
  }

  /// Show share dialog for conversation
  static Future<void> showForConversation({
    required BuildContext context,
    required List<TranslationEntry> conversation,
    String? conversationTitle,
    bool includeTimestamps = true,
    Function(ShareResult)? onCompleted,
  }) async {
    final shareContent = ShareContent(
      type: ShareContentType.conversation,
      text: 'Preparing conversation...',
      subject: conversationTitle ?? 'Conversation from LingoSphere',
      metadata: {
        'conversation_length': conversation.length,
        'title': conversationTitle,
      },
    );

    await showDialog<void>(
      context: context,
      builder: (context) => ShareDialog(
        content: shareContent,
        title: 'Share Conversation',
        onShareCompleted: onCompleted,
      ),
    );
  }

  @override
  State<ShareDialog> createState() => _ShareDialogState();
}

class _ShareDialogState extends State<ShareDialog>
    with SingleTickerProviderStateMixin {
  final NativeSharingService _sharingService = NativeSharingService();
  late List<SharingPlatform> _platforms;
  bool _isSharing = false;

  @override
  void initState() {
    super.initState();
    _platforms =
        widget.availablePlatforms ?? _sharingService.getAvailablePlatforms();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400, maxHeight: 600),
        child: Card(
          elevation: 16,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildHeader(),
              _buildPreview(),
              _buildPlatformGrid(),
              _buildActions(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGradient,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.share,
              color: AppTheme.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.title ?? 'Share Content',
                  style: const TextStyle(
                    color: AppTheme.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    fontFamily: AppTheme.headingFontFamily,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Choose how to share your ${widget.content.type.name}',
                  style: const TextStyle(
                    color: AppTheme.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.close, color: AppTheme.white),
            splashRadius: 20,
          ),
        ],
      ),
    );
  }

  Widget _buildPreview() {
    return Container(
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.gray50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.gray200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                _getContentTypeIcon(),
                color: AppTheme.primaryBlue,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Preview',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.gray900,
                ),
              ),
              const Spacer(),
              Text(
                '${widget.content.text?.length ?? 0} characters',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppTheme.gray600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            constraints: const BoxConstraints(maxHeight: 100),
            child: SingleChildScrollView(
              child: Text(
                widget.content.text ?? 'No content available',
                style: const TextStyle(
                  fontSize: 14,
                  color: AppTheme.gray700,
                  height: 1.4,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlatformGrid() {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: AnimationLimiter(
          child: GridView.builder(
            shrinkWrap: true,
            physics: const BouncingScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              childAspectRatio: 1,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: _platforms.length,
            itemBuilder: (context, index) {
              return AnimationConfiguration.staggeredGrid(
                position: index,
                duration: const Duration(milliseconds: 375),
                columnCount: 4,
                child: ScaleAnimation(
                  child: FadeInAnimation(
                    child: _buildPlatformItem(_platforms[index]),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildPlatformItem(SharingPlatform platform) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: _isSharing ? null : () => _shareToPlatform(platform),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            color: AppTheme.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.gray200),
            boxShadow: [
              BoxShadow(
                color: AppTheme.gray900.withValues(alpha: 0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _getPlatformColor(platform).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _sharingService.getPlatformIcon(platform),
                  color: _getPlatformColor(platform),
                  size: 24,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _sharingService.getPlatformDisplayName(platform),
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.gray700,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActions() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: AppTheme.gray50,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextButton.icon(
              onPressed: _isSharing ? null : () => Navigator.of(context).pop(),
              icon: const Icon(Icons.close, size: 18),
              label: const Text('Cancel'),
              style: TextButton.styleFrom(
                foregroundColor: AppTheme.gray600,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: _isSharing
                  ? null
                  : () => _shareToPlatform(SharingPlatform.generic),
              icon: _isSharing
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.share, size: 18),
              label: Text(_isSharing ? 'Sharing...' : 'More Options'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryBlue,
                foregroundColor: AppTheme.white,
                elevation: 2,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _shareToPlatform(SharingPlatform platform) async {
    if (_isSharing) return;

    setState(() {
      _isSharing = true;
    });

    try {
      final shareContent = widget.content.copyWith(preferredPlatform: platform);
      final result = await _sharingService.shareContent(shareContent);

      if (widget.onShareCompleted != null) {
        widget.onShareCompleted!(result);
      }

      if (result.success) {
        if (mounted) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Shared successfully to ${_sharingService.getPlatformDisplayName(platform)}!',
              ),
              backgroundColor: AppTheme.successGreen,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to share: ${result.errorMessage}'),
              backgroundColor: AppTheme.errorRed,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error sharing: $e'),
            backgroundColor: AppTheme.errorRed,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSharing = false;
        });
      }
    }
  }

  IconData _getContentTypeIcon() {
    switch (widget.content.type) {
      case ShareContentType.translation:
        return Icons.translate;
      case ShareContentType.conversation:
        return Icons.chat_bubble_outline;
      case ShareContentType.image:
        return Icons.image;
      case ShareContentType.audio:
        return Icons.audiotrack;
      case ShareContentType.file:
        return Icons.insert_drive_file;
      default:
        return Icons.text_fields;
    }
  }

  Color _getPlatformColor(SharingPlatform platform) {
    switch (platform) {
      case SharingPlatform.whatsapp:
        return const Color(0xFF25D366);
      case SharingPlatform.telegram:
        return const Color(0xFF0088CC);
      case SharingPlatform.twitter:
        return const Color(0xFF1DA1F2);
      case SharingPlatform.facebook:
        return const Color(0xFF4267B2);
      case SharingPlatform.instagram:
        return const Color(0xFFE4405F);
      case SharingPlatform.linkedin:
        return const Color(0xFF0077B5);
      case SharingPlatform.email:
        return AppTheme.accentTeal;
      case SharingPlatform.sms:
        return AppTheme.successGreen;
      case SharingPlatform.clipboard:
        return AppTheme.warningAmber;
      case SharingPlatform.airdrop:
        return AppTheme.primaryBlue;
      default:
        return AppTheme.gray600;
    }
  }
}
