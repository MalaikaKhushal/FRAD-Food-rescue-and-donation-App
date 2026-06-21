import 'package:flutter/material.dart';

class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key});

  static const Color primaryOrange = Color(0xffC75B12);
  static const Color amber = Color(0xffF59E0B);
  static const Color lightBg = Color(0xffFFFBF5);
  static const Color cardBg = Color(0xffFFFFFF);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightBg,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    _HeroSection(),
                    const SizedBox(height: 20),
                    _StatsRow(),
                    const SizedBox(height: 20),
                    _SectionHeader(title: 'Nearby Food', onSeeAll: () {}),
                    const SizedBox(height: 10),
                    _FoodListings(),
                    const SizedBox(height: 20),
                    _SectionHeader(title: 'Quick Actions'),
                    const SizedBox(height: 10),
                    _QuickActions(),
                    const SizedBox(height: 20),
                    _CharitySection(),
                    const SizedBox(height: 20),
                    _AddFoodButton(),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
            _BottomNavBar(),
          ],
        ),
      ),
    );
  }
}

// ─── Hero ────────────────────────────────────────────────────────────────────

class _HeroSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xffC75B12), Color(0xffF59E0B), Color(0xffFFD89B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -50,
            right: -50,
            child: Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.10),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            bottom: -60,
            left: -60,
            child: Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.07),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.95),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 20,
                      offset: Offset(0, 8),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.food_bank_rounded,
                  size: 40,
                  color: Color(0xffC75B12),
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'FRAD',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 3,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Food Rescue & Donation',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.20),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.circle, size: 8, color: Colors.greenAccent),
                    SizedBox(width: 6),
                    Text(
                      '23 listings available nearby',
                      style: TextStyle(fontSize: 12, color: Colors.white),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Together We Can End Food Waste',
                style: TextStyle(
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                  color: Colors.white70,
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/provider-home');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xffC75B12),
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        "I'm a Provider",
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/receiver-home');
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: const BorderSide(
                          color: Colors.white70,
                          width: 1.5,
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        "I'm a Receiver",
                        style: TextStyle(fontWeight: FontWeight.w600),
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

// ─── Stats ────────────────────────────────────────────────────────────────────

class _StatsRow extends StatelessWidget {
  final List<Map<String, String>> stats = const [
    {'value': '1.2k', 'label': 'Meals Saved'},
    {'value': '480', 'label': 'KG Rescued'},
    {'value': '38', 'label': 'Partners'},
  ];

  @override
  Widget build(BuildContext context) {
    return Row(
      children: stats
          .map(
            (s) => Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Text(
                      s['value']!,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xffC75B12),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      s['label']!,
                      style: const TextStyle(fontSize: 11, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}

// ─── Section Header ───────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback? onSeeAll;

  const _SectionHeader({required this.title, this.onSeeAll});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        if (onSeeAll != null)
          GestureDetector(
            onTap: onSeeAll,
            child: const Text(
              'See all →',
              style: TextStyle(
                fontSize: 13,
                color: Color(0xffC75B12),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
      ],
    );
  }
}

// ─── Food Listings ────────────────────────────────────────────────────────────

class _FoodListings extends StatelessWidget {
  final List<_FoodItem> items = const [
    _FoodItem(
      emoji: '🍛',
      name: 'Chicken Biryani',
      provider: 'UET Hostel Mess',
      quantity: '50 plates',
      pickup: '8PM – 9PM',
      price: 'Rs. 50',
      badgeColor: Color(0xffFEF3C7),
      badgeTextColor: Color(0xff92400E),
    ),
    _FoodItem(
      emoji: '🍩',
      name: 'Assorted Donuts',
      provider: 'ABC Bakery',
      quantity: '20 pieces',
      pickup: '9PM – 10PM',
      price: 'FREE',
      badgeColor: Color(0xffDBEAFE),
      badgeTextColor: Color(0xff1E40AF),
    ),
    _FoodItem(
      emoji: '🥗',
      name: 'Leftover Salads',
      provider: 'Grand Marriage Hall',
      quantity: '30 boxes',
      pickup: '7PM – 8PM',
      price: 'Rs. 30',
      badgeColor: Color(0xffD1FAE5),
      badgeTextColor: Color(0xff065F46),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: items
          .map(
            (item) => Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: const Color(0xffFFF8F0),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Center(
                      child: Text(
                        item.emoji,
                        style: const TextStyle(fontSize: 26),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          '${item.provider} · ${item.quantity}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            const Icon(
                              Icons.access_time,
                              size: 12,
                              color: Colors.grey,
                            ),
                            const SizedBox(width: 3),
                            Text(
                              item.pickup,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: item.badgeColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      item.price,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: item.badgeTextColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )
          .toList(),
    );
  }
}

class _FoodItem {
  final String emoji, name, provider, quantity, pickup, price;
  final Color badgeColor, badgeTextColor;

  const _FoodItem({
    required this.emoji,
    required this.name,
    required this.provider,
    required this.quantity,
    required this.pickup,
    required this.price,
    required this.badgeColor,
    required this.badgeTextColor,
  });
}

// ─── Quick Actions ────────────────────────────────────────────────────────────

class _QuickActions extends StatelessWidget {
  final List<Map<String, dynamic>> actions = const [
    {
      'icon': Icons.local_offer_rounded,
      'label': 'Discount Food',
      'sub': 'Surplus at low price',
      'bg': Color(0xffFEF3C7),
      'ic': Color(0xffB45309),
      'route': '/discount-food',
    },
    {
      'icon': Icons.favorite_rounded,
      'label': 'Free Donations',
      'sub': 'Zero cost meals',
      'bg': Color(0xffD1FAE5),
      'ic': Color(0xff059669),
      'route': '/free-food',
    },
    {
      'icon': Icons.bookmark_rounded,
      'label': 'My Reservations',
      'sub': 'Track your pickups',
      'bg': Color(0xffDBEAFE),
      'ic': Color(0xff2563EB),
      'route': '/reservations',
    },
    {
      'icon': Icons.bar_chart_rounded,
      'label': 'Impact Stats',
      'sub': 'Waste saved today',
      'bg': Color(0xffFFE4E6),
      'ic': Color(0xffE11D48),
      'route': '/stats',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      childAspectRatio: 1.5,
      children: actions
          .map(
            (a) => GestureDetector(
              onTap: () => Navigator.pushNamed(context, a['route']),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: a['bg'],
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(a['icon'], color: a['ic'], size: 20),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      a['label'],
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                    Text(
                      a['sub'],
                      style: const TextStyle(fontSize: 11, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}

// ─── Charity Section ──────────────────────────────────────────────────────────

class _CharitySection extends StatelessWidget {
  final List<Map<String, String>> ngos = const [
    {
      'emoji': '🤝',
      'name': 'Helping Hands NGO',
      'sub': 'Abbottabad · Serving 200+ daily',
    },
    {
      'emoji': '❤️',
      'name': 'Edhi Foundation',
      'sub': 'Nationwide · Food & shelter',
    },
    {
      'emoji': '🏦',
      'name': 'Pakistan Food Bank',
      'sub': 'Karachi · Emergency relief',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Charity Partners',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
              GestureDetector(
                onTap: () => Navigator.pushNamed(context, '/charities'),
                child: const Text(
                  'See all →',
                  style: TextStyle(
                    color: Color(0xffC75B12),
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...ngos.map(
            (ngo) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: const Color(0xffFEF3C7),
                    child: Text(
                      ngo['emoji']!,
                      style: const TextStyle(fontSize: 18),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          ngo['name']!,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                        Text(
                          ngo['sub']!,
                          style: const TextStyle(
                            fontSize: 11,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xffD1FAE5),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      'Active',
                      style: TextStyle(
                        fontSize: 11,
                        color: Color(0xff065F46),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Add Food Button ──────────────────────────────────────────────────────────

class _AddFoodButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () => Navigator.pushNamed(context, '/add-food'),
        icon: const Icon(Icons.add_circle_outline),
        label: const Text(
          'Add Surplus Food',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xffC75B12),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 4,
          shadowColor: const Color(0xffC75B12).withOpacity(0.4),
        ),
      ),
    );
  }
}

// ─── Bottom Nav Bar ───────────────────────────────────────────────────────────

class _BottomNavBar extends StatefulWidget {
  @override
  State<_BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<_BottomNavBar> {
  int _selected = 0;

  final List<Map<String, dynamic>> _items = const [
    {'icon': Icons.home_rounded, 'label': 'Home'},
    {'icon': Icons.search_rounded, 'label': 'Explore'},
    {'icon': Icons.notifications_rounded, 'label': 'Alerts'},
    {'icon': Icons.person_rounded, 'label': 'Profile'},
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(
              _items.length,
              (i) => GestureDetector(
                onTap: () => setState(() => _selected = i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: _selected == i
                        ? const Color(0xffC75B12).withOpacity(0.10)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _items[i]['icon'],
                        color: _selected == i
                            ? const Color(0xffC75B12)
                            : Colors.grey,
                        size: 24,
                      ),
                      const SizedBox(height: 3),
                      Text(
                        _items[i]['label'],
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: _selected == i
                              ? FontWeight.w600
                              : FontWeight.normal,
                          color: _selected == i
                              ? const Color(0xffC75B12)
                              : Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
