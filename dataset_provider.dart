import 'package:flutter/material.dart';
import '../services/api_service.dart';

class DatasetModel {
  final String id, title, description, category, fileFormat, license;
  final List<String> tags;
  final String? source;
  final double sizeMb, rating;
  final int downloads, views;
  final DateTime createdAt;

  DatasetModel({required this.id, required this.title, required this.description, required this.category,
    required this.tags, required this.license, this.source, required this.fileFormat,
    required this.sizeMb, required this.downloads, required this.views, required this.rating, required this.createdAt});

  factory DatasetModel.fromJson(Map<String, dynamic> j) => DatasetModel(
    id: j['id']?.toString() ?? '', title: j['title']?.toString() ?? '',
    description: j['description']?.toString() ?? '', category: j['category']?.toString() ?? '',
    tags: (j['tags'] as List?)?.map((e) => e.toString()).toList() ?? [],
    license: j['license']?.toString() ?? 'CC BY 4.0', source: j['source']?.toString(),
    fileFormat: j['file_format']?.toString() ?? j['fileFormat']?.toString() ?? 'CSV',
    sizeMb: (j['size_mb'] ?? j['sizeMb'] ?? 0).toDouble(),
    downloads: (j['downloads'] ?? 0) as int, views: (j['views'] ?? 0) as int,
    rating: (j['rating'] ?? 0).toDouble(),
    createdAt: DateTime.tryParse(j['created_at']?.toString() ?? j['createdAt']?.toString() ?? '') ?? DateTime(2024));

  Map<String, dynamic> toMap() => {'id':id,'title':title,'description':description,'category':category,
    'tags':tags,'license':license,'source':source,'fileFormat':fileFormat,'sizeMb':sizeMb,
    'downloads':downloads,'views':views,'rating':rating};
}

