import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/auth_provider.dart';
import '../providers/analytics_provider.dart';
import '../config/app_colors.dart';

// ─────────────────────────────────────────────────────────────
// HOME SCREEN
// ─────────────────────────────────────────────────────────────
class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);
  @override State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _navIdx = 0;

  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<AnalyticsProvider>().fetchOverview());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.obsidian,
      appBar: _buildAppBar(),
      drawer: const _AppDrawer(),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        children: const [
          _HeroSection(),
          _KpiStrip(),
          _SectionLabel('Quick Access', 'All portal sections'),
          _QuickGrid(),
          _SectionLabel('Clinical Services', 'Hospitals · Vaccines · Calendar · Support'),
          _ServicesRow(),
          _SectionLabel('Portal Features', 'Research tools & international data'),
          _FeatureIconRow(),
          _SectionLabel('Health Indicators', 'Egypt 2024 · WHO GHO'),
          _IndicatorBar(),
          _SectionLabel('Browse by Category', '12 medical specialties'),
          _CategoryChips(),
          _MissionBlock(),
          _Footer(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _navIdx,
        height: 60,
        backgroundColor: AppColors.charcoal,
        surfaceTintColor: Colors.transparent,
        indicatorColor: AppColors.gold.withOpacity(0.15),
        onDestinationSelected: (i) {
          setState(() => _navIdx = i);
          const routes = ['/', '/datasets', '/dashboard', '/create-dataset', '/news'];
          if (i != 0) Navigator.pushNamed(context, routes[i]).then((_) => setState(() => _navIdx = 0));
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined),           selectedIcon: Icon(Icons.home_rounded),              label: 'Home'),
          NavigationDestination(icon: Icon(Icons.dataset_outlined),        selectedIcon: Icon(Icons.dataset_rounded),           label: 'Datasets'),
          NavigationDestination(icon: Icon(Icons.dashboard_outlined),      selectedIcon: Icon(Icons.dashboard_rounded),         label: 'Dashboard'),
          NavigationDestination(icon: Icon(Icons.document_scanner_outlined),selectedIcon: Icon(Icons.document_scanner_rounded), label: 'Create'),
          NavigationDestination(icon: Icon(Icons.newspaper_outlined),      selectedIcon: Icon(Icons.newspaper_rounded),         label: 'News'),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() => AppBar(
    backgroundColor: AppColors.charcoal,
    surfaceTintColor: Colors.transparent,
    bottom: PreferredSize(preferredSize: const Size.fromHeight(1), child: Container(height: 1, color: AppColors.border)),
    leading: Builder(builder: (ctx) => IconButton(
      icon: const Icon(Icons.menu_rounded, size: 20, color: AppColors.textSecondary),
      onPressed: () => Scaffold.of(ctx).openDrawer())),
    title: Row(mainAxisSize: MainAxisSize.min, children: [
      Container(
        width: 28, height: 28,
        decoration: BoxDecoration(color: AppColors.inkBlack, borderRadius: BorderRadius.circular(7), border: Border.all(color: AppColors.gold.withOpacity(0.35))),
        child: Center(child: ShaderMask(
          shaderCallback: (b) => AppColors.goldAccent.createShader(b),
          child: const Icon(Icons.health_and_safety_rounded, size: 16, color: Colors.white)))),
      const SizedBox(width: 9),
      Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
        Text('NHODP', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.textPrimary, letterSpacing: 0.5)),
        Text('Egypt Health Portal', style: GoogleFonts.inter(fontSize: 9, color: AppColors.textMuted)),
      ]),
    ]),
    actions: [
      IconButton(icon: const Icon(Icons.search_rounded, size: 20, color: AppColors.textSecondary), onPressed: () => Navigator.pushNamed(context, '/search')),
      Consumer<AuthProvider>(builder: (_, auth, __) => auth.isAuthenticated
        ? GestureDetector(
            onTap: () => Navigator.pushNamed(context, '/profile'),
            child: Container(
              margin: const EdgeInsets.fromLTRB(0, 10, 14, 10), width: 30, height: 30,
              decoration: BoxDecoration(shape: BoxShape.circle,
                gradient: const LinearGradient(colors: [AppColors.goldDim, AppColors.gold]),
                boxShadow: [BoxShadow(color: AppColors.gold.withOpacity(0.4), blurRadius: 8)]),
              child: Center(child: Text(
                auth.userName.isNotEmpty ? auth.userName[0].toUpperCase() : 'U',
                style: GoogleFonts.inter(color: AppColors.obsidian, fontWeight: FontWeight.w800, fontSize: 13)))))
        : Padding(
            padding: const EdgeInsets.only(right: 12),
            child: TextButton(
              onPressed: () => Navigator.pushNamed(context, '/login'),
              style: TextButton.styleFrom(
                backgroundColor: AppColors.gold.withOpacity(0.1), foregroundColor: AppColors.gold,
                minimumSize: const Size(0,0), padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(7), side: const BorderSide(color: AppColors.gold, width: 1))),
              child: Text('Sign in', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.gold))))),
    ],
  );
}

