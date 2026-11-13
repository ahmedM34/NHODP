import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';
import '../config/app_colors.dart';

class VaccinesScreen extends StatefulWidget {
  const VaccinesScreen({Key? key}) : super(key: key);
  @override
  State<VaccinesScreen> createState() => _VaccinesScreenState();
}

class _VaccinesScreenState extends State<VaccinesScreen> with SingleTickerProviderStateMixin {
  late TabController _tabs;
  String _ageGroup = 'Adult (18–59)';

  static const _ageGroups = ['Child (0–9)', 'Adolescent (10–17)', 'Adult (18–59)', 'Elderly (60+)', 'Pregnant'];

  static const _coverageData = [
    {'vaccine': 'BCG', 'coverage': 98.2, 'target': 95.0, 'color': AppColors.catHepato},
    {'vaccine': 'DTP3', 'coverage': 93.2, 'target': 90.0, 'color': AppColors.catInfectious},
    {'vaccine': 'Polio OPV3', 'coverage': 94.5, 'target': 95.0, 'color': AppColors.catEndocrine},
    {'vaccine': 'Measles MCV2', 'coverage': 88.5, 'target': 95.0, 'color': AppColors.catOncology},
    {'vaccine': 'Hepatitis B', 'coverage': 91.0, 'target': 90.0, 'color': AppColors.catNeonatology},
    {'vaccine': 'Pneumococcal', 'coverage': 72.3, 'target': 85.0, 'color': AppColors.catNutrition},
    {'vaccine': 'Rotavirus', 'coverage': 68.7, 'target': 80.0, 'color': AppColors.catMaternal},
    {'vaccine': 'COVID-19 (3rd)', 'coverage': 42.1, 'target': 70.0, 'color': AppColors.catMental},
  ];

