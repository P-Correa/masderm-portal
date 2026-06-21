import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/data_provider.dart';
import '../models/influencer.dart';
import '../theme/app_theme.dart';
import '../widgets/copy_button.dart';
import '../widgets/dropdown_slicer.dart';

class InfluencersScreen extends StatefulWidget {
  const InfluencersScreen({super.key});

  @override
  State<InfluencersScreen> createState() => _InfluencersScreenState();
}

class _InfluencersScreenState extends State<InfluencersScreen> {
  final _searchCtrl = TextEditingController();
  String _search = '';
  Set<String> _estadoFilter = {};
  Set<String> _contratoFilter = {};
  Set<String> _ppFilter = {};
  Set<String> _facturaFilter = {};

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<Influencer> _filtered(List<Influencer> all) {
    return all.where((i) {
      if (_search.isNotEmpty) {
        final q = _search.toLowerCase();
        if (!i.nome.toLowerCase().contains(q) &&
            !i.handle.toLowerCase().contains(q) &&
            !i.contacto.toLowerCase().contains(q)) { return false; }
      }
      if (_estadoFilter.isNotEmpty && !_estadoFilter.contains(i.estado)) return false;
      if (_contratoFilter.isNotEmpty && !_contratoFilter.contains(i.contrato)) return false;
      if (_ppFilter.isNotEmpty && !_ppFilter.contains(i.pp)) return false;
      if (_facturaFilter.isNotEmpty && !_facturaFilter.contains(i.factura)) return false;
      return true;
    }).toList();
  }

  void _clearAll() {
    _searchCtrl.clear();
    setState(() {
      _search = '';
      _estadoFilter = {};
      _contratoFilter = {};
      _ppFilter = {};
      _facturaFilter = {};
    });
  }

  bool get _hasFilters =>
      _search.isNotEmpty ||
      _estadoFilter.isNotEmpty ||
      _contratoFilter.isNotEmpty ||
      _ppFilter.isNotEmpty ||
      _facturaFilter.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final data = context.watch<DataProvider>();
    final all = data.allInfluencers.toList();
    final list = _filtered(all);

