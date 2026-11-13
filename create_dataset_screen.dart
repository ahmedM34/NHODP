// ═══════════════════════════════════════════════════════════════════
// create_dataset_screen.dart  —  NHODP v6
// Your full OCR implementation embedded inside Create Dataset.
// Adds: approval workflow, versioning, audit log on top of the real OCR pipeline.
// ═══════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:file_picker/file_picker.dart';
import '../config/app_colors.dart';
import '../providers/auth_provider.dart';
import '../providers/dataset_provider.dart';
import '../services/api_service.dart';

// ─── MODEL (same as your ocr_screen.dart) ────────────────────────
class _UploadFile {
  final String name;
  final List<int> bytes;
  final String mime;
  final int sizeBytes;
  _ProcessState state;
  Map<String, dynamic>? result;
  String? error;

  _UploadFile({
    required this.name,
    required this.bytes,
    required this.mime,
    required this.sizeBytes,
    this.state = _ProcessState.queued,
  });

  String get sizeStr {
    if (sizeBytes < 1024) return '${sizeBytes}B';
    if (sizeBytes < 1024 * 1024) return '${(sizeBytes / 1024).toStringAsFixed(0)}KB';
    return '${(sizeBytes / 1024 / 1024).toStringAsFixed(1)}MB';
  }

  String get ext => name.split('.').last.toUpperCase();

  Color get extColor {
    switch (ext) {
      case 'PDF': return AppColors.catCardio;
      case 'PNG': return AppColors.catHepato;
      case 'JPG':
      case 'JPEG': return AppColors.catInfectious;
      default: return AppColors.catNutrition;
    }
  }
}

enum _ProcessState { queued, processing, done, failed }

// ─── VERSIONING MODEL ─────────────────────────────────────────────
class _DatasetVersion {
  final int version;
  final String status;   // pending | approved | rejected
  final String submittedBy;
  final DateTime timestamp;
  final String? adminNote;

  const _DatasetVersion({
    required this.version,
    required this.status,
    required this.submittedBy,
    required this.timestamp,
    this.adminNote,
  });
}

// ─── SCREEN ──────────────────────────────────────────────────────
class CreateDatasetScreen extends StatefulWidget {
  const CreateDatasetScreen({Key? key}) : super(key: key);
  @override
  State<CreateDatasetScreen> createState() => _CreateDatasetScreenState();
}

class _CreateDatasetScreenState extends State<CreateDatasetScreen>
    with TickerProviderStateMixin {

  // ── OCR state (identical to your ocr_screen.dart) ─────────────
  late TabController _tabs;          // 4 tabs: Upload & Process | Results | My Datasets | Status
  final List<_UploadFile> _queue = [];
  bool _processingAll = false;
  int _processingIdx = -1;
  List<Map<String, dynamic>> _myDatasets = [];
  bool _loadingDatasets = false;

  // ── Approval / Versioning state ────────────────────────────────
  String _submissionStatus = 'none';   // none | pending | approved | rejected
  String? _datasetId;
  String? _adminFeedback;
  final List<_DatasetVersion> _versionHistory = [];

  // ── Audit log ─────────────────────────────────────────────────
  final List<String> _auditLog = [];

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 4, vsync: this);
    _loadMyDatasets();
    _addAudit('Create Dataset session opened');
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  void _addAudit(String msg) {
    final ts = DateTime.now().toIso8601String().substring(0, 19).replaceAll('T', ' ');
    setState(() => _auditLog.insert(0, '[$ts] $msg'));
  }

  // ── Dataset list (same as ocr_screen) ─────────────────────────
  Future<void> _loadMyDatasets() async {
    setState(() => _loadingDatasets = true);
    try {
      final r = await ApiService.listOcrDerivedDatasets(limit: 50);
      final list = r['datasets'] as List? ?? [];
      setState(() {
        _myDatasets = list.cast<Map<String, dynamic>>();
        _loadingDatasets = false;
      });
    } catch (_) {
      setState(() => _loadingDatasets = false);
    }
  }

  // ── File pick (identical to ocr_screen) ───────────────────────
  Future<void> _pickFiles() async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
      withData: true,
    );
    if (result == null || result.files.isEmpty) return;

    final added = <_UploadFile>[];
    for (final f in result.files) {
      if (f.bytes == null) continue;
      final mime = f.extension == 'pdf' ? 'application/pdf' : 'image/${f.extension}';
      added.add(_UploadFile(name: f.name, bytes: f.bytes!, mime: mime, sizeBytes: f.size));
    }
    if (added.isEmpty) return;
    setState(() => _queue.addAll(added));
    _addAudit('${added.length} file(s) added: ${added.map((f) => f.name).join(", ")}');
    _processAll();
  }

  // ── Process all (identical to ocr_screen) ─────────────────────
  Future<void> _processAll() async {
    if (_processingAll) return;
    setState(() => _processingAll = true);

    for (int i = 0; i < _queue.length; i++) {
      final f = _queue[i];
      if (f.state != _ProcessState.queued) continue;
      setState(() { _processingIdx = i; f.state = _ProcessState.processing; });
      try {
        final res = await ApiService.uploadOcrFile(
          fileBytes: f.bytes,
          fileName: f.name,
          mimeType: f.mime,
        );
        if (mounted) {
          setState(() {
            if (res.containsKey('error')) {
              f.state = _ProcessState.failed;
              f.error = res['error'] as String?;
              _addAudit('OCR failed: ${f.name} — ${f.error}');
            } else {
              f.state = _ProcessState.done;
              f.result = res;
              final phi = (res['phi_count'] as int?) ?? 0;
              _addAudit('OCR success: ${f.name} — $phi PHI removed, job: ${res['job_id']}');
            }
          });
        }
      } catch (e) {
        if (mounted) {
          setState(() { f.state = _ProcessState.failed; f.error = e.toString(); });
          _addAudit('OCR exception: ${f.name}');
        }
      }
    }
    if (mounted) setState(() { _processingAll = false; _processingIdx = -1; });
  }

  void _removeFile(int i) {
    _addAudit('File removed: ${_queue[i].name}');
    setState(() => _queue.removeAt(i));
  }

  void _clearDone() => setState(() => _queue.removeWhere((f) => f.state == _ProcessState.done));

  void _retryFailed() {
    setState(() {
      for (final f in _queue) {
        if (f.state == _ProcessState.failed) f.state = _ProcessState.queued;
      }
    });
    _processAll();
  }

  // ── Approval workflow ─────────────────────────────────────────
  void _onDatasetPublished() {
    _loadMyDatasets();
    _addAudit('Dataset submitted for admin review');
    setState(() => _submissionStatus = 'pending');
    // Jump to Status tab so user sees the workflow
    _tabs.animateTo(3);
  }

  void _simulateApprove() {
    final now = DateTime.now();
    setState(() {
      _submissionStatus = 'approved';
      _versionHistory.add(_DatasetVersion(
        version: _versionHistory.length + 1,
        status: 'approved',
        submittedBy: context.read<AuthProvider>().user?['email']?.toString() ?? 'user@nhodp.gov.eg',
        timestamp: now,
        adminNote: 'PHI removal verified. Dataset meets quality standards. Approved for catalog.',
      ));
    });
    _addAudit('Admin approved dataset — now active in catalog');
    context.read<DatasetProvider>().fetchDatasets();
  }

  void _simulateReject() {
    final now = DateTime.now();
    final feedback = 'Dataset requires additional field validation. Please check reference ranges and resubmit.';
    setState(() {
      _submissionStatus = 'rejected';
      _adminFeedback = feedback;
      _versionHistory.add(_DatasetVersion(
        version: _versionHistory.length + 1,
        status: 'rejected',
        submittedBy: context.read<AuthProvider>().user?['email']?.toString() ?? 'user@nhodp.gov.eg',
        timestamp: now,
        adminNote: feedback,
      ));
    });
    _addAudit('Admin rejected dataset — feedback provided');
  }

  void _startNewVersion() {
    setState(() { _submissionStatus = 'none'; });
    _addAudit('New version initiated — returning to upload');
    _tabs.animateTo(0);
  }

  // ── Audit log bottom sheet ────────────────────────────────────
  void _showAuditLog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.darkSurface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.55, maxChildSize: 0.9, minChildSize: 0.3, expand: false,
        builder: (_, ctrl) => Column(children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 10),
            child: Row(children: [
              const Icon(Icons.history_rounded, size: 18, color: AppColors.gold),
              const SizedBox(width: 10),
              Text('Audit Log', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
              const Spacer(),
              Text('${_auditLog.length} events', style: GoogleFonts.inter(fontSize: 11, color: AppColors.textMuted)),
            ])),
          Container(height: 1, color: AppColors.border),
          Expanded(child: ListView.builder(
            controller: ctrl,
            padding: const EdgeInsets.all(16),
            itemCount: _auditLog.length,
            itemBuilder: (_, i) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Container(width: 6, height: 6, margin: const EdgeInsets.only(top: 5, right: 10),
                  decoration: const BoxDecoration(color: AppColors.gold, shape: BoxShape.circle)),
                Expanded(child: Text(_auditLog[i],
                  style: GoogleFonts.robotoMono(fontSize: 10, color: AppColors.textSecondary, height: 1.4))),
              ])))),
        ])));
  }

  // ─────────────────────────────────────────────────────────────
  // BUILD
  // ─────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final done   = _queue.where((f) => f.state == _ProcessState.done).length;
    final failed = _queue.where((f) => f.state == _ProcessState.failed).length;
    final queued = _queue.where((f) => f.state == _ProcessState.queued).length;

    return Scaffold(
      backgroundColor: AppColors.obsidian,
      appBar: AppBar(
        backgroundColor: AppColors.charcoal,
        foregroundColor: AppColors.textPrimary,
        surfaceTintColor: Colors.transparent,
        scrolledUnderElevation: 0,
        title: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Create Dataset',
            style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
          Text('OCR  ·  Anonymize  ·  Admin Approval  ·  Versioning',
            style: GoogleFonts.inter(fontSize: 10, color: AppColors.textMuted)),
        ]),
        actions: [
          // Audit log icon
          IconButton(
            icon: const Icon(Icons.history_rounded, size: 20),
            tooltip: 'Audit Log',
            onPressed: _showAuditLog),
          if (_queue.isNotEmpty)
            TextButton.icon(
              onPressed: () { setState(() => _queue.clear()); _addAudit('Queue cleared'); },
              icon: const Icon(Icons.clear_all_rounded, size: 16),
              label: Text('Clear', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600)),
              style: TextButton.styleFrom(foregroundColor: AppColors.textMuted)),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(49),
          child: Column(children: [
            Container(height: 1, color: AppColors.border),
            TabBar(
              controller: _tabs,
              indicatorColor: AppColors.gold,
              indicatorWeight: 2,
              labelColor: AppColors.gold,
              unselectedLabelColor: AppColors.textMuted,
              labelStyle: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 11),
              dividerColor: Colors.transparent,
              isScrollable: true,
              tabs: [
                const Tab(text: 'Upload & OCR'),
                Tab(text: 'Results${done > 0 ? "  $done" : ""}'),
                const Tab(text: 'My Datasets'),
                Tab(text: _submissionStatus == 'none'
                  ? 'Approval'
                  : _submissionStatus == 'pending' ? '⏳ Pending'
                  : _submissionStatus == 'approved' ? '✅ Approved'
                  : '❌ Rejected'),
              ]),
          ])),
      ),
      body: TabBarView(
        controller: _tabs,
        children: [
          // ── TAB 1: Upload & OCR (your exact implementation) ──
          _UploadTab(
            queue: _queue,
            processing: _processingAll,
            processingIdx: _processingIdx,
            onPick: _pickFiles,
            onRemove: _removeFile,
            onRetryFailed: failed > 0 ? _retryFailed : null,
            onProcess: queued > 0 && !_processingAll ? _processAll : null,
          ),

          // ── TAB 2: Results (your exact implementation) ────────
          _ResultsTab(
            queue: _queue,
            onClearDone: done > 0 ? _clearDone : null,
            onDatasetPublished: _onDatasetPublished,
          ),

          // ── TAB 3: My Datasets (your exact implementation) ────
          _DatasetsTab(
            datasets: _myDatasets,
            loading: _loadingDatasets,
            onRefresh: _loadMyDatasets,
          ),

          // ── TAB 4: Approval & Versioning (new) ───────────────
          _ApprovalTab(
            status: _submissionStatus,
            adminFeedback: _adminFeedback,
            versionHistory: _versionHistory,
            onSimulateApprove: _simulateApprove,
            onSimulateReject: _simulateReject,
            onNewVersion: _startNewVersion,
            onGoToResults: () => _tabs.animateTo(1),
          ),
        ]),
    );
  }
}

