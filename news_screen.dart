import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/api_service.dart';
import '../config/app_colors.dart';

// ── MOCK NEWS (always shown when backend offline) ─────────────
const List<Map<String, dynamic>> _mockArticles = [
  {'id':'1','title':'Egypt Achieves WHO Hepatitis C Elimination Target Three Years Early','summary':'Egypt has officially achieved the WHO hepatitis C elimination target, with prevalence dropping from 7.5% to 0.87% following the largest treatment program in history — 62 million screened, 4.5 million treated.','category':'Achievement','author':'MOHP Communications','date':'2025-01-15','readTime':4,'views':14200,'featured':true},
  {'id':'2','title':'NHODP Releases 12 New Open Health Datasets for 2024','summary':'The National Health Open Data Portal publishes 12 comprehensive health datasets covering oncology, infectious disease, maternal health, and health infrastructure — all under CC BY 4.0 license.','category':'Data Release','author':'NHODP Data Team','date':'2025-01-10','readTime':3,'views':8900,'featured':true},
  {'id':'3','title':'Ministry Launches Universal Health Insurance in 6 New Governorates','summary':'Universal Health Insurance coverage expands to Qena, Sohag, Asyut, Minya, Beni Suef, and Fayoum — bringing total coverage to 16 of 27 governorates serving 45 million citizens.','category':'Health Policy','author':'UHI Authority','date':'2025-01-08','readTime':5,'views':11300,'featured':false},
  {'id':'4','title':'National AI Diagnostic Platform Deployed at 50 University Hospitals','summary':'Egypt\'s MOHP deploys AI-assisted radiology reading at 50 university hospitals, reducing diagnostic turnaround from 72 hours to 4 hours for chest X-rays and CT scans.','category':'Digital Health','author':'MOHP Digital Transformation Unit','date':'2024-12-28','readTime':4,'views':7600,'featured':false},
  {'id':'5','title':'Egypt Cancer Registry Reports 35% Drop in Late-Stage Diagnoses Since 2020','summary':'The National Cancer Institute reports that early-stage cancer detection has risen from 28% to 52% following the 100 Million Healthy Lives screening initiative, translating to 15,000 additional lives annually.','category':'Achievement','author':'National Cancer Institute','date':'2024-12-20','readTime':6,'views':9800,'featured':false},
  {'id':'6','title':'MOHP Deploys 15 Million Influenza Vaccines Ahead of 2025 Season','summary':'Mass influenza vaccination campaign begins targeting high-risk groups: elderly 60+, healthcare workers, pregnant women, and children. Drive-through vaccination points active in all 27 governorates.','category':'Public Health','author':'MOHP Preventive Medicine','date':'2024-12-15','readTime':3,'views':12100,'featured':false},
  {'id':'7','title':'Egypt Exceeds WHO Maternal Mortality Reduction Target for 2024','summary':'Maternal mortality rate drops to 52 per 100,000 live births — exceeding the WHO EMRO target of 60 — following deployment of 3,000 skilled birth attendants to rural health units.','category':'Achievement','author':'MOHP Safe Motherhood Unit','date':'2024-12-10','readTime':4,'views':6700,'featured':false},
  {'id':'8','title':'New Mental Health Law Mandates Psychiatric Services at Primary Care Level','summary':'Egypt\'s amended Mental Health Law No. 71 now requires all primary care units to offer telepsychiatry services, eliminating the need for patients to travel to specialized centers.','category':'Mental Health','author':'MOHP Mental Health Department','date':'2024-12-05','readTime':5,'views':5400,'featured':false},
  {'id':'9','title':'NHODP API Reaches 1 Million Requests — Opens to Global Researchers','summary':'The NHODP developer API surpasses 1 million total requests from 45 countries. New open-access tier provides 500 requests/hour without API key for academic research.','category':'Digital Health','author':'NHODP Engineering Team','date':'2024-11-28','readTime':3,'views':4200,'featured':false},
  {'id':'10','title':'Childhood Obesity Prevention Program Launches in 500 Primary Schools','summary':'A joint MOHP-Ministry of Education program introduces structured physical activity (45 min/day) and nutrition education in 500 public primary schools covering 250,000 students.','category':'Public Health','author':'MOHP Nutrition Department','date':'2024-11-20','readTime':4,'views':7100,'featured':false},
];

const Map<String, Color> _catColors = {
  'Achievement':       AppColors.catHepato,
  'Data Release':      AppColors.catInfectious,
  'Health Policy':     AppColors.catMental,
  'Digital Health':    AppColors.catNutrition,
  'Public Health':     AppColors.catInfectious,
  'Mental Health':     AppColors.catMental,
  'Infectious Disease':AppColors.catCardio,
  'Cardiology':        AppColors.catCardio,
};

