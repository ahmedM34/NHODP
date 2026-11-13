// ============================================================
// DATA REQUEST SCREEN
// Like NHS Digital / data.gov / WHO data request portal
// Features: formal dataset request form, custom data queries,
//           API key request, bulk download request
// ============================================================
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../config/app_colors.dart';

class DataRequestScreen extends StatefulWidget {
  const DataRequestScreen({Key? key}) : super(key: key);
  @override
  State<DataRequestScreen> createState() => _DataRequestScreenState();
}

class _DataRequestScreenState extends State<DataRequestScreen> with SingleTickerProviderStateMixin {
  late TabController _tabs;
  @override
  void initState() { super.initState(); _tabs = TabController(length: 3, vsync: this); }
  @override
  void dispose() { _tabs.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.obsidian,
      appBar: AppBar(backgroundColor: AppColors.charcoal, surfaceTintColor: Colors.transparent,
        title: Text('Data Access & Requests', style: GoogleFonts.inter(color: AppColors.textPrimary, fontWeight: FontWeight.w700)),
        bottom: PreferredSize(preferredSize: const Size.fromHeight(49),
          child: Column(children: [
            Container(height: 1, color: AppColors.border),
            TabBar(controller: _tabs, indicatorColor: AppColors.gold, indicatorWeight: 2,
              labelColor: AppColors.gold, unselectedLabelColor: AppColors.textMuted,
              labelStyle: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 11), dividerColor: Colors.transparent,
              tabs: const [Tab(text: 'Request Dataset'), Tab(text: 'API Access'), Tab(text: 'My Requests')]),
          ])),
      ),
      body: TabBarView(controller: _tabs, children: [
        _RequestDatasetTab(),
        _APIAccessTab(),
        _MyRequestsTab(),
      ]),
    );
  }
}

class _RequestDatasetTab extends StatefulWidget {
  @override
  State<_RequestDatasetTab> createState() => _RequestDatasetTabState();
}

class _RequestDatasetTabState extends State<_RequestDatasetTab> {
  final _nameCtrl    = TextEditingController();
  final _emailCtrl   = TextEditingController();
  final _institutionCtrl = TextEditingController();
  final _purposeCtrl = TextEditingController();
  final _descCtrl    = TextEditingController();
  String _dataType   = 'Aggregated';
  String _purpose    = 'Academic Research';
  bool _ethics       = false;
  bool _terms        = false;
  bool _submitted    = false;
  final _formKey     = GlobalKey<FormState>();

  @override
  void dispose() { _nameCtrl.dispose(); _emailCtrl.dispose(); _institutionCtrl.dispose(); _purposeCtrl.dispose(); _descCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    if (_submitted) return _SuccessView(title: 'Request Submitted', subtitle: 'REF: NHODP-REQ-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}', onReset: () => setState(() => _submitted = false));
    return SingleChildScrollView(padding: const EdgeInsets.all(16), child: Form(key: _formKey, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _SectionHeader('Request a Custom Dataset', Icons.dataset_linked_rounded, 'For data not available in the catalog'),
      const SizedBox(height: 20),
      // Requestor info
      _FieldLabel('Your Information'),
      _LuxField(_nameCtrl, 'Full Name *', Icons.person_rounded),
      const SizedBox(height: 10),
      _LuxField(_emailCtrl, 'Institutional Email *', Icons.email_rounded, type: TextInputType.emailAddress,
        validator: (v) => (v==null||!v.contains('@')) ? 'Valid email required' : null),
      const SizedBox(height: 10),
      _LuxField(_institutionCtrl, 'Institution / Organization *', Icons.business_rounded),
      const SizedBox(height: 16),
      _FieldLabel('Request Details'),
      _LuxDropdown('Research Purpose', _purpose, ['Academic Research','Policy Analysis','Public Health Program','Clinical Study','Journalism','Other'], (v) => setState(() => _purpose = v!)),
      const SizedBox(height: 10),
      _LuxDropdown('Data Format Needed', _dataType, ['Aggregated','Anonymized Record-Level','Summary Statistics','Geospatial','Longitudinal'], (v) => setState(() => _dataType = v!)),
      const SizedBox(height: 10),
      TextFormField(controller: _descCtrl, maxLines: 3,
        style: GoogleFonts.inter(color: AppColors.textPrimary, fontSize: 13),
        decoration: InputDecoration(labelText: 'Describe the specific data you need *', alignLabelWithHint: true,
          prefixIcon: const Padding(padding: EdgeInsets.only(bottom: 42), child: Icon(Icons.description_rounded, size: 18))),
        validator: (v) => (v==null||v.trim().isEmpty) ? 'Required' : null),
      const SizedBox(height: 16),
      _FieldLabel('Compliance'),
      _CheckItem('I confirm this request is for legitimate research / public health purposes', _ethics, (v) => setState(() => _ethics = v!)),
      const SizedBox(height: 8),
      _CheckItem('I agree to the NHODP Data Use Terms and Egyptian Health Data Protection Law', _terms, (v) => setState(() => _terms = v!)),
      const SizedBox(height: 20),
      SizedBox(width: double.infinity, child: GestureDetector(
        onTap: () {
          if (!_formKey.currentState!.validate()) return;
          if (!_ethics || !_terms) { ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Please accept all compliance items', style: GoogleFonts.inter()), backgroundColor: AppColors.error)); return; }
          setState(() => _submitted = true);
        },
        child: Container(height: 52, decoration: BoxDecoration(gradient: const LinearGradient(colors: [AppColors.goldDim, AppColors.gold, AppColors.goldLight]), borderRadius: BorderRadius.circular(12),
          boxShadow: [BoxShadow(color: AppColors.gold.withOpacity(0.25), blurRadius: 14, offset: const Offset(0,5))]),
          child: Center(child: Text('Submit Data Request', style: GoogleFonts.inter(color: AppColors.obsidian, fontWeight: FontWeight.w800, fontSize: 15)))))),
      const SizedBox(height: 8),
      Center(child: Text('Expected response: 5–10 business days', style: GoogleFonts.inter(color: AppColors.textMuted, fontSize: 11))),
    ])));
  }
}