    // Dynamic slicer options derived from data
    final allEstados = all.map((i) => i.estado).where((e) => e.isNotEmpty).toSet().toList()..sort();
    final allContratos = all.map((i) => i.contrato).where((e) => e.isNotEmpty).toSet().toList()..sort();
    final allPPs = all.map((i) => i.pp).where((e) => e.isNotEmpty).toSet().toList()..sort();
    final allFacturas = all.map((i) => i.factura).where((e) => e.isNotEmpty).toSet().toList()..sort();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
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
            child: Text('Influencers',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
          ),
        ),
        // Filter bar
        Container(
          padding: const EdgeInsets.fromLTRB(32, 14, 32, 12),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              // Search
              SizedBox(
                width: 220,
                height: 34,
                child: TextField(
                  controller: _searchCtrl,
                  onChanged: (v) => setState(() => _search = v),
                  decoration: InputDecoration(
                    hintText: 'Pesquisar nome, handle…',
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
              // Estado slicer
              DropdownSlicer<String>(
                title: 'Estado',
                items: allEstados,
                selected: _estadoFilter,
                labelOf: (e) => e,
                onToggle: (e) => setState(() {
                  if (_estadoFilter.contains(e)) {
                    _estadoFilter = Set.from(_estadoFilter)..remove(e);
                  } else {
                    _estadoFilter = Set.from(_estadoFilter)..add(e);
                  }
                }),
                onClear: _estadoFilter.isNotEmpty ? () => setState(() => _estadoFilter = {}) : null,
              ),
              // Contrato slicer
              DropdownSlicer<String>(
                title: 'Contrato',
                items: allContratos,
                selected: _contratoFilter,
                labelOf: (e) => e,
                onToggle: (e) => setState(() {
                  if (_contratoFilter.contains(e)) {
                    _contratoFilter = Set.from(_contratoFilter)..remove(e);
                  } else {
                    _contratoFilter = Set.from(_contratoFilter)..add(e);
                  }
                }),
                onClear: _contratoFilter.isNotEmpty ? () => setState(() => _contratoFilter = {}) : null,
              ),
              // PP slicer
              DropdownSlicer<String>(
                title: 'PP',
                items: allPPs,
                selected: _ppFilter,
                labelOf: (e) => e,
                onToggle: (e) => setState(() {
                  if (_ppFilter.contains(e)) {
                    _ppFilter = Set.from(_ppFilter)..remove(e);
                  } else {
                    _ppFilter = Set.from(_ppFilter)..add(e);
                  }
                }),
                onClear: _ppFilter.isNotEmpty ? () => setState(() => _ppFilter = {}) : null,
              ),
              // Factura slicer
              DropdownSlicer<String>(
                title: 'Factura',
                items: allFacturas,
                selected: _facturaFilter,
                labelOf: (e) => e,
                onToggle: (e) => setState(() {
                  if (_facturaFilter.contains(e)) {
                    _facturaFilter = Set.from(_facturaFilter)..remove(e);
                  } else {
                    _facturaFilter = Set.from(_facturaFilter)..add(e);
                  }
                }),
                onClear: _facturaFilter.isNotEmpty ? () => setState(() => _facturaFilter = {}) : null,
              ),
              // Clear button
              if (_hasFilters)
                TextButton(
                  onPressed: _clearAll,
                  child: const Text('Limpar', style: TextStyle(fontSize: 12)),
                ),
              // Count
              const SizedBox(width: 4),
              Text(
                '${list.length} de ${all.length} influencers',
                style: const TextStyle(fontSize: 12, color: AppTheme.textMuted),
              ),
            ],
          ),
        ),
        // Table
        Expanded(
          child: data.isLoading
              ? const Center(child: CircularProgressIndicator())
              : list.isEmpty
                  ? const Center(
                      child: Text('Sem resultados',
                          style: TextStyle(color: AppTheme.textMuted)))
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
                            dataRowMinHeight: 48,
                            dataRowMaxHeight: 64,
                            columnSpacing: 20,
                            horizontalMargin: 16,
                            headingTextStyle: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.textMuted,
                            ),
                            columns: const [
                              DataColumn(label: Text('Nome')),
                              DataColumn(label: Text('Contacto')),
                              DataColumn(label: Text('Estado')),
                              DataColumn(label: Text('Followers'), numeric: true),
                              DataColumn(label: Text('Contrato')),
                              DataColumn(label: Text('PP')),
                              DataColumn(label: Text('Factura')),
                              DataColumn(label: Text('Produtos')),
                              DataColumn(label: Text('Notas')),
                            ],
                            rows: list.map((inf) => _buildRow(inf)).toList(),
                          ),
                        ),
                      ),
                    ),
        ),
      ],
    );
  }

  DataRow _buildRow(Influencer inf) {
    return DataRow(cells: [
      // Nome + handle
      DataCell(
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(inf.nome,
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
            if (inf.handle.isNotEmpty)
              GestureDetector(
                onTap: () => _openLink(inf.link),
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
      // Contacto
      DataCell(
        inf.contacto.isNotEmpty
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 180),
                    child: Text(inf.contacto,
                        style: const TextStyle(fontSize: 12),
                        overflow: TextOverflow.ellipsis),
                  ),
                  const SizedBox(width: 4),
                  CopyButton(text: inf.contacto),
                ],
              )
            : const SizedBox(),
      ),
      // Estado
      DataCell(_EstadoBadge(estado: inf.estado)),
      // Followers
      DataCell(Text(
        inf.followers > 0 ? _fmtFollowers(inf.followers) : '—',
        style: const TextStyle(fontSize: 13),
      )),
      // Contrato
      DataCell(inf.contrato.isNotEmpty
          ? _SmallBadge(
              label: inf.contrato,
              color: inf.contrato == 'Firmado' ? const Color(0xFF16A34A) : const Color(0xFFC2410C),
              bg: inf.contrato == 'Firmado' ? const Color(0xFFDCFCE7) : const Color(0xFFFFEDD5),
            )
          : const Text('—', style: TextStyle(fontSize: 12))),
      // PP
      DataCell(inf.pp.isNotEmpty
          ? _SmallBadge(
              label: inf.pp,
              color: inf.pp == 'Aceptado' ? const Color(0xFF16A34A) : const Color(0xFFB45309),
              bg: inf.pp == 'Aceptado' ? const Color(0xFFDCFCE7) : const Color(0xFFFEF3C7),
            )
          : const Text('—', style: TextStyle(fontSize: 12))),
      // Factura
      DataCell(inf.factura.isNotEmpty
          ? _SmallBadge(
              label: inf.factura,
              color: _facturaColor(inf.factura),
              bg: _facturaBg(inf.factura),
            )
          : const Text('—', style: TextStyle(fontSize: 12))),
      // Produtos
      DataCell(
        inf.produtosAtivos.isNotEmpty
            ? Wrap(
                spacing: 4,
                runSpacing: 4,
                children: inf.produtosAtivos
                    .map((p) => Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF3F4F6),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(p, style: const TextStyle(fontSize: 10)),
                        ))
                    .toList(),
              )
            : const Text('—', style: TextStyle(fontSize: 12)),
      ),
      // Notas
      DataCell(
        inf.notas.isNotEmpty
            ? ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 200),
                child: Text(
                  inf.notas,
                  style: const TextStyle(fontSize: 12, color: AppTheme.textMuted),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                ),
              )
            : const SizedBox(),
      ),
    ]);
  }

  void _openLink(String url) {
    if (url.isEmpty) return;
    launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
  }

  String _fmtFollowers(int n) {
    if (n >= 1000000) return '${(n / 1000000).toStringAsFixed(1)}M';
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(0)}K';
    return n.toString();
  }

  Color _facturaColor(String v) {
    switch (v) {
      case 'Pagada': return const Color(0xFF16A34A);
      case 'Enviada': return const Color(0xFF2563EB);
      case 'Pendiente': return const Color(0xFFB45309);
      case 'Intercâmbio': return const Color(0xFF7C3AED);
      default: return const Color(0xFF6B7280);
    }
  }

  Color _facturaBg(String v) {
    switch (v) {
      case 'Pagada': return const Color(0xFFDCFCE7);
      case 'Enviada': return const Color(0xFFDBEAFE);
      case 'Pendiente': return const Color(0xFFFEF3C7);
      case 'Intercâmbio': return const Color(0xFFEDE9FE);
      default: return const Color(0xFFF3F4F6);
    }
  }
}

