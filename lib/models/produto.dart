class Produto {
  final String nomeProduto;
  final String categoria;
  final String subCategoria;
  final String tipo;
  final double precoEur;
  final String descricao;
  final String paraQueServe;
  final String tecnologia;
  final String disponibilidade;
  final String idealParaInfluencer;
  final String notasParceria;

  const Produto({
    required this.nomeProduto,
    required this.categoria,
    required this.subCategoria,
    required this.tipo,
    required this.precoEur,
    required this.descricao,
    required this.paraQueServe,
    required this.tecnologia,
    required this.disponibilidade,
    required this.idealParaInfluencer,
    required this.notasParceria,
  });

  factory Produto.fromCsv(List<dynamic> row) {
    return Produto(
      nomeProduto: _str(row, 0),
      categoria: _str(row, 1),
      subCategoria: _str(row, 2),
      tipo: _str(row, 3),
      precoEur: _double(row, 4),
      descricao: _str(row, 5),
      paraQueServe: _str(row, 6),
      tecnologia: _str(row, 7),
      disponibilidade: _str(row, 8),
      idealParaInfluencer: _str(row, 9),
      notasParceria: _str(row, 10),
    );
  }

  static String _str(List<dynamic> row, int i) =>
      i < row.length ? (row[i]?.toString().trim() ?? '') : '';

  static double _double(List<dynamic> row, int i) {
    if (i >= row.length) return 0.0;
    final raw = row[i]?.toString().trim().replaceAll(',', '.') ?? '';
    return double.tryParse(raw) ?? 0.0;
  }

  bool get isDisponivel => disponibilidade == 'Disponível';
  bool get isIdealInfluencer => idealParaInfluencer == 'Sim';

  String get precoFormatado => '€${precoEur.toStringAsFixed(2)}';
}
