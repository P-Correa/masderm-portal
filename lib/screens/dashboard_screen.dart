import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/data_provider.dart';
import '../theme/app_theme.dart';
import '../models/influencer.dart';

// ── Store products ─────────────────────────────────────────────────────────────

class _StoreProduct {
  final String nome;
  final String descricao;
  final String preco;
  final String imageUrl;
  final String url;
  final int reviews;
  const _StoreProduct({
    required this.nome,
    required this.descricao,
    required this.preco,
    required this.imageUrl,
    required this.url,
    required this.reviews,
  });
}

const _top5Masderm = [
  _StoreProduct(
    nome: 'RF Body Firming 1000ml',
    descricao: 'Creme corporal firmador por radiofrequência',
    preco: '€28,90',
    imageUrl: 'https://cdn.shopify.com/s/files/1/0076/1230/1394/products/rf-body-firming-1000ml-636354.jpg?v=1738646787',
    url: 'https://masderm.com/products/crema-radiofrecuencia-corporal',
    reviews: 3933,
  ),
  _StoreProduct(
    nome: 'RF Facial Cream',
    descricao: 'Creme facial firmador de radiofrequência 500ml–1000ml',
    preco: 'A partir de €26,90',
    imageUrl: 'https://cdn.shopify.com/s/files/1/0076/1230/1394/files/rf-facial-cream-4650422.jpg?v=1774685296',
    url: 'https://masderm.com/products/crema-radiofrecuencia-facial',
    reviews: 2213,
  ),
  _StoreProduct(
    nome: 'RF Body Slim',
    descricao: 'Creme anticelulite de radiofrequência 500ml–1000ml',
    preco: 'A partir de €26,90',
    imageUrl: 'https://cdn.shopify.com/s/files/1/0076/1230/1394/files/rf-body-slim-684877.webp?v=1711611314',
    url: 'https://masderm.com/products/crema-radiofrecuencia-corporal-slim',
    reviews: 1570,
  ),
  _StoreProduct(
    nome: 'RF Tratamento de Flacidez Corporal',
    descricao: 'Tratamento completo por radiofrequência para flacidez corporal',
    preco: '€128,80',
    imageUrl: 'https://cdn.shopify.com/s/files/1/0076/1230/1394/files/rf-tratamiento-flacidez-corporal-8276015.jpg?v=1779409152',
    url: 'https://masderm.com/products/rf-tratamiento-antiestrias',
    reviews: 861,
  ),
  _StoreProduct(
    nome: 'Serum Triphasic 100ml',
    descricao: 'Sérum trifásico anti-manchas e uniformizador do tom de pele',
    preco: '€32,90',
    imageUrl: 'https://cdn.shopify.com/s/files/1/0076/1230/1394/files/SERUM_2025_1.jpg?v=1774263359',
    url: 'https://masderm.com/products/serum-facial-trifasico',
    reviews: 0,
  ),
];

// ── Shared helpers ─────────────────────────────────────────────────────────────

(Color, Color) _estadoColors(String estado) {
  switch (estado) {
    case 'Mensual':       return (Colors.white, const Color(0xFF7C3AED));
    case 'Contenido subido':  return (const Color(0xFF16A34A), const Color(0xFFDCFCE7));
    case 'Contenido recibido': return (const Color(0xFF0D9488), const Color(0xFFCCFBF1));
    case 'Producto enviado':  return (const Color(0xFF2563EB), const Color(0xFFDBEAFE));
    case 'Aprobada':      return (const Color(0xFF65A30D), const Color(0xFFECFCCB));
    case 'Contactada':    return (const Color(0xFFC2410C), const Color(0xFFFFEDD5));
    case 'Rechazada':     return (const Color(0xFFDC2626), const Color(0xFFFEE2E2));
    case 'Embarazada':    return (const Color(0xFFBE185D), const Color(0xFFFCE7F3));
    default:              return (const Color(0xFF6B7280), const Color(0xFFF3F4F6));
  }
}

Color _facturaColor(String v) {
  switch (v) {
    case 'Pagada':     return const Color(0xFF16A34A);
    case 'Enviada':    return const Color(0xFF2563EB);
    case 'Pendiente':  return const Color(0xFFB45309);
    case 'Intercâmbio': return const Color(0xFF7C3AED);
    default:           return const Color(0xFF6B7280);
  }
}

Color _facturaBg(String v) {
  switch (v) {
    case 'Pagada':     return const Color(0xFFDCFCE7);
    case 'Enviada':    return const Color(0xFFDBEAFE);
    case 'Pendiente':  return const Color(0xFFFEF3C7);
    case 'Intercâmbio': return const Color(0xFFEDE9FE);
    default:           return const Color(0xFFF3F4F6);
  }
}

String _fmtFollowers(int n) {
  if (n >= 1000000) return '${(n / 1000000).toStringAsFixed(1)}M';
  if (n >= 1000) return '${(n / 1000).toStringAsFixed(0)}K';
  return n.toString();
}

// ── Chart color maps ──────────────────────────────────────────────────────────

const _catColors = {
  'Instagram': Color(0xFFE1306C),
  'TikTok': Color(0xFF010101),
  'Médicas/Especialistas': Color(0xFF2563EB),
  'CILAD': Color(0xFF7C3AED),
};

const _facturaColors = {
  'Pagada': Color(0xFF16A34A),
  'Pendiente': Color(0xFFB45309),
  'Enviada': Color(0xFF2563EB),
  'Intercâmbio': Color(0xFF7C3AED),
  'Sem fatura': Color(0xFFD1D5DB),
};

const _estadoChartColors = [
  Color(0xFF16A34A), Color(0xFF0D9488), Color(0xFF2563EB),
  Color(0xFF65A30D), Color(0xFFC2410C), Color(0xFF7C3AED),
  Color(0xFFDC2626), Color(0xFF6B7280),
];

const _barPalette = [
  Color(0xFF6366F1), Color(0xFFE1306C), Color(0xFF16A34A),
  Color(0xFF0D9488), Color(0xFFF59E0B), Color(0xFF2563EB),
  Color(0xFF7C3AED), Color(0xFFDC2626), Color(0xFF0891B2),
  Color(0xFFD97706),
];

// ── Portuguese month abbreviations ───────────────────────────────────────────

String _fmtMonth(String yyyyMM) {
  final parts = yyyyMM.split('-');
  if (parts.length != 2) return yyyyMM;
  final month = int.tryParse(parts[1]) ?? 0;
  final year = parts[0].substring(2); // last 2 digits
  const abbr = ['', 'Jan', 'Fev', 'Mar', 'Abr', 'Mai', 'Jun',
                     'Jul', 'Ago', 'Set', 'Out', 'Nov', 'Dez'];
  if (month < 1 || month > 12) return yyyyMM;
  return '${abbr[month]} $year';
}

// ── Dashboard Screen ──────────────────────────────────────────────────────────

class DashboardScreen extends StatefulWidget {
  final ValueChanged<int>? onNavigate;
  const DashboardScreen({super.key, this.onNavigate});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String? _subTitle;
  String? _subFilter; // 'mensual' | 'contactadas' | 'publicado' | 'firmado'

  void _openSub(String title, String filter) {
    setState(() {
      _subTitle = title;
      _subFilter = filter;
    });
  }

  void _closeSub() {
    setState(() {
      _subTitle = null;
      _subFilter = null;
    });
  }

