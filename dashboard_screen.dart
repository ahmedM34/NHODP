import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/analytics_provider.dart';
import '../providers/auth_provider.dart';
import '../config/app_colors.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);
  @override State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> with SingleTickerProviderStateMixin {
  late TabController _tabs;
  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 3, vsync: this);
    Future.microtask(() => context.read<AnalyticsProvider>().fetchAll());
  }
  @override void dispose() { _tabs.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.obsidian,
      appBar: AppBar(
        backgroundColor: AppColors.charcoal,
        surfaceTintColor: Colors.transparent,
        bottom: PreferredSize(preferredSize: const Size.fromHeight(49), child: Column(children: [
          Container(height: 1, color: AppColors.border),
          TabBar(controller: _tabs, indicatorColor: AppColors.gold, indicatorWeight: 2,
            labelColor: AppColors.gold, unselectedLabelColor: AppColors.textMuted,
            labelStyle: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 12),
            dividerColor: Colors.transparent,
            tabs: const [Tab(text: 'Overview'), Tab(text: 'Indicators'), Tab(text: 'Services')]),
        ])),
        title: Row(children: [
          // Egypt flag
          Container(width: 28, height: 18, decoration: BoxDecoration(borderRadius: BorderRadius.circular(2), border: Border.all(color: AppColors.border.withOpacity(0.5))),
            child: Column(children: [
              Expanded(child: Container(color: const Color(0xFFCE1126))),
              Expanded(child: Container(color: Colors.white)),
              Expanded(child: Container(color: const Color(0xFF000000))),
            ])),
          const SizedBox(width: 10),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Dashboard', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
            Text('National Health Portal — Egypt 2024', style: GoogleFonts.inter(fontSize: 9, color: AppColors.textMuted)),
          ]),
          const Spacer(),
          Consumer<AuthProvider>(builder: (_, auth, __) => Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(color: AppColors.gold.withOpacity(0.1), borderRadius: BorderRadius.circular(4), border: Border.all(color: AppColors.gold.withOpacity(0.35))),
            child: Text(auth.isAuthenticated ? auth.userRole.toUpperCase() : 'PUBLIC',
              style: GoogleFonts.inter(color: AppColors.gold, fontSize: 9, letterSpacing: 1.5, fontWeight: FontWeight.w700)))),
        ]),
      ),
      body: TabBarView(controller: _tabs, children: [
        _OverviewTab(),
        _IndicatorsTab(),
        _ServicesTab(),
      ]),
    );
  }
}

// ── OVERVIEW TAB ──────────────────────────────────────────────
class _OverviewTab extends StatelessWidget {
  static const _kpis = [
    _KD('72.4', 'yrs', 'Life Expectancy',   '+0.5y/yr',  true,  AppColors.catHepato),
    _KD('17.5',  '‰',  'Infant Mortality',  '−1.5/yr',   true,  AppColors.catCardio),
    _KD('93.2',  '%',  'DTP3 Coverage',     '+0.7%/yr',  true,  AppColors.catInfectious),
    _KD('0.87',  '%',  'Hepatitis C',       '−0.73%/yr', true,  AppColors.catHepato),
    _KD('17.2',  '%',  'Diabetes Rate',     '+0.5%/yr',  false, AppColors.catEndocrine),
    _KD('62',    '/100','UHC Index',         '+1.5/yr',   true,  AppColors.catInfectious),
    _KD('26.3',  '%',  'Hypertension',      '+0.6%/yr',  false, AppColors.catOncology),
    _KD('52',    '',   'Mat. Mortality',    '−5/yr',     true,  AppColors.catMaternal),
  ];

  static const _alerts = [
    _AD('CRITICAL', 'Influenza Season Active', 'Oct–Mar 2025 H3N2 dominant strain. 15M doses distributed.', AppColors.catCardio, Icons.emergency_rounded),
    _AD('WARNING',  'Diabetes Prevalence Rising', '17.2% — exceeds WHO regional average of 12.2%.', AppColors.warning, Icons.trending_up_rounded),
    _AD('INFO',     'Hepatitis C Elimination', 'Prevalence < 1% — WHO target achieved 3 years early.', AppColors.catHepato, Icons.verified_rounded),
  ];

