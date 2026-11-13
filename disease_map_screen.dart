import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/analytics_provider.dart';
import '../config/app_colors.dart';

class DiseaseMapScreen extends StatefulWidget {
  const DiseaseMapScreen({Key? key}) : super(key: key);
  @override
  State<DiseaseMapScreen> createState() => _DiseaseMapScreenState();
}

class _DiseaseMapScreenState extends State<DiseaseMapScreen> {
  Map<String, dynamic>? _selectedGov;
  Map<String, dynamic>? _govDetail;
  bool _loadingDetail = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final prov = context.read<AnalyticsProvider>();
      if (prov.governorates.isEmpty) prov.fetchAll();
    });
  }

  Future<void> _selectGov(Map<String, dynamic> gov) async {
    setState(() {
      _selectedGov = gov;
      _loadingDetail = true;
      _govDetail = null;
    });
    final prov = context.read<AnalyticsProvider>();
    final detail = await prov.getGovernorateDetail(gov['name'] as String);
    if (mounted) {
      setState(() {
        _govDetail = detail;
        _loadingDetail = false;
      });
    }
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
          Text('Egypt Health Map',
              style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary)),
          Text('Tap any governorate for full analytics',
              style: GoogleFonts.inter(
                  fontSize: 10, color: AppColors.textMuted)),
        ]),
      ),
      body: Consumer<AnalyticsProvider>(builder: (_, prov, __) {
        if (prov.isLoading) {
          return const Center(
              child: CircularProgressIndicator(
                  color: AppColors.gold, strokeWidth: 2));
        }
        return Column(children: [
          // Egypt flag stripe
          Row(children: [
            Expanded(
                child: Container(
                    height: 3,
                    color: const Color(0xFFCE1126).withOpacity(0.8))),
            Expanded(
                child: Container(
                    height: 3,
                    color: Colors.white.withOpacity(0.12))),
            Expanded(
                child: Container(height: 3, color: AppColors.charcoal)),
          ]),
          Expanded(
            child: _selectedGov == null
                ? _MapView(govs: prov.governorates, onSelect: _selectGov)
                : _GovDetailView(
                    gov: _selectedGov!,
                    detail: _govDetail,
                    loading: _loadingDetail,
                    onBack: () => setState(() {
                      _selectedGov = null;
                      _govDetail = null;
                    }),
                    prov: prov,
                  ),
          ),
        ]);
      }),
    );
  }
}

// ── MAP VIEW ──────────────────────────────────────────────────
class _MapView extends StatelessWidget {
  final List<Map<String, dynamic>> govs;
  final ValueChanged<Map<String, dynamic>> onSelect;
  const _MapView({required this.govs, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    final sorted = [...govs]
      ..sort((a, b) =>
          (b['health_index'] as num).compareTo(a['health_index'] as num));

    return Column(children: [
      // Legend
      Container(
        color: AppColors.inkBlack,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(children: [
          _Legend(AppColors.catHepato, 'Excellent 72+'),
          const SizedBox(width: 12),
          _Legend(AppColors.gold, 'Good 65–71'),
          const SizedBox(width: 12),
          _Legend(AppColors.catNutrition, 'Fair 58–64'),
          const SizedBox(width: 12),
          _Legend(AppColors.catCardio, 'Needs Action'),
        ]),
      ),
      Container(height: 1, color: AppColors.border),
      // Pharaonic header
      Container(
        color: AppColors.charcoal,
        padding:
            const EdgeInsets.symmetric(vertical: 7, horizontal: 20),
        child: Row(children: [
          Text('ARAB REPUBLIC OF EGYPT — 27 GOVERNORATES',
              style: GoogleFonts.inter(
                  color: AppColors.gold,
                  fontSize: 9,
                  letterSpacing: 2.5,
                  fontWeight: FontWeight.w700)),
        ]),
      ),
      // Map grid
      Expanded(child: _EgyptMapGrid(govs: sorted, onSelect: onSelect)),
    ]);
  }
}

class _Legend extends StatelessWidget {
  final Color c;
  final String l;
  const _Legend(this.c, this.l);
  @override
  Widget build(BuildContext context) => Row(mainAxisSize: MainAxisSize.min, children: [
    Container(
        width: 10,
        height: 10,
        decoration: BoxDecoration(
            color: c, borderRadius: BorderRadius.circular(2))),
    const SizedBox(width: 4),
    Text(l,
        style: GoogleFonts.inter(
            fontSize: 9, color: AppColors.textMuted)),
  ]);
}

// ── EGYPT MAP GRID ────────────────────────────────────────────
class _EgyptMapGrid extends StatelessWidget {
  final List<Map<String, dynamic>> govs;
  final ValueChanged<Map<String, dynamic>> onSelect;
  const _EgyptMapGrid({required this.govs, required this.onSelect});