class _APIAccessTab extends StatefulWidget {
  @override
  State<_APIAccessTab> createState() => _APIAccessTabState();
}

class _APIAccessTabState extends State<_APIAccessTab> {
  bool _keyGenerated = false;
  final _demoKey = 'nhodp_sk_demo_${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}';

  @override
  Widget build(BuildContext context) {
    return ListView(padding: const EdgeInsets.all(16), children: [
      _SectionHeader('NHODP REST API', Icons.api_rounded, 'Programmatic access to all health datasets'),
      const SizedBox(height: 20),
      // API overview cards
      Row(children: [
        _ApiStatCard('5', 'Endpoints', Icons.hub_rounded, AppColors.catInfectious),
        const SizedBox(width: 10),
        _ApiStatCard('100', 'Req/hour', Icons.speed_rounded, AppColors.gold),
        const SizedBox(width: 10),
        _ApiStatCard('JSON', 'Format', Icons.code_rounded, AppColors.catHepato),
      ]).animate().fadeIn(),
      const SizedBox(height: 20),
      // Endpoint reference
      _FieldLabel('Endpoint Reference'),
      ...[
        ['GET',  '/datasets',              'List all health datasets'],
        ['GET',  '/datasets/{id}',         'Get dataset metadata'],
        ['GET',  '/datasets/{id}/records', 'Fetch dataset records'],
        ['GET',  '/search?q={query}',      'Full-text search'],
        ['POST', '/datasets/from-ocr',     'Publish OCR result as dataset'],
        ['GET',  '/stats/health-indicators','National health indicators'],
      ].map((ep) => Container(margin: const EdgeInsets.only(bottom: 6), padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: AppColors.inkBlack, borderRadius: BorderRadius.circular(10), border: Border.all(color: AppColors.border)),
        child: Row(children: [
          Container(padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
            decoration: BoxDecoration(color: (ep[0]=='GET' ? AppColors.catHepato : AppColors.catOncology).withOpacity(0.15), borderRadius: BorderRadius.circular(4)),
            child: Text(ep[0], style: GoogleFonts.inter(color: ep[0]=='GET' ? AppColors.catHepato : AppColors.catOncology, fontSize: 10, fontWeight: FontWeight.w800))),
          const SizedBox(width: 8),
          Expanded(child: Text(ep[1], style: GoogleFonts.inter(color: AppColors.textPrimary, fontSize: 12))),
          Flexible(child: Text(ep[2], style: GoogleFonts.inter(color: AppColors.textMuted, fontSize: 10), textAlign: TextAlign.right)),
        ]))),
      const SizedBox(height: 20),
      _FieldLabel('Example Request'),
      Container(padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: AppColors.charcoal, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.border)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('curl -H "Authorization: Bearer YOUR_KEY" \\', style: GoogleFonts.inter(color: AppColors.gold, fontSize: 12)),
          Text('  http://localhost:8002/datasets?category=Oncology', style: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 12)),
        ])),
      const SizedBox(height: 20),
      _FieldLabel('Your API Key'),
      if (!_keyGenerated) SizedBox(width: double.infinity, child: OutlinedButton.icon(
        onPressed: () => setState(() => _keyGenerated = true),
        icon: const Icon(Icons.key_rounded, size: 18), label: Text('Generate API Key', style: GoogleFonts.inter(fontWeight: FontWeight.w700)))),
      if (_keyGenerated) Container(padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: AppColors.goldSurface, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.gold.withOpacity(0.3))),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            const Icon(Icons.key_rounded, color: AppColors.gold, size: 16),
            const SizedBox(width: 8),
            Text('API Key (Demo)', style: GoogleFonts.inter(color: AppColors.gold, fontWeight: FontWeight.w700, fontSize: 13)),
          ]),
          const SizedBox(height: 8),
          Text(_demoKey, style: GoogleFonts.inter(color: AppColors.textPrimary, fontSize: 12)),
          const SizedBox(height: 4),
          Text('Rate limit: 100 requests/hour. For production access, submit a formal request.', style: GoogleFonts.inter(color: AppColors.textMuted, fontSize: 10)),
        ])),
    ]);
  }
}

