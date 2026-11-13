import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../config/app_colors.dart';

// ── HOSPITAL DATA ─────────────────────────────────────────────
const List<Map<String, dynamic>> _hospitals = [
  {'name':'Kasr El Aini Hospital','gov':'Cairo','type':'University','beds':3200,'icu':180,'emergency':true,'specialties':['Oncology','Cardiology','Surgery','Internal Med','Neurology'],'address':'Kasr El Aini St, Cairo','phone':'02-23640444','status':'operational'},
  {'name':'Cairo University Children Hospital','gov':'Cairo','type':'Specialized','beds':800,'icu':60,'emergency':true,'specialties':['Pediatrics','Neonatology','Pediatric Surgery'],'address':'Abbasiya, Cairo','phone':'02-26841111','status':'operational'},
  {'name':'National Cancer Institute','gov':'Cairo','type':'Specialized','beds':700,'icu':40,'emergency':false,'specialties':['Oncology','Radiotherapy','Chemotherapy','Palliative Care'],'address':'Kasr El Aini, Cairo','phone':'02-23644720','status':'operational'},
  {'name':'El Demerdash Hospital','gov':'Cairo','type':'University','beds':1200,'icu':90,'emergency':true,'specialties':['Cardiology','Surgery','Nephrology','Rheumatology'],'address':'Abbasiya, Cairo','phone':'02-26841811','status':'operational'},
  {'name':'Alexandria Main University Hospital','gov':'Alexandria','type':'University','beds':2100,'icu':140,'emergency':true,'specialties':['All Specialties'],'address':'El Hadara, Alexandria','phone':'03-4873456','status':'operational'},
  {'name':'El Shatby Maternity Hospital','gov':'Alexandria','type':'Specialized','beds':600,'icu':45,'emergency':true,'specialties':['Obstetrics','Gynecology','Maternal-Fetal Medicine'],'address':'El Shatby, Alexandria','phone':'03-5921511','status':'operational'},
  {'name':'Mansoura University Hospital','gov':'Dakahlia','type':'University','beds':2800,'icu':160,'emergency':true,'specialties':['Urology','Nephrology','Transplant','Cardiology','Surgery'],'address':'Mansoura, Dakahlia','phone':'050-2202543','status':'operational'},
  {'name':'Mansoura Children Hospital','gov':'Dakahlia','type':'Specialized','beds':500,'icu':50,'emergency':true,'specialties':['Pediatrics','Pediatric Surgery','NICU'],'address':'Mansoura, Dakahlia','phone':'050-2224544','status':'operational'},
  {'name':'Assiut University Hospital','gov':'Asyut','type':'University','beds':1800,'icu':110,'emergency':true,'specialties':['Surgery','Internal Med','Oncology','Gynecology'],'address':'Assiut University St','phone':'088-2333188','status':'operational'},
  {'name':'South Valley University Hospital','gov':'Qena','type':'University','beds':900,'icu':55,'emergency':true,'specialties':['Surgery','Internal Med','Orthopedics'],'address':'Qena, South Valley','phone':'096-5211281','status':'operational'},
  {'name':'Suez Canal University Hospital','gov':'Ismailia','type':'University','beds':1100,'icu':70,'emergency':true,'specialties':['Surgery','Cardiology','Nephrology','Neurology'],'address':'Ismailia','phone':'064-3230543','status':'operational'},
  {'name':'Tanta University Hospital','gov':'Gharbia','type':'University','beds':1600,'icu':95,'emergency':true,'specialties':['All Specialties'],'address':'El Gaish St, Tanta','phone':'040-3356789','status':'operational'},
  {'name':'Benha University Hospital','gov':'Qalyubia','type':'University','beds':1000,'icu':65,'emergency':true,'specialties':['Surgery','Cardiology','Internal Med'],'address':'Benha, Qalyubia','phone':'013-3225421','status':'operational'},
  {'name':'Zagazig University Hospital','gov':'Sharqia','type':'University','beds':1400,'icu':85,'emergency':true,'specialties':['Surgery','Oncology','Nephrology','Ophthalmology'],'address':'Zagazig, Sharqia','phone':'055-2305422','status':'operational'},
  {'name':'Ain Shams University Hospital','gov':'Cairo','type':'University','beds':2400,'icu':150,'emergency':true,'specialties':['Cardiology','Neurology','Oncology','Transplant'],'address':'Abbasiya, Cairo','phone':'02-26841610','status':'operational'},
  {'name':'El Nozha International Hospital','gov':'Cairo','type':'General','beds':400,'icu':35,'emergency':true,'specialties':['Cardiology','Surgery','Internal Med'],'address':'El Nozha, Cairo','phone':'02-26216614','status':'operational'},
  {'name':'Luxor International Hospital','gov':'Luxor','type':'General','beds':350,'icu':28,'emergency':true,'specialties':['Surgery','Internal Med','Orthopedics'],'address':'Luxor City','phone':'095-2374188','status':'operational'},
  {'name':'Aswan University Hospital','gov':'Aswan','type':'University','beds':700,'icu':48,'emergency':true,'specialties':['Surgery','Internal Med','Urology'],'address':'Aswan University Campus','phone':'097-2322313','status':'operational'},
  {'name':'Port Said General Hospital','gov':'Port Said','type':'General','beds':800,'icu':52,'emergency':true,'specialties':['Surgery','Cardiology','Internal Med','Orthopedics'],'address':'Port Said','phone':'066-3241234','status':'operational'},
  {'name':'Beni Suef University Hospital','gov':'Beni Suef','type':'University','beds':900,'icu':58,'emergency':true,'specialties':['Surgery','Gynecology','Internal Med'],'address':'Beni Suef University','phone':'082-2326543','status':'operational'},
];

