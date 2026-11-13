import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/analytics_provider.dart';
import '../config/app_colors.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({Key? key}) : super(key: key);
  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 3, vsync: this);
    Future.microtask(() => context.read<AnalyticsProvider>().fetchAll());
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.obsidian,
      appBar: AppBar(
        backgroundColor: AppColors.charcoal,
        foregroundColor: AppColors.textPrimary,
        surfaceTintColor: Colors.transparent,
        scrolledUnderElevation: 0,
        title: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Health Analytics',
              style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary)),
          Consumer<AnalyticsProvider>(
            builder: (_, a, __) => Text(
              a.backendOnline
                  ? 'Live — API Connected'
                  : 'Demo Data — Start backend for live data',
              style: GoogleFonts.inter(
                  fontSize: 10,
                  color: a.backendOnline
                      ? AppColors.catHepato
                      : AppColors.gold),
            ),
          ),
        ]),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(49),
          child: Column(children: [
            Container(height: 1, color: AppColors.border),
            TabBar(
              controller: _tabs,
              indicatorColor: AppColors.gold,
              indicatorWeight: 2,
              labelColor: AppColors.gold,
              unselectedLabelColor: AppColors.textMuted,
              labelStyle: GoogleFonts.inter(
                  fontWeight: FontWeight.w700, fontSize: 12),
              dividerColor: Colors.transparent,
              tabs: const [
                Tab(text: 'Overview'),
                Tab(text: 'Trends'),
                Tab(text: 'Governorates'),
              ],
            ),
          ]),
        ),
      ),
      body: Consumer<AnalyticsProvider>(builder: (_, a, __) {
        if (a.isLoading) {
          return const Center(
              child: CircularProgressIndicator(
                  color: AppColors.gold, strokeWidth: 2));
        }
        return TabBarView(
          controller: _tabs,
          children: [
            _OverviewTab(a: a),
            _TrendsTab(a: a),
            _GovTab(a: a),
          ],
        );
      }),
    );
  }
}

// ── OVERVIEW TAB ──────────────────────────────────────────────
class _OverviewTab extends StatelessWidget {
  final AnalyticsProvider a;
  const _OverviewTab({required this.a});

  String _fmt(dynamic v) {
    final n = v is num ? v.toInt() : int.tryParse(v.toString()) ?? 0;
    if (n >= 1000000) return '${(n / 1000000).toStringAsFixed(1)}M';
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(0)}K';
    return '$n';
  }

  @override
  Widget build(BuildContext context) {
    final o = a.overview;
    final kpis = [
      ['${o['total_datasets'] ?? 12}', 'Datasets',
          Icons.dataset_rounded, AppColors.catInfectious],
      [_fmt(o['total_downloads'] ?? 31840), 'Downloads',
          Icons.download_rounded, AppColors.gold],
      [_fmt(o['total_views'] ?? 184500), 'Data Views',
          Icons.visibility_rounded, AppColors.catHepato],
      ['${o['total_users'] ?? 384}', 'Users',
          Icons.people_rounded, AppColors.catMental],
      ['${o['total_articles'] ?? 10}', 'Publications',
          Icons.article_rounded, AppColors.catNutrition],
      ['${o['governorates_covered'] ?? 27}', 'Governorates',
          Icons.map_rounded, AppColors.catMaternal],
      ['${o['total_ocr_jobs'] ?? 247}', 'OCR Jobs',
          Icons.document_scanner, AppColors.catPediatrics],
      [_fmt(o['total_article_views'] ?? 96200), 'Article Views',
          Icons.bar_chart_rounded, AppColors.catOncology],
    ];

    return RefreshIndicator(
      color: AppColors.gold,
      backgroundColor: AppColors.inkBlack,
      onRefresh: () => context.read<AnalyticsProvider>().fetchAll(),
      child: ListView(padding: const EdgeInsets.all(14), children: [
        _SectionLabel('Platform Overview'),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate:
              const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            childAspectRatio: 2.2,
          ),
          itemCount: kpis.length,
          itemBuilder: (_, i) {
            final k = kpis[i];
            final color = k[3] as Color;
            return Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                  color: AppColors.inkBlack,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.border)),
              child: Row(children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8)),
                  child: Icon(k[2] as IconData, size: 16, color: color),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(k[0] as String,
                          style: GoogleFonts.inter(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary)),
                      Text(k[1] as String,
                          style: GoogleFonts.inter(
                              fontSize: 10, color: AppColors.textMuted),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis),
                    ],
                  ),
                ),
              ]),
            ).animate(delay: (i * 45).ms).fadeIn();
          },
        ),
        const SizedBox(height: 16),
        _SectionLabel('Health Indicators (Live)'),
        ...a.indicators.take(8).toList().asMap().entries.map((e) {
          final i = e.key;
          final ind = e.value;
          final trend = ind['trend'] as String? ?? 'up';
          final change = (ind['change'] as num?)?.toDouble() ?? 0;
          final name = ind['name']?.toString() ?? '';
          final isBad = trend == 'up' &&
              (name.contains('Diabetes') ||
                  name.contains('Hypertension') ||
                  name.contains('Obesity') ||
                  name.contains('Smoking'));
          final color = isBad ? AppColors.catCardio : AppColors.catHepato;
          return Container(
            margin: const EdgeInsets.only(bottom: 6),
            padding: const EdgeInsets.all(11),
            decoration: BoxDecoration(
                color: AppColors.inkBlack,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.border)),
            child: Row(children: [
              Container(
                  width: 3,
                  height: 30,
                  decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(2))),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Text(name,
                      style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary)),
                  Text('${ind['value']} ${ind['unit'] ?? ''}',
                      style: GoogleFonts.inter(
                          fontSize: 11, color: AppColors.textMuted)),
                ]),
              ),
              Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                Icon(
                    isBad
                        ? Icons.trending_up_rounded
                        : Icons.trending_down_rounded,
                    size: 14,
                    color: color),
                Text(
                    '${change > 0 ? '+' : ''}${change.toStringAsFixed(1)}',
                    style: GoogleFonts.inter(
                        fontSize: 11,
                        color: color,
                        fontWeight: FontWeight.w700)),
              ]),
            ]),
          ).animate(delay: (i * 35).ms).fadeIn();
        }),
      ]),
    );
  }
}

