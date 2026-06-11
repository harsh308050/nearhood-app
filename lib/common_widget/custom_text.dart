import 'dart:async';
import 'package:flutter/material.dart';
import 'package:nearhood/core/theme/app_typography.dart';

/// A fully customizable, generic Text widget that supports pre-defined
/// typography styles as well as inheriting styles from parent widgets 
/// (such as AnimatedDefaultTextStyle used in TextField labels).
class CustomText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final Color? color;
  final double? fontSize;
  final FontWeight? fontWeight;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;
  final TextDecoration? decoration;
  final double? height;
  final double? letterSpacing;

  // Scroll parameters
  final bool enableScroll;
  final int? numberOfReps;
  final Duration? delayBefore;
  final Duration? pauseBetween;
  final Duration? pauseOnBounce;
  final TextScrollMode scrollMode;
  final Velocity velocity;
  final int? intervalSpaces;
  final bool fadedBorder;
  final double? fadedBorderWidth;
  final FadeBorderSide fadeBorderSide;
  final FadeBorderVisibility fadeBorderVisibility;
  final EdgeInsetsGeometry? padding;

  const CustomText(
    this.text, {
    super.key,
    this.style,
    this.color,
    this.fontSize,
    this.fontWeight,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.decoration,
    this.height,
    this.letterSpacing,
    this.enableScroll = false,
    this.numberOfReps,
    this.delayBefore,
    this.pauseBetween,
    this.pauseOnBounce,
    this.scrollMode = TextScrollMode.endless,
    this.velocity = const Velocity(pixelsPerSecond: Offset(80, 0)),
    this.intervalSpaces,
    this.fadedBorder = false,
    this.fadedBorderWidth = 0.2,
    this.fadeBorderSide = FadeBorderSide.both,
    this.fadeBorderVisibility = FadeBorderVisibility.auto,
    this.padding,
  });

  /// Factory constructors for standard typography variants.
  factory CustomText.heroTitle(String text, {Color? color, TextAlign? textAlign, int? maxLines}) {
    return CustomText(text, style: AppTypography.heroTitle, color: color, textAlign: textAlign, maxLines: maxLines);
  }

  factory CustomText.screenTitle(String text, {Color? color, TextAlign? textAlign, int? maxLines}) {
    return CustomText(text, style: AppTypography.screenTitle, color: color, textAlign: textAlign, maxLines: maxLines);
  }

  factory CustomText.sectionHeader(String text, {Color? color, TextAlign? textAlign, int? maxLines}) {
    return CustomText(text, style: AppTypography.sectionHeader, color: color, textAlign: textAlign, maxLines: maxLines);
  }
  
  factory CustomText.cardTitle(String text, {Color? color, TextAlign? textAlign, int? maxLines}) {
    return CustomText(text, style: AppTypography.cardTitle, color: color, textAlign: textAlign, maxLines: maxLines);
  }

  factory CustomText.bodyText(String text, {Color? color, TextAlign? textAlign, int? maxLines}) {
    return CustomText(text, style: AppTypography.bodyText, color: color, textAlign: textAlign, maxLines: maxLines);
  }

  factory CustomText.caption(String text, {Color? color, TextAlign? textAlign, int? maxLines}) {
    return CustomText(text, style: AppTypography.caption, color: color, textAlign: textAlign, maxLines: maxLines);
  }

  factory CustomText.buttonLabel(String text, {Color? color, TextAlign? textAlign, int? maxLines}) {
    return CustomText(text, style: AppTypography.buttonLabel, color: color, textAlign: textAlign, maxLines: maxLines);
  }

  factory CustomText.overline(String text, {Color? color, TextAlign? textAlign, int? maxLines}) {
    return CustomText(text, style: AppTypography.overline, color: color, textAlign: textAlign, maxLines: maxLines);
  }

  @override
  Widget build(BuildContext context) {
    // Merge provided overrides with the base style if present.
    // If style is null, we apply overrides to a bare TextStyle so it 
    // can inherit properties from DefaultTextStyle without forcing an override.
    final finalStyle = style?.copyWith(
      color: color,
      fontSize: fontSize,
      fontWeight: fontWeight,
      decoration: decoration,
      height: height,
      letterSpacing: letterSpacing,
    ) ?? TextStyle(
      color: color,
      fontSize: fontSize,
      fontWeight: fontWeight,
      decoration: decoration,
      height: height,
      letterSpacing: letterSpacing,
    );

    if (enableScroll) {
      return TextScroll(
        text,
        key: key,
        style: finalStyle,
        textAlign: textAlign,
        numberOfReps: numberOfReps,
        delayBefore: delayBefore,
        pauseBetween: pauseBetween,
        pauseOnBounce: pauseOnBounce,
        mode: scrollMode,
        velocity: velocity,
        selectable: maxLines == null,
        intervalSpaces: intervalSpaces,
        fadedBorder: fadedBorder,
        fadedBorderWidth: fadedBorderWidth,
        fadeBorderSide: fadeBorderSide,
        fadeBorderVisibility: fadeBorderVisibility,
        padding: padding,
      );
    }

    return Text(
      text,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow ?? (maxLines != null ? TextOverflow.ellipsis : null),
      style: finalStyle,
    );
  }
}

