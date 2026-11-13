import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../config/app_colors.dart';
import '../services/chatbot_service.dart';

class SupportScreen extends StatefulWidget {
  const SupportScreen({Key? key}) : super(key: key);
  @override State<SupportScreen> createState() => _SupportScreenState();
}

class _SupportScreenState extends State<SupportScreen> with SingleTickerProviderStateMixin {
  late TabController _tabs;
  @override
  void initState() { super.initState(); _tabs = TabController(length: 3, vsync: this); }
  @override void dispose() { _tabs.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.obsidian,
      appBar: AppBar(
        backgroundColor: AppColors.charcoal,
        foregroundColor: AppColors.textPrimary,
        surfaceTintColor: Colors.transparent,
        scrolledUnderElevation: 0,
        title: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Support Center', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
          Text('Help · FAQ · Live Assistance', style: GoogleFonts.inter(fontSize: 10, color: AppColors.textMuted)),
        ]),
        bottom: PreferredSize(preferredSize: const Size.fromHeight(49), child: Column(children: [
          Container(height: 1, color: AppColors.border),
          TabBar(controller: _tabs, indicatorColor: AppColors.gold, indicatorWeight: 2,
            labelColor: AppColors.gold, unselectedLabelColor: AppColors.textMuted,
            labelStyle: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 12),
            dividerColor: Colors.transparent,
            tabs: const [Tab(text: 'Live Assist'), Tab(text: 'FAQ'), Tab(text: 'Contact')]),
        ])),
      ),
      body: TabBarView(controller: _tabs, children: [
        const _ChatTab(),
        const _FaqTab(),
        const _ContactTab(),
      ]),
    );
  }
}

// ─── PROFESSIONAL CHAT TAB ────────────────────────────────────
class _ChatTab extends StatefulWidget {
  const _ChatTab();
  @override State<_ChatTab> createState() => _ChatTabState();
}

class _ChatTabState extends State<_ChatTab> {
  final _ctrl         = TextEditingController();
  final _scrollCtrl   = ScrollController();
  final List<ChatMessage> _messages = [];
  bool _typing = false;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _addWelcome();
  }

  void _addWelcome() {
    _messages.add(ChatMessage(
      id: '0', role: 'assistant',
      text: 'مرحباً! Welcome to NHODP Support!\n\nI\'m your intelligent health data assistant. I can help you with:\n\n• 📊 Finding and downloading health datasets\n• 🔑 API access and documentation\n• 🏥 Hospital directory navigation\n• 💉 Vaccination schedules\n• 📋 Data request submissions\n• 🔧 Technical support\n\nWhat can I help you with today?',
      suggestions: ['Browse datasets', 'Get API access', 'Find hospitals', 'Contact human support'],
    ));
  }

  @override void dispose() { _ctrl.dispose(); _scrollCtrl.dispose(); super.dispose(); }

  Future<void> _send([String? override]) async {
    final text = (override ?? _ctrl.text).trim();
    if (text.isEmpty) return;
    _ctrl.clear();

    final userMsg = ChatMessage(id: DateTime.now().millisecondsSinceEpoch.toString(), role: 'user', text: text);
    setState(() { _messages.add(userMsg); _typing = true; });
    _scrollToBottom();

    // Simulate realistic typing delay
    final delay = 800 + (text.length * 12).clamp(0, 1500);
    await Future.delayed(Duration(milliseconds: delay));

    if (!mounted) return;
    final reply = await ChatbotService.sendMessage(text, _messages);

    setState(() { _messages.add(reply); _typing = false; });
    _scrollToBottom();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(_scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      // Online indicator
      Container(
        color: AppColors.inkBlack,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
        child: Row(children: [
          Container(width: 8, height: 8, decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.catHepato,
            boxShadow: [BoxShadow(color: AppColors.catHepato.withOpacity(0.5), blurRadius: 6)])),
          const SizedBox(width: 8),
          Text('NHODP Support Assistant', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.catHepato)),
          const Spacer(),
          Text('Intelligent · Context-Aware', style: GoogleFonts.inter(fontSize: 10, color: AppColors.textMuted)),
        ])),
      Container(height: 1, color: AppColors.border),
      // Messages
      Expanded(child: ListView.builder(
        controller: _scrollCtrl,
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
        itemCount: _messages.length + (_typing ? 1 : 0),
        itemBuilder: (_, i) {
          if (_typing && i == _messages.length) {
            return const _TypingBubble().animate().fadeIn();
          }
          final msg = _messages[i];
          return _MessageBubble(msg: msg, onSuggestion: _send).animate().fadeIn().slideY(begin: 0.1);
        })),
      // Input
      Container(
        color: AppColors.charcoal,
        padding: const EdgeInsets.fromLTRB(14, 10, 14, 16),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Row(children: [
            Expanded(child: TextField(
              controller: _ctrl,
              style: GoogleFonts.inter(color: AppColors.textPrimary, fontSize: 13),
              maxLines: null, textInputAction: TextInputAction.send,
              onSubmitted: (_) => _send(),
              decoration: InputDecoration(
                hintText: 'Ask me anything about NHODP…',
                hintStyle: GoogleFonts.inter(color: AppColors.textMuted, fontSize: 13),
                filled: true, fillColor: AppColors.elevated,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: const BorderSide(color: AppColors.border)),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: const BorderSide(color: AppColors.border)),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: const BorderSide(color: AppColors.gold, width: 1.5))))),
            const SizedBox(width: 10),
            GestureDetector(
              onTap: _send,
              child: Container(width: 44, height: 44,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [AppColors.goldDim, AppColors.gold]),
                  shape: BoxShape.circle,
                  boxShadow: [BoxShadow(color: AppColors.gold.withOpacity(0.3), blurRadius: 10)]),
                child: const Icon(Icons.send_rounded, color: AppColors.obsidian, size: 20))),
          ]),
          const SizedBox(height: 6),
          Text('Powered by NHODP AI · Context-aware · Bilingual (EN/AR)',
            style: GoogleFonts.inter(fontSize: 9, color: AppColors.textMuted.withOpacity(0.6))),
        ])),
    ]);
  }
}

