import 'package:flutter/material.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'package:url_launcher/url_launcher.dart';
import 'loginscreen.dart';

// ─────────────────────────────────────────────────────────────
//  FRAD – Landing Page  (landingpage.dart)  — Animated Version
//  Place this file in:  lib/screens/landingpage.dart
// ─────────────────────────────────────────────────────────────
class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  static const Color primary = Color(0xffC75B12);
  static const Color amber = Color(0xffF59E0B);
  static const Color lightGold = Color(0xffFFD89B);
  static const Color bgLight = Color(0xffFDFBF7);
  static const Color cardWhite = Color(0xffFFFFFF);
  static const Color textDark = Color(0xff1E293B);

  // ── Social links — replace these with your real profile URLs ──
  static const String linkedInUrl =
      'https://www.linkedin.com/in/malaikakhushal/';
  static const String githubUrl = ' https://github.com/MalaikaKhushal';

  @override
  Widget build(BuildContext context) {
    final bool isDesktop = MediaQuery.of(context).size.width > 800;

    return Scaffold(
      backgroundColor: bgLight,
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            const _AppHeader(),
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: isDesktop
                    ? MediaQuery.of(context).size.width * 0.15
                    : 0,
              ),
              child: Column(
                children: [
                  const _HeroBanner(),
                  _RevealOnScroll(
                    revealKey: 'providers',
                    child: const _ProvidersSection(),
                  ),
                  _RevealOnScroll(
                    revealKey: 'howitworks',
                    child: const _HowItWorks(),
                  ),
                  _RevealOnScroll(
                    revealKey: 'features',
                    child: const _KeyFeatures(),
                  ),
                  _RevealOnScroll(
                    revealKey: 'impact',
                    child: const _ImpactStats(),
                  ),
                  _RevealOnScroll(revealKey: 'about', child: const _AboutUs()),
                  _RevealOnScroll(
                    revealKey: 'contact',
                    child: const _ContactUs(),
                  ),
                  _RevealOnScroll(
                    revealKey: 'portals',
                    child: const _PortalsSection(),
                  ),
                ],
              ),
            ),
            const _Footer(),
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
//  REUSABLE: Scroll reveal wrapper (fade + slide up on scroll-in)
// ══════════════════════════════════════════════════════════════
class _RevealOnScroll extends StatefulWidget {
  final Widget child;
  final String revealKey;
  const _RevealOnScroll({required this.child, required this.revealKey});

  @override
  State<_RevealOnScroll> createState() => _RevealOnScrollState();
}

class _RevealOnScrollState extends State<_RevealOnScroll>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;
  bool _triggered = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onVisibilityChanged(VisibilityInfo info) {
    if (!_triggered && info.visibleFraction > 0.15) {
      _triggered = true;
      _controller.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: Key(widget.revealKey),
      onVisibilityChanged: _onVisibilityChanged,
      child: FadeTransition(
        opacity: _fade,
        child: SlideTransition(position: _slide, child: widget.child),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
//  REUSABLE: Floating glow wrapper (for CTA buttons)
// ══════════════════════════════════════════════════════════════
class _FloatingGlowButton extends StatefulWidget {
  final Widget child;
  final Color glowColor;
  const _FloatingGlowButton({required this.child, required this.glowColor});

  @override
  State<_FloatingGlowButton> createState() => _FloatingGlowButtonState();
}

class _FloatingGlowButtonState extends State<_FloatingGlowButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final t = _controller.value;
        final dy = -4 * t;
        final glowRadius = 10 + (12 * t);
        final glowAlpha = (70 + 70 * t).toInt();
        return Transform.translate(
          offset: Offset(0, dy),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: widget.glowColor.withAlpha(glowAlpha),
                  blurRadius: glowRadius,
                  spreadRadius: 1,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: child,
          ),
        );
      },
      child: widget.child,
    );
  }
}

// ══════════════════════════════════════════════════════════════
//  REUSABLE: Typewriter text
// ══════════════════════════════════════════════════════════════
class _TypewriterText extends StatefulWidget {
  final String text;
  final TextStyle style;
  const _TypewriterText({required this.text, required this.style});

  @override
  State<_TypewriterText> createState() => _TypewriterTextState();
}