// ══════════════════════════════════════════════════════════════════
// UPLOAD TAB — exact copy from your ocr_screen.dart
// ══════════════════════════════════════════════════════════════════

class _UploadTab extends StatelessWidget {
  final List<_UploadFile> queue;
  final bool processing;
  final int processingIdx;
  final VoidCallback onPick;
  final ValueChanged<int> onRemove;
  final VoidCallback? onRetryFailed;
  final VoidCallback? onProcess;

  const _UploadTab({
    required this.queue,
    required this.processing,
    required this.processingIdx,
    required this.onPick,
    required this.onRemove,
    this.onRetryFailed,
    this.onProcess,
  });

  @override
  Widget build(BuildContext context) {
    final done   = queue.where((f) => f.state == _ProcessState.done).length;
    final failed = queue.where((f) => f.state == _ProcessState.failed).length;
    final inProg = queue.where((f) => f.state == _ProcessState.processing).length;

    return ListView(padding: const EdgeInsets.all(16), children: [
      // How it works card
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.goldSurface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.gold.withOpacity(0.25))),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            ShaderMask(
              shaderCallback: (b) => const LinearGradient(colors: [AppColors.gold, AppColors.goldBright]).createShader(b),
              child: const Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 20)),
            const SizedBox(width: 10),
            Text('Intelligent Medical OCR Pipeline',
              style: GoogleFonts.inter(color: AppColors.textPrimary, fontSize: 15, fontWeight: FontWeight.w800)),
          ]),
          const SizedBox(height: 12),
          _Step('1', 'Upload', 'PDF, JPG, or PNG lab reports — single or bulk', AppColors.catInfectious),
          _Step('2', 'Extract', 'Arabic + English OCR with 97%+ accuracy', AppColors.catHepato),
          _Step('3', 'Anonymize', '18 PHI types detected and redacted — Arabic + English', AppColors.gold),
          _Step('4', 'Approve', 'Submit for admin approval to add to research catalog', AppColors.catMaternal),
        ])).animate().fadeIn(),
      const SizedBox(height: 16),

      // Drop zone
      GestureDetector(
        onTap: onPick,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 36),
          decoration: BoxDecoration(
            color: AppColors.inkBlack,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.gold.withOpacity(0.3), width: 1.5),
            boxShadow: [BoxShadow(color: AppColors.gold.withOpacity(0.05), blurRadius: 20)]),
          child: Column(children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppColors.gold.withOpacity(0.1),
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.gold.withOpacity(0.25))),
              child: ShaderMask(
                shaderCallback: (b) => const LinearGradient(colors: [AppColors.gold, AppColors.goldBright]).createShader(b),
                child: const Icon(Icons.cloud_upload_rounded, size: 44, color: Colors.white))),
            const SizedBox(height: 16),
            Text('Tap to Select Files',
              style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
            const SizedBox(height: 6),
            Text('PDF  ·  JPG  ·  PNG  —  single or bulk',
              style: GoogleFonts.inter(fontSize: 13, color: AppColors.textMuted)),
            const SizedBox(height: 14),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              _Pill(Icons.picture_as_pdf_rounded, 'PDF', AppColors.catCardio),
              const SizedBox(width: 8),
              _Pill(Icons.image_rounded, 'JPG', AppColors.catInfectious),
              const SizedBox(width: 8),
              _Pill(Icons.image_rounded, 'PNG', AppColors.catHepato),
            ]),
          ])).animate().fadeIn(delay: 100.ms)),
      const SizedBox(height: 14),

      // Queue status bar
      if (queue.isNotEmpty) ...[
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: AppColors.inkBlack,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.border)),
          child: Row(children: [
            _StatusDot('${queue.length}', 'total', AppColors.textSecondary),
            _StatusDot('$inProg', 'processing', AppColors.gold),
            _StatusDot('$done', 'done', AppColors.catHepato),
            if (failed > 0) _StatusDot('$failed', 'failed', AppColors.catCardio),
            const Spacer(),
            if (onProcess != null)
              GestureDetector(
                onTap: onProcess,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [AppColors.goldDim, AppColors.gold]),
                    borderRadius: BorderRadius.circular(8)),
                  child: Text('Process', style: GoogleFonts.inter(color: AppColors.obsidian, fontSize: 12, fontWeight: FontWeight.w800)))),
            if (onRetryFailed != null && !processing)
              GestureDetector(
                onTap: onRetryFailed,
                child: Container(
                  margin: const EdgeInsets.only(left: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.catCardio.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.catCardio.withOpacity(0.3))),
                  child: Text('Retry Failed', style: GoogleFonts.inter(color: AppColors.catCardio, fontSize: 11, fontWeight: FontWeight.w700)))),
          ])),
        const SizedBox(height: 10),

        // File queue list
        ...queue.asMap().entries.map((e) {
          final i = e.key;
          final f = e.value;
          return _FileQueueCard(
            file: f,
            isProcessing: processingIdx == i,
            onRemove: f.state != _ProcessState.processing ? () => onRemove(i) : null,
          ).animate(delay: Duration(milliseconds: i * 30)).fadeIn();
        }),
      ],
    ]);
  }
}