  Color _colorFor(int idx) {
    if (idx >= 72) return AppColors.catHepato;
    if (idx >= 65) return AppColors.gold;
    if (idx >= 58) return AppColors.catNutrition;
    return AppColors.catCardio;
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(10, 8, 10, 20),
      itemCount: (govs.length / 3).ceil(),
      itemBuilder: (_, row) {
        final start = row * 3;
        final end = (start + 3).clamp(0, govs.length);
        final rowGovs = govs.sublist(start, end);
        final cells = rowGovs.asMap().entries.map((e) {
          final gov = e.value;
          final hi = (gov['health_index'] as num).toInt();
          final col = _colorFor(hi);
          return Expanded(
            child: GestureDetector(
              onTap: () => onSelect(gov),
              child: Container(
                height: 90,
                margin: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  color: AppColors.inkBlack,
                  borderRadius: BorderRadius.circular(10),
                  border:
                      Border.all(color: col.withOpacity(0.4), width: 1.5),
                  boxShadow: [
                    BoxShadow(
                        color: col.withOpacity(0.12),
                        blurRadius: 10,
                        offset: const Offset(0, 3))
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Stack(children: [
                    // Top accent line
                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        height: 2,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(colors: [
                            col.withOpacity(0.6),
                            col,
                            col.withOpacity(0.6)
                          ]),
                        ),
                      ),
                    ),
                    // Content
                    Center(
                      child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                        Text('$hi',
                            style: GoogleFonts.inter(
                                fontSize: 22,
                                fontWeight: FontWeight.w900,
                                color: col)),
                        Text(gov['name'] as String,
                            style: GoogleFonts.inter(
                                fontSize: 9,
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.w600),
                            textAlign: TextAlign.center,
                            maxLines: 2),
                        Text('${gov['hospitals']} hosp.',
                            style: GoogleFonts.inter(
                                fontSize: 8,
                                color: AppColors.textMuted)),
                      ]),
                    ),
                  ]),
                ),
              ).animate(
                  delay: Duration(milliseconds: e.key * 40)).fadeIn().scale(
                  begin: const Offset(0.92, 0.92)),
            ),
          );
        }).toList();

        // Pad to 3 columns
        while (cells.length < 3) {
          cells.add(const Expanded(child: SizedBox()));
        }

        return Row(children: cells);
      },
    );
  }
}

// ── GOVERNORATE DETAIL VIEW ───────────────────────────────────
class _GovDetailView extends StatelessWidget {
  final Map<String, dynamic> gov;
  final Map<String, dynamic>? detail;
  final bool loading;
  final VoidCallback onBack;
  final AnalyticsProvider prov;

  const _GovDetailView({
    required this.gov,
    required this.detail,
    required this.loading,
    required this.onBack,
    required this.prov,
  });

  Color get _col {
    final hi = (gov['health_index'] as num).toInt();
    if (hi >= 72) return AppColors.catHepato;
    if (hi >= 65) return AppColors.gold;
    if (hi >= 58) return AppColors.catNutrition;
    return AppColors.catCardio;
  }