final List<String> _allGovs = ['All', ..._hospitals.map((h) => h['gov'] as String).toSet().toList()..sort()];
final List<String> _allTypes = ['All Types', 'University', 'Specialized', 'General'];
final List<String> _allSpecs = ['All Specialties', 'Cardiology', 'Oncology', 'Surgery', 'Pediatrics', 'Nephrology', 'Neurology', 'Obstetrics'];

class HospitalsScreen extends StatefulWidget {
  const HospitalsScreen({Key? key}) : super(key: key);
  @override
  State<HospitalsScreen> createState() => _HospitalsScreenState();
}

class _HospitalsScreenState extends State<HospitalsScreen> {
  final _searchCtrl = TextEditingController();
  String _gov = 'All';
  String _type = 'All Types';
  bool _icuOnly = false;
  bool _emergOnly = false;

  @override
  void dispose() { _searchCtrl.dispose(); super.dispose(); }

  List<Map<String, dynamic>> get _filtered {
    var list = _hospitals.toList();
    if (_gov != 'All') list = list.where((h) => h['gov'] == _gov).toList();
    if (_type != 'All Types') list = list.where((h) => h['type'] == _type).toList();
    if (_icuOnly) list = list.where((h) => (h['icu'] as int) > 0).toList();
    if (_emergOnly) list = list.where((h) => h['emergency'] == true).toList();
    final q = _searchCtrl.text.trim().toLowerCase();
    if (q.isNotEmpty) list = list.where((h) =>
      (h['name'] as String).toLowerCase().contains(q) ||
      (h['gov'] as String).toLowerCase().contains(q) ||
      (h['specialties'] as List).join(' ').toLowerCase().contains(q)
    ).toList();
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;
    final totalBeds = filtered.fold(0, (s, h) => s + (h['beds'] as int));
    final totalIcu  = filtered.fold(0, (s, h) => s + (h['icu'] as int));

    return Scaffold(
      backgroundColor: AppColors.obsidian,
      appBar: AppBar(
        backgroundColor: AppColors.charcoal,
        surfaceTintColor: Colors.transparent,
        bottom: PreferredSize(preferredSize: const Size.fromHeight(1), child: Container(height: 1, color: AppColors.border)),
        title: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Hospital Directory', style: GoogleFonts.inter(fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
          Text('${_hospitals.length} government hospitals · Egypt', style: GoogleFonts.inter(fontSize: 10, color: AppColors.textMuted)),
        ]),
      ),
      body: Column(children: [
        // Summary strip
        Container(color: AppColors.inkBlack, padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(children: [
            _KpiMini('${filtered.length}', 'Hospitals', AppColors.gold),
            _KpiMini('${(totalBeds / 1000).toStringAsFixed(0)}K', 'Total Beds', AppColors.catInfectious),
            _KpiMini('$totalIcu', 'ICU Beds', AppColors.catCardio),
            _KpiMini('${filtered.where((h) => h['emergency'] == true).length}', 'Emergency', AppColors.catHepato),
          ])),
        Container(height: 1, color: AppColors.border),
        // Filters
        Container(color: AppColors.charcoal, padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            TextField(controller: _searchCtrl,
              style: GoogleFonts.inter(color: AppColors.textPrimary, fontSize: 13),
              decoration: InputDecoration(
                hintText: 'Search by name, governorate, specialty…',
                hintStyle: GoogleFonts.inter(color: AppColors.textMuted, fontSize: 13),
                prefixIcon: const Icon(Icons.search_rounded, color: AppColors.gold, size: 18),
                suffixIcon: _searchCtrl.text.isNotEmpty ? IconButton(icon: const Icon(Icons.close_rounded, size: 15, color: AppColors.textMuted), onPressed: () { _searchCtrl.clear(); setState(() {}); }) : null,
                filled: true, fillColor: AppColors.elevated,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.border)),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.border)),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.gold, width: 1.5)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10)),
              onChanged: (_) => setState(() {})),
            const SizedBox(height: 8),
            Row(children: [
              Expanded(child: _DropFilter(_gov, _allGovs, (v) => setState(() { _gov = v!; }))),
              const SizedBox(width: 8),
              Expanded(child: _DropFilter(_type, _allTypes, (v) => setState(() { _type = v!; }))),
              const SizedBox(width: 8),
              _ToggleFilter('ICU', _icuOnly, AppColors.catCardio, () => setState(() => _icuOnly = !_icuOnly)),
              const SizedBox(width: 6),
              _ToggleFilter('ER', _emergOnly, AppColors.catHepato, () => setState(() => _emergOnly = !_emergOnly)),
            ]),
          ])),
        Container(height: 1, color: AppColors.border),
        // List
        Expanded(child: filtered.isEmpty
          ? Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
              const Icon(Icons.local_hospital_rounded, size: 48, color: AppColors.textMuted),
              const SizedBox(height: 12),
              Text('No hospitals match your filters', style: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 16, fontWeight: FontWeight.w600)),
            ]))
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 20),
              itemCount: filtered.length,
              itemBuilder: (_, i) => _HospitalCard(h: filtered[i]).animate(delay: (i * 35).ms).fadeIn().slideY(begin: 0.04))),
      ]),
    );
  }
}