// ══════════════════════════════════════════════════════════════════
// RESULTS TAB — exact copy from your ocr_screen.dart
// ══════════════════════════════════════════════════════════════════

class _ResultsTab extends StatelessWidget {
  final List<_UploadFile> queue;
  final VoidCallback? onClearDone;
  final VoidCallback onDatasetPublished;
  const _ResultsTab({required this.queue, this.onClearDone, required this.onDatasetPublished});

  @override
  Widget build(BuildContext context) {
    final done = queue.where((f) => f.state == _ProcessState.done).toList();
    if (done.isEmpty) {
      return Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.inkBlack, border: Border.all(color: AppColors.border)),
          child: const Icon(Icons.article_outlined, size: 36, color: AppColors.textMuted)),
        const SizedBox(height: 14),
        Text('No results yet', style: GoogleFonts.inter(fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.textSecondary)),
        const SizedBox(height: 6),
        Text('Upload and process files in the first tab', style: GoogleFonts.inter(fontSize: 13, color: AppColors.textMuted)),
      ]));
    }

    return Column(children: [
      if (onClearDone != null)
        Container(
          color: AppColors.charcoal,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(children: [
            Text('${done.length} documents processed',
              style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
            const Spacer(),
            TextButton(onPressed: onClearDone, child: Text('Clear All', style: GoogleFonts.inter(fontSize: 12, color: AppColors.textMuted))),
          ])),
      Container(height: 1, color: AppColors.border),
      Expanded(child: ListView.builder(
        padding: const EdgeInsets.all(14),
        itemCount: done.length,
        itemBuilder: (_, i) => _ResultCard(
          file: done[i],
          onPublished: onDatasetPublished,
        ).animate(delay: Duration(milliseconds: i * 50)).fadeIn())),
    ]);
  }
}

class _ResultCard extends StatefulWidget {
  final _UploadFile file;
  final VoidCallback onPublished;
  const _ResultCard({required this.file, required this.onPublished});
  @override
  State<_ResultCard> createState() => _ResultCardState();
}

class _ResultCardState extends State<_ResultCard> {
  bool _expanded = false;
  bool _showOriginal = false;
  bool _publishing = false;
  bool _published = false;

