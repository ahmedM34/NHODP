import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../config/app_colors.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.obsidian,
      appBar: AppBar(backgroundColor: AppColors.charcoal, surfaceTintColor: Colors.transparent,
        title: Text('About NHODP', style: GoogleFonts.inter(color: AppColors.textPrimary, fontWeight: FontWeight.w700)),
        bottom: PreferredSize(preferredSize: const Size.fromHeight(1), child: Container(height: 1, color: AppColors.border))),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        _heroBanner().animate().fadeIn(),
        const SizedBox(height: 20),
        Row(children: [
          _statBox('12', 'Datasets', Icons.dataset_rounded, AppColors.catInfectious),
          const SizedBox(width: 10),
          _statBox('27', 'Governorates', Icons.map_rounded, AppColors.catHepato),
          const SizedBox(width: 10),
          _statBox('18', 'Indicators', Icons.monitor_heart_rounded, AppColors.gold),
        ]).animate(delay: 100.ms).fadeIn(),
        const SizedBox(height: 20),
        _sectionCard('Our Mission', 'NHODP democratizes access to Egypt\'s health data. By providing open, machine-readable datasets under Creative Commons licensing, we enable evidence-based research, policy analysis, and public health innovation that benefits all Egyptians.'),
        _sourceSection().animate(delay: 150.ms).fadeIn(),
        _methodologySection().animate(delay: 200.ms).fadeIn(),
        _qualitySection().animate(delay: 250.ms).fadeIn(),
        _govSection().animate(delay: 300.ms).fadeIn(),
        _partnersSection().animate(delay: 350.ms).fadeIn(),
        _licenseSection().animate(delay: 400.ms).fadeIn(),
        _contactCard().animate(delay: 450.ms).fadeIn(),
        const SizedBox(height: 8),
        Text('NHODP v2.0.0  ·  © 2026 Ministry of Health & Population, Egypt', style: GoogleFonts.inter(color: AppColors.textMuted, fontSize: 10), textAlign: TextAlign.center),
        const SizedBox(height: 16),
      ]),
    );
  }

  Widget _heroBanner() {
    return Container(padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(color: AppColors.goldSurface, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.gold.withOpacity(0.25))),
      child: Column(children: [
        ShaderMask(shaderCallback: (b) => const LinearGradient(colors: [AppColors.gold, AppColors.goldBright]).createShader(b),
          child: const Icon(Icons.health_and_safety_rounded, color: Colors.white, size: 48)),
        const SizedBox(height: 14),
        Text('NHODP', style: GoogleFonts.inter(color: AppColors.textPrimary, fontSize: 32, fontWeight: FontWeight.w800, letterSpacing: 4)),
        const SizedBox(height: 4),
        Text('National Health Open Data Portal', style: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 14)),
        Text('جمهورية مصر العربية', style: GoogleFonts.inter(color: AppColors.gold.withOpacity(0.7), fontSize: 12)),
        const SizedBox(height: 14),
        Container(width: 60, height: 1.5, decoration: BoxDecoration(gradient: AppColors.goldAccent)),
        const SizedBox(height: 14),
        Text('Empowering researchers, clinicians, and policymakers\nwith Egypt\'s most comprehensive health data.',
          textAlign: TextAlign.center, style: GoogleFonts.inter(color: AppColors.textMuted, fontSize: 13, height: 1.6)),
      ]));
  }

  Widget _statBox(String value, String label, IconData icon, Color color) {
    return Expanded(child: Container(padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(color: AppColors.inkBlack, borderRadius: BorderRadius.circular(12), border: Border.all(color: color.withOpacity(0.2))),
      child: Column(children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(height: 6),
        Text(value, style: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
        Text(label, style: GoogleFonts.inter(fontSize: 10, color: AppColors.textMuted)),
      ])));
  }

  Widget _sectionCard(String title, String text) {
    return Container(margin: const EdgeInsets.only(bottom: 14), padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppColors.inkBlack, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.border)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: GoogleFonts.inter(fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
        Container(width: 30, height: 1.5, margin: const EdgeInsets.only(top: 4, bottom: 12), decoration: BoxDecoration(gradient: AppColors.goldAccent)),
        Text(text, style: GoogleFonts.inter(fontSize: 13, color: AppColors.textSecondary, height: 1.7)),
      ]));
  }

  Widget _sourceSection() {
    final sources = [
      ['Ministry of Health & Population (MOHP)', 'National health statistics, vital records, and surveillance.'],
      ['CAPMAS Egypt', 'Demographic surveys, mortality, and population estimates.'],
      ['National Cancer Institute (NCI Cairo)', 'Cancer registry, incidence, and survival statistics.'],
      ['Primary Health Care Corporation', 'Primary care utilization and patient registration.'],
      ['WHO / UNICEF Egypt', 'Validation, immunization, and maternal health indicators.'],
    ];
    return Container(margin: const EdgeInsets.only(bottom: 14), padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppColors.inkBlack, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.border)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Data Sources', style: GoogleFonts.inter(fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
        Container(width: 30, height: 1.5, margin: const EdgeInsets.only(top: 4, bottom: 12), decoration: BoxDecoration(gradient: AppColors.goldAccent)),
        ...sources.map((s) => Padding(padding: const EdgeInsets.only(bottom: 10), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(width: 5, height: 5, margin: const EdgeInsets.only(top: 6, right: 10), decoration: const BoxDecoration(color: AppColors.gold, shape: BoxShape.circle)),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(s[0], style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 12, color: AppColors.textPrimary)),
            Text(s[1], style: GoogleFonts.inter(fontSize: 11, color: AppColors.textMuted)),
          ])),
        ]))),
      ]));
  }

  Widget _methodologySection() {
    return _sectionCard('Data Methodology',
      '1. Collection — From official government systems, surveys, and registries.\n\n'
      '2. Validation — Cross-referenced against WHO, UNICEF, and World Bank indicators.\n\n'
      '3. Anonymization — Record-level data de-identified using our 11-type PHI pipeline.\n\n'
      '4. Standardization — FHIR-compatible JSON and CSV formats.\n\n'
      '5. Licensing — Published under CC BY 4.0 unless otherwise stated.');
  }

  Widget _qualitySection() {
    final metrics = [
      ['Completeness', 0.88, AppColors.successLight],
      ['Accuracy', 0.92, AppColors.successLight],
      ['Timeliness', 0.75, AppColors.gold],
      ['Accessibility', 0.95, AppColors.successLight],
      ['Interoperability', 0.70, AppColors.gold],
    ];
    return Container(margin: const EdgeInsets.only(bottom: 14), padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppColors.inkBlack, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.border)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Data Quality Framework', style: GoogleFonts.inter(fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
        Container(width: 30, height: 1.5, margin: const EdgeInsets.only(top: 4, bottom: 12), decoration: BoxDecoration(gradient: AppColors.goldAccent)),
        ...metrics.map((m) => Padding(padding: const EdgeInsets.only(bottom: 10), child: Row(children: [
          SizedBox(width: 110, child: Text(m[0] as String, style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w600))),
          Expanded(child: ClipRRect(borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(value: m[1] as double, minHeight: 8, backgroundColor: AppColors.elevated,
              valueColor: AlwaysStoppedAnimation(m[2] as Color)))),
          const SizedBox(width: 10),
          Text('${((m[1] as double) * 100).toInt()}%', style: GoogleFonts.inter(fontSize: 11, color: m[2] as Color, fontWeight: FontWeight.w700)),
        ]))),
      ]));
  }

  Widget _govSection() {
    return _sectionCard('Governance & Privacy',
      'NHODP operates under Egyptian Personal Data Protection Law (No. 151 of 2020) and WHO data sharing guidelines.\n\n'
      'All personally identifiable information is removed using our automated PHI detection pipeline before publication.\n\n'
      'Oversight: Technical Advisory Committee comprising MOHP, Cairo University Faculty of Medicine, and the Egyptian Medical Syndicate.');
  }

  Widget _partnersSection() {
    final partners = [
      [Icons.local_hospital_rounded, 'WHO Eastern Mediterranean Regional Office (EMRO)', AppColors.catInfectious],
      [Icons.child_care_rounded, 'UNICEF Egypt Country Office', AppColors.catPediatrics],
      [Icons.school_rounded, 'Cairo University Faculty of Medicine', AppColors.catMental],
      [Icons.analytics_rounded, 'Institute for Health Metrics and Evaluation (IHME)', AppColors.catHepato],
      [Icons.public_rounded, 'World Bank Health, Nutrition & Population', AppColors.catNutrition],
    ];
    return Container(margin: const EdgeInsets.only(bottom: 14), padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppColors.inkBlack, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.border)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Partners & Affiliations', style: GoogleFonts.inter(fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
        Container(width: 30, height: 1.5, margin: const EdgeInsets.only(top: 4, bottom: 12), decoration: BoxDecoration(gradient: AppColors.goldAccent)),
        ...partners.map((p) => Padding(padding: const EdgeInsets.only(bottom: 9), child: Row(children: [
          Container(padding: const EdgeInsets.all(7), decoration: BoxDecoration(color: (p[2] as Color).withOpacity(0.1), borderRadius: BorderRadius.circular(7)),
            child: Icon(p[0] as IconData, color: p[2] as Color, size: 14)),
          const SizedBox(width: 10),
          Expanded(child: Text(p[1] as String, style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary))),
        ]))),
      ]));
  }

  Widget _licenseSection() {
    return _sectionCard('Data License',
      'All datasets are published under CC BY 4.0 International unless noted otherwise.\n\n'
      'You are free to share and adapt the material for any purpose, including commercial use, '
      'provided appropriate credit is given to NHODP and the Ministry of Health & Population, Egypt.\n\n'
      'Citation: NHODP (2026). [Dataset Name]. National Health Open Data Portal, MOHP Egypt. https://nhodp.gov.eg');
  }

  Widget _contactCard() {
    final contacts = [
      [Icons.email_rounded, 'data@nhodp.gov.eg', 'Data inquiries & requests'],
      [Icons.bug_report_rounded, 'tech@nhodp.gov.eg', 'Technical issues'],
      [Icons.policy_rounded, 'policy@nhodp.gov.eg', 'Governance & licensing'],
      [Icons.location_on_rounded, 'Cairo, Arab Republic of Egypt', 'MOHP Headquarters'],
    ];
    return Container(margin: const EdgeInsets.only(bottom: 20), padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppColors.inkBlack, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.border)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Contact Us', style: GoogleFonts.inter(fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
        Container(width: 30, height: 1.5, margin: const EdgeInsets.only(top: 4, bottom: 12), decoration: BoxDecoration(gradient: AppColors.goldAccent)),
        ...contacts.map((c) => Padding(padding: const EdgeInsets.only(bottom: 10), child: Row(children: [
          Icon(c[0] as IconData, color: AppColors.gold.withOpacity(0.7), size: 16),
          const SizedBox(width: 10),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(c[1] as String, style: GoogleFonts.inter(color: AppColors.textPrimary, fontSize: 13, fontWeight: FontWeight.w600)),
            Text(c[2] as String, style: GoogleFonts.inter(color: AppColors.textMuted, fontSize: 11)),
          ])),
        ]))),
      ]));
  }
}