// ─── MESSAGE BUBBLE ───────────────────────────────────────────
class _MessageBubble extends StatelessWidget {
  final ChatMessage msg;
  final ValueChanged<String> onSuggestion;
  const _MessageBubble({required this.msg, required this.onSuggestion});

  @override
  Widget build(BuildContext context) {
    final isUser = msg.isUser;
    final time = '${msg.timestamp.hour.toString().padLeft(2,'0')}:${msg.timestamp.minute.toString().padLeft(2,'0')}';

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.85),
        child: Column(crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start, children: [
          // Avatar + name
          if (!isUser) Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 4),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Container(width: 22, height: 22, decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(colors: [AppColors.goldDim, AppColors.gold])),
                child: const Icon(Icons.support_agent_rounded, size: 13, color: AppColors.obsidian)),
              const SizedBox(width: 6),
              Text('NHODP Assistant', style: GoogleFonts.inter(fontSize: 10, color: AppColors.textMuted, fontWeight: FontWeight.w600)),
            ])),
          // Main bubble
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isUser ? AppColors.gold : AppColors.inkBlack,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(14), topRight: const Radius.circular(14),
                bottomLeft: isUser ? const Radius.circular(14) : const Radius.circular(4),
                bottomRight: isUser ? const Radius.circular(4) : const Radius.circular(14)),
              border: isUser ? null : Border.all(color: AppColors.border),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 8, offset: const Offset(0, 2))]),
            child: Text(msg.text,
              style: GoogleFonts.inter(fontSize: 13, color: isUser ? AppColors.obsidian : AppColors.textPrimary, height: 1.55))),
          // Confirmation box
          if (!isUser && msg.confirmation != null) Container(
            margin: const EdgeInsets.only(top: 6),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.gold.withOpacity(0.07),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.gold.withOpacity(0.25))),
            child: Row(children: [
              const Icon(Icons.help_outline_rounded, size: 13, color: AppColors.gold),
              const SizedBox(width: 7),
              Expanded(child: Text(msg.confirmation!, style: GoogleFonts.inter(fontSize: 11.5, color: AppColors.gold, fontStyle: FontStyle.italic))),
            ])),
          // Suggestion chips
          if (!isUser && msg.suggestions.isNotEmpty) Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Wrap(spacing: 6, runSpacing: 6, children: msg.suggestions.map((s) =>
              GestureDetector(
                onTap: () => onSuggestion(s),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.elevated,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.gold.withOpacity(0.3))),
                  child: Text(s, style: GoogleFonts.inter(fontSize: 11, color: AppColors.gold, fontWeight: FontWeight.w600))))).toList())),
          // Timestamp
          Padding(
            padding: const EdgeInsets.only(top: 3, left: 4, right: 4),
            child: Text(time, style: GoogleFonts.inter(fontSize: 9, color: AppColors.textMuted))),
        ])));
  }
}

// ─── TYPING INDICATOR ─────────────────────────────────────────
class _TypingBubble extends StatefulWidget {
  const _TypingBubble();
  @override State<_TypingBubble> createState() => _TypingBubbleState();
}

