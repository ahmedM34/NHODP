import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/dataset_provider.dart';
import '../config/app_colors.dart';

const Map<String, Color> _catColor = {
  'Oncology': AppColors.catOncology, 'Infectious Disease': AppColors.catInfectious,
  'Endocrinology': AppColors.catEndocrine, 'Cardiology': AppColors.catCardio,
  'Hepatology': AppColors.catHepato, 'Maternal Health': AppColors.catMaternal,
  'Mental Health': AppColors.catMental, 'Pediatrics': AppColors.catPediatrics,
  'Nutrition': AppColors.catNutrition, 'Health Infrastructure': AppColors.catInfrastructure,
  'Neonatology': AppColors.catNeonatology,
};
const Map<String, IconData> _catIcon = {
  'Oncology': Icons.biotech_rounded, 'Infectious Disease': Icons.coronavirus_rounded,
  'Endocrinology': Icons.monitor_heart_rounded, 'Cardiology': Icons.favorite_rounded,
  'Hepatology': Icons.vaccines_rounded, 'Maternal Health': Icons.pregnant_woman_rounded,
  'Mental Health': Icons.psychology_rounded, 'Pediatrics': Icons.child_care_rounded,
  'Nutrition': Icons.local_dining_rounded, 'Health Infrastructure': Icons.local_hospital_rounded,
  'Neonatology': Icons.baby_changing_station_rounded,
};

class DatasetsScreen extends StatefulWidget {
  const DatasetsScreen({Key? key}) : super(key: key);
  @override State<DatasetsScreen> createState() => _DatasetsScreenState();
}