// ─── HERO ─────────────────────────────────────────────────────
class _HeroSection extends StatelessWidget {
  const _HeroSection();
  @override
  Widget build(BuildContext context) => Container(
    decoration: const BoxDecoration(color: Color(0xFF0C0C0C)),
    child: Stack(children: [
      CustomPaint(painter: _GridPainter()),
      Positioned(top: -40, right: -40, child: Container(width: 220, height: 220,
        decoration: BoxDecoration(shape: BoxShape.circle,
          gradient: RadialGradient(colors: [AppColors.gold.withOpacity(0.07), Colors.transparent])))),
      Positioned(top: 0, left: 0, right: 0, child: Container(height: 2, decoration: const BoxDecoration(gradient: AppColors.goldAccent))),
      Padding(
        padding: const EdgeInsets.fromLTRB(22, 36, 22, 32),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Gov badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(border: Border.all(color: Colors.white.withOpacity(0.09)), borderRadius: BorderRadius.circular(4), color: Colors.white.withOpacity(0.02)),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              SizedBox(width: 18, height: 12, child: Column(children: [
                Expanded(child: Container(color: AppColors.egyptRed)),
                Expanded(child: Container(color: Colors.white.withOpacity(0.8))),
                Expanded(child: Container(color: AppColors.charcoal)),
              ])),
              const SizedBox(width: 9),
              Text('ARAB REPUBLIC OF EGYPT · MINISTRY OF HEALTH',
                style: GoogleFonts.inter(color: Colors.white.withOpacity(0.35), fontSize: 8, letterSpacing: 1.8)),
            ])).animate().fadeIn(delay: 100.ms),
          const SizedBox(height: 20),
          Text('National Health\nOpen Data Portal',
            style: GoogleFonts.inter(fontSize: 32, fontWeight: FontWeight.w700, color: AppColors.textPrimary, height: 1.15, letterSpacing: -0.5))
            .animate(delay: 180.ms).fadeIn().slideY(begin: 0.1),
          const SizedBox(height: 8),
          Container(width: 40, height: 2, decoration: const BoxDecoration(gradient: AppColors.goldAccent))
            .animate(delay: 320.ms).scaleX(begin: 0),
          const SizedBox(height: 12),
          Text("Access Egypt's most comprehensive health datasets.\nFuel research. Inform policy. Save lives.",
            style: GoogleFonts.inter(fontSize: 13, color: Colors.white.withOpacity(0.42), height: 1.6))
            .animate(delay: 260.ms).fadeIn(),
          const SizedBox(height: 22),
          Row(children: [
            _HeroCTA(label: 'Browse Datasets', icon: Icons.dataset_rounded, route: '/datasets', filled: true),
            const SizedBox(width: 10),
            _HeroCTA(label: 'Dashboard', icon: Icons.dashboard_rounded, route: '/dashboard', filled: false),
          ]).animate(delay: 400.ms).fadeIn().slideY(begin: 0.08),
        ]),
      ),
    ]),
  );
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()..color = Colors.white.withOpacity(0.018)..strokeWidth = 0.5;
    for (double x = -size.height; x < size.width + size.height; x += 60)
      canvas.drawLine(Offset(x, 0), Offset(x + size.height, size.height), p);
  }
  @override bool shouldRepaint(_) => false;
}