// ── TRENDS TAB ────────────────────────────────────────────────
class _TrendsTab extends StatefulWidget {
  final AnalyticsProvider a;
  const _TrendsTab({required this.a});
  @override
  State<_TrendsTab> createState() => _TrendsTabState();
}

class _TrendsTabState extends State<_TrendsTab> {
  String _selected = 'Diabetes';

  static const Map<String, Color> _colors = {
    'Diabetes': AppColors.catEndocrine,
    'Hypertension': AppColors.catCardio,
    'Cancer': AppColors.catOncology,
    'HepatitisC': AppColors.catHepato,
    'COVID19': AppColors.catInfectious,
    'Obesity': AppColors.catNutrition,
  };

  @override
  Widget build(BuildContext context) {
    final trendsMap = widget.a.trends;
    final datasetsMap =
        (trendsMap['datasets'] as Map?)?.cast<String, dynamic>() ?? {};
    final monthsList =
        (trendsMap['months'] as List?)?.cast<String>() ??
            ['J', 'F', 'M', 'A', 'M', 'J', 'J', 'A', 'S', 'O', 'N', 'D'];
    final vals = (datasetsMap[_selected] as List?)?.cast<num>() ??
        List.filled(12, 0);
    final col = _colors[_selected] ?? AppColors.gold;

    return ListView(padding: const EdgeInsets.all(14), children: [
      // Disease selector
      SizedBox(
        height: 34,
        child: ListView(
          scrollDirection: Axis.horizontal,
          children: _colors.keys.map((d) {
            final isSelected = _selected == d;
            final c = _colors[d] ?? AppColors.gold;
            return GestureDetector(
              onTap: () => setState(() => _selected = d),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 140),
                margin: const EdgeInsets.only(right: 8),
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                decoration: BoxDecoration(
                  color: isSelected ? c : AppColors.elevated,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                      color: isSelected ? c : AppColors.border),
                ),
                child: Text(d,
                    style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: isSelected
                            ? AppColors.textPrimary
                            : AppColors.textSecondary)),
              ),
            );
          }).toList(),
        ),
      ),
      const SizedBox(height: 14),
      // Chart
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
            color: AppColors.inkBlack,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border)),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
          Row(children: [
            Text(_selected,
                style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary)),
            const Spacer(),
            Text('2024 · cases per 100K',
                style: GoogleFonts.inter(
                    fontSize: 10, color: AppColors.textMuted)),
          ]),
          const SizedBox(height: 4),
          Text(
            widget.a.backendOnline ? 'Source: MOHP Live API' : 'Source: Demo Data',
            style: GoogleFonts.inter(
                fontSize: 10, color: AppColors.textMuted),
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 160,
            child: BarChart(BarChartData(
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                getDrawingHorizontalLine: (_) =>
                    FlLine(color: AppColors.border, strokeWidth: 0.5),
              ),
              titlesData: FlTitlesData(
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 18,
                    getTitlesWidget: (v, _) {
                      final idx = v.toInt().clamp(0, monthsList.length - 1);
                      return Text(monthsList[idx].substring(0, 1),
                          style: GoogleFonts.inter(
                              fontSize: 9,
                              color: AppColors.textMuted));
                    },
                  ),
                ),
                leftTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false)),
                topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false)),
                rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false)),
              ),
              borderData: FlBorderData(show: false),
              barGroups: vals.asMap().entries.map((e) {
                return BarChartGroupData(x: e.key, barRods: [
                  BarChartRodData(
                    toY: e.value.toDouble(),
                    color: col,
                    width: 14,
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(4)),
                  ),
                ]);
              }).toList(),
            )),
          ),
        ]),
      ),
      const SizedBox(height: 14),
      // Summary stats
      Row(children: [
        _StatBox('Peak',
            vals.reduce((a, b) => a > b ? a : b).toStringAsFixed(0),
            'cases/100K', AppColors.catCardio),
        const SizedBox(width: 8),
        _StatBox('Min',
            vals.reduce((a, b) => a < b ? a : b).toStringAsFixed(0),
            'cases/100K', AppColors.catHepato),
        const SizedBox(width: 8),
        _StatBox(
            'Avg',
            (vals.reduce((a, b) => a + b) / vals.length).toStringAsFixed(0),
            'cases/100K',
            AppColors.gold),
      ]),
    ]);
  }
}