  List<Influencer> _getList(DataProvider data) {
    switch (_subFilter) {
      case 'mensual':
        return data.allInfluencers.where((i) => i.isMensual).toList();
      case 'contactadas':
        return data.allInfluencers.where((i) => i.estado == 'Contactada').toList();
      case 'publicado':
        return data.allInfluencers.where((i) => i.estado == 'Contenido subido').toList();
      case 'firmado':
        return data.allInfluencers.where((i) => i.contrato == 'Firmado').toList();
      default:
        return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    final data = context.watch<DataProvider>();

    if (_subFilter != null) {
      return _InfluencerSubPage(
        title: _subTitle!,
        influencers: _getList(data),
        onBack: _closeSub,
      );
    }

    return _buildDashboard(context, data);
  }

  Widget _buildDashboard(BuildContext context, DataProvider data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Fixed header
        Container(
          height: 57,
          padding: const EdgeInsets.symmetric(horizontal: 32),
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: AppTheme.border)),
          ),
          child: const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Dashboard',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
                letterSpacing: -0.2,
              ),
            ),
          ),
        ),
        if (data.isLoading)
          const Expanded(
            child: Center(child: CircularProgressIndicator(color: AppTheme.accent)),
          )
        else
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(32, 24, 32, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Visão geral das parcerias Masderm Portugal',
                    style: TextStyle(fontSize: 13, color: AppTheme.textSecondary),
                  ),
                  const SizedBox(height: 28),

                  // Stat cards + carousel
                  SizedBox(
                    height: 218,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        SizedBox(
                          width: 700,
                          child: GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              crossAxisSpacing: 8,
                              mainAxisSpacing: 8,
                              mainAxisExtent: 105,
                            ),
                            itemCount: 6,
                            itemBuilder: (_, i) => [
                              _StatCard(
                                label: 'Total Influencers',
                                value: data.totalInfluencers.toString(),
                                icon: Icons.people_outline_rounded,
                                onTap: () => widget.onNavigate?.call(1),
                              ),
                              _StatCard(
                                label: 'Mensual',
                                value: data.mensual.toString(),
                                icon: Icons.star_outline_rounded,
                                valueColor: const Color(0xFF7C3AED),
                                onTap: () => _openSub('Mensual', 'mensual'),
                              ),
                              _StatCard(
                                label: 'Em Parceria',
                                value: data.ativas.toString(),
                                icon: Icons.handshake_outlined,
                                valueColor: AppTheme.scoreHigh,
                                onTap: () => widget.onNavigate?.call(2),
                              ),
                              _StatCard(
                                label: 'Contactadas',
                                value: data.contactadas.toString(),
                                icon: Icons.mail_outline_rounded,
                                onTap: () => _openSub('Contactadas', 'contactadas'),
                              ),
                              _StatCard(
                                label: 'Conteúdo Publicado',
                                value: data.conteudoSubido.toString(),
                                icon: Icons.check_circle_outline_rounded,
                                valueColor: AppTheme.scoreHigh,
                                onTap: () => _openSub('Conteúdo Publicado', 'publicado'),
                              ),
                              _StatCard(
                                label: 'Contrato Firmado',
                                value: data.contratoFirmado.toString(),
                                icon: Icons.description_outlined,
                                onTap: () => _openSub('Contrato Firmado', 'firmado'),
                              ),
                            ][i],
                          ),
                        ),
                        const SizedBox(width: 16),
                        const Expanded(
                          child: _ProductCarousel(produtos: _top5Masderm),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  const _ChartsSection(),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

// ── Charts Section ────────────────────────────────────────────────────────────

class _ChartsSection extends StatefulWidget {
  const _ChartsSection();

  @override
  State<_ChartsSection> createState() => _ChartsSectionState();
}

class _ChartsSectionState extends State<_ChartsSection> {
  Set<int> _selectedYears = {};
  Set<int> _selectedMonths = {}; // 1=Jan..12=Dec

  String? _filterPlataforma;
  String? _filterFactura;
  String? _filterEstado;

  bool get _hasTimeFilter => _selectedYears.isNotEmpty || _selectedMonths.isNotEmpty;

  List<Influencer> _chartInfluencers(DataProvider data) {
    return _crossFiltered(_timeFiltered(data));
  }

  List<Influencer> _globalFiltered(DataProvider data) {
    return _crossFiltered(data.allInfluencers.toList());
  }

  List<Influencer> _timeFiltered(DataProvider data) {
    if (!_hasTimeFilter) return data.allInfluencers.toList();
    return data.allInfluencers.where((inf) {
      if (inf.inicioPP == null || inf.finPP == null) return false;
      var cur = DateTime(inf.inicioPP!.year, inf.inicioPP!.month);
      final end = DateTime(inf.finPP!.year, inf.finPP!.month);
      while (!cur.isAfter(end)) {
        final yearOk = _selectedYears.isEmpty || _selectedYears.contains(cur.year);
        final monthOk = _selectedMonths.isEmpty || _selectedMonths.contains(cur.month);
        if (yearOk && monthOk) return true;
        cur = DateTime(cur.year, cur.month + 1);
      }
      return false;
    }).toList();
  }

  List<Influencer> _crossFiltered(List<Influencer> list) {
    var result = list;
    if (_filterPlataforma != null) result = result.where((i) => (i.categoria.isNotEmpty ? i.categoria : 'Instagram') == _filterPlataforma).toList();
    if (_filterFactura != null) result = result.where((i) => (i.factura.isNotEmpty ? i.factura : 'Sem fatura') == _filterFactura).toList();
    if (_filterEstado != null) result = result.where((i) => i.estado == _filterEstado).toList();
    return result;
  }

  Map<String, double> _computeFluxo(List<Influencer> list) {
    final map = <String, double>{};
    for (final i in list) {
      if (i.inicioPP == null || i.finPP == null || i.feeMensual <= 0) continue;
      var cur = DateTime(i.inicioPP!.year, i.inicioPP!.month);
      final end = DateTime(i.finPP!.year, i.finPP!.month);
      while (!cur.isAfter(end)) {
        final key = '${cur.year}-${cur.month.toString().padLeft(2, '0')}';
        map[key] = (map[key] ?? 0) + i.feeMensual;
        cur = DateTime(cur.year, cur.month + 1);
      }
    }
    return Map.fromEntries(map.entries.toList()..sort((a, b) => a.key.compareTo(b.key)));
  }

  @override
  Widget build(BuildContext context) {
    final data = context.watch<DataProvider>();

    // Derive available years from all influencer PP dates
    final years = <int>{};
    for (final inf in data.allInfluencers) {
      if (inf.inicioPP != null) years.add(inf.inicioPP!.year);
      if (inf.finPP != null) years.add(inf.finPP!.year);
    }
    final sortedYears = years.toList()..sort();

    final chartList = _chartInfluencers(data);
    final globalList = _globalFiltered(data);

    var fluxo = _computeFluxo(globalList);
    if (_hasTimeFilter) {
      fluxo = Map.fromEntries(fluxo.entries.where((e) {
        final parts = e.key.split('-');
        final y = int.parse(parts[0]);
        final m = int.parse(parts[1]);
        final yearOk = _selectedYears.isEmpty || _selectedYears.contains(y);
        final monthOk = _selectedMonths.isEmpty || _selectedMonths.contains(m);
        return yearOk && monthOk;
      }));
    }

    const monthLabels = ['Jan', 'Fev', 'Mar', 'Abr', 'Mai', 'Jun',
                          'Jul', 'Ago', 'Set', 'Out', 'Nov', 'Dez'];

    final hasActiveFilter = _filterPlataforma != null || _filterFactura != null || _filterEstado != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Slicers row: Ano + Mês side by side
        Row(
          children: [
            _DropdownSlicer<int>(
              title: 'Ano',
              items: sortedYears,
              selected: _selectedYears,
              labelOf: (y) => y.toString(),
              onToggle: (y) => setState(() {
                if (_selectedYears.contains(y)) {
                  _selectedYears = Set.from(_selectedYears)..remove(y);
                } else {
                  _selectedYears = Set.from(_selectedYears)..add(y);
                }
              }),
              onClear: _selectedYears.isNotEmpty ? () => setState(() => _selectedYears = {}) : null,
            ),
            const SizedBox(width: 12),
            _DropdownSlicer<int>(
              title: 'Mês',
              items: List.generate(12, (i) => i + 1),
              selected: _selectedMonths,
              labelOf: (m) => monthLabels[m - 1],
              onToggle: (m) => setState(() {
                if (_selectedMonths.contains(m)) {
                  _selectedMonths = Set.from(_selectedMonths)..remove(m);
                } else {
                  _selectedMonths = Set.from(_selectedMonths)..add(m);
                }
              }),
              onClear: _selectedMonths.isNotEmpty ? () => setState(() => _selectedMonths = {}) : null,
            ),
          ],
        ),

        // Active cross-filter badges
        if (hasActiveFilter) ...[
          const SizedBox(height: 8),
          Row(
            children: [
              if (_filterPlataforma != null)
                _ActiveFilterBadge(
                  label: 'Plataforma: $_filterPlataforma',
                  onClear: () => setState(() => _filterPlataforma = null),
                ),
              if (_filterFactura != null)
                _ActiveFilterBadge(
                  label: 'Fatura: $_filterFactura',
                  onClear: () => setState(() => _filterFactura = null),
                ),
              if (_filterEstado != null)
                _ActiveFilterBadge(
                  label: 'Estado: $_filterEstado',
                  onClear: () => setState(() => _filterEstado = null),
                ),
              const SizedBox(width: 4),
              GestureDetector(
                onTap: () => setState(() {
                  _filterPlataforma = null;
                  _filterFactura = null;
                  _filterEstado = null;
                }),
                child: const Text(
                  'Limpar filtros',
                  style: TextStyle(fontSize: 11, color: AppTheme.accent, fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
        ],

        const SizedBox(height: 16),

        // Row of 3 donut/bar charts
        SizedBox(
          height: 260,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(child: _PlatformDonut(
                influencers: chartList,
                selectedCategory: _filterPlataforma,
                onCategoryTap: (v) => setState(() => _filterPlataforma = _filterPlataforma == v ? null : v),
              )),
              const SizedBox(width: 12),
              Expanded(child: _InvestimentoDonut(
                influencers: chartList,
                selectedFactura: _filterFactura,
                onFacturaTap: (v) => setState(() => _filterFactura = _filterFactura == v ? null : v),
              )),
              const SizedBox(width: 12),
              Expanded(child: _EstadoBars(
                influencers: chartList,
                selectedEstado: _filterEstado,
                onEstadoTap: (v) => setState(() => _filterEstado = _filterEstado == v ? null : v),
              )),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Fluxo financeiro (full width)
        SizedBox(
          height: 240,
          child: _FluxoChart(fluxoMensal: fluxo),
        ),
        const SizedBox(height: 16),

        // Top 10 por investimento (full width)
        SizedBox(
          height: 280,
          child: _Top10Bars(influencers: globalList),
        ),

        // Payment Table
        _PpPaymentTable(influencers: globalList),
      ],
    );
  }
}

// ── Dropdown Slicer (Power BI style) ─────────────────────────────────────────

class _DropdownSlicer<T> extends StatefulWidget {
  final String title;
  final List<T> items;
  final Set<T> selected;
  final String Function(T) labelOf;
  final void Function(T) onToggle;
  final VoidCallback? onClear;

  const _DropdownSlicer({
    required this.title,
    required this.items,
    required this.selected,
    required this.labelOf,
    required this.onToggle,
    this.onClear,
    super.key,
  });

  @override
  State<_DropdownSlicer<T>> createState() => _DropdownSlicerState<T>();
}

class _DropdownSlicerState<T> extends State<_DropdownSlicer<T>> {
  bool _open = false;
  OverlayEntry? _overlay;
  final _layerLink = LayerLink();

  @override
  void dispose() {
    _removeOverlay();
    super.dispose();
  }

  @override
  void didUpdateWidget(_DropdownSlicer<T> old) {
    super.didUpdateWidget(old);
    if (_overlay != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _overlay?.markNeedsBuild());
    }
  }

  void _removeOverlay() {
    _overlay?.remove();
    _overlay = null;
  }

  void _close() {
    _removeOverlay();
    if (mounted) setState(() => _open = false);
  }

  void _toggle() {
    if (_open) {
      _close();
    } else {
      final overlay = Overlay.of(context);
      _overlay = OverlayEntry(builder: _buildDropdown);
      overlay.insert(_overlay!);
      setState(() => _open = true);
    }
  }

  Widget _buildDropdown(BuildContext ctx) {
    return Stack(
      children: [
        Positioned.fill(
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: _close,
          ),
        ),
        CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          targetAnchor: Alignment.bottomLeft,
          followerAnchor: Alignment.topLeft,
          offset: const Offset(0, 4),
          child: Material(
            color: Colors.transparent,
            child: Container(
              constraints: const BoxConstraints(maxHeight: 220, minWidth: 120, maxWidth: 180),
              decoration: BoxDecoration(
                color: AppTheme.cardBg,
                border: Border.all(color: AppTheme.border),
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (widget.onClear != null) ...[
                    InkWell(
                      onTap: () {
                        widget.onClear!();
                        WidgetsBinding.instance.addPostFrameCallback((_) => _overlay?.markNeedsBuild());
                      },
                      child: const Padding(
                        padding: EdgeInsets.fromLTRB(12, 8, 12, 6),
                        child: Text('(Selecionar Tudo)', style: TextStyle(fontSize: 12, color: AppTheme.textMuted)),
                      ),
                    ),
                    const Divider(height: 1),
                  ],
                  Flexible(
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: widget.items.map((item) {
                          final isSelected = widget.selected.contains(item);
                          return InkWell(
                            onTap: () {
                              widget.onToggle(item);
                              WidgetsBinding.instance.addPostFrameCallback((_) => _overlay?.markNeedsBuild());
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    isSelected ? Icons.check_box_rounded : Icons.check_box_outline_blank_rounded,
                                    size: 16,
                                    color: isSelected ? AppTheme.accent : AppTheme.textMuted,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    widget.labelOf(item),
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: isSelected ? AppTheme.textPrimary : AppTheme.textSecondary,
                                      fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final isActive = widget.selected.isNotEmpty;
    final label = isActive ? widget.selected.map(widget.labelOf).join(', ') : 'Todos';

    return CompositedTransformTarget(
      link: _layerLink,
      child: GestureDetector(
        onTap: _toggle,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          height: 34,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: AppTheme.cardBg,
            border: Border.all(
              color: _open || isActive ? AppTheme.accent : AppTheme.border,
              width: _open || isActive ? 1.5 : 1.0,
            ),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${widget.title}: ',
                style: const TextStyle(fontSize: 12, color: AppTheme.textMuted, fontWeight: FontWeight.w500),
              ),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 140),
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: isActive ? AppTheme.textPrimary : AppTheme.textSecondary,
                    fontWeight: isActive ? FontWeight.w500 : FontWeight.normal,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 4),
              Icon(
                _open ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                size: 18,
                color: AppTheme.textMuted,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Active Filter Badge ───────────────────────────────────────────────────────

class _ActiveFilterBadge extends StatelessWidget {
  final String label;
  final VoidCallback onClear;

  const _ActiveFilterBadge({required this.label, required this.onClear});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 6),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppTheme.accent.withValues(alpha: 0.1),
        border: Border.all(color: AppTheme.accent.withValues(alpha: 0.3)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: const TextStyle(fontSize: 11, color: AppTheme.accent, fontWeight: FontWeight.w500)),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: onClear,
            child: const Icon(Icons.close, size: 12, color: AppTheme.accent),
          ),
        ],
      ),
    );
  }
}

// ── Chart Card Wrapper ────────────────────────────────────────────────────────

class _ChartCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final Widget chart;

  const _ChartCard({
    required this.title,
    this.subtitle,
    this.trailing,
    required this.chart,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.cardBg,
        border: Border.all(color: AppTheme.border),
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
              if (trailing != null) ...[const Spacer(), trailing!],
            ],
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 2),
            Text(
              subtitle!,
              style: const TextStyle(fontSize: 11, color: AppTheme.textMuted),
            ),
          ],
          const SizedBox(height: 12),
          Expanded(child: chart),
        ],
      ),
    );
  }
}

// ── 1. Platform Donut ─────────────────────────────────────────────────────────

class _PlatformDonut extends StatelessWidget {
  final List<Influencer> influencers;
  final String? selectedCategory;
  final ValueChanged<String?> onCategoryTap;

  const _PlatformDonut({
    required this.influencers,
    required this.selectedCategory,
    required this.onCategoryTap,
  });

  @override
  Widget build(BuildContext context) {
    final counts = <String, int>{};
    for (final i in influencers) {
      final cat = i.categoria.isNotEmpty ? i.categoria : 'Instagram';
      counts[cat] = (counts[cat] ?? 0) + 1;
    }
    final total = counts.values.fold(0, (a, b) => a + b);
    final keys = counts.keys.toList();

    final sections = keys.asMap().entries.map((e) {
      final key = e.value;
      final color = _catColors[key] ?? const Color(0xFF6B7280);
      return PieChartSectionData(
        value: counts[key]!.toDouble(),
        color: color,
        radius: 38,
        showTitle: false,
      );
    }).toList();

    return _ChartCard(
      title: 'Plataforma',
      chart: Column(
        children: [
          SizedBox(
            height: 150,
            child: total == 0
                ? const Center(child: Text('Sem dados', style: TextStyle(fontSize: 11, color: AppTheme.textMuted)))
                : PieChart(
                    PieChartData(
                      sections: sections,
                      centerSpaceRadius: 44,
                      sectionsSpace: 2,
                      pieTouchData: PieTouchData(
                        touchCallback: (FlTouchEvent event, PieTouchResponse? response) {
                          if (event is! FlTapUpEvent || response?.touchedSection == null) return;
                          final idx = response!.touchedSection!.touchedSectionIndex;
                          if (idx >= 0 && idx < keys.length) onCategoryTap(keys[idx]);
                        },
                      ),
                    ),
                  ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 10,
            runSpacing: 4,
            alignment: WrapAlignment.center,
            children: counts.entries.map((e) {
              final color = _catColors[e.key] ?? const Color(0xFF6B7280);
              final isSelected = selectedCategory == e.key;
              return GestureDetector(
                onTap: () => onCategoryTap(e.key),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
                    const SizedBox(width: 4),
                    Text(
                      '${e.key} ${e.value}',
                      style: TextStyle(
                        fontSize: 10,
                        color: isSelected ? color : AppTheme.textSecondary,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

// ── 2. Investimento Donut ─────────────────────────────────────────────────────

class _InvestimentoDonut extends StatelessWidget {
  final List<Influencer> influencers;
  final String? selectedFactura;
  final ValueChanged<String?> onFacturaTap;

  const _InvestimentoDonut({
    required this.influencers,
    required this.selectedFactura,
    required this.onFacturaTap,
  });

  @override
  Widget build(BuildContext context) {
    final sums = <String, double>{};
    double total = 0;
    for (final i in influencers) {
      if (i.fee <= 0) continue;
      final key = i.factura.isNotEmpty ? i.factura : 'Sem fatura';
      sums[key] = (sums[key] ?? 0) + i.fee;
      total += i.fee;
    }
    final keys = sums.keys.toList();

    final sections = keys.asMap().entries.map((e) {
      final key = e.value;
      final color = _facturaColors[key] ?? const Color(0xFF6B7280);
      return PieChartSectionData(
        value: sums[key]!,
        color: color,
        radius: 38,
        showTitle: false,
      );
    }).toList();

    final totalStr = total >= 1000
        ? '€${(total / 1000).toStringAsFixed(1)}K'
        : '€${total.toStringAsFixed(0)}';

    return _ChartCard(
      title: 'Investimento €',
      chart: Column(
        children: [
          SizedBox(
            height: 150,
            child: total == 0
                ? const Center(child: Text('Sem dados', style: TextStyle(fontSize: 11, color: AppTheme.textMuted)))
                : Stack(
                    alignment: Alignment.center,
                    children: [
                      PieChart(
                        PieChartData(
                          sections: sections,
                          centerSpaceRadius: 44,
                          sectionsSpace: 2,
                          pieTouchData: PieTouchData(
                            touchCallback: (FlTouchEvent event, PieTouchResponse? response) {
                              if (event is! FlTapUpEvent || response?.touchedSection == null) return;
                              final idx = response!.touchedSection!.touchedSectionIndex;
                              if (idx >= 0 && idx < keys.length) onFacturaTap(keys[idx]);
                            },
                          ),
                        ),
                      ),
                      Text(
                        totalStr,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                    ],
                  ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 10,
            runSpacing: 4,
            alignment: WrapAlignment.center,
            children: sums.entries.map((e) {
              final color = _facturaColors[e.key] ?? const Color(0xFF6B7280);
              final isSelected = selectedFactura == e.key;
              return GestureDetector(
                onTap: () => onFacturaTap(e.key),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
                    const SizedBox(width: 4),
                    Text(
                      '${e.key} €${e.value.toStringAsFixed(0)}',
                      style: TextStyle(
                        fontSize: 10,
                        color: isSelected ? color : AppTheme.textSecondary,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

// ── 3. Estado Bars ────────────────────────────────────────────────────────────

class _EstadoBars extends StatelessWidget {
  final List<Influencer> influencers;
  final String? selectedEstado;
  final ValueChanged<String?> onEstadoTap;

  const _EstadoBars({
    required this.influencers,
    required this.selectedEstado,
    required this.onEstadoTap,
  });

  @override
  Widget build(BuildContext context) {
    final counts = <String, int>{};
    for (final i in influencers) {
      final key = i.estado.isNotEmpty ? i.estado : 'Sem estado';
      if (key == 'Sem estado') continue;
      counts[key] = (counts[key] ?? 0) + 1;
    }
    final sorted = counts.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    final top = sorted.take(6).toList();

    if (top.isEmpty) {
      return const _ChartCard(
        title: 'Estado das Parcerias',
        chart: Center(child: Text('Sem dados', style: TextStyle(fontSize: 11, color: AppTheme.textMuted))),
      );
    }

    final maxVal = top.first.value.toDouble();

    final groups = top.asMap().entries.map((e) {
      final isSelected = selectedEstado == e.value.key;
      final color = isSelected
          ? AppTheme.accent
          : _estadoChartColors[e.key % _estadoChartColors.length];
      return BarChartGroupData(
        x: e.key,
        barRods: [
          BarChartRodData(
            toY: e.value.value.toDouble(),
            color: color,
            width: 18,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(3)),
          ),
        ],
      );
    }).toList();

    return _ChartCard(
      title: 'Estado das Parcerias',
      chart: BarChart(
        BarChartData(
          barGroups: groups,
          maxY: maxVal * 1.2,
          borderData: FlBorderData(show: false),
          gridData: const FlGridData(
            show: true,
            drawVerticalLine: false,
          ),
          titlesData: FlTitlesData(
            leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                getTitlesWidget: (value, meta) {
                  final idx = value.toInt();
                  if (idx < 0 || idx >= top.length) return const SizedBox();
                  final label = top[idx].key;
                  final short = label.length > 8 ? '${label.substring(0, 8)}…' : label;
                  return Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Transform.rotate(
                      angle: -0.5,
                      child: Text(
                        short,
                        style: const TextStyle(fontSize: 9, color: AppTheme.textMuted),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          barTouchData: BarTouchData(
            touchCallback: (FlTouchEvent event, BarTouchResponse? response) {
              if (event is! FlTapUpEvent || response?.spot == null) return;
              final idx = response!.spot!.touchedBarGroupIndex;
              if (idx >= 0 && idx < top.length) onEstadoTap(top[idx].key);
            },
            touchTooltipData: BarTouchTooltipData(
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                final label = top[group.x].key;
                return BarTooltipItem(
                  '$label\n${rod.toY.toInt()}',
                  const TextStyle(fontSize: 11, color: Colors.white),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

// ── 4. Fluxo Chart ────────────────────────────────────────────────────────────

class _FluxoChart extends StatelessWidget {
  final Map<String, double> fluxoMensal;

  const _FluxoChart({required this.fluxoMensal});

  @override
  Widget build(BuildContext context) {
    final months = fluxoMensal.keys.toList();
    final now = DateTime.now();
    final currentKey = '${now.year}-${now.month.toString().padLeft(2, '0')}';

    if (months.isEmpty) {
      return const _ChartCard(
        title: 'Fluxo Financeiro Mensal',
        subtitle: 'Fee acumulado por mês (€)',
        chart: Center(child: Text('Sem dados', style: TextStyle(fontSize: 11, color: AppTheme.textMuted))),
      );
    }

    final maxVal = fluxoMensal.values.fold(0.0, (a, b) => a > b ? a : b);

    final groups = months.asMap().entries.map((e) {
      final key = e.value;
      final value = fluxoMensal[key] ?? 0;

      Color barColor;
      if (key.compareTo(currentKey) < 0) {
        barColor = const Color(0xFF16A34A);
      } else if (key == currentKey) {
        barColor = const Color(0xFFE87C2C);
      } else {
        barColor = const Color(0xFFD1D5DB);
      }

      return BarChartGroupData(
        x: e.key,
        barRods: [
          BarChartRodData(
            toY: value,
            color: barColor,
            width: months.length > 12 ? 14 : 20,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(3)),
          ),
        ],
      );
    }).toList();

    return _ChartCard(
      title: 'Fluxo Financeiro Mensal',
      subtitle: 'Fee acumulado por mês (€)',
      chart: BarChart(
        BarChartData(
          barGroups: groups,
          maxY: maxVal * 1.2,
          borderData: FlBorderData(show: false),
          gridData: const FlGridData(
            show: true,
            drawVerticalLine: false,
          ),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 48,
                getTitlesWidget: (value, meta) {
                  if (value == 0) return const SizedBox();
                  final label = value >= 1000
                      ? '€${(value / 1000).toStringAsFixed(1)}K'
                      : '€${value.toStringAsFixed(0)}';
                  return Text(label, style: const TextStyle(fontSize: 9, color: AppTheme.textMuted));
                },
              ),
            ),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 28,
                getTitlesWidget: (value, meta) {
                  final idx = value.toInt();
                  if (idx < 0 || idx >= months.length) return const SizedBox();
                  return Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      _fmtMonth(months[idx]),
                      style: const TextStyle(fontSize: 9, color: AppTheme.textMuted),
                    ),
                  );
                },
              ),
            ),
          ),
          barTouchData: BarTouchData(
            touchTooltipData: BarTouchTooltipData(
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                final key = months[group.x];
                return BarTooltipItem(
                  '${_fmtMonth(key)}\n€${rod.toY.toStringAsFixed(0)}',
                  const TextStyle(fontSize: 11, color: Colors.white),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

// ── 5. Top 10 Bars ────────────────────────────────────────────────────────────

class _Top10Bars extends StatefulWidget {
  final List<Influencer> influencers;
  const _Top10Bars({required this.influencers});

  @override
  State<_Top10Bars> createState() => _Top10BarsState();
}

class _Top10BarsState extends State<_Top10Bars> {
  String _mode = 'total'; // 'total' | 'mensal'

  @override
  Widget build(BuildContext context) {
    // Top 10 always ranked by total fee; Mensal mode filters to active (finPP >= current month) and shows feeMensual
    final now = DateTime.now();
    final currentMonth = DateTime(now.year, now.month);
    final byFee = widget.influencers.where((i) => i.fee > 0).toList()
      ..sort((a, b) => b.fee.compareTo(a.fee));
    final top10ByFee = byFee.take(10).toList();
    final top = _mode == 'mensal'
        ? top10ByFee.where((i) {
            if (i.finPP == null || i.feeMensual <= 0) return false;
            final fin = DateTime(i.finPP!.year, i.finPP!.month);
            return !fin.isBefore(currentMonth);
          }).toList()
        : top10ByFee;

    final modeToggle = Row(
      mainAxisSize: MainAxisSize.min,
      children: ['Total', 'Mensal'].map((m) {
        final active = _mode == m.toLowerCase();
        return GestureDetector(
          onTap: () => setState(() => _mode = m.toLowerCase()),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 130),
            margin: const EdgeInsets.only(left: 4),
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
            decoration: BoxDecoration(
              color: active ? AppTheme.accent : Colors.transparent,
              border: Border.all(color: active ? AppTheme.accent : AppTheme.border),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              m,
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: active ? Colors.white : AppTheme.textSecondary),
            ),
          ),
        );
      }).toList(),
    );

    if (top.isEmpty) {
      return _ChartCard(
        title: 'Top 10 por Investimento',
        trailing: modeToggle,
        chart: const Center(child: Text('Sem dados', style: TextStyle(fontSize: 11, color: AppTheme.textMuted))),
      );
    }

    final maxVal = top.isEmpty ? 1.0 : top.map((i) => _mode == 'mensal' ? i.feeMensual : i.fee).fold(0.0, (a, b) => a > b ? a : b);

    final groups = top.asMap().entries.map((e) {
      final color = _barPalette[e.key % _barPalette.length];
      final value = _mode == 'mensal' ? e.value.feeMensual : e.value.fee;
      return BarChartGroupData(
        x: e.key,
        barRods: [
          BarChartRodData(
            toY: value,
            color: color,
            width: 18,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(3)),
          ),
        ],
      );
    }).toList();

    return _ChartCard(
      title: 'Top 10 por Investimento',
      trailing: modeToggle,
      chart: BarChart(
        BarChartData(
          barGroups: groups,
          maxY: maxVal * 1.2,
          borderData: FlBorderData(show: false),
          gridData: const FlGridData(show: true, drawVerticalLine: false),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 48,
                getTitlesWidget: (value, meta) {
                  if (value == 0) return const SizedBox();
                  final label = value >= 1000
                      ? '€${(value / 1000).toStringAsFixed(1)}K'
                      : '€${value.toStringAsFixed(0)}';
                  return Text(label, style: const TextStyle(fontSize: 9, color: AppTheme.textMuted));
                },
              ),
            ),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                getTitlesWidget: (value, meta) {
                  final idx = value.toInt();
                  if (idx < 0 || idx >= top.length) return const SizedBox();
                  final nome = top[idx].nome.split(' ').first;
                  final short = nome.length > 12 ? nome.substring(0, 12) : nome;
                  return Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Transform.rotate(
                      angle: -0.5,
                      child: Text(short, style: const TextStyle(fontSize: 9, color: AppTheme.textMuted)),
                    ),
                  );
                },
              ),
            ),
          ),
          barTouchData: BarTouchData(
            touchTooltipData: BarTouchTooltipData(
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                final inf = top[group.x];
                final val = _mode == 'mensal' ? inf.feeMensual : inf.fee;
                final label = _mode == 'mensal' ? 'Fee mensal' : 'Fee total';
                return BarTooltipItem(
                  '${inf.nome}\n$label: €${val.toStringAsFixed(0)}',
                  const TextStyle(fontSize: 11, color: Colors.white),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

// ── 6. PP Payment Table ───────────────────────────────────────────────────────

class _PpPaymentTable extends StatefulWidget {
  final List<Influencer> influencers;
  const _PpPaymentTable({required this.influencers});
  @override State<_PpPaymentTable> createState() => _PpPaymentTableState();
}

class _PpPaymentTableState extends State<_PpPaymentTable> {
  String _sortCol = 'inicioPP';
  bool _sortAsc = true;
  String _search = '';
  Set<int> _yearFilter = {};
  Set<int> _monthFilter = {};
  Set<String> _ativoFilter = {};
  final _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  int _parcelasPagas(Influencer i) {
    if (i.inicioPP == null) return 0;
    final now = DateTime.now();
    final current = DateTime(now.year, now.month);
    final start = DateTime(i.inicioPP!.year, i.inicioPP!.month);
    if (current.isBefore(start)) return 0;
    final endDate = i.finPP != null ? DateTime(i.finPP!.year, i.finPP!.month) : current;
    final last = current.isBefore(endDate) ? current : endDate;
    return (last.year - start.year) * 12 + (last.month - start.month) + 1;
  }

  @override
  Widget build(BuildContext context) {
    // All influencers with PP data
    final all = widget.influencers
        .where((i) => i.inicioPP != null && i.feeMensual > 0)
        .toList();
    if (all.isEmpty) return const SizedBox();

    // Available years/months for slicers
    final availableYears = all.map((i) => i.inicioPP!.year).toSet().toList()..sort();

    // Apply search + year + month + ativo filter
    var ppList = all.where((i) {
      final yearOk = _yearFilter.isEmpty || _yearFilter.contains(i.inicioPP!.year);
      final monthOk = _monthFilter.isEmpty || _monthFilter.contains(i.inicioPP!.month);
      if (!yearOk || !monthOk) return false;
      if (_ativoFilter.isNotEmpty) {
        final pagas = _parcelasPagas(i);
        final total = i.mesesPP > 0 ? i.mesesPP : (i.finPP != null
            ? (i.finPP!.year - i.inicioPP!.year) * 12 + (i.finPP!.month - i.inicioPP!.month) + 1
            : pagas);
        final restantes = (total - pagas).clamp(0, total);
        final ativo = restantes > 0 ? 'Sim' : 'Não';
        if (!_ativoFilter.contains(ativo)) return false;
      }
      if (_search.isEmpty) return true;
      final q = _search.toLowerCase();
      return i.nome.toLowerCase().contains(q) || i.handle.toLowerCase().contains(q);
    }).toList();

    ppList.sort((a, b) {
      int cmp;
      switch (_sortCol) {
        case 'inicioPP': cmp = (a.inicioPP ?? DateTime(0)).compareTo(b.inicioPP ?? DateTime(0)); break;
        case 'nome': cmp = a.nome.compareTo(b.nome); break;
        case 'feeMensual': cmp = a.feeMensual.compareTo(b.feeMensual); break;
        case 'jaPago': cmp = (_parcelasPagas(a) * a.feeMensual).compareTo(_parcelasPagas(b) * b.feeMensual); break;
        default: cmp = 0;
      }
      return _sortAsc ? cmp : -cmp;
    });

    void sort(String col) => setState(() {
      if (_sortCol == col) { _sortAsc = !_sortAsc; } else { _sortCol = col; _sortAsc = true; }
    });

    return Container(
      margin: const EdgeInsets.only(top: 16),
      decoration: BoxDecoration(
        color: AppTheme.cardBg,
        border: Border.all(color: AppTheme.border),
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title + count
          Row(children: [
            const Text('Calendário de Pagamentos PP', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
            const SizedBox(width: 8),
            Text('(${ppList.length} de ${all.length})', style: const TextStyle(fontSize: 12, color: AppTheme.textMuted)),
          ]),
          const SizedBox(height: 12),
          // Search + year slicer row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Search bar
              SizedBox(
                width: 240,
                height: 34,
                child: TextField(
                  controller: _searchCtrl,
                  onChanged: (v) => setState(() => _search = v),
                  decoration: InputDecoration(
                    hintText: 'Pesquisar influencer…',
                    hintStyle: const TextStyle(fontSize: 12, color: AppTheme.textMuted),
                    prefixIcon: const Icon(Icons.search, size: 15, color: AppTheme.textMuted),
                    contentPadding: EdgeInsets.zero,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: const BorderSide(color: AppTheme.border)),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: const BorderSide(color: AppTheme.border)),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: const BorderSide(color: AppTheme.accent)),
                  ),
                  style: const TextStyle(fontSize: 12),
                ),
              ),
              const SizedBox(width: 12),
              // Início PP — Ano dropdown
              _DropdownSlicer<int>(
                title: 'Ano PP',
                items: availableYears,
                selected: _yearFilter,
                labelOf: (y) => y.toString(),
                onToggle: (y) => setState(() {
                  if (_yearFilter.contains(y)) {
                    _yearFilter = Set.from(_yearFilter)..remove(y);
                  } else {
                    _yearFilter = Set.from(_yearFilter)..add(y);
                  }
                }),
                onClear: _yearFilter.isNotEmpty ? () => setState(() => _yearFilter = {}) : null,
              ),
              const SizedBox(width: 8),
              // Início PP — Mês dropdown
              _DropdownSlicer<int>(
                title: 'Mês PP',
                items: List.generate(12, (i) => i + 1),
                selected: _monthFilter,
                labelOf: (m) => const ['Jan','Fev','Mar','Abr','Mai','Jun','Jul','Ago','Set','Out','Nov','Dez'][m - 1],
                onToggle: (m) => setState(() {
                  if (_monthFilter.contains(m)) {
                    _monthFilter = Set.from(_monthFilter)..remove(m);
                  } else {
                    _monthFilter = Set.from(_monthFilter)..add(m);
                  }
                }),
                onClear: _monthFilter.isNotEmpty ? () => setState(() => _monthFilter = {}) : null,
              ),
              const SizedBox(width: 8),
              _DropdownSlicer<String>(
                title: 'Ativo',
                items: const ['Sim', 'Não'],
                selected: _ativoFilter,
                labelOf: (v) => v,
                onToggle: (v) => setState(() {
                  if (_ativoFilter.contains(v)) {
                    _ativoFilter = Set.from(_ativoFilter)..remove(v);
                  } else {
                    _ativoFilter = Set.from(_ativoFilter)..add(v);
                  }
                }),
                onClear: _ativoFilter.isNotEmpty ? () => setState(() => _ativoFilter = {}) : null,
              ),
            ],
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              sortColumnIndex: ['nome','inicioPP','feeMensual','total','jaPago','aPagar','pagas','restantes','ativo'].indexOf(_sortCol).clamp(0, 8),
              sortAscending: _sortAsc,
              headingRowHeight: 38,
              dataRowMinHeight: 44,
              dataRowMaxHeight: 56,
              columnSpacing: 20,
              horizontalMargin: 0,
              headingRowColor: WidgetStateProperty.all(AppTheme.background),
              headingTextStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppTheme.textMuted),
              columns: [
                DataColumn(label: const Text('Influencer'), onSort: (_, __) => sort('nome')),
                DataColumn(label: const Text('Início PP'), onSort: (_, __) => sort('inicioPP')),
                DataColumn(label: const Text('Fee Mensal'), numeric: true, onSort: (_, __) => sort('feeMensual')),
                const DataColumn(label: Text('Total Contrato'), numeric: true),
                DataColumn(label: const Text('Já Pago'), numeric: true, onSort: (_, __) => sort('jaPago')),
                const DataColumn(label: Text('A Pagar'), numeric: true),
                const DataColumn(label: Text('Parcelas Pagas'), numeric: true),
                const DataColumn(label: Text('Parcelas Restantes'), numeric: true),
                const DataColumn(label: Text('Ativo')),
              ],
              rows: ppList.map((inf) {
                final pagas = _parcelasPagas(inf);
                final total = inf.mesesPP > 0 ? inf.mesesPP : (inf.finPP != null && inf.inicioPP != null
                    ? (inf.finPP!.year - inf.inicioPP!.year) * 12 + (inf.finPP!.month - inf.inicioPP!.month) + 1
                    : pagas);
                final restantes = (total - pagas).clamp(0, total);
                final jaPago = pagas * inf.feeMensual;
                final aPagar = restantes * inf.feeMensual;
                final totalContrato = total * inf.feeMensual;
                final ativo = restantes > 0;

                return DataRow(cells: [
                  DataCell(ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 160),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(inf.nome, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500), overflow: TextOverflow.ellipsis),
                        if (inf.handle.isNotEmpty)
                          Text(inf.handle, style: const TextStyle(fontSize: 11, color: AppTheme.accent), overflow: TextOverflow.ellipsis),
                      ],
                    ),
                  )),
                  DataCell(Text(
                    inf.inicioPP != null ? '${inf.inicioPP!.year}-${inf.inicioPP!.month.toString().padLeft(2,'0')}' : '—',
                    style: const TextStyle(fontSize: 12),
                  )),
                  DataCell(Text('€${inf.feeMensual.toStringAsFixed(0)}', style: const TextStyle(fontSize: 12))),
                  DataCell(Text('€${totalContrato.toStringAsFixed(0)}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500))),
                  DataCell(Text('€${jaPago.toStringAsFixed(0)}', style: const TextStyle(fontSize: 12, color: Color(0xFF16A34A)))),
                  DataCell(Text('€${aPagar.toStringAsFixed(0)}', style: TextStyle(fontSize: 12, color: aPagar > 0 ? const Color(0xFFB45309) : AppTheme.textMuted))),
                  DataCell(Text('$pagas', style: const TextStyle(fontSize: 12))),
                  DataCell(Text('$restantes', style: TextStyle(fontSize: 12, fontWeight: restantes > 0 ? FontWeight.w500 : FontWeight.normal))),
                  DataCell(Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: ativo ? const Color(0xFFDCFCE7) : const Color(0xFFF3F4F6),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      ativo ? 'Sim' : 'Não',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: ativo ? const Color(0xFF16A34A) : AppTheme.textMuted),
                    ),
                  )),
                ]);
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Influencer Sub-Page ───────────────────────────────────────────────────────

class _InfluencerSubPage extends StatefulWidget {
  final String title;
  final List<Influencer> influencers;
  final VoidCallback onBack;

  const _InfluencerSubPage({
    required this.title,
    required this.influencers,
    required this.onBack,
  });

  @override
  State<_InfluencerSubPage> createState() => _InfluencerSubPageState();
}

class _InfluencerSubPageState extends State<_InfluencerSubPage> {
  final _searchCtrl = TextEditingController();
  String _search = '';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<Influencer> get _filtered {
    if (_search.isEmpty) return widget.influencers;
    final q = _search.toLowerCase();
    return widget.influencers.where((i) =>
        i.nome.toLowerCase().contains(q) ||
        i.handle.toLowerCase().contains(q) ||
        i.contacto.toLowerCase().contains(q)).toList();
  }

  @override
  Widget build(BuildContext context) {
    final list = _filtered;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header with back button
        Container(
          height: 57,
          padding: const EdgeInsets.symmetric(horizontal: 32),
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: AppTheme.border)),
          ),
          child: Row(
            children: [
              _BackButton(onTap: widget.onBack),
              const SizedBox(width: 12),
              Container(width: 1, height: 16, color: AppTheme.border),
              const SizedBox(width: 12),
              Text(
                widget.title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                  letterSpacing: -0.2,
                ),
              ),
            ],
          ),
        ),
        // Filter bar
        Padding(
          padding: const EdgeInsets.fromLTRB(32, 16, 32, 12),
          child: Row(
            children: [
              SizedBox(
                width: 260,
                height: 36,
                child: TextField(
                  controller: _searchCtrl,
                  onChanged: (v) => setState(() => _search = v),
                  decoration: InputDecoration(
                    hintText: 'Pesquisar nome, handle, contacto…',
                    hintStyle: const TextStyle(fontSize: 13, color: AppTheme.textMuted),
                    prefixIcon: const Icon(Icons.search, size: 16, color: AppTheme.textMuted),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6),
                      borderSide: const BorderSide(color: AppTheme.border),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6),
                      borderSide: const BorderSide(color: AppTheme.border),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6),
                      borderSide: const BorderSide(color: AppTheme.accent),
                    ),
                  ),
                  style: const TextStyle(fontSize: 13),
                ),
              ),
              const Spacer(),
              Text(
                '${list.length} influencer${list.length == 1 ? '' : 's'}',
                style: const TextStyle(fontSize: 13, color: AppTheme.textMuted),
              ),
            ],
          ),
        ),
        // Table
        Expanded(
          child: list.isEmpty
              ? const Center(
                  child: Text('Sem resultados',
                      style: TextStyle(color: AppTheme.textMuted)),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(32, 0, 32, 32),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: AppTheme.border),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: DataTable(
                        headingRowHeight: 40,
                        dataRowMinHeight: 52,
                        dataRowMaxHeight: 72,
                        columnSpacing: 20,
                        horizontalMargin: 16,
                        headingRowColor: WidgetStateProperty.all(
                          AppTheme.background,
                        ),
                        headingTextStyle: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textMuted,
                        ),
                        columns: const [
                          DataColumn(label: Text('Nome')),
                          DataColumn(label: Text('Estado')),
                          DataColumn(label: Text('Contacto')),
                          DataColumn(label: Text('Followers'), numeric: true),
                          DataColumn(label: Text('Contrato')),
                          DataColumn(label: Text('PP')),
                          DataColumn(label: Text('Factura')),
                          DataColumn(label: Text('Produtos')),
                          DataColumn(label: Text('Notas')),
                        ],
                        rows: list.map(_buildRow).toList(),
                      ),
                    ),
                  ),
                ),
        ),
      ],
    );
  }

  DataRow _buildRow(Influencer inf) {
    final (estadoColor, estadoBg) = _estadoColors(inf.estado);

    return DataRow(cells: [
      // Nome + handle
      DataCell(
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              inf.nome,
              style: const TextStyle(
                  fontSize: 13, fontWeight: FontWeight.w500),
            ),
            if (inf.handle.isNotEmpty)
              GestureDetector(
                onTap: inf.link.isNotEmpty
                    ? () => launchUrl(Uri.parse(inf.link),
                        mode: LaunchMode.externalApplication)
                    : null,
                child: Text(
                  inf.handle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.accent,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
          ],
        ),
      ),
      // Estado
      DataCell(
        inf.estado.isNotEmpty
            ? Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: estadoBg,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  inf.estado,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: estadoColor,
                  ),
                ),
              )
            : const SizedBox(),
      ),
      // Contacto
      DataCell(
        inf.contacto.isNotEmpty
            ? ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 180),
                child: Text(
                  inf.contacto,
                  style: const TextStyle(fontSize: 12),
                  overflow: TextOverflow.ellipsis,
                ),
              )
            : const Text('—',
                style: TextStyle(
                    fontSize: 12, color: AppTheme.textMuted)),
      ),
      // Followers
      DataCell(Text(
        inf.followers > 0 ? _fmtFollowers(inf.followers) : '—',
        style: const TextStyle(fontSize: 13),
      )),
      // Contrato
      DataCell(
        inf.contrato.isNotEmpty
            ? Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: inf.contrato == 'Firmado'
                      ? const Color(0xFFDCFCE7)
                      : const Color(0xFFFFEDD5),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  inf.contrato,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: inf.contrato == 'Firmado'
                        ? const Color(0xFF16A34A)
                        : const Color(0xFFC2410C),
                  ),
                ),
              )
            : const Text('—',
                style: TextStyle(
                    fontSize: 12, color: AppTheme.textMuted)),
      ),
      // PP
      DataCell(
        inf.pp.isNotEmpty
            ? Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: inf.pp == 'Aceptado'
                      ? const Color(0xFFDCFCE7)
                      : const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  inf.pp,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: inf.pp == 'Aceptado'
                        ? const Color(0xFF16A34A)
                        : const Color(0xFFB45309),
                  ),
                ),
              )
            : const Text('—',
                style: TextStyle(
                    fontSize: 12, color: AppTheme.textMuted)),
      ),
      // Factura
      DataCell(
        inf.factura.isNotEmpty
            ? Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: _facturaBg(inf.factura),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  inf.factura,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: _facturaColor(inf.factura),
                  ),
                ),
              )
            : const Text('—',
                style: TextStyle(
                    fontSize: 12, color: AppTheme.textMuted)),
      ),
      // Produtos
      DataCell(
        inf.produtosAtivos.isNotEmpty
            ? Wrap(
                spacing: 4,
                runSpacing: 4,
                children: inf.produtosAtivos
                    .map((p) => Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 5, vertical: 1),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF3F4F6),
                            borderRadius: BorderRadius.circular(3),
                          ),
                          child: Text(p,
                              style: const TextStyle(
                                  fontSize: 10,
                                  color: AppTheme.textSecondary)),
                        ))
                    .toList(),
              )
            : const Text('—',
                style: TextStyle(
                    fontSize: 12, color: AppTheme.textMuted)),
      ),
      // Notas
      DataCell(
        inf.notas.isNotEmpty
            ? ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 200),
                child: Text(
                  inf.notas,
                  style: const TextStyle(
                      fontSize: 11,
                      color: AppTheme.textMuted,
                      fontStyle: FontStyle.italic),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                ),
              )
            : const SizedBox(),
      ),
    ]);
  }
}