class _EstadoBadge extends StatelessWidget {
  final String estado;
  const _EstadoBadge({required this.estado});

  @override
  Widget build(BuildContext context) {
    if (estado.isEmpty) return const SizedBox();
    final (color, bg) = _colors();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(4)),
      child: Text(
        estado,
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: color),
      ),
    );
  }

  (Color, Color) _colors() {
    switch (estado) {
      case 'Mensual': return (Colors.white, const Color(0xFF7C3AED));
      case 'Contenido subido': return (const Color(0xFF16A34A), const Color(0xFFDCFCE7));
      case 'Contenido recibido': return (const Color(0xFF0D9488), const Color(0xFFCCFBF1));
      case 'Producto enviado': return (const Color(0xFF2563EB), const Color(0xFFDBEAFE));
      case 'Aprobada': return (const Color(0xFF65A30D), const Color(0xFFECFCCB));
      case 'Contactada': return (const Color(0xFFC2410C), const Color(0xFFFFEDD5));
      case 'Rechazada': return (const Color(0xFFDC2626), const Color(0xFFFEE2E2));
      case 'Embarazada': return (const Color(0xFFBE185D), const Color(0xFFFCE7F3));
      default: return (const Color(0xFF6B7280), const Color(0xFFF3F4F6));
    }
  }
}

class _SmallBadge extends StatelessWidget {
  final String label;
  final Color color;
  final Color bg;
  const _SmallBadge({required this.label, required this.color, required this.bg});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(4)),
      child: Text(label,
          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: color)),
    );
  }
}