  Future<void> _publish() async {
    final r = widget.file.result!;
    final formData = await showDialog<Map<String, dynamic>>(
      context: context,
      barrierDismissible: false,
      builder: (_) => _PublishDialog(
        jobId: r['job_id'] as String? ?? '',
        suggestedTitle: 'Anonymized Report — ${widget.file.name}',
        phiCount: (r['phi_count'] as int?) ?? 0,
      ));
    if (formData == null) return;
    setState(() => _publishing = true);
    try {
      final res = await ApiService.publishOcrJob(
        jobId: r['job_id'] as String? ?? '',
        title: formData['title'] as String,
        description: formData['description'] as String,
        category: formData['category'] as String,
        tags: List<String>.from(formData['tags'] as List? ?? []),
      );
      if (mounted) {
        setState(() { _publishing = false; _published = res['success'] == true; });
        if (_published) {
          widget.onPublished();
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            backgroundColor: AppColors.catHepato,
            content: Row(children: [
              const Icon(Icons.check_circle_rounded, color: Colors.white, size: 18),
              const SizedBox(width: 8),
              Text('Submitted — check Approval tab!', style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w600)),
            ]),
            action: SnackBarAction(label: 'Go', textColor: Colors.white,
              onPressed: () => Navigator.pushNamed(context, '/datasets'))));
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            backgroundColor: AppColors.catCardio,
            content: Text(res['detail']?.toString() ?? 'Publish failed', style: GoogleFonts.inter(color: Colors.white))));
        }
      }
    } catch (e) {
      if (mounted) setState(() => _publishing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final r = widget.file.result!;
    final phi = (r['phi_hits'] as List?) ?? (r['phi_detected'] as List?) ?? [];
    final conf = ((r['ocr_confidence'] as num?) ?? (r['confidence'] as num?) ?? 0) * 100;
    final anonymized = r['anonymized_text'] as String? ?? '';
    final original = r['original_text'] as String? ?? '';

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: AppColors.inkBlack,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _published ? AppColors.catHepato.withOpacity(0.4) : AppColors.border)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Header
        GestureDetector(
          onTap: () => setState(() => _expanded = !_expanded),
          child: Container(
            padding: const EdgeInsets.all(14),
            child: Row(children: [
              Container(
                width: 42, height: 42,
                decoration: BoxDecoration(
                  color: widget.file.extColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: widget.file.extColor.withOpacity(0.3))),
                child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Icon(widget.file.ext == 'PDF' ? Icons.picture_as_pdf_rounded : Icons.image_rounded,
                    size: 18, color: widget.file.extColor),
                  Text(widget.file.ext, style: GoogleFonts.inter(fontSize: 7, fontWeight: FontWeight.w800, color: widget.file.extColor)),
                ])),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(widget.file.name,
                  style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                  maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 4),
                Row(children: [
                  _Badge('${phi.length} PHI', AppColors.gold),
                  const SizedBox(width: 6),
                  _Badge('${conf.toStringAsFixed(0)}% OCR', AppColors.catHepato),
                  const SizedBox(width: 6),
                  _Badge(widget.file.sizeStr, AppColors.textMuted),
                ]),
              ])),
              if (_published)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.catHepato.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: AppColors.catHepato.withOpacity(0.3))),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    const Icon(Icons.verified_rounded, size: 12, color: AppColors.catHepato),
                    const SizedBox(width: 4),
                    Text('Submitted', style: GoogleFonts.inter(fontSize: 10, color: AppColors.catHepato, fontWeight: FontWeight.w700)),
                  ])),
              const SizedBox(width: 8),
              Icon(_expanded ? Icons.expand_less_rounded : Icons.expand_more_rounded, color: AppColors.textMuted, size: 20),
            ]))),

        if (_expanded) ...[
          Container(height: 1, color: AppColors.border),

          // PHI chips
          if (phi.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 0),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  const Icon(Icons.shield_rounded, size: 14, color: AppColors.gold),
                  const SizedBox(width: 6),
                  Text('${phi.length} PHI Types Detected & Redacted',
                    style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.gold)),
                ]),
                const SizedBox(height: 8),
                Wrap(spacing: 6, runSpacing: 6, children: phi.map((p) {
                  final type = (p['phi_type'] ?? 'unknown') as String;
                  final conf2 = ((p['confidence'] as num?) ?? 0) * 100;
                  const colorMap = {
                    'email': AppColors.catInfectious, 'phone_egypt': AppColors.catHepato,
                    'national_id': AppColors.catCardio, 'date': AppColors.catNutrition,
                    'date_of_birth': AppColors.catNutrition, 'name_english': AppColors.catOncology,
                    'name_arabic': AppColors.catMaternal, 'medical_record': AppColors.catMental,
                    'passport': AppColors.catPediatrics,
                  };
                  final c = colorMap[type] ?? AppColors.catInfrastructure;
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                    decoration: BoxDecoration(
                      color: c.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: c.withOpacity(0.3))),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      Container(width: 5, height: 5, decoration: BoxDecoration(color: c, shape: BoxShape.circle)),
                      const SizedBox(width: 5),
                      Text('${type.replaceAll('_', ' ').toUpperCase()}  ${conf2.toStringAsFixed(0)}%',
                        style: GoogleFonts.inter(fontSize: 9, color: c, fontWeight: FontWeight.w700, letterSpacing: 0.5)),
                    ]));
                }).toList()),
              ])),

          // Lab Results Table
          Builder(builder: (context) {
            final labs = (r['lab_results'] as List?) ?? [];
            if (labs.isEmpty) return const SizedBox.shrink();
            return Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 0),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  const Icon(Icons.biotech_rounded, size: 14, color: AppColors.catInfectious),
                  const SizedBox(width: 6),
                  Text('Extracted Lab Results — ${labs.length} tests',
                    style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.catInfectious)),
                ]),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(color: AppColors.elevated, borderRadius: BorderRadius.circular(10), border: Border.all(color: AppColors.border)),
                  child: Column(children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.catInfectious.withOpacity(0.08),
                        borderRadius: const BorderRadius.only(topLeft: Radius.circular(9), topRight: Radius.circular(9))),
                      child: Row(children: [
                        Expanded(flex: 3, child: Text('Test', style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w800, color: AppColors.textMuted, letterSpacing: 0.8))),
                        Expanded(flex: 2, child: Text('Result', style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w800, color: AppColors.textMuted, letterSpacing: 0.8))),
                        Expanded(flex: 1, child: Text('Unit', style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w800, color: AppColors.textMuted, letterSpacing: 0.8))),
                        Expanded(flex: 2, child: Text('Ref. Range', style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w800, color: AppColors.textMuted, letterSpacing: 0.8))),
                      ])),
                    ...labs.asMap().entries.map((e) {
                      final lab = e.value as Map<String, dynamic>;
                      final testName  = lab['test_name']?.toString() ?? '';
                      final result    = lab['result']?.toString() ?? '';
                      final unit      = lab['unit']?.toString() ?? '';
                      final refRange  = lab['reference_range']?.toString() ?? '';
                      final isNeg = result.toLowerCase().contains('negative');
                      final isPos = result.toLowerCase().contains('positive') || result.toLowerCase().contains('reactive');
                      final resultColor = isNeg ? AppColors.catHepato : isPos ? AppColors.catCardio : AppColors.textPrimary;
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: const BoxDecoration(border: Border(top: BorderSide(color: AppColors.border))),
                        child: Row(children: [
                          Expanded(flex: 3, child: Text(testName, style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textPrimary), maxLines: 2)),
                          Expanded(flex: 2, child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(color: resultColor.withOpacity(0.1), borderRadius: BorderRadius.circular(4), border: Border.all(color: resultColor.withOpacity(0.25))),
                            child: Text(result, style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w700, color: resultColor)))),
                          Expanded(flex: 1, child: Text(unit, style: GoogleFonts.inter(fontSize: 10, color: AppColors.textSecondary))),
                          Expanded(flex: 2, child: Text(refRange, style: GoogleFonts.inter(fontSize: 10, color: AppColors.textMuted))),
                        ]));
                    }).toList(),
                  ])),
              ]));
          }),

          // Export Downloads
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 0),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                const Icon(Icons.download_rounded, size: 14, color: AppColors.textSecondary),
                const SizedBox(width: 6),
                Text('Download Structured Output', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textSecondary)),
              ]),
              const SizedBox(height: 8),
              Row(children: [
                _ExportBtn('JSON', AppColors.catInfectious, () => _downloadExport(context, r['job_id']?.toString() ?? '', 'json')),
                const SizedBox(width: 6),
                _ExportBtn('CSV', AppColors.catHepato, () => _downloadExport(context, r['job_id']?.toString() ?? '', 'csv')),
                const SizedBox(width: 6),
                _ExportBtn('XML', AppColors.catCardio, () => _downloadExport(context, r['job_id']?.toString() ?? '', 'xml')),
                const SizedBox(width: 6),
                _ExportBtn('TXT', AppColors.gold, () => _downloadExport(context, r['job_id']?.toString() ?? '', 'txt')),
              ]),
            ])),

          // Text toggle
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 0),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Text(_showOriginal ? 'Original Text' : 'Anonymized Text',
                  style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                const Spacer(),
                GestureDetector(
                  onTap: () => setState(() => _showOriginal = !_showOriginal),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: (_showOriginal ? AppColors.warning : AppColors.catHepato).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: (_showOriginal ? AppColors.warning : AppColors.catHepato).withOpacity(0.3))),
                    child: Text(_showOriginal ? 'Show Anonymized' : 'Show Original',
                      style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w700,
                        color: _showOriginal ? AppColors.warning : AppColors.catHepato)))),
              ]),
              if (_showOriginal)
                Container(
                  margin: const EdgeInsets.only(top: 6),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withOpacity(0.07),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: AppColors.warning.withOpacity(0.25))),
                  child: Row(children: [
                    const Icon(Icons.warning_amber_rounded, size: 12, color: AppColors.warning),
                    const SizedBox(width: 6),
                    Text('Contains PHI — for review only. Do not share.', style: GoogleFonts.inter(fontSize: 10, color: AppColors.warning)),
                  ])),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: AppColors.elevated, borderRadius: BorderRadius.circular(10), border: Border.all(color: AppColors.border)),
                child: SelectableText(
                  _showOriginal ? original : anonymized,
                  style: GoogleFonts.robotoMono(fontSize: 11, color: AppColors.textSecondary, height: 1.8))),
            ])),

          // Publish / Submit button
          Padding(
            padding: const EdgeInsets.all(14),
            child: _published
              ? Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.catHepato.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.catHepato.withOpacity(0.25))),
                  child: Row(children: [
                    const Icon(Icons.check_circle_rounded, color: AppColors.catHepato, size: 20),
                    const SizedBox(width: 10),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('Submitted for Admin Review', style: GoogleFonts.inter(fontWeight: FontWeight.w800, fontSize: 14, color: AppColors.catHepato)),
                      Text('Check the Approval tab to track status', style: GoogleFonts.inter(fontSize: 11, color: AppColors.textMuted)),
                    ])),
                    TextButton(
                      onPressed: () => Navigator.pushNamed(context, '/datasets'),
                      child: Text('View →', style: GoogleFonts.inter(color: AppColors.gold, fontWeight: FontWeight.w700))),
                  ]))
              : GestureDetector(
                  onTap: _publishing ? null : _publish,
                  child: Container(
                    height: 52,
                    decoration: BoxDecoration(
                      gradient: !_publishing
                        ? const LinearGradient(colors: [AppColors.goldDim, AppColors.gold, AppColors.goldLight])
                        : null,
                      color: _publishing ? AppColors.elevated : null,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: !_publishing
                        ? [BoxShadow(color: AppColors.gold.withOpacity(0.25), blurRadius: 16, offset: const Offset(0, 6))]
                        : []),
                    child: Center(child: _publishing
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2.5, color: AppColors.obsidian))
                      : Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                          const Icon(Icons.upload_rounded, color: AppColors.obsidian, size: 18),
                          const SizedBox(width: 8),
                          Text('Request Publication', style: GoogleFonts.inter(color: AppColors.obsidian, fontWeight: FontWeight.w800, fontSize: 15)),
                        ]))))),
        ],
      ]));
  }
}

// ══════════════════════════════════════════════════════════════════
// MY DATASETS TAB — exact copy from your ocr_screen.dart
// ══════════════════════════════════════════════════════════════════

class _DatasetsTab extends StatefulWidget {
  final List<Map<String, dynamic>> datasets;
  final bool loading;
  final VoidCallback onRefresh;
  const _DatasetsTab({required this.datasets, required this.loading, required this.onRefresh});
  @override
  State<_DatasetsTab> createState() => _DatasetsTabState();
}

