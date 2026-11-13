import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../config/app_colors.dart';

class HealthCalendarScreen extends StatefulWidget {
  const HealthCalendarScreen({Key? key}) : super(key: key);
  @override
  State<HealthCalendarScreen> createState() => _HealthCalendarScreenState();
}

class _HealthCalendarScreenState extends State<HealthCalendarScreen> {
  String _filter = 'All';
  static const _filters = ['All', 'Campaign', 'Awareness', 'Emergency', 'WHO'];

  static const List<Map<String, dynamic>> _events = [
    // CRITICAL ALERTS
    {'month':'Jan 2025','day':15,'title':'Avian Influenza H5N1 Monitoring Enhanced','type':'Emergency','desc':'MOHP activates enhanced surveillance at all poultry farms and border crossings following WHO reports of H5N1 spread in the region. Citizens advised to avoid contact with sick birds.','color':AppColors.catCardio,'icon':Icons.emergency_rounded,'priority':'critical'},
    {'month':'Feb 2025','day':4,'title':'World Cancer Day — Free Screening Campaign','type':'Awareness','desc':'National Cancer Institute and 150 MOHP centers offer free mammography, pap smear, and colorectal cancer screening across all 27 governorates. Book via health.gov.eg.','color':AppColors.catOncology,'icon':Icons.campaign_rounded,'priority':'high'},
    {'month':'Mar 2025','day':7,'title':'Influenza Season End — Surveillance Continues','type':'Campaign','desc':'2024/25 influenza season officially ended. H3N2 was dominant strain. Surveillance maintained. COVID-19/Influenza co-infection monitoring active at all hospitals.','color':AppColors.catInfectious,'icon':Icons.vaccines_rounded,'priority':'medium'},
    {'month':'Mar 2025','day':22,'title':'World Water Day — Cholera Prevention Campaign','type':'Campaign','desc':'MOHP and WHO launch joint cholera prevention initiative targeting flood-prone areas in Delta region. Oral cholera vaccine distributed to 500,000 high-risk residents.','color':AppColors.catHepato,'icon':Icons.water_drop_rounded,'priority':'high'},
    {'month':'Apr 2025','day':7,'title':'World Health Day — Universal Coverage Theme','type':'Awareness','desc':'WHO 2025 theme: My Health, My Right. Egypt commits to extending UHI to 6 additional governorates (total: 16 of 27 covered). Free registration drive for all uninsured citizens.','color':AppColors.catInfectious,'icon':Icons.health_and_safety_rounded,'priority':'high'},
    {'month':'Apr 2025','day':24,'title':'World Malaria Day — Vector Control Campaign','type':'Campaign','desc':'Delta and canal governorates receive intensive vector control operations. 12 million homes inspected. No indigenous malaria transmission in Egypt since 2014.','color':AppColors.catMental,'icon':Icons.bug_report_rounded,'priority':'medium'},
    {'month':'May 2025','day':1,'title':'Hajj Season Vaccination Mandatory Deadline','type':'Emergency','desc':'ALL Hajj and Umra pilgrims MUST have: ACWY Meningococcal vaccine, COVID-19 booster, Influenza vaccine. Medical certificates required at point of departure. 1.8M pilgrims affected.','color':AppColors.catCardio,'icon':Icons.emergency_rounded,'priority':'critical'},
    {'month':'May 2025','day':31,'title':'World No Tobacco Day — Smoking Cessation Initiative','type':'Awareness','desc':'Ministry of Health launches free smoking cessation clinics at 1,200 primary care units. Nicotine replacement therapy provided free of charge for 3 months to registered participants.','color':AppColors.catNutrition,'icon':Icons.smoke_free_rounded,'priority':'medium'},
    {'month':'Jun 2025','day':5,'title':'National Hepatitis C Elimination Update','type':'Campaign','desc':'Progress report: 62.4M screened, 4.5M treated, Egypt achieves WHO elimination targets (prevalence < 1%) 3 years ahead of schedule. WHO certification ceremony in Cairo.','color':AppColors.catHepato,'icon':Icons.emoji_events_rounded,'priority':'high'},
    {'month':'Jun 2025','day':14,'title':'World Blood Donor Day — National Drive','type':'Campaign','desc':'National Blood Transfusion Service targets collection of 500,000 units. All 450 donation centers open extended hours. Rare blood type drive (Rh negative, Bombay).','color':AppColors.catCardio,'icon':Icons.bloodtype_rounded,'priority':'medium'},
    {'month':'Jul 2025','day':28,'title':'World Hepatitis Day — Awareness Campaign','type':'Awareness','desc':'Egypt highlights its model of viral hepatitis elimination as benchmark for global programs. Free testing for hepatitis B and C at all UHI centers.','color':AppColors.catHepato,'icon':Icons.coronavirus_rounded,'priority':'medium'},
    {'month':'Sep 2025','day':10,'title':'World Suicide Prevention Day — Mental Health Response','type':'Awareness','desc':'MOHP launches national mental health helpline (08008880700). Telepsychiatry services expanded to cover all governorates. 350 new psychiatrists deployed to public hospitals.','color':AppColors.catMental,'icon':Icons.psychology_rounded,'priority':'high'},
    {'month':'Sep 2025','day':26,'title':'World Contraception Day — Family Planning Campaign','type':'Campaign','desc':'Free family planning services at all MOHP centers. Distribution of 3 million contraceptive kits. Targeting reduction of unintended pregnancy rate by 15%.','color':AppColors.catMaternal,'icon':Icons.pregnant_woman_rounded,'priority':'medium'},
    {'month':'Oct 2025','day':1,'title':'2025/26 Influenza Season Opens — Mass Vaccination','type':'Campaign','desc':'Mass influenza vaccination campaign begins. Priority: elderly 60+, pregnant women, healthcare workers, children 6m–5y, chronic disease patients. 15 million doses available nationwide.','color':AppColors.catInfectious,'icon':Icons.vaccines_rounded,'priority':'critical'},
    {'month':'Oct 2025','day':10,'title':'World Mental Health Day — "Mind Your Health" Campaign','type':'Awareness','desc':'National awareness on depression and anxiety. Free psychiatric consultations at 800 centers. Egypt targets 30% reduction in untreated mental illness by 2030.','color':AppColors.catMental,'icon':Icons.mood_rounded,'priority':'high'},
    {'month':'Nov 2025','day':14,'title':'World Diabetes Day — National Screening','type':'Awareness','desc':'Free HbA1c and fasting glucose testing at all 2,600 primary care units. Diabetes management training for 50,000 healthcare workers. New national diabetes registry launched.','color':AppColors.catEndocrine,'icon':Icons.monitor_heart_rounded,'priority':'high'},
    {'month':'Dec 2025','day':1,'title':'World AIDS Day — HIV Testing & Awareness','type':'Awareness','desc':'Free anonymous HIV testing at 400 centers nationwide. Egypt reports 95% of diagnosed HIV patients on antiretroviral therapy — exceeding UNAIDS 95-95-95 target.','color':AppColors.catOncology,'icon':Icons.health_and_safety_rounded,'priority':'medium'},
    {'month':'Dec 2025','day':15,'title':'Meningococcal Alert — University Campuses','type':'Emergency','desc':'Cluster of meningococcal cases detected at 2 university campuses. Prophylactic antibiotics distributed to close contacts. Enhanced surveillance activated. Public advised to report symptoms promptly.','color':AppColors.catCardio,'icon':Icons.emergency_rounded,'priority':'critical'},
  ];

