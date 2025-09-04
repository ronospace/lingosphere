// 🌐 LingoSphere - Quick Share Button
// Inline sharing buttons for translations and conversations

import 'package:flutter/material.dart';
import '../../../core/services/native_sharing_service.dart';
import '../../../core/models/translation_entry.dart';
import '../../theme/app_theme.dart';
import 'share_dialog.dart';

/// Quick share button sizes
enum QuickShareSize {
  small,
  medium,
  large,
}

/// Quick share button widget
class QuickShareButton extends StatefulWidget {
  final ShareContent? content;
  final TranslationEntry? translation;
  final List<TranslationEntry>? conversation;
  final SharingPlatform? directPlatform;
  final QuickShareSize size;
  final Color? primaryColor;
  final Color? backgroundColor;
  final String? tooltip;
  final bool showLabel;
  final Function(ShareResult)? onShareCompleted;

  const QuickShareButton({
    super.key,
    this.content,
    this.translation,
    this.conversation,
    this.directPlatform,
    this.size = QuickShareSize.medium,
    this.primaryColor,
    this.backgroundColor,
    this.tooltip,
    this.showLabel = false,
    this.onShareCompleted,
  }) : assert(content != null || translation != null || conversation != null,
            'Must provide either content, translation, or conversation');

  /// Create quick share button for translation
  factory QuickShareButton.forTranslation({
    required TranslationEntry translation,
    SharingPlatform? directPlatform,
    QuickShareSize size = QuickShareSize.medium,
    Color? primaryColor,
    Color? backgroundColor,
    String? tooltip,
    bool showLabel = false,
    Function(ShareResult)? onCompleted,
  }) {
    return QuickShareButton(
      translation: translation,
      directPlatform: directPlatform,
      size: size,
      primaryColor: primaryColor,
      backgroundColor: backgroundColor,
      tooltip: tooltip,
      showLabel: showLabel,
      onShareCompleted: onCompleted,
    );
  }

  /// Create quick share button for conversation
  factory QuickShareButton.forConversation({
    required List<TranslationEntry> conversation,
    SharingPlatform? directPlatform,
    QuickShareSize size = QuickShareSize.medium,
    Color? primaryColor,
    Color? backgroundColor,
    String? tooltip,
    bool showLabel = false,
    Function(ShareResult)? onCompleted,
  }) {
    return QuickShareButton(
      conversation: conversation,
      directPlatform: directPlatform,
      size: size,
      primaryColor: primaryColor,
      backgroundColor: backgroundColor,
      tooltip: tooltip,
      showLabel: showLabel,
      onShareCompleted: onCompleted,
    );
  }

  /// Create quick share button for analytics data
  factory QuickShareButton.forAnalytics({
    required ShareContent content,
    SharingPlatform? directPlatform,
    QuickShareSize size = QuickShareSize.medium,
    Color? primaryColor,
    Color? backgroundColor,
    String? tooltip,
    bool showLabel = false,
    Function(ShareResult)? onCompleted,
  }) {
    return QuickShareButton(
      content: content,
      directPlatform: directPlatform,
      size: size,
      primaryColor: primaryColor,
      backgroundColor: backgroundColor,
      tooltip: tooltip,
      showLabel: showLabel,
      onShareCompleted: onCompleted,
    );
  }

  @override
  State<QuickShareButton> createState() => _QuickShareButtonState();
}