  @override
  Widget build(BuildContext context) {
    return ListView(padding: const EdgeInsets.all(14), children: [
      // Alert strip
      ..._alerts.asMap().entries.map((e) => _AlertCard(a: e.value).animate(delay: (e.key * 60).ms).fadeIn()),
      const SizedBox(height: 14),
      // KPI grid - 2 columns, compact
      Text('Key Performance Indicators', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
      Container(width: 32, height: 2, margin: const EdgeInsets.only(top: 4, bottom: 10), decoration: BoxDecoration(gradient: AppColors.goldAccent)),
      GridView.builder(
        shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 8, mainAxisSpacing: 8, mainAxisExtent: 90),
        itemCount: _kpis.length,
        itemBuilder: (_, i) => _KpiCard(k: _kpis[i]).animate(delay: (i * 40).ms).fadeIn()),
      const SizedBox(height: 14),
      // Trend chart
      _TrendChart(),
      const SizedBox(height: 14),
      // Egypt health at a glance
      _EgyptSnapshot(),
    ]);
  }
}

class _KD {
  final String v, unit, label, trend; final bool good; final Color c;
  const _KD(this.v, this.unit, this.label, this.trend, this.good, this.c);
}

class _AD {
  final String level, title, body; final Color c; final IconData icon;
  const _AD(this.level, this.title, this.body, this.c, this.icon);
}

class _AlertCard extends StatelessWidget {
  final _AD a;
  const _AlertCard({required this.a});
  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 8),
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    decoration: BoxDecoration(color: a.c.withOpacity(0.08), borderRadius: BorderRadius.circular(8), border: Border.all(color: a.c.withOpacity(0.3))),
    child: Row(children: [
      Icon(a.icon, color: a.c, size: 16),
      const SizedBox(width: 10),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1), decoration: BoxDecoration(color: a.c.withOpacity(0.15), borderRadius: BorderRadius.circular(3)),
            child: Text(a.level, style: GoogleFonts.inter(fontSize: 8, color: a.c, fontWeight: FontWeight.w800, letterSpacing: 0.5))),
          const SizedBox(width: 6),
          Expanded(child: Text(a.title, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textPrimary))),
        ]),
        const SizedBox(height: 2),
        Text(a.body, style: GoogleFonts.inter(fontSize: 11, color: AppColors.textSecondary, height: 1.4)),
      ])),
    ]));
}

class _KpiCard extends StatelessWidget {
  final _KD k;
  const _KpiCard({required this.k});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(11),
    decoration: BoxDecoration(color: AppColors.inkBlack, borderRadius: BorderRadius.circular(10), border: Border.all(color: AppColors.border)),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
      Row(children: [
        Container(width: 3, height: 14, decoration: BoxDecoration(color: k.c, borderRadius: BorderRadius.circular(2))),
        const SizedBox(width: 6),
        Expanded(child: Text(k.label, style: GoogleFonts.inter(fontSize: 10, color: AppColors.textMuted, fontWeight: FontWeight.w500), maxLines: 1, overflow: TextOverflow.ellipsis)),
      ]),
      const SizedBox(height: 5),
      RichText(text: TextSpan(children: [
        TextSpan(text: k.v, style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
        TextSpan(text: ' ${k.unit}', style: GoogleFonts.inter(fontSize: 10, color: AppColors.textMuted)),
      ])),
      const SizedBox(height: 3),
      Row(children: [
        Icon(k.good ? Icons.trending_up_rounded : Icons.trending_up_rounded, size: 11, color: k.good ? AppColors.catHepato : AppColors.catCardio),
        const SizedBox(width: 3),
        Text(k.trend, style: GoogleFonts.inter(fontSize: 10, color: k.good ? AppColors.catHepato : AppColors.catCardio, fontWeight: FontWeight.w600)),
      ]),
    ]));
}

class _TrendChart extends StatelessWidget {
  static const _yrs = ['2019','2020','2021','2022','2023','2024'];
  static const _lifeExp = [70.4, 70.1, 71.0, 71.5, 71.9, 72.4];
  static const _immun   = [89.0, 87.5, 90.1, 91.0, 92.0, 93.2];

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(color: AppColors.inkBlack, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.border)),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
      Row(children: [
        Text('6-Year Health Trends', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
        const Spacer(),
        _TrendLegend(AppColors.gold, 'Life Exp.'),
        const SizedBox(width: 12),
        _TrendLegend(AppColors.catInfectious, 'DTP3 %'),
      ]),
      const SizedBox(height: 14),
      SizedBox(height: 120, child: LineChart(LineChartData(
        gridData: FlGridData(show: true, drawVerticalLine: false, getDrawingHorizontalLine: (_) => FlLine(color: AppColors.border, strokeWidth: 0.5)),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 20, getTitlesWidget: (v, _) {
            final i = v.toInt().clamp(0, 5);
            return Text(_yrs[i], style: GoogleFonts.inter(fontSize: 8, color: AppColors.textMuted));
          })),
          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false))),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(spots: _lifeExp.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value)).toList(),
            isCurved: true, color: AppColors.gold, barWidth: 2,
            dotData: FlDotData(show: true, getDotPainter: (_, __, ___, ____) => FlDotCirclePainter(radius: 2.5, color: AppColors.gold, strokeWidth: 0)),
            belowBarData: BarAreaData(show: true, color: AppColors.gold.withOpacity(0.06))),
          LineChartBarData(spots: _immun.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value)).toList(),
            isCurved: true, color: AppColors.catInfectious, barWidth: 2,
            dotData: FlDotData(show: true, getDotPainter: (_, __, ___, ____) => FlDotCirclePainter(radius: 2.5, color: AppColors.catInfectious, strokeWidth: 0)),
            belowBarData: BarAreaData(show: true, color: AppColors.catInfectious.withOpacity(0.06))),
        ],
      ))),
    ]));
}

