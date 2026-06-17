import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:csv/csv.dart';
import '../models/influencer.dart';
import '../models/parceria.dart';
import '../models/produto.dart';

class DataProvider extends ChangeNotifier {
  List<Influencer> _influencers = [];
  List<Parceria> _parcerias = [];
  List<Produto> _produtos = [];
  bool _isLoading = false;
  bool _isLoaded = false;
  String? _error;

  List<Influencer> get influencers => List.unmodifiable(_influencers);
  List<Parceria> get parcerias => List.unmodifiable(_parcerias);
  List<Produto> get produtos => List.unmodifiable(_produtos);
  bool get isLoading => _isLoading;
  bool get isLoaded => _isLoaded;
  String? get error => _error;

  // Dashboard stats
  int get totalInfluencers => _influencers.length;
  int get prioridadeAlta =>
      _influencers.where((i) => i.isPrioridadeAlta).length;
  double get scoreMedio => _influencers.isEmpty
      ? 0
      : _influencers.map((i) => i.scoreRelevancia).reduce((a, b) => a + b) /
          _influencers.length;
  int get totalParcerias => _parcerias.length;
  int get parceriasAtivas => _parcerias.where((p) => p.isAtiva).length;
  int get totalProdutos => _produtos.length;

  List<Influencer> get topInfluencers {
    final sorted = [..._influencers]
      ..sort((a, b) => b.scoreRelevancia.compareTo(a.scoreRelevancia));
    return sorted.take(5).toList();
  }

  Future<void> loadAll(BuildContext context) async {
    if (_isLoaded || _isLoading) return;
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await Future.wait([
        _loadInfluencers(context),
        _loadParcerias(context),
        _loadProdutos(context),
      ]);
      _isLoaded = true;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _loadInfluencers(BuildContext context) async {
    try {
      final raw = await DefaultAssetBundle.of(context)
          .loadString('assets/data/influencers.csv');
      final rows = const CsvToListConverter(eol: '\n').convert(raw);
      if (rows.length > 1) {
        _influencers = rows.skip(1).where((r) => r.isNotEmpty && r[0].toString().trim().isNotEmpty).map((r) => Influencer.fromCsv(r)).toList();
      }
    } catch (e) {
      debugPrint('Error loading influencers: $e');
    }
  }

  Future<void> _loadParcerias(BuildContext context) async {
    try {
      final raw = await DefaultAssetBundle.of(context)
          .loadString('assets/data/parcerias.csv');
      final rows = const CsvToListConverter(eol: '\n').convert(raw);
      if (rows.length > 1) {
        _parcerias = rows.skip(1).where((r) => r.isNotEmpty && r[0].toString().trim().isNotEmpty).map((r) => Parceria.fromCsv(r)).toList();
      }
    } catch (e) {
      debugPrint('Error loading parcerias: $e');
    }
  }

  Future<void> _loadProdutos(BuildContext context) async {
    try {
      final raw = await DefaultAssetBundle.of(context)
          .loadString('assets/data/produtos.csv');
      final rows = const CsvToListConverter(eol: '\n').convert(raw);
      if (rows.length > 1) {
        _produtos = rows.skip(1).where((r) => r.isNotEmpty && r[0].toString().trim().isNotEmpty).map((r) => Produto.fromCsv(r)).toList();
      }
    } catch (e) {
      debugPrint('Error loading produtos: $e');
    }
  }
}