  static const Map<String, List<Map<String, dynamic>>> _schedules = {
    'Child (0–9)': [
      {'vaccine': 'BCG', 'timing': 'At birth', 'doses': 1, 'mandatory': true, 'description': 'Tuberculosis prevention', 'side_effects': 'Mild local reaction'},
      {'vaccine': 'Hepatitis B', 'timing': 'Birth, 2m, 6m', 'doses': 3, 'mandatory': true, 'description': 'Hepatitis B virus prevention', 'side_effects': 'Soreness at injection site'},
      {'vaccine': 'DTP + Hib + IPV', 'timing': '2m, 4m, 6m, 18m', 'doses': 4, 'mandatory': true, 'description': 'Diphtheria, tetanus, pertussis, Hib, polio', 'side_effects': 'Fever, irritability'},
      {'vaccine': 'Polio OPV', 'timing': 'Birth, 2m, 4m, 6m', 'doses': 4, 'mandatory': true, 'description': 'Oral polio vaccine — eradication program', 'side_effects': 'Rare vaccine-derived polio'},
      {'vaccine': 'PCV13', 'timing': '2m, 4m, 6m, 12m', 'doses': 4, 'mandatory': true, 'description': 'Pneumococcal disease prevention', 'side_effects': 'Fever, fussiness'},
      {'vaccine': 'Rotavirus', 'timing': '2m, 4m', 'doses': 2, 'mandatory': true, 'description': 'Severe diarrhea prevention', 'side_effects': 'Temporary vomiting'},
      {'vaccine': 'MMR', 'timing': '12m, 18m', 'doses': 2, 'mandatory': true, 'description': 'Measles, mumps, rubella', 'side_effects': 'Mild rash, fever'},
      {'vaccine': 'Varicella', 'timing': '12m, 4y', 'doses': 2, 'mandatory': false, 'description': 'Chickenpox prevention', 'side_effects': 'Mild chickenpox-like rash'},
    ],
    'Adolescent (10–17)': [
      {'vaccine': 'HPV', 'timing': '11–12 years (2 doses)', 'doses': 2, 'mandatory': false, 'description': 'Human papillomavirus — cervical cancer prevention', 'side_effects': 'Pain, dizziness'},
      {'vaccine': 'Tdap Booster', 'timing': 'Every 10 years', 'doses': 1, 'mandatory': true, 'description': 'Tetanus, diphtheria, pertussis booster', 'side_effects': 'Arm soreness'},
      {'vaccine': 'MCV4', 'timing': '11–12 years', 'doses': 1, 'mandatory': false, 'description': 'Meningococcal disease prevention', 'side_effects': 'Redness, pain'},
      {'vaccine': 'Influenza', 'timing': 'Annual (October)', 'doses': 1, 'mandatory': false, 'description': 'Seasonal influenza prevention', 'side_effects': 'Mild flu-like symptoms'},
    ],
    'Adult (18–59)': [
      {'vaccine': 'Influenza', 'timing': 'Annual (October–November)', 'doses': 1, 'mandatory': false, 'description': 'Seasonal flu prevention — especially for healthcare workers', 'side_effects': 'Arm soreness, mild fever'},
      {'vaccine': 'COVID-19', 'timing': 'Primary + Boosters', 'doses': 3, 'mandatory': false, 'description': 'COVID-19 prevention — all WHO-approved vaccines available', 'side_effects': 'Fatigue, fever (24–48h)'},
      {'vaccine': 'Td Booster', 'timing': 'Every 10 years', 'doses': 1, 'mandatory': true, 'description': 'Tetanus and diphtheria booster', 'side_effects': 'Mild arm soreness'},
      {'vaccine': 'Hepatitis A+B', 'timing': 'If not previously vaccinated', 'doses': 3, 'mandatory': false, 'description': 'For travelers, healthcare workers, high-risk groups', 'side_effects': 'Local reaction'},
      {'vaccine': 'MMR', 'timing': 'If not immune (2 doses)', 'doses': 2, 'mandatory': false, 'description': 'For adults born after 1957 without immunity', 'side_effects': 'Mild rash'},
      {'vaccine': 'Varicella', 'timing': 'If not immune (2 doses)', 'doses': 2, 'mandatory': false, 'description': 'For adults without prior infection or vaccination', 'side_effects': 'Local rash'},
    ],
    'Elderly (60+)': [
      {'vaccine': 'Influenza (High-Dose)', 'timing': 'Annual', 'doses': 1, 'mandatory': true, 'description': 'High-dose quadrivalent influenza — reduces severity by 40%', 'side_effects': 'Arm soreness, fatigue'},
      {'vaccine': 'Pneumococcal PCV20', 'timing': 'Single dose', 'doses': 1, 'mandatory': true, 'description': 'Prevents pneumococcal pneumonia and meningitis', 'side_effects': 'Injection site reaction'},
      {'vaccine': 'Shingles (Shingrix)', 'timing': '2 doses, 2–6 months apart', 'doses': 2, 'mandatory': false, 'description': 'Prevents herpes zoster — over 90% efficacy in 60+', 'side_effects': 'Shingles-like symptoms (transient)'},
      {'vaccine': 'COVID-19 Booster', 'timing': 'Annual updated formula', 'doses': 1, 'mandatory': true, 'description': 'Updated booster — bivalent or latest WHO-recommended', 'side_effects': 'Fatigue, fever (24h)'},
      {'vaccine': 'Td Booster', 'timing': 'Every 10 years', 'doses': 1, 'mandatory': true, 'description': 'Tetanus booster critical for wound protection', 'side_effects': 'Mild arm soreness'},
    ],
    'Pregnant': [
      {'vaccine': 'Tdap', 'timing': '27–36 weeks each pregnancy', 'doses': 1, 'mandatory': true, 'description': 'Protects newborn from whooping cough before birth', 'side_effects': 'Arm soreness, mild fever'},
      {'vaccine': 'Influenza (Inactivated)', 'timing': 'Any trimester', 'doses': 1, 'mandatory': true, 'description': 'Flu vaccine safe in all trimesters — protects mother and baby', 'side_effects': 'Arm pain, fatigue'},
      {'vaccine': 'COVID-19 mRNA', 'timing': 'Any trimester', 'doses': 1, 'mandatory': false, 'description': 'Recommended by WHO and MOHP for all pregnant women', 'side_effects': 'Transient fatigue'},
      {'vaccine': 'Hepatitis B', 'timing': 'If not previously vaccinated', 'doses': 3, 'mandatory': false, 'description': 'Safe during pregnancy — prevents vertical transmission', 'side_effects': 'Local reaction'},
    ],
  };