class _TrendLegend extends StatelessWidget {
  final Color c; final String l;
  const _TrendLegend(this.c, this.l);
  @override
  Widget build(BuildContext context) => Row(mainAxisSize: MainAxisSize.min, children: [
    Container(width: 12, height: 2, color: c),
    const SizedBox(width: 4),
    Text(l, style: GoogleFonts.inter(fontSize: 10, color: AppColors.textMuted)),
  ]);
}

class _EgyptSnapshot extends StatelessWidget {
  static const _stats = [
    ['104M', 'Population'],
    ['27', 'Governorates'],
    ['56K', 'Health Facilities'],
    ['580K', 'Health Workers'],
  ];
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(color: AppColors.inkBlack, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.gold.withOpacity(0.2))),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
      Row(children: [
        Container(width: 22, height: 15, decoration: BoxDecoration(borderRadius: BorderRadius.circular(2)), child: Column(children: [
          Expanded(child: Container(color: const Color(0xFFCE1126))),
          Expanded(child: Container(color: Colors.white)),
          Expanded(child: Container(color: Colors.black)),
        ])),
        const SizedBox(width: 8),
        Text('Egypt at a Glance — 2024', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
      ]),
      const SizedBox(height: 10),
      Row(children: _stats.map((s) => Expanded(child: Column(mainAxisSize: MainAxisSize.min, children: [
        Text(s[0], style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.gold)),
        Text(s[1], style: GoogleFonts.inter(fontSize: 9, color: AppColors.textMuted, letterSpacing: 0.5)),
      ]))).toList()),
    ]));
}

// ── INDICATORS TAB ────────────────────────────────────────────
class _IndicatorsTab extends StatelessWidget {
  static const _inds = [
    _ID('Life Expectancy', '72.4 yrs', 73.3, 72.4, 100, AppColors.catHepato),
    _ID('DTP3 Coverage', '93.2%', 84.0, 93.2, 100, AppColors.catInfectious),
    _ID('Maternal Mortality', '52/100K', 223.0, 52.0, 260, AppColors.catMaternal),
    _ID('Infant Mortality', '17.5‰', 28.0, 17.5, 50, AppColors.catCardio),
    _ID('Hepatitis C', '0.87%', 1.0, 0.87, 3, AppColors.catHepato),
    _ID('Diabetes Prev.', '17.2%', 9.3, 17.2, 25, AppColors.catEndocrine),
    _ID('Physician Density', '8.1/10K', 18.0, 8.1, 20, AppColors.catInfectious),
    _ID('UHC Index', '62/100', 68.0, 62.0, 100, AppColors.catMental),
  ];
  @override
  Widget build(BuildContext context) => ListView(padding: const EdgeInsets.all(14), children: [
    ..._inds.asMap().entries.map((e) => _IndRow(d: e.value).animate(delay: (e.key * 45).ms).fadeIn()),
  ]);
}

class _ID {
  final String name, val; final double global, egypt, max; final Color c;
  const _ID(this.name, this.val, this.global, this.egypt, this.max, this.c);
}

