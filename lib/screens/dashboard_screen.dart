import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/data_provider.dart';
import '../theme/app_theme.dart';
import '../models/influencer.dart';

// ── Store products ─────────────────────────────────────────────────────────────

class _StoreProduct {
  final String nome;
  final String descricao;
  final String preco;
  final String imageUrl;
  final int reviews;
  const _StoreProduct({
    required this.nome,
    required this.descricao,
    required this.preco,
    required this.imageUrl,
    required this.reviews,
  });
}

const _top5Masderm = [
  _StoreProduct(
    nome: 'RF Body Firming 1000ml',
    descricao: 'Creme corporal firmador por radiofrequência',
    preco: '€28,90',
    imageUrl: 'https://cdn.shopify.com/s/files/1/0076/1230/1394/products/rf-body-firming-1000ml-636354.jpg?v=1738646787',
    reviews: 3933,
  ),
  _StoreProduct(
    nome: 'RF Facial Cream',
    descricao: 'Creme facial firmador de radiofrequência 500ml–1000ml',
    preco: 'A partir de €26,90',
    imageUrl: 'https://cdn.shopify.com/s/files/1/0076/1230/1394/files/rf-facial-cream-4650422.jpg?v=1774685296',
    reviews: 2213,
  ),
  _StoreProduct(
    nome: 'RF Body Slim',
    descricao: 'Creme anticelulite de radiofrequência 500ml–1000ml',
    preco: 'A partir de €26,90',
    imageUrl: 'https://cdn.shopify.com/s/files/1/0076/1230/1394/files/rf-body-slim-684877.webp?v=1711611314',
    reviews: 1570,
  ),
  _StoreProduct(
    nome: 'RF Tratamento de Flacidez Corporal',
    descricao: 'Tratamento completo por radiofrequência para flacidez corporal',
    preco: '€128,80',
    imageUrl: 'https://cdn.shopify.com/s/files/1/0076/1230/1394/files/rf-tratamiento-flacidez-corporal-8276015.jpg?v=1779409152',
    reviews: 861,
  ),
  _StoreProduct(
    nome: 'Serum Triphasic 100ml',
    descricao: 'Sérum trifásico anti-manchas e uniformizador do tom de pele',
    preco: '€32,90',
    imageUrl: 'https://cdn.shopify.com/s/files/1/0076/1230/1394/files/SERUM_2025_1.jpg?v=1774263359',
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

                  // Top influencers
                  const Text(
                    'Top Influencers por Prioridade',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Mensual primeiro, depois por estado de progressão',
                    style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                  ),
                  const SizedBox(height: 14),
                  Container(
                    decoration: BoxDecoration(
                      color: AppTheme.cardBg,
                      border: Border.all(color: AppTheme.border),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: data.topInfluencers.isEmpty
                        ? const Padding(
                            padding: EdgeInsets.all(24),
                            child: Text('Sem dados',
                                style: TextStyle(color: AppTheme.textMuted)),
                          )
                        : Column(
                            children: data.topInfluencers.asMap().entries.map((e) {
                              final isLast = e.key == data.topInfluencers.length - 1;
                              return _TopInfluencerRow(
                                influencer: e.value,
                                rank: e.key + 1,
                                showDivider: !isLast,
                              );
                            }).toList(),
                          ),
                  ),
                ],
              ),
            ),
          ),
      ],
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
                    hintStyle: TextStyle(fontSize: 13, color: AppTheme.textMuted),
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
                      borderSide: BorderSide(color: AppTheme.accent),
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
                  style: TextStyle(
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
          // Product image — 180px
          SizedBox(
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
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                        letterSpacing: -0.2,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (produto.reviews > 0) ...[
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          const Icon(Icons.star_rounded,
                              size: 12, color: Color(0xFFE87C2C)),
                          const SizedBox(width: 3),
                          Text(
                            '${_formatReviews(produto.reviews)} avaliações',
                            style: const TextStyle(
                                fontSize: 11, color: AppTheme.textMuted),
                          ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 6),
                    Text(
                      produto.descricao,
                      style: const TextStyle(
                        fontSize: 11,
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
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.scoreHigh,
                        ),
                      ),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: () => launchUrl(
                        Uri.parse('https://masderm.com/pt/collections/masderm'),
                        mode: LaunchMode.externalApplication,
                      ),
                      style: TextButton.styleFrom(
                        foregroundColor: AppTheme.accent,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 3),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: const Text('Ver na loja →',
                          style: TextStyle(fontSize: 11)),
                    ),
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

// ── Top Influencer Row ────────────────────────────────────────────────────────

class _TopInfluencerRow extends StatefulWidget {
  final Influencer influencer;
  final int rank;
  final bool showDivider;

  const _TopInfluencerRow({
    required this.influencer,
    required this.rank,
    required this.showDivider,
  });

  @override
  State<_TopInfluencerRow> createState() => _TopInfluencerRowState();
}

class _TopInfluencerRowState extends State<_TopInfluencerRow> {
  bool _hovered = false;

  void _openInstagram() {
    final link = widget.influencer.link;
    if (link.isEmpty) return;
    launchUrl(Uri.parse(link), mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    final inf = widget.influencer;
    final (estadoColor, estadoBg) = _estadoColors(inf.estado);

    return Column(
      children: [
        MouseRegion(
          cursor: SystemMouseCursors.click,
          onEnter: (_) => setState(() => _hovered = true),
          onExit: (_) => setState(() => _hovered = false),
          child: GestureDetector(
            onTap: _openInstagram,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 100),
              curve: Curves.easeOut,
              color: _hovered ? AppTheme.background : Colors.transparent,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    SizedBox(
                      width: 20,
                      child: Text('${widget.rank}',
                          style: const TextStyle(
                              fontSize: 12,
                              color: AppTheme.textMuted,
                              fontWeight: FontWeight.w500)),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 3,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(inf.nome,
                              style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: AppTheme.textPrimary)),
                          if (inf.handle.isNotEmpty)
                            Text(inf.handle,
                                style: const TextStyle(
                                    fontSize: 12,
                                    color: AppTheme.textMuted)),
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: inf.estado.isNotEmpty
                          ? Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: estadoBg,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(inf.estado,
                                  style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: estadoColor)),
                            )
                          : const SizedBox(),
                    ),
                    Expanded(
                      flex: 1,
                      child: Text(
                        inf.followers > 0
                            ? _fmtFollowers(inf.followers)
                            : '—',
                        style: const TextStyle(
                            fontSize: 12,
                            color: AppTheme.textSecondary),
                        textAlign: TextAlign.right,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 2,
                      child: inf.contrato.isNotEmpty
                          ? Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 7, vertical: 2),
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
                                  fontSize: 12,
                                  color: AppTheme.textMuted)),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 3,
                      child: inf.produtosAtivos.isNotEmpty
                          ? Wrap(
                              spacing: 4,
                              runSpacing: 2,
                              children: inf.produtosAtivos
                                  .take(3)
                                  .map((p) => Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 5, vertical: 1),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFF3F4F6),
                                          borderRadius:
                                              BorderRadius.circular(3),
                                        ),
                                        child: Text(p,
                                            style: const TextStyle(
                                                fontSize: 10,
                                                color: AppTheme
                                                    .textSecondary)),
                                      ))
                                  .toList(),
                            )
                          : const Text('—',
                              style: TextStyle(
                                  fontSize: 12,
                                  color: AppTheme.textMuted)),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        if (widget.showDivider)
          const Divider(height: 1, color: AppTheme.border),
      ],
    );
  }
}
