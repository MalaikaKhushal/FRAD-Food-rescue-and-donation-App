import 'package:flutter/material.dart';
import 'loginscreen.dart';
import 'signupscreen.dart';
// ─────────────────────────────────────────────────────────────
//  FRAD – Landing Page  (landingpage.dart)
//  Place this file in:  lib/screens/landingpage.dart
// ─────────────────────────────────────────────────────────────

class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  // ── Brand colors (same as SplashScreen) ──
  static const Color primary = Color(0xffC75B12);
  static const Color amber = Color(0xffF59E0B);
  static const Color lightGold = Color(0xffFFD89B);
  static const Color bgLight = Color(0xffFFFBF5);
  static const Color cardWhite = Color(0xffFFFFFF);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgLight,
      body: SingleChildScrollView(
        child: Column(
          children: const [
            _AppHeader(),
            _HeroBanner(),
            _ProvidersSection(),
            _HowItWorks(),
            _KeyFeatures(),
            _ImpactStats(),
            _AboutUs(),
            _ContactUs(),
            _PortalsSection(),
            _Footer(),
          ],
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
      padding: const EdgeInsets.only(top: 52, bottom: 18, left: 20, right: 20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xffC75B12), Color(0xffF59E0B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.95),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.food_bank_rounded,
              size: 30,
              color: Color(0xffC75B12),
            ),
          ),
          const SizedBox(width: 12),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'FRAD',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 2,
                ),
              ),
              Text(
                'Food Rescue & Donation App',
                style: TextStyle(fontSize: 11, color: Colors.white70),
              ),
              Text(
                'Save Food • Save Money • Help Communities',
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.white60,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
//  SECTION 2 – Hero Banner
// ══════════════════════════════════════════════════════════════
class _HeroBanner extends StatelessWidget {
  const _HeroBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 36),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xffC75B12), Color(0xffF59E0B), Color(0xffFFD89B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xffC75B12).withValues(alpha: 0.35),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Decorative circles
          Positioned(
            top: -40,
            right: -40,
            child: Container(
              width: 130,
              height: 130,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.10),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            bottom: -60,
            left: -60,
            child: Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.07),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text('🍱', style: TextStyle(fontSize: 52)),
              const SizedBox(height: 16),
              const Text(
                'Reduce Food Waste',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Connect Extra Food With People Who Need It',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white70,
                  fontStyle: FontStyle.italic,
                ),
              ),

              const SizedBox(height: 28),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const LoginScreen(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xffC75B12),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Sign In',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SignupScreen(),
                          ),
                        );
                      },

                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: const BorderSide(
                          color: Colors.white70,
                          width: 1.8,
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),

                      child: const Text(
                        'Create Account',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
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
//  SECTION 3 – Our Providers
// ══════════════════════════════════════════════════════════════
class _ProvidersSection extends StatelessWidget {
  const _ProvidersSection();

  static const List<Map<String, dynamic>> _providers = [
    {
      'emoji': '🍔',
      'title': 'Restaurant',
      'desc': 'Upload extra burgers, pizza and more',
      'bg': Color(0xffFFF3E0),
    },
    {
      'emoji': '🥐',
      'title': 'Bakery',
      'desc': 'Upload pastries, cakes and bread',
      'bg': Color(0xffFCE4EC),
    },
    {
      'emoji': '🍱',
      'title': 'Hostel Mess',
      'desc': 'Upload extra meal boxes daily',
      'bg': Color(0xffE8F5E9),
    },
    {
      'emoji': '🎉',
      'title': 'Event Caterer',
      'desc': 'Upload leftover event food',
      'bg': Color(0xffE3F2FD),
    },
  ];

  @override
  Widget build(BuildContext context) {
    return _Section(
      label: 'OUR PROVIDERS',
      title: 'Who Shares Food on FRAD?',
      child: GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.1,
        children: _providers.map((p) {
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: p['bg'],
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(p['emoji'], style: const TextStyle(fontSize: 32)),
                const SizedBox(height: 8),
                Text(
                  p['title'],
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Color(0xff1A1A1A),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  p['desc'],
                  style: const TextStyle(fontSize: 12, color: Colors.black54),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
//  SECTION 4 – How It Works
// ══════════════════════════════════════════════════════════════
class _HowItWorks extends StatelessWidget {
  const _HowItWorks();

  static const List<Map<String, dynamic>> _steps = [
    {
      'icon': Icons.upload_rounded,
      'step': '01',
      'title': 'Provider Uploads Food',
      'desc':
          'Restaurant, bakery or hostel posts surplus food with quantity and pickup time.',
    },
    {
      'icon': Icons.bookmark_add_rounded,
      'step': '02',
      'title': 'Customer Reserves Food',
      'desc':
          'Nearby users browse listings and reserve what they need instantly.',
    },
    {
      'icon': Icons.qr_code_rounded,
      'step': '03',
      'title': 'QR Code Generated',
      'desc': 'A unique QR code is sent to the customer for secure pickup.',
    },
    {
      'icon': Icons.check_circle_rounded,
      'step': '04',
      'title': 'Pickup Completed',
      'desc': 'Provider scans QR, order confirmed. Food saved, money saved!',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return _Section(
      label: 'HOW IT WORKS',
      title: 'Simple 4-Step Process',
      bgColor: const Color(0xffFFF8F0),
      child: Column(
        children: List.generate(_steps.length, (i) {
          final s = _steps[i];
          return Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xffC75B12), Color(0xffF59E0B)],
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          s['icon'] as IconData,
                          color: Colors.white,
                          size: 22,
                        ),
                      ),
                      if (i < _steps.length - 1)
                        Container(
                          width: 2,
                          height: 36,
                          color: const Color(0xffF59E0B).withValues(alpha: 0.4),
                        ),
                    ],
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            s['step'],
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Color(0xffF59E0B),
                              letterSpacing: 1.5,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            s['title'],
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Color(0xff1A1A1A),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            s['desc'],
                            style: const TextStyle(
                              fontSize: 13,
                              color: Colors.black54,
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          );
        }),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
//  SECTION 5 – Key Features
// ══════════════════════════════════════════════════════════════
class _KeyFeatures extends StatelessWidget {
  const _KeyFeatures();

  static const List<Map<String, dynamic>> _features = [
    {
      'icon': Icons.volunteer_activism_rounded,
      'title': 'Food Rescue',
      'desc': 'Rescue edible food before it goes to waste.',
      'bg': Color(0xffFEF3C7),
      'ic': Color(0xffB45309),
    },
    {
      'icon': Icons.local_offer_rounded,
      'title': 'Discounted Food',
      'desc': 'Get quality meals at a fraction of the price.',
      'bg': Color(0xffD1FAE5),
      'ic': Color(0xff059669),
    },
    {
      'icon': Icons.qr_code_scanner_rounded,
      'title': 'QR Verification',
      'desc': 'Secure and contactless pickup every time.',
      'bg': Color(0xffDBEAFE),
      'ic': Color(0xff2563EB),
    },
    {
      'icon': Icons.wifi_rounded,
      'title': 'Real-Time Availability',
      'desc': 'Live updates on food listings near you.',
      'bg': Color(0xffFFE4E6),
      'ic': Color(0xffE11D48),
    },
    {
      'icon': Icons.notifications_active_rounded,
      'title': 'Notifications',
      'desc': 'Instant alerts when new food is posted.',
      'bg': Color(0xffF3E8FF),
      'ic': Color(0xff7C3AED),
    },
    {
      'icon': Icons.track_changes_rounded,
      'title': 'Smart Tracking',
      'desc': 'Track how much food you have saved.',
      'bg': Color(0xffFFF3E0),
      'ic': Color(0xffC75B12),
    },
  ];

  @override
  Widget build(BuildContext context) {
    return _Section(
      label: 'KEY FEATURES',
      title: 'Everything You Need',
      child: GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.2,
        children: _features.map((f) {
          return Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: f['bg'],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    f['icon'] as IconData,
                    color: f['ic'] as Color,
                    size: 22,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  f['title'],
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  f['desc'],
                  style: const TextStyle(
                    fontSize: 11,
                    color: Colors.grey,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
//  SECTION 6 – Impact Statistics
// ══════════════════════════════════════════════════════════════
class _ImpactStats extends StatelessWidget {
  const _ImpactStats();

  static const List<Map<String, String>> _stats = [
    {'value': '2,500 KG', 'label': 'Food Saved'},
    {'value': '8,000+', 'label': 'Meals Rescued'},
    {'value': '120+', 'label': 'Providers'},
    {'value': '5,000+', 'label': 'Orders Completed'},
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xffC75B12), Color(0xffF59E0B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          const Text(
            'OUR IMPACT',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: Colors.white70,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Numbers That Matter',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 24),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 2,
            children: _stats.map((s) {
              return Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      s['value']!,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      s['label']!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 11,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
//  SECTION 7 – About Us
// ══════════════════════════════════════════════════════════════
class _AboutUs extends StatelessWidget {
  const _AboutUs();

  @override
  Widget build(BuildContext context) {
    return _Section(
      label: 'ABOUT US',
      title: 'What is FRAD?',
      bgColor: const Color(0xffFFF8F0),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: const Color(0xffF59E0B).withValues(alpha: 0.3),
            width: 1.5,
          ),
        ),
        child: Column(
          children: [
            const Icon(
              Icons.food_bank_rounded,
              size: 48,
              color: Color(0xffC75B12),
            ),
            const SizedBox(height: 14),
            const Text(
              'FRAD is a platform that helps restaurants, bakeries, hostel messes and event caterers share surplus food instead of wasting it.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.black87,
                height: 1.6,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'We believe every extra meal deserves a second chance — not a trash bin. Join FRAD and be part of the food rescue movement.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: Colors.black54,
                height: 1.6,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
//  SECTION 8 – Contact Us
// ══════════════════════════════════════════════════════════════
class _ContactUs extends StatelessWidget {
  const _ContactUs();

  static const List<Map<String, dynamic>> _contacts = [
    {
      'icon': Icons.email_rounded,
      'label': 'Email',
      'value': 'support@frad.com',
    },
    {'icon': Icons.phone_rounded, 'label': 'Phone', 'value': '+92-XXX-XXXXXXX'},
    {
      'icon': Icons.location_on_rounded,
      'label': 'Location',
      'value': 'COMSATS Abbottabad',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return _Section(
      label: 'CONTACT US',
      title: 'Get in Touch',
      child: Column(
        children: _contacts.map((c) {
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xffC75B12), Color(0xffF59E0B)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    c['icon'] as IconData,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 14),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      c['label'],
                      style: const TextStyle(
                        fontSize: 11,
                        color: Colors.grey,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      c['value'],
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xff1A1A1A),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
//  SECTION 9 – Portals Section
// ══════════════════════════════════════════════════════════════
class _PortalsSection extends StatelessWidget {
  const _PortalsSection();

  static const List<Map<String, dynamic>> _portals = [
    {
      'icon': Icons.person_rounded,
      'title': 'Customer Portal',
      'sub': 'Browse Food',
      'bg': Color(0xffFFF3E0),
      'ic': Color(0xffC75B12),
      'route': '/customer',
    },
    {
      'icon': Icons.restaurant_rounded,
      'title': 'Restaurant Portal',
      'sub': 'Manage Listings',
      'bg': Color(0xffFCE4EC),
      'ic': Color(0xffE11D48),
      'route': '/restaurant',
    },
    {
      'icon': Icons.bakery_dining_rounded,
      'title': 'Bakery Portal',
      'sub': 'Manage Products',
      'bg': Color(0xffFFF8E1),
      'ic': Color(0xffF59E0B),
      'route': '/bakery',
    },
    {
      'icon': Icons.dinner_dining_rounded,
      'title': 'Hostel Mess Portal',
      'sub': 'Manage Meals',
      'bg': Color(0xffE8F5E9),
      'ic': Color(0xff059669),
      'route': '/hostel',
    },
    {
      'icon': Icons.celebration_rounded,
      'title': 'Event Caterer Portal',
      'sub': 'Manage Events',
      'bg': Color(0xffE3F2FD),
      'ic': Color(0xff2563EB),
      'route': '/caterer',
    },
    {
      'icon': Icons.admin_panel_settings_rounded,
      'title': 'Admin Portal',
      'sub': 'System Control',
      'bg': Color(0xffF3E8FF),
      'ic': Color(0xff7C3AED),
      'route': '/admin',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return _Section(
      label: 'PORTALS',
      title: 'Choose Your Portal',
      bgColor: const Color(0xffFFF8F0),
      child: Column(
        children: _portals.map((p) {
          return GestureDetector(
            onTap: () => Navigator.pushNamed(context, p['route']),
            child: Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: p['bg'],
                      borderRadius: BorderRadius.circular(13),
                    ),
                    child: Icon(
                      p['icon'] as IconData,
                      color: p['ic'] as Color,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          p['title'],
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          p['sub'],
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.chevron_right_rounded,
                    color: Colors.grey,
                    size: 22,
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
//  SECTION 10 – Footer
// ══════════════════════════════════════════════════════════════
class _Footer extends StatelessWidget {
  const _Footer();

  static const List<String> _links = [
    'Home',
    'About Us',
    'Contact Us',
    'Privacy Policy',
    'Terms & Conditions',
    'FAQs',
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xffC75B12), Color(0xffF59E0B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.food_bank_rounded,
                  size: 22,
                  color: Color(0xffC75B12),
                ),
              ),
              const SizedBox(width: 10),
              const Text(
                'FRAD',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Save Food • Share Kindness • Reduce Waste',
            style: TextStyle(fontSize: 12, color: Colors.white70),
          ),
          const SizedBox(height: 24),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 16,
            runSpacing: 10,
            children: _links.map((link) {
              return GestureDetector(
                onTap: () {},
                child: Text(
                  link,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
          Divider(color: Colors.white.withValues(alpha: 0.3)),
          const SizedBox(height: 16),
          const Text(
            '© 2025 FRAD — COMSATS Abbottabad',
            style: TextStyle(fontSize: 12, color: Colors.white60),
          ),
          const Text(
            'All rights reserved.',
            style: TextStyle(fontSize: 11, color: Colors.white54),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
//  REUSABLE: _Section wrapper
// ══════════════════════════════════════════════════════════════
class _Section extends StatelessWidget {
  final String label;
  final String title;
  final Widget child;
  final Color? bgColor;

  const _Section({
    required this.label,
    required this.title,
    required this.child,
    this.bgColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: bgColor ?? const Color(0xffFFFBF5),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: Color(0xffF59E0B),
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xff1A1A1A),
            ),
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}
