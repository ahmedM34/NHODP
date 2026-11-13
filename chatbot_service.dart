import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';
import '../config/app_colors.dart';

/// Chat message model
class ChatMessage {
  final String id;
  final String role; // 'user' | 'assistant'
  final String text;
  final String? confirmation;
  final List<String> suggestions;
  final DateTime timestamp;

  ChatMessage({
    required this.id,
    required this.role,
    required this.text,
    this.confirmation,
    this.suggestions = const [],
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  bool get isUser => role == 'user';
}

/// Smart chatbot service — connects to FastAPI or falls back to local intelligence
class ChatbotService {
  static const _base = String.fromEnvironment('API_BASE_URL', defaultValue: 'http://localhost');
  static const _chatUrl = '$_base:8004/chat';

  /// Send a message and get a response
  static Future<ChatMessage> sendMessage(String text, List<ChatMessage> history) async {
    // Try API first
    try {
      final r = await http.post(Uri.parse(_chatUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'message': text,
          'history': history.map((m) => {'role': m.role, 'content': m.text}).toList(),
        })).timeout(const Duration(seconds: 8));
      if (r.statusCode == 200) {
        final d = jsonDecode(r.body) as Map<String, dynamic>;
        return ChatMessage(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          role: 'assistant',
          text: d['answer']?.toString() ?? _localResponse(text, history),
          confirmation: d['confirmation']?.toString(),
          suggestions: (d['suggestions'] as List?)?.cast<String>() ?? [],
        );
      }
    } catch (_) {}
    // Fallback: local intelligent response
    return _localIntelligentResponse(text, history);
  }

  /// Local intelligent chatbot — intent-based with context awareness
  static ChatMessage _localIntelligentResponse(String input, List<ChatMessage> history) {
    final text   = input.toLowerCase().trim();
    final lastBot = history.where((m) => !m.isUser).lastOrNull?.text ?? '';

    // Intent detection
    final intent = _detectIntent(text);

    String answer;
    String? confirmation;
    List<String> suggestions = [];

    switch (intent) {
      case 'greeting':
        answer = 'مرحباً بك في بوابة البيانات الصحية المفتوحة! Welcome to NHODP!\n\nI can help you with:\n• 📊 Finding and downloading health datasets\n• 🔑 API access and documentation\n• 🏥 Hospital and vaccination information\n• 📋 Data request submissions\n• 🔧 Technical support';
        suggestions = ['Browse datasets', 'Get API access', 'Find hospitals', 'Submit data request'];
        break;

      case 'dataset':
        answer = 'NHODP hosts **12 open health datasets** covering:\n\n• Oncology, Infectious Disease, Cardiology\n• Maternal Health, Mental Health, Pediatrics\n• Hepatology, Nutrition, Health Infrastructure\n\nAll datasets are:\n✅ Free under CC BY 4.0 license\n✅ Anonymized (PHI removed)\n✅ Available in CSV, JSON, or XLSX format\n\n**How to access:**\n1. Go to the Datasets section from the home menu\n2. Use search or category filter to find your dataset\n3. Tap "Download" on the dataset card\n4. No registration required for public datasets';
        confirmation = 'Just to confirm: you need help finding and downloading health datasets, correct?';
        suggestions = ['How to download', 'Available formats', 'Request custom data', 'API access'];
        break;

      case 'api':
        answer = 'The NHODP REST API is available at:\n📡 `http://localhost:8002` (Datasets)\n📡 `http://localhost:8005` (Analytics)\n📡 `http://localhost:8001` (Auth)\n\n**Quick start:**\n```\nGET /datasets\nGET /datasets/{id}\nGET /stats/overview\nGET /stats/health-indicators\n```\n\n**Authentication:**\nPublic endpoints: No key needed\nPrivate endpoints: Bearer token (register first)\n\n**Rate limit:** 100 req/hour (public) · 1000 req/hour (registered)';
        confirmation = 'To confirm: you want to access the NHODP API. Are you building a research application or need data programmatically?';
        suggestions = ['Register for API key', 'View endpoints', 'Download API docs', 'Report API issue'];
        break;

      case 'hospital':
        answer = 'The **Hospital Directory** contains 20+ major government hospitals across Egypt, including:\n\n🏥 Kasr El Aini Hospital (Cairo) — 3,200 beds\n🏥 Mansoura University Hospital — 2,800 beds\n🏥 Alexandria University Hospital — 2,100 beds\n\n**Filter by:**\n• Governorate (27 options)\n• Specialty (Oncology, Cardiology, etc.)\n• ICU availability\n• Emergency services\n\n**To find a hospital:**\nHome → Services Grid → Hospital Directory\n\n**Emergency:** Call 123 (ambulance)';
        confirmation = 'Just to confirm: you need to find a specific hospital in Egypt, correct?';
        suggestions = ['Find ICU hospital', 'Emergency hospitals', 'Search by specialty', 'Hospital in my city'];
        break;

      case 'vaccine':
        answer = 'The **Vaccination Center** shows complete schedules organized by age group:\n\n👶 **Children (0–9):** BCG, DTP, Polio, MMR, PCV13\n🧒 **Adolescents:** HPV, Tdap booster, Meningococcal\n🧑 **Adults:** Influenza (annual), COVID-19, Td booster\n👴 **Elderly:** High-dose influenza, Pneumococcal, Shingrix\n🤰 **Pregnant:** Tdap (27–36 wks), Inactivated influenza\n\n**Coverage status:**\nDTP3: 93.2% ✅ | Measles: 88.5% ⚠️ | COVID booster: 42.1% ⬇️';
        confirmation = 'To confirm: you need vaccination schedule information for Egypt, correct?';
        suggestions = ['Child vaccines', 'Adult vaccines', 'COVID booster', 'Hajj vaccines'];
        break;

      case 'login':
      case 'account':
        answer = 'To sign in to your NHODP account:\n\n1. Tap **Sign In** in the top-right corner (or app bar)\n2. Enter your email and password\n3. Tap the **Sign In** button\n\n**Demo credentials for testing:**\n📧 Email: `admin@nhodp.gov.eg`\n🔑 Password: `Admin@2026`\n\n**Forgot your password?**\nCurrently, password reset is done by contacting: data@nhodp.gov.eg\n\n**New user?** Tap "Register" to create a free account.';
        confirmation = 'To confirm: you need help signing into your NHODP account, correct?';
        suggestions = ['Create account', 'Forgot password', 'Contact support', 'Demo credentials'];
        break;

      case 'ocr':
        answer = 'The **OCR Service** lets you:\n\n1. 📤 Upload a scanned health document (PDF/image)\n2. 🔍 AI extracts text (Arabic + English)\n3. 🛡️ Detects and removes 11 types of PHI automatically\n4. ✅ You review the anonymized result\n5. 📊 Optionally publish as a new research dataset\n\n**Supported PHI types removed:**\nNames, MRNs, dates, phone numbers, addresses, emails, national IDs, insurance numbers, vehicle plates, biometric IDs, and IP addresses.\n\n**To use:** Home → Quick Access → OCR Service';
        confirmation = 'To confirm: you want to anonymize a health document using OCR, correct?';
        suggestions = ['Upload a document', 'Learn about PHI', 'Publish as dataset', 'View OCR jobs'];
        break;

      case 'data_request':
        answer = 'To submit a **Custom Data Request:**\n\n1. Go to: Home → Portal Features → Data Request & API\n2. Fill out the request form:\n   - Your institution and role\n   - Data variables needed\n   - Time period and granularity\n   - Research purpose\n3. Submit — our data team responds in **5–10 business days**\n\n**For urgent requests:**\n📧 data@nhodp.gov.eg\n\n**What we can provide:**\n• Governorate-level disaggregation\n• Multi-year longitudinal datasets\n• Linked datasets across health domains';
        confirmation = 'To confirm: you want to request a custom health dataset from MOHP, correct?';
        suggestions = ['Fill data request form', 'Contact data team', 'API alternative', 'View existing datasets'];
        break;

      case 'contact':
        answer = 'NHODP Contact Directory:\n\n📧 **Data Inquiries:** data@nhodp.gov.eg\n📧 **Technical Support:** tech@nhodp.gov.eg\n📧 **Research Partnerships:** research@nhodp.gov.eg\n📞 **Medical Hotline:** 15999 (24/7)\n🚨 **Emergency:** 123\n\n**Office hours:**\nSunday–Thursday: 8:00 AM – 4:00 PM\n\n**Ministry of Health & Population**\nArab Republic of Egypt, Cairo';
        suggestions = ['Email data team', 'Technical issue', 'Medical emergency', 'Partnership inquiry'];
        break;

      case 'unclear':
      default:
        // Check if it's a follow-up
        if (history.length > 2 && lastBot.isNotEmpty) {
          answer = 'I\'m not sure I fully understood. Could you clarify what you need?\n\nFor example, are you asking about:\n• **A)** Finding or downloading a dataset\n• **B)** Technical issues with the platform\n• **C)** Medical information or hospitals\n• **D)** Something else entirely\n\nPlease reply with A, B, C, or D — or describe your question more specifically.';
          suggestions = ['Datasets', 'Technical issue', 'Hospitals', 'Something else'];
        } else {
          answer = 'I didn\'t fully understand your question. Could you try rephrasing it?\n\nI can help you with:\n• 📊 Health datasets and downloads\n• 🔑 API documentation and access\n• 🏥 Hospital directory\n• 💉 Vaccination schedules\n• 📋 Data requests\n• 🔧 Technical support';
          confirmation = 'Can you clarify what you\'re looking for?';
          suggestions = ['Datasets help', 'API access', 'Find hospitals', 'Contact support'];
        }
        break;
    }

    return ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      role: 'assistant',
      text: answer,
      confirmation: confirmation,
      suggestions: suggestions,
    );
  }