class _DatasetsTabState extends State<_DatasetsTab> {
  Future<void> _publishNewVersion(Map<String, dynamic> ds) async {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('Upload a new file in the Upload tab to create a new version', style: GoogleFonts.inter(color: Colors.white)),
      backgroundColor: AppColors.charcoal,
      action: SnackBarAction(label: 'Go', textColor: AppColors.gold, onPressed: () => DefaultTabController.of(context).animateTo(0))));
  }

  @override
  Widget build(BuildContext context) {
    if (widget.loading) return const Center(child: CircularProgressIndicator(color: AppColors.gold, strokeWidth: 2));
    if (widget.datasets.isEmpty) {
      return RefreshIndicator(color: AppColors.gold, onRefresh: () async => widget.onRefresh(),
        child: ListView(children: [
          SizedBox(height: MediaQuery.of(context).size.height * 0.25),
          Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.inkBlack, border: Border.all(color: AppColors.border)),
              child: const Icon(Icons.dataset_outlined, size: 36, color: AppColors.textMuted)),
            const SizedBox(height: 14),
            Text('No published datasets yet', style: GoogleFonts.inter(fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.textSecondary)),
            const SizedBox(height: 6),
            Text('Process files and request publication', style: GoogleFonts.inter(fontSize: 13, color: AppColors.textMuted)),
          ])),
        ]));
    }
    return RefreshIndicator(color: AppColors.gold, onRefresh: () async => widget.onRefresh(),
      child: ListView.builder(
        padding: const EdgeInsets.all(14),
        itemCount: widget.datasets.length,
        itemBuilder: (_, i) {
          final ds = widget.datasets[i];
          return _DatasetManageCard(ds: ds, onPublishVersion: () => _publishNewVersion(ds), onRefresh: widget.onRefresh)
            .animate(delay: Duration(milliseconds: i * 40)).fadeIn();
        }));
  }
}

class _DatasetManageCard extends StatefulWidget {
  final Map<String, dynamic> ds;
  final VoidCallback onPublishVersion;
  final VoidCallback onRefresh;
  const _DatasetManageCard({required this.ds, required this.onPublishVersion, required this.onRefresh});
  @override
  State<_DatasetManageCard> createState() => _DatasetManageCardState();
}

class _DatasetManageCardState extends State<_DatasetManageCard> {
  bool _updating = false;

  Future<void> _editMetadata() async {
    final ds = widget.ds;
    final titleCtrl = TextEditingController(text: ds['title'] as String? ?? '');
    final descCtrl  = TextEditingController(text: ds['description'] as String? ?? '');
    String cat = ds['category'] as String? ?? 'Clinical Records';
    const cats = ['Clinical Records','Radiology','Pathology','Pharmacy','Oncology','Cardiology','Pediatrics','Other'];

    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (_) => StatefulBuilder(builder: (ctx, sSet) => Dialog(
        child: Padding(padding: const EdgeInsets.all(20), child: Column(mainAxisSize: MainAxisSize.min, children: [
          Row(children: [
            Text('Edit Dataset', style: GoogleFonts.inter(fontSize: 17, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
            const Spacer(),
            IconButton(icon: const Icon(Icons.close_rounded, size: 18, color: AppColors.textMuted), onPressed: () => Navigator.pop(ctx)),
          ]),
          const SizedBox(height: 14),
          TextField(controller: titleCtrl, style: GoogleFonts.inter(color: AppColors.textPrimary, fontSize: 13),
            decoration: const InputDecoration(labelText: 'Title', prefixIcon: Icon(Icons.title_rounded, size: 18))),
          const SizedBox(height: 10),
          TextField(controller: descCtrl, maxLines: 3, style: GoogleFonts.inter(color: AppColors.textPrimary, fontSize: 13),
            decoration: const InputDecoration(labelText: 'Description', prefixIcon: Icon(Icons.description_rounded, size: 18), alignLabelWithHint: true)),
          const SizedBox(height: 10),
          DropdownButtonFormField<String>(
            value: cats.contains(cat) ? cat : cats[0],
            dropdownColor: AppColors.darkSurface,
            style: GoogleFonts.inter(color: AppColors.textPrimary, fontSize: 13),
            decoration: const InputDecoration(labelText: 'Category', prefixIcon: Icon(Icons.category_rounded, size: 18)),
            items: cats.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
            onChanged: (v) => sSet(() => cat = v ?? cat)),
          const SizedBox(height: 16),
          Row(children: [
            Expanded(child: OutlinedButton(onPressed: () => Navigator.pop(ctx), child: Text('Cancel', style: GoogleFonts.inter(fontWeight: FontWeight.w600)))),
            const SizedBox(width: 10),
            Expanded(flex: 2, child: FilledButton(
              onPressed: () => Navigator.pop(ctx, {'title': titleCtrl.text.trim(), 'description': descCtrl.text.trim(), 'category': cat}),
              child: Text('Save Changes', style: GoogleFonts.inter(fontWeight: FontWeight.w700)))),
          ]),
        ])))));

    titleCtrl.dispose(); descCtrl.dispose();
    if (result == null) return;
    setState(() => _updating = true);
    try {
      await ApiService.updateDataset(widget.ds['id'] as String? ?? '', result);
      widget.onRefresh();
    } finally {
      if (mounted) setState(() => _updating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final ds = widget.ds;
    final published = ds['dataset_published'] as bool? ?? true;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.inkBlack,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: published ? AppColors.catHepato.withOpacity(0.25) : AppColors.border)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(color: AppColors.catInfectious.withOpacity(0.1), borderRadius: BorderRadius.circular(9), border: Border.all(color: AppColors.catInfectious.withOpacity(0.25))),
            child: const Icon(Icons.dataset_rounded, size: 18, color: AppColors.catInfectious)),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(ds['title'] as String? ?? 'Untitled', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary), maxLines: 2, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 3),
            Text(ds['category'] as String? ?? '', style: GoogleFonts.inter(fontSize: 11, color: AppColors.textMuted)),
          ])),
          if (published)
            Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(color: AppColors.catHepato.withOpacity(0.1), borderRadius: BorderRadius.circular(6), border: Border.all(color: AppColors.catHepato.withOpacity(0.3))),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                const Icon(Icons.public_rounded, size: 11, color: AppColors.catHepato),
                const SizedBox(width: 4),
                Text('Published', style: GoogleFonts.inter(fontSize: 10, color: AppColors.catHepato, fontWeight: FontWeight.w700)),
              ])),
        ]),
        const SizedBox(height: 10),
        Row(children: [
          _Stat(Icons.download_rounded, '${ds['downloads'] ?? 0}', AppColors.textMuted),
          const SizedBox(width: 12),
          _Stat(Icons.visibility_rounded, '${ds['views'] ?? 0}', AppColors.textMuted),
          const SizedBox(width: 12),
          _Stat(Icons.shield_rounded, '${ds['phi_removed_count'] ?? ds['phi_count'] ?? 0} PHI removed', AppColors.gold),
        ]),
        const SizedBox(height: 12),
        Container(height: 1, color: AppColors.border),
        const SizedBox(height: 10),
        Row(children: [
          Expanded(child: OutlinedButton.icon(
            onPressed: _updating ? null : _editMetadata,
            icon: _updating ? const SizedBox(width: 12, height: 12, child: CircularProgressIndicator(strokeWidth: 1.5, color: AppColors.gold)) : const Icon(Icons.edit_rounded, size: 14),
            label: Text('Edit Metadata', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600)),
            style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 10), foregroundColor: AppColors.gold, side: const BorderSide(color: AppColors.gold, width: 1), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))))),
          const SizedBox(width: 8),
          Expanded(child: OutlinedButton.icon(
            onPressed: widget.onPublishVersion,
            icon: const Icon(Icons.update_rounded, size: 14),
            label: Text('New Version', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600)),
            style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 10), foregroundColor: AppColors.catInfectious, side: const BorderSide(color: AppColors.catInfectious, width: 1), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))))),
          const SizedBox(width: 8),
          OutlinedButton.icon(
            onPressed: () => Navigator.pushNamed(context, '/datasets'),
            icon: const Icon(Icons.open_in_new_rounded, size: 14),
            label: Text('View', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600)),
            style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10), foregroundColor: AppColors.textMuted, side: const BorderSide(color: AppColors.border, width: 1), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)))),
        ]),
      ]));
  }
}

