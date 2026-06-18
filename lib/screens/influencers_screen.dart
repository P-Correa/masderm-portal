import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/data_provider.dart';
import '../theme/app_theme.dart';
import '../models/influencer.dart';
import '../widgets/copy_button.dart';

class InfluencersScreen extends StatefulWidget {
  const InfluencersScreen({super.key});

  @override
  State<InfluencersScreen> createState() => _InfluencersScreenState();
}

class _InfluencersScreenState extends State<InfluencersScreen> {
  final _searchCtrl = TextEditingController();
  String _searchQuery = '';
  String _filterEstado = 'Todos';
  String _filterNicho = 'Todos';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<Influencer> _filtered(List<Influencer> all) {
    return all.where((inf) {
      final q = _searchQuery.toLowerCase();
      final matchSearch = q.isEmpty ||
          inf.nome.toLowerCase().contains(q) ||
          inf.handleInstagram.toLowerCase().contains(q) ||
          inf.nichoPrincipal.toLowerCase().contains(q) ||
          inf.cidade.toLowerCase().contains(q);
      final matchEstado =
          _filterEstado == 'Todos' || inf.estadoProspeccao == _filterEstado;
      final matchNicho =
          _filterNicho == 'Todos' || inf.nichoPrincipal == _filterNicho;
      return matchSearch && matchEstado && matchNicho;
    }).toList();
  }

  Color _scoreColor(int score) {
    if (score >= 8) return AppTheme.scoreHigh;
    if (score >= 6) return AppTheme.scoreMid;
    return AppTheme.scoreLow;
  }

  Color _scoreBg(int score) {
    if (score >= 8) return AppTheme.scoreHighBg;
    if (score >= 6) return AppTheme.scoreMidBg;
    return AppTheme.scoreLowBg;
  }

  @override
  Widget build(BuildContext context) {
    final data = context.watch<DataProvider>();
    final all = data.influencers;

    final estados = ['Todos', ...{...all.map((i) => i.estadoProspeccao)}];
    final nichos = ['Todos', ...{...all.map((i) => i.nichoPrincipal)}];
    final filtered = _filtered(all);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          const Text(
            'Influencers',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
              letterSpacing: -0.4,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${all.length} influencers em base de dados',
            style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary),
          ),
          const SizedBox(height: 20),

