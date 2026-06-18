class Parceria {
  final String idParceria;
  final String handleInfluenciadora;
  final String nomeInfluenciadora;
  final String produtoPrincipal;
  final String tipoColaboracao;
  final String valorAcordadoEur;
  final String dataAcordo;
  final String dataEnvioBriefing;
  final String dataPublicacaoPrevista;
  final String dataPublicacaoReal;
  final String tipoConteudoAcordado;
  final String linkPublicacao;
  final String alcanceReal;
  final String impressoes;
  final String likes;
  final String comentarios;
  final String partilhas;
  final String taxaEngagementPublicacao;
  final String estadoPipeline;
  final String proximaAccao;
  final String dataProximaAccao;
  final String responsavel;
  final String notasInternas;

  const Parceria({
    required this.idParceria,
    required this.handleInfluenciadora,
    required this.nomeInfluenciadora,
    required this.produtoPrincipal,
    required this.tipoColaboracao,
    required this.valorAcordadoEur,
    required this.dataAcordo,
    required this.dataEnvioBriefing,
    required this.dataPublicacaoPrevista,
    required this.dataPublicacaoReal,
    required this.tipoConteudoAcordado,
    required this.linkPublicacao,
    required this.alcanceReal,
    required this.impressoes,
    required this.likes,
    required this.comentarios,
    required this.partilhas,
    required this.taxaEngagementPublicacao,
    required this.estadoPipeline,
    required this.proximaAccao,
    required this.dataProximaAccao,
    required this.responsavel,
    required this.notasInternas,
  });

  factory Parceria.fromCsv(List<dynamic> row) {
    return Parceria(
      idParceria: _str(row, 0),
      handleInfluenciadora: _str(row, 1),
      nomeInfluenciadora: _str(row, 2),
      produtoPrincipal: _str(row, 3),
      tipoColaboracao: _str(row, 4),
      valorAcordadoEur: _str(row, 5),
      dataAcordo: _str(row, 6),
      dataEnvioBriefing: _str(row, 7),
      dataPublicacaoPrevista: _str(row, 8),
      dataPublicacaoReal: _str(row, 9),
      tipoConteudoAcordado: _str(row, 10),
      linkPublicacao: _str(row, 11),
      alcanceReal: _str(row, 12),
      impressoes: _str(row, 13),
      likes: _str(row, 14),
      comentarios: _str(row, 15),
      partilhas: _str(row, 16),
      taxaEngagementPublicacao: _str(row, 17),
      estadoPipeline: _str(row, 18),
      proximaAccao: _str(row, 19),
      dataProximaAccao: _str(row, 20),
      responsavel: _str(row, 21),
      notasInternas: _str(row, 22),
    );
  }

  static String _str(List<dynamic> row, int i) =>
      i < row.length ? (row[i]?.toString().trim() ?? '') : '';

  bool get isAtiva {
    final estado = estadoPipeline.toUpperCase();
    return estado.contains('ATIV') ||
        estado.contains('PUBL') ||
        estado.contains('EM CURSO');
  }

  Parceria copyWith({
    String? idParceria,
    String? handleInfluenciadora,
    String? nomeInfluenciadora,
    String? produtoPrincipal,
    String? tipoColaboracao,
    String? valorAcordadoEur,
    String? dataAcordo,
    String? dataEnvioBriefing,
    String? dataPublicacaoPrevista,
    String? dataPublicacaoReal,
    String? tipoConteudoAcordado,
    String? linkPublicacao,
    String? alcanceReal,
    String? impressoes,
    String? likes,
    String? comentarios,
    String? partilhas,
    String? taxaEngagementPublicacao,
    String? estadoPipeline,
    String? proximaAccao,
    String? dataProximaAccao,
    String? responsavel,
    String? notasInternas,
  }) {
    return Parceria(
      idParceria: idParceria ?? this.idParceria,
      handleInfluenciadora:
          handleInfluenciadora ?? this.handleInfluenciadora,
      nomeInfluenciadora: nomeInfluenciadora ?? this.nomeInfluenciadora,
      produtoPrincipal: produtoPrincipal ?? this.produtoPrincipal,
      tipoColaboracao: tipoColaboracao ?? this.tipoColaboracao,
      valorAcordadoEur: valorAcordadoEur ?? this.valorAcordadoEur,
      dataAcordo: dataAcordo ?? this.dataAcordo,
      dataEnvioBriefing: dataEnvioBriefing ?? this.dataEnvioBriefing,
      dataPublicacaoPrevista:
          dataPublicacaoPrevista ?? this.dataPublicacaoPrevista,
      dataPublicacaoReal: dataPublicacaoReal ?? this.dataPublicacaoReal,
      tipoConteudoAcordado:
          tipoConteudoAcordado ?? this.tipoConteudoAcordado,
      linkPublicacao: linkPublicacao ?? this.linkPublicacao,
      alcanceReal: alcanceReal ?? this.alcanceReal,
      impressoes: impressoes ?? this.impressoes,
      likes: likes ?? this.likes,
      comentarios: comentarios ?? this.comentarios,
      partilhas: partilhas ?? this.partilhas,
      taxaEngagementPublicacao:
          taxaEngagementPublicacao ?? this.taxaEngagementPublicacao,
      estadoPipeline: estadoPipeline ?? this.estadoPipeline,
      proximaAccao: proximaAccao ?? this.proximaAccao,
      dataProximaAccao: dataProximaAccao ?? this.dataProximaAccao,
      responsavel: responsavel ?? this.responsavel,
      notasInternas: notasInternas ?? this.notasInternas,
    );
  }
}