  @override
  Widget build(BuildContext context) {
    final hi = (gov['health_index'] as num).toInt();
    final pop = (gov['population'] as int);
    final popStr = pop >= 1000000
        ? '${(pop / 1000000).toStringAsFixed(1)}M'
        : '${(pop / 1000).toStringAsFixed(0)}K';

    return Column(children: [
      // Header
      Container(
        color: AppColors.charcoal,
        padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
        child: Row(children: [
          GestureDetector(
            onTap: onBack,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                  color: AppColors.elevated,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.border)),
              child: const Icon(Icons.arrow_back_rounded,
                  size: 16, color: AppColors.textSecondary),
            ),
          ),
          const SizedBox(width: 12),
          Container(
              width: 3,
              height: 30,
              decoration: BoxDecoration(
                  color: _col,
                  borderRadius: BorderRadius.circular(2))),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
              Text(gov['name'] as String,
                  style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary)),
              Text('Pop $popStr  ·  Health Index $hi/100',
                  style: GoogleFonts.inter(
                      fontSize: 11, color: AppColors.textMuted)),
            ]),
          ),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
                color: _col.withOpacity(0.12),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: _col.withOpacity(0.4))),
            child: Text(
                detail?['health_score_label'] as String? ?? '...',
                style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: _col)),
          ),
        ]),
      ),
      Container(
          height: 2,
          decoration: BoxDecoration(
              gradient: LinearGradient(colors: [
            _col,
            _col.withOpacity(0.2),
            Colors.transparent
          ]))),
      // Body
      Expanded(
        child: loading
            ? const Center(
                child: CircularProgressIndicator(
                    color: AppColors.gold, strokeWidth: 2))
            : _GovContent(
                gov: gov,
                detail: detail ?? {},
                col: _col,
                prov: prov,
              ),
      ),
    ]).animate().slideX(begin: 0.08).fadeIn(duration: 350.ms);
  }
}

// ── GOV CONTENT ───────────────────────────────────────────────
class _GovContent extends StatelessWidget {
  final Map<String, dynamic> gov;
  final Map<String, dynamic> detail;
  final Color col;
  final AnalyticsProvider prov;

  const _GovContent({
    required this.gov,
    required this.detail,
    required this.col,
    required this.prov,
  });

