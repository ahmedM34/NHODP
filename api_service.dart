import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

/// Central API client for NHODP.
///
/// URL resolution priority:
///   1. Compile-time --dart-define=API_BASE_URL=https://…
///   2. Runtime override stored in SharedPreferences (key: api_base_url)
///   3. Default: http://localhost  (direct service ports when running locally)
class ApiService {
  // Compile-time override:  flutter run --dart-define=API_BASE_URL=http://10.0.0.5
  /// Synchronous base for URL display only — not for actual HTTP calls
  static String get ocrBaseSync => (_runtimeBase ?? _compiledBase) + ':8003';

  static const String _compiledBase =
      String.fromEnvironment('API_BASE_URL', defaultValue: 'http://localhost');

  static String? _runtimeBase;

  static Future<String> get _base async {
    if (_runtimeBase != null) return _runtimeBase!;
    final prefs = await SharedPreferences.getInstance();
    _runtimeBase = prefs.getString('api_base_url') ?? _compiledBase;
    return _runtimeBase!;
  }

  /// Allow users to override the backend host at runtime (settings screen, etc.)
  static Future<void> setBaseUrl(String url) async {
    _runtimeBase = url.trimRight().replaceAll(RegExp(r'/$'), '');
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('api_base_url', _runtimeBase!);
  }

  static Future<String> get authBase      async => '${await _base}:8001';
  static Future<String> get datasetBase   async => '${await _base}:8002';
  static Future<String> get ocrBase       async => '${await _base}:8003';
  static Future<String> get contentBase   async => '${await _base}:8004';
  static Future<String> get analyticsBase async => '${await _base}:8005';

  static Future<String?> _token() async =>
      (await SharedPreferences.getInstance()).getString('auth_token');

  static Future<Map<String, String>> _headers({bool auth = false}) async {
    final h = {'Content-Type': 'application/json'};
    if (auth) {
      final t = await _token();
      if (t != null) h['Authorization'] = 'Bearer $t';
    }
    return h;
  }

