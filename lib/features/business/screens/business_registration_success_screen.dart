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

    _checkController.forward().then((_) {
      _particleController.forward();
      _contentController.forward();
    });
  }

  @override
  void dispose() {
    _checkController.dispose();
    _pulseController.dispose();
    _particleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(flex: 2),
            _buildAnimation(),
            SizedBox(height: 32.h),
            _buildContent(),
            const Spacer(flex: 2),
            _buildHomeButton(),
            SizedBox(height: 40.h),
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
              Text(
                AppStrings.businessRegistered,
                textAlign: TextAlign.center,
                style: AppTypography.screenTitle.copyWith(
                  color: AppColors.darkGrey,
                  fontSize: 20.sp,
                ),
              ),
              SizedBox(height: 12.h),
              Text(
                'Your business profile is now under review. '
                'You\'ll see it live once approved by our team.',
                textAlign: TextAlign.center,
                style: AppTypography.bodyText.copyWith(
                  color: AppColors.grey,
                  fontSize: 14.sp,
                  height: 1.5,
                ),
              ),
              SizedBox(height: 20.h),
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
          child: Text(
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
