import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/data_provider.dart';
import '../theme/app_theme.dart';
import '../models/influencer.dart';
import '../models/produto.dart';

class DashboardScreen extends StatelessWidget {
  final ValueChanged<int>? onNavigate;
  const DashboardScreen({super.key, this.onNavigate});

  @override
  Widget build(BuildContext context) {
    final data = context.watch<DataProvider>();

    // Top 5 produtos — sem filtro de encoding (CSV tem accents corrompidos)
    final displayProdutos = data.produtos.take(5).toList();

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
                        Expanded(
                          child: _ProductCarousel(produtos: displayProdutos),
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
  final List<Produto> produtos;
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
      _ctrl.animateToPage(
        next,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    });
  }

  void _goTo(int i) {
    setState(() => _current = i);
    _ctrl.animateToPage(
      i,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
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
      child: widget.produtos.isEmpty
          ? const Center(
              child: Text('A carregar produtos...',
                  style: TextStyle(fontSize: 12, color: AppTheme.textMuted)),
            )
          : Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
                  child: Row(
                    children: [
                      const Icon(Icons.local_offer_outlined,
                          size: 13, color: AppTheme.textMuted),
                      const SizedBox(width: 6),
                      const Text(
                        'Produto em destaque',
                        style: TextStyle(
                            fontSize: 11, color: AppTheme.textSecondary),
                      ),
                      const Spacer(),
                      Text(
                        '${_current + 1}/${widget.produtos.length}',
                        style: const TextStyle(
                            fontSize: 11, color: AppTheme.textMuted),
                      ),
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
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
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
  final Produto produto;
  const _ProductPage({required this.produto});

  @override
  Widget build(BuildContext context) {
    final descricao = produto.descricao.isNotEmpty
        ? produto.descricao
        : produto.paraQueServe;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            produto.nomeProduto,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
              letterSpacing: -0.2,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            produto.categoria,
            style: const TextStyle(fontSize: 11, color: AppTheme.textMuted),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: Text(
              descricao,
              style: const TextStyle(
                fontSize: 12,
                color: AppTheme.textSecondary,
                height: 1.5,
              ),
              overflow: TextOverflow.fade,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppTheme.scoreHighBg,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  produto.precoFormatado,
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
                  Uri.parse('https://masderm.pt'),
                  mode: LaunchMode.externalApplication,
                ),
                style: TextButton.styleFrom(
                  foregroundColor: AppTheme.accent,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                        color: _scoreBgColor(widget.influencer.scoreRelevancia),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '${widget.influencer.scoreRelevancia}/10',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: _scoreColor(widget.influencer.scoreRelevancia),
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
