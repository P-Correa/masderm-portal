class Influencer {
  final String nome;
  final String link;
  final String contacto;
  final String estado;
  final double engagement;
  final double ubicacion;
  final double idade;
  final double mulheres;
  final int followers;
  final double fee;
  final int numVideos;
  final int mesesPP;
  final double feeMensual;
  final String contrato;
  final String pp;
  final String factura;
  final String direccion;
  final bool firming;
  final bool facial;
  final bool slim;
  final bool bodyDevice;
  final bool deviceFacialPlus;
  final bool rfDeviceFacial;
  final bool peptidmas;
  final bool collagenmas;
  final bool lipomasGelDevice;
  final String notas;

  const Influencer({
    required this.nome,
    required this.link,
    required this.contacto,
    required this.estado,
    required this.engagement,
    required this.ubicacion,
    required this.idade,
    required this.mulheres,
    required this.followers,
    required this.fee,
    required this.numVideos,
    required this.mesesPP,
    required this.feeMensual,
    required this.contrato,
    required this.pp,
    required this.factura,
    required this.direccion,
    required this.firming,
    required this.facial,
    required this.slim,
    required this.bodyDevice,
    required this.deviceFacialPlus,
    required this.rfDeviceFacial,
    required this.peptidmas,
    required this.collagenmas,
    required this.lipomasGelDevice,
    required this.notas,
  });

  String get handle {
    if (link.isEmpty) return '';
    try {
      final uri = Uri.parse(link.trim());
      final segments = uri.pathSegments.where((s) => s.isNotEmpty).toList();
      return segments.isNotEmpty ? '@${segments[0]}' : link;
    } catch (_) {
      return link;
    }
  }

  bool get isMensual => estado == 'Mensual';
  bool get isAtiva => const ['Mensual', 'Aprobada', 'Producto enviado', 'Contenido recibido', 'Contenido subido'].contains(estado);
  bool get isExcluida => estado == 'Rechazada' || estado == 'Embarazada';

  int get estadoPrioridade {
    switch (estado) {
      case 'Mensual': return 7;
      case 'Contenido subido': return 6;
      case 'Contenido recibido': return 5;
      case 'Producto enviado': return 4;
      case 'Aprobada': return 3;
      case 'Contactada': return 2;
      case 'Rechazada': return -1;
      case 'Embarazada': return -1;
      default: return 0;
    }
  }

  List<String> get produtosAtivos {
    final result = <String>[];
    if (firming) result.add('Firming');
    if (facial) result.add('Facial');
    if (slim) result.add('Slim');
    if (bodyDevice) result.add('Body Device');
    if (deviceFacialPlus) result.add('Device Facial+');
    if (rfDeviceFacial) result.add('RF Device');
    if (peptidmas) result.add('Peptidmas');
    if (collagenmas) result.add('Collagenmas');
    if (lipomasGelDevice) result.add('Lipomas Gel');
    return result;
  }

  factory Influencer.fromCsv(List<dynamic> r) {
    double parseDouble(dynamic v) {
      if (v == null || v.toString().isEmpty) return 0.0;
      return double.tryParse(v.toString()) ?? 0.0;
    }
    int parseInt(dynamic v) {
      if (v == null || v.toString().isEmpty) return 0;
      return int.tryParse(v.toString()) ?? 0;
    }
    bool parseBool(dynamic v) {
      return v?.toString().toLowerCase() == 'true';
    }
    String s(int i) => i < r.length ? r[i]?.toString().trim() ?? '' : '';

    return Influencer(
      nome: s(0),
      link: s(1),
      contacto: s(2),
      estado: s(3),
      engagement: parseDouble(r.length > 4 ? r[4] : null),
      ubicacion: parseDouble(r.length > 5 ? r[5] : null),
      idade: parseDouble(r.length > 6 ? r[6] : null),
      mulheres: parseDouble(r.length > 7 ? r[7] : null),
      followers: parseInt(r.length > 8 ? r[8] : null),
      fee: parseDouble(r.length > 9 ? r[9] : null),
      numVideos: parseInt(r.length > 10 ? r[10] : null),
      mesesPP: parseInt(r.length > 11 ? r[11] : null),
      feeMensual: parseDouble(r.length > 12 ? r[12] : null),
      contrato: s(13),
      pp: s(14),
      factura: s(15),
      direccion: s(16),
      firming: parseBool(r.length > 17 ? r[17] : null),
      facial: parseBool(r.length > 18 ? r[18] : null),
      slim: parseBool(r.length > 19 ? r[19] : null),
      bodyDevice: parseBool(r.length > 20 ? r[20] : null),
      deviceFacialPlus: parseBool(r.length > 21 ? r[21] : null),
      rfDeviceFacial: parseBool(r.length > 22 ? r[22] : null),
      peptidmas: parseBool(r.length > 23 ? r[23] : null),
      collagenmas: parseBool(r.length > 24 ? r[24] : null),
      lipomasGelDevice: parseBool(r.length > 25 ? r[25] : null),
      notas: s(26),
    );
  }
}