          // Filters row
          Wrap(
            spacing: 10,
            runSpacing: 10,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              SizedBox(
                width: 260,
                height: 36,
                child: TextField(
                  controller: _searchCtrl,
                  style: const TextStyle(fontSize: 13),
                  decoration: InputDecoration(
                    hintText: 'Pesquisar por nome, handle, cidade...',
                    prefixIcon: const Icon(Icons.search_rounded,
                        size: 16, color: AppTheme.textMuted),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 0),
                    isDense: true,
                  ),
                  onChanged: (v) => setState(() => _searchQuery = v),
                ),
              ),
              _FilterDropdown(
                label: 'Estado',
                value: _filterEstado,
                items: estados,
                onChanged: (v) => setState(() => _filterEstado = v ?? 'Todos'),
              ),
              _FilterDropdown(
                label: 'Nicho',
                value: _filterNicho,
                items: nichos,
                onChanged: (v) => setState(() => _filterNicho = v ?? 'Todos'),
              ),
              if (_searchQuery.isNotEmpty ||
                  _filterEstado != 'Todos' ||
                  _filterNicho != 'Todos')
                TextButton(
                  onPressed: () => setState(() {
                    _searchCtrl.clear();
                    _searchQuery = '';
                    _filterEstado = 'Todos';
                    _filterNicho = 'Todos';
                  }),
                  style: TextButton.styleFrom(
                    foregroundColor: AppTheme.textSecondary,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 6),
                  ),
                  child: const Text('Limpar filtros',
                      style: TextStyle(fontSize: 12)),
                ),
            ],
          ),
          const SizedBox(height: 16),

          if (data.isLoading)
            const Center(
                child:
                    CircularProgressIndicator(color: AppTheme.accent))
          else if (filtered.isEmpty)
            _EmptyState(hasFilters: _searchQuery.isNotEmpty ||
                _filterEstado != 'Todos' ||
                _filterNicho != 'Todos')
          else
            Container(
              decoration: BoxDecoration(
                color: AppTheme.cardBg,
                border: Border.all(color: AppTheme.border),
                borderRadius: BorderRadius.circular(8),
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  headingRowHeight: 40,
                  dataRowMinHeight: 52,
                  dataRowMaxHeight: 64,
                  columnSpacing: 20,
                  horizontalMargin: 16,
                  headingRowColor: WidgetStateProperty.all(AppTheme.background),
                  dividerThickness: 1,
                  border: TableBorder(
                    horizontalInside: BorderSide(
                        color: AppTheme.border, width: 1),
                  ),
                  columns: const [
                    DataColumn(label: _ColHeader('Nome')),
                    DataColumn(label: _ColHeader('Handle')),
                    DataColumn(label: _ColHeader('Email')),
                    DataColumn(label: _ColHeader('Nicho')),
                    DataColumn(label: _ColHeader('Seguidores')),
                    DataColumn(label: _ColHeader('Engagement')),
                    DataColumn(label: _ColHeader('Cidade')),
                    DataColumn(label: _ColHeader('Tipo')),
                    DataColumn(label: _ColHeader('Autenticidade')),
                    DataColumn(label: _ColHeader('Apto')),
                    DataColumn(label: _ColHeader('Score')),
                    DataColumn(label: _ColHeader('Estado')),
                  ],
                  rows: filtered.map((inf) {
                    return DataRow(cells: [
                      DataCell(
                        SizedBox(
                          width: 150,
                          child: Text(
                            inf.nome,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: AppTheme.textPrimary,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                      DataCell(Text(
                        inf.handleInstagram,
                        style: const TextStyle(
                            fontSize: 12, color: AppTheme.textSecondary),
                      )),
                      // Email com botão de copiar
                      DataCell(
                        inf.emailContacto.isNotEmpty
                            ? Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  SizedBox(
                                    width: 160,
                                    child: Text(
                                      inf.emailContacto,
                                      style: const TextStyle(
                                          fontSize: 12,
                                          color: AppTheme.textSecondary),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  CopyButton(
                                    text: inf.emailContacto,
                                    tooltip: 'Copiar email',
                                  ),
                                ],
                              )
                            : const Text('—',
                                style: TextStyle(
                                    fontSize: 12, color: AppTheme.textMuted)),
                      ),
                      DataCell(SizedBox(
                        width: 100,
                        child: Text(
                          inf.nichoPrincipal,
                          style: const TextStyle(
                              fontSize: 12, color: AppTheme.textSecondary),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      )),
                      DataCell(Text(
                        _formatSeguidores(inf.seguidoresAprox),
                        style: const TextStyle(
                            fontSize: 12, color: AppTheme.textPrimary),
                      )),
                      DataCell(Text(
                        inf.taxaEngagementEstimada,
                        style: const TextStyle(
                            fontSize: 12, color: AppTheme.textPrimary),
                      )),
                      DataCell(Text(
                        inf.cidade,
                        style: const TextStyle(
                            fontSize: 12, color: AppTheme.textSecondary),
                      )),
                      DataCell(Text(
                        inf.tipoConta,
                        style: const TextStyle(
                            fontSize: 12, color: AppTheme.textSecondary),
                      )),
                      DataCell(_Badge(
                        label: inf.autenticidade,
                        color: inf.autenticidade == 'Alta'
                            ? AppTheme.scoreHigh
                            : AppTheme.scoreMid,
                        bgColor: inf.autenticidade == 'Alta'
                            ? AppTheme.scoreHighBg
                            : AppTheme.scoreMidBg,
                      )),
                      DataCell(_Badge(
                        label: inf.aptoMasderm,
                        color: inf.aptoMasderm == 'Sim'
                            ? AppTheme.scoreHigh
                            : inf.aptoMasderm == 'Talvez'
                                ? AppTheme.scoreMid
                                : AppTheme.scoreLow,
                        bgColor: inf.aptoMasderm == 'Sim'
                            ? AppTheme.scoreHighBg
                            : inf.aptoMasderm == 'Talvez'
                                ? AppTheme.scoreMidBg
                                : AppTheme.scoreLowBg,
                      )),
                      DataCell(Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: _scoreBg(inf.scoreRelevancia),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '${inf.scoreRelevancia}/10',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: _scoreColor(inf.scoreRelevancia),
                          ),
                        ),
                      )),
                      DataCell(SizedBox(
                        width: 130,
                        child: _EstadoBadge(estado: inf.estadoProspeccao),
                      )),
                    ]);
                  }).toList(),
                ),
              ),
            ),
          const SizedBox(height: 8),
          if (filtered.isNotEmpty)
            Text(
              '${filtered.length} resultado${filtered.length == 1 ? '' : 's'}',
              style: const TextStyle(
                  fontSize: 12, color: AppTheme.textMuted),
            ),
        ],
      ),
    );
  }

  String _formatSeguidores(int n) {
    if (n >= 1000000) return '${(n / 1000000).toStringAsFixed(1)}M';
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(0)}K';
    return n.toString();
  }
}

class _ColHeader extends StatelessWidget {
  final String text;
  const _ColHeader(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: AppTheme.textSecondary,
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final String label;
  final Color color;
  final Color bgColor;

  const _Badge({
    required this.label,
    required this.color,
    required this.bgColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: color,
        ),
      ),
    );
  }
}

class _EstadoBadge extends StatelessWidget {
  final String estado;
  const _EstadoBadge({required this.estado});

  @override
  Widget build(BuildContext context) {
    Color color;
    Color bgColor;
    switch (estado) {
      case 'PRIORIDADE ALTA':
        color = AppTheme.scoreHigh;
        bgColor = AppTheme.scoreHighBg;
        break;
      case 'A CONTACTAR':
        color = const Color(0xFF2563EB);
        bgColor = const Color(0xFFEFF6FF);
        break;
      case 'EM AVALIAÇÃO':
        color = AppTheme.scoreMid;
        bgColor = AppTheme.scoreMidBg;
        break;
      default:
        color = AppTheme.textSecondary;
        bgColor = AppTheme.background;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        estado,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: color,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}

class _FilterDropdown extends StatelessWidget {
  final String label;
  final String value;
  final List<String> items;
  final ValueChanged<String?> onChanged;

  const _FilterDropdown({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 36,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: AppTheme.cardBg,
        border: Border.all(color: AppTheme.border),
        borderRadius: BorderRadius.circular(6),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isDense: true,
          style: const TextStyle(
              fontSize: 13, color: AppTheme.textPrimary),
          items: items
              .map((e) => DropdownMenuItem(value: e, child: Text(e)))
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final bool hasFilters;
  const _EmptyState({required this.hasFilters});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(48),
      decoration: BoxDecoration(
        color: AppTheme.cardBg,
        border: Border.all(color: AppTheme.border),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Column(
          children: [
            Icon(
              hasFilters
                  ? Icons.search_off_rounded
                  : Icons.people_outline_rounded,
              size: 36,
              color: AppTheme.textMuted,
            ),
            const SizedBox(height: 12),
            Text(
              hasFilters
                  ? 'Sem resultados para os filtros aplicados'
                  : 'Sem influencers em base de dados',
              style: const TextStyle(
                  fontSize: 14, color: AppTheme.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}