  static const _alerts = [
    {'type': 'warning', 'title': 'Seasonal Influenza Season Active', 'body': 'October–March 2025 flu season. High-risk groups urged to vaccinate immediately. Over 1.2M doses distributed to MOHP centers.', 'color': AppColors.warning, 'icon': Icons.warning_rounded},
    {'type': 'info', 'title': 'Updated COVID-19 Booster Available', 'body': 'JN.1 variant-targeted bivalent booster now available at 2,400 vaccination centers. Recommended for elderly and immunocompromised.', 'color': AppColors.catInfectious, 'icon': Icons.vaccines_rounded},
    {'type': 'required', 'title': 'Meningococcal Vaccine for Hajj Pilgrims', 'body': 'ACWY quadrivalent meningococcal vaccine MANDATORY for all Hajj and Umra pilgrims. Must be administered 10+ days before departure.', 'color': AppColors.catCardio, 'icon': Icons.emergency_rounded},
  ];

  @override
  void initState() { super.initState(); _tabs = TabController(length: 3, vsync: this); }
  @override
  void dispose() { _tabs.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.obsidian,
      appBar: AppBar(
        backgroundColor: AppColors.charcoal,
        surfaceTintColor: Colors.transparent,
        bottom: PreferredSize(preferredSize: const Size.fromHeight(49),
          child: Column(children: [
            Container(height: 1, color: AppColors.border),
            TabBar(controller: _tabs, indicatorColor: AppColors.gold, indicatorWeight: 2,
              labelColor: AppColors.gold, unselectedLabelColor: AppColors.textMuted,
              labelStyle: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 12),
              dividerColor: Colors.transparent,
              tabs: const [Tab(text: 'Schedule'), Tab(text: 'Coverage'), Tab(text: 'Alerts')]),
          ])),
        title: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Vaccination Center', style: GoogleFonts.inter(fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
          Text('National Immunization Program — Egypt', style: GoogleFonts.inter(fontSize: 10, color: AppColors.textMuted)),
        ]),
      ),
      body: TabBarView(controller: _tabs, children: [
        _ScheduleTab(ageGroups: _ageGroups, selected: _ageGroup, schedules: _schedules,
          onSelect: (a) => setState(() => _ageGroup = a)),
        _CoverageTab(data: _coverageData),
        _AlertsTab(alerts: _alerts),
      ]),
    );
  }
}

// ─── SCHEDULE TAB ─────────────────────────────────────────────
class _ScheduleTab extends StatelessWidget {
  final List<String> ageGroups; final String selected;
  final Map<String, List<Map<String, dynamic>>> schedules;
  final ValueChanged<String> onSelect;
  const _ScheduleTab({required this.ageGroups, required this.selected, required this.schedules, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    final vaccines = schedules[selected] ?? [];
    return Column(children: [
      // Age group selector
      Container(color: AppColors.charcoal, padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
        child: SizedBox(height: 36, child: ListView(scrollDirection: Axis.horizontal,
          children: ageGroups.map((a) => GestureDetector(onTap: () => onSelect(a),
            child: AnimatedContainer(duration: const Duration(milliseconds: 150),
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
              decoration: BoxDecoration(
                color: selected == a ? AppColors.gold : AppColors.elevated,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: selected == a ? AppColors.gold : AppColors.border)),
              child: Text(a, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700,
                color: selected == a ? AppColors.obsidian : AppColors.textSecondary))))).toList()))),
      Container(height: 1, color: AppColors.border),
      // Header
      Container(color: AppColors.inkBlack, padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(children: [
          Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(color: AppColors.gold.withOpacity(0.1), borderRadius: BorderRadius.circular(4), border: Border.all(color: AppColors.gold.withOpacity(0.3))),
            child: Text('${vaccines.length} vaccines for $selected', style: GoogleFonts.inter(fontSize: 11, color: AppColors.gold, fontWeight: FontWeight.w600))),
          const Spacer(),
          _MandatoryLegend(),
        ])),
      Container(height: 1, color: AppColors.border),
      // Vaccine list
      Expanded(child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 20),
        itemCount: vaccines.length,
        itemBuilder: (_, i) => _VaccineCard(v: vaccines[i]).animate(delay: (i * 50).ms).fadeIn().slideX(begin: 0.05))),
    ]);
  }
}

