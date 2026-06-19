import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/data_provider.dart';
import '../models/influencer.dart';
import '../theme/app_theme.dart';
import '../widgets/copy_button.dart';

class InfluencersScreen extends StatefulWidget {
  const InfluencersScreen({super.key});

  @override
  State<InfluencersScreen> createState() => _InfluencersScreenState();
}

class _InfluencersScreenState extends State<InfluencersScreen> {
  final _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final data = context.watch<DataProvider>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Fixed header
        Container(
          height: 57,
          padding: const EdgeInsets.symmetric(horizontal: 32),
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: AppTheme.border)),
          ),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text('Influencers',
                style: const TextStyle(
                    fontSize: 14, fontWeight: FontWeight.w600)),
          ),
        ),
        // Filter bar
        Container(
          padding: const EdgeInsets.fromLTRB(32, 16, 32, 12),
          child: Row(
            children: [
              SizedBox(
                width: 240,
                height: 36,
                child: TextField(
                  controller: _searchCtrl,
                  onChanged: (v) =>
                      data.filterInfluencers(search: v),
                  decoration: InputDecoration(
                    hintText: 'Pesquisar nome, handle, contacto…',
                    hintStyle: TextStyle(
                        fontSize: 13, color: AppTheme.textMuted),
                    prefixIcon: Icon(Icons.search,
                        size: 16, color: AppTheme.textMuted),
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6),
                      borderSide: BorderSide(color: AppTheme.border),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6),
                      borderSide: BorderSide(color: AppTheme.border),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6),
                      borderSide: BorderSide(color: AppTheme.accent),
                    ),
                  ),
                  style: const TextStyle(fontSize: 13),
                ),
              ),
              const SizedBox(width: 12),
              SizedBox(
                height: 36,
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: data.filterEstado,
                    hint: Text('Estado',
                        style: TextStyle(
                            fontSize: 13, color: AppTheme.textMuted)),
                    items: [
                      DropdownMenuItem(
                          value: null,
                          child: Text('Todos',
                              style: const TextStyle(fontSize: 13))),
                      ...data.allEstados.map((e) => DropdownMenuItem(
                          value: e,
                          child: Text(e,
                              style: const TextStyle(fontSize: 13)))),
                    ],
                    onChanged: (v) =>
                        data.filterInfluencers(estado: v),
                    style: const TextStyle(fontSize: 13),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              TextButton(
                onPressed: () {
                  _searchCtrl.clear();
                  data.clearFilters();
                },
                child: const Text('Limpar',
                    style: TextStyle(fontSize: 13)),
              ),
              const Spacer(),
              Text(
                '${data.influencers.length} influencers',
                style: TextStyle(
                    fontSize: 13, color: AppTheme.textMuted),
              ),
            ],
          ),
        ),
        // Table
        Expanded(
          child: data.isLoading
              ? const Center(child: CircularProgressIndicator())
              : data.influencers.isEmpty
                  ? Center(
                      child: Text('Sem resultados',
                          style: TextStyle(color: AppTheme.textMuted)))
                  : SingleChildScrollView(
                      padding:
                          const EdgeInsets.fromLTRB(32, 0, 32, 32),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Container(
                          decoration: BoxDecoration(
                            border:
                                Border.all(color: AppTheme.border),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: DataTable(
                            headingRowHeight: 40,
                            dataRowMinHeight: 48,
                            dataRowMaxHeight: 64,
                            columnSpacing: 20,
                            horizontalMargin: 16,
                            headingTextStyle: TextStyle(
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
                            rows: data.influencers
                                .map((inf) => _buildRow(inf))
                                .toList(),
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
                style: const TextStyle(
                    fontSize: 13, fontWeight: FontWeight.w500)),
            if (inf.handle.isNotEmpty)
              GestureDetector(
                onTap: () => _openLink(inf.link),
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
      // Contacto
      DataCell(
        inf.contacto.isNotEmpty
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 180),
                    child: Text(
                      inf.contacto,
                      style: const TextStyle(fontSize: 12),
                      overflow: TextOverflow.ellipsis,
                    ),
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
              color: inf.contrato == 'Firmado'
                  ? const Color(0xFF16A34A)
                  : const Color(0xFFC2410C),
              bg: inf.contrato == 'Firmado'
                  ? const Color(0xFFDCFCE7)
                  : const Color(0xFFFFEDD5),
            )
          : const Text('—', style: TextStyle(fontSize: 12))),
      // PP
      DataCell(inf.pp.isNotEmpty
          ? _SmallBadge(
              label: inf.pp,
              color: inf.pp == 'Aceptado'
                  ? const Color(0xFF16A34A)
                  : const Color(0xFFB45309),
              bg: inf.pp == 'Aceptado'
                  ? const Color(0xFFDCFCE7)
                  : const Color(0xFFFEF3C7),
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
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF3F4F6),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(p,
                              style: const TextStyle(fontSize: 10)),
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
                  style: TextStyle(
                      fontSize: 12, color: AppTheme.textMuted),
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
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        estado,
        style: TextStyle(
            fontSize: 11, fontWeight: FontWeight.w600, color: color),
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
      decoration:
          BoxDecoration(color: bg, borderRadius: BorderRadius.circular(4)),
      child: Text(label,
          style: TextStyle(
              fontSize: 11, fontWeight: FontWeight.w500, color: color)),
    );
  }
}