// ══════════════════════════════════════════════════════════════════
// APPROVAL & VERSIONING TAB — new addition
// ══════════════════════════════════════════════════════════════════

class _ApprovalTab extends StatelessWidget {
  final String status;
  final String? adminFeedback;
  final List<_DatasetVersion> versionHistory;
  final VoidCallback onSimulateApprove;
  final VoidCallback onSimulateReject;
  final VoidCallback onNewVersion;
  final VoidCallback onGoToResults;

  const _ApprovalTab({
    required this.status,
    required this.adminFeedback,
    required this.versionHistory,
    required this.onSimulateApprove,
    required this.onSimulateReject,
    required this.onNewVersion,
    required this.onGoToResults,
  });

  @override
  Widget build(BuildContext context) {
    if (status == 'none') return _buildWaitingState(context);
    if (status == 'pending') return _buildPendingState(context);
    if (status == 'approved') return _buildApprovedState(context);
    return _buildRejectedState(context);
  }

  Widget _buildWaitingState(BuildContext context) => Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
    Container(padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.inkBlack, border: Border.all(color: AppColors.border)),
      child: const Icon(Icons.pending_actions_rounded, size: 44, color: AppColors.textMuted)),
    const SizedBox(height: 16),
    Text('No submission yet', style: GoogleFonts.inter(fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.textSecondary)),
    const SizedBox(height: 8),
    Text('Process files and tap "Request Publication"\nin the Results tab to begin.',
      style: GoogleFonts.inter(fontSize: 13, color: AppColors.textMuted), textAlign: TextAlign.center),
    const SizedBox(height: 24),
    GestureDetector(
      onTap: onGoToResults,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [AppColors.goldDim, AppColors.gold]),
          borderRadius: BorderRadius.circular(10)),
        child: Text('Go to Results →', style: GoogleFonts.inter(color: AppColors.obsidian, fontWeight: FontWeight.w800)))),
  ]));

  Widget _buildPendingState(BuildContext context) => SingleChildScrollView(
    padding: const EdgeInsets.all(16),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      // Status card
      Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [AppColors.gold.withOpacity(0.1), AppColors.gold.withOpacity(0.03)]),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.gold.withOpacity(0.3))),
        child: Row(children: [
          SizedBox(width: 26, height: 26, child: CircularProgressIndicator(strokeWidth: 2.5, color: AppColors.gold, backgroundColor: AppColors.elevated)),
          const SizedBox(width: 14),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Pending Admin Review', style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.gold)),
            Text('An admin will verify PHI removal and data quality before approving.',
              style: GoogleFonts.inter(fontSize: 12, color: AppColors.textMuted, height: 1.4)),
          ])),
        ])).animate().fadeIn(),

      const SizedBox(height: 20),

      // Workflow diagram
      Text('Review Workflow', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textSecondary)),
      const SizedBox(height: 10),
      _WorkflowDiagram(currentStep: 1),

      const SizedBox(height: 24),

      // Demo admin panel
      Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.elevated.withOpacity(0.5),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            const Icon(Icons.admin_panel_settings_rounded, size: 16, color: AppColors.textMuted),
            const SizedBox(width: 8),
            Text('Admin Panel (Demo)', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textMuted)),
          ]),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: GestureDetector(
              onTap: onSimulateApprove,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(color: AppColors.catHepato.withOpacity(0.1), borderRadius: BorderRadius.circular(10), border: Border.all(color: AppColors.catHepato.withOpacity(0.4))),
                child: Column(children: [
                  const Icon(Icons.check_circle_rounded, color: AppColors.catHepato, size: 26),
                  const SizedBox(height: 6),
                  Text('Approve', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.catHepato)),
                  Text('Make dataset active', style: GoogleFonts.inter(fontSize: 10, color: AppColors.textMuted)),
                ])))),
            const SizedBox(width: 12),
            Expanded(child: GestureDetector(
              onTap: onSimulateReject,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(color: AppColors.error.withOpacity(0.08), borderRadius: BorderRadius.circular(10), border: Border.all(color: AppColors.error.withOpacity(0.35))),
                child: Column(children: [
                  Icon(Icons.cancel_rounded, color: AppColors.errorLight, size: 26),
                  const SizedBox(height: 6),
                  Text('Reject', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.errorLight)),
                  Text('Send feedback to user', style: GoogleFonts.inter(fontSize: 10, color: AppColors.textMuted)),
                ])))),
          ]),
        ])),
    ]));

  Widget _buildApprovedState(BuildContext context) => SingleChildScrollView(
    padding: const EdgeInsets.all(16),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [AppColors.catHepato.withOpacity(0.12), AppColors.catHepato.withOpacity(0.03)]),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.catHepato.withOpacity(0.35))),
        child: Row(children: [
          const Icon(Icons.verified_rounded, color: AppColors.catHepato, size: 32),
          const SizedBox(width: 14),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Dataset Approved & Active', style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.catHepato)),
            Text('Now visible in the health research catalog.', style: GoogleFonts.inter(fontSize: 12, color: AppColors.textMuted)),
          ])),
        ])).animate().fadeIn(),

      const SizedBox(height: 16),
      _WorkflowDiagram(currentStep: 3),
      const SizedBox(height: 20),

      if (versionHistory.isNotEmpty) ...[
        _VersionHistorySection(versions: versionHistory),
        const SizedBox(height: 20),
      ],

      Row(children: [
        Expanded(child: OutlinedButton.icon(
          onPressed: () => Navigator.pushNamed(context, '/datasets'),
          icon: const Icon(Icons.open_in_new_rounded, size: 14),
          label: Text('View in Catalog', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
          style: OutlinedButton.styleFrom(foregroundColor: AppColors.catHepato, side: const BorderSide(color: AppColors.catHepato), minimumSize: const Size(0, 48)))),
        const SizedBox(width: 12),
        Expanded(child: GestureDetector(
          onTap: onNewVersion,
          child: Container(
            height: 48,
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [AppColors.goldDim, AppColors.gold]),
              borderRadius: BorderRadius.circular(10)),
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              const Icon(Icons.update_rounded, color: AppColors.obsidian, size: 16),
              const SizedBox(width: 6),
              Text('Create v${(versionHistory.length + 1)}', style: GoogleFonts.inter(color: AppColors.obsidian, fontWeight: FontWeight.w800)),
            ])))),
      ]),
    ]));

  Widget _buildRejectedState(BuildContext context) => SingleChildScrollView(
    padding: const EdgeInsets.all(16),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [AppColors.error.withOpacity(0.1), AppColors.error.withOpacity(0.03)]),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.error.withOpacity(0.35))),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Icon(Icons.cancel_rounded, color: AppColors.errorLight, size: 26),
            const SizedBox(width: 12),
            Text('Dataset Rejected', style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.errorLight)),
          ]),
          if (adminFeedback != null) ...[
            const SizedBox(height: 12),
            Container(height: 1, color: AppColors.error.withOpacity(0.2)),
            const SizedBox(height: 10),
            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Icon(Icons.feedback_rounded, size: 14, color: AppColors.textMuted),
              const SizedBox(width: 8),
              Expanded(child: Text(adminFeedback!, style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary, height: 1.5))),
            ]),
          ],
        ])).animate().fadeIn(),

      const SizedBox(height: 16),

      if (versionHistory.isNotEmpty) ...[
        _VersionHistorySection(versions: versionHistory),
        const SizedBox(height: 20),
      ],

      GestureDetector(
        onTap: onNewVersion,
        child: Container(
          height: 52,
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [AppColors.goldDim, AppColors.gold, AppColors.goldLight]),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [BoxShadow(color: AppColors.gold.withOpacity(0.25), blurRadius: 12, offset: const Offset(0, 4))]),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            const Icon(Icons.edit_rounded, color: AppColors.obsidian, size: 18),
            const SizedBox(width: 8),
            Text('Revise & Resubmit', style: GoogleFonts.inter(color: AppColors.obsidian, fontWeight: FontWeight.w800, fontSize: 15)),
          ]))),
    ]));
}

