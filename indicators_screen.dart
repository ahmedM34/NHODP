import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';
import '../config/app_colors.dart';

class IndicatorsScreen extends StatefulWidget {
  const IndicatorsScreen({Key? key}) : super(key: key);
  @override State<IndicatorsScreen> createState() => _IndicatorsScreenState();
}

class _IndicatorsScreenState extends State<IndicatorsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabs;
  String _cat = 'All';
  String _search = '';

  static const _cats = ['All','Mortality','Morbidity','Nutrition','Workforce','Infrastructure','Immunization','NCD'];

  static const List<Map<String, dynamic>> _data = [
    {'id':'EG001','name':'Life Expectancy at Birth','cat':'Mortality','val':72.4,'unit':'years','trend':[69.2,70.1,70.8,71.3,71.9,72.4],'global':73.3,'regional':69.1,'dir':'up','sdg':'SDG 3.4','src':'WHO GHO'},
    {'id':'EG002','name':'Infant Mortality Rate','cat':'Mortality','val':17.5,'unit':'per 1,000 LB','trend':[28.0,24.3,22.1,20.5,19.0,17.5],'global':28.0,'regional':38.2,'dir':'down_good','sdg':'SDG 3.2','src':'MOHP'},
    {'id':'EG003','name':'Maternal Mortality Ratio','cat':'Mortality','val':52.0,'unit':'per 100K LB','trend':[83.0,74.0,68.0,62.0,57.0,52.0],'global':223.0,'regional':174.0,'dir':'down_good','sdg':'SDG 3.1','src':'MOHP'},
    {'id':'EG004','name':'Under-5 Mortality Rate','cat':'Mortality','val':22.3,'unit':'per 1,000 LB','trend':[35.0,30.2,27.4,25.1,23.5,22.3],'global':38.0,'regional':49.0,'dir':'down_good','sdg':'SDG 3.2','src':'UNICEF'},
    {'id':'EG005','name':'Neonatal Mortality Rate','cat':'Mortality','val':12.8,'unit':'per 1,000 LB','trend':[18.0,16.5,15.0,14.2,13.5,12.8],'global':17.0,'regional':22.0,'dir':'down_good','sdg':'SDG 3.2','src':'MOHP'},
    {'id':'EG006','name':'Diabetes Prevalence','cat':'NCD','val':17.2,'unit':'% adults','trend':[14.1,14.9,15.5,16.0,16.7,17.2],'global':9.3,'regional':12.2,'dir':'up_bad','sdg':'SDG 3.4','src':'IDF'},
    {'id':'EG007','name':'Hypertension Prevalence','cat':'NCD','val':26.3,'unit':'% adults','trend':[23.1,23.8,24.5,25.0,25.7,26.3],'global':28.0,'regional':25.0,'dir':'up_bad','sdg':'SDG 3.4','src':'WHO'},
    {'id':'EG008','name':'Obesity Prevalence','cat':'Nutrition','val':34.5,'unit':'% adults','trend':[28.2,29.8,31.0,32.4,33.5,34.5],'global':19.0,'regional':26.5,'dir':'up_bad','sdg':'SDG 2.2','src':'NCD RisC'},
    {'id':'EG009','name':'Stunting Under-5','cat':'Nutrition','val':22.3,'unit':'% children','trend':[33.0,29.4,27.0,25.1,23.8,22.3],'global':22.3,'regional':27.0,'dir':'down_good','sdg':'SDG 2.2','src':'EDHS'},
    {'id':'EG010','name':'Physician Density','cat':'Workforce','val':8.1,'unit':'per 10,000','trend':[6.2,6.8,7.1,7.5,7.8,8.1],'global':18.0,'regional':9.0,'dir':'up','sdg':'SDG 3.c','src':'WHO'},
    {'id':'EG011','name':'Nursing & Midwifery','cat':'Workforce','val':14.7,'unit':'per 10,000','trend':[11.0,11.8,12.5,13.2,13.9,14.7],'global':30.0,'regional':16.0,'dir':'up','sdg':'SDG 3.c','src':'WHO'},
    {'id':'EG012','name':'Hospital Bed Density','cat':'Infrastructure','val':15.8,'unit':'per 10,000','trend':[13.1,13.8,14.2,14.8,15.2,15.8],'global':27.0,'regional':14.0,'dir':'up','sdg':'SDG 3.8','src':'MOHP'},
    {'id':'EG013','name':'DTP3 Immunization Coverage','cat':'Immunization','val':93.2,'unit':'%','trend':[89.0,90.1,91.0,91.8,92.5,93.2],'global':84.0,'regional':88.0,'dir':'up','sdg':'SDG 3.b','src':'WHO/UNICEF'},
    {'id':'EG014','name':'Measles Coverage MCV2','cat':'Immunization','val':88.5,'unit':'%','trend':[83.0,84.2,85.5,86.4,87.5,88.5],'global':71.0,'regional':84.0,'dir':'up','sdg':'SDG 3.b','src':'WHO'},
    {'id':'EG015','name':'Hepatitis C Prevalence','cat':'Morbidity','val':0.87,'unit':'% population','trend':[7.5,5.2,3.8,2.4,1.6,0.87],'global':1.0,'regional':2.8,'dir':'down_good','sdg':'SDG 3.3','src':'MOHP'},
    {'id':'EG016','name':'Tuberculosis Incidence','cat':'Morbidity','val':14.0,'unit':'per 100,000','trend':[18.5,17.2,16.5,15.8,14.9,14.0],'global':133.0,'regional':50.0,'dir':'down_good','sdg':'SDG 3.3','src':'WHO'},
    {'id':'EG017','name':'UHC Service Coverage Index','cat':'Infrastructure','val':62.0,'unit':'score /100','trend':[54.0,56.0,57.5,59.0,60.5,62.0],'global':68.0,'regional':57.0,'dir':'up','sdg':'SDG 3.8','src':'WHO'},
    {'id':'EG018','name':'Out-of-Pocket Health Exp.','cat':'Infrastructure','val':62.4,'unit':'% total health','trend':[68.2,66.5,65.8,64.9,63.5,62.4],'global':38.0,'regional':55.0,'dir':'down_good','sdg':'SDG 3.8','src':'WHO NHA'},
  ];

  List<Map<String, dynamic>> get _filtered => _data.where((d) {
    final matchCat = _cat == 'All' || d['cat'] == _cat;
    final q = _search.toLowerCase();
    final matchQ = q.isEmpty || (d['name'] as String).toLowerCase().contains(q) || (d['sdg'] as String).toLowerCase().contains(q);
    return matchCat && matchQ;
  }).toList();

  @override
  void initState() { super.initState(); _tabs = TabController(length: 2, vsync: this); }
  @override void dispose() { _tabs.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;
    return Scaffold(
      backgroundColor: AppColors.obsidian,
      appBar: AppBar(
        backgroundColor: AppColors.charcoal,
        surfaceTintColor: Colors.transparent,
        title: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Health Indicators', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
          Text('WHO GHO Standard — Egypt ${filtered.length} indicators', style: GoogleFonts.inter(fontSize: 10, color: AppColors.textMuted)),
        ]),
        bottom: PreferredSize(preferredSize: const Size.fromHeight(49), child: Column(children: [
          Container(height: 1, color: AppColors.border),
          TabBar(controller: _tabs, indicatorColor: AppColors.gold, indicatorWeight: 2,
            labelColor: AppColors.gold, unselectedLabelColor: AppColors.textMuted,
            labelStyle: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 12),
            dividerColor: Colors.transparent,
            tabs: const [Tab(text: 'Indicators Table'), Tab(text: 'SDG Tracker')]),
        ])),
      ),
      body: Column(children: [
        // Search + category filter
        Container(color: AppColors.charcoal, padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            TextField(
              style: GoogleFonts.inter(color: AppColors.textPrimary, fontSize: 13),
              decoration: InputDecoration(
                hintText: 'Search indicators, SDG goals…',
                hintStyle: GoogleFonts.inter(color: AppColors.textMuted, fontSize: 13),
                prefixIcon: const Icon(Icons.search_rounded, color: AppColors.gold, size: 18),
                filled: true, fillColor: AppColors.elevated,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.border)),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.border)),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.gold, width: 1.5)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10)),
              onChanged: (v) => setState(() => _search = v)),
            const SizedBox(height: 8),
            SizedBox(height: 30, child: ListView(scrollDirection: Axis.horizontal, children: _cats.map((c) =>
              GestureDetector(onTap: () => setState(() => _cat = c),
                child: AnimatedContainer(duration: const Duration(milliseconds: 140),
                  margin: const EdgeInsets.only(right: 7),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                  decoration: BoxDecoration(
                    color: _cat == c ? AppColors.gold : AppColors.elevated,
                    borderRadius: BorderRadius.circular(5),
                    border: Border.all(color: _cat == c ? AppColors.gold : AppColors.border)),
                  child: Text(c, style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700, color: _cat == c ? AppColors.obsidian : AppColors.textSecondary))))).toList())),
          ])),
        Container(height: 1, color: AppColors.border),
        Container(color: AppColors.inkBlack, padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
          child: Row(children: [
            Text('${filtered.length} indicators', style: GoogleFonts.inter(fontSize: 11, color: AppColors.textMuted, fontWeight: FontWeight.w500)),
            const Spacer(),
            Text('Source: WHO GHO · MOHP · CAPMAS', style: GoogleFonts.inter(fontSize: 10, color: AppColors.textMuted)),
          ])),
        Container(height: 1, color: AppColors.border),
        Expanded(child: filtered.isEmpty
          ? Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
              const Icon(Icons.search_off_rounded, size: 40, color: AppColors.textMuted),
              const SizedBox(height: 10),
              Text('No indicators found', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
              const SizedBox(height: 4),
              Text('Try different search terms', style: GoogleFonts.inter(fontSize: 12, color: AppColors.textMuted)),
            ]))
          : TabBarView(controller: _tabs, children: [
              // TABLE VIEW
              ListView.builder(
                padding: const EdgeInsets.fromLTRB(14, 8, 14, 20),
                itemCount: filtered.length,
                itemBuilder: (_, i) => _IndicatorCard(d: filtered[i]).animate(delay: (i * 35).ms).fadeIn()),
              // SDG TRACKER VIEW
              ListView.builder(
                padding: const EdgeInsets.fromLTRB(14, 8, 14, 20),
                itemCount: filtered.length,
                itemBuilder: (_, i) => _SdgCard(d: filtered[i]).animate(delay: (i * 35).ms).fadeIn()),
            ])),
      ]),
    );
  }
}