class _MandatoryLegend extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Row(mainAxisSize: MainAxisSize.min, children: [
    Container(width: 10, height: 10, decoration: BoxDecoration(color: AppColors.catCardio, borderRadius: BorderRadius.circular(2))),
    const SizedBox(width: 4),
    Text('Required', style: GoogleFonts.inter(fontSize: 10, color: AppColors.textMuted)),
    const SizedBox(width: 10),
    Container(width: 10, height: 10, decoration: BoxDecoration(color: AppColors.elevated, borderRadius: BorderRadius.circular(2), border: Border.all(color: AppColors.border))),
    const SizedBox(width: 4),
    Text('Optional', style: GoogleFonts.inter(fontSize: 10, color: AppColors.textMuted)),
  ]);
}

class _VaccineCard extends StatelessWidget {
  final Map<String, dynamic> v;
  const _VaccineCard({required this.v});
  @override
  Widget build(BuildContext context) {
    final mandatory = v['mandatory'] as bool;
    final color = mandatory ? AppColors.catCardio : AppColors.catHepato;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(color: AppColors.inkBlack, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.border)),
      child: ClipRRect(borderRadius: BorderRadius.circular(12), child: Row(children: [
        Container(width: 3, decoration: BoxDecoration(color: color, borderRadius: const BorderRadius.horizontal(left: Radius.circular(12)))),
        Expanded(child: Padding(padding: const EdgeInsets.all(14), child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
          Row(children: [
            Expanded(child: Text(v['vaccine'] as String, style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 14, color: AppColors.textPrimary))),
            Container(padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
              decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(4), border: Border.all(color: color.withOpacity(0.3))),
              child: Text(mandatory ? 'REQUIRED' : 'OPTIONAL', style: GoogleFonts.inter(fontSize: 8, color: color, fontWeight: FontWeight.w800, letterSpacing: 0.5))),
          ]),
          const SizedBox(height: 6),
          Text(v['description'] as String, style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary, height: 1.4)),
          const SizedBox(height: 8),
          Row(children: [
            _VTag(Icons.schedule_rounded, v['timing'] as String, AppColors.catInfectious),
            const SizedBox(width: 10),
            _VTag(Icons.vaccines_rounded, '${v['doses']} dose${(v['doses'] as int) > 1 ? 's' : ''}', AppColors.gold),
          ]),
          const SizedBox(height: 6),
          Row(children: [
            Icon(Icons.info_outline_rounded, size: 12, color: AppColors.textMuted),
            const SizedBox(width: 5),
            Expanded(child: Text('Side effects: ${v['side_effects']}', style: GoogleFonts.inter(fontSize: 11, color: AppColors.textMuted))),
          ]),
        ]))),
      ])));
  }
}

class _VTag extends StatelessWidget {
  final IconData icon; final String l; final Color c;
  const _VTag(this.icon, this.l, this.c);
  @override
  Widget build(BuildContext context) => Row(mainAxisSize: MainAxisSize.min, children: [
    Icon(icon, size: 11, color: c), const SizedBox(width: 4),
    Text(l, style: GoogleFonts.inter(fontSize: 11, color: c, fontWeight: FontWeight.w500)),
  ]);
}