class _HeroCTA extends StatelessWidget {
  final String label, route; final IconData icon; final bool filled;
  const _HeroCTA({required this.label, required this.icon, required this.route, required this.filled});
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: () => Navigator.pushNamed(context, route),
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
      decoration: filled
        ? BoxDecoration(gradient: const LinearGradient(colors: [AppColors.goldDim, AppColors.gold, AppColors.goldLight]),
            borderRadius: BorderRadius.circular(8), boxShadow: [BoxShadow(color: AppColors.gold.withOpacity(0.28), blurRadius: 14, offset: const Offset(0,5))])
        : BoxDecoration(borderRadius: BorderRadius.circular(8), border: Border.all(color: AppColors.border), color: Colors.white.withOpacity(0.03)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 14, color: filled ? AppColors.obsidian : AppColors.textSecondary),
        const SizedBox(width: 6),
        Text(label, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: filled ? AppColors.obsidian : AppColors.textSecondary)),
      ]),
    ),
  );
}

// ─── KPI STRIP ────────────────────────────────────────────────
class _KpiStrip extends StatelessWidget {
  const _KpiStrip();
  @override
  Widget build(BuildContext context) => Consumer<AnalyticsProvider>(builder: (_, a, __) {
    final o = a.overview;
    final dl = (o['total_downloads'] as num?)?.toInt() ?? 13800;
    final items = [
      ['12', 'Datasets'], [dl >= 1000 ? '${dl ~/ 1000}K+' : '$dl', 'Downloads'],
      ['27', 'Governorates'], ['18', 'Indicators'],
    ];
    return Container(
      color: AppColors.inkBlack,
      child: Column(children: [
        Container(height: 1, color: AppColors.border),
        Row(children: List.generate(items.length * 2 - 1, (i) {
          if (i.isOdd) return Container(width: 1, height: 46, color: AppColors.border);
          final s = items[i ~/ 2];
          return Expanded(child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 13),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              ShaderMask(shaderCallback: (b) => AppColors.goldAccent.createShader(b),
                child: Text(s[0], style: GoogleFonts.inter(fontSize: 19, fontWeight: FontWeight.w800, color: Colors.white))),
              const SizedBox(height: 1),
              Text(s[1], style: GoogleFonts.inter(fontSize: 9, color: AppColors.textMuted, letterSpacing: 0.4)),
            ])));
        })),
        Container(height: 1, color: AppColors.border),
      ]),
    );
  });
}

// ─── SECTION LABEL ────────────────────────────────────────────
class _SectionLabel extends StatelessWidget {
  final String title, sub;
  const _SectionLabel(this.title, this.sub);
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(18, 24, 18, 12),
    child: Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
      Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
        Text(title, style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
        Container(width: 24, height: 2, margin: const EdgeInsets.only(top: 4), decoration: const BoxDecoration(gradient: AppColors.goldAccent)),
      ]),
      const Spacer(),
      Text(sub, style: GoogleFonts.inter(fontSize: 10, color: AppColors.textMuted)),
    ]),
  );
}

// ─── QUICK GRID — 4 columns, compact icon squares ─────────────
class _QuickItem { final String label, route; final IconData icon; final Color color;
  const _QuickItem(this.label, this.icon, this.color, this.route); }

class _QuickGrid extends StatelessWidget {
  const _QuickGrid();
  static const _items = [
    _QuickItem('Dashboard',  Icons.dashboard_rounded,          AppColors.catHepato,    '/dashboard'),
    _QuickItem('Datasets',   Icons.dataset_rounded,           AppColors.catInfectious, '/datasets'),
    _QuickItem('Analytics',  Icons.analytics_rounded,          AppColors.catMental,    '/analytics'),
    _QuickItem('Disease Map',Icons.map_rounded,                AppColors.catPediatrics,'/disease-map'),
    _QuickItem('Indicators', Icons.monitor_heart_rounded,      AppColors.gold,         '/indicators'),
    _QuickItem('Create Dataset', Icons.document_scanner_rounded, AppColors.catCardio, '/create-dataset'),
    _QuickItem('News',       Icons.newspaper_rounded,          AppColors.catNutrition, '/news'),
    _QuickItem('Search',     Icons.search_rounded,             AppColors.catOncology,  '/search'),
  ];
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 18),
    child: GridView.builder(
      shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 4, crossAxisSpacing: 8, mainAxisSpacing: 8, childAspectRatio: 1.0),
      itemCount: _items.length,
      itemBuilder: (ctx, i) {
        final it = _items[i];
        return GestureDetector(
          onTap: () => Navigator.pushNamed(ctx, it.route),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.inkBlack, borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border)),
            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Container(width: 38, height: 38,
                decoration: BoxDecoration(color: it.color.withOpacity(0.1), borderRadius: BorderRadius.circular(9), border: Border.all(color: it.color.withOpacity(0.18))),
                child: Icon(it.icon, color: it.color, size: 18)),
              const SizedBox(height: 6),
              Text(it.label, style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.textPrimary), textAlign: TextAlign.center),
            ]),
          ).animate(delay: (i * 40).ms).fadeIn().scale(begin: const Offset(0.88, 0.88)));
      }));
}