  List<Map<String, dynamic>> get _filtered =>
    _filter == 'All' ? _events : _events.where((e) => e['type'] == _filter).toList();

  Color _priorityColor(String p) {
    if (p == 'critical') return AppColors.catCardio;
    if (p == 'high') return AppColors.gold;
    return AppColors.textSecondary;
  }

  @override
  Widget build(BuildContext context) {
    final events = _filtered;
    final critical = events.where((e) => e['priority'] == 'critical').length;
    final high     = events.where((e) => e['priority'] == 'high').length;

    return Scaffold(
      backgroundColor: AppColors.obsidian,
      appBar: AppBar(
        backgroundColor: AppColors.charcoal,
        surfaceTintColor: Colors.transparent,
        bottom: PreferredSize(preferredSize: const Size.fromHeight(1), child: Container(height: 1, color: AppColors.border)),
        title: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Health Calendar 2025', style: GoogleFonts.inter(fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
          Text('Campaigns, awareness days & emergency alerts', style: GoogleFonts.inter(fontSize: 10, color: AppColors.textMuted)),
        ]),
      ),
      body: Column(children: [
        // Alert strip
        Container(color: AppColors.catCardio.withOpacity(0.08), padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(children: [
            Container(padding: const EdgeInsets.all(6), decoration: BoxDecoration(color: AppColors.catCardio.withOpacity(0.15), borderRadius: BorderRadius.circular(6)),
              child: Icon(Icons.emergency_rounded, size: 16, color: AppColors.catCardio)),
            const SizedBox(width: 10),
            Expanded(child: Text('$critical critical alerts active  ·  $high high-priority events', style: GoogleFonts.inter(fontSize: 12, color: AppColors.catCardio, fontWeight: FontWeight.w600))),
            const Icon(Icons.chevron_right_rounded, size: 16, color: AppColors.catCardio),
          ])),
        Container(height: 1, color: AppColors.border),
        // Filter chips
        Container(color: AppColors.charcoal, padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
          child: SizedBox(height: 32, child: ListView(scrollDirection: Axis.horizontal,
            children: _filters.map((f) => GestureDetector(onTap: () => setState(() => _filter = f),
              child: AnimatedContainer(duration: const Duration(milliseconds: 150),
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: _filter == f ? AppColors.gold : AppColors.elevated,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: _filter == f ? AppColors.gold : AppColors.border)),
                child: Text(f, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: _filter == f ? AppColors.obsidian : AppColors.textSecondary))))).toList()))),
        Container(height: 1, color: AppColors.border),
        // Events list
        Expanded(child: ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
          itemCount: events.length,
          itemBuilder: (_, i) {
            final e = events[i];
            final color    = e['color'] as Color;
            final priority = e['priority'] as String;
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(color: AppColors.inkBlack, borderRadius: BorderRadius.circular(12), border: Border.all(color: color.withOpacity(0.3))),
              child: ClipRRect(borderRadius: BorderRadius.circular(12), child: Row(children: [
                // Date column
                Container(width: 56, color: color.withOpacity(0.1), padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    Text((e['day'] as int).toString().padLeft(2, '0'), style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w800, color: color)),
                    Text(e['month'] as String, style: GoogleFonts.inter(fontSize: 8, color: color.withOpacity(0.7), letterSpacing: 0.3), textAlign: TextAlign.center),
                  ])),
                Container(width: 1, color: color.withOpacity(0.2)),
                Expanded(child: Padding(padding: const EdgeInsets.all(12), child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
                  Row(children: [
                    Icon(e['icon'] as IconData, size: 14, color: color),
                    const SizedBox(width: 6),
                    Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(3)),
                      child: Text(e['type'] as String, style: GoogleFonts.inter(fontSize: 8, color: color, fontWeight: FontWeight.w700))),
                    const SizedBox(width: 6),
                    if (priority == 'critical') Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(color: AppColors.catCardio.withOpacity(0.15), borderRadius: BorderRadius.circular(3)),
                      child: Text('CRITICAL', style: GoogleFonts.inter(fontSize: 8, color: AppColors.catCardio, fontWeight: FontWeight.w800, letterSpacing: 0.5))),
                  ]),
                  const SizedBox(height: 6),
                  Text(e['title'] as String, style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 13, color: AppColors.textPrimary, height: 1.3)),
                  const SizedBox(height: 5),
                  Text(e['desc'] as String, style: GoogleFonts.inter(fontSize: 11.5, color: AppColors.textSecondary, height: 1.5), maxLines: 3, overflow: TextOverflow.ellipsis),
                ]))),
              ]))).animate(delay: (i * 35).ms).fadeIn().slideY(begin: 0.04);
          })),
      ]),
    );
  }
}