class _DatasetsScreenState extends State<DatasetsScreen> {
  final _ctrl = TextEditingController();
  String? _cat;
  int _page = 0;
  static const _per = 8;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final p = context.read<DatasetProvider>();
      p.fetchDatasets();
      p.fetchCategories();
    });
  }
  @override void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Consumer<DatasetProvider>(builder: (_, prov, __) {
      // Filter
      var list = prov.datasets;
      if (_cat != null) list = list.where((d) => d.category == _cat).toList();
      final q = _ctrl.text.trim().toLowerCase();
      if (q.isNotEmpty) list = list.where((d) =>
        d.title.toLowerCase().contains(q) || d.category.toLowerCase().contains(q) ||
        d.tags.join(' ').toLowerCase().contains(q) || (d.source ?? '').toLowerCase().contains(q)).toList();
      final totalPgs = (list.length / _per).ceil().clamp(1, 999);
      final page     = _page.clamp(0, totalPgs - 1);
      final items    = list.skip(page * _per).take(_per).toList();
      final cats     = prov.categories;

      return Scaffold(
        backgroundColor: AppColors.obsidian,
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => Navigator.pushNamed(context, '/create-dataset'),
          backgroundColor: AppColors.gold,
          foregroundColor: AppColors.obsidian,
          icon: const Icon(Icons.add_rounded, size: 20),
          label: Text('Create Dataset',
            style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w800)),
        ),
        appBar: AppBar(
          backgroundColor: AppColors.charcoal, surfaceTintColor: Colors.transparent,
          bottom: PreferredSize(preferredSize: const Size.fromHeight(1), child: Container(height: 1, color: AppColors.border)),
          title: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Health Datasets', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
            Text('${prov.datasets.length} datasets · ${prov.backendOnline ? "🟢 Live" : "🟡 Demo"} · Egypt Health Catalog',
              style: GoogleFonts.inter(fontSize: 10, color: prov.backendOnline ? AppColors.catHepato : AppColors.gold)),
          ]),
        ),
        body: Column(children: [
          // Search + chips
          Container(color: AppColors.charcoal, padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              TextField(controller: _ctrl,
                style: GoogleFonts.inter(color: AppColors.textPrimary, fontSize: 13),
                decoration: InputDecoration(
                  hintText: 'Search datasets, categories, sources…',
                  hintStyle: GoogleFonts.inter(color: AppColors.textMuted, fontSize: 13),
                  prefixIcon: const Icon(Icons.search_rounded, color: AppColors.gold, size: 18),
                  suffixIcon: _ctrl.text.isNotEmpty ? IconButton(icon: const Icon(Icons.close_rounded, size: 15, color: AppColors.textMuted),
                    onPressed: () { _ctrl.clear(); setState(() { _cat = null; _page = 0; }); }) : null,
                  filled: true, fillColor: AppColors.elevated,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.border)),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.border)),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.gold, width: 1.5)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10)),
                onChanged: (_) => setState(() => _page = 0)),
              const SizedBox(height: 8),
              SizedBox(height: 30, child: ListView(scrollDirection: Axis.horizontal, children: [
                _Chip('All', _cat == null, () => setState(() { _cat = null; _page = 0; })),
                ...cats.map((c) => _Chip(c, _cat == c, () => setState(() { _cat = _cat == c ? null : c; _page = 0; }))),
              ])),
            ])),
          // Status bar
          Container(color: AppColors.inkBlack, padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
            child: Row(children: [
              Text('${list.length} datasets', style: GoogleFonts.inter(fontSize: 11, color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
              const Spacer(),
              if (totalPgs > 1) Text('Page ${page + 1} / $totalPgs', style: GoogleFonts.inter(fontSize: 10, color: AppColors.textMuted)),
            ])),
          Container(height: 1, color: AppColors.border),
          // List
          Expanded(child: prov.isLoading
            ? const Center(child: CircularProgressIndicator(color: AppColors.gold, strokeWidth: 2))
            : list.isEmpty
              ? Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
                  const Icon(Icons.search_off_rounded, size: 40, color: AppColors.textMuted),
                  const SizedBox(height: 10),
                  Text('No datasets found', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
                ]))
              : RefreshIndicator(color: AppColors.gold, backgroundColor: AppColors.inkBlack,
                  onRefresh: () => context.read<DatasetProvider>().fetchDatasets(),
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(14, 8, 14, 20),
                    itemCount: items.length,
                    itemBuilder: (_, i) => _DSCard(ds: items[i]).animate(delay: (i * 40).ms).fadeIn()))),
          // Pagination
          if (totalPgs > 1) Container(
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: const BoxDecoration(color: AppColors.charcoal, border: Border(top: BorderSide(color: AppColors.border))),
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              _PBtn(Icons.chevron_left_rounded, page > 0, () => setState(() => _page = page - 1)),
              const SizedBox(width: 8),
              ...List.generate(totalPgs.clamp(0, 5), (i) => GestureDetector(
                onTap: () => setState(() => _page = i),
                child: AnimatedContainer(duration: const Duration(milliseconds: 140),
                  width: 34, height: 34, margin: const EdgeInsets.symmetric(horizontal: 3),
                  decoration: BoxDecoration(color: i == page ? AppColors.gold : Colors.transparent, borderRadius: BorderRadius.circular(6), border: Border.all(color: i == page ? AppColors.gold : AppColors.border)),
                  child: Center(child: Text('${i + 1}', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700, color: i == page ? AppColors.obsidian : AppColors.textMuted)))))),
              const SizedBox(width: 8),
              _PBtn(Icons.chevron_right_rounded, page < totalPgs - 1, () => setState(() => _page = page + 1)),
            ])),
        ]),
      );
    });
  }
}

class _Chip extends StatelessWidget {
  final String l; final bool sel; final VoidCallback t;
  const _Chip(this.l, this.sel, this.t);
  @override
  Widget build(BuildContext context) => GestureDetector(onTap: t,
    child: AnimatedContainer(duration: const Duration(milliseconds: 140),
      margin: const EdgeInsets.only(right: 7),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(color: sel ? AppColors.gold : AppColors.elevated, borderRadius: BorderRadius.circular(5), border: Border.all(color: sel ? AppColors.gold : AppColors.border)),
      child: Text(l, style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700, color: sel ? AppColors.obsidian : AppColors.textSecondary))));
}