class _MyRequestsTab extends StatelessWidget {
  final _mockRequests = const [
    {'id':'NHODP-REQ-4721','type':'Dataset','status':'Approved','date':'2026-03-12','dataset':'Cancer Registry 2020-24'},
    {'id':'NHODP-REQ-4698','type':'API Key','status':'Pending','date':'2026-03-28','dataset':'API Access - Research'},
    {'id':'NHODP-REQ-4651','type':'Dataset','status':'Under Review','date':'2026-02-14','dataset':'Mental Health Survey'},
  ];
  const _MyRequestsTab();
  @override
  Widget build(BuildContext context) {
    return ListView(padding: const EdgeInsets.all(16), children: [
      _SectionHeader('My Data Requests', Icons.inbox_rounded, 'Track the status of your submitted requests'),
      const SizedBox(height: 16),
      ..._mockRequests.map((req) {
        final status = req['status'] as String;
        final color = status == 'Approved' ? AppColors.successLight : status == 'Pending' ? AppColors.gold : AppColors.info;
        return Container(margin: const EdgeInsets.only(bottom: 10), padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(color: AppColors.inkBlack, borderRadius: BorderRadius.circular(13), border: Border.all(color: color.withOpacity(0.2))),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Text(req['id'] as String, style: GoogleFonts.inter(color: AppColors.textMuted, fontSize: 10)),
              const Spacer(),
              Container(padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(20), border: Border.all(color: color.withOpacity(0.4))),
                child: Text(status, style: GoogleFonts.inter(color: color, fontSize: 10, fontWeight: FontWeight.w700))),
            ]),
            const SizedBox(height: 7),
            Text(req['dataset'] as String, style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 15, color: AppColors.textPrimary)),
            const SizedBox(height: 4),
            Row(children: [
              Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(color: AppColors.elevated, borderRadius: BorderRadius.circular(4)),
                child: Text(req['type'] as String, style: GoogleFonts.inter(fontSize: 10, color: AppColors.textMuted, fontWeight: FontWeight.w600))),
              const SizedBox(width: 8),
              Text(req['date'] as String, style: GoogleFonts.inter(fontSize: 11, color: AppColors.textMuted)),
            ]),
          ]));
      }),
    ]);
  }
}

// ── Helpers ───────────────────────────────────────────────────
class _SectionHeader extends StatelessWidget {
  final String title, subtitle; final IconData icon;
  const _SectionHeader(this.title, this.icon, this.subtitle);
  @override
  Widget build(BuildContext context) => Row(children: [
    Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: AppColors.gold.withOpacity(0.1), borderRadius: BorderRadius.circular(10), border: Border.all(color: AppColors.gold.withOpacity(0.25))),
      child: ShaderMask(shaderCallback: (b) => const LinearGradient(colors: [AppColors.gold, AppColors.goldBright]).createShader(b),
        child: Icon(icon, color: Colors.white, size: 22))),
    const SizedBox(width: 12),
    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(title, style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
      Text(subtitle, style: GoogleFonts.inter(fontSize: 11, color: AppColors.textMuted)),
    ])),
  ]);
}

