import 'package:flutter/material.dart';
import 'package:nearhood/core/theme/app_colors.dart';
import 'package:nearhood/core/constants/app_assets.dart';
import 'package:nearhood/core/utils/cm.dart';
import 'package:nearhood/common_widget/custom_text.dart';

class ReactionItem {
  final String type;
  final String label;
  final String assetPath;
  final Color color;

  const ReactionItem({
    required this.type,
    required this.label,
    required this.assetPath,
    required this.color,
  });
}

const List<ReactionItem> reactionsList = [
  ReactionItem(
    type: 'like',
    label: 'Like',
    assetPath: AppAssets.icReactLike,
    color: Color(0xFF0A66C2),
  ),
  ReactionItem(
    type: 'celebrate',
    label: 'Celebrate',
    assetPath: AppAssets.icReactCelebrate,
    color: Color(0xFF1B9A59),
  ),
  ReactionItem(
    type: 'support',
    label: 'Support',
    assetPath: AppAssets.icReactSupport,
    color: Color(0xFF7552CC),
  ),
  ReactionItem(
    type: 'love',
    label: 'Love',
    assetPath: AppAssets.icReactLove,
    color: Color(0xFFDF3E30),
  ),
  ReactionItem(
    type: 'insightful',
    label: 'Insightful',
    assetPath: AppAssets.icReactInsightful,
    color: Color(0xFFF4B400),
  ),
  ReactionItem(
    type: 'funny',
    label: 'Funny',
    assetPath: AppAssets.icReactFunny,
    color: Color(0xFF119EA4),
  ),
];

final _reactionTween = Tween<double>(begin: 0.0, end: 1.0);

class ReactionPickerOverlay {
  static OverlayEntry? _currentOverlay;

  static void show({
    required BuildContext context,
    required Offset buttonPosition,
    required Size buttonSize,
    required ValueNotifier<Offset?> touchPositionNotifier,
    required ValueNotifier<String?> selectedReactionNotifier,
    required Function(String reaction) onReactionSelected,
  }) {
    dismiss();

    final overlayState = Overlay.of(context);
    _currentOverlay = OverlayEntry(
      builder: (context) => _ReactionPickerWidget(
        buttonPosition: buttonPosition,
        buttonSize: buttonSize,
        touchPositionNotifier: touchPositionNotifier,
        selectedReactionNotifier: selectedReactionNotifier,
        onDismiss: () => dismiss(),
        onReactionSelected: onReactionSelected,
      ),
    );

    overlayState.insert(_currentOverlay!);
  }

  static void dismiss() {
    if (_currentOverlay != null) {
      _currentOverlay!.remove();
      _currentOverlay = null;
    }
  }
}

class _ReactionPickerWidget extends StatefulWidget {
  final Offset buttonPosition;
  final Size buttonSize;
  final ValueNotifier<Offset?> touchPositionNotifier;
  final ValueNotifier<String?> selectedReactionNotifier;
  final VoidCallback onDismiss;
  final Function(String reaction) onReactionSelected;

  const _ReactionPickerWidget({
    required this.buttonPosition,
    required this.buttonSize,
    required this.touchPositionNotifier,
    required this.selectedReactionNotifier,
    required this.onDismiss,
    required this.onReactionSelected,
  });

  @override
  State<_ReactionPickerWidget> createState() => _ReactionPickerWidgetState();
}

class _ReactionPickerWidgetState extends State<_ReactionPickerWidget> {
  int _highlightedIndex = -1;
  late double _leftOffset;
  late double _topOffset;

  final double _popupWidth = 276.0;
  final double _emojiSize = 30.0;
  final double _emojiSpacing = 8.0;
  final double _paddingHorizontal = 12.0;

  @override
  void initState() {
    super.initState();
    widget.touchPositionNotifier.addListener(_handleTouchUpdate);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _calculatePosition();
  }

  @override
  void dispose() {
    widget.touchPositionNotifier.removeListener(_handleTouchUpdate);
    super.dispose();
  }

  void _calculatePosition() {
    final screenWidth = MediaQuery.of(context).size.width;
    final buttonCenterX =
        widget.buttonPosition.dx + widget.buttonSize.width / 2;

    // Centered horizontally above the button and clamped to keep it on screen
    _leftOffset = (buttonCenterX - (_popupWidth / 2)).clamp(
      16.0,
      screenWidth - _popupWidth - 16.0,
    );
    // Directly above the button with a small offset
    _topOffset = widget.buttonPosition.dy - 60.0;
  }

