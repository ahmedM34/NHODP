import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/dataset_provider.dart';
import '../config/app_colors.dart';

class DatasetDetailScreen extends StatelessWidget {
  const DatasetDetailScreen({Key? key}) : super(key: key);

  static const _catData = {
    'Oncology':              [AppColors.catOncology,       Icons.biotech_rounded],
    'Infectious Disease':    [AppColors.catInfectious,     Icons.coronavirus_rounded],
    'Endocrinology':         [AppColors.catEndocrine,      Icons.monitor_heart_rounded],
    'Cardiology':            [AppColors.catCardio,         Icons.favorite_rounded],
    'Hepatology':            [AppColors.catHepato,         Icons.vaccines_rounded],
    'Maternal Health':       [AppColors.catMaternal,       Icons.pregnant_woman_rounded],
    'Mental Health':         [AppColors.catMental,         Icons.psychology_rounded],
    'Pediatrics':            [AppColors.catPediatrics,     Icons.child_care_rounded],
    'Nutrition':             [AppColors.catNutrition,      Icons.local_dining_rounded],
    'Health Infrastructure': [AppColors.catInfrastructure, Icons.local_hospital_rounded],
    'Neonatology':           [AppColors.catNeonatology,    Icons.baby_changing_station_rounded],
  };

  @override
  Widget build(BuildContext context) {
    final ds = ModalRoute.of(context)?.settings.arguments as DatasetModel?;
    if (ds == null) return Scaffold(backgroundColor: AppColors.obsidian,
      appBar: AppBar(title: const Text('Not Found')),
      body: const Center(child: Text('Dataset not found')));

    final cat  = ds.category;
    final data = _catData[cat] ?? [AppColors.catInfrastructure, Icons.dataset_rounded];
    final color = data[0] as Color;
    final icon  = data[1] as IconData;

    return Scaffold(
      backgroundColor: AppColors.obsidian,
      body: CustomScrollView(slivers: [
        SliverAppBar(
          expandedHeight: 220,
          pinned: true,
          backgroundColor: AppColors.charcoal,
          foregroundColor: AppColors.textPrimary,
          flexibleSpace: FlexibleSpaceBar(
            collapseMode: CollapseMode.pin,
            background: Container(
              color: AppColors.charcoal,
              child: Stack(children: [
                // Glow
                Positioned(top: -40, right: -40, child: Container(width: 200, height: 200,
                  decoration: BoxDecoration(shape: BoxShape.circle,
                    gradient: RadialGradient(colors: [color.withOpacity(0.2), Colors.transparent])))),
                Positioned.fill(child: CustomPaint(painter: _DiagPainter(color))),
                Padding(padding: const EdgeInsets.fromLTRB(20, 90, 20, 20),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.end, children: [
                    Row(children: [
                      Container(padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                        decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(5),
                          border: Border.all(color: color.withOpacity(0.35))),
                        child: Row(mainAxisSize: MainAxisSize.min, children: [
                          Icon(icon, size: 12, color: color),
                          const SizedBox(width: 5),
                          Text(cat, style: GoogleFonts.inter(fontSize: 10, color: color, fontWeight: FontWeight.w700, letterSpacing: 0.5)),
                        ])),
                    ]),
                    const SizedBox(height: 10),
                    Text(ds.title, style: GoogleFonts.inter(
                      color: AppColors.textPrimary, fontSize: 20, fontWeight: FontWeight.w700, height: 1.2)),
                  ])),
              ]),
            ),
          ),
        ),
        SliverToBoxAdapter(child: Padding(padding: const EdgeInsets.all(20),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // Stat badges
            Row(children: [
              _StatBadge(Icons.download_rounded, '${ds.downloads}', 'Downloads', color),
              const SizedBox(width: 10),
              _StatBadge(Icons.visibility_rounded, '${ds.views}', 'Views', AppColors.catMental),
              const SizedBox(width: 10),
              _StatBadge(Icons.star_rounded, ds.rating.toStringAsFixed(1), 'Rating', AppColors.gold),
              const SizedBox(width: 10),
              _StatBadge(Icons.storage_rounded, '${ds.sizeMb}MB', 'Size', AppColors.catNutrition),
            ]).animate().fadeIn(delay: 100.ms),
            const SizedBox(height: 22),
            _Section('Description', ds.description),
            const SizedBox(height: 20),
            _InfoGrid(ds: ds),
            const SizedBox(height: 20),
            if (ds.tags.isNotEmpty) ...[
              Text('Tags', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
              const SizedBox(height: 10),
              Wrap(spacing: 8, runSpacing: 6, children: ds.tags.map((t) =>
                Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(color: color.withOpacity(0.08), borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: color.withOpacity(0.25))),
                  child: Text('#$t', style: GoogleFonts.inter(color: color, fontSize: 12, fontWeight: FontWeight.w500)))).toList()),
              const SizedBox(height: 20),
            ],
            // Download button
            SizedBox(width: double.infinity, child: GestureDetector(
              onTap: () => ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text('Download started!', style: GoogleFonts.inter()),
                backgroundColor: AppColors.success)),
              child: Container(height: 54,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [AppColors.goldDim, AppColors.gold, AppColors.goldLight]),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [BoxShadow(color: AppColors.gold.withOpacity(0.25), blurRadius: 16, offset: const Offset(0, 6))]),
                child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  const Icon(Icons.download_rounded, color: AppColors.obsidian, size: 20),
                  const SizedBox(width: 10),
                  Text('Download Dataset', style: GoogleFonts.inter(color: AppColors.obsidian, fontWeight: FontWeight.w800, fontSize: 16)),
                ])))),
            const SizedBox(height: 12),
            SizedBox(width: double.infinity, child: OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.share_rounded, size: 18),
              label: const Text('Share Dataset'),
            )),
          ]),
        )),
      ]),
    );
  }
}