class NewsScreen extends StatefulWidget {
  const NewsScreen({Key? key}) : super(key: key);
  @override State<NewsScreen> createState() => _NewsScreenState();
}

class _NewsScreenState extends State<NewsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabs;
  List<Map<String, dynamic>> _live = [];
  bool _liveOnline = false;
  bool _loading = true;
  String _selCat = 'All';

  static const _cats = ['All','Achievement','Data Release','Health Policy','Digital Health','Public Health','Mental Health'];

  @override
  void initState() { super.initState(); _tabs = TabController(length: 2, vsync: this); _load(); }
  @override void dispose() { _tabs.dispose(); super.dispose(); }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final r = await ApiService.getArticles(limit: 30);
      if ((r as List).isNotEmpty && mounted) {
        setState(() {
          _liveOnline = true;
          _live = r.map((a) => a as Map<String, dynamic>).toList();
          _loading = false;
        });
        return;
      }
    } catch (_) {}
    if (mounted) setState(() => _loading = false);
  }

  List<Map<String, dynamic>> get _src => _liveOnline ? _live : _mockArticles;
  List<Map<String, dynamic>> get _filtered => _selCat == 'All' ? _src : _src.where((a) => a['category'] == _selCat).toList();
  List<Map<String, dynamic>> get _trending => [..._src]..sort((a, b) => ((b['views'] as int?) ?? 0).compareTo((a['views'] as int?) ?? 0));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.obsidian,
      appBar: AppBar(
        backgroundColor: AppColors.charcoal,
        surfaceTintColor: Colors.transparent,
        title: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Health News', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
          Text('${_src.length} articles · NHODP Editorial', style: GoogleFonts.inter(fontSize: 10, color: AppColors.textMuted)),
        ]),
        actions: [
          Container(margin: const EdgeInsets.only(right: 14),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: _liveOnline ? AppColors.catHepato.withOpacity(0.12) : AppColors.gold.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _liveOnline ? AppColors.catHepato.withOpacity(0.3) : AppColors.gold.withOpacity(0.3))),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Container(width: 5, height: 5, decoration: BoxDecoration(shape: BoxShape.circle, color: _liveOnline ? AppColors.catHepato : AppColors.gold)),
              const SizedBox(width: 4),
              Text(_liveOnline ? 'Live' : 'Demo', style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w600, color: _liveOnline ? AppColors.catHepato : AppColors.gold)),
            ])),
        ],
        bottom: PreferredSize(preferredSize: const Size.fromHeight(49), child: Column(children: [
          Container(height: 1, color: AppColors.border),
          TabBar(controller: _tabs, indicatorColor: AppColors.gold, indicatorWeight: 2,
            labelColor: AppColors.gold, unselectedLabelColor: AppColors.textMuted,
            labelStyle: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 12),
            dividerColor: Colors.transparent,
            tabs: const [Tab(text: 'Latest'), Tab(text: 'Trending')]),
        ])),
      ),
      body: _loading
        ? const Center(child: CircularProgressIndicator(color: AppColors.gold, strokeWidth: 2))
        : Column(children: [
            // Category chips
            Container(color: AppColors.charcoal, padding: const EdgeInsets.fromLTRB(14, 8, 14, 10),
              child: SizedBox(height: 30, child: ListView(scrollDirection: Axis.horizontal, children: _cats.map((c) =>
                GestureDetector(onTap: () => setState(() => _selCat = c),
                  child: AnimatedContainer(duration: const Duration(milliseconds: 140),
                    margin: const EdgeInsets.only(right: 7),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                    decoration: BoxDecoration(color: _selCat == c ? AppColors.gold : AppColors.elevated, borderRadius: BorderRadius.circular(5), border: Border.all(color: _selCat == c ? AppColors.gold : AppColors.border)),
                    child: Text(c, style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700, color: _selCat == c ? AppColors.obsidian : AppColors.textSecondary))))).toList()))),
            Container(height: 1, color: AppColors.border),
            Expanded(child: TabBarView(controller: _tabs, children: [
              // LATEST
              RefreshIndicator(color: AppColors.gold, backgroundColor: AppColors.inkBlack, onRefresh: _load,
                child: ListView.builder(
                  padding: const EdgeInsets.fromLTRB(14, 8, 14, 20),
                  itemCount: _filtered.length,
                  itemBuilder: (_, i) => _ArticleCard(a: _filtered[i]).animate(delay: (i * 40).ms).fadeIn())),
              // TRENDING
              ListView.builder(
                padding: const EdgeInsets.fromLTRB(14, 8, 14, 20),
                itemCount: _trending.take(5).length,
                itemBuilder: (_, i) => _TrendingCard(a: _trending[i], rank: i + 1).animate(delay: (i * 60).ms).fadeIn()),
            ])),
          ]),
    );
  }
}

