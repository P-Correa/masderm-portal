import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:csv/csv.dart';
import 'package:http/http.dart' as http;
import '../models/influencer.dart';
import '../models/parceria.dart';
import '../models/produto.dart';

const String _githubBase =
    'https://api.github.com/repos/P-Correa/masderm-portal/contents/assets/data';

class DataProvider extends ChangeNotifier {
  List<Influencer> _influencers = [];
  List<Parceria> _parcerias = [];
  List<Produto> _produtos = [];
  bool _isLoading = false;
  bool _isLoaded = false;
  String? _error;
  DateTime? _lastUpdated;

  // Sorting state
  String _sortColumn = 'scoreRelevancia';
  bool _sortAscending = false;

  // Filter state
  String? _filterNicho;
  String? _filterEstado;
  String? _filterCidade;
  double? _filterMinScore;
  String _searchQuery = '';

  List<Influencer> get influencers => _filteredAndSorted();
  List<Influencer> get allInfluencers => List.unmodifiable(_influencers);
  List<Parceria> get parcerias => List.unmodifiable(_parcerias);
  List<Produto> get produtos => List.unmodifiable(_produtos);
  bool get isLoading => _isLoading;
  bool get isLoaded => _isLoaded;
  String? get error => _error;
  DateTime? get lastUpdated => _lastUpdated;

  String get sortColumn => _sortColumn;
  bool get sortAscending => _sortAscending;
  String? get filterNicho => _filterNicho;
  String? get filterEstado => _filterEstado;
  String? get filterCidade => _filterCidade;
  double? get filterMinScore => _filterMinScore;
  String get searchQuery => _searchQuery;

  // Dashboard stats
  int get totalInfluencers => _influencers.length;
  int get prioridadeAlta =>
      _influencers.where((i) => i.isPrioridadeAlta).length;
  double get scoreMedio => _influencers.isEmpty
      ? 0
      : _influencers
              .map((i) => i.scoreRelevancia)
              .reduce((a, b) => a + b) /
          _influencers.length;
  int get emContacto => _influencers
      .where((i) =>
          i.estadoProspeccao.toUpperCase().contains('CONTACT') ||
          i.estadoProspeccao.toUpperCase().contains('NEGOCI'))
      .length;
  int get totalParcerias => _parcerias.length;
  int get parceriasAtivas => _parcerias.where((p) => p.isAtiva).length;
  int get totalProdutos => _produtos.length;

  List<Influencer> get topInfluencers {
    final sorted = [..._influencers]
      ..sort((a, b) => b.scoreRelevancia.compareTo(a.scoreRelevancia));
    return sorted.take(5).toList();
  }

  Map<String, int> get distribuicaoPorEstado {
    final map = <String, int>{};
    for (final inf in _influencers) {
      final estado = inf.estadoProspeccao.isEmpty ? 'Sem estado' : inf.estadoProspeccao;
      map[estado] = (map[estado] ?? 0) + 1;
    }
    return Map.fromEntries(
      map.entries.toList()..sort((a, b) => b.value.compareTo(a.value)),
    );
  }

  List<String> get allNichos {
    final nichos = _influencers
        .map((i) => i.nichoPrincipal)
        .where((n) => n.isNotEmpty)
        .toSet()
        .toList();
    nichos.sort();
    return nichos;
  }

  List<String> get allEstados {
    final estados = _influencers
        .map((i) => i.estadoProspeccao)
        .where((e) => e.isNotEmpty)
        .toSet()
        .toList();
    estados.sort();
    return estados;
  }

  List<String> get allCidades {
    final cidades = _influencers
        .map((i) => i.cidade)
        .where((c) => c.isNotEmpty)
        .toSet()
        .toList();
    cidades.sort();
    return cidades;
  }

  void sortInfluencers(String column, bool ascending) {
    _sortColumn = column;
    _sortAscending = ascending;
    notifyListeners();
  }

  void filterInfluencers({
    String? nicho,
    String? estado,
    String? cidade,
    double? minScore,
    String? search,
  }) {
    _filterNicho = nicho;
    _filterEstado = estado;
    _filterCidade = cidade;
    _filterMinScore = minScore;
    if (search != null) _searchQuery = search;
    notifyListeners();
  }

  void clearFilters() {
    _filterNicho = null;
    _filterEstado = null;
    _filterCidade = null;
    _filterMinScore = null;
    _searchQuery = '';
    notifyListeners();
  }

  List<Influencer> _filteredAndSorted() {
    var list = [..._influencers];

    // Search
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      list = list.where((i) {
        return i.nome.toLowerCase().contains(q) ||
            i.handleInstagram.toLowerCase().contains(q) ||
            i.emailContacto.toLowerCase().contains(q) ||
            i.cidade.toLowerCase().contains(q);
      }).toList();
    }

