import 'package:flutter/material.dart';
import '../services/api_service.dart';

// ── Complete fallback dataset (richest possible) ──────────────
const _fallbackOverview = {
  'total_datasets': 12, 'total_downloads': 31840, 'total_views': 184500,
  'total_ocr_jobs': 247, 'total_phi_detected': 8432, 'total_users': 384,
  'active_users': 127, 'total_articles': 10, 'total_article_views': 96200,
  'governorates_covered': 27,
};

const _fallbackTrends = {
  'months': ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'],
  'year': 2024,
  'datasets': {
    'Diabetes':     [120,132,141,155,162,148,139,144,158,171,165,178],
    'Hypertension': [95,102,110,108,115,122,119,127,133,128,140,145],
    'Cancer':       [45,48,52,55,58,61,59,63,67,70,72,75],
    'HepatitisC':   [88,72,60,48,38,30,25,22,18,15,12,10],
    'COVID19':      [210,185,160,130,95,72,55,48,60,78,65,52],
    'Obesity':      [145,148,152,158,161,155,150,153,160,165,162,170],
  },
};

const List<Map<String, dynamic>> _fallbackGovs = [
  {'name':'Cairo',         'population':10100000,'health_index':72,'hospitals':145,'datasets':34},
  {'name':'Giza',          'population':9200000, 'health_index':68,'hospitals':98, 'datasets':28},
  {'name':'Alexandria',    'population':5200000, 'health_index':70,'hospitals':87, 'datasets':22},
  {'name':'Dakahlia',      'population':6800000, 'health_index':61,'hospitals':64, 'datasets':15},
  {'name':'Sharqia',       'population':7100000, 'health_index':59,'hospitals':72, 'datasets':18},
  {'name':'Qalyubia',      'population':5600000, 'health_index':63,'hospitals':55, 'datasets':12},
  {'name':'Gharbia',       'population':5000000, 'health_index':60,'hospitals':58, 'datasets':14},
  {'name':'Menoufia',      'population':4200000, 'health_index':58,'hospitals':48, 'datasets':11},
  {'name':'Beheira',       'population':5700000, 'health_index':57,'hospitals':62, 'datasets':13},
  {'name':'Kafr El Sheikh','population':3300000, 'health_index':55,'hospitals':41, 'datasets':9 },
  {'name':'Sohag',         'population':5200000, 'health_index':53,'hospitals':52, 'datasets':11},
  {'name':'Minya',         'population':5900000, 'health_index':52,'hospitals':58, 'datasets':12},
  {'name':'Asyut',         'population':4400000, 'health_index':56,'hospitals':49, 'datasets':10},
  {'name':'Ismailia',      'population':1200000, 'health_index':71,'hospitals':22, 'datasets':8 },
  {'name':'Port Said',     'population':750000,  'health_index':74,'hospitals':18, 'datasets':7 },
  {'name':'Suez',          'population':800000,  'health_index':69,'hospitals':16, 'datasets':6 },
  {'name':'Luxor',         'population':1300000, 'health_index':64,'hospitals':24, 'datasets':10},
  {'name':'Aswan',         'population':1500000, 'health_index':62,'hospitals':26, 'datasets':9 },
  {'name':'Qena',          'population':3800000, 'health_index':54,'hospitals':44, 'datasets':9 },
  {'name':'Beni Suef',     'population':3100000, 'health_index':55,'hospitals':34, 'datasets':7 },
  {'name':'Fayoum',        'population':3700000, 'health_index':50,'hospitals':38, 'datasets':8 },
  {'name':'Damietta',      'population':1500000, 'health_index':65,'hospitals':28, 'datasets':7 },
  {'name':'Red Sea',       'population':380000,  'health_index':66,'hospitals':10, 'datasets':4 },
  {'name':'South Sinai',   'population':190000,  'health_index':73,'hospitals':12, 'datasets':5 },
  {'name':'North Sinai',   'population':500000,  'health_index':58,'hospitals':14, 'datasets':4 },
  {'name':'Matrouh',       'population':450000,  'health_index':61,'hospitals':9,  'datasets':3 },
  {'name':'New Valley',    'population':250000,  'health_index':60,'hospitals':8,  'datasets':3 },
];