  static String _detectIntent(String text) {
    if (RegExp(r'\b(hi|hello|hey|مرحبا|السلام|صباح|مساء|ahlan)\b').hasMatch(text)) return 'greeting';
    if (RegExp(r'\b(dataset|data|download|csv|json|xlsx|catalog|بيانات|تحميل)\b').hasMatch(text)) return 'dataset';
    if (RegExp(r'\b(api|endpoint|key|token|request|rest|curl|swagger)\b').hasMatch(text)) return 'api';
    if (RegExp(r'\b(hospital|clinic|icu|bed|emergency|مستشفى|طوارئ|عناية)\b').hasMatch(text)) return 'hospital';
    if (RegExp(r'\b(vaccine|vaccination|immunization|لقاح|تطعيم|حقنة)\b').hasMatch(text)) return 'vaccine';
    if (RegExp(r'\b(login|sign.?in|password|account|دخول|حساب|كلمة.?سر)\b').hasMatch(text)) return 'login';
    if (RegExp(r'\b(account|register|profile|user|تسجيل|مستخدم)\b').hasMatch(text)) return 'account';
    if (RegExp(r'\b(ocr|scan|document|anonymi|phi|وثيقة|مسح)\b').hasMatch(text)) return 'ocr';
    if (RegExp(r'\b(request|custom|specific|طلب|مخصص|بيانات.?مخصصة)\b').hasMatch(text)) return 'data_request';
    if (RegExp(r'\b(contact|email|phone|support|help|مساعدة|تواصل|اتصال)\b').hasMatch(text)) return 'contact';
    return 'unclear';
  }

  static String _localResponse(String text, List<ChatMessage> history) =>
    _localIntelligentResponse(text, history).text;
}