class _DiagPainter extends CustomPainter {
  final Color color;
  _DiagPainter(this.color);
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()..color = color.withOpacity(0.04)..strokeWidth = 1;
    for (int i = -5; i < 10; i++) {
      canvas.drawLine(Offset(i * 60.0, 0), Offset(i * 60.0 + size.height, size.height), p);
    }
  }
  @override bool shouldRepaint(_) => false;
}

class _StatBadge extends StatelessWidget {
  final IconData icon; final String value, label; final Color color;
  const _StatBadge(this.icon, this.value, this.label, this.color);
  @override
  Widget build(BuildContext context) => Expanded(child: Container(
    padding: const EdgeInsets.symmetric(vertical: 12),
    decoration: BoxDecoration(color: AppColors.inkBlack, borderRadius: BorderRadius.circular(12),
      border: Border.all(color: color.withOpacity(0.2))),
    child: Column(children: [
      Icon(icon, size: 14, color: color),
      const SizedBox(height: 4),
      Text(value, style: GoogleFonts.inter(color: AppColors.textPrimary, fontWeight: FontWeight.w700, fontSize: 15)),
      Text(label, style: GoogleFonts.inter(color: AppColors.textMuted, fontSize: 9), textAlign: TextAlign.center),
    ])));
}

class _Section extends StatelessWidget {
  final String title, content;
  const _Section(this.title, this.content);
  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Text(title, style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
    const SizedBox(height: 8),
    Text(content, style: GoogleFonts.inter(fontSize: 14, color: AppColors.textSecondary, height: 1.65)),
  ]);
}

class _InfoGrid extends StatelessWidget {
  final DatasetModel ds;
  const _InfoGrid({required this.ds});
  @override
  Widget build(BuildContext context) {
    final rows = [
      [Icons.source_rounded,              'Source',     ds.source ?? 'NHODP'],
      [Icons.insert_drive_file_rounded,   'Format',     ds.fileFormat],
      [Icons.gavel_rounded,               'License',    ds.license],
      [Icons.calendar_today_rounded,      'Published',  '${ds.createdAt.day}/${ds.createdAt.month}/${ds.createdAt.year}'],
      [Icons.category_rounded,            'Category',   ds.category],
      [Icons.star_rounded,                'Rating',     '${ds.rating}/5.0'],
    ];
    return Container(
      decoration: BoxDecoration(color: AppColors.inkBlack, borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border)),
      child: Column(children: rows.asMap().entries.map((e) {
        final i = e.key; final r = e.value;
        return Container(
          decoration: BoxDecoration(border: i < rows.length - 1 ? Border(bottom: BorderSide(color: AppColors.border)) : null),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
          child: Row(children: [
            Icon(r[0] as IconData, size: 15, color: AppColors.gold.withOpacity(0.7)),
            const SizedBox(width: 12),
            Text(r[1] as String, style: GoogleFonts.inter(color: AppColors.textSecondary, fontWeight: FontWeight.w600, fontSize: 13)),
            const Spacer(),
            Text(r[2] as String, style: GoogleFonts.inter(color: AppColors.textPrimary, fontSize: 13), textAlign: TextAlign.right),
          ]),
        );
      }).toList()),
    );
  }
}