const List<Map<String, dynamic>> _fallbackIndicators = [
  {'name':'Life Expectancy',   'value':72.4,'unit':'years',      'trend':'up',  'change':1.2, 'global':73.3,'sdg':'SDG 3.4'},
  {'name':'Infant Mortality',  'value':17.5,'unit':'per 1,000 LB','trend':'down','change':-2.1,'global':28.0,'sdg':'SDG 3.2'},
  {'name':'Maternal Mortality','value':52,  'unit':'per 100K LB','trend':'down','change':-8.0,'global':223.0,'sdg':'SDG 3.1'},
  {'name':'DTP3 Coverage',     'value':93.2,'unit':'%',          'trend':'up',  'change':1.5, 'global':84.0,'sdg':'SDG 3.b'},
  {'name':'Hepatitis C',       'value':0.87,'unit':'%',          'trend':'down','change':-6.5,'global':1.0, 'sdg':'SDG 3.3'},
  {'name':'Diabetes',          'value':17.2,'unit':'% adults',   'trend':'up',  'change':0.8, 'global':9.3, 'sdg':'SDG 3.4'},
  {'name':'Physician Density', 'value':8.1, 'unit':'per 10,000', 'trend':'up',  'change':0.4, 'global':18.0,'sdg':'SDG 3.c'},
  {'name':'Hospital Beds',     'value':15.8,'unit':'per 10,000', 'trend':'up',  'change':0.6, 'global':27.0,'sdg':'SDG 3.8'},
  {'name':'UHC Index',         'value':62,  'unit':'score /100', 'trend':'up',  'change':1.5, 'global':68.0,'sdg':'SDG 3.8'},
  {'name':'Hypertension',      'value':26.3,'unit':'% adults',   'trend':'up',  'change':1.1, 'global':28.0,'sdg':'SDG 3.4'},
  {'name':'Obesity',           'value':34.5,'unit':'% adults',   'trend':'up',  'change':2.0, 'global':19.0,'sdg':'SDG 2.2'},
  {'name':'Measles MCV2',      'value':88.5,'unit':'%',          'trend':'up',  'change':0.7, 'global':71.0,'sdg':'SDG 3.b'},
];

class AnalyticsProvider extends ChangeNotifier {
  Map<String, dynamic> _overview   = {};
  Map<String, dynamic> _trends     = {};
  List<Map<String, dynamic>> _govs = [];
  List<Map<String, dynamic>> _inds = [];
  bool _isLoading = false;
  bool _backendOnline = false;

  // ── Getters with guaranteed non-null data ───────────────────
  Map<String, dynamic> get overview    => _overview.isNotEmpty  ? _overview    : _fallbackOverview;
  Map<String, dynamic> get trends      => _trends.isNotEmpty    ? _trends      : _fallbackTrends;
  List<Map<String, dynamic>> get governorates => _govs.isNotEmpty ? _govs : _fallbackGovs;
  List<Map<String, dynamic>> get indicators   => _inds.isNotEmpty ? _inds : _fallbackIndicators;
  bool get isLoading     => _isLoading;
  bool get backendOnline => _backendOnline;

  // ── One-shot: loads everything from /stats/standalone ───────
  Future<void> fetchAll() async {
    _isLoading = true;
    notifyListeners();
    try {
      final all = await ApiService.getAllAnalytics();
      if (all.isNotEmpty) {
        _backendOnline = true;
        // Parse overview
        if (all['overview'] is Map)  _overview = Map<String, dynamic>.from(all['overview'] as Map);
        // Parse trends
        if (all['disease_trends'] is Map) _trends = Map<String, dynamic>.from(all['disease_trends'] as Map);
        // Parse governorates
        if (all['governorates'] is List) {
          _govs = (all['governorates'] as List).cast<Map<String, dynamic>>();
        }
        // Parse indicators
        if (all['health_indicators'] is List) {
          _inds = (all['health_indicators'] as List).cast<Map<String, dynamic>>();
        }
      }
    } catch (e) {
      _backendOnline = false;
    }
    // Always guarantee data from fallback
    if (_overview.isEmpty)  _overview = Map<String, dynamic>.from(_fallbackOverview);
    if (_trends.isEmpty)    _trends   = Map<String, dynamic>.from(_fallbackTrends);
    if (_govs.isEmpty)      _govs     = List<Map<String, dynamic>>.from(_fallbackGovs);
    if (_inds.isEmpty)      _inds     = List<Map<String, dynamic>>.from(_fallbackIndicators);
    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchOverview() => fetchAll();
  Future<void> fetchTrends()   => fetchAll();
  Future<void> fetchGovernorates() => fetchAll();
  Future<void> fetchIndicators()   => fetchAll();

  // ── Governorate drill-down ───────────────────────────────────
  Future<Map<String, dynamic>> getGovernorateDetail(String name) async {
    try {
      final d = await ApiService.getGovernorateDetail(name);
      if (d.isNotEmpty) return d;
    } catch (_) {}
    // Build from fallback
    final g = _govs.firstWhere((g) => g['name'] == name,
        orElse: () => {'name': name, 'health_index': 60, 'hospitals': 20, 'population': 1000000, 'datasets': 5});
    final hi = (g['health_index'] as num).toDouble();
    return {
      ...g,
      'health_score_label': hi >= 72 ? 'Excellent' : hi >= 65 ? 'Good' : hi >= 58 ? 'Fair' : 'Needs Attention',
      'disease_rates': {
        'diabetes':     (14.5 + (27 - hi) * 0.35).toStringAsFixed(1),
        'hypertension': (22.0 + (27 - hi) * 0.25).toStringAsFixed(1),
        'obesity':      (28.0 + (27 - hi) * 0.30).toStringAsFixed(1),
      },
      'vaccination_coverage': {
        'dtp3':    (hi * 1.28).clamp(0, 99).toStringAsFixed(1),
        'measles': (hi * 1.21).clamp(0, 99).toStringAsFixed(1),
        'covid':   (hi * 0.58).toStringAsFixed(1),
      },
      'icu_beds_per_10k': (2.1 + (hi - 50) * 0.08).toStringAsFixed(1),
      'population_millions': ((g['population'] as int) / 1000000).toStringAsFixed(2),
    };
  }
}