class _IndicatorCard extends StatelessWidget {
  final Map<String, dynamic> d;
  const _IndicatorCard({required this.d});

  Color get _dirColor {
    final dir = d['dir'] as String;
    if (dir == 'down_good' || dir == 'up') return AppColors.catHepato;
    if (dir == 'up_bad') return AppColors.catCardio;
    return AppColors.textSecondary;
  }

  IconData get _dirIcon {
    final dir = d['dir'] as String;
    if (dir == 'down_good') return Icons.trending_down_rounded;
    if (dir == 'up_bad') return Icons.trending_up_rounded;
    return Icons.trending_up_rounded;
  }

  @override
  Widget build(BuildContext context) {
    final val  = (d['val'] as num).toDouble();
    final glob = (d['global'] as num).toDouble();
    final reg  = (d['regional'] as num).toDouble();
    final trend = (d['trend'] as List).cast<num>();

    return GestureDetector(
      onTap: () => _showDetail(context),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(color: AppColors.inkBlack, borderRadius: BorderRadius.circular(10), border: Border.all(color: AppColors.border)),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
            // Header row
            Row(children: [
              Container(width: 3, height: 20, decoration: BoxDecoration(color: _dirColor, borderRadius: BorderRadius.circular(2))),
              const SizedBox(width: 8),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(d['name'] as String, style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 13, color: AppColors.textPrimary)),
                Row(children: [
                  Text(d['sdg'] as String, style: GoogleFonts.inter(fontSize: 10, color: AppColors.gold, fontWeight: FontWeight.w600)),
                  const SizedBox(width: 8),
                  Text(d['src'] as String, style: GoogleFonts.inter(fontSize: 10, color: AppColors.textMuted)),
                ]),
              ])),
              Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                Text('${val} ${d['unit']}', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
                Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(_dirIcon, size: 12, color: _dirColor),
                  const SizedBox(width: 3),
                  Text(d['dir'] == 'down_good' ? 'Improving' : d['dir'] == 'up_bad' ? 'Worsening' : 'Improving',
                    style: GoogleFonts.inter(fontSize: 10, color: _dirColor, fontWeight: FontWeight.w600)),
                ]),
              ]),
            ]),
            const SizedBox(height: 10),
            // Comparison row
            Row(children: [
              _CompBadge('EG', val.toStringAsFixed(1), _dirColor),
              const SizedBox(width: 8),
              _CompBadge('GL', glob.toStringAsFixed(1), AppColors.textSecondary),
              const SizedBox(width: 8),
              _CompBadge('MENA', reg.toStringAsFixed(1), AppColors.textMuted),
              const Spacer(),
              // Mini sparkline
              SizedBox(width: 64, height: 24, child: LineChart(LineChartData(
                gridData: const FlGridData(show: false),
                titlesData: const FlTitlesData(show: false),
                borderData: FlBorderData(show: false),
                lineBarsData: [LineChartBarData(
                  spots: trend.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value.toDouble())).toList(),
                  isCurved: true, color: _dirColor, barWidth: 1.5, dotData: const FlDotData(show: false),
                  belowBarData: BarAreaData(show: true, color: _dirColor.withOpacity(0.08)))],
                minY: trend.reduce((a, b) => a < b ? a : b).toDouble() * 0.95,
                maxY: trend.reduce((a, b) => a > b ? a : b).toDouble() * 1.05,
              ))),
            ]),
          ]))));
  }

  void _showDetail(BuildContext context) {
    final trend = (d['trend'] as List).cast<num>();
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.darkSurface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(padding: const EdgeInsets.all(20), child: Column(mainAxisSize: MainAxisSize.min, children: [
        Center(child: Container(width: 32, height: 3, decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(2)))),
        const SizedBox(height: 14),
        Row(children: [
          Expanded(child: Text(d['name'] as String, style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textPrimary))),
          Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: AppColors.gold.withOpacity(0.1), borderRadius: BorderRadius.circular(6), border: Border.all(color: AppColors.gold.withOpacity(0.3))),
            child: Text(d['sdg'] as String, style: GoogleFonts.inter(color: AppColors.gold, fontSize: 11, fontWeight: FontWeight.w700))),
        ]),
        const SizedBox(height: 16),
        Row(children: [
          _DetailStat('Egypt', '${d['val']}', d['unit'] as String, _dirColor),
          const SizedBox(width: 10),
          _DetailStat('Global', '${d['global']}', d['unit'] as String, AppColors.textSecondary),
          const SizedBox(width: 10),
          _DetailStat('MENA', '${d['regional']}', d['unit'] as String, AppColors.textMuted),
        ]),
        const SizedBox(height: 16),
        Text('6-Year Trend', style: GoogleFonts.inter(color: AppColors.textMuted, fontSize: 11, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        SizedBox(height: 100, child: LineChart(LineChartData(
          gridData: FlGridData(show: true, drawVerticalLine: false, getDrawingHorizontalLine: (_) => FlLine(color: AppColors.border, strokeWidth: 0.5)),
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 18,
              getTitlesWidget: (v, _) { final yrs = ['2019','2020','2021','2022','2023','2024']; return Text(yrs[v.toInt().clamp(0,5)], style: GoogleFonts.inter(fontSize: 8, color: AppColors.textMuted)); })),
            leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false))),
          borderData: FlBorderData(show: false),
          lineBarsData: [LineChartBarData(
            spots: trend.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value.toDouble())).toList(),
            isCurved: true, color: _dirColor, barWidth: 2.5,
            dotData: FlDotData(show: true, getDotPainter: (_, __, ___, ____) => FlDotCirclePainter(radius: 3, color: _dirColor, strokeWidth: 0)),
            belowBarData: BarAreaData(show: true, color: _dirColor.withOpacity(0.08)))],
        ))),
        const SizedBox(height: 14),
        SizedBox(width: double.infinity, child: OutlinedButton.icon(
          onPressed: () { Navigator.pop(context); ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Data exported as CSV', style: GoogleFonts.inter()), backgroundColor: AppColors.catHepato)); },
          icon: const Icon(Icons.download_rounded, size: 16),
          label: Text('Export Data', style: GoogleFonts.inter(fontWeight: FontWeight.w600)))),
      ])));
  }
}