class _FieldLabel extends StatelessWidget {
  final String label;
  const _FieldLabel(this.label);
  @override
  Widget build(BuildContext context) => Padding(padding: const EdgeInsets.only(bottom: 8),
    child: Text(label, style: GoogleFonts.inter(color: AppColors.textSecondary, fontWeight: FontWeight.w700, fontSize: 13)));
}

class _LuxField extends StatelessWidget {
  final TextEditingController ctrl; final String label; final IconData icon;
  final TextInputType? type; final String? Function(String?)? validator;
  const _LuxField(this.ctrl, this.label, this.icon, {this.type, this.validator});
  @override
  Widget build(BuildContext context) => TextFormField(
    controller: ctrl, keyboardType: type,
    style: GoogleFonts.inter(color: AppColors.textPrimary, fontSize: 13),
    decoration: InputDecoration(labelText: label, prefixIcon: Icon(icon, size: 18)),
    validator: validator ?? (v) => (v==null||v.trim().isEmpty) ? '$label is required' : null);
}

Widget _LuxDropdown(String label, String value, List<String> items, ValueChanged<String?> onChanged) {
  return DropdownButtonFormField<String>(value: value, dropdownColor: AppColors.darkSurface,
    style: GoogleFonts.inter(color: AppColors.textPrimary, fontSize: 13),
    decoration: InputDecoration(labelText: label, prefixIcon: const Icon(Icons.arrow_drop_down_rounded, size: 18)),
    items: items.map((i) => DropdownMenuItem(value: i, child: Text(i))).toList(),
    onChanged: onChanged);
}

Widget _CheckItem(String label, bool value, ValueChanged<bool?> onChanged) {
  return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Checkbox(value: value, onChanged: onChanged, activeColor: AppColors.gold, side: const BorderSide(color: AppColors.border)),
    const SizedBox(width: 8),
    Expanded(child: Text(label, style: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 12, height: 1.5))),
  ]);
}

class _ApiStatCard extends StatelessWidget {
  final String value, label; final IconData icon; final Color color;
  const _ApiStatCard(this.value, this.label, this.icon, this.color);
  @override
  Widget build(BuildContext context) => Expanded(child: Container(
    padding: const EdgeInsets.symmetric(vertical: 14),
    decoration: BoxDecoration(color: AppColors.inkBlack, borderRadius: BorderRadius.circular(12), border: Border.all(color: color.withOpacity(0.2))),
    child: Column(children: [
      Icon(icon, color: color, size: 18),
      const SizedBox(height: 6),
      Text(value, style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
      Text(label, style: GoogleFonts.inter(fontSize: 10, color: AppColors.textMuted)),
    ])));
}

class _SuccessView extends StatelessWidget {
  final String title, subtitle; final VoidCallback onReset;
  const _SuccessView({required this.title, required this.subtitle, required this.onReset});
  @override
  Widget build(BuildContext context) => Center(child: Padding(padding: const EdgeInsets.all(28), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
    Container(padding: const EdgeInsets.all(20), decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.successLight.withOpacity(0.1), border: Border.all(color: AppColors.successLight.withOpacity(0.3))),
      child: const Icon(Icons.check_circle_rounded, color: AppColors.successLight, size: 48)),
    const SizedBox(height: 20),
    Text(title, style: GoogleFonts.inter(color: AppColors.textPrimary, fontSize: 24, fontWeight: FontWeight.w700)),
    const SizedBox(height: 8),
    Text(subtitle, style: GoogleFonts.inter(color: AppColors.gold, fontSize: 13)),
    const SizedBox(height: 6),
    Text('Our data team will review your request and contact you within 5 business days.', style: GoogleFonts.inter(color: AppColors.textMuted, fontSize: 13, height: 1.5), textAlign: TextAlign.center),
    const SizedBox(height: 24),
    OutlinedButton(onPressed: onReset, child: Text('Submit Another Request', style: GoogleFonts.inter(fontWeight: FontWeight.w600))),
  ])));
}