// ─── COVERAGE TAB ─────────────────────────────────────────────
class _CoverageTab extends StatelessWidget {
  final List<Map<String, dynamic>> data;
  const _CoverageTab({required this.data});
  @override
  Widget build(BuildContext context) {
    return ListView(padding: const EdgeInsets.all(16), children: [
      // Summary cards
      Row(children: [
        _CovStat('93.2%', 'DTP3 Coverage', AppColors.catInfectious),
        const SizedBox(width: 10),
        _CovStat('88.5%', 'MCV2 Coverage', AppColors.catOncology),
        const SizedBox(width: 10),
        _CovStat('42.1%', 'COVID-19 Booster', AppColors.catMental),
      ]).animate().fadeIn(),
      const SizedBox(height: 20),
      Text('Vaccination Coverage vs. WHO Targets 2024',
        style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
      const SizedBox(height: 4),
      Text('National immunization program — Egypt Ministry of Health',
        style: GoogleFonts.inter(fontSize: 11, color: AppColors.textMuted)),
      const SizedBox(height: 14),
      ...data.asMap().entries.map((e) {
        final i = e.key; final d = e.value;
        final cov    = d['coverage'] as double;
        final target = d['target'] as double;
        final color  = d['color'] as Color;
        final onTarget = cov >= target;
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(color: AppColors.inkBlack, borderRadius: BorderRadius.circular(10), border: Border.all(color: AppColors.border)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
            Row(children: [
              Expanded(child: Text(d['vaccine'] as String, style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 13, color: AppColors.textPrimary))),
              Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(color: onTarget ? AppColors.catHepato.withOpacity(0.12) : AppColors.catCardio.withOpacity(0.12), borderRadius: BorderRadius.circular(4)),
                child: Text(onTarget ? 'ON TARGET' : 'BELOW TARGET', style: GoogleFonts.inter(fontSize: 8, color: onTarget ? AppColors.catHepato : AppColors.catCardio, fontWeight: FontWeight.w700, letterSpacing: 0.5))),
            ]),
            const SizedBox(height: 8),
            Stack(children: [
              Container(height: 8, decoration: BoxDecoration(color: AppColors.elevated, borderRadius: BorderRadius.circular(4))),
              FractionallySizedBox(widthFactor: (target / 100).clamp(0.0, 1.0),
                child: Container(height: 8, decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(4)))),
              FractionallySizedBox(widthFactor: (cov / 100).clamp(0.0, 1.0),
                child: Container(height: 8, decoration: BoxDecoration(gradient: LinearGradient(colors: [color.withOpacity(0.7), color]), borderRadius: BorderRadius.circular(4)))),
            ]),
            const SizedBox(height: 5),
            Row(children: [
              Text('${cov.toStringAsFixed(1)}% coverage', style: GoogleFonts.inter(fontSize: 11, color: color, fontWeight: FontWeight.w700)),
              const Spacer(),
              Text('Target: ${target.toStringAsFixed(0)}%', style: GoogleFonts.inter(fontSize: 11, color: AppColors.textMuted)),
            ]),
          ])).animate(delay: (i * 40).ms).fadeIn();
      }),
    ]);
  }
}

class _CovStat extends StatelessWidget {
  final String v, l; final Color c;
  const _CovStat(this.v, this.l, this.c);
  @override
  Widget build(BuildContext context) => Expanded(child: Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(color: AppColors.inkBlack, borderRadius: BorderRadius.circular(10), border: Border.all(color: c.withOpacity(0.25))),
    child: Column(mainAxisSize: MainAxisSize.min, children: [
      Text(v, style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w800, color: c)),
      const SizedBox(height: 3),
      Text(l, style: GoogleFonts.inter(fontSize: 9, color: AppColors.textMuted, height: 1.3), textAlign: TextAlign.center),
    ])));
}

// ─── ALERTS TAB ───────────────────────────────────────────────
class _AlertsTab extends StatelessWidget {
  final List<Map<String, dynamic>> alerts;
  const _AlertsTab({required this.alerts});
  @override
  Widget build(BuildContext context) {
    return ListView(padding: const EdgeInsets.all(16), children: [
      Container(padding: const EdgeInsets.all(12), margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(color: AppColors.gold.withOpacity(0.08), borderRadius: BorderRadius.circular(8), border: Border.all(color: AppColors.gold.withOpacity(0.25))),
        child: Row(children: [
          const Icon(Icons.notifications_active_rounded, color: AppColors.gold, size: 18),
          const SizedBox(width: 10),
          Expanded(child: Text('${alerts.length} active vaccination alerts — Ministry of Health & Population, Egypt 2025',
            style: GoogleFonts.inter(fontSize: 12, color: AppColors.gold, fontWeight: FontWeight.w500))),
        ])),
      ...alerts.asMap().entries.map((e) {
        final i = e.key; final a = e.value;
        final color = a['color'] as Color;
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(color: AppColors.inkBlack, borderRadius: BorderRadius.circular(12), border: Border.all(color: color.withOpacity(0.3))),
          child: ClipRRect(borderRadius: BorderRadius.circular(12), child: Row(children: [
            Container(width: 3, color: color),
            Expanded(child: Padding(padding: const EdgeInsets.all(14), child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
              Row(children: [
                Icon(a['icon'] as IconData, size: 18, color: color),
                const SizedBox(width: 8),
                Expanded(child: Text(a['title'] as String, style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 13, color: AppColors.textPrimary))),
              ]),
              const SizedBox(height: 8),
              Text(a['body'] as String, style: GoogleFonts.inter(fontSize: 12.5, color: AppColors.textSecondary, height: 1.55)),
            ]))),
          ]))).animate(delay: (i * 60).ms).fadeIn().slideX(begin: 0.06);
      }),
    ]);
  }
}