class _CompBadge extends StatelessWidget {
  final String label, val; final Color c;
  const _CompBadge(this.label, this.val, this.c);
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(color: c.withOpacity(0.08), borderRadius: BorderRadius.circular(5), border: Border.all(color: c.withOpacity(0.2))),
    child: Column(mainAxisSize: MainAxisSize.min, children: [
      Text(label, style: GoogleFonts.inter(fontSize: 8, color: c.withOpacity(0.7), letterSpacing: 0.5)),
      Text(val, style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700, color: c)),
    ]));
}

class _DetailStat extends StatelessWidget {
  final String label, val, unit; final Color c;
  const _DetailStat(this.label, this.val, this.unit, this.c);
  @override
  Widget build(BuildContext context) => Expanded(child: Container(
    padding: const EdgeInsets.all(10),
    decoration: BoxDecoration(color: AppColors.elevated, borderRadius: BorderRadius.circular(8), border: Border.all(color: c.withOpacity(0.2))),
    child: Column(mainAxisSize: MainAxisSize.min, children: [
      Text(label, style: GoogleFonts.inter(fontSize: 9, color: AppColors.textMuted)),
      const SizedBox(height: 3),
      Text(val, style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w800, color: c)),
      Text(unit, style: GoogleFonts.inter(fontSize: 8, color: AppColors.textMuted), textAlign: TextAlign.center),
    ])));
}

