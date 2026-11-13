// ============================================================
// PUBLICATIONS & REPORTS SCREEN
// Like WHO reports / CDC MMWR / NHS Digital publications
// Features: research papers, policy reports, data stories,
//           annual health reports with download
// ============================================================
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../config/app_colors.dart';

class PublicationsScreen extends StatefulWidget {
  const PublicationsScreen({Key? key}) : super(key: key);
  @override
  State<PublicationsScreen> createState() => _PublicationsScreenState();
}

class _PublicationsScreenState extends State<PublicationsScreen> {
  String _selType = 'All';
  String _searchQ = '';

  static const _types = ['All','Annual Report','Data Brief','Policy Note','Research Paper','Statistical Bulletin'];

  static const List<Map<String, dynamic>> _pubs = [
    {'title':'Egypt National Health Report 2025','type':'Annual Report','date':'March 2026','authors':'Ministry of Health & Population','pages':247,'downloads':4821,'abstract':'Comprehensive review of Egypt\'s health system performance in 2025, covering service coverage, disease burden, workforce, infrastructure, and financing across all 27 governorates.','tags':['Annual','National','MOHP'],'featured':true},
    {'title':'Hepatitis C Elimination: Lessons from Egypt\'s 100 Million Campaign','type':'Research Paper','date':'January 2026','authors':'Rady A, Hassan F, Khalil M et al.','pages':18,'downloads':2340,'abstract':'Analysis of the world\'s largest hepatitis C treatment program, examining screening strategies, treatment uptake, and elimination outcomes across Egyptian governorates.','tags':['Hepatitis C','Elimination','Public Health'],'featured':true},
    {'title':'Diabetes Burden in Egypt 2023: A National Survey','type':'Statistical Bulletin','date':'November 2025','authors':'CAPMAS, MOHP','pages':64,'downloads':1890,'abstract':'National survey results on type 1 and type 2 diabetes prevalence, risk factors, treatment adherence, and complications among Egyptian adults.','tags':['Diabetes','NCD','Survey'],'featured':false},
    {'title':'Universal Health Insurance: Year 3 Progress Report','type':'Policy Note','date':'October 2025','authors':'Health Insurance Authority','pages':32,'downloads':3210,'abstract':'Progress update on UHI implementation, enrollment statistics, benefit package utilization, and financial sustainability across the six pioneer governorates.','tags':['UHI','Coverage','Policy'],'featured':false},
    {'title':'Child Nutrition and Growth in Egypt: 2022 Data Brief','type':'Data Brief','date':'September 2025','authors':'UNICEF Egypt, MOHP','pages':12,'downloads':1560,'abstract':'Key findings from the 2022 Egypt Multiple Indicator Cluster Survey on child malnutrition, stunting, wasting, and overweight prevalence.','tags':['Nutrition','Children','MICS'],'featured':false},
    {'title':'Mental Health in Egypt: Burden, Gaps, and Pathways','type':'Research Paper','date':'August 2025','authors':'Fouad S, Ibrahim M, WHO EMRO','pages':41,'downloads':980,'abstract':'Systematic analysis of mental health prevalence, treatment gaps, and integration of mental health into primary care in Egypt, with policy recommendations.','tags':['Mental Health','Primary Care','WHO'],'featured':false},
    {'title':'Cancer Registry Annual Report 2020-2024','type':'Annual Report','date':'June 2025','authors':'National Cancer Institute Cairo','pages':189,'downloads':1240,'abstract':'Five-year cancer incidence, mortality, and survival data from Egypt\'s national cancer registry, with geographic and demographic breakdowns by governorate.','tags':['Cancer','Registry','Oncology'],'featured':true},
    {'title':'Health Workforce in Egypt: Status and Projections 2025-2030','type':'Statistical Bulletin','date':'May 2025','authors':'MOHP Human Resources Department','pages':88,'downloads':721,'abstract':'Analysis of Egypt\'s health workforce composition, geographic distribution, training capacity, and projections needed to meet UHC targets by 2030.','tags':['Workforce','Capacity','Planning'],'featured':false},
    {'title':'COVID-19 in Egypt: Epidemiological Review 2020-2023','type':'Research Paper','date':'March 2025','authors':'National Public Health Institute','pages':55,'downloads':4560,'abstract':'Comprehensive epidemiological review of COVID-19 in Egypt including wave analysis, vaccination campaign outcomes, and health system response.','tags':['COVID-19','Pandemic','Epidemiology'],'featured':false},
    {'title':'Maternal Mortality in Egypt: Progress and Remaining Challenges','type':'Data Brief','date':'February 2025','authors':'MOHP Safe Motherhood Unit','pages':16,'downloads':720,'abstract':'Analysis of maternal mortality ratio trends, causes of death, and geographic disparities between governorates with policy recommendations for SDG 3.1.','tags':['Maternal','Mortality','SDG'],'featured':false},
  ];

