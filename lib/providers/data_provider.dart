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
  String _sortColumn = 'estadoPrioridade';
  bool _sortAscending = false;

  // Filter state
  String? _filterEstado;
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
  String? get filterEstado => _filterEstado;
  String get searchQuery => _searchQuery;

  // Dashboard stats
  int get totalInfluencers => _influencers.length;
  int get mensual => _influencers.where((i) => i.isMensual).length;
  int get ativas => _influencers.where((i) => i.isAtiva).length;
  int get contactadas => _influencers.where((i) => i.estado == 'Contactada').length;
  int get conteudoSubido => _influencers.where((i) => i.estado == 'Contenido subido').length;
  int get contratoFirmado => _influencers.where((i) => i.contrato == 'Firmado').length;

  // Category counts (dynamic — based on CSV separator detection)
  Map<String, int> get porCategoria {
    final map = <String, int>{};
    for (final i in _influencers) {
      final cat = i.categoria.isNotEmpty ? i.categoria : 'Instagram';
      map[cat] = (map[cat] ?? 0) + 1;
    }
    return map;
  }

  // Financial stats
  Map<String, double> get investimentoPorFactura {
    final map = <String, double>{};
    for (final i in _influencers) {
      if (i.fee <= 0) continue;
      final key = i.factura.isNotEmpty ? i.factura : 'Sem fatura';
      map[key] = (map[key] ?? 0) + i.fee;
    }
    return map;
  }

  double get totalInvestimento =>
      _influencers.fold(0.0, (sum, i) => sum + i.fee);

  // Estado distribution (for charts)
  Map<String, int> get porEstado {
    final map = <String, int>{};
    for (final i in _influencers) {
      final key = i.estado.isNotEmpty ? i.estado : 'Sem estado';
      map[key] = (map[key] ?? 0) + 1;
    }
    return Map.fromEntries(
      map.entries.toList()..sort((a, b) => b.value.compareTo(a.value)),
    );
  }

  // Legacy stats (kept for compatibility)
  int get totalParcerias => _parcerias.length;
  int get parceriasAtivas => _parcerias.where((p) => p.isAtiva).length;
  int get totalProdutos => _produtos.length;

  List<String> get allEstados {
    final estados = _influencers
        .map((i) => i.estado)
        .where((e) => e.isNotEmpty)
        .toSet()
        .toList();
    estados.sort();
    return estados;
  }

  List<Influencer> get topInfluencers {
    final sorted = [..._influencers]
      ..sort((a, b) => b.estadoPrioridade.compareTo(a.estadoPrioridade));
    return sorted.take(5).toList();
  }

  void sortInfluencers(String column, bool ascending) {
    _sortColumn = column;
    _sortAscending = ascending;
    notifyListeners();
  }

  void filterInfluencers({
    String? estado,
    String? search,
  }) {
    _filterEstado = estado;
    if (search != null) _searchQuery = search;
    notifyListeners();
  }

  void clearFilters() {
    _filterEstado = null;
    _searchQuery = '';
    notifyListeners();
  }

  List<Influencer> _filteredAndSorted() {
    var list = [..._influencers];

    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      list = list.where((i) {
        return i.nome.toLowerCase().contains(q) ||
            i.handle.toLowerCase().contains(q) ||
            i.contacto.toLowerCase().contains(q);
      }).toList();
    }

    if (_filterEstado != null && _filterEstado!.isNotEmpty) {
      list = list.where((i) => i.estado == _filterEstado).toList();
    }

    list.sort((a, b) {
      int cmp;
      switch (_sortColumn) {
        case 'nome':
          cmp = a.nome.compareTo(b.nome);
          break;
        case 'followers':
          cmp = a.followers.compareTo(b.followers);
          break;
        case 'estado':
          cmp = a.estado.compareTo(b.estado);
          break;
        case 'estadoPrioridade':
          cmp = a.estadoPrioridade.compareTo(b.estadoPrioridade);
          break;
        default:
          cmp = a.estadoPrioridade.compareTo(b.estadoPrioridade);
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
    final bundle = DefaultAssetBundle.of(context);

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
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
