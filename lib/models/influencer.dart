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
}