/// TextScroll widget automatically scrolls provided [text] according
/// to custom settings, in order to achieve 'marquee' text effect.
class TextScroll extends StatefulWidget {
  const TextScroll(
    this.text, {
    Key? key,
    this.style,
    this.textAlign,
    this.textDirection = TextDirection.ltr,
    this.numberOfReps,
    this.delayBefore,
    this.pauseBetween,
    this.pauseOnBounce,
    this.mode = TextScrollMode.endless,
    this.velocity = const Velocity(pixelsPerSecond: Offset(80, 0)),
    this.selectable = false,
    this.intervalSpaces,
    this.fadedBorder = false,
    this.fadedBorderWidth = 0.2,
    this.fadeBorderSide = FadeBorderSide.both,
    this.fadeBorderVisibility = FadeBorderVisibility.auto,
    this.padding,
  }) : super(key: key);

  final String text;
  final TextAlign? textAlign;
  final TextDirection textDirection;
  final TextStyle? style;
  final int? numberOfReps;
  final Duration? delayBefore;
  final Duration? pauseBetween;
  final Duration? pauseOnBounce;
  final TextScrollMode mode;
  final Velocity velocity;
  final bool selectable;
  final int? intervalSpaces;
  final bool fadedBorder;
  final double? fadedBorderWidth;
  final FadeBorderSide fadeBorderSide;
  final FadeBorderVisibility fadeBorderVisibility;
  final EdgeInsetsGeometry? padding;

  @override
  State<TextScroll> createState() => _TextScrollState();
}

class _TextScrollState extends State<TextScroll> {
  final _scrollController = ScrollController();
  String? _endlessText;
  double? _originalTextWidth;
  double _textMinWidth = 0;
  Timer? _timer;
  bool _running = false;
  int _counter = 0;

  @override
  void initState() {
    super.initState();

    final WidgetsBinding? binding = WidgetsBinding.instance;
    if (binding != null) {
      binding.addPostFrameCallback(_initScroller);
    }
  }

  @override
  void didUpdateWidget(covariant TextScroll oldWidget) {
    _onUpdate(oldWidget);

    if (oldWidget.velocity != widget.velocity) {
      _setTimer();
    }

    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    assert(
      widget.intervalSpaces == null || widget.mode == TextScrollMode.endless,
      'intervalSpaces is only available in TextScrollMode.endless mode',
    );
    assert(
      !widget.fadedBorder ||
          (widget.fadedBorder &&
              widget.fadedBorderWidth != null &&
              widget.fadedBorderWidth! > 0 &&
              widget.fadedBorderWidth! <= 1),
      'fadedBorderInterval must be between 0 and 1 when fadedBorder is true',
    );

    Widget baseWidget = Directionality(
      textDirection: widget.textDirection,
      child: SingleChildScrollView(
        controller: _scrollController,
        physics: const NeverScrollableScrollPhysics(),
        scrollDirection: Axis.horizontal,
        padding: widget.padding,
        child: ConstrainedBox(
          constraints: BoxConstraints(minWidth: _textMinWidth),
          child: widget.selectable
              ? SelectableText(
                  _endlessText ?? widget.text,
                  style: widget.style,
                  textAlign: widget.textAlign,
                )
              : Text(
                  _endlessText ?? widget.text,
                  style: widget.style,
                  textAlign: widget.textAlign,
                ),
        ),
      ),
    );

    Widget? fadeBorderWidget;

    if (widget.fadedBorder) {
      final List<Color> colors = List.generate(
        1 ~/ widget.fadedBorderWidth! - 1,
        (index) {
          return Colors.transparent;
        },
        growable: true,
      );

      if (widget.fadeBorderSide == FadeBorderSide.both ||
          widget.fadeBorderSide == FadeBorderSide.left) {
        colors.insert(0, Colors.black);
      } else {
        colors.add(Colors.transparent);
      }
      if (widget.fadeBorderSide == FadeBorderSide.both ||
          widget.fadeBorderSide == FadeBorderSide.right) {
        colors.add(Colors.black);
      } else {
        colors.add(Colors.transparent);
      }

      final List<double> stops = List.generate(1 ~/ widget.fadedBorderWidth!, (
        index,
      ) {
        return (index + 1) * widget.fadedBorderWidth!;
      }, growable: true);

      stops.insert(0, 0);

      final TextPainter textPrototype = TextPainter(
        text: TextSpan(text: _endlessText ?? widget.text, style: widget.style),
        textDirection: widget.textDirection,
        textScaler: MediaQuery.of(context).textScaler,
        textWidthBasis: TextWidthBasis.longestLine,
      )..layout();

      fadeBorderWidget = LayoutBuilder(
        builder: (context, constraints) {
          if (widget.fadeBorderVisibility == FadeBorderVisibility.always ||
              constraints.maxWidth < textPrototype.size.width) {
            return ShaderMask(
              blendMode: BlendMode.dstOut,
              shaderCallback: (rect) {
                return LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: colors,
                  stops: stops,
                ).createShader(rect);
              },
              child: baseWidget,
            );
          } else {
            return baseWidget;
          }
        },
      );
    }