  // ── AUTH ──────────────────────────────────────────────────────
  static Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final r = await http.post(
        Uri.parse('${await authBase}/auth/login'),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {'username': email, 'password': password},
      ).timeout(const Duration(seconds: 10));
      final d = jsonDecode(r.body) as Map<String, dynamic>;
      return r.statusCode == 200
          ? {'success': true, ...d}
          : {'success': false, 'detail': d['detail'] ?? 'Login failed'};
    } catch (_) {
      return {'success': false, 'detail': 'Cannot reach backend. Is it running?'};
    }
  }

  static Future<Map<String, dynamic>> register(Map<String, dynamic> data) async {
    try {
      final r = await http.post(
        Uri.parse('${await authBase}/auth/register'),
        headers: await _headers(),
        body: jsonEncode(data),
      ).timeout(const Duration(seconds: 10));
      final d = jsonDecode(r.body) as Map<String, dynamic>;
      return r.statusCode == 201
          ? {'success': true, ...d}
          : {'success': false, 'detail': d['detail'] ?? 'Registration failed'};
    } catch (_) {
      return {'success': false, 'detail': 'Cannot reach backend'};
    }
  }

  static Future<Map<String, dynamic>> getCurrentUser() async {
    final r = await http.get(
      Uri.parse('${await authBase}/users/me'),
      headers: await _headers(auth: true),
    ).timeout(const Duration(seconds: 8));
    if (r.statusCode == 200) return jsonDecode(r.body);
    throw Exception('Unauthorized');
  }

  static Future<Map<String, dynamic>> getUserStats() async {
    try {
      final r = await http.get(Uri.parse('${await authBase}/stats/users'))
          .timeout(const Duration(seconds: 6));
      return r.statusCode == 200 ? jsonDecode(r.body) : {};
    } catch (_) { return {}; }
  }

  // ── DATASETS ──────────────────────────────────────────────────
  static Future<List<dynamic>> getDatasets({
    int skip = 0, int limit = 50,
    String? category, String? search,
  }) async {
    try {
      var p = 'skip=$skip&limit=$limit';
      if (category != null) p += '&category=${Uri.encodeComponent(category)}';
      if (search != null && search.isNotEmpty) p += '&search=${Uri.encodeComponent(search)}';
      final r = await http.get(Uri.parse('${await datasetBase}/datasets?$p'))
          .timeout(const Duration(seconds: 10));
      return r.statusCode == 200 ? jsonDecode(utf8.decode(r.bodyBytes)) : [];
    } catch (_) { return []; }
  }

  static Future<Map<String, dynamic>> getDatasetById(String id) async {
    try {
      final r = await http.get(Uri.parse('${await datasetBase}/datasets/$id'))
          .timeout(const Duration(seconds: 8));
      return r.statusCode == 200 ? jsonDecode(r.body) : {};
    } catch (_) { return {}; }
  }

  static Future<Map<String, dynamic>> getDatasetCategories() async {
    try {
      final r = await http.get(Uri.parse('${await datasetBase}/categories'))
          .timeout(const Duration(seconds: 6));
      return r.statusCode == 200 ? jsonDecode(r.body) : {'categories': []};
    } catch (_) { return {'categories': []}; }
  }

  static Future<Map<String, dynamic>> getDatasetStats() async {
    try {
      final r = await http.get(Uri.parse('${await datasetBase}/stats'))
          .timeout(const Duration(seconds: 6));
      return r.statusCode == 200 ? jsonDecode(r.body) : {};
    } catch (_) { return {}; }
  }

  static Future<Map<String, dynamic>> searchDatasets(String q) async {
    try {
      final r = await http.get(Uri.parse('${await datasetBase}/search?q=${Uri.encodeComponent(q)}'))
          .timeout(const Duration(seconds: 8));
      return r.statusCode == 200 ? jsonDecode(r.body) : {'results': []};
    } catch (_) { return {'results': []}; }
  }

  // ── CONTENT ───────────────────────────────────────────────────
  static Future<List<dynamic>> getArticles({int limit = 20, String? category}) async {
    try {
      var url = '${await contentBase}/articles?limit=$limit';
      if (category != null) url += '&category=${Uri.encodeComponent(category)}';
      final r = await http.get(Uri.parse(url)).timeout(const Duration(seconds: 8));
      return r.statusCode == 200 ? jsonDecode(utf8.decode(r.bodyBytes)) : [];
    } catch (_) { return []; }
  }

  static Future<List<dynamic>> getLatestArticles({int limit = 5}) async {
    try {
      final r = await http.get(Uri.parse('${await contentBase}/latest?limit=$limit'))
          .timeout(const Duration(seconds: 6));
      return r.statusCode == 200 ? jsonDecode(utf8.decode(r.bodyBytes)) : [];
    } catch (_) { return []; }
  }

  static Future<List<dynamic>> getTrendingArticles({int limit = 5}) async {
    try {
      final r = await http.get(Uri.parse('${await contentBase}/trending?limit=$limit'))
          .timeout(const Duration(seconds: 6));
      return r.statusCode == 200 ? jsonDecode(utf8.decode(r.bodyBytes)) : [];
    } catch (_) { return []; }
  }

  // ── ANALYTICS ─────────────────────────────────────────────────
  static Future<Map<String, dynamic>> getAllAnalytics() async {
    try {
      final r = await http.get(Uri.parse('${await analyticsBase}/stats/standalone'))
          .timeout(const Duration(seconds: 8));
      return r.statusCode == 200 ? jsonDecode(r.body) as Map<String, dynamic> : {};
    } catch (_) { return {}; }
  }

  static Future<Map<String, dynamic>> getOverview() async {
    try {
      final all = await getAllAnalytics();
      if (all.containsKey('overview')) return all['overview'] as Map<String, dynamic>;
      final r = await http.get(Uri.parse('${await analyticsBase}/stats/overview'))
          .timeout(const Duration(seconds: 6));
      return r.statusCode == 200 ? jsonDecode(r.body) as Map<String, dynamic> : {};
    } catch (_) { return {}; }
  }

  static Future<Map<String, dynamic>> getHealthStatus() async {
    try {
      final r = await http.get(Uri.parse('${await analyticsBase}/stats/service-health'))
          .timeout(const Duration(seconds: 6));
      return r.statusCode == 200 ? jsonDecode(r.body) as Map<String, dynamic> : {};
    } catch (_) { return {}; }
  }

  // ── HEALTH CHECKS (per service) ───────────────────────────────
  static Future<bool> pingAuth() async {
    try { final r = await http.get(Uri.parse('${await authBase}/health')).timeout(const Duration(seconds: 4)); return r.statusCode == 200; }
    catch (_) { return false; }
  }

  static Future<bool> pingDataset() async {
    try { final r = await http.get(Uri.parse('${await datasetBase}/health')).timeout(const Duration(seconds: 4)); return r.statusCode == 200; }
    catch (_) { return false; }
  }

  static Future<bool> pingOcr() async {
    try { final r = await http.get(Uri.parse('${await ocrBase}/health')).timeout(const Duration(seconds: 4)); return r.statusCode == 200; }
    catch (_) { return false; }
  }

  static Future<bool> pingContent() async {
    try { final r = await http.get(Uri.parse('${await contentBase}/health')).timeout(const Duration(seconds: 4)); return r.statusCode == 200; }
    catch (_) { return false; }
  }

  static Future<bool> pingAnalytics() async {
    try { final r = await http.get(Uri.parse('${await analyticsBase}/health')).timeout(const Duration(seconds: 4)); return r.statusCode == 200; }
    catch (_) { return false; }
  }

  // ── OCR UPLOAD ────────────────────────────────────────────────
  static Future<Map<String, dynamic>> uploadOcrFile({
    required List<int> fileBytes,
    required String fileName,
    required String mimeType,
    bool autoPublish = false,
    String? datasetTitle,
    String? datasetCategory,
  }) async {
    try {
      final base = await ocrBase;
      final params = StringBuffer('?auto_publish=$autoPublish');
      if (datasetTitle != null) params.write('&dataset_title=${Uri.encodeComponent(datasetTitle)}');
      if (datasetCategory != null) params.write('&dataset_category=${Uri.encodeComponent(datasetCategory)}');

      final req = http.MultipartRequest('POST', Uri.parse('$base/ocr/upload$params'));
      req.files.add(http.MultipartFile.fromBytes(
        'file', fileBytes, filename: fileName,
        contentType: http.MediaType.parse(mimeType),
      ));
      final streamed = await req.send().timeout(const Duration(seconds: 90));
      final body = await streamed.stream.bytesToString();
      if (streamed.statusCode == 200) return jsonDecode(body) as Map<String, dynamic>;
      return {'error': 'HTTP ${streamed.statusCode}', 'detail': body};
    } catch (e) {
      return {'error': e.toString()};
    }
  }

  static Future<Map<String, dynamic>> publishOcrJob({
    required String jobId,
    required String title,
    required String description,
    required String category,
    List<String> tags = const [],
  }) async {
    try {
      final r = await http.post(
        Uri.parse('${await ocrBase}/ocr/jobs/$jobId/publish'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'title': title, 'description': description, 'category': category, 'tags': tags}),
      ).timeout(const Duration(seconds: 15));
      final d = jsonDecode(r.body) as Map<String, dynamic>;
      return r.statusCode == 200 ? {'success': true, ...d} : {'success': false, 'detail': d['detail'] ?? 'Failed'};
    } catch (e) { return {'success': false, 'detail': e.toString()}; }
  }

  static Future<Map<String, dynamic>> getOcrJob(String jobId) async {
    try {
      final r = await http.get(Uri.parse('${await ocrBase}/ocr/jobs/$jobId'))
          .timeout(const Duration(seconds: 10));
      return r.statusCode == 200 ? jsonDecode(r.body) as Map<String, dynamic> : {};
    } catch (_) { return {}; }
  }

  static Future<Map<String, dynamic>> listOcrDerivedDatasets({int skip = 0, int limit = 20}) async {
    try {
      final r = await http.get(Uri.parse('${await datasetBase}/datasets/ocr-derived?skip=$skip&limit=$limit'))
          .timeout(const Duration(seconds: 8));
      return r.statusCode == 200 ? jsonDecode(r.body) : {'total': 0, 'datasets': []};
    } catch (_) { return {'total': 0, 'datasets': []}; }
  }

  static Future<Map<String, dynamic>> saveOcrAsDataset({
    required String ocrJobId,
    required String title,
    required String description,
    required String category,
    String anonymizedText = '',
    int phiCount = 0,
  }) async {
    try {
      final r = await http.post(
        Uri.parse('${await datasetBase}/datasets/from-ocr'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'ocr_job_id': ocrJobId, 'title': title,
          'description': description, 'category': category,
          'anonymized_text': anonymizedText, 'phi_count': phiCount,
        }),
      ).timeout(const Duration(seconds: 15));
      final d = jsonDecode(r.body) as Map<String, dynamic>;
      return r.statusCode == 201 ? {'success': true, ...d} : {'success': false, 'detail': d['detail'] ?? 'Failed'};
    } catch (e) { return {'success': false, 'detail': e.toString()}; }
  }

  static Future<Map<String, dynamic>> updateDataset(String datasetId, Map<String, dynamic> updates) async {
    try {
      final r = await http.patch(
        Uri.parse('${await datasetBase}/datasets/$datasetId'),
        headers: await _headers(),
        body: jsonEncode(updates),
      ).timeout(const Duration(seconds: 15));
      final d = jsonDecode(r.body) as Map<String, dynamic>;
      return r.statusCode == 200 ? {'success': true, ...d} : {'success': false, 'detail': d['detail'] ?? 'Failed'};
    } catch (e) { return {'success': false, 'detail': e.toString()}; }
  }

  // ── DATASET WORKFLOW (approval, versioning) ───────────────────

  static Future<Map<String, dynamic>> submitDatasetForReview({
    required String title,
    required String description,
    required String category,
    required String license,
    required List<String> tags,
    required String outputFormat,
    required int phiRemovedCount,
    String? ocrJobId,
  }) async {
    try {
      final r = await http.post(
        Uri.parse('${await datasetBase}/datasets/submit-review'),
        headers: await _headers(auth: true),
        body: jsonEncode({
          'title': title, 'description': description, 'category': category,
          'license': license, 'tags': tags, 'output_format': outputFormat,
          'phi_removed_count': phiRemovedCount,
          if (ocrJobId != null) 'ocr_job_id': ocrJobId,
        }),
      ).timeout(const Duration(seconds: 15));
      final d = jsonDecode(r.body) as Map<String, dynamic>;
      return r.statusCode == 201
          ? {'success': true, ...d}
          : {'success': false, 'detail': d['detail'] ?? 'Submission failed'};
    } catch (e) { return {'success': false, 'detail': e.toString()}; }
  }

  static Future<Map<String, dynamic>> getDatasetPendingRequests() async {
    try {
      final r = await http.get(
        Uri.parse('${await datasetBase}/datasets/pending'),
        headers: await _headers(auth: true),
      ).timeout(const Duration(seconds: 10));
      return r.statusCode == 200
          ? jsonDecode(r.body)
          : {'pending': []};
    } catch (_) { return {'pending': []}; }
  }

  static Future<Map<String, dynamic>> adminApproveDataset(
      String datasetId, {String? note}) async {
    try {
      final r = await http.post(
        Uri.parse('${await datasetBase}/datasets/$datasetId/approve'),
        headers: await _headers(auth: true),
        body: jsonEncode({'note': note ?? 'Approved by admin'}),
      ).timeout(const Duration(seconds: 12));
      final d = jsonDecode(r.body) as Map<String, dynamic>;
      return r.statusCode == 200
          ? {'success': true, ...d}
          : {'success': false, 'detail': d['detail'] ?? 'Approval failed'};
    } catch (e) { return {'success': false, 'detail': e.toString()}; }
  }

  static Future<Map<String, dynamic>> adminRejectDataset(
      String datasetId, {required String feedback}) async {
    try {
      final r = await http.post(
        Uri.parse('${await datasetBase}/datasets/$datasetId/reject'),
        headers: await _headers(auth: true),
        body: jsonEncode({'feedback': feedback}),
      ).timeout(const Duration(seconds: 12));
      final d = jsonDecode(r.body) as Map<String, dynamic>;
      return r.statusCode == 200
          ? {'success': true, ...d}
          : {'success': false, 'detail': d['detail'] ?? 'Rejection failed'};
    } catch (e) { return {'success': false, 'detail': e.toString()}; }
  }

  static Future<Map<String, dynamic>> createDatasetVersion(
      String datasetId, Map<String, dynamic> updates) async {
    try {
      final r = await http.post(
        Uri.parse('${await datasetBase}/datasets/$datasetId/versions'),
        headers: await _headers(auth: true),
        body: jsonEncode(updates),
      ).timeout(const Duration(seconds: 15));
      final d = jsonDecode(r.body) as Map<String, dynamic>;
      return r.statusCode == 201
          ? {'success': true, ...d}
          : {'success': false, 'detail': d['detail'] ?? 'Versioning failed'};
    } catch (e) { return {'success': false, 'detail': e.toString()}; }
  }

  static Future<List<dynamic>> getDatasetVersionHistory(String datasetId) async {
    try {
      final r = await http.get(
        Uri.parse('${await datasetBase}/datasets/$datasetId/versions'),
        headers: await _headers(auth: true),
      ).timeout(const Duration(seconds: 10));
      return r.statusCode == 200 ? jsonDecode(r.body) as List : [];
    } catch (_) { return []; }
  }

  static Future<List<dynamic>> getDatasetAuditLog(String datasetId) async {
    try {
      final r = await http.get(
        Uri.parse('${await datasetBase}/datasets/$datasetId/audit-log'),
        headers: await _headers(auth: true),
      ).timeout(const Duration(seconds: 10));
      return r.statusCode == 200 ? jsonDecode(r.body) as List : [];
    } catch (_) { return []; }
  }

  // ── GOVERNORATE DETAIL ────────────────────────────────────────
  static Future<Map<String, dynamic>> getGovernorateDetail(String name) async {
    try {
      final r = await http.get(
        Uri.parse('\${await analyticsBase}/stats/governorate/\${Uri.encodeComponent(name)}'),
      ).timeout(const Duration(seconds: 8));
      return r.statusCode == 200
          ? jsonDecode(r.body) as Map<String, dynamic>
          : {};
    } catch (_) { return {}; }
  }

}
