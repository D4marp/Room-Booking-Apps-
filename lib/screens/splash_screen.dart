import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../utils/app_theme.dart';
import 'auth/login_screen.dart';
import 'home/home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize animations
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 1400),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.3,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    _startAnimations();
    _navigateToNextScreen();
  }

  void _startAnimations() {
    _fadeController.forward();
    Future.delayed(const Duration(milliseconds: 200), () {
      _scaleController.forward();
    });
    Future.delayed(const Duration(milliseconds: 400), () {
      _slideController.forward();
    });
  }

  void _navigateToNextScreen() {
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        final authProvider = Provider.of<AuthProvider>(context, listen: false);

        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                authProvider.isAuthenticated
                    ? const HomeScreen()
                    : const LoginScreen(),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
            transitionDuration: const Duration(milliseconds: 500),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _scaleController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.primaryGradient,
        ),
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Decorative top elements
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: Opacity(
                    opacity: 0.15,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Transform.rotate(
                          angle: 0.3,
                          child: const Icon(
                            Icons.meeting_room,
                            size: 80,
                            color: Colors.white,
                          ),
                        ),
                        Transform.rotate(
                          angle: -0.3,
                          child: const Icon(
                            Icons.calendar_today,
                            size: 80,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: AppSpacing.xl),

                // Main Logo
                Transform.scale(
                  scale: _scaleAnimation.value,
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: Container(
                      width: 130,
                      height: 130,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.25),
                            blurRadius: 30,
                            offset: const Offset(0, 15),
                          ),
                          BoxShadow(
                            color: AppColors.primaryBlue.withOpacity(0.15),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Icon(
                            Icons.meeting_room,
                            size: 70,
                            color: AppColors.primaryBlue,
                          ),
                          Positioned(
                            top: 10,
                            right: 10,
                            child: Container(
                              width: 20,
                              height: 20,
                              decoration: BoxDecoration(
                                color: AppColors.successGreen,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Icon(
                                Icons.check,
                                size: 12,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: AppSpacing.xl),

                // App Name and Tagline
                SlideTransition(
                  position: _slideAnimation,
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: Column(
                      children: [
                        Text(
                          'RoomBooking',
                          style:
                              Theme.of(context).textTheme.displayMedium?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 1.5,
                              ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.md,
                            vertical: AppSpacing.xs,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          child: Text(
                            'Office & Campus Rooms',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Colors.white.withOpacity(0.95),
                                  letterSpacing: 0.3,
                                  fontWeight: FontWeight.w500,
                                ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: AppSpacing.xxl),

                // Loading Animation - Modern dots
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildAnimatedDot(0),
                      const SizedBox(width: 8),
                      _buildAnimatedDot(1),
                      const SizedBox(width: 8),
                      _buildAnimatedDot(2),
                    ],
                  ),
                ),

                const SizedBox(height: AppSpacing.xl),

                // Loading Text
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: Text(
                    'Preparing your workspace...',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.white.withOpacity(0.85),
                          letterSpacing: 0.2,
                        ),
                  ),
                ),

                const Spacer(),

                // Footer info
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.lg),
                    child: Column(
                      children: [
                        Text(
                          'Smart Room Booking System',
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                color: Colors.white.withOpacity(0.7),
                              ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          width: 40,
                          height: 3,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedDot(int index) {
    return Transform.scale(
      scale: _scaleAnimation.value,
      child: Container(
        width: 8,
        height: 8,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.7 - (index * 0.15)),
          borderRadius: BorderRadius.circular(4),
        ),
      ),
    );
  }
}