// ── Workflow diagram ──────────────────────────────────────────────

class _WorkflowDiagram extends StatelessWidget {
  final int currentStep; // 0=submit 1=review 2=decision 3=approved
  const _WorkflowDiagram({required this.currentStep});

  @override
  Widget build(BuildContext context) {
    const steps = [
      (Icons.upload_rounded, 'Submitted'),
      (Icons.manage_search_rounded, 'Under Review'),
      (Icons.gavel_rounded, 'Decision'),
      (Icons.public_rounded, 'Live in Catalog'),
    ];
    return Row(children: List.generate(steps.length * 2 - 1, (i) {
      if (i.isOdd) {
        final done = i ~/ 2 < currentStep;
        return Expanded(child: Container(height: 2, color: done ? AppColors.gold : AppColors.border));
      }
      final idx = i ~/ 2;
      final done = idx < currentStep;
      final active = idx == currentStep;
      return Column(mainAxisSize: MainAxisSize.min, children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: 32, height: 32,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: done ? AppColors.gold : active ? AppColors.goldDeep : AppColors.elevated,
            border: Border.all(color: done || active ? AppColors.gold : AppColors.border, width: active ? 2 : 1)),
          child: Icon(steps[idx].$1, size: 14, color: done ? AppColors.obsidian : active ? AppColors.gold : AppColors.textMuted)),
        const SizedBox(height: 4),
        Text(steps[idx].$2, style: GoogleFonts.inter(fontSize: 8, color: active ? AppColors.gold : AppColors.textMuted, fontWeight: active ? FontWeight.w700 : FontWeight.w400)),
      ]);
    }));
  }
}

// ── Version history ───────────────────────────────────────────────

class _VersionHistorySection extends StatelessWidget {
  final List<_DatasetVersion> versions;
  const _VersionHistorySection({required this.versions});

  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Row(children: [
      const Icon(Icons.history_rounded, size: 16, color: AppColors.gold),
      const SizedBox(width: 8),
      Text('Version History', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
      const Spacer(),
      Text('${versions.length} version(s)', style: GoogleFonts.inter(fontSize: 11, color: AppColors.textMuted)),
    ]),
    const SizedBox(height: 10),
    ...versions.reversed.map((v) {
      final statusColor = v.status == 'approved' ? AppColors.catHepato : v.status == 'rejected' ? AppColors.error : AppColors.gold;
      return Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: AppColors.inkBlack, borderRadius: BorderRadius.circular(10), border: Border.all(color: AppColors.border)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(color: AppColors.elevated, borderRadius: BorderRadius.circular(4)),
              child: Text('v${v.version}', style: GoogleFonts.robotoMono(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.gold))),
            const SizedBox(width: 8),
            Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(color: statusColor.withOpacity(0.12), borderRadius: BorderRadius.circular(4), border: Border.all(color: statusColor.withOpacity(0.3))),
              child: Text(v.status.toUpperCase(), style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.w800, color: statusColor))),
            const Spacer(),
            Text(v.timestamp.toIso8601String().substring(0, 16).replaceAll('T', ' '), style: GoogleFonts.inter(fontSize: 10, color: AppColors.textMuted)),
          ]),
          const SizedBox(height: 4),
          Text('By: ${v.submittedBy}', style: GoogleFonts.inter(fontSize: 10, color: AppColors.textMuted)),
          if (v.adminNote != null) ...[
            const SizedBox(height: 6),
            Container(height: 1, color: AppColors.border),
            const SizedBox(height: 6),
            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Icon(Icons.admin_panel_settings_rounded, size: 11, color: AppColors.textMuted),
              const SizedBox(width: 5),
              Expanded(child: Text(v.adminNote!, style: GoogleFonts.inter(fontSize: 11, color: AppColors.textSecondary, height: 1.4))),
            ]),
          ],
        ]));
    }).toList(),
  ]);
}

// ══════════════════════════════════════════════════════════════════
// SHARED WIDGETS — exact copies from your ocr_screen.dart
// ══════════════════════════════════════════════════════════════════

class _Step extends StatelessWidget {
  final String n, title, desc; final Color c;
  const _Step(this.n, this.title, this.desc, this.c);
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Container(width: 20, height: 20,
        decoration: BoxDecoration(color: c.withOpacity(0.15), shape: BoxShape.circle, border: Border.all(color: c.withOpacity(0.4))),
        child: Center(child: Text(n, style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.w900, color: c)))),
      const SizedBox(width: 10),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
        Text(desc, style: GoogleFonts.inter(fontSize: 11, color: AppColors.textMuted)),
      ])),
    ]));
}

class _Pill extends StatelessWidget {
  final IconData icon; final String label; final Color c;
  const _Pill(this.icon, this.label, this.c);
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    decoration: BoxDecoration(color: c.withOpacity(0.1), borderRadius: BorderRadius.circular(20), border: Border.all(color: c.withOpacity(0.3))),
    child: Row(mainAxisSize: MainAxisSize.min, children: [
      Icon(icon, size: 13, color: c), const SizedBox(width: 5),
      Text(label, style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700, color: c)),
    ]));
}

class _StatusDot extends StatelessWidget {
  final String count, label; final Color c;
  const _StatusDot(this.count, this.label, this.c);
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(right: 14),
    child: Row(mainAxisSize: MainAxisSize.min, children: [
      Container(width: 7, height: 7, decoration: BoxDecoration(color: c, shape: BoxShape.circle)),
      const SizedBox(width: 5),
      Text('$count $label', style: GoogleFonts.inter(fontSize: 11, color: AppColors.textSecondary)),
    ]));
}

class _FileQueueCard extends StatelessWidget {
  final _UploadFile file;
  final bool isProcessing;
  final VoidCallback? onRemove;
  const _FileQueueCard({required this.file, required this.isProcessing, this.onRemove});

  @override
  Widget build(BuildContext context) {
    Color stateColor; IconData stateIcon; String stateLabel;
    switch (file.state) {
      case _ProcessState.queued:     stateColor = AppColors.textMuted;  stateIcon = Icons.schedule_rounded;    stateLabel = 'Queued'; break;
      case _ProcessState.processing: stateColor = AppColors.gold;       stateIcon = Icons.autorenew_rounded;   stateLabel = 'Processing…'; break;
      case _ProcessState.done:       stateColor = AppColors.catHepato;  stateIcon = Icons.check_circle_rounded; stateLabel = '${file.result?['phi_count'] ?? 0} PHI removed'; break;
      case _ProcessState.failed:     stateColor = AppColors.catCardio;  stateIcon = Icons.error_rounded;       stateLabel = 'Failed'; break;
    }
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: AppColors.inkBlack, borderRadius: BorderRadius.circular(12), border: Border.all(color: stateColor.withOpacity(0.25), width: 1.5)),
      child: Row(children: [
        Container(width: 40, height: 40,
          decoration: BoxDecoration(color: file.extColor.withOpacity(0.1), borderRadius: BorderRadius.circular(8), border: Border.all(color: file.extColor.withOpacity(0.3))),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(file.ext == 'PDF' ? Icons.picture_as_pdf_rounded : Icons.image_rounded, size: 16, color: file.extColor),
            Text(file.ext, style: GoogleFonts.inter(fontSize: 7, fontWeight: FontWeight.w800, color: file.extColor)),
          ])),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(file.name, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary), maxLines: 1, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 3),
          Row(children: [
            if (isProcessing) ...[
              SizedBox(width: 10, height: 10, child: CircularProgressIndicator(strokeWidth: 1.5, color: AppColors.gold)),
              const SizedBox(width: 6),
            ] else Icon(stateIcon, size: 12, color: stateColor),
            const SizedBox(width: 4),
            Text(stateLabel, style: GoogleFonts.inter(fontSize: 11, color: stateColor)),
            const SizedBox(width: 10),
            Text(file.sizeStr, style: GoogleFonts.inter(fontSize: 11, color: AppColors.textMuted)),
          ]),
          if (file.state == _ProcessState.done && file.result != null) _OcrMiniSummary(result: file.result!),
        ])),
        if (onRemove != null)
          IconButton(icon: const Icon(Icons.close_rounded, size: 16, color: AppColors.textMuted), onPressed: onRemove, padding: EdgeInsets.zero, constraints: const BoxConstraints(minWidth: 28, minHeight: 28)),
      ]));
  }
}

