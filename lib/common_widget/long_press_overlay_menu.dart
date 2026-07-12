import 'dart:ui';
import 'package:nearhood/core/utils/custom_import.dart';

class OverlayMenuItem {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  final Widget? trailing;

  const OverlayMenuItem({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
    this.trailing,
  });
}

class LongPressOverlayMenu extends StatefulWidget {
  final Widget child;
  final List<OverlayMenuItem> menuItems;
  final Offset position;
  final Size size;
  final double blurSigma;
  final Color barrierColor;
  final double menuWidth;
  final double menuBorderRadius;
  final double menuSpacing;
  final Duration animationDuration;
  final Widget? menuHeader;
  final bool showDividers;
  final Color? menuBackgroundColor;
  final List<BoxShadow>? menuShadow;
  final Decoration? menuDecoration;

  const LongPressOverlayMenu({
    super.key,
    required this.child,
    required this.menuItems,
    required this.position,
    required this.size,
    this.blurSigma = 5.0,
    this.barrierColor = const Color(0x99000000),
    this.menuWidth = 170,
    this.menuBorderRadius = 16,
    this.menuSpacing = 8,
    this.animationDuration = const Duration(milliseconds: 200),
    this.menuHeader,
    this.showDividers = true,
    this.menuBackgroundColor,
    this.menuShadow,
    this.menuDecoration,
  });

  static Future<void> show({
    required BuildContext context,
    required Widget child,
    required List<OverlayMenuItem> menuItems,
    required Offset position,
    required Size size,
    double blurSigma = 5.0,
    Color barrierColor = const Color(0x99000000),
    double menuWidth = 170,
    double menuBorderRadius = 16,
    double menuSpacing = 8,
    Duration animationDuration = const Duration(milliseconds: 200),
    Widget? menuHeader,
    bool showDividers = true,
    Color? menuBackgroundColor,
    List<BoxShadow>? menuShadow,
    Decoration? menuDecoration,
    double? menuLeft,
    double? menuRight,
  }) {
    final screenSize = MediaQuery.of(context).size;
    final menuEstimatedHeight =
        (menuItems.length * 52.0) + (showDividers ? (menuItems.length - 1) : 0);

    final spaceAbove = position.dy;
    final spaceBelow = screenSize.height - position.dy - size.height;
    final bool showAbove =
        spaceBelow < menuEstimatedHeight + menuSpacing * 2 &&
        spaceAbove > menuEstimatedHeight + menuSpacing * 2;

    final double menuTop = showAbove
        ? position.dy - menuEstimatedHeight - menuSpacing
        : position.dy + size.height + menuSpacing;

    final effectiveMenuLeft =
        menuLeft ?? (menuRight == null ? position.dx : null);

    return showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'dismiss',
      barrierColor: barrierColor,
      transitionDuration: animationDuration,
      pageBuilder: (dialogContext, anim1, anim2) {
        return _LongPressOverlayContent(
          menuItems: menuItems,
          position: position,
          size: size,
          menuTop: menuTop,
          menuWidth: menuWidth,
          menuBorderRadius: menuBorderRadius,
          blurSigma: blurSigma,
          menuHeader: menuHeader,
          showDividers: showDividers,
          menuBackgroundColor: menuBackgroundColor,
          menuShadow: menuShadow,
          menuDecoration: menuDecoration,
          menuLeft: effectiveMenuLeft,
          menuRight: menuRight,
          child: child,
        );
      },
    );
  }

  @override
  State<LongPressOverlayMenu> createState() => _LongPressOverlayMenuState();
}

class _LongPressOverlayMenuState extends State<LongPressOverlayMenu> {
  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}

class _LongPressOverlayContent extends StatelessWidget {
  final Widget child;
  final List<OverlayMenuItem> menuItems;
  final Offset position;
  final Size size;
  final double menuTop;
  final double menuWidth;
  final double menuBorderRadius;
  final double blurSigma;
  final Widget? menuHeader;
  final bool showDividers;
  final Color? menuBackgroundColor;
  final List<BoxShadow>? menuShadow;
  final Decoration? menuDecoration;
  final double? menuLeft;
  final double? menuRight;

  const _LongPressOverlayContent({
    required this.child,
    required this.menuItems,
    required this.position,
    required this.size,
    required this.menuTop,
    required this.menuWidth,
    required this.menuBorderRadius,
    required this.blurSigma,
    this.menuHeader,
    this.showDividers = true,
    this.menuBackgroundColor,
    this.menuShadow,
    this.menuDecoration,
    this.menuLeft,
    this.menuRight,
  });

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
      child: Scaffold(
        backgroundColor: AppColors.transparent,
        body: Stack(
          children: [
            GestureDetector(
              onTap: () => Navigator.pop(context),
              behavior: HitTestBehavior.opaque,
              child: const SizedBox.expand(),
            ),
            Positioned(
              left: position.dx,
              top: position.dy,
              width: size.width,
              height: size.height,
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Material(color: AppColors.transparent, child: child),
              ),
            ),
            Positioned(
              left: menuLeft,
              right: menuRight,
              top: menuTop,
              width: menuWidth,
              child: _buildMenu(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenu(BuildContext context) {
    final defaultShadow = [
      BoxShadow(
        color: AppColors.black.withValues(alpha: 0.15),
        blurRadius: 10,
        offset: const Offset(0, 4),
      ),
    ];

    final decoration =
        menuDecoration ??
        BoxDecoration(
          color: menuBackgroundColor ?? AppColors.white,
          borderRadius: BorderRadius.circular(menuBorderRadius.r),
          boxShadow: menuShadow ?? defaultShadow,
        );

    final visibleItems = menuItems
        .where((item) => item.label.isNotEmpty)
        .toList();

    return Material(
      color: AppColors.transparent,
      child: Container(
        decoration: decoration,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(menuBorderRadius.r),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (menuHeader != null) menuHeader!,
              for (int i = 0; i < visibleItems.length; i++) ...[
                if (i > 0 && showDividers)
                  Divider(height: 1, color: AppColors.borderLight),
                _buildMenuItem(context, visibleItems[i]),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItem(BuildContext context, OverlayMenuItem item) {
    return InkWell(
      onTap: () {
        Navigator.pop(context);
        item.onTap();
      },
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        child: Row(
          children: [
            Icon(item.icon, color: item.color, size: 22.r),
            sw(12.w),
            Expanded(
              child: CustomText(
                item.label,
                style: AppTypography.bodyText.copyWith(
                  fontWeight: FontWeight.w600,
                  color: item.color,
                  fontSize: 14.sp,
                ),
              ),
            ),
            if (item.trailing != null) item.trailing!,
          ],
        ),
      ),
    );
  }
}