  @override
  Widget build(BuildContext context) {
    final diseaseRates =
        (detail['disease_rates'] as Map?)?.cast<String, dynamic>() ?? {};
    final vaccineCoverage =
        (detail['vaccination_coverage'] as Map?)?.cast<String, dynamic>() ??
            {};
    final hi = (gov['health_index'] as num).toInt();

    return DefaultTabController(
      length: 4,
      child: Column(children: [
        Container(
          color: AppColors.charcoal,
          child: TabBar(
            indicatorColor: col,
            indicatorWeight: 2,
            labelColor: col,
            unselectedLabelColor: AppColors.textMuted,
            labelStyle:
                GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 11),
            dividerColor: AppColors.border,
            tabs: const [
              Tab(text: 'Overview'),
              Tab(text: 'Hospitals'),
              Tab(text: 'Vaccines'),
              Tab(text: 'Analytics'),
            ],
          ),
        ),
        Expanded(
          child: TabBarView(children: [
            // OVERVIEW
            ListView(padding: const EdgeInsets.all(14), children: [
              Row(children: [
                _GovKpi('$hi/100', 'Health Index',
                    Icons.favorite_rounded, col),
                const SizedBox(width: 8),
                _GovKpi('${gov['hospitals']}', 'Hospitals',
                    Icons.local_hospital_rounded, AppColors.catInfectious),
                const SizedBox(width: 8),
                _GovKpi('${gov['datasets']}', 'Datasets',
                    Icons.dataset_rounded, AppColors.gold),
              ]).animate().fadeIn(),
              const SizedBox(height: 12),
              _SHead('Disease Prevalence', col),
              _RateBar(
                  'Diabetes',
                  double.tryParse(
                          diseaseRates['diabetes']?.toString() ?? '17') ??
                      17,
                  25,
                  AppColors.catEndocrine),
              _RateBar(
                  'Hypertension',
                  double.tryParse(diseaseRates['hypertension']?.toString() ??
                          '25') ??
                      25,
                  40,
                  AppColors.catCardio),
              _RateBar(
                  'Obesity',
                  double.tryParse(
                          diseaseRates['obesity']?.toString() ?? '30') ??
                      30,
                  50,
                  AppColors.catNutrition),
              const SizedBox(height: 12),
              _SHead('Health Index vs Benchmarks', col),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                    color: AppColors.inkBlack,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.border)),
                child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                  _CompBar('${gov['name']}', hi.toDouble(), 100, col),
                  const SizedBox(height: 8),
                  _CompBar('National Avg', 62.3, 100,
                      AppColors.textSecondary),
                  const SizedBox(height: 8),
                  _CompBar(
                      'WHO Target', 75.0, 100, AppColors.catHepato),
                ]),
              ),
            ]),
            // HOSPITALS
            _HospitalsTab(gov: gov, col: col),
            // VACCINES
            ListView(padding: const EdgeInsets.all(14), children: [
              _SHead('Vaccination Coverage', col),
              _CovTile(
                  'DTP3 Children',
                  double.tryParse(
                          vaccineCoverage['dtp3']?.toString() ?? '90') ??
                      90,
                  95,
                  AppColors.catInfectious),
              _CovTile(
                  'Measles MCV2',
                  double.tryParse(vaccineCoverage['measles']?.toString() ??
                          '85') ??
                      85,
                  95,
                  AppColors.catOncology),
              _CovTile(
                  'COVID-19 Booster',
                  double.tryParse(
                          vaccineCoverage['covid']?.toString() ?? '40') ??
                      40,
                  70,
                  AppColors.catMental),
              const SizedBox(height: 14),
              _SHead('ICU & Critical Care', col),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                    color: AppColors.inkBlack,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.border)),
                child: Row(children: [
                  _GovKpi2(
                      '${detail['icu_beds_per_10k'] ?? '2.1'}',
                      'ICU/10K',
                      AppColors.catCardio),
                  _GovKpi2('${gov['hospitals']}', 'Facilities',
                      AppColors.catInfectious),
                  _GovKpi2(
                      '${((gov['hospitals'] as int) * 18)}',
                      'ICU est.',
                      AppColors.gold),
                ]),
              ),
            ]),
            // ANALYTICS
            _AnalyticsTab(gov: gov, col: col, prov: prov),
          ]),
        ),
      ]),
    );
  }
}

// ── SMALL HELPERS ─────────────────────────────────────────────
class _SHead extends StatelessWidget {
  final String t;
  final Color c;
  const _SHead(this.t, this.c);
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Row(children: [
          Container(
              width: 3,
              height: 14,
              decoration: BoxDecoration(
                  color: c, borderRadius: BorderRadius.circular(2))),
          const SizedBox(width: 8),
          Text(t,
              style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary)),
        ]),
      );
}

class _GovKpi extends StatelessWidget {
  final String v, l;
  final IconData i;
  final Color c;
  const _GovKpi(this.v, this.l, this.i, this.c);
  @override
  Widget build(BuildContext context) => Expanded(
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
              color: AppColors.inkBlack,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: c.withOpacity(0.25))),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Icon(i, size: 16, color: c),
            const SizedBox(height: 5),
            Text(v,
                style: GoogleFonts.inter(
                    fontSize: 18, fontWeight: FontWeight.w900, color: c)),
            Text(l,
                style: GoogleFonts.inter(
                    fontSize: 9, color: AppColors.textMuted),
                textAlign: TextAlign.center),
          ]),
        ),
      );
}

class _GovKpi2 extends StatelessWidget {
  final String v, l;
  final Color c;
  const _GovKpi2(this.v, this.l, this.c);
  @override
  Widget build(BuildContext context) => Expanded(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text(v,
              style: GoogleFonts.inter(
                  fontSize: 20, fontWeight: FontWeight.w900, color: c)),
          Text(l,
              style: GoogleFonts.inter(
                  fontSize: 9, color: AppColors.textMuted),
              textAlign: TextAlign.center),
        ]),
      );
}