class _OcrMiniSummary extends StatelessWidget {
  final Map<String, dynamic> result;
  const _OcrMiniSummary({required this.result});
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 6),
    child: Row(children: [
      _Badge('${result['phi_count'] ?? (result['phi_hits'] as List?)?.length ?? 0} PHI', AppColors.gold),
      const SizedBox(width: 6),
      _Badge('${(((result['ocr_confidence'] as num?) ?? (result['confidence'] as num?) ?? 0) * 100).toStringAsFixed(0)}% conf', AppColors.catHepato),
      const SizedBox(width: 6),
      _Badge('${(result['processing_time_s'] as num?) ?? (result['processing_time'] as num?)?.toStringAsFixed(1) ?? '?'}s', AppColors.textMuted),
    ]));
}

class _Badge extends StatelessWidget {
  final String t; final Color c;
  const _Badge(this.t, this.c);
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
    decoration: BoxDecoration(color: c.withOpacity(0.1), borderRadius: BorderRadius.circular(4), border: Border.all(color: c.withOpacity(0.25))),
    child: Text(t, style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.w700, color: c)));
}

class _Stat extends StatelessWidget {
  final IconData icon; final String label; final Color c;
  const _Stat(this.icon, this.label, this.c);
  @override
  Widget build(BuildContext context) => Row(mainAxisSize: MainAxisSize.min, children: [
    Icon(icon, size: 12, color: c), const SizedBox(width: 4),
    Text(label, style: GoogleFonts.inter(fontSize: 11, color: c)),
  ]);
}

// ══════════════════════════════════════════════════════════════════
// PUBLISH DIALOG — exact copy from your ocr_screen.dart
// ══════════════════════════════════════════════════════════════════

void _downloadExport(BuildContext context, String jobId, String format) async {
  if (jobId.isEmpty) return;
  final baseUrl = 'http://localhost:8003';
  final url = '$baseUrl/ocr/jobs/$jobId/export/$format';
  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      backgroundColor: AppColors.darkSurface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14), side: BorderSide(color: AppColors.gold.withOpacity(0.3))),
      title: Text('Download ${format.toUpperCase()}', style: GoogleFonts.inter(color: AppColors.gold, fontWeight: FontWeight.w800)),
      content: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Open this URL in your browser to download:', style: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 13)),
        const SizedBox(height: 10),
        Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: AppColors.elevated, borderRadius: BorderRadius.circular(8), border: Border.all(color: AppColors.border)),
          child: SelectableText(url, style: GoogleFonts.robotoMono(color: AppColors.catInfectious, fontSize: 12))),
      ]),
      actions: [TextButton(onPressed: () => Navigator.pop(context), child: Text('Close', style: GoogleFonts.inter(color: AppColors.gold, fontWeight: FontWeight.w700)))],
    ));
}

class _ExportBtn extends StatelessWidget {
  final String label; final Color color; final VoidCallback onTap;
  const _ExportBtn(this.label, this.color, this.onTap);
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8), border: Border.all(color: color.withOpacity(0.35))),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(Icons.download_rounded, size: 13, color: color), const SizedBox(width: 5),
        Text(label, style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w800, color: color, letterSpacing: 0.5)),
      ])));
}

class _PublishDialog extends StatefulWidget {
  final String jobId, suggestedTitle;
  final int phiCount;
  const _PublishDialog({required this.jobId, required this.suggestedTitle, required this.phiCount});
  @override
  State<_PublishDialog> createState() => _PublishDialogState();
}

class _PublishDialogState extends State<_PublishDialog> {
  late TextEditingController _titleCtrl, _descCtrl;
  String _cat = 'Clinical Records';
  final _formKey = GlobalKey<FormState>();
  static const _cats = [
    'Clinical Records','Radiology','Pathology','Pharmacy',
    'Oncology','Cardiology','Pediatrics','Endocrinology',
    'Maternal Health','Mental Health','Nephrology','Other',
  ];

  @override
  void initState() {
    super.initState();
    _titleCtrl = TextEditingController(text: widget.suggestedTitle);
    _descCtrl = TextEditingController(
      text: 'Anonymized medical document processed via NHODP OCR. '
            '${widget.phiCount} PHI items removed. '
            'Available for research under CC BY 4.0 license.');
  }

  @override
  void dispose() { _titleCtrl.dispose(); _descCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Dialog(child: SingleChildScrollView(
      padding: const EdgeInsets.all(22),
      child: Form(key: _formKey, child: Column(mainAxisSize: MainAxisSize.min, children: [
        Row(children: [
          ShaderMask(
            shaderCallback: (b) => const LinearGradient(colors: [AppColors.gold, AppColors.goldBright]).createShader(b),
            child: const Icon(Icons.upload_rounded, color: Colors.white, size: 22)),
          const SizedBox(width: 10),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Request Publication', style: GoogleFonts.inter(fontSize: 17, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
            Text('Pending admin review', style: GoogleFonts.inter(fontSize: 11, color: AppColors.textMuted)),
          ])),
          IconButton(icon: const Icon(Icons.close_rounded, size: 18, color: AppColors.textMuted), onPressed: () => Navigator.pop(context)),
        ]),
        Container(
          margin: const EdgeInsets.symmetric(vertical: 14),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: AppColors.catHepato.withOpacity(0.07), borderRadius: BorderRadius.circular(8), border: Border.all(color: AppColors.catHepato.withOpacity(0.25))),
          child: Row(children: [
            const Icon(Icons.shield_rounded, size: 14, color: AppColors.catHepato), const SizedBox(width: 8),
            Expanded(child: Text('${widget.phiCount} PHI items removed  ·  CC BY 4.0  ·  Safe for research', style: GoogleFonts.inter(fontSize: 11, color: AppColors.catHepato))),
          ])),
        TextFormField(
          controller: _titleCtrl, style: GoogleFonts.inter(color: AppColors.textPrimary, fontSize: 13),
          decoration: const InputDecoration(labelText: 'Dataset Title *', prefixIcon: Icon(Icons.title_rounded, size: 18)),
          validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null),
        const SizedBox(height: 12),
        TextFormField(
          controller: _descCtrl, maxLines: 3, style: GoogleFonts.inter(color: AppColors.textPrimary, fontSize: 13),
          decoration: const InputDecoration(labelText: 'Description *', prefixIcon: Icon(Icons.description_rounded, size: 18), alignLabelWithHint: true),
          validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(
          value: _cat, dropdownColor: AppColors.darkSurface,
          style: GoogleFonts.inter(color: AppColors.textPrimary, fontSize: 13),
          decoration: const InputDecoration(labelText: 'Category', prefixIcon: Icon(Icons.category_rounded, size: 18)),
          items: _cats.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
          onChanged: (v) => setState(() => _cat = v ?? _cat)),
        const SizedBox(height: 18),
        Row(children: [
          Expanded(child: OutlinedButton(onPressed: () => Navigator.pop(context), child: Text('Cancel', style: GoogleFonts.inter(fontWeight: FontWeight.w600)))),
          const SizedBox(width: 12),
          Expanded(flex: 2, child: GestureDetector(
            onTap: () {
              if (_formKey.currentState!.validate()) {
                Navigator.pop(context, {
                  'title': _titleCtrl.text.trim(),
                  'description': _descCtrl.text.trim(),
                  'category': _cat,
                  'tags': ['ocr', 'anonymized', _cat.toLowerCase().replaceAll(' ', '-')],
                });
              }
            },
            child: Container(
              height: 50,
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [AppColors.goldDim, AppColors.gold, AppColors.goldLight]),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [BoxShadow(color: AppColors.gold.withOpacity(0.3), blurRadius: 14, offset: const Offset(0, 5))]),
              child: Center(child: Text('Submit for Review', style: GoogleFonts.inter(color: AppColors.obsidian, fontWeight: FontWeight.w800, fontSize: 15)))))),
        ]),
      ]))));
  }
}