class _KpiMini extends StatelessWidget {
  final String v, l; final Color c;
  const _KpiMini(this.v, this.l, this.c);
  @override
  Widget build(BuildContext context) => Expanded(child: Column(mainAxisSize: MainAxisSize.min, children: [
    Text(v, style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w800, color: c)),
    Text(l, style: GoogleFonts.inter(fontSize: 9, color: AppColors.textMuted, letterSpacing: 0.5)),
  ]));
}

class _DropFilter extends StatelessWidget {
  final String value; final List<String> items; final ValueChanged<String?> onChanged;
  const _DropFilter(this.value, this.items, this.onChanged);
  @override
  Widget build(BuildContext context) => DropdownButtonFormField<String>(
    value: value, dropdownColor: AppColors.darkSurface,
    style: GoogleFonts.inter(color: AppColors.textPrimary, fontSize: 12),
    decoration: InputDecoration(filled: true, fillColor: AppColors.elevated, contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: const BorderSide(color: AppColors.border)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: const BorderSide(color: AppColors.border))),
    items: items.map((i) => DropdownMenuItem(value: i, child: Text(i, style: GoogleFonts.inter(fontSize: 12, color: AppColors.textPrimary), overflow: TextOverflow.ellipsis))).toList(),
    onChanged: onChanged);
}

class _ToggleFilter extends StatelessWidget {
  final String l; final bool active; final Color c; final VoidCallback t;
  const _ToggleFilter(this.l, this.active, this.c, this.t);
  @override
  Widget build(BuildContext context) => GestureDetector(onTap: t,
    child: AnimatedContainer(duration: const Duration(milliseconds: 150),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(color: active ? c.withOpacity(0.2) : AppColors.elevated, borderRadius: BorderRadius.circular(6), border: Border.all(color: active ? c : AppColors.border)),
      child: Text(l, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: active ? c : AppColors.textSecondary))));
}