class _TypewriterTextState extends State<_TypewriterText> {
  String _shown = '';
  int _index = 0;

  @override
  void initState() {
    super.initState();
    _startTyping();
  }

  Future<void> _startTyping() async {
    while (mounted && _index < widget.text.length) {
      await Future.delayed(const Duration(milliseconds: 45));
      if (!mounted) return;
      setState(() {
        _index++;
        _shown = widget.text.substring(0, _index);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Text(_shown, textAlign: TextAlign.center, style: widget.style);
  }
}

// ══════════════════════════════════════════════════════════════
//  REUSABLE: Hover-lift wrapper for cards (scale + shadow + border)
// ══════════════════════════════════════════════════════════════
class _HoverLift extends StatefulWidget {
  final Widget Function(bool hovering) builder;
  const _HoverLift({required this.builder});

  @override
  State<_HoverLift> createState() => _HoverLiftState();
}

class _HoverLiftState extends State<_HoverLift> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _hovering = true),
        onTapUp: (_) => setState(() => _hovering = false),
        onTapCancel: () => setState(() => _hovering = false),
        child: AnimatedScale(
          scale: _hovering ? 1.04 : 1.0,
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          child: widget.builder(_hovering),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
//  SECTION 1 – App Header
// ══════════════════════════════════════════════════════════════
class _AppHeader extends StatelessWidget {
  const _AppHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 60, bottom: 24, left: 24, right: 24),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [LandingPage.primary, LandingPage.amber],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: const Color.fromRGBO(0, 0, 0, 0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(
                Icons.food_bank_rounded,
                size: 34,
                color: LandingPage.primary,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'FRAD',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: 1.5,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Food Rescue & Donation App',
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xE6FFFFFF),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
//  SECTION 2 – Hero Banner (with typewriter + floating buttons)
// ══════════════════════════════════════════════════════════════
class _HeroBanner extends StatelessWidget {
  const _HeroBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            LandingPage.primary,
            LandingPage.amber,
            LandingPage.lightGold,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: LandingPage.primary.withAlpha(77),
            blurRadius: 25,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Stack(
        children: [
          const Positioned(
            top: -30,
            right: -30,
            child: CircleAvatar(
              radius: 70,
              backgroundColor: Color.fromRGBO(255, 255, 255, 0.08),
            ),
          ),
          const Positioned(
            bottom: -50,
            left: -40,
            child: CircleAvatar(
              radius: 90,
              backgroundColor: Color.fromRGBO(255, 255, 255, 0.05),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text('🍱', style: TextStyle(fontSize: 56)),
              const SizedBox(height: 16),
              const Text(
                'Reduce Food Waste',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Connect Extra Food With People Who Need It',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  color: Color(0xE6FFFFFF),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 10),
              _TypewriterText(
                text: 'Save Food • Save Money • Help Communities',
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.white70,
                  fontStyle: FontStyle.italic,
                ),
              ),
              const SizedBox(height: 36),
              Row(
                children: [
                  Expanded(
                    child: _FloatingGlowButton(
                      glowColor: Colors.white,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pushReplacementNamed(context, '/signin');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: LandingPage.primary,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          'Sign In',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _FloatingGlowButton(
                      glowColor: LandingPage.lightGold,
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/createaccount');
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          side: const BorderSide(color: Colors.white, width: 2),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: const Text(
                          'Create Account',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// SECTION 3 – Providers Section (badges now animate on hover/tap)
// ══════════════════════════════════════════════════════════════
class _ProvidersSection extends StatelessWidget {
  const _ProvidersSection();
  @override
  Widget build(BuildContext context) {
    return _buildSectionLayout(
      title: 'Our Trusted Partners',
      subtitle: 'Connecting ecosystems to save nutrition daily.',
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: Row(
          children: const [
            _ProviderBadge(icon: Icons.restaurant, label: 'Restaurants'),
            _ProviderBadge(icon: Icons.local_hotel, label: 'Hotels'),
            _ProviderBadge(icon: Icons.storefront, label: 'Supermarkets'),
            _ProviderBadge(icon: Icons.bakery_dining, label: 'Bakeries'),
            _ProviderBadge(icon: Icons.celebration, label: 'Event Halls'),
          ],
        ),
      ),
    );
  }
}

class _ProviderBadge extends StatelessWidget {
  final IconData icon;
  final String label;
  const _ProviderBadge({required this.icon, required this.label});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 14, bottom: 8, top: 4),
      child: _HoverLift(
        builder: (hovering) => AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          decoration: BoxDecoration(
            color: LandingPage.cardWhite,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: hovering ? LandingPage.amber : const Color(0xffE2E8F0),
              width: hovering ? 1.5 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: hovering
                    ? LandingPage.primary.withAlpha(60)
                    : const Color.fromRGBO(0, 0, 0, 0.03),
                blurRadius: hovering ? 16 : 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              AnimatedScale(
                scale: hovering ? 1.15 : 1.0,
                duration: const Duration(milliseconds: 180),
                child: Icon(icon, color: LandingPage.primary, size: 22),
              ),
              const SizedBox(width: 10),
              Text(
                label,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: LandingPage.textDark,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// SECTION 4 – How It Works (step cards animate on hover/tap)
// ══════════════════════════════════════════════════════════════
class _HowItWorks extends StatelessWidget {
  const _HowItWorks();
  @override
  Widget build(BuildContext context) {
    return _buildSectionLayout(
      title: 'How It Works',
      subtitle: 'Simple steps to make an immediate community impact.',
      child: Column(
        children: const [
          _StepCard(
            stepNumber: '01',
            title: 'List Surplus Food',
            description:
                'Providers log surplus inventory or meals onto the secure platform within minutes.',
          ),
          _StepCard(
            stepNumber: '02',
            title: 'Claim or Donate',
            description:
                'NGOs, shelters, or individuals browse and claim open food batches near them.',
          ),
          _StepCard(
            stepNumber: '03',
            title: 'Safe Redistribution',
            description:
                'Logistics partners manage lightning fast routing safely directly to locations.',
          ),
        ],
      ),
    );
  }
}

class _StepCard extends StatelessWidget {
  final String stepNumber;
  final String title;
  final String description;
  const _StepCard({
    required this.stepNumber,
    required this.title,
    required this.description,
  });
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: _HoverLift(
        builder: (hovering) => AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: LandingPage.cardWhite,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: hovering ? LandingPage.amber : const Color(0xffE2E8F0),
              width: hovering ? 1.5 : 1,
            ),
            boxShadow: hovering
                ? [
                    BoxShadow(
                      color: LandingPage.primary.withAlpha(45),
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                    ),
                  ]
                : [],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                stepNumber,
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  color: LandingPage.amber,
                ),
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: LandingPage.textDark,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      description,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xff64748B),
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// SECTION 5 – Key Features (feature cards animate on hover/tap)
// ══════════════════════════════════════════════════════════════
class _KeyFeatures extends StatelessWidget {
  const _KeyFeatures();
  @override
  Widget build(BuildContext context) {
    return _buildSectionLayout(
      title: 'Key App Features',
      subtitle:
          'Powerful integrations to deliver robust operational performance.',
      child: GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: MediaQuery.of(context).size.width > 600 ? 2 : 1,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 2.2,
        children: const [
          _FeatureItem(
            icon: Icons.location_on_rounded,
            title: 'Real-time Tracking',
          ),
          _FeatureItem(
            icon: Icons.notifications_active,
            title: 'Instant Alert pings',
          ),
          _FeatureItem(
            icon: Icons.verified_user_rounded,
            title: 'Verified Profiles',
          ),
          _FeatureItem(
            icon: Icons.analytics_outlined,
            title: 'Analytics Panel',
          ),
        ],
      ),
    );
  }
}

class _FeatureItem extends StatelessWidget {
  final IconData icon;
  final String title;
  const _FeatureItem({required this.icon, required this.title});
  @override
  Widget build(BuildContext context) {
    return _HoverLift(
      builder: (hovering) => AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: LandingPage.cardWhite,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: hovering ? LandingPage.amber : const Color(0xffE2E8F0),
            width: hovering ? 1.5 : 1,
          ),
          boxShadow: hovering
              ? [
                  BoxShadow(
                    color: LandingPage.primary.withAlpha(45),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ]
              : [],
        ),
        child: Row(
          children: [
            AnimatedScale(
              scale: hovering ? 1.12 : 1.0,
              duration: const Duration(milliseconds: 180),
              child: CircleAvatar(
                backgroundColor: LandingPage.primary.withAlpha(26),
                child: Icon(icon, color: LandingPage.primary),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: LandingPage.textDark,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// SECTION 6 – Impact Stats (light card, no dark bg — counts up on scroll)
// ══════════════════════════════════════════════════════════════
class _ImpactStats extends StatelessWidget {
  const _ImpactStats();
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: LandingPage.cardWhite,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xffE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: const Color.fromRGBO(0, 0, 0, 0.04),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            'Our Shared Success Metrics',
            style: TextStyle(
              color: LandingPage.textDark,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: const [
              _StatItem(value: 50, suffix: 'K+', title: 'Meals Saved'),
              _StatItem(value: 120, suffix: '+', title: 'NGO Partners'),
              _StatItem(value: 40, suffix: ' Tons', title: 'CO2 Saved'),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatefulWidget {
  final double value;
  final String suffix;
  final String title;
  const _StatItem({
    required this.value,
    required this.suffix,
    required this.title,
  });

  @override
  State<_StatItem> createState() => _StatItemState();
}

class _StatItemState extends State<_StatItem> {
  bool _visible = false;

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: Key('stat_${widget.title}'),
      onVisibilityChanged: (info) {
        if (!_visible && info.visibleFraction > 0.4) {
          setState(() => _visible = true);
        }
      },
      child: Column(
        children: [
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: _visible ? widget.value : 0),
            duration: const Duration(milliseconds: 1800),
            curve: Curves.easeOutCubic,
            builder: (context, val, child) {
              return Text(
                '${val.toInt()}${widget.suffix}',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: LandingPage.primary,
                ),
              );
            },
          ),
          const SizedBox(height: 4),
          Text(
            widget.title,
            style: const TextStyle(
              color: Color(0xff64748B),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// SECTION 7 – About Us
// ══════════════════════════════════════════════════════════════
class _AboutUs extends StatelessWidget {
  const _AboutUs();
  @override
  Widget build(BuildContext context) {
    return _buildSectionLayout(
      title: 'About Our Mission',
      subtitle: 'Zero waste, zero hunger—our continuous target objective.',
      child: _HoverLift(
        builder: (hovering) => AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: LandingPage.cardWhite,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: hovering ? LandingPage.amber : const Color(0xffE2E8F0),
              width: hovering ? 1.5 : 1,
            ),
            boxShadow: hovering
                ? [
                    BoxShadow(
                      color: LandingPage.primary.withAlpha(35),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ]
                : [],
          ),
          child: const Text(
            'FRAD provides centralized, cloud-enabled infrastructure linking agricultural businesses, dining vendors, and commercial sectors with charity organizations. We optimize excess provisions securely to remove nutritional deficits completely.',
            style: TextStyle(
              color: Color(0xff475569),
              fontSize: 14,
              height: 1.6,
            ),
          ),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// SECTION 8 – Contact Us
// ══════════════════════════════════════════════════════════════
class _ContactUs extends StatelessWidget {
  const _ContactUs();
  @override
  Widget build(BuildContext context) {
    return _buildSectionLayout(
      title: 'Get In Touch',
      subtitle: 'Questions? Our support team responds round-the-clock.',
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: LandingPage.cardWhite,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xffE2E8F0)),
        ),
        child: Column(
          children: const [
            _ContactTile(
              icon: Icons.mail_outline,
              title: 'support@fradapp.org',
            ),
            Divider(height: 24, color: Color(0xffE2E8F0)),
            _ContactTile(icon: Icons.phone_android, title: '+1 (800) 555-FRAD'),
          ],
        ),
      ),
    );
  }
}

class _ContactTile extends StatelessWidget {
  final IconData icon;
  final String title;
  const _ContactTile({required this.icon, required this.title});
  @override
  Widget build(BuildContext context) {
    return _HoverLift(
      builder: (hovering) => Row(
        children: [
          AnimatedScale(
            scale: hovering ? 1.15 : 1.0,
            duration: const Duration(milliseconds: 180),
            child: Icon(icon, color: LandingPage.primary, size: 22),
          ),
          const SizedBox(width: 14),
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: hovering ? LandingPage.primary : LandingPage.textDark,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// SECTION 9 – Portals Section (hover scale + glow)
// ══════════════════════════════════════════════════════════════
class _PortalsSection extends StatelessWidget {
  const _PortalsSection();
  @override
  Widget build(BuildContext context) {
    return _buildSectionLayout(
      title: 'Dedicated Ecosystem Portals',
      subtitle:
          'Tailored interfaces crafted specifically for operations roles.',
      child: Column(
        children: const [
          _PortalCard(
            title: 'Donor Control Panel',
            roles: 'Restaurants / Hotels / Retail',
          ),
          _PortalCard(
            title: 'Receiver Workspace',
            roles: 'NGOs / Food Banks / Shelters',
          ),
          _PortalCard(
            title: 'Admin Operations Base',
            roles: 'Compliance / Supervised Approvals',
          ),
        ],
      ),
    );
  }
}

class _PortalCard extends StatelessWidget {
  final String title;
  final String roles;
  const _PortalCard({required this.title, required this.roles});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: _HoverLift(
        builder: (hovering) => AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            color: LandingPage.cardWhite,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: hovering ? LandingPage.amber : const Color(0xffE2E8F0),
              width: hovering ? 1.5 : 1,
            ),
            boxShadow: hovering
                ? [
                    BoxShadow(
                      color: LandingPage.primary.withAlpha(30),
                      blurRadius: 14,
                      offset: const Offset(0, 6),
                    ),
                  ]
                : [],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: LandingPage.textDark,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      roles,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xff94A3B8),
                      ),
                    ),
                  ],
                ),
              ),
              AnimatedSlide(
                offset: hovering ? const Offset(0.15, 0) : Offset.zero,
                duration: const Duration(milliseconds: 180),
                child: const Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 14,
                  color: Color(0xff94A3B8),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// SECTION 10 – Footer (light bg, no dark color + social icons)
// ══════════════════════════════════════════════════════════════
class _Footer extends StatelessWidget {
  const _Footer();
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: LandingPage.bgLight,
      padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 24),
      child: Column(
        children: [
          const Text(
            'FRAD Ecosystem Alliance',
            style: TextStyle(
              color: LandingPage.textDark,
              fontWeight: FontWeight.bold,
              fontSize: 16,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              _SocialIconButton(
                icon: Icons
                    .business_center_rounded, // swap for LinkedIn logo asset if you add one
                url: LandingPage.linkedInUrl,
                tooltip: 'LinkedIn',
              ),
              SizedBox(width: 14),
              _SocialIconButton(
                icon: Icons
                    .code_rounded, // swap for GitHub logo asset if you add one
                url: LandingPage.githubUrl,
                tooltip: 'GitHub',
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            '© 2026 FRAD Inc. Saving sustainability values worldwide.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Color(0xff94A3B8), fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _SocialIconButton extends StatelessWidget {
  final IconData icon;
  final String url;
  final String tooltip;
  const _SocialIconButton({
    required this.icon,
    required this.url,
    required this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    return _HoverLift(
      builder: (hovering) => Tooltip(
        message: tooltip,
        child: InkWell(
          borderRadius: BorderRadius.circular(50),
          onTap: () async {
            final uri = Uri.parse(url);
            if (await canLaunchUrl(uri)) {
              await launchUrl(uri, mode: LaunchMode.externalApplication);
            }
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: hovering ? LandingPage.primary : LandingPage.cardWhite,
              border: Border.all(
                color: hovering ? LandingPage.primary : const Color(0xffE2E8F0),
              ),
              boxShadow: hovering
                  ? [
                      BoxShadow(
                        color: LandingPage.primary.withAlpha(60),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : [],
            ),
            child: Icon(
              icon,
              size: 20,
              color: hovering ? Colors.white : LandingPage.textDark,
            ),
          ),
        ),
      ),
    );
  }
}

// Helper Layout builder
Widget _buildSectionLayout({
  required String title,
  required String subtitle,
  required Widget child,
}) {
  return Padding(
    padding: const EdgeInsets.only(left: 20, right: 20, top: 32, bottom: 8),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w900,
            color: LandingPage.textDark,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: const TextStyle(fontSize: 14, color: Color(0xff64748B)),
        ),
        const SizedBox(height: 20),
        child,
      ],
    ),
  );
}
