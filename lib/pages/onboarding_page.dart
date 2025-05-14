import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingPage extends StatefulWidget {
  final VoidCallback? onFinish;
  const OnboardingPage({super.key, this.onFinish});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final controller = PageController();
  bool isLastPage = false;

  final List<_OnboardingSlide> slides = [
    _OnboardingSlide(
      title: 'The Importance of Blood Donation',
      subtitle:
          'Every donation can save up to three lives. Your contribution matters!',
      image: 'assets/images/blood_donation.jpg',
    ),
    _OnboardingSlide(
      title: 'Connecting Donors and Recipients',
      subtitle:
          'iDonate bridges the gap between those who want to help and those in need.',
      image: 'assets/images/connecting.jpg',
    ),
    _OnboardingSlide(
      title: 'Anonymity & Preferred Donor Options',
      subtitle:
          'Choose to remain anonymous or select your preferred donor/recipient.',
      image: 'assets/images/privacy.jpg',
    ),
    _OnboardingSlide(
      title: 'Easy and Fast Requests',
      subtitle:
          'Request or donate blood quickly and easily, anytime, anywhere.',
      image: 'assets/images/fast.jpg',
    ),
  ];

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView.builder(
            controller: controller,
            itemCount: slides.length,
            onPageChanged: (index) {
              setState(() {
                isLastPage = index == slides.length - 1;
              });
            },
            itemBuilder: (context, index) {
              final slide = slides[index];
              return _buildPage(slide);
            },
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.7),
                  ],
                ),
              ),
              child: Column(
                children: [
                  SmoothPageIndicator(
                    controller: controller,
                    count: slides.length,
                    effect: const WormEffect(
                      spacing: 16,
                      dotColor: Colors.white24,
                      activeDotColor: Colors.white,
                      dotHeight: 8,
                      dotWidth: 8,
                    ),
                  ),
                  const SizedBox(height: 30),
                  if (isLastPage)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: const Color(0xFFCC2B2B),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            onPressed: _handleFinish,
                            child: const Text(
                              'Sign Up',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Colors.white),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            onPressed: _handleFinish,
                            child: const Text(
                              'Sign In',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    )
                  else
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton(
                          onPressed: () {
                            controller.jumpToPage(slides.length - 1);
                          },
                          child: const Text(
                            'SKIP',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            controller.nextPage(
                              duration: const Duration(milliseconds: 500),
                              curve: Curves.easeInOut,
                            );
                          },
                          child: const Text(
                            'NEXT',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPage(_OnboardingSlide slide) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Background Image
        Image.asset(
          slide.image,
          fit: BoxFit.cover,
        ),
        // Red Overlay
        Container(
          color: const Color(0xFFCC2B2B).withOpacity(0.4),
        ),
        // Content
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                slide.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  height: 1.2,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Text(
                slide.subtitle,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _handleFinish() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_complete', true);
    if (widget.onFinish != null) widget.onFinish!();
  }
}

class _OnboardingSlide {
  final String title;
  final String subtitle;
  final String image;
  const _OnboardingSlide({
    required this.title,
    required this.subtitle,
    required this.image,
  });
}

class OnboardingPageWithCallback extends StatelessWidget {
  final VoidCallback onFinish;
  const OnboardingPageWithCallback({required this.onFinish, super.key});
  @override
  Widget build(BuildContext context) {
    return OnboardingPage(onFinish: onFinish);
  }
}