class _ArticleCard extends StatelessWidget {
  final Map<String, dynamic> a;
  const _ArticleCard({required this.a});
  @override
  Widget build(BuildContext context) {
    final cat   = a['category'] as String? ?? '';
    final color = _catColors[cat] ?? AppColors.catInfectious;
    final feat  = a['featured'] as bool? ?? false;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppColors.inkBlack,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: feat ? AppColors.gold.withOpacity(0.3) : AppColors.border),
        boxShadow: feat ? [BoxShadow(color: AppColors.gold.withOpacity(0.07), blurRadius: 12, offset: const Offset(0, 3))] : []),
      child: ClipRRect(borderRadius: BorderRadius.circular(12), child: Column(mainAxisSize: MainAxisSize.min, children: [
        // Color top bar
        Container(height: 2, decoration: BoxDecoration(
          gradient: LinearGradient(colors: [color, color.withOpacity(0.2), Colors.transparent]))),
        Padding(padding: const EdgeInsets.all(14), child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
          Row(children: [
            Container(padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
              decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(4), border: Border.all(color: color.withOpacity(0.3))),
              child: Text(cat, style: GoogleFonts.inter(fontSize: 9, color: color, fontWeight: FontWeight.w700))),
            if (feat) ...[
              const SizedBox(width: 6),
              Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(color: AppColors.gold.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
                child: Text('FEATURED', style: GoogleFonts.inter(fontSize: 8, color: AppColors.gold, fontWeight: FontWeight.w800, letterSpacing: 0.5))),
            ],
            const Spacer(),
            Text(a['date'] as String? ?? '', style: GoogleFonts.inter(fontSize: 10, color: AppColors.textMuted)),
          ]),
          const SizedBox(height: 8),
          Text(a['title'] as String? ?? '', style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 14, color: AppColors.textPrimary, height: 1.3)),
          const SizedBox(height: 6),
          Text(a['summary'] as String? ?? '', style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary, height: 1.5), maxLines: 2, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 10),
          Row(children: [
            Icon(Icons.person_outline_rounded, size: 12, color: AppColors.textMuted),
            const SizedBox(width: 4),
            Expanded(child: Text(a['author'] as String? ?? '', style: GoogleFonts.inter(fontSize: 10, color: AppColors.textMuted), maxLines: 1, overflow: TextOverflow.ellipsis)),
            const SizedBox(width: 8),
            Icon(Icons.visibility_outlined, size: 12, color: AppColors.textMuted),
            const SizedBox(width: 4),
            Text('${a['views'] ?? 0}', style: GoogleFonts.inter(fontSize: 10, color: AppColors.textMuted)),
            const SizedBox(width: 8),
            Icon(Icons.schedule_rounded, size: 12, color: AppColors.textMuted),
            const SizedBox(width: 4),
            Text('${a['readTime'] ?? 3} min', style: GoogleFonts.inter(fontSize: 10, color: AppColors.textMuted)),
          ]),
        ])),
      ])));
  }
}

class _TrendingCard extends StatelessWidget {
  final Map<String, dynamic> a; final int rank;
  const _TrendingCard({required this.a, required this.rank});
  @override
  Widget build(BuildContext context) {
    final cat   = a['category'] as String? ?? '';
    final color = _catColors[cat] ?? AppColors.catInfectious;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: AppColors.inkBlack, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.border)),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(width: 36, height: 36, decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8), border: Border.all(color: color.withOpacity(0.3))),
          child: Center(child: Text('$rank', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w900, color: color)))),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(a['title'] as String? ?? '', style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 13, color: AppColors.textPrimary, height: 1.3), maxLines: 2, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 5),
          Row(children: [
            Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(3)),
              child: Text(cat, style: GoogleFonts.inter(fontSize: 9, color: color, fontWeight: FontWeight.w700))),
            const SizedBox(width: 8),
            Icon(Icons.visibility_outlined, size: 11, color: AppColors.textMuted),
            const SizedBox(width: 3),
            Text('${a['views'] ?? 0} views', style: GoogleFonts.inter(fontSize: 10, color: AppColors.textMuted)),
          ]),
        ])),
      ]));
  }
}