  void _handleTouchUpdate() {
    final touchPosition = widget.touchPositionNotifier.value;
    if (touchPosition == null) {
      if (mounted) {
        setState(() {
          _highlightedIndex = -1;
        });
      }
      return;
    }

    // Calculate relative horizontal touch coordinate
    final touchX = touchPosition.dx;
    final relativeX = touchX - (_leftOffset + _paddingHorizontal);

    // Calculate index based on touch coordinates
    final itemTotalWidth = _emojiSize + _emojiSpacing;
    int index = (relativeX / itemTotalWidth).floor();

    // Clamp index to valid emoji range to prevent fluctuations at boundaries
    index = index.clamp(0, reactionsList.length - 1);

    if (mounted) {
      setState(() {
        _highlightedIndex = index;
      });
    }
    widget.selectedReactionNotifier.value = reactionsList[index].type;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Barrier listener for tap
        Positioned.fill(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: widget.onDismiss,
            onPanStart: (_) => widget.onDismiss(),
            child: Container(color: AppColors.transparent),
          ),
        ),

        // Tooltip label above the hovered emoji
        if (_highlightedIndex != -1)
          Positioned(
            left:
                _leftOffset +
                _paddingHorizontal +
                _highlightedIndex * (_emojiSize + _emojiSpacing) +
                (_emojiSize / 2),
            top: _topOffset - 42.0,
            child: FractionalTranslation(
              translation: const Offset(-0.5, 0.0),
              child: TweenAnimationBuilder<double>(
                key: ValueKey(_highlightedIndex),
                tween: _reactionTween,
                duration: const Duration(milliseconds: 120),
                curve: Curves.easeOut,
                builder: (context, value, child) {
                  return Transform.scale(
                    scale: value,
                    alignment: Alignment.bottomCenter,
                    child: Opacity(
                      opacity: value.clamp(0.0, 1.0),
                      child: child,
                    ),
                  );
                },
                child: Material(
                  color: AppColors.transparent,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      vertical: 4.h,
                      horizontal: 10.w,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.darkGrey,
                      borderRadius: BorderRadius.circular(100.r),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.black.withValues(alpha: 0.15),
                          blurRadius: 4.r,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: CustomText(
                      reactionsList[_highlightedIndex].label,
                      decoration: TextDecoration.none,
                      style: TextStyle(
                        color: AppColors.white,
                        fontSize: 10.5.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

        // Main pop-up row container
        Positioned(
          left: _leftOffset,
          top: _topOffset,
          child: Material(
            color: AppColors.transparent,
            child: TweenAnimationBuilder<double>(
              tween: _reactionTween,
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOutBack,
              builder: (context, value, child) {
                return Transform.scale(
                  scale: value,
                  alignment: Alignment.bottomCenter,
                  child: Opacity(opacity: value.clamp(0.0, 1.0), child: child),
                );
              },
              child: Listener(
                behavior: HitTestBehavior.opaque,
                onPointerDown: (event) {
                  widget.touchPositionNotifier.value = event.position;
                },
                onPointerMove: (event) {
                  widget.touchPositionNotifier.value = event.position;
                },
                onPointerUp: (event) {
                  final selected = widget.selectedReactionNotifier.value;
                  if (selected != null) {
                    widget.onReactionSelected(selected);
                  }
                  widget.touchPositionNotifier.value = null;
                  widget.onDismiss();
                },
                onPointerCancel: (event) {
                  widget.touchPositionNotifier.value = null;
                  widget.onDismiss();
                },
                child: Container(
                  height: 48.0,
                  width: _popupWidth,
                  padding: EdgeInsets.symmetric(horizontal: _paddingHorizontal),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(100.r),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.black.withValues(alpha: 0.12),
                        blurRadius: 12.r,
                        spreadRadius: 1.r,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(reactionsList.length, (index) {
                      final isHovered = index == _highlightedIndex;
                      final reaction = reactionsList[index];

                      return AnimatedScale(
                        scale: isHovered ? 1.45 : 1.0,
                        duration: const Duration(milliseconds: 100),
                        curve: Curves.easeOutCubic,
                        child: GestureDetector(
                          onTap: () {
                            widget.onReactionSelected(reaction.type);
                            widget.onDismiss();
                          },
                          child: Container(
                            width: _emojiSize,
                            height: _emojiSize,
                            margin: EdgeInsets.only(
                              right: index == reactionsList.length - 1
                                  ? 0
                                  : _emojiSpacing,
                            ),
                            child: Image.asset(
                              reaction.assetPath,
                              width: _emojiSize,
                              height: _emojiSize,
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
