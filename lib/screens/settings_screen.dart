import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/ai_provider.dart';
import '../providers/data_provider.dart';
import '../theme/app_theme.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _keyController = TextEditingController();
  bool _obscureKey = true;
  bool _testing = false;
  String? _testResult;

  @override
  void initState() {
    super.initState();
    _loadKey();
  }

  Future<void> _loadKey() async {
    final prefs = await SharedPreferences.getInstance();
    final key = prefs.getString('anthropic_api_key') ?? '';
    if (!mounted) return;
    _keyController.text = key;
    await context.read<AiProvider>().loadApiKey();
  }

  Future<void> _saveKey() async {
    final ai = context.read<AiProvider>();
    await ai.saveApiKey(_keyController.text.trim());
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('API Key guardada'), duration: Duration(seconds: 2)),
      );
    }
  }

  Future<void> _testConnection() async {
    await context.read<AiProvider>().saveApiKey(_keyController.text.trim());
    setState(() { _testing = true; _testResult = null; });
    final ok = await context.read<AiProvider>().testConnection();
    if (mounted) setState(() { _testing = false; _testResult = ok ? 'Ligação bem-sucedida ✓' : 'Falhou — verifica a API Key'; });
  }

  @override
  void dispose() {
    _keyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final data = context.watch<DataProvider>();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Definições', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          const Text('Configura integrações e preferências da plataforma.',
              style: TextStyle(color: AppTheme.textSecondary, fontSize: 14)),
          const SizedBox(height: 32),

          // AI Section
          _SectionCard(
            title: 'Inteligência Artificial',
            icon: Icons.psychology_outlined,
            children: [
              const Text(
                'Anthropic API Key',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 4),
              const Text(
                'Necessária para análise de influencers, geração de emails e sugestões automáticas. Obtém a tua chave em console.anthropic.com.',
                style: TextStyle(fontSize: 13, color: AppTheme.textSecondary),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _keyController,
                obscureText: _obscureKey,
                style: const TextStyle(fontSize: 13, fontFamily: 'monospace'),
                decoration: InputDecoration(
                  hintText: 'sk-ant-...',
                  suffixIcon: IconButton(
                    icon: Icon(_obscureKey ? Icons.visibility_outlined : Icons.visibility_off_outlined, size: 18),
                    onPressed: () => setState(() => _obscureKey = !_obscureKey),
                  ),
                ),
              ),
              if (_testResult != null) ...[
                const SizedBox(height: 8),
                Text(
                  _testResult!,
                  style: TextStyle(
                    fontSize: 13,
                    color: _testResult!.contains('✓') ? AppTheme.scoreHigh : AppTheme.scoreLow,
                  ),
                ),
              ],
              const SizedBox(height: 16),
              Row(
                children: [
                  ElevatedButton(
                    onPressed: _saveKey,
                    child: const Text('Guardar'),
                  ),
                  const SizedBox(width: 8),
                  OutlinedButton(
                    onPressed: _testing ? null : _testConnection,
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppTheme.borderColor),
                      foregroundColor: AppTheme.textPrimary,
                    ),
                    child: _testing
                        ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2))
                        : const Text('Testar ligação'),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Data Section
          _SectionCard(
            title: 'Dados',
            icon: Icons.cloud_sync_outlined,
            children: [
              _InfoRow(label: 'Fonte de dados', value: 'GitHub (P-Correa/masderm-portal)'),
              _InfoRow(label: 'Influencers carregadas', value: '${data.influencers.length}'),
              _InfoRow(label: 'Parcerias', value: '${data.parcerias.length}'),
              _InfoRow(label: 'Produtos', value: '${data.produtos.length}'),
              if (data.lastUpdated != null)
                _InfoRow(label: 'Última sincronização', value: _formatDate(data.lastUpdated!)),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: data.isLoading ? null : () => data.refresh(context),
                icon: data.isLoading
                    ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Icon(Icons.refresh, size: 16),
                label: const Text('Forçar atualização'),
              ),
              const SizedBox(height: 8),
              const Text(
                'Os dados são atualizados automaticamente a cada sessão. O agente semanal adiciona novas influencers todas as segundas-feiras.',
                style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // About Section
          _SectionCard(
            title: 'Sobre',
            icon: Icons.info_outline,
            children: [
              _InfoRow(label: 'Versão', value: '1.0.0'),
              _InfoRow(label: 'Plataforma', value: 'Masderm Portugal — Gestão de Parcerias'),
              _InfoRow(label: 'Repositório', value: 'github.com/P-Correa/masderm-portal'),
              _InfoRow(label: 'Login', value: 'adminmasderm@test.com'),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime dt) {
    return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;

  const _SectionCard({required this.title, required this.icon, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: AppTheme.cardDecoration(),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: AppTheme.textPrimary),
              const SizedBox(width: 8),
              Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 20),
          const Divider(height: 1),
          const SizedBox(height: 20),
          ...children,
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          SizedBox(
            width: 200,
            child: Text(label, style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
          ),
          Expanded(
            child: Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }
}
