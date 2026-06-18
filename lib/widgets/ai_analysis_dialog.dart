import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/influencer.dart';
import '../providers/ai_provider.dart';
import '../providers/data_provider.dart';
import '../theme/app_theme.dart';
import 'copy_button.dart';

class AiAnalysisDialog extends StatefulWidget {
  final Influencer influencer;

  const AiAnalysisDialog({super.key, required this.influencer});

  /// Shows the dialog with a scale(0.95→1) + opacity entry — never from scale(0).
  static Future<void> show(BuildContext context, Influencer influencer) {
    return showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Fechar',
      barrierColor: Colors.black.withValues(alpha: 0.45),
      transitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (_, __, ___) => AiAnalysisDialog(influencer: influencer),
      transitionBuilder: (ctx, anim, _, child) {
        final curved = CurvedAnimation(parent: anim, curve: Curves.easeOut);
        return FadeTransition(
          opacity: curved,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.95, end: 1.0).animate(curved),
            child: child,
          ),
        );
      },
    );
  }

  @override
  State<AiAnalysisDialog> createState() => _AiAnalysisDialogState();
}

class _AiAnalysisDialogState extends State<AiAnalysisDialog> {
  String? _analysis;
  String? _error;
  bool _loading = true;
  bool _showEmailGen = false;
  String? _selectedProduct;
  String? _generatedEmail;
  bool _loadingEmail = false;

  @override
  void initState() {
    super.initState();
    _analyze();
  }

  Future<void> _analyze() async {
    final ai = context.read<AiProvider>();
    try {
      final result = await ai.analyzeInfluencer(widget.influencer);
      if (mounted) setState(() { _analysis = result; _loading = false; });
    } catch (e) {
      if (mounted) setState(() { _error = e.toString(); _loading = false; });
    }
  }

  Future<void> _generateEmail() async {
    if (_selectedProduct == null) return;
    final ai = context.read<AiProvider>();
    setState(() => _loadingEmail = true);
    try {
      final email = await ai.generateProspectionEmail(widget.influencer, _selectedProduct!);
      if (mounted) setState(() { _generatedEmail = email; _loadingEmail = false; });
    } catch (e) {
      if (mounted) setState(() { _loadingEmail = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final produtos = context.watch<DataProvider>().produtos
        .where((p) => p.idealParaInfluencer == 'Sim' && p.disponibilidade == 'Disponível')
        .map((p) => p.nomeProduto)
        .toList();

    return Dialog(
      backgroundColor: AppTheme.surfaceColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560, maxHeight: 640),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 16, 0),
              child: Row(
                children: [
                  const Icon(Icons.psychology_outlined, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Análise IA — @${widget.influencer.handleInstagram}',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, size: 18),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                  ),
                ],
              ),
            ),
            const Divider(height: 20),
            // Content
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 0),
                child: _loading
                    ? const Padding(
                        padding: EdgeInsets.symmetric(vertical: 40),
                        child: Center(
                          child: Column(
                            children: [
                              CircularProgressIndicator(strokeWidth: 2),
                              SizedBox(height: 16),
                              Text('A analisar com IA...', style: TextStyle(color: AppTheme.textSecondary)),
                            ],
                          ),
                        ),
                      )
                    : _error != null
                        ? Padding(
                            padding: const EdgeInsets.symmetric(vertical: 24),
                            child: Text(_error!, style: const TextStyle(color: AppTheme.scoreLow)),
                          )
                        : Text(_analysis ?? '', style: const TextStyle(fontSize: 13, height: 1.6)),
              ),
            ),
            // Email generator section
            if (!_loading && _error == null) ...[
              const Divider(height: 24),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
                child: _showEmailGen
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Gerar email de prospeção',
                              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                          const SizedBox(height: 10),
                          DropdownButtonFormField<String>(
                            initialValue: _selectedProduct,
                            hint: const Text('Selecionar produto'),
                            decoration: InputDecoration(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(6),
                                borderSide: const BorderSide(color: AppTheme.borderColor),
                              ),
                            ),
                            items: produtos.map((p) => DropdownMenuItem(value: p, child: Text(p, style: const TextStyle(fontSize: 13)))).toList(),
                            onChanged: (v) => setState(() { _selectedProduct = v; _generatedEmail = null; }),
                          ),
                          if (_generatedEmail != null) ...[
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppTheme.bgColor,
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: AppTheme.borderColor),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(child: Text(_generatedEmail!, style: const TextStyle(fontSize: 12, height: 1.5))),
                                  CopyButton(text: _generatedEmail!, tooltip: 'Copiar email'),
                                ],
                              ),
                            ),
                          ],
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              TextButton(
                                onPressed: () => setState(() => _showEmailGen = false),
                                child: const Text('Cancelar'),
                              ),
                              const SizedBox(width: 8),
                              ElevatedButton(
                                onPressed: _selectedProduct == null || _loadingEmail ? null : _generateEmail,
                                child: _loadingEmail
                                    ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                                    : const Text('Gerar email'),
                              ),
                            ],
                          ),
                        ],
                      )
                    : OutlinedButton.icon(
                        onPressed: () => setState(() => _showEmailGen = true),
                        icon: const Icon(Icons.email_outlined, size: 16),
                        label: const Text('Gerar email de prospeção'),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppTheme.borderColor),
                          foregroundColor: AppTheme.textPrimary,
                        ),
                      ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