// ─── SERVICES ROW — horizontal, slim pill cards ───────────────
class _ServiceItem { final String label, sub, route; final IconData icon; final Color color;
  const _ServiceItem(this.label, this.sub, this.icon, this.color, this.route); }

class _ServicesRow extends StatelessWidget {
  const _ServicesRow();
  static const _items = [
    _ServiceItem('Hospitals',    '20+ gov. hospitals', Icons.local_hospital_rounded,   AppColors.catCardio,    '/hospitals'),
    _ServiceItem('Vaccines',     'Schedules & coverage',Icons.vaccines_rounded,         AppColors.catHepato,    '/vaccines'),
    _ServiceItem('Calendar',     'Health campaigns',    Icons.event_rounded,            AppColors.catInfectious,'/health-calendar'),
    _ServiceItem('Support',      'Help & contact',      Icons.support_agent_rounded,    AppColors.gold,         '/support'),
    _ServiceItem('Publications', '10 research reports', Icons.menu_book_rounded,        AppColors.catMental,    '/publications'),
    _ServiceItem('Data Request', 'API & custom data',   Icons.request_page_rounded,     AppColors.catNutrition, '/data-request'),
  ];
  @override
  Widget build(BuildContext context) => SizedBox(
    height: 92,
    child: ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      scrollDirection: Axis.horizontal, itemCount: _items.length,
      itemBuilder: (ctx, i) {
        final s = _items[i];
        return GestureDetector(
          onTap: () => Navigator.pushNamed(ctx, s.route),
          child: Container(
            width: 118, margin: const EdgeInsets.only(right: 8),
            padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
            decoration: BoxDecoration(color: AppColors.inkBlack, borderRadius: BorderRadius.circular(11), border: Border.all(color: AppColors.border)),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
              Container(width: 28, height: 28,
                decoration: BoxDecoration(color: s.color.withOpacity(0.1), borderRadius: BorderRadius.circular(7)),
                child: Icon(s.icon, color: s.color, size: 14)),
              const SizedBox(height: 8),
              Text(s.label, style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textPrimary), maxLines: 1, overflow: TextOverflow.ellipsis),
              const SizedBox(height: 2),
              Text(s.sub, style: GoogleFonts.inter(fontSize: 9, color: AppColors.textMuted), maxLines: 1, overflow: TextOverflow.ellipsis),
            ])).animate(delay: (i * 50).ms).fadeIn().slideX(begin: 0.1));
      }));
}

// ─── FEATURE ICON ROW ─────────────────────────────────────────
class _FI { final String l, s, r; final IconData i;
  const _FI(this.l, this.s, this.i, this.r); }

