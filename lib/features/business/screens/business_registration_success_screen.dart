import 'dart:math';
import 'package:nearhood/core/utils/custom_import.dart';
import 'package:nearhood/features/home/home_screen.dart';

class BusinessRegistrationSuccessScreen extends StatefulWidget {
  const BusinessRegistrationSuccessScreen({super.key});

  @override
  State<BusinessRegistrationSuccessScreen> createState() =>
      _BusinessRegistrationSuccessScreenState();
}

class _BusinessRegistrationSuccessScreenState
    extends State<BusinessRegistrationSuccessScreen>
    with TickerProviderStateMixin {
  late final AnimationController _checkController;
  late final AnimationController _pulseController;
  late final AnimationController _particleController;
  late final AnimationController _contentController;
  late final AnimationController _confettiController;

  @override
  void initState() {
    super.initState();

    _checkController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );
    _contentController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _confettiController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    );

    _checkController.forward().then((_) {
      _particleController.forward();
      _confettiController.forward();
      _contentController.forward();
    });
  }

  @override
  void dispose() {
    _checkController.dispose();
    _pulseController.dispose();
    _particleController.dispose();
    _contentController.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Stack(
          children: [
            // Confetti layer
            AnimatedBuilder(
              animation: _confettiController,
              builder: (context, _) => CustomPaint(
                size: Size(MediaQuery.of(context).size.width,
                    MediaQuery.of(context).size.height),
                painter: _ConfettiPainter(progress: _confettiController.value),
              ),
            ),
            Column(
              children: [
                const Spacer(flex: 2),
                _buildAnimation(),
                sh(32),
                _buildContent(),
                const Spacer(flex: 2),
                _buildHomeButton(),
                sh(40),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimation() {
    return SizedBox(
      height: 180.h,
      width: 180.w,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Pulse rings
          AnimatedBuilder(
            animation: _pulseController,
            builder: (context, _) {
              return Transform.scale(
                scale: 1.0 + _pulseController.value * 0.15,
                child: Container(
                  width: 120.r,
                  height: 120.r,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.green.withValues(
                        alpha: 0.2 * (1 - _pulseController.value),
                      ),
                      width: 2,
                    ),
                  ),
                ),
              );
            },
          ),
          // Green circle background
          AnimatedBuilder(
            animation: _checkController,
            builder: (context, child) {
              return Transform.scale(
                scale: Curves.elasticOut.transform(_checkController.value),
                child: child,
              );
            },
            child: Container(
              width: 100.r,
              height: 100.r,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.green,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.green.withValues(alpha: 0.3),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
            ),
          ),
          // Checkmark
          AnimatedBuilder(
            animation: _checkController,
            builder: (context, _) {
              return CustomPaint(
                size: Size(50.r, 50.r),
                painter: _CheckmarkPainter(
                  progress: Curves.easeOut.transform(_checkController.value),
                ),
              );
            },
          ),
          // Particles
          ...List.generate(12, (i) {
            return AnimatedBuilder(
              animation: _particleController,
              builder: (context, _) {
                final angle = (i * 30) * pi / 180;
                final distance = _particleController.value * 70.r;
                final opacity = (1 - _particleController.value).clamp(0.0, 1.0);
                return Transform.translate(
                  offset: Offset(cos(angle) * distance, sin(angle) * distance),
                  child: Opacity(
                    opacity: opacity,
                    child: Container(
                      width: 6.r,
                      height: 6.r,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: i.isEven
                            ? AppColors.green
                            : AppColors.primaryBlue,
                      ),
                    ),
                  ),
                );
              },
            );
          }),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return FadeTransition(
      opacity: _contentController,
      child: SlideTransition(
        position: Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero)
            .animate(
              CurvedAnimation(
                parent: _contentController,
                curve: Curves.easeOut,
              ),
            ),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 32.w),
          child: Column(
            children: [
              CustomText(
                'Business Created Successfully!',
                textAlign: TextAlign.center,
                style: AppTypography.screenTitle.copyWith(
                  color: AppColors.darkGrey,
                  fontSize: 20.sp,
                ),
              ),
              sh(12),
              CustomText(
                'Your business profile is now live. Neighbors can discover you in the marketplace.',
                textAlign: TextAlign.center,
                style: AppTypography.bodyText.copyWith(
                  color: AppColors.grey,
                  fontSize: 14.sp,
                  height: 1.5,
                ),
              ),
              sh(20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHomeButton() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 32.w),
      child: SizedBox(
        width: double.infinity,
        height: 50.h,
        child: ElevatedButton(
          onPressed: () {
            callNextScreenAndClearStack(
              context,
              const HomeScreen(),
              transitionType: PageTransitionType.leftToRight,
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryBlue,
            foregroundColor: AppColors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.r),
            ),
            elevation: 0,
          ),
          child: CustomText(
            'Go to Home',
            style: AppTypography.buttonLabel.copyWith(
              color: AppColors.white,
              fontSize: 16.sp,
            ),
          ),
        ),
      ),
    );
  }
}

class _ConfettiPainter extends CustomPainter {
  final double progress;

  _ConfettiPainter({required this.progress});

  static const _colors = [
    Color(0xFFFF6B6B),
    Color(0xFF4ECDC4),
    Color(0xFFFFE66D),
    Color(0xFF95E1D3),
    Color(0xFFF38181),
    Color(0xFFAA96DA),
    Color(0xFFFCBD6E),
    Color(0xFF6BCB77),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final random = Random(42);
    final confettiCount = 60;

    for (var i = 0; i < confettiCount; i++) {
      final color = _colors[i % _colors.length];
      final paint = Paint()..color = color;

      final startX = random.nextDouble() * size.width;
      final startY = -20.0 + (random.nextDouble() * size.height * 0.3);

      final fallDistance = progress * size.height * 1.2;
      final drift = sin(progress * pi * 2 + i) * 40;
      final x = startX + drift;
      final y = startY + fallDistance * (0.5 + random.nextDouble() * 0.5);

      if (y < 0 || y > size.height) continue;

      final rotation = progress * pi * (2 + random.nextDouble() * 4);
      final w = 4.0 + random.nextDouble() * 4;
      final h = 2.0 + random.nextDouble() * 3;

      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(rotation);

      final opacity = (1 - (y / size.height)).clamp(0.0, 1.0);
      paint.color = color.withValues(alpha: opacity * 0.8);

      canvas.drawRect(
        Rect.fromCenter(center: Offset.zero, width: w, height: h),
        paint,
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_ConfettiPainter oldDelegate) =>
      oldDelegate.progress != progress;
}

class _CheckmarkPainter extends CustomPainter {
  final double progress;

  _CheckmarkPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final path = Path();
    path.moveTo(size.width * 0.2, size.height * 0.52);
    path.lineTo(size.width * 0.42, size.height * 0.74);
    path.lineTo(size.width * 0.8, size.height * 0.28);

    final metrics = path.computeMetrics().first;
    final extractedPath = metrics.extractPath(0, metrics.length * progress);

    canvas.drawPath(extractedPath, paint);
  }

  @override
  bool shouldRepaint(_CheckmarkPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
