import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/data_provider.dart';
import '../theme/app_theme.dart';
import '../models/parceria.dart';

class ParceriasScreen extends StatelessWidget {
  const ParceriasScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final data = context.watch<DataProvider>();
    final parcerias = data.parcerias;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          const Text(
            'Parcerias',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
              letterSpacing: -0.4,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            parcerias.isEmpty
                ? 'Pipeline de parcerias ativo'
                : '${parcerias.length} parceria${parcerias.length == 1 ? '' : 's'} no pipeline',
            style: const TextStyle(
                fontSize: 13, color: AppTheme.textSecondary),
          ),
          const SizedBox(height: 28),

          if (data.isLoading)
            const Center(
                child: CircularProgressIndicator(color: AppTheme.accent))
          else if (parcerias.isEmpty)
            _EmptyParceriasState()
          else
            _ParceriasTable(parcerias: parcerias),
        ],
      ),
    );
  }
}

class _EmptyParceriasState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 32),
      decoration: BoxDecoration(
        color: AppTheme.cardBg,
        border: Border.all(color: AppTheme.border),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: AppTheme.background,
              border: Border.all(color: AppTheme.border),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.handshake_outlined,
              size: 24,
              color: AppTheme.textMuted,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Sem parcerias ainda',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'As parcerias aparecerão aqui assim que forem criadas.\nComece por contactar as influencers em Prioridade Alta.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: AppTheme.textSecondary,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: AppTheme.background,
              border: Border.all(color: AppTheme.border),
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.info_outline_rounded,
                    size: 14, color: AppTheme.textMuted),
                SizedBox(width: 8),
                Text(
                  'Os dados são importados automaticamente do ficheiro parcerias.csv',
                  style:
                      TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ParceriasTable extends StatelessWidget {
  final List<Parceria> parcerias;
  const _ParceriasTable({required this.parcerias});

  Color _estadoColor(String estado) {
    final e = estado.toUpperCase();
    if (e.contains('ATIV') || e.contains('PUBL') || e.contains('CONCLU')) {
      return AppTheme.scoreHigh;
    }
    if (e.contains('NEGOC') || e.contains('BRIEFING') || e.contains('CURSO')) {
      return const Color(0xFF2563EB);
    }
    if (e.contains('PEND') || e.contains('ESPERA')) {
      return AppTheme.scoreMid;
    }
    if (e.contains('CANCEL') || e.contains('RECUS')) {
      return AppTheme.scoreLow;
    }
    return AppTheme.textSecondary;
  }

  Color _estadoBgColor(String estado) {
    final e = estado.toUpperCase();
    if (e.contains('ATIV') || e.contains('PUBL') || e.contains('CONCLU')) {
      return AppTheme.scoreHighBg;
    }
    if (e.contains('NEGOC') || e.contains('BRIEFING') || e.contains('CURSO')) {
      return const Color(0xFFEFF6FF);
    }
    if (e.contains('PEND') || e.contains('ESPERA')) {
      return AppTheme.scoreMidBg;
    }
    if (e.contains('CANCEL') || e.contains('RECUS')) {
      return AppTheme.scoreLowBg;
    }
    return AppTheme.background;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
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
          headingRowColor:
              WidgetStateProperty.all(AppTheme.background),
          border: TableBorder(
            horizontalInside:
                BorderSide(color: AppTheme.border, width: 1),
          ),
          columns: const [
            DataColumn(label: _ColHeader('ID')),
            DataColumn(label: _ColHeader('Influencer')),
            DataColumn(label: _ColHeader('Produto')),
            DataColumn(label: _ColHeader('Tipo')),
            DataColumn(label: _ColHeader('Valor')),
            DataColumn(label: _ColHeader('Pub. Prevista')),
            DataColumn(label: _ColHeader('Estado')),
            DataColumn(label: _ColHeader('Próxima Ação')),
            DataColumn(label: _ColHeader('Responsável')),
          ],
          rows: parcerias.map((p) {
            return DataRow(cells: [
              DataCell(Text(p.idParceria,
                  style: const TextStyle(
                      fontSize: 12, color: AppTheme.textMuted))),
              DataCell(
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(p.nomeInfluenciadora,
                        style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: AppTheme.textPrimary)),
                    Text(p.handleInfluenciadora,
                        style: const TextStyle(
                            fontSize: 11, color: AppTheme.textMuted)),
                  ],
                ),
              ),
              DataCell(SizedBox(
                width: 140,
                child: Text(p.produtoPrincipal,
                    style: const TextStyle(
                        fontSize: 12, color: AppTheme.textPrimary),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis),
              )),
              DataCell(Text(p.tipoColaboracao,
                  style: const TextStyle(
                      fontSize: 12, color: AppTheme.textSecondary))),
              DataCell(Text(
                p.valorAcordadoEur.isNotEmpty
                    ? '€${p.valorAcordadoEur}'
                    : '—',
                style: const TextStyle(
                    fontSize: 12, color: AppTheme.textPrimary),
              )),
              DataCell(Text(
                p.dataPublicacaoPrevista.isNotEmpty
                    ? p.dataPublicacaoPrevista
                    : '—',
                style: const TextStyle(
                    fontSize: 12, color: AppTheme.textSecondary),
              )),
              DataCell(Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: _estadoBgColor(p.estadoPipeline),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  p.estadoPipeline.isNotEmpty ? p.estadoPipeline : '—',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: _estadoColor(p.estadoPipeline),
                  ),
                ),
              )),
              DataCell(SizedBox(
                width: 140,
                child: Text(
                  p.proximaAccao.isNotEmpty ? p.proximaAccao : '—',
                  style: const TextStyle(
                      fontSize: 12, color: AppTheme.textSecondary),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              )),
              DataCell(Text(
                p.responsavel.isNotEmpty ? p.responsavel : '—',
                style: const TextStyle(
                    fontSize: 12, color: AppTheme.textSecondary),
              )),
            ]);
          }).toList(),
        ),
      ),
    );
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