class _FeatureIconRow extends StatelessWidget {
  const _FeatureIconRow();
  static const _items = [
    _FI('Health Indicators','WHO GHO — 18 KPIs',   Icons.monitor_heart_rounded, '/indicators'),
    _FI('Disease Map',      '27 governorates',      Icons.map_rounded,           '/disease-map'),
    _FI('Hospital Dir.',    '20+ hospitals',         Icons.local_hospital_rounded,'/hospitals'),
    _FI('Vaccination',      'Schedules & charts',   Icons.vaccines_rounded,      '/vaccines'),
    _FI('Publications',     '10 reports',           Icons.menu_book_rounded,     '/publications'),
    _FI('Data Request',     'API access',           Icons.request_page_rounded,  '/data-request'),
  ];
  @override
  Widget build(BuildContext context) => SizedBox(
    height: 76,
    child: ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      scrollDirection: Axis.horizontal, itemCount: _items.length,
      itemBuilder: (ctx, i) {
        final it = _items[i];
        return GestureDetector(
          onTap: () => Navigator.pushNamed(ctx, it.r),
          child: Container(
            width: 108, margin: const EdgeInsets.only(right: 8),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            decoration: BoxDecoration(color: AppColors.inkBlack, borderRadius: BorderRadius.circular(10), border: Border.all(color: AppColors.border)),
            child: Row(children: [
              Container(width: 28, height: 28, decoration: BoxDecoration(color: AppColors.elevated, borderRadius: BorderRadius.circular(6)),
                child: Icon(it.i, size: 14, color: AppColors.gold)),
              const SizedBox(width: 8),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
                Text(it.l, style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                Text(it.s, style: GoogleFonts.inter(fontSize: 9, color: AppColors.textMuted), overflow: TextOverflow.ellipsis),
              ])),
            ])).animate(delay: (i * 45).ms).fadeIn().slideX(begin: 0.08));
      }));
}

// ─── INDICATOR BAR — horizontal compact numbers ───────────────
class _IndItem { final String v, u, l; final Color c;
  const _IndItem(this.v, this.u, this.l, this.c); }

class _IndicatorBar extends StatelessWidget {
  const _IndicatorBar();
  static const _items = [
    _IndItem('72.4','yrs','Life Expectancy', AppColors.catHepato),
    _IndItem('93.2','%',  'DTP3 Coverage',   AppColors.catInfectious),
    _IndItem('0.87','%',  'Hepatitis C',     AppColors.catEndocrine),
    _IndItem('17.2','%',  'Diabetes Rate',   AppColors.catCardio),
  ];
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 18),
    child: Row(children: List.generate(_items.length, (i) {
      final m = _items[i];
      return Expanded(child: Container(
        margin: EdgeInsets.only(right: i < _items.length - 1 ? 8 : 0),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: AppColors.inkBlack, borderRadius: BorderRadius.circular(10), border: Border.all(color: AppColors.border)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
          Container(width: 3, height: 14, decoration: BoxDecoration(color: m.c, borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 6),
          RichText(text: TextSpan(children: [
            TextSpan(text: m.v, style: GoogleFonts.inter(fontSize: 17, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
            TextSpan(text: m.u, style: GoogleFonts.inter(fontSize: 8, color: AppColors.textMuted)),
          ])),
          const SizedBox(height: 2),
          Text(m.l, style: GoogleFonts.inter(fontSize: 9, color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
        ])).animate(delay: (i * 55).ms).fadeIn());
    })));
}

// ─── CATEGORY CHIPS — compact grid ───────────────────────────
class _CatChip { final String name; final Color color; final IconData icon;
  const _CatChip(this.name, this.color, this.icon); }

class _CategoryChips extends StatelessWidget {
  const _CategoryChips();
  static const _cats = [
    _CatChip('Oncology',          AppColors.catOncology,   Icons.biotech_rounded),
    _CatChip('Infectious Disease',AppColors.catInfectious, Icons.coronavirus_rounded),
    _CatChip('Endocrinology',     AppColors.catEndocrine,  Icons.monitor_heart_rounded),
    _CatChip('Cardiology',        AppColors.catCardio,     Icons.favorite_rounded),
    _CatChip('Hepatology',        AppColors.catHepato,     Icons.vaccines_rounded),
    _CatChip('Maternal Health',   AppColors.catMaternal,   Icons.pregnant_woman_rounded),
    _CatChip('Mental Health',     AppColors.catMental,     Icons.psychology_rounded),
    _CatChip('Pediatrics',        AppColors.catPediatrics, Icons.child_care_rounded),
  ];
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 18),
    child: Wrap(spacing: 8, runSpacing: 8, children: List.generate(_cats.length, (i) {
      final c = _cats[i];
      return GestureDetector(
        onTap: () => Navigator.pushNamed(context, '/datasets'),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(color: AppColors.inkBlack, borderRadius: BorderRadius.circular(20), border: Border.all(color: AppColors.border)),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Container(width: 6, height: 6, decoration: BoxDecoration(color: c.color, shape: BoxShape.circle)),
            const SizedBox(width: 7),
            Icon(c.icon, size: 13, color: c.color),
            const SizedBox(width: 6),
            Text(c.name, style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
          ])).animate(delay: (i * 35).ms).fadeIn().scale(begin: const Offset(0.92, 0.92)));
    })));
}