// ── Back Button ───────────────────────────────────────────────────────────────

class _BackButton extends StatefulWidget {
  final VoidCallback onTap;
  const _BackButton({required this.onTap});

  @override
  State<_BackButton> createState() => _BackButtonState();
}

class _BackButtonState extends State<_BackButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
          decoration: BoxDecoration(
            color: _hovered ? AppTheme.background : Colors.transparent,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 13,
                color: _hovered ? AppTheme.textPrimary : AppTheme.textSecondary,
              ),
              const SizedBox(width: 5),
              Text(
                'Dashboard',
                style: TextStyle(
                  fontSize: 13,
                  color: _hovered ? AppTheme.textPrimary : AppTheme.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Product Carousel ──────────────────────────────────────────────────────────

class _ProductCarousel extends StatefulWidget {
  final List<_StoreProduct> produtos;
  const _ProductCarousel({required this.produtos});

  @override
  State<_ProductCarousel> createState() => _ProductCarouselState();
}

class _ProductCarouselState extends State<_ProductCarousel> {
  late PageController _ctrl;
  int _current = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _ctrl = PageController();
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    if (widget.produtos.isEmpty) return;
    _timer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (!mounted || widget.produtos.isEmpty) return;
      final next = (_current + 1) % widget.produtos.length;
      setState(() => _current = next);
      _ctrl.animateToPage(next,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut);
    });
  }

  void _goTo(int i) {
    setState(() => _current = i);
    _ctrl.animateToPage(i,
        duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.cardBg,
        border: Border.all(color: AppTheme.border),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 13, 16, 0),
            child: Row(
              children: [
                const Icon(Icons.local_offer_outlined,
                    size: 13, color: AppTheme.textMuted),
                const SizedBox(width: 6),
                const Text('Produtos em destaque',
                    style: TextStyle(
                        fontSize: 11, color: AppTheme.textSecondary)),
                const Spacer(),
                Text('${_current + 1}/${widget.produtos.length}',
                    style: const TextStyle(
                        fontSize: 11, color: AppTheme.textMuted)),
              ],
            ),
          ),
          Expanded(
            child: PageView.builder(
              controller: _ctrl,
              itemCount: widget.produtos.length,
              onPageChanged: (i) => setState(() => _current = i),
              itemBuilder: (_, i) =>
                  _ProductPage(produto: widget.produtos[i]),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Row(
              children: List.generate(
                widget.produtos.length,
                (i) => GestureDetector(
                  onTap: () => _goTo(i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeOut,
                    margin: const EdgeInsets.only(right: 5),
                    width: i == _current ? 18 : 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: i == _current ? AppTheme.accent : AppTheme.border,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProductPage extends StatelessWidget {
  final _StoreProduct produto;
  const _ProductPage({required this.produto});

  String _formatReviews(int n) {
    final s = n.toString();
    if (s.length > 3) {
      return '${s.substring(0, s.length - 3)}.${s.substring(s.length - 3)}';
    }
    return s;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Product image — 180px, clickable
          MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: () => launchUrl(Uri.parse(produto.url), mode: LaunchMode.externalApplication),
              child: SizedBox(
                width: 180,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: Image.network(
                    produto.imageUrl,
                    fit: BoxFit.cover,
                    loadingBuilder: (_, child, progress) => progress == null
                        ? child
                        : Container(
                            color: AppTheme.background,
                            child: const Center(
                              child: SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                    strokeWidth: 1.5, color: AppTheme.accent),
                              ),
                            ),
                          ),
                    errorBuilder: (_, __, ___) => Container(
                      color: AppTheme.background,
                      child: const Icon(Icons.image_not_supported_outlined,
                          color: AppTheme.textMuted, size: 20),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      produto.nome,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                        letterSpacing: -0.2,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (produto.reviews > 0) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.star_rounded,
                              size: 13, color: Color(0xFFE87C2C)),
                          const SizedBox(width: 3),
                          Text(
                            '${_formatReviews(produto.reviews)} avaliações',
                            style: const TextStyle(
                                fontSize: 12, color: AppTheme.textMuted),
                          ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 6),
                    Text(
                      produto.descricao,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppTheme.textSecondary,
                        height: 1.4,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppTheme.scoreHighBg,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        produto.preco,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.scoreHigh,
                        ),
                      ),
                    ),
                    const Spacer(),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Stat Card ─────────────────────────────────────────────────────────────────

class _StatCard extends StatefulWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color? valueColor;
  final VoidCallback? onTap;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    this.valueColor,
    this.onTap,
  });

  @override
  State<_StatCard> createState() => _StatCardState();
}

class _StatCardState extends State<_StatCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final clickable = widget.onTap != null;
    return MouseRegion(
      cursor: clickable ? SystemMouseCursors.click : MouseCursor.defer,
      onEnter: (_) { if (clickable) setState(() => _hovered = true); },
      onExit: (_) { if (clickable) setState(() => _hovered = false); },
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          curve: Curves.easeOut,
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
          decoration: BoxDecoration(
            color: _hovered ? AppTheme.background : AppTheme.cardBg,
            border: Border.all(
              color: _hovered ? AppTheme.accent : AppTheme.border,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(widget.icon, size: 13, color: AppTheme.textMuted),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      widget.label,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppTheme.textSecondary,
                        fontWeight: FontWeight.w400,
                        height: 1.3,
                      ),
                    ),
                  ),
                ],
              ),
              Text(
                widget.value,
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w600,
                  color: widget.valueColor ?? AppTheme.textPrimary,
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
