import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/data_provider.dart';
import '../theme/app_theme.dart';
import '../models/influencer.dart';

// Top 5 produtos Masderm por popularidade (fonte: masderm.com/pt/collections/masderm)
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

// ── Dashboard Screen ──────────────────────────────────────────────────────────

class DashboardScreen extends StatelessWidget {
  final ValueChanged<int>? onNavigate;
  const DashboardScreen({super.key, this.onNavigate});

  @override
  Widget build(BuildContext context) {
    final data = context.watch<DataProvider>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Top header bar
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
            child: Center(
              child: CircularProgressIndicator(color: AppTheme.accent),
            ),
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

                  // Stats grid + product carousel
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
                                onTap: () => onNavigate?.call(1),
                              ),
                              _StatCard(
                                label: 'Prioridade Alta',
                                value: data.prioridadeAlta.toString(),
                                icon: Icons.star_outline_rounded,
                                valueColor: AppTheme.scoreHigh,
                              ),
                              _StatCard(
                                label: 'Score Médio',
                                value: data.scoreMedio.toStringAsFixed(1),
                                icon: Icons.analytics_outlined,
                              ),
                              _StatCard(
                                label: 'Total Parcerias',
                                value: data.totalParcerias.toString(),
                                icon: Icons.handshake_outlined,
                                onTap: () => onNavigate?.call(2),
                              ),
                              _StatCard(
                                label: 'Parcerias Ativas',
                                value: data.parceriasAtivas.toString(),
                                icon: Icons.check_circle_outline_rounded,
                                valueColor: AppTheme.scoreHigh,
                              ),
                              _StatCard(
                                label: 'Total Produtos',
                                value: data.totalProdutos.toString(),
                                icon: Icons.inventory_2_outlined,
                                onTap: () => onNavigate?.call(3),
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
                    'Top Influencers por Score',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Influencers com maior relevância para a marca',
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
                            children:
                                data.topInfluencers.asMap().entries.map((e) {
                              final isLast =
                                  e.key == data.topInfluencers.length - 1;
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

// ── Product Carousel ──────────────────────────────────────────────────────────

class _ProductCarousel extends StatefulWidget {
  final List<_StoreProduct> produtos;
  const _ProductCarousel({super.key, required this.produtos});

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
          // Header
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
          // Pages
          Expanded(
            child: PageView.builder(
              controller: _ctrl,
              itemCount: widget.produtos.length,
              onPageChanged: (i) => setState(() => _current = i),
              itemBuilder: (_, i) =>
                  _ProductPage(produto: widget.produtos[i]),
            ),
          ),
          // Dot indicators
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
                      color: i == _current
                          ? AppTheme.accent
                          : AppTheme.border,
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
  const _ProductPage({super.key, required this.produto});

  String _formatReviews(int n) {
    final s = n.toString();
    if (s.length > 3) return '${s.substring(0, s.length - 3)}.${s.substring(s.length - 3)}';
    return s;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Product image
          SizedBox(
            width: 88,
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
                                strokeWidth: 1.5,
                                color: AppTheme.accent),
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
                        Uri.parse(
                            'https://masderm.com/pt/collections/masderm'),
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

  Color _scoreColor(int score) {
    if (score >= 8) return AppTheme.scoreHigh;
    if (score >= 6) return AppTheme.scoreMid;
    return AppTheme.scoreLow;
  }

  Color _scoreBgColor(int score) {
    if (score >= 8) return AppTheme.scoreHighBg;
    if (score >= 6) return AppTheme.scoreMidBg;
    return AppTheme.scoreLowBg;
  }

  void _openInstagram() {
    final handle = widget.influencer.handleInstagram.replaceAll('@', '');
    launchUrl(
      Uri.parse('https://www.instagram.com/$handle/'),
      mode: LaunchMode.externalApplication,
    );
  }

  @override
  Widget build(BuildContext context) {
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    SizedBox(
                      width: 20,
                      child: Text(
                        '${widget.rank}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppTheme.textMuted,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 3,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.influencer.nome,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          Text(
                            widget.influencer.handleInstagram,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppTheme.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        widget.influencer.nichoPrincipal,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        widget.influencer.estadoProspeccao,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: _scoreBgColor(
                            widget.influencer.scoreRelevancia),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '${widget.influencer.scoreRelevancia}/10',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color:
                              _scoreColor(widget.influencer.scoreRelevancia),
                        ),
                      ),
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