class _SdgCard extends StatelessWidget {
  final Map<String, dynamic> d;
  const _SdgCard({required this.d});

  Color get _col {
    final dir = d['dir'] as String;
    if (dir == 'down_good' || dir == 'up') return AppColors.catHepato;
    return AppColors.catCardio;
  }

  @override
  Widget build(BuildContext context) {
    final val  = (d['val'] as num).toDouble();
    final glob = (d['global'] as num).toDouble();
    final better = (d['dir'] == 'down_good') ? val < glob : val > glob;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: AppColors.inkBlack, borderRadius: BorderRadius.circular(10), border: Border.all(color: _col.withOpacity(0.25))),
      child: Row(children: [
        Container(width: 48, height: 48, decoration: BoxDecoration(color: _col.withOpacity(0.1), borderRadius: BorderRadius.circular(8), border: Border.all(color: _col.withOpacity(0.3))),
          child: Center(child: Text(d['sdg'] as String, style: GoogleFonts.inter(fontSize: 8, fontWeight: FontWeight.w800, color: _col), textAlign: TextAlign.center))),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(d['name'] as String, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
          const SizedBox(height: 3),
          Text('Egypt: ${d['val']} ${d['unit']}  ·  Global: ${d['global']}', style: GoogleFonts.inter(fontSize: 10, color: AppColors.textSecondary)),
        ])),
        Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(better ? Icons.check_circle_rounded : Icons.warning_rounded, size: 20, color: _col),
          Text(better ? 'ON TRACK' : 'LAGGING', style: GoogleFonts.inter(fontSize: 8, color: _col, fontWeight: FontWeight.w700)),
        ]),
      ]));
  }
}
