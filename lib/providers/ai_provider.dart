import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/influencer.dart';

class AiProvider extends ChangeNotifier {
  String _apiKey = '';
  bool _isLoading = false;
  String? _error;

  bool get hasApiKey => _apiKey.isNotEmpty;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadApiKey() async {
    final prefs = await SharedPreferences.getInstance();
    _apiKey = prefs.getString('gemini_api_key') ?? '';
    notifyListeners();
  }

  Future<void> saveApiKey(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('gemini_api_key', key);
    _apiKey = key;
    notifyListeners();
  }

  Future<String> _callGemini(String prompt) async {
    if (_apiKey.isEmpty) {
      throw Exception('API Key não configurada. Vai a Definições para adicionar a tua Google Gemini API Key.');
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final url = Uri.parse(
        'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=$_apiKey',
      );

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'contents': [
            {
              'parts': [{'text': prompt}]
            }
          ],
          'generationConfig': {
            'maxOutputTokens': 1024,
            'temperature': 0.7,
          },
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['candidates'][0]['content']['parts'][0]['text'] as String;
      } else {
        final err = jsonDecode(response.body);
        throw Exception(err['error']?['message'] ?? 'Erro na API: ${response.statusCode}');
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<String> analyzeInfluencer(Influencer inf) async {
    final prompt = '''Analisa este perfil de influenciadora portuguesa para a marca Masderm (dermocosméticos, tecnologia de radiofrequência, público +35 anos).

**Perfil:**
- Nome: ${inf.nome}
- Instagram: @${inf.handleInstagram}
- Nicho: ${inf.nichoPrincipal} / ${inf.subNicho}
- Seguidores: ${inf.seguidoresAprox}
- Taxa de Engagement: ${inf.taxaEngagementEstimada}
- Idade aprox: ${inf.idadeAprox} anos
- Cidade: ${inf.cidade}
- Tipo de conta: ${inf.tipoConta}
- Tipo de conteúdo: ${inf.tipoConteudo}
- Autenticidade: ${inf.autenticidade}
- Score atual: ${inf.scoreRelevancia}/10
- Estado: ${inf.estadoProspeccao}
- Notas: ${inf.notas}

Responde em português de Portugal com:
1. **Pontos Fortes** para parceria com a Masderm (2-3 pontos)
2. **Pontos de Atenção** (1-2 riscos ou limitações)
3. **Produtos Recomendados** para gifting inicial (2-3 produtos Masderm específicos)
4. **Abordagem Sugerida** (como contactar e que tipo de parceria propor)
5. **Recomendação Final**: Prioridade Alta / Média / Baixa e porquê

Resposta concisa e direta.''';

    return _callGemini(prompt);
  }

  Future<String> generateProspectionEmail(Influencer inf, String productName) async {
    final prompt = '''Escreve um email de prospeção em português de Portugal para a influenciadora @${inf.handleInstagram} (${inf.nome}), do nicho ${inf.nichoPrincipal}, com ${inf.seguidoresAprox} seguidores.

O email é da Masderm Portugal, marca de dermocosméticos com tecnologia de radiofrequência. O produto a oferecer é: $productName.

O email deve ser:
- Profissional mas caloroso
- Personalizado para o nicho da influenciadora
- Máximo 150 palavras
- Com objeto do email (linha "Assunto:")
- Mencionar o produto de forma natural
- Propor gifting com possibilidade de parceria

Formato: Assunto: [...]\\n\\n[corpo do email]''';

    return _callGemini(prompt);
  }

  Future<List<Map<String, String>>> getTop5Recommendations(List<Influencer> influencers) async {
    final available = influencers
        .where((i) =>
            i.estadoProspeccao == 'PRIORIDADE ALTA' ||
            i.estadoProspeccao == 'A CONTACTAR' ||
            i.estadoProspeccao == 'EM AVALIAÇÃO')
        .take(15)
        .toList();

    if (available.isEmpty) return [];

    final listText = available
        .map((i) =>
            '- @${i.handleInstagram}: score ${i.scoreRelevancia}, ${i.nichoPrincipal}, ${i.seguidoresAprox} seguidores, estado: ${i.estadoProspeccao}')
        .join('\n');

    final prompt = '''Seleciona as 5 melhores influenciadoras para contactar esta semana para a marca Masderm Portugal (dermocosméticos +35 anos):

$listText

Para cada uma, responde APENAS com este formato exacto (5 linhas):
HANDLE: @handle | RAZÃO: motivo curto (max 15 palavras)

Ordena por prioridade de contacto.''';

    final result = await _callGemini(prompt);
    final lines = result.split('\n').where((l) => l.startsWith('HANDLE:')).toList();

    return lines.map((line) {
      final parts = line.split('|');
      final handle = parts[0].replaceAll('HANDLE:', '').trim();
      final reason = parts.length > 1 ? parts[1].replaceAll('RAZÃO:', '').trim() : '';
      return {'handle': handle, 'reason': reason};
    }).toList();
  }

  Future<String?> testConnection() async {
    try {
      await _callGemini('Responde apenas com: OK');
      return null; // null = success
    } catch (e) {
      return e.toString();
    }
  }
}
