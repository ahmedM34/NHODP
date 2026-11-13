import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/api_service.dart';
import '../config/app_colors.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);
  @override
  State<SearchScreen> createState() => _SearchScreenState();
}
class _SearchScreenState extends State<SearchScreen> {
  final _ctrl = TextEditingController();
  List<dynamic> _results = [];
  bool _loading = false, _searched = false;

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  Future<void> _search(String q) async {
    if (q.trim().length < 2) return;
    setState(() { _loading = true; _searched = true; });
    try {
      final r = await ApiService.searchDatasets(q.trim());
      setState(() { _results = (r['results'] as List?) ?? []; _loading = false; });
    } catch (_) { setState(() { _results = []; _loading = false; }); }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: AppColors.charcoal, surfaceTintColor: Colors.transparent,
        title: Text('Search', style: GoogleFonts.inter(color: AppColors.textPrimary, fontWeight: FontWeight.w700)),
        bottom: PreferredSize(preferredSize: const Size.fromHeight(72), child: Container(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          color: AppColors.obsidian,
          child: TextField(controller: _ctrl, autofocus: true,
            style: GoogleFonts.inter(color: AppColors.textPrimary, fontSize: 14),
            decoration: InputDecoration(
              hintText: 'Search health datasets...',
              hintStyle: GoogleFonts.inter(color: AppColors.textMuted, fontSize: 14),
              prefixIcon: const Icon(Icons.search_rounded, color: AppColors.gold, size: 20),
              suffixIcon: _ctrl.text.isNotEmpty ? IconButton(
                icon: const Icon(Icons.clear_rounded, size: 17, color: AppColors.textMuted),
                onPressed: () { _ctrl.clear(); setState(() { _results = []; _searched = false; }); }) : null,
              filled: true, fillColor: AppColors.elevated,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.gold, width: 1.5)),
            ),
            onChanged: (v) => setState(() {}),
            onSubmitted: _search),
        ))),
      body: Column(children: [
        Container(height: 1, color: AppColors.border),
        if (!_searched) Expanded(child: _SuggestionsView(onTap: (s) { _ctrl.text = s; _search(s); })),
        if (_loading) const Expanded(child: Center(child: CircularProgressIndicator(color: AppColors.gold, strokeWidth: 2))),
        if (_searched && !_loading && _results.isEmpty) Expanded(child: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          const Icon(Icons.search_off_rounded, size: 48, color: AppColors.textMuted),
          const SizedBox(height: 12),
          Text('No results', style: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 18, fontWeight: FontWeight.w600)),
        ]))),
        if (_searched && !_loading && _results.isNotEmpty) Expanded(child: Column(children: [
          Padding(padding: const EdgeInsets.fromLTRB(16, 10, 16, 4),
            child: Row(children: [Text('${_results.length} results', style: GoogleFonts.inter(color: AppColors.textMuted, fontSize: 12))])),
          Expanded(child: ListView.builder(padding: const EdgeInsets.symmetric(horizontal: 16), itemCount: _results.length,
            itemBuilder: (_, i) {
              final r = _results[i] as Map<String, dynamic>;
              return Container(margin: const EdgeInsets.only(bottom: 10), padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(color: AppColors.inkBlack, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.border)),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: AppColors.gold.withOpacity(0.1), borderRadius: BorderRadius.circular(8), border: Border.all(color: AppColors.gold.withOpacity(0.25))),
                      child: const Icon(Icons.dataset_rounded, color: AppColors.gold, size: 18)),
                    const SizedBox(width: 10),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(r['title'] as String? ?? '', style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 14, color: AppColors.textPrimary), maxLines: 1, overflow: TextOverflow.ellipsis),
                      Text(r['category'] as String? ?? '', style: GoogleFonts.inter(fontSize: 10, color: AppColors.gold, fontWeight: FontWeight.w600)),
                    ])),
                  ]),
                  if (r['description'] != null) ...[
                    const SizedBox(height: 6),
                    Text(r['description'] as String, style: GoogleFonts.inter(fontSize: 11, color: AppColors.textMuted), maxLines: 2, overflow: TextOverflow.ellipsis),
                  ],
                ]));
            })),
        ])),
      ]),
    );
  }
}

class _SuggestionsView extends StatelessWidget {
  final ValueChanged<String> onTap;
  const _SuggestionsView({required this.onTap});
  static const _suggestions = ['Diabetes','COVID-19','Hepatitis C','Cancer Registry','Vaccination','Maternal Health','Cardiology','Mental Health','Hospital Beds','Obesity'];
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(padding: const EdgeInsets.all(20), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('Popular Searches', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
      const SizedBox(height: 14),
      Wrap(spacing: 10, runSpacing: 10, children: _suggestions.map((s) => GestureDetector(
        onTap: () => onTap(s),
        child: Container(padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(color: AppColors.elevated, borderRadius: BorderRadius.circular(20), border: Border.all(color: AppColors.border)),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.search_rounded, size: 13, color: AppColors.textMuted),
            const SizedBox(width: 6),
            Text(s, style: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 13)),
          ])))).toList()),
    ]));
  }
}