  List<Map<String, dynamic>> get _filtered => _pubs.where((p) {
    final matchType = _selType == 'All' || p['type'] == _selType;
    final matchQ = _searchQ.isEmpty || (p['title'] as String).toLowerCase().contains(_searchQ.toLowerCase()) || (p['abstract'] as String).toLowerCase().contains(_searchQ.toLowerCase());
    return matchType && matchQ;
  }).toList();

  @override
  Widget build(BuildContext context) {
    final featured = _filtered.where((p) => p['featured'] == true).toList();
    final rest = _filtered.where((p) => p['featured'] != true).toList();

    return Scaffold(
      backgroundColor: AppColors.obsidian,
      appBar: AppBar(backgroundColor: AppColors.charcoal, surfaceTintColor: Colors.transparent,
        title: Text('Publications & Reports', style: GoogleFonts.inter(color: AppColors.textPrimary, fontWeight: FontWeight.w700)),
        bottom: PreferredSize(preferredSize: const Size.fromHeight(1), child: Container(height: 1, color: AppColors.border))),
      body: Column(children: [
        Container(color: AppColors.charcoal, padding: const EdgeInsets.fromLTRB(14, 10, 14, 10), child: Column(children: [
          TextField(style: GoogleFonts.inter(color: AppColors.textPrimary, fontSize: 13),
            decoration: InputDecoration(hintText: 'Search publications, reports...', hintStyle: GoogleFonts.inter(color: AppColors.textMuted, fontSize: 13),
              prefixIcon: const Icon(Icons.search_rounded, color: AppColors.gold, size: 18), filled: true, fillColor: AppColors.elevated,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.border)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.border)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.gold, width: 1.5)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12)),
            onChanged: (v) => setState(() => _searchQ = v)),
          const SizedBox(height: 8),
          SingleChildScrollView(scrollDirection: Axis.horizontal, child: Row(children: _types.map((t) => Padding(padding: const EdgeInsets.only(right: 8),
              child: GestureDetector(onTap: () => setState(() => _selType = t),
                child: AnimatedContainer(duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                  decoration: BoxDecoration(color: _selType == t ? AppColors.gold.withOpacity(0.12) : AppColors.elevated, borderRadius: BorderRadius.circular(16), border: Border.all(color: _selType == t ? AppColors.gold : AppColors.border, width: _selType == t ? 1.5 : 1)),
                  child: Text(t, style: GoogleFonts.inter(fontSize: 11, color: _selType == t ? AppColors.gold : AppColors.textMuted, fontWeight: _selType == t ? FontWeight.w700 : FontWeight.w500)))))).toList())),
        ])),
        Expanded(child: ListView(padding: const EdgeInsets.all(14), children: [
          if (featured.isNotEmpty && _selType == 'All' && _searchQ.isEmpty) ...[
            Row(children: [
              ShaderMask(shaderCallback: (b) => const LinearGradient(colors: [AppColors.gold, AppColors.goldBright]).createShader(b),
                child: const Icon(Icons.star_rounded, color: Colors.white, size: 16)),
              const SizedBox(width: 6),
              Text('Featured Publications', style: GoogleFonts.inter(color: AppColors.gold, fontWeight: FontWeight.w700, fontSize: 13, letterSpacing: 0.5)),
            ]),
            const SizedBox(height: 10),
            ...featured.asMap().entries.map((e) => _PubCard(pub: e.value, index: e.key, featured: true)),
            const SizedBox(height: 16),
            Text('All Publications', style: GoogleFonts.inter(color: AppColors.textMuted, fontWeight: FontWeight.w700, fontSize: 13)),
            const SizedBox(height: 10),
          ],
          ...(_selType == 'All' && _searchQ.isEmpty ? rest : _filtered).asMap().entries.map((e) => _PubCard(pub: e.value, index: e.key + featured.length, featured: false)),
        ])),
      ]),
    );
  }
}

class _PubCard extends StatelessWidget {
  final Map<String, dynamic> pub;
  final int index;
  final bool featured;
  const _PubCard({required this.pub, required this.index, required this.featured});

  static const _typeColors = {
    'Annual Report': AppColors.catOncology, 'Data Brief': AppColors.catInfectious,
    'Policy Note': AppColors.catMental, 'Research Paper': AppColors.catHepato,
    'Statistical Bulletin': AppColors.catNutrition,
  };
  static const _typeIcons = {
    'Annual Report': Icons.summarize_rounded, 'Data Brief': Icons.data_object_rounded,
    'Policy Note': Icons.policy_rounded, 'Research Paper': Icons.science_rounded,
    'Statistical Bulletin': Icons.bar_chart_rounded,
  };