class _QuickShareButtonState extends State<QuickShareButton>
    with SingleTickerProviderStateMixin {
  final NativeSharingService _sharingService = NativeSharingService();
  bool _isSharing = false;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final buttonSize = _getButtonSize();
    final iconSize = _getIconSize();

    Widget button = AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: _buildButton(buttonSize, iconSize),
        );
      },
    );

    if (widget.tooltip != null) {
      button = Tooltip(
        message: widget.tooltip!,
        child: button,
      );
    }

    return button;
  }

  Widget _buildButton(double size, double iconSize) {
    if (widget.showLabel) {
      return _buildLabeledButton(size, iconSize);
    } else {
      return _buildIconButton(size, iconSize);
    }
  }

  Widget _buildIconButton(double size, double iconSize) {
    return GestureDetector(
      onTapDown: (_) => _animationController.forward(),
      onTapUp: (_) => _animationController.reverse(),
      onTapCancel: () => _animationController.reverse(),
      onTap: _isSharing ? null : _onShareTapped,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: widget.backgroundColor ??
              (widget.primaryColor ?? AppTheme.primaryBlue).withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(size / 2),
          border: Border.all(
            color:
                (widget.primaryColor ?? AppTheme.primaryBlue).withValues(alpha: 0.2),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: (widget.primaryColor ?? AppTheme.primaryBlue)
                  .withValues(alpha: 0.15),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: _isSharing
              ? SizedBox(
                  width: iconSize * 0.8,
                  height: iconSize * 0.8,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: widget.primaryColor ?? AppTheme.primaryBlue,
                  ),
                )
              : Icon(
                  _getShareIcon(),
                  size: iconSize,
                  color: widget.primaryColor ?? AppTheme.primaryBlue,
                ),
        ),
      ),
    );
  }

  Widget _buildLabeledButton(double size, double iconSize) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: _isSharing ? null : _onShareTapped,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: widget.backgroundColor ??
                (widget.primaryColor ?? AppTheme.primaryBlue).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: (widget.primaryColor ?? AppTheme.primaryBlue)
                  .withValues(alpha: 0.2),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _isSharing
                  ? SizedBox(
                      width: iconSize,
                      height: iconSize,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: widget.primaryColor ?? AppTheme.primaryBlue,
                      ),
                    )
                  : Icon(
                      _getShareIcon(),
                      size: iconSize,
                      color: widget.primaryColor ?? AppTheme.primaryBlue,
                    ),
              const SizedBox(width: 8),
              Text(
                _getShareLabel(),
                style: TextStyle(
                  fontSize: _getLabelFontSize(),
                  fontWeight: FontWeight.w600,
                  color: widget.primaryColor ?? AppTheme.primaryBlue,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _onShareTapped() async {
    if (_isSharing) return;

    // If direct platform is specified, share directly
    if (widget.directPlatform != null) {
      await _shareDirectly();
    } else {
      await _showShareDialog();
    }
  }

  Future<void> _shareDirectly() async {
    setState(() {
      _isSharing = true;
    });

    try {
      ShareResult result;

      if (widget.content != null) {
        final shareContent = widget.content!.copyWith(
          preferredPlatform: widget.directPlatform,
        );
        result = await _sharingService.shareContent(shareContent);
      } else if (widget.translation != null) {
        result = await _sharingService.shareTranslation(
          translation: widget.translation!,
          preferredPlatform: widget.directPlatform,
        );
      } else if (widget.conversation != null) {
        result = await _sharingService.shareConversation(
          conversation: widget.conversation!,
          preferredPlatform: widget.directPlatform,
        );
      } else {
        result = ShareResult.createError('No content to share');
      }

      if (widget.onShareCompleted != null) {
        widget.onShareCompleted!(result);
      }

      if (result.success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Shared successfully!'),
            backgroundColor: AppTheme.successGreen,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 2),
          ),
        );
      } else if (!result.success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to share: ${result.errorMessage}'),
            backgroundColor: AppTheme.errorRed,
            behavior: SnackBarBehavior.floating,
          ),
        );
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

  Future<void> _showShareDialog() async {
    if (widget.translation != null) {
      await ShareDialog.showForTranslation(
        context: context,
        translation: widget.translation!,
        onCompleted: widget.onShareCompleted,
      );
    } else if (widget.conversation != null) {
      await ShareDialog.showForConversation(
        context: context,
        conversation: widget.conversation!,
        onCompleted: widget.onShareCompleted,
      );
    } else if (widget.content != null) {
      await showDialog<void>(
        context: context,
        builder: (context) => ShareDialog(
          content: widget.content!,
          onShareCompleted: widget.onShareCompleted,
        ),
      );
    }
  }

  double _getButtonSize() {
    switch (widget.size) {
      case QuickShareSize.small:
        return 32;
      case QuickShareSize.medium:
        return 40;
      case QuickShareSize.large:
        return 48;
    }
  }

  double _getIconSize() {
    switch (widget.size) {
      case QuickShareSize.small:
        return 16;
      case QuickShareSize.medium:
        return 20;
      case QuickShareSize.large:
        return 24;
    }
  }

  double _getLabelFontSize() {
    switch (widget.size) {
      case QuickShareSize.small:
        return 12;
      case QuickShareSize.medium:
        return 14;
      case QuickShareSize.large:
        return 16;
    }
  }

  IconData _getShareIcon() {
    if (widget.directPlatform != null) {
      return _sharingService.getPlatformIcon(widget.directPlatform!);
    }
    return Icons.share;
  }

  String _getShareLabel() {
    if (widget.directPlatform != null) {
      return _sharingService.getPlatformDisplayName(widget.directPlatform!);
    }
    return 'Share';
  }
}

/// Horizontal row of quick share buttons
class QuickShareRow extends StatelessWidget {
  final TranslationEntry? translation;
  final List<TranslationEntry>? conversation;
  final List<SharingPlatform> platforms;
  final QuickShareSize size;
  final Function(ShareResult)? onShareCompleted;

  const QuickShareRow({
    super.key,
    this.translation,
    this.conversation,
    this.platforms = const [
      SharingPlatform.whatsapp,
      SharingPlatform.telegram,
      SharingPlatform.twitter,
      SharingPlatform.email,
    ],
    this.size = QuickShareSize.medium,
    this.onShareCompleted,
  }) : assert(translation != null || conversation != null,
            'Must provide either translation or conversation');

  @override
  Widget build(BuildContext context) {
    final availablePlatforms = NativeSharingService().getAvailablePlatforms();
    final filteredPlatforms = platforms
        .where((platform) => availablePlatforms.contains(platform))
        .toList();

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (int i = 0; i < filteredPlatforms.length; i++) ...[
            if (i > 0) const SizedBox(width: 8),
            QuickShareButton(
              translation: translation,
              conversation: conversation,
              directPlatform: filteredPlatforms[i],
              size: size,
              onShareCompleted: onShareCompleted,
            ),
          ],
          const SizedBox(width: 8),
          QuickShareButton(
            translation: translation,
            conversation: conversation,
            size: size,
            tooltip: 'More sharing options',
            onShareCompleted: onShareCompleted,
          ),
        ],
      ),
    );
  }
}