class _DSCard extends StatelessWidget {
  final DatasetModel ds;
  const _DSCard({required this.ds});
  @override
  Widget build(BuildContext context) {
    final color = _catColor[ds.category] ?? AppColors.catInfrastructure;
    final icon  = _catIcon[ds.category]  ?? Icons.dataset_rounded;
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, '/dataset-detail', arguments: ds),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(color: AppColors.inkBlack, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.border)),
        child: ClipRRect(borderRadius: BorderRadius.circular(12), child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(height: 2, decoration: BoxDecoration(gradient: LinearGradient(colors: [color, color.withOpacity(0.2), Colors.transparent]))),
          Padding(padding: const EdgeInsets.all(13), child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Container(width: 42, height: 42, decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8), border: Border.all(color: color.withOpacity(0.25))),
                child: Icon(icon, color: color, size: 20)),
              const SizedBox(width: 10),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(ds.title, style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 13, color: AppColors.textPrimary, height: 1.3), maxLines: 2, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 4),
                Row(children: [
                  _Tag(ds.category, color),
                  const SizedBox(width: 5),
                  _Tag(ds.fileFormat, AppColors.textMuted),
                  if (ds.source != null) ...[
                    const SizedBox(width: 5),
                    Expanded(child: Text(ds.source!, style: GoogleFonts.inter(fontSize: 9, color: AppColors.textMuted), maxLines: 1, overflow: TextOverflow.ellipsis)),
                  ],
                ]),
              ])),
              const Icon(Icons.arrow_forward_ios_rounded, size: 12, color: AppColors.textMuted),
            ]),
            const SizedBox(height: 8),
            Text(ds.description, style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary, height: 1.45), maxLines: 2, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 10),
            Container(height: 1, color: AppColors.border),
            const SizedBox(height: 8),
            Row(children: [
              _Stat(Icons.download_rounded, '${ds.downloads}', AppColors.textMuted),
              const SizedBox(width: 12),
              _Stat(Icons.storage_rounded, '${ds.sizeMb.toStringAsFixed(1)} MB', AppColors.textMuted),
              const Spacer(),
              Row(children: List.generate(5, (i) => Icon(i < ds.rating.round() ? Icons.star_rounded : Icons.star_outline_rounded, size: 12, color: i < ds.rating.round() ? AppColors.gold : AppColors.border))),
              const SizedBox(width: 4),
              Text(ds.rating.toStringAsFixed(1), style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
            ]),
            if (ds.tags.isNotEmpty) ...[
              const SizedBox(height: 7),
              Wrap(spacing: 5, runSpacing: 4, children: ds.tags.take(4).map((t) =>
                Container(padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                  decoration: BoxDecoration(color: AppColors.elevated, borderRadius: BorderRadius.circular(3), border: Border.all(color: AppColors.border)),
                  child: Text('#$t', style: GoogleFonts.inter(fontSize: 9, color: AppColors.textMuted)))).toList()),
            ],
          ])),
        ]))));
  }
}

class _Tag extends StatelessWidget {
  final String l; final Color c;
  const _Tag(this.l, this.c);
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
    decoration: BoxDecoration(color: c.withOpacity(0.1), borderRadius: BorderRadius.circular(3), border: Border.all(color: c.withOpacity(0.25))),
    child: Text(l, style: GoogleFonts.inter(fontSize: 9, color: c, fontWeight: FontWeight.w700)));
}
class _Stat extends StatelessWidget {
  final IconData i; final String l; final Color c;
  const _Stat(this.i, this.l, this.c);
  @override
  Widget build(BuildContext context) => Row(mainAxisSize: MainAxisSize.min, children: [
    Icon(i, size: 11, color: c), const SizedBox(width: 3),
    Text(l, style: GoogleFonts.inter(fontSize: 10, color: c)),
  ]);
}
class _PBtn extends StatelessWidget {
  final IconData icon; final bool en; final VoidCallback t;
  const _PBtn(this.icon, this.en, this.t);
  @override
  Widget build(BuildContext context) => GestureDetector(onTap: en ? t : null,
    child: Container(width: 34, height: 34, decoration: BoxDecoration(borderRadius: BorderRadius.circular(6), color: AppColors.inkBlack, border: Border.all(color: AppColors.border)),
      child: Icon(icon, size: 18, color: en ? AppColors.textSecondary : AppColors.border)));
}