// ── Seed data (exact same as backend SEED_DATASETS) ──────────
final List<DatasetModel> _seed = [
  DatasetModel(id:'s1',title:'Egypt National Cancer Registry 2020-2024',description:'Comprehensive cancer incidence and mortality data across all Egyptian governorates with demographic breakdowns.',category:'Oncology',tags:['cancer','registry','mortality','egypt'],license:'CC BY 4.0',source:'Ministry of Health Egypt',fileFormat:'CSV',sizeMb:45.2,downloads:1240,views:8930,rating:4.8,createdAt:DateTime(2024,1,15)),
  DatasetModel(id:'s2',title:'COVID-19 Cases & Vaccination Egypt 2020-2023',description:'Daily COVID-19 confirmed cases, recoveries, deaths and vaccination rates by governorate.',category:'Infectious Disease',tags:['covid19','vaccination','pandemic','egypt'],license:'CC BY 4.0',source:'MOHP Egypt',fileFormat:'JSON',sizeMb:12.7,downloads:4560,views:22100,rating:4.9,createdAt:DateTime(2020,3,10)),
  DatasetModel(id:'s3',title:'Egyptian Diabetes Prevalence Survey 2023',description:'National survey on Type 1 & Type 2 diabetes prevalence, risk factors and treatment adherence.',category:'Endocrinology',tags:['diabetes','prevalence','survey'],license:'CC BY-NC 4.0',source:'Ain Shams University Hospital',fileFormat:'XLSX',sizeMb:8.3,downloads:890,views:5400,rating:4.6,createdAt:DateTime(2023,6,1)),
  DatasetModel(id:'s4',title:'Maternal Mortality Egypt 2015-2023',description:'Maternal mortality ratio, causes of death, and antenatal care coverage by region.',category:'Maternal Health',tags:['maternal','mortality','antenatal'],license:'CC BY 4.0',source:'CAPMAS Egypt',fileFormat:'CSV',sizeMb:3.1,downloads:720,views:4200,rating:4.7,createdAt:DateTime(2023,8,20)),
  DatasetModel(id:'s5',title:'Egypt Child Immunization Coverage 2022',description:'Vaccination coverage rates for children under 5 across all Egyptian governorates.',category:'Pediatrics',tags:['vaccination','children','immunization'],license:'CC BY 4.0',source:'UNICEF Egypt / MOHP',fileFormat:'CSV',sizeMb:2.4,downloads:560,views:3100,rating:4.5,createdAt:DateTime(2022,12,1)),
  DatasetModel(id:'s6',title:'Cardiovascular Disease Risk Factors Egypt',description:'Blood pressure, cholesterol, smoking, and obesity prevalence data from 50,000+ participants.',category:'Cardiology',tags:['cardiovascular','hypertension','obesity'],license:'CC BY-NC-SA 4.0',source:'National Heart Institute Cairo',fileFormat:'XLSX',sizeMb:22.6,downloads:1100,views:6700,rating:4.7,createdAt:DateTime(2023,3,5)),
  DatasetModel(id:'s7',title:'Hospital Bed Capacity Egypt 2024',description:'Public and private hospital beds, ICU capacity, and healthcare worker distribution.',category:'Health Infrastructure',tags:['hospitals','capacity','icu'],license:'CC BY 4.0',source:'MOHP Egypt',fileFormat:'JSON',sizeMb:1.8,downloads:980,views:7200,rating:4.4,createdAt:DateTime(2024,1,1)),
  DatasetModel(id:'s8',title:'Mental Health Prevalence Survey Egypt 2023',description:'Depression, anxiety, and PTSD prevalence across age groups with treatment gap analysis.',category:'Mental Health',tags:['mental-health','depression','anxiety'],license:'CC BY-NC 4.0',source:'WHO Egypt / MOHP',fileFormat:'PDF+CSV',sizeMb:15.5,downloads:440,views:2800,rating:4.8,createdAt:DateTime(2023,10,1)),
  DatasetModel(id:'s9',title:'Tuberculosis Notification Egypt 2019-2023',description:'TB case notification rates, drug resistance patterns, and treatment success rates.',category:'Infectious Disease',tags:['tuberculosis','tb','drug-resistance'],license:'CC BY 4.0',source:'National TB Programme Egypt',fileFormat:'CSV',sizeMb:5.9,downloads:310,views:1950,rating:4.3,createdAt:DateTime(2024,3,10)),
  DatasetModel(id:'s10',title:'Hepatitis C Elimination Program Data',description:'"100 Million Health" campaign screening and treatment outcomes for Hepatitis C.',category:'Hepatology',tags:['hepatitis-c','elimination','screening'],license:'CC BY 4.0',source:'MOHP Egypt',fileFormat:'XLSX',sizeMb:38.4,downloads:2340,views:14600,rating:4.9,createdAt:DateTime(2019,10,1)),
  DatasetModel(id:'s11',title:'Egypt Obesity & Nutrition Survey 2022',description:'BMI distribution, dietary habits, and physical activity levels across Egyptian population.',category:'Nutrition',tags:['obesity','nutrition','bmi'],license:'CC BY-NC 4.0',source:'CAPMAS / MOHP',fileFormat:'CSV',sizeMb:7.2,downloads:670,views:4100,rating:4.5,createdAt:DateTime(2022,8,1)),
  DatasetModel(id:'s12',title:'Neonatal Mortality & Birth Outcomes Egypt',description:'Neonatal mortality rates, preterm births, low birth weight, and APGAR score distributions.',category:'Neonatology',tags:['neonatal','birth','mortality'],license:'CC BY 4.0',source:'MOHP Vital Statistics',fileFormat:'CSV',sizeMb:4.6,downloads:390,views:2300,rating:4.6,createdAt:DateTime(2023,5,20)),
];

class DatasetProvider extends ChangeNotifier {
  List<DatasetModel> _datasets = [];
  List<String> _categories = [];
  bool _isLoading = false;
  bool _backendOnline = false;
  String? _error;

  List<DatasetModel> get datasets    => _datasets.isNotEmpty ? _datasets : _seed;
  List<String>       get categories  => _categories.isNotEmpty ? _categories : _seed.map((d) => d.category).toSet().toList()..sort();
  bool               get isLoading   => _isLoading;
  bool               get backendOnline => _backendOnline;
  String?            get error       => _error;

  Future<void> fetchDatasets({int limit = 100, String? category, String? search}) async {
    _isLoading = true; _error = null; notifyListeners();
    try {
      final data = await ApiService.getDatasets(limit: limit, category: category, search: search);
      if (data.isNotEmpty) {
        _datasets = data.map((d) => DatasetModel.fromJson(d as Map<String, dynamic>)).toList();
        _backendOnline = true;
      }
    } catch (e) { _error = e.toString(); }
    if (_datasets.isEmpty) _datasets = _seed;
    _isLoading = false; notifyListeners();
  }

  Future<void> fetchCategories() async {
    try {
      final d = await ApiService.getDatasetCategories();
      final cats = d['categories'] as List? ?? [];
      if (cats.isNotEmpty) {
        _categories = cats.map((c) => c['name'].toString()).toList();
        notifyListeners();
      }
    } catch (_) {}
    if (_categories.isEmpty) {
      _categories = _seed.map((d) => d.category).toSet().toList()..sort();
      notifyListeners();
    }
  }
}