class _TypingBubbleState extends State<_TypingBubble> with TickerProviderStateMixin {
  late List<AnimationController> _ctrls;
  @override
  void initState() {
    super.initState();
    _ctrls = List.generate(3, (i) => AnimationController(
      vsync: this, duration: const Duration(milliseconds: 500))
      ..repeat(reverse: true, period: Duration(milliseconds: 500 + i * 160)));
  }
  @override void dispose() { for (final c in _ctrls) c.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) => Align(alignment: Alignment.centerLeft,
    child: Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(color: AppColors.inkBlack, borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(14), topRight: Radius.circular(14), bottomRight: Radius.circular(14), bottomLeft: Radius.circular(4)),
        border: Border.all(color: AppColors.border)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Text('Thinking', style: GoogleFonts.inter(fontSize: 11, color: AppColors.textMuted)),
        const SizedBox(width: 8),
        ...List.generate(3, (i) => AnimatedBuilder(
          animation: _ctrls[i],
          builder: (_, __) => Container(
            width: 5, height: 5 + _ctrls[i].value * 5,
            margin: EdgeInsets.only(right: i < 2 ? 3 : 0),
            decoration: BoxDecoration(color: AppColors.gold.withOpacity(0.5 + _ctrls[i].value * 0.5), borderRadius: BorderRadius.circular(3))))),
      ])));
}

// ─── FAQ TAB ──────────────────────────────────────────────────
class _FaqTab extends StatelessWidget {
  const _FaqTab();

  static const _faqs = [
    ['How do I download a dataset?',
     'Go to the Datasets section from the home menu or bottom navigation. Find your dataset using search or category filters. Tap the dataset card to open the detail view, then tap "Download". All public datasets are free — no login required.'],
    ['How do I access the NHODP API?',
     'Visit Data Request & API from the Portal Features section. You can generate a demo API key immediately for 100 requests/hour. For production access (1000+ req/hour), register and submit an API access request form. Base URL: http://localhost:8002 for datasets.'],
    ['How is patient data protected?',
     'All datasets are fully anonymized using our 11-type PHI detection pipeline (OCR Service). Types removed: names, MRNs, dates, phone numbers, addresses, emails, national IDs, insurance numbers, vehicle plates, biometric IDs, and IP addresses. We comply with Egyptian Data Protection Law No. 151/2020.'],
    ['How do I submit a custom data request?',
     'Use the Data Request section (Portal Features → Data Request & API). Fill in your institution, research purpose, required variables, and time period. Our team responds in 5–10 business days. For urgent requests, email: data@nhodp.gov.eg'],
    ['What is the OCR service?',
     'The OCR service extracts text from Arabic and English medical documents (PDF/images), detects and removes Protected Health Information automatically, and lets you publish anonymized documents as new research datasets available to the global research community.'],
    ['How do I find hospitals in my governorate?',
     'Use the Hospital Directory in the Clinical Services section (visible on the home screen as a 2×2 services grid). Filter by governorate, specialty (Cardiology, Oncology, etc.), ICU availability, or emergency services. Each card shows bed count, phone number, and address.'],
    ['Where can I get vaccination schedules?',
     'Go to the Vaccination Center (Clinical Services section on home). Select your age group: Child, Adolescent, Adult, Elderly, or Pregnant. You will see mandatory and optional vaccines, dosing schedules, and current national alerts. Coverage charts show Egypt vs. WHO targets.'],
    ['How often is data updated?',
     'COVID-19: weekly | Disease surveillance: monthly | Vital statistics: annually | Hospital capacity: quarterly. Each dataset card shows the "Last Updated" date. When the backend is connected, all data is live from the MOHP API.'],
    ['Can I use NHODP data for academic research?',
     'Yes! All datasets are published under CC BY 4.0 license — free for academic, commercial, and research use with attribution. Cite as: "NHODP, Ministry of Health & Population, Arab Republic of Egypt." For unpublished data, submit a data request.'],
    ['I found a bug or error — how do I report it?',
     'Email tech@nhodp.gov.eg with a description of the issue, the screen it occurred on, and your device/browser. Include a screenshot if possible. Response time: 1–3 business days.'],
  ];

  @override
  Widget build(BuildContext context) => ListView.builder(
    padding: const EdgeInsets.all(14),
    itemCount: _faqs.length,
    itemBuilder: (_, i) => Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(color: AppColors.inkBlack, borderRadius: BorderRadius.circular(10), border: Border.all(color: AppColors.border)),
      child: Theme(data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.fromLTRB(14, 6, 14, 6),
          childrenPadding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
          iconColor: AppColors.gold, collapsedIconColor: AppColors.textMuted,
          title: Text(_faqs[i][0], style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 13, color: AppColors.textPrimary)),
          children: [
            Container(height: 1, color: AppColors.border, margin: const EdgeInsets.only(bottom: 10)),
            Text(_faqs[i][1], style: GoogleFonts.inter(fontSize: 12.5, color: AppColors.textSecondary, height: 1.65)),
          ])).animate(delay: (i * 35).ms).fadeIn()));
}