    return fadeBorderWidget ?? baseWidget;
  }

  Future<void> _initScroller(_) async {
    setState(() {
      _textMinWidth = _scrollController.position.viewportDimension;
    });

    await _delayBefore();
    _setTimer();
  }

  void _setTimer() {
    _timer?.cancel();
    _running = false;

    _timer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
      if (!_available) {
        _timer?.cancel();
        _timer = null;
        return;
      }

      final int? maxReps = widget.numberOfReps;
      if (maxReps != null && _counter >= maxReps) {
        _timer?.cancel();
        _timer = null;
        return;
      }

      if (!_running) _run();
    });
  }

  Future<void> _run() async {
    _running = true;

    final int? maxReps = widget.numberOfReps;
    if (maxReps == null || _counter < maxReps) {
      _counter++;

      switch (widget.mode) {
        case TextScrollMode.bouncing:
          {
            await _animateBouncing();
            break;
          }
        default:
          {
            await _animateEndless();
          }
      }
    }
    _running = false;
  }

  Future<void> _animateEndless() async {
    if (!_available) return;

    final ScrollPosition position = _scrollController.position;
    final bool needsScrolling = position.maxScrollExtent > 0;
    if (!needsScrolling) {
      if (_endlessText != null) setState(() => _endlessText = null);
      return;
    }

    if (_endlessText == null || _originalTextWidth == null) {
      setState(() {
        _originalTextWidth =
            position.maxScrollExtent + position.viewportDimension;
        _endlessText =
            widget.text + _getSpaces(widget.intervalSpaces ?? 8) + widget.text;
      });

      return;
    }

    final double endlessTextWidth =
        position.maxScrollExtent + position.viewportDimension;
    final double singleRoundExtent = endlessTextWidth - _originalTextWidth!;
    final Duration duration = _getDuration(singleRoundExtent);
    if (duration == Duration.zero) return;

    if (!_available) return;
    await _scrollController.animateTo(
      singleRoundExtent,
      duration: duration,
      curve: Curves.linear,
    );
    if (!_available) return;
    _scrollController.jumpTo(position.minScrollExtent);

    if (widget.pauseBetween != null) {
      await Future.delayed(widget.pauseBetween!);
    }
  }

  Future<void> _animateBouncing() async {
    final double maxExtent = _scrollController.position.maxScrollExtent;
    final double minExtent = _scrollController.position.minScrollExtent;
    final double extent = maxExtent - minExtent;
    final Duration duration = _getDuration(extent);
    if (duration == Duration.zero) return;

    if (!_available) return;
    await _scrollController.animateTo(
      maxExtent,
      duration: duration,
      curve: Curves.linear,
    );
    if (widget.pauseOnBounce != null) {
      await Future.delayed(widget.pauseOnBounce!);
    }
    if (!_available) return;
    await _scrollController.animateTo(
      minExtent,
      duration: duration,
      curve: Curves.linear,
    );
    if (!_available) return;
    if (widget.pauseBetween != null) {
      await Future<dynamic>.delayed(widget.pauseBetween!);
    }
  }

  Future<void> _delayBefore() async {
    final Duration? delayBefore = widget.delayBefore;
    if (delayBefore == null) return;

    await Future<dynamic>.delayed(delayBefore);
  }

  Duration _getDuration(double extent) {
    if (widget.velocity.pixelsPerSecond.dx == 0) return Duration.zero;

    final int milliseconds =
        (extent * 1000 / widget.velocity.pixelsPerSecond.dx).round();

    return Duration(milliseconds: milliseconds);
  }

  void _onUpdate(TextScroll oldWidget) {
    if (widget.text != oldWidget.text && _endlessText != null) {
      setState(() {
        _endlessText = null;
        _originalTextWidth = null;
      });
      _scrollController.jumpTo(_scrollController.position.minScrollExtent);
    }
  }

  String _getSpaces(int number) {
    String spaces = '';
    for (int i = 0; i < number; i++) {
      spaces += '\u{00A0}';
    }

    return spaces;
  }

  bool get _available => mounted && _scrollController.hasClients;
}

enum TextScrollMode { bouncing, endless }
enum FadeBorderSide { left, right, both }
enum FadeBorderVisibility { always, auto }