class _StatBox extends StatelessWidget {
  final String l, v, u;
  final Color c;
  const _StatBox(this.l, this.v, this.u, this.c);
  @override
  Widget build(BuildContext context) => Expanded(
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
              color: AppColors.inkBlack,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: c.withOpacity(0.25))),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Text(l,
                style: GoogleFonts.inter(
                    fontSize: 9, color: AppColors.textMuted)),
            Text(v,
                style: GoogleFonts.inter(
                    fontSize: 18, fontWeight: FontWeight.w800, color: c)),
            Text(u,
                style: GoogleFonts.inter(
                    fontSize: 9, color: AppColors.textMuted)),
          ]),
        ),
      );
}

// ── GOVERNORATES TAB ─────────────────────────────────────────
class _GovTab extends StatelessWidget {
  final AnalyticsProvider a;
  const _GovTab({required this.a});

  @override
  Widget build(BuildContext context) {
    final govs = [...a.governorates]
      ..sort((x, y) =>
          (y['health_index'] as num).compareTo(x['health_index'] as num));

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 20),
      itemCount: govs.length,
      itemBuilder: (_, i) {
        final g = govs[i];
        final idx = (g['health_index'] as num).toDouble();
        final color = idx >= 70
            ? AppColors.catHepato
            : idx >= 60
                ? AppColors.gold
                : AppColors.catCardio;
        final pop = (g['population'] as num).toInt();
        final popStr = pop >= 1000000
            ? '${(pop / 1000000).toStringAsFixed(1)}M'
            : '${(pop / 1000).toStringAsFixed(0)}K';

        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
              color: AppColors.inkBlack,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.border)),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
            Row(children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: color.withOpacity(0.3))),
                child: Center(
                  child: Text('${i + 1}',
                      style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: color)),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Text(g['name']?.toString() ?? '',
                      style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary)),
                  Text(
                      'Pop: $popStr  ·  ${g['hospitals']} hospitals  ·  ${g['datasets']} datasets',
                      style: GoogleFonts.inter(
                          fontSize: 10, color: AppColors.textMuted)),
                ]),
              ),
              Text('${idx.toInt()}/100',
                  style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: color)),
            ]),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(3),
              child: LinearProgressIndicator(
                value: (idx / 100).clamp(0.0, 1.0),
                backgroundColor: AppColors.elevated,
                color: color,
                minHeight: 5,
              ),
            ),
          ]),
        ).animate(delay: (i * 30).ms).fadeIn();
      },
    );
  }
}

// ── HELPERS ───────────────────────────────────────────────────
class _SectionLabel extends StatelessWidget {
  final String t;
  const _SectionLabel(this.t);
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
          Text(t,
              style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary)),
          Container(
            width: 32,
            height: 2,
            margin: const EdgeInsets.only(top: 4),
            decoration: BoxDecoration(gradient: AppColors.goldAccent),
          ),
        ]),
      );
}
