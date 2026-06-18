import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class Influencer {
  final String nome;
  final String handleInstagram;
  final String urlInstagram;
  final String nichoPrincipal;
  final String subNicho;
  final int seguidoresAprox;
  final String taxaEngagementEstimada;
  final int idadeAprox;
  final String cidade;
  final String emailContacto;
  final String tipoConta;
  final String tipoConteudo;
  final String autenticidade;
  final String aptoMasderm;
  final int scoreRelevancia;
  final String estadoProspeccao;
  final String dataPrimeiroContacto;
  final String dataUltimoContacto;
  final String produtosEnviados;
  final String publicacoesRealizadas;
  final String notas;

  const Influencer({
    required this.nome,
    required this.handleInstagram,
    required this.urlInstagram,
    required this.nichoPrincipal,
    required this.subNicho,
    required this.seguidoresAprox,
    required this.taxaEngagementEstimada,
    required this.idadeAprox,
    required this.cidade,
    required this.emailContacto,
    required this.tipoConta,
    required this.tipoConteudo,
    required this.autenticidade,
    required this.aptoMasderm,
    required this.scoreRelevancia,
    required this.estadoProspeccao,
    required this.dataPrimeiroContacto,
    required this.dataUltimoContacto,
    required this.produtosEnviados,
    required this.publicacoesRealizadas,
    required this.notas,
  });

  factory Influencer.fromCsv(List<dynamic> row) {
    return Influencer(
      nome: _str(row, 0),
      handleInstagram: _str(row, 1),
      urlInstagram: _str(row, 2),
      nichoPrincipal: _str(row, 3),
      subNicho: _str(row, 4),
      seguidoresAprox: _int(row, 5),
      taxaEngagementEstimada: _str(row, 6),
      idadeAprox: _int(row, 7),
      cidade: _str(row, 8),
      emailContacto: _str(row, 9),
      tipoConta: _str(row, 10),
      tipoConteudo: _str(row, 11),
      autenticidade: _str(row, 12),
      aptoMasderm: _str(row, 13),
      scoreRelevancia: _int(row, 14),
      estadoProspeccao: _str(row, 15),
      dataPrimeiroContacto: _str(row, 16),
      dataUltimoContacto: _str(row, 17),
      produtosEnviados: _str(row, 18),
      publicacoesRealizadas: _str(row, 19),
      notas: _str(row, 20),
    );
  }

  static String _str(List<dynamic> row, int i) =>
      i < row.length ? (row[i]?.toString().trim() ?? '') : '';

  static int _int(List<dynamic> row, int i) {
    if (i >= row.length) return 0;
    final raw = row[i]?.toString().trim() ?? '';
    return int.tryParse(raw) ?? 0;
  }

  bool get isPrioridadeAlta => estadoProspeccao == 'PRIORIDADE ALTA';
  bool get isAptoMasderm => aptoMasderm == 'Sim';

  Color get scoreColor => AppTheme.scoreColor(scoreRelevancia);

  String get scoreColorHex {
    if (scoreRelevancia >= 8) return '#16A34A';
    if (scoreRelevancia >= 6) return '#CA8A04';
    return '#DC2626';
  }

  Influencer copyWith({
    String? nome,
    String? handleInstagram,
    String? urlInstagram,
    String? nichoPrincipal,
    String? subNicho,
    int? seguidoresAprox,
    String? taxaEngagementEstimada,
    int? idadeAprox,
    String? cidade,
    String? emailContacto,
    String? tipoConta,
    String? tipoConteudo,
    String? autenticidade,
    String? aptoMasderm,
    int? scoreRelevancia,
    String? estadoProspeccao,
    String? dataPrimeiroContacto,
    String? dataUltimoContacto,
    String? produtosEnviados,
    String? publicacoesRealizadas,
    String? notas,
  }) {
    return Influencer(
      nome: nome ?? this.nome,
      handleInstagram: handleInstagram ?? this.handleInstagram,
      urlInstagram: urlInstagram ?? this.urlInstagram,
      nichoPrincipal: nichoPrincipal ?? this.nichoPrincipal,
      subNicho: subNicho ?? this.subNicho,
      seguidoresAprox: seguidoresAprox ?? this.seguidoresAprox,
      taxaEngagementEstimada:
          taxaEngagementEstimada ?? this.taxaEngagementEstimada,
      idadeAprox: idadeAprox ?? this.idadeAprox,
      cidade: cidade ?? this.cidade,
      emailContacto: emailContacto ?? this.emailContacto,
      tipoConta: tipoConta ?? this.tipoConta,
      tipoConteudo: tipoConteudo ?? this.tipoConteudo,
      autenticidade: autenticidade ?? this.autenticidade,
      aptoMasderm: aptoMasderm ?? this.aptoMasderm,
      scoreRelevancia: scoreRelevancia ?? this.scoreRelevancia,
      estadoProspeccao: estadoProspeccao ?? this.estadoProspeccao,
      dataPrimeiroContacto:
          dataPrimeiroContacto ?? this.dataPrimeiroContacto,
      dataUltimoContacto: dataUltimoContacto ?? this.dataUltimoContacto,
      produtosEnviados: produtosEnviados ?? this.produtosEnviados,
      publicacoesRealizadas:
          publicacoesRealizadas ?? this.publicacoesRealizadas,
      notas: notas ?? this.notas,
    );
  }
}
