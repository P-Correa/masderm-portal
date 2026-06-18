import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/data_provider.dart';
import '../theme/app_theme.dart';
import '../models/influencer.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final data = context.watch<DataProvider>();

    if (data.isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppTheme.accent),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          const Text(
            'Dashboard',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
              letterSpacing: -0.4,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Visão geral das parcerias Masderm Portugal',
            style: TextStyle(fontSize: 13, color: AppTheme.textSecondary),
          ),
          const SizedBox(height: 28),

          // Stats grid
          LayoutBuilder(
            builder: (context, constraints) {
              final crossCount = constraints.maxWidth > 900
                  ? 3
                  : constraints.maxWidth > 600
                      ? 2
                      : 1;
              return GridView.count(
                crossAxisCount: crossCount,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 3.2,
                children: [
                  _StatCard(
                    label: 'Total Influencers',
                    value: data.totalInfluencers.toString(),
                    icon: Icons.people_outline_rounded,
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
                  ),
                ],
              );
            },
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
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color? valueColor;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.cardBg,
        border: Border.all(color: AppTheme.border),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: AppTheme.background,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: AppTheme.border),
            ),
            child: Icon(icon, size: 15, color: AppTheme.textSecondary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppTheme.textSecondary,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: valueColor ?? AppTheme.textPrimary,
                    letterSpacing: -0.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TopInfluencerRow extends StatelessWidget {
  final Influencer influencer;
  final int rank;
  final bool showDivider;

  const _TopInfluencerRow({
    required this.influencer,
    required this.rank,
    required this.showDivider,
  });

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

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              SizedBox(
                width: 20,
                child: Text(
                  '$rank',
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
                      influencer.nome,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    Text(
                      influencer.handleInstagram,
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
                  influencer.nichoPrincipal,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  influencer.estadoProspeccao,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: _scoreBgColor(influencer.scoreRelevancia),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '${influencer.scoreRelevancia}/10',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: _scoreColor(influencer.scoreRelevancia),
                  ),
                ),
              ),
            ],
          ),
        ),
        if (showDivider)
          const Divider(height: 1, color: AppTheme.border),
      ],
    );
  }
}
