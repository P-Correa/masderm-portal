import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/data_provider.dart';
import '../theme/app_theme.dart';
import '../models/produto.dart';

class ProdutosScreen extends StatefulWidget {
  const ProdutosScreen({super.key});

  @override
  State<ProdutosScreen> createState() => _ProdutosScreenState();
}

class _ProdutosScreenState extends State<ProdutosScreen> {
  final _searchCtrl = TextEditingController();
  String _searchQuery = '';
  String _filterCategoria = 'Todas';
  bool _somenteIdeal = false;
  bool _somenteDisponivel = false;

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<Produto> _filtered(List<Produto> all) {
    return all.where((p) {
      final q = _searchQuery.toLowerCase();
      final matchSearch = q.isEmpty ||
          p.nomeProduto.toLowerCase().contains(q) ||
          p.paraQueServe.toLowerCase().contains(q) ||
          p.tecnologia.toLowerCase().contains(q) ||
          p.descricao.toLowerCase().contains(q);
      final matchCat =
          _filterCategoria == 'Todas' || p.categoria == _filterCategoria;
      final matchIdeal = !_somenteIdeal || p.isIdealInfluencer;
      final matchDisp = !_somenteDisponivel || p.isDisponivel;
      return matchSearch && matchCat && matchIdeal && matchDisp;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final data = context.watch<DataProvider>();
    final all = data.produtos;
    final categorias = [
      'Todas',
      ...{...all.map((p) => p.categoria)}
    ];
    final filtered = _filtered(all);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          const Text(
            'Produtos',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
              letterSpacing: -0.4,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${all.length} produtos no catálogo',
            style: const TextStyle(
                fontSize: 13, color: AppTheme.textSecondary),
          ),
          const SizedBox(height: 20),

          // Filters
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
                  decoration: const InputDecoration(
                    hintText: 'Pesquisar por nome, função, tecnologia...',
                    prefixIcon: Icon(Icons.search_rounded,
                        size: 16, color: AppTheme.textMuted),
                    contentPadding: EdgeInsets.symmetric(
                        horizontal: 12, vertical: 0),
                    isDense: true,
                  ),
                  onChanged: (v) => setState(() => _searchQuery = v),
                ),
              ),
              _FilterDropdown(
                value: _filterCategoria,
                items: categorias,
                onChanged: (v) =>
                    setState(() => _filterCategoria = v ?? 'Todas'),
              ),
              _ToggleChip(
                label: 'Ideal para influencer',
                active: _somenteIdeal,
                onTap: () =>
                    setState(() => _somenteIdeal = !_somenteIdeal),
              ),
              _ToggleChip(
                label: 'Disponível',
                active: _somenteDisponivel,
                onTap: () => setState(
                    () => _somenteDisponivel = !_somenteDisponivel),
              ),
            ],
          ),
          const SizedBox(height: 16),

          if (data.isLoading)
            const Center(
                child:
                    CircularProgressIndicator(color: AppTheme.accent))
          else if (filtered.isEmpty)
            _EmptyState()
          else ...[
            LayoutBuilder(
              builder: (context, constraints) {
                final cols = constraints.maxWidth > 1100
                    ? 4
                    : constraints.maxWidth > 800
                        ? 3
                        : constraints.maxWidth > 500
                            ? 2
                            : 1;
                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate:
                      SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: cols,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.4,
                  ),
                  itemCount: filtered.length,
                  itemBuilder: (context, i) =>
                      _ProdutoCard(produto: filtered[i]),
                );
              },
            ),
            const SizedBox(height: 8),
            Text(
              '${filtered.length} produto${filtered.length == 1 ? '' : 's'}',
              style: const TextStyle(
                  fontSize: 12, color: AppTheme.textMuted),
            ),
          ],
        ],
      ),
    );
  }
}

class _ProdutoCard extends StatefulWidget {
  final Produto produto;
  const _ProdutoCard({required this.produto});

  @override
  State<_ProdutoCard> createState() => _ProdutoCardState();
}

class _ProdutoCardState extends State<_ProdutoCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final p = widget.produto;
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.cardBg,
          border: Border.all(
            color: _hovered ? AppTheme.accent.withValues(alpha: 0.3) : AppTheme.border,
          ),
          borderRadius: BorderRadius.circular(8),
          boxShadow: _hovered
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  )
                ]
              : [],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Category + disponibilidade
            Row(
              children: [
                Expanded(
                  child: Text(
                    p.categoria,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppTheme.textMuted,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 6),
                _DisponibilidadeBadge(disponivel: p.isDisponivel),
              ],
            ),
            const SizedBox(height: 8),

            // Name
            Text(
              p.nomeProduto,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
                height: 1.3,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 6),

            // Para que serve
            Expanded(
              child: Text(
                p.paraQueServe.isNotEmpty ? p.paraQueServe : p.descricao,
                style: const TextStyle(
                  fontSize: 11,
                  color: AppTheme.textSecondary,
                  height: 1.4,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),

            const SizedBox(height: 10),
            // Bottom row: price + ideal badge
            Row(
              children: [
                Text(
                  p.precoFormatado,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                    letterSpacing: -0.2,
                  ),
                ),
                const Spacer(),
                if (p.isIdealInfluencer)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppTheme.scoreHighBg,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      'Ideal',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.scoreHigh,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _DisponibilidadeBadge extends StatelessWidget {
  final bool disponivel;
  const _DisponibilidadeBadge({required this.disponivel});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: disponivel ? AppTheme.scoreHighBg : AppTheme.scoreLowBg,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        disponivel ? 'Disponível' : 'Esgotado',
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w500,
          color: disponivel ? AppTheme.scoreHigh : AppTheme.scoreLow,
        ),
      ),
    );
  }
}

class _FilterDropdown extends StatelessWidget {
  final String value;
  final List<String> items;
  final ValueChanged<String?> onChanged;

  const _FilterDropdown({
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

class _ToggleChip extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _ToggleChip({
    required this.label,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        height: 36,
        padding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
        decoration: BoxDecoration(
          color: active ? AppTheme.accent : AppTheme.cardBg,
          border: Border.all(
              color: active ? AppTheme.accent : AppTheme.border),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: active ? Colors.white : AppTheme.textSecondary,
              fontWeight:
                  active ? FontWeight.w500 : FontWeight.w400,
            ),
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(48),
      decoration: BoxDecoration(
        color: AppTheme.cardBg,
        border: Border.all(color: AppTheme.border),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Center(
        child: Column(
          children: [
            Icon(Icons.inventory_2_outlined,
                size: 36, color: AppTheme.textMuted),
            SizedBox(height: 12),
            Text(
              'Sem produtos para os filtros aplicados',
              style: TextStyle(
                  fontSize: 14, color: AppTheme.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}