// ─── CONTACT TAB ──────────────────────────────────────────────
class _ContactTab extends StatelessWidget {
  const _ContactTab();
  static const _contacts = [
    {'title':'Data Inquiries','email':'data@nhodp.gov.eg','phone':null,'hours':'Sun–Thu 8AM–4PM','icon':Icons.dataset_rounded,'color':AppColors.catInfectious,'desc':'For dataset access, custom data requests, and licensing questions.'},
    {'title':'Technical Support','email':'tech@nhodp.gov.eg','phone':null,'hours':'Sun–Thu 9AM–3PM','icon':Icons.support_agent_rounded,'color':AppColors.catHepato,'desc':'Platform bugs, API issues, account problems, and integration help.'},
    {'title':'Medical Hotline','email':null,'phone':'15999','hours':'24/7 available','icon':Icons.local_hospital_rounded,'color':AppColors.catCardio,'desc':'Egypt national health information and referral service.'},
    {'title':'Emergency Services','email':null,'phone':'123','hours':'24/7 emergency','icon':Icons.emergency_rounded,'color':AppColors.catOncology,'desc':'Medical emergency, ambulance dispatch.'},
    {'title':'Research Partnerships','email':'research@nhodp.gov.eg','phone':null,'hours':'Sun–Thu 8AM–2PM','icon':Icons.science_rounded,'color':AppColors.catMental,'desc':'Academic collaborations, joint publications, and data sharing agreements.'},
    {'title':'Data Governance','email':'policy@nhodp.gov.eg','phone':null,'hours':'Sun–Thu 9AM–3PM','icon':Icons.gavel_rounded,'color':AppColors.catNutrition,'desc':'Data usage policy, compliance, GDPR/Egyptian Data Law questions.'},
  ];

  @override
  Widget build(BuildContext context) => ListView(padding: const EdgeInsets.all(14), children: [
    // Header banner
    Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.gold.withOpacity(0.07),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.gold.withOpacity(0.25))),
      child: Row(children: [
        Container(width: 22, height: 15, decoration: BoxDecoration(borderRadius: BorderRadius.circular(2)),
          child: Column(children: [
            Expanded(child: Container(color: const Color(0xFFCE1126))),
            Expanded(child: Container(color: Colors.white)),
            Expanded(child: Container(color: Colors.black)),
          ])),
        const SizedBox(width: 10),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('NHODP Support Channels', style: GoogleFonts.inter(fontWeight: FontWeight.w800, fontSize: 13, color: AppColors.gold)),
          Text('Ministry of Health & Population · Arab Republic of Egypt', style: GoogleFonts.inter(fontSize: 10, color: AppColors.textMuted)),
        ])),
      ])).animate().fadeIn(),
    ..._contacts.asMap().entries.map((e) {
      final i = e.key; final c = e.value;
      final color = c['color'] as Color;
      return Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: AppColors.inkBlack, borderRadius: BorderRadius.circular(10), border: Border.all(color: AppColors.border)),
        child: Row(children: [
          Container(padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(9), border: Border.all(color: color.withOpacity(0.25))),
            child: Icon(c['icon'] as IconData, size: 18, color: color)),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(c['title'] as String, style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 13, color: AppColors.textPrimary)),
            const SizedBox(height: 2),
            Text(c['desc'] as String, style: GoogleFonts.inter(fontSize: 11, color: AppColors.textSecondary, height: 1.4), maxLines: 2, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 5),
            if (c['email'] != null) GestureDetector(
              onTap: () => Clipboard.setData(ClipboardData(text: c['email'] as String)),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(Icons.email_rounded, size: 12, color: color),
                const SizedBox(width: 5),
                Text(c['email'] as String, style: GoogleFonts.inter(fontSize: 12, color: color, fontWeight: FontWeight.w600)),
                const SizedBox(width: 5),
                Icon(Icons.copy_rounded, size: 10, color: color.withOpacity(0.5)),
              ])),
            if (c['phone'] != null) Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(Icons.phone_rounded, size: 12, color: color),
              const SizedBox(width: 5),
              Text(c['phone'] as String, style: GoogleFonts.inter(fontSize: 17, fontWeight: FontWeight.w900, color: color)),
            ]),
            const SizedBox(height: 3),
            Text(c['hours'] as String, style: GoogleFonts.inter(fontSize: 10, color: AppColors.textMuted)),
          ])),
        ])).animate(delay: (i * 50).ms).fadeIn();
    }),
  ]);
}