  @override
  Widget build(BuildContext context) {
    final type  = pub['type'] as String;
    final color = _typeColors[type] ?? AppColors.catInfrastructure;
    final icon  = _typeIcons[type] ?? Icons.article_rounded;
    final tags  = (pub['tags'] as List).cast<String>();

    return GestureDetector(
      onTap: () => _showDetail(context),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: featured ? AppColors.goldSurface : AppColors.inkBlack,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: featured ? AppColors.gold.withOpacity(0.25) : AppColors.border),
          boxShadow: featured ? [BoxShadow(color: AppColors.gold.withOpacity(0.08), blurRadius: 12)] : [],
        ),
        child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(8), border: Border.all(color: color.withOpacity(0.25))),
              child: Icon(icon, color: color, size: 18)),
            const SizedBox(width: 10),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Container(padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(4), border: Border.all(color: color.withOpacity(0.3))),
                child: Text(type, style: GoogleFonts.inter(fontSize: 9, color: color, fontWeight: FontWeight.w700, letterSpacing: 0.5))),
              const SizedBox(height: 3),
              Text(pub['date'] as String, style: GoogleFonts.inter(fontSize: 10, color: AppColors.textMuted)),
            ])),
            if (featured) Container(padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
              decoration: BoxDecoration(color: AppColors.gold.withOpacity(0.1), borderRadius: BorderRadius.circular(4), border: Border.all(color: AppColors.gold.withOpacity(0.3))),
              child: Text('FEATURED', style: GoogleFonts.inter(fontSize: 8, color: AppColors.gold, fontWeight: FontWeight.w800, letterSpacing: 1))),
          ]),
          const SizedBox(height: 10),
          Text(pub['title'] as String, style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 16, color: AppColors.textPrimary, height: 1.2), maxLines: 2, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 5),
          Text(pub['authors'] as String, style: GoogleFonts.inter(fontSize: 11, color: AppColors.textMuted), maxLines: 1, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 8),
          Text(pub['abstract'] as String, style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary, height: 1.45), maxLines: 2, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 10),
          Row(children: [
            Icon(Icons.download_rounded, size: 12, color: AppColors.textMuted),
            const SizedBox(width: 4),
            Text('${pub['downloads']} downloads', style: GoogleFonts.inter(fontSize: 11, color: AppColors.textMuted)),
            const SizedBox(width: 12),
            Icon(Icons.article_rounded, size: 12, color: AppColors.textMuted),
            const SizedBox(width: 4),
            Text('${pub['pages']} pages', style: GoogleFonts.inter(fontSize: 11, color: AppColors.textMuted)),
            const Spacer(),
            ...tags.take(2).map((t) => Container(margin: const EdgeInsets.only(left: 4), padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(color: AppColors.elevated, borderRadius: BorderRadius.circular(4)),
              child: Text(t, style: GoogleFonts.inter(fontSize: 9, color: AppColors.textMuted)))),
          ]),
        ])),
      ),
    ).animate(delay: (index * 50).ms).fadeIn().slideY(begin: 0.05);
  }

  void _showDetail(BuildContext context) {
    showModalBottomSheet(context: context, isScrollControlled: true, backgroundColor: AppColors.darkSurface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => Padding(padding: const EdgeInsets.all(24), child: Column(mainAxisSize: MainAxisSize.min, children: [
        Center(child: Container(width: 36, height: 3, margin: const EdgeInsets.only(bottom: 16), decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(2)))),
        Text(pub['type'] as String, style: GoogleFonts.inter(color: AppColors.gold, fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 1)),
        const SizedBox(height: 8),
        Text(pub['title'] as String, style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.textPrimary, height: 1.2)),
        const SizedBox(height: 8),
        Text(pub['authors'] as String, style: GoogleFonts.inter(color: AppColors.textMuted, fontSize: 12)),
        Text(pub['date'] as String, style: GoogleFonts.inter(color: AppColors.textMuted, fontSize: 12)),
        Container(width: 40, height: 1.5, margin: const EdgeInsets.symmetric(vertical: 14), decoration: BoxDecoration(gradient: AppColors.goldAccent)),
        Text(pub['abstract'] as String, style: GoogleFonts.inter(fontSize: 14, color: AppColors.textSecondary, height: 1.7)),
        const SizedBox(height: 20),
        SizedBox(width: double.infinity, child: GestureDetector(
          onTap: () { Navigator.pop(context); ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Downloading PDF...', style: GoogleFonts.inter()), backgroundColor: AppColors.success)); },
          child: Container(height: 50, decoration: BoxDecoration(gradient: const LinearGradient(colors: [AppColors.goldDim, AppColors.gold]), borderRadius: BorderRadius.circular(12)),
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              const Icon(Icons.download_rounded, color: AppColors.obsidian, size: 18),
              const SizedBox(width: 8),
              Text('Download PDF · ${pub['pages']} pages', style: GoogleFonts.inter(color: AppColors.obsidian, fontWeight: FontWeight.w800, fontSize: 14)),
            ])))),
      ])));
  }
}