class _RateBar extends StatelessWidget {
  final String label;
  final double val, max;
  final Color c;
  const _RateBar(this.label, this.val, this.max, this.c);
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Row(children: [
          SizedBox(
              width: 88,
              child: Text(label,
                  style: GoogleFonts.inter(
                      fontSize: 12, color: AppColors.textSecondary))),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: (val / max).clamp(0.0, 1.0),
                color: c,
                backgroundColor: AppColors.elevated,
                minHeight: 10,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text('${val.toStringAsFixed(1)}%',
              style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: c)),
        ]),
      );
}

class _CompBar extends StatelessWidget {
  final String label;
  final double val, max;
  final Color c;
  const _CompBar(this.label, this.val, this.max, this.c);
  @override
  Widget build(BuildContext context) => Row(children: [
        SizedBox(
            width: 100,
            child: Text(label,
                style: GoogleFonts.inter(
                    fontSize: 11, color: AppColors.textSecondary))),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(
              value: (val / max).clamp(0.0, 1.0),
              color: c,
              backgroundColor: AppColors.elevated,
              minHeight: 8,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text('${val.toStringAsFixed(0)}',
            style: GoogleFonts.inter(
                fontSize: 11, fontWeight: FontWeight.w700, color: c)),
      ]);
}

class _CovTile extends StatelessWidget {
  final String label;
  final double val, target;
  final Color c;
  const _CovTile(this.label, this.val, this.target, this.c);
  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
            color: AppColors.inkBlack,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.border)),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Row(children: [
            Text(label,
                style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary)),
            const Spacer(),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                  color: (val >= target
                          ? AppColors.catHepato
                          : AppColors.catCardio)
                      .withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4)),
              child: Text(val >= target ? 'ON TARGET' : 'BELOW',
                  style: GoogleFonts.inter(
                      fontSize: 8,
                      fontWeight: FontWeight.w800,
                      color: val >= target
                          ? AppColors.catHepato
                          : AppColors.catCardio)),
            ),
            const SizedBox(width: 8),
            Text('${val.toStringAsFixed(1)}%',
                style: GoogleFonts.inter(
                    fontSize: 14, fontWeight: FontWeight.w800, color: c)),
          ]),
          const SizedBox(height: 8),
          Stack(children: [
            Container(
                height: 8,
                decoration: BoxDecoration(
                    color: AppColors.elevated,
                    borderRadius: BorderRadius.circular(4))),
            FractionallySizedBox(
              widthFactor: (target / 100).clamp(0.0, 1.0),
              child: Container(
                  height: 8,
                  decoration: BoxDecoration(
                      color: AppColors.border,
                      borderRadius: BorderRadius.circular(4))),
            ),
            FractionallySizedBox(
              widthFactor: (val / 100).clamp(0.0, 1.0),
              child: Container(
                  height: 8,
                  decoration: BoxDecoration(
                      color: c, borderRadius: BorderRadius.circular(4))),
            ),
          ]),
          const SizedBox(height: 4),
          Row(mainAxisAlignment: MainAxisAlignment.end, children: [
            Text('Target: ${target.toStringAsFixed(0)}%',
                style: GoogleFonts.inter(
                    fontSize: 9, color: AppColors.textMuted)),
          ]),
        ]),
      );
}

// ── HOSPITALS TAB ─────────────────────────────────────────────
class _HospitalsTab extends StatelessWidget {
  final Map<String, dynamic> gov;
  final Color col;
  const _HospitalsTab({required this.gov, required this.col});