// ─── MISSION BLOCK ────────────────────────────────────────────
class _MissionBlock extends StatelessWidget {
  const _MissionBlock();
  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.fromLTRB(18, 28, 18, 0),
    padding: const EdgeInsets.all(22),
    decoration: BoxDecoration(color: AppColors.inkBlack, borderRadius: BorderRadius.circular(14),
      border: Border.all(color: AppColors.gold.withOpacity(0.2)),
      boxShadow: [BoxShadow(color: AppColors.gold.withOpacity(0.04), blurRadius: 20, offset: const Offset(0, 6))]),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
      Container(width: 28, height: 2, decoration: const BoxDecoration(gradient: AppColors.goldAccent)),
      const SizedBox(height: 12),
      Text('Open Data.\nPublic Health.\nEgypt\'s Future.',
        style: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.textPrimary, height: 1.25)),
      const SizedBox(height: 10),
      Text('NHODP transforms fragmented ministry records into open, machine-readable, privacy-protected datasets — powering research and policy for 104 million Egyptians.',
        style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary, height: 1.65)),
      const SizedBox(height: 16),
      Row(children: [
        _MiniStat('100%', 'Open Access'),
        Container(width: 1, height: 28, color: AppColors.border, margin: const EdgeInsets.symmetric(horizontal: 16)),
        _MiniStat('GDPR', 'Compliant'),
        Container(width: 1, height: 28, color: AppColors.border, margin: const EdgeInsets.symmetric(horizontal: 16)),
        _MiniStat('WHO', 'Standards'),
      ]),
    ]));
}

class _MiniStat extends StatelessWidget {
  final String v, l;
  const _MiniStat(this.v, this.l);
  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
    Text(v, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.gold)),
    Text(l, style: GoogleFonts.inter(fontSize: 10, color: AppColors.textMuted)),
  ]);
}

// ─── FOOTER ───────────────────────────────────────────────────
class _Footer extends StatelessWidget {
  const _Footer();
  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(top: 28),
    padding: const EdgeInsets.all(20),
    color: AppColors.charcoal,
    child: Column(children: [
      Container(height: 1, color: AppColors.border, margin: const EdgeInsets.only(bottom: 16)),
      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        Container(width: 20, height: 20, decoration: BoxDecoration(color: AppColors.inkBlack, borderRadius: BorderRadius.circular(5), border: Border.all(color: AppColors.gold.withOpacity(0.3))),
          child: Center(child: ShaderMask(shaderCallback: (b) => AppColors.goldAccent.createShader(b), child: const Icon(Icons.health_and_safety_rounded, size: 12, color: Colors.white)))),
        const SizedBox(width: 7),
        Text('NHODP', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.textPrimary, letterSpacing: 0.5)),
      ]),
      const SizedBox(height: 10),
      Text('Nile University · ITCS-GP25-96 · Graduation Project II', style: GoogleFonts.inter(fontSize: 10, color: AppColors.textMuted), textAlign: TextAlign.center),
      const SizedBox(height: 4),
      Text('Nourhan Samir  ·  Ahmed Helmy  ·  Eyad Osama Aly  ·  Omar Refaat Ahmed  ·  Ahmed Magdy Elhossany',
        style: GoogleFonts.inter(fontSize: 9, color: AppColors.textMuted), textAlign: TextAlign.center),
      const SizedBox(height: 4),
      Text('Supervisors: Dr. Islam Tharwat  ·  Dr. Heba Aslan', style: GoogleFonts.inter(fontSize: 9, color: AppColors.textMuted), textAlign: TextAlign.center),
      const SizedBox(height: 12),
      Container(height: 1, color: AppColors.border),
      const SizedBox(height: 10),
      Text('© 2026 NHODP — Arab Republic of Egypt, Ministry of Health', style: GoogleFonts.inter(fontSize: 9, color: AppColors.textMuted.withOpacity(0.6)), textAlign: TextAlign.center),
    ]));
}