class _IndRow extends StatelessWidget {
  final _ID d;
  const _IndRow({required this.d});
  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 8),
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(color: AppColors.inkBlack, borderRadius: BorderRadius.circular(10), border: Border.all(color: AppColors.border)),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
      Row(children: [
        Container(width: 3, height: 16, decoration: BoxDecoration(color: d.c, borderRadius: BorderRadius.circular(2))),
        const SizedBox(width: 8),
        Expanded(child: Text(d.name, style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 13, color: AppColors.textPrimary))),
        Text(d.val, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w800, color: d.c)),
      ]),
      const SizedBox(height: 8),
      // Egypt bar
      Row(children: [
        SizedBox(width: 52, child: Text('Egypt', style: GoogleFonts.inter(fontSize: 9, color: AppColors.textMuted))),
        Expanded(child: Stack(children: [
          Container(height: 6, decoration: BoxDecoration(color: AppColors.elevated, borderRadius: BorderRadius.circular(3))),
          FractionallySizedBox(widthFactor: (d.egypt / d.max).clamp(0.0, 1.0),
            child: Container(height: 6, decoration: BoxDecoration(color: d.c, borderRadius: BorderRadius.circular(3)))),
        ])),
        const SizedBox(width: 6),
        Text(d.val.replaceAll(RegExp(r'[a-zA-Z%‰ /K]'), ''), style: GoogleFonts.inter(fontSize: 10, color: d.c, fontWeight: FontWeight.w700)),
      ]),
      const SizedBox(height: 4),
      // Global bar
      Row(children: [
        SizedBox(width: 52, child: Text('Global', style: GoogleFonts.inter(fontSize: 9, color: AppColors.textMuted))),
        Expanded(child: Stack(children: [
          Container(height: 6, decoration: BoxDecoration(color: AppColors.elevated, borderRadius: BorderRadius.circular(3))),
          FractionallySizedBox(widthFactor: (d.global / d.max).clamp(0.0, 1.0),
            child: Container(height: 6, decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(3)))),
        ])),
        const SizedBox(width: 6),
        Text(d.global.toStringAsFixed(0), style: GoogleFonts.inter(fontSize: 10, color: AppColors.textMuted)),
      ]),
    ]));
}

// ── SERVICES TAB ──────────────────────────────────────────────
class _ServicesTab extends StatelessWidget {
  static const _services = [
    {'name': 'Dataset Service', 'port': ':8002', 'status': 'operational', 'requests': '12.4K', 'color': AppColors.catHepato},
    {'name': 'Auth Service', 'port': ':8001', 'status': 'operational', 'requests': '8.1K', 'color': AppColors.catInfectious},
    {'name': 'OCR Service', 'port': ':8003', 'status': 'operational', 'requests': '1.2K', 'color': AppColors.gold},
    {'name': 'Content Service', 'port': ':8004', 'status': 'operational', 'requests': '3.8K', 'color': AppColors.catMental},
    {'name': 'Analytics Service', 'port': ':8005', 'status': 'degraded', 'requests': '5.6K', 'color': AppColors.catNutrition},
    {'name': 'Nginx Gateway', 'port': ':8080', 'status': 'operational', 'requests': '31.1K', 'color': AppColors.catMaternal},
  ];
  @override
  Widget build(BuildContext context) => ListView(padding: const EdgeInsets.all(14), children: [
    Container(padding: const EdgeInsets.all(12), margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(color: AppColors.catHepato.withOpacity(0.08), borderRadius: BorderRadius.circular(10), border: Border.all(color: AppColors.catHepato.withOpacity(0.3))),
      child: Row(children: [
        Container(width: 8, height: 8, decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.catHepato, boxShadow: [BoxShadow(color: AppColors.catHepato.withOpacity(0.5), blurRadius: 6)])),
        const SizedBox(width: 10),
        Text('5 of 6 services operational', style: GoogleFonts.inter(fontSize: 12, color: AppColors.catHepato, fontWeight: FontWeight.w600)),
        const Spacer(),
        Text('Last check: 2 min ago', style: GoogleFonts.inter(fontSize: 10, color: AppColors.textMuted)),
      ])).animate().fadeIn(),
    ..._services.asMap().entries.map((e) {
      final i = e.key; final s = e.value;
      final color = s['color'] as Color;
      final ok = s['status'] == 'operational';
      return Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: AppColors.inkBlack, borderRadius: BorderRadius.circular(10), border: Border.all(color: AppColors.border)),
        child: Row(children: [
          Container(width: 8, height: 8, decoration: BoxDecoration(shape: BoxShape.circle, color: ok ? AppColors.catHepato : AppColors.warning)),
          const SizedBox(width: 10),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(s['name'] as String, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
            Text('localhost${s['port']}  ·  ${s['requests']} req/day', style: GoogleFonts.inter(fontSize: 10, color: AppColors.textMuted)),
          ])),
          Container(padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
            decoration: BoxDecoration(color: (ok ? AppColors.catHepato : AppColors.warning).withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
            child: Text(s['status'] as String, style: GoogleFonts.inter(fontSize: 9, color: ok ? AppColors.catHepato : AppColors.warning, fontWeight: FontWeight.w700))),
        ])).animate(delay: (i * 50).ms).fadeIn();
    }),
  ]);
}