  @override
  Widget build(BuildContext context) {
    final name = gov['name'] as String;
    final count = (gov['hospitals'] as int).clamp(0, 8);
    final hospitals = List.generate(count, (i) => {
          'name': i == 0
              ? '$name University Hospital'
              : i == 1
                  ? '$name General Hospital'
                  : i == 2
                      ? '$name Children Hospital'
                      : 'District Hospital ${i + 1}',
          'type':
              i < 2 ? 'University' : i == 2 ? 'Specialized' : 'General',
          'beds': i == 0 ? 1200 : i == 1 ? 800 : i == 2 ? 400 : 150 + i * 40,
          'icu': i == 0 ? 80 : i == 1 ? 50 : i == 2 ? 30 : 10 + i * 5,
          'er': i < 3,
        });

    return ListView(padding: const EdgeInsets.all(14), children: [
      Container(
        padding: const EdgeInsets.all(10),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
            color: col.withOpacity(0.07),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: col.withOpacity(0.2))),
        child: Row(children: [
          Icon(Icons.local_hospital_rounded, color: col, size: 16),
          const SizedBox(width: 8),
          Text('${gov['hospitals']} government facilities in $name',
              style: GoogleFonts.inter(
                  fontSize: 12, color: col, fontWeight: FontWeight.w600)),
        ]),
      ),
      ...hospitals.asMap().entries.map((e) {
        final i = e.key;
        final h = e.value;
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
              color: AppColors.inkBlack,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.border)),
          child: Row(children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                  color: col.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8)),
              child: Icon(Icons.local_hospital_rounded,
                  color: col, size: 18),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text(h['name'] as String,
                    style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
                Text(
                    '${h['type']}  ·  ${h['beds']} beds  ·  ${h['icu']} ICU',
                    style: GoogleFonts.inter(
                        fontSize: 10, color: AppColors.textMuted)),
              ]),
            ),
            if (h['er'] == true)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                    color: AppColors.catHepato.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4)),
                child: Text('ER 24/7',
                    style: GoogleFonts.inter(
                        fontSize: 8,
                        color: AppColors.catHepato,
                        fontWeight: FontWeight.w800)),
              ),
          ]),
        ).animate(delay: Duration(milliseconds: i * 40)).fadeIn();
      }),
    ]);
  }
}

// ── ANALYTICS TAB ─────────────────────────────────────────────
class _AnalyticsTab extends StatelessWidget {
  final Map<String, dynamic> gov;
  final Color col;
  final AnalyticsProvider prov;
  const _AnalyticsTab(
      {required this.gov, required this.col, required this.prov});

  @override
  Widget build(BuildContext context) {
    final hi = (gov['health_index'] as num).toDouble();
    final trend = List.generate(
        6,
        (i) => FlSpot(i.toDouble(),
            hi - 4 + i * 0.8 + (i % 2 == 0 ? 0.5 : -0.3)));
    final years = ['2019', '2020', '2021', '2022', '2023', '2024'];

    return ListView(padding: const EdgeInsets.all(14), children: [
      _SHead('6-Year Health Index Trend', col),
      Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
            color: AppColors.inkBlack,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border)),
        child: SizedBox(
          height: 140,
          child: LineChart(LineChartData(
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
                  reservedSize: 20,
                  getTitlesWidget: (v, _) {
                    final idx = v.toInt().clamp(0, 5);
                    return Text(years[idx],
                        style: GoogleFonts.inter(
                            fontSize: 8, color: AppColors.textMuted));
                  },
                ),
              ),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 30,
                  getTitlesWidget: (v, _) => Text('${v.toInt()}',
                      style: GoogleFonts.inter(
                          fontSize: 8, color: AppColors.textMuted)),
                ),
              ),
              topTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false)),
              rightTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false)),
            ),
            borderData: FlBorderData(show: false),
            lineBarsData: [
              LineChartBarData(
                spots: trend,
                isCurved: true,
                color: col,
                barWidth: 2.5,
                dotData: FlDotData(
                  show: true,
                  getDotPainter: (s, _, __, ___) => FlDotCirclePainter(
                      radius: s.x == 5 ? 4 : 2,
                      color: col,
                      strokeWidth: 0),
                ),
                belowBarData:
                    BarAreaData(show: true, color: col.withOpacity(0.07)),
              ),
            ],
            minY: hi - 8,
            maxY: hi + 4,
          )),
        ),
      ),
      const SizedBox(height: 12),
      _SHead('Governorate Ranking', col),
      Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
            color: AppColors.inkBlack,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: col.withOpacity(0.25))),
        child: Row(children: [
          Icon(Icons.emoji_events_rounded, color: col, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
                '${gov['name']} — Health Index ${hi.toInt()}/100. '
                'Ranked among ${hi >= 70 ? "top" : hi >= 60 ? "middle" : "lower"} tier governorates.',
                style: GoogleFonts.inter(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                    height: 1.5)),
          ),
        ]),
      ),
    ]);
  }
}