// ─── APP DRAWER ───────────────────────────────────────────────
class _AppDrawer extends StatelessWidget {
  const _AppDrawer();
  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    const sections = [
      ['/', 'Home', Icons.home_rounded],
      ['/dashboard', 'Dashboard', Icons.dashboard_rounded],
      ['/datasets', 'Datasets', Icons.dataset_rounded],
      ['/analytics', 'Analytics', Icons.analytics_rounded],
      ['/disease-map', 'Disease Map', Icons.map_rounded],
      ['/indicators', 'Health Indicators', Icons.monitor_heart_rounded],
      ['/create-dataset', 'Create Dataset', Icons.document_scanner_rounded],
      ['/hospitals', 'Hospitals', Icons.local_hospital_rounded],
      ['/vaccines', 'Vaccines', Icons.vaccines_rounded],
      ['/health-calendar', 'Health Calendar', Icons.event_rounded],
      ['/news', 'News', Icons.newspaper_rounded],
      ['/publications', 'Publications', Icons.menu_book_rounded],
      ['/data-request', 'Data Request', Icons.request_page_rounded],
      ['/support', 'Support', Icons.support_agent_rounded],
      ['/about', 'About', Icons.info_rounded],
    ];
    return Drawer(
      child: Column(children: [
        Container(
          padding: const EdgeInsets.fromLTRB(18, 52, 18, 20),
          color: AppColors.charcoal,
          child: Row(children: [
            Container(width: 36, height: 36, decoration: BoxDecoration(color: AppColors.inkBlack, borderRadius: BorderRadius.circular(9), border: Border.all(color: AppColors.gold.withOpacity(0.35))),
              child: Center(child: ShaderMask(shaderCallback: (b) => AppColors.goldAccent.createShader(b), child: const Icon(Icons.health_and_safety_rounded, size: 20, color: Colors.white)))),
            const SizedBox(width: 11),
            Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
              Text('NHODP', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textPrimary, letterSpacing: 0.5)),
              Text('Egypt Health Portal', style: GoogleFonts.inter(fontSize: 10, color: AppColors.textMuted)),
            ]),
          ])),
        Expanded(child: ListView(children: [
          ...sections.map((s) => ListTile(
            dense: true,
            leading: Icon(s[2] as IconData, size: 18, color: AppColors.textMuted),
            title: Text(s[1] as String, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
            onTap: () { Navigator.pop(context); Navigator.pushNamed(context, s[0] as String); },
            contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 0),
          )),
        ])),
        Container(color: AppColors.charcoal, padding: const EdgeInsets.all(14), child: auth.isAuthenticated
          ? ListTile(dense: true,
              leading: Container(width: 28, height: 28, decoration: BoxDecoration(shape: BoxShape.circle, gradient: const LinearGradient(colors: [AppColors.goldDim, AppColors.gold])),
                child: Center(child: Text(auth.userName.isNotEmpty ? auth.userName[0].toUpperCase() : 'U', style: GoogleFonts.inter(color: AppColors.obsidian, fontWeight: FontWeight.w800, fontSize: 13)))),
              title: Text(auth.userName, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
              subtitle: Text(auth.userRole.toUpperCase(), style: GoogleFonts.inter(fontSize: 9, color: AppColors.textMuted, letterSpacing: 1)),
              trailing: IconButton(icon: const Icon(Icons.logout_rounded, size: 18, color: AppColors.textMuted), onPressed: () { Navigator.pop(context); auth.logout(); }))
          : GestureDetector(onTap: () { Navigator.pop(context); Navigator.pushNamed(context, '/login'); },
              child: Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(borderRadius: BorderRadius.circular(9), border: Border.all(color: AppColors.gold.withOpacity(0.35)), color: AppColors.gold.withOpacity(0.05)),
                child: Row(children: [
                  const Icon(Icons.login_rounded, size: 16, color: AppColors.gold),
                  const SizedBox(width: 8),
                  Text('Sign in', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.gold)),
                  const Spacer(),
                  const Icon(Icons.chevron_right_rounded, size: 16, color: AppColors.gold),
                ])))),
      ]),
    );
  }
}