class _HospitalCard extends StatelessWidget {
  final Map<String, dynamic> h;
  const _HospitalCard({required this.h});
  @override
  Widget build(BuildContext context) {
    final type = h['type'] as String;
    final typeColor = type == 'University' ? AppColors.gold : type == 'Specialized' ? AppColors.catInfectious : AppColors.catHepato;
    final specs = (h['specialties'] as List).cast<String>();
    final hasIcu = (h['icu'] as int) > 0;
    final hasEmerg = h['emergency'] == true;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(color: AppColors.inkBlack, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.border),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 3))]),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        // Top bar
        Container(height: 2, decoration: BoxDecoration(
          gradient: LinearGradient(colors: [typeColor, typeColor.withOpacity(0.2), Colors.transparent]),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(12)))),
        Padding(padding: const EdgeInsets.all(14), child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
          // Header
          Row(children: [
            Container(padding: const EdgeInsets.all(9),
              decoration: BoxDecoration(color: typeColor.withOpacity(0.1), borderRadius: BorderRadius.circular(8), border: Border.all(color: typeColor.withOpacity(0.25))),
              child: Icon(Icons.local_hospital_rounded, size: 20, color: typeColor)),
            const SizedBox(width: 10),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(h['name'] as String, style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 14, color: AppColors.textPrimary), maxLines: 1, overflow: TextOverflow.ellipsis),
              Row(children: [
                Icon(Icons.location_on_rounded, size: 11, color: AppColors.textMuted),
                const SizedBox(width: 3),
                Text(h['gov'] as String, style: GoogleFonts.inter(fontSize: 11, color: AppColors.textMuted)),
                const SizedBox(width: 8),
                Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                  decoration: BoxDecoration(color: typeColor.withOpacity(0.1), borderRadius: BorderRadius.circular(3)),
                  child: Text(type, style: GoogleFonts.inter(fontSize: 9, color: typeColor, fontWeight: FontWeight.w700))),
              ]),
            ])),
            Column(crossAxisAlignment: CrossAxisAlignment.end, mainAxisSize: MainAxisSize.min, children: [
              if (hasEmerg) Container(padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(color: AppColors.catCardio.withOpacity(0.15), borderRadius: BorderRadius.circular(4), border: Border.all(color: AppColors.catCardio.withOpacity(0.4))),
                child: Text('EMERGENCY', style: GoogleFonts.inter(fontSize: 8, color: AppColors.catCardio, fontWeight: FontWeight.w800, letterSpacing: 0.5))),
              const SizedBox(height: 4),
              if (hasIcu) Container(padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(color: AppColors.gold.withOpacity(0.1), borderRadius: BorderRadius.circular(4), border: Border.all(color: AppColors.gold.withOpacity(0.35))),
                child: Text('ICU', style: GoogleFonts.inter(fontSize: 8, color: AppColors.gold, fontWeight: FontWeight.w800, letterSpacing: 0.5))),
            ]),
          ]),
          const SizedBox(height: 12),
          // Stats row
          Row(children: [
            _Stat2(Icons.bed_rounded, '${h['beds']}', 'Beds', AppColors.catInfectious),
            Container(width: 1, height: 32, color: AppColors.border, margin: const EdgeInsets.symmetric(horizontal: 12)),
            _Stat2(Icons.medical_services_rounded, '${h['icu']}', 'ICU Beds', AppColors.catCardio),
            Container(width: 1, height: 32, color: AppColors.border, margin: const EdgeInsets.symmetric(horizontal: 12)),
            _Stat2(Icons.emergency_rounded, hasEmerg ? 'Open' : 'No', 'Emergency', hasEmerg ? AppColors.catHepato : AppColors.textMuted),
          ]),
          const SizedBox(height: 10),
          Container(height: 1, color: AppColors.border),
          const SizedBox(height: 10),
          // Specialties
          Wrap(spacing: 5, runSpacing: 5, children: specs.take(5).map((s) =>
            Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(color: AppColors.elevated, borderRadius: BorderRadius.circular(4), border: Border.all(color: AppColors.border)),
              child: Text(s, style: GoogleFonts.inter(fontSize: 10, color: AppColors.textSecondary)))).toList()),
          const SizedBox(height: 10),
          // Contact
          Row(children: [
            Icon(Icons.phone_rounded, size: 12, color: AppColors.gold),
            const SizedBox(width: 5),
            Text(h['phone'] as String, style: GoogleFonts.inter(fontSize: 12, color: AppColors.gold, fontWeight: FontWeight.w500)),
            const Spacer(),
            Icon(Icons.location_on_outlined, size: 12, color: AppColors.textMuted),
            const SizedBox(width: 4),
            Expanded(child: Text(h['address'] as String, style: GoogleFonts.inter(fontSize: 11, color: AppColors.textMuted), maxLines: 1, overflow: TextOverflow.ellipsis, textAlign: TextAlign.end)),
          ]),
        ])),
      ]));
  }
}

class _Stat2 extends StatelessWidget {
  final IconData icon; final String v, l; final Color c;
  const _Stat2(this.icon, this.v, this.l, this.c);
  @override
  Widget build(BuildContext context) => Column(mainAxisSize: MainAxisSize.min, children: [
    Icon(icon, size: 14, color: c),
    const SizedBox(height: 3),
    Text(v, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
    Text(l, style: GoogleFonts.inter(fontSize: 9, color: AppColors.textMuted)),
  ]);
}