    // Filters
    if (_filterNicho != null && _filterNicho!.isNotEmpty) {
      list = list.where((i) => i.nichoPrincipal == _filterNicho).toList();
    }
    if (_filterEstado != null && _filterEstado!.isNotEmpty) {
      list =
          list.where((i) => i.estadoProspeccao == _filterEstado).toList();
    }
    if (_filterCidade != null && _filterCidade!.isNotEmpty) {
      list = list.where((i) => i.cidade == _filterCidade).toList();
    }
    if (_filterMinScore != null) {
      list = list
          .where((i) => i.scoreRelevancia >= _filterMinScore!)
          .toList();
    }

    // Sort
    list.sort((a, b) {
      int cmp;
      switch (_sortColumn) {
        case 'nome':
          cmp = a.nome.compareTo(b.nome);
          break;
        case 'handleInstagram':
          cmp = a.handleInstagram.compareTo(b.handleInstagram);
          break;
        case 'scoreRelevancia':
          cmp = a.scoreRelevancia.compareTo(b.scoreRelevancia);
          break;
        case 'seguidoresAprox':
          cmp = a.seguidoresAprox.compareTo(b.seguidoresAprox);
          break;
        case 'taxaEngagementEstimada':
          cmp = a.taxaEngagementEstimada
              .compareTo(b.taxaEngagementEstimada);
          break;
        case 'estadoProspeccao':
          cmp = a.estadoProspeccao.compareTo(b.estadoProspeccao);
          break;
        default:
          cmp = a.scoreRelevancia.compareTo(b.scoreRelevancia);
      }
      return _sortAscending ? cmp : -cmp;
    });

    return list;
  }

  Future<void> loadAll(BuildContext context) async {
    if (_isLoaded || _isLoading) return;
    await _fetchAll(context);
  }

  Future<void> refresh(BuildContext context) async {
    _isLoaded = false;
    await _fetchAll(context);
  }

  Future<void> _fetchAll(BuildContext context) async {
    // Capture asset bundle before any async gap
    final bundle = DefaultAssetBundle.of(context);

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Try GitHub API first
      bool githubSuccess = false;
      try {
        await Future.wait([
          _loadFromGitHub('influencers.csv'),
          _loadFromGitHub('parcerias.csv'),
          _loadFromGitHub('produtos.csv'),
        ]);
        githubSuccess = true;
      } catch (e) {
        debugPrint('GitHub fetch failed, falling back to assets: $e');
      }

      if (!githubSuccess) {
        // Fallback to local assets
        await Future.wait([
          _loadInfluencersAsset(bundle),
          _loadParceriasAsset(bundle),
          _loadProdutosAsset(bundle),
        ]);
      }

      _isLoaded = true;
      _lastUpdated = DateTime.now();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _loadFromGitHub(String filename) async {
    final url = Uri.parse('$_githubBase/$filename');
    final response = await http.get(url, headers: {
      'Accept': 'application/vnd.github.v3+json',
    }).timeout(const Duration(seconds: 10));

    if (response.statusCode != 200) {
      throw Exception('GitHub API returned ${response.statusCode}');
    }

    final json = jsonDecode(response.body) as Map<String, dynamic>;
    final contentB64 =
        (json['content'] as String).replaceAll('\n', '').replaceAll('\r', '');
    final bytes = base64Decode(contentB64);
    final csvString = utf8.decode(bytes);
    _parseCsv(filename, csvString);
  }

  Future<void> _loadInfluencersAsset(AssetBundle bundle) async {
    final raw = await bundle.loadString('assets/data/influencers.csv');
    _parseCsv('influencers.csv', raw);
  }

  Future<void> _loadParceriasAsset(AssetBundle bundle) async {
    final raw = await bundle.loadString('assets/data/parcerias.csv');
    _parseCsv('parcerias.csv', raw);
  }

  Future<void> _loadProdutosAsset(AssetBundle bundle) async {
    final raw = await bundle.loadString('assets/data/produtos.csv');
    _parseCsv('produtos.csv', raw);
  }

  void _parseCsv(String filename, String raw) {
    try {
      final rows = const CsvToListConverter(eol: '\n').convert(raw);
      if (rows.length <= 1) return;
      final dataRows = rows
          .skip(1)
          .where((r) => r.isNotEmpty && r[0].toString().trim().isNotEmpty)
          .toList();

      if (filename.contains('influencer')) {
        _influencers = dataRows.map((r) => Influencer.fromCsv(r)).toList();
      } else if (filename.contains('parceria')) {
        _parcerias = dataRows.map((r) => Parceria.fromCsv(r)).toList();
      } else if (filename.contains('produto')) {
        _produtos = dataRows.map((r) => Produto.fromCsv(r)).toList();
      }
    } catch (e) {
      debugPrint('Error parsing $filename: $e');
    }
  }
}
