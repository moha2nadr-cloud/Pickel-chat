import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/conversation_provider.dart';
import '../providers/settings_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _hideKey = true;
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (_, settings, __) {
        _controller.value = TextEditingValue(text: settings.apiKey);
        return Scaffold(
          appBar: AppBar(title: const Text('Settings')),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              TextField(
                controller: _controller,
                obscureText: _hideKey,
                decoration: InputDecoration(
                  labelText: 'API Key',
                  suffixIcon: IconButton(
                    icon: Icon(_hideKey ? Icons.visibility : Icons.visibility_off),
                    onPressed: () => setState(() => _hideKey = !_hideKey),
                  ),
                ),
                onChanged: settings.updateApiKey,
              ),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: settings.isLoading
                    ? null
                    : () async {
                        final ok = await settings.testConnection();
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(ok ? 'Connection successful' : 'Connection failed')),
                        );
                      },
                child: const Text('Test connection'),
              ),
              const SizedBox(height: 20),
              DropdownButtonFormField<String>(
                value: settings.settings.themeModeValue,
                decoration: const InputDecoration(labelText: 'Theme'),
                items: const [
                  DropdownMenuItem(value: 'system', child: Text('System')),
                  DropdownMenuItem(value: 'light', child: Text('Light')),
                  DropdownMenuItem(value: 'dark', child: Text('Dark')),
                ],
                onChanged: (v) {
                  if (v != null) settings.updateTheme(v);
                },
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: settings.language,
                decoration: const InputDecoration(labelText: 'Language'),
                items: const [
                  DropdownMenuItem(value: 'ar', child: Text('Arabic')),
                  DropdownMenuItem(value: 'en', child: Text('English')),
                ],
                onChanged: (v) {
                  if (v != null) settings.updateLanguage(v);
                },
              ),
              const SizedBox(height: 20),
              OutlinedButton(
                onPressed: () => _confirmClear(context),
                child: const Text('Clear all history'),
              ),
              const SizedBox(height: 20),
              const Text('Version: 1.0.0+1'),
              const SizedBox(height: 6),
              const SelectableText('OpenCode Zen docs: https://opencode.ai/zen/docs'),
            ],
          ),
        );
      },
    );
  }

  Future<void> _confirmClear(BuildContext context) async {
    final clear = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Confirm'),
        content: const Text('Delete all conversations?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete')),
        ],
      ),
    );
    if (clear == true && context.mounted) {
      await context.read<ConversationProvider>().clearAll();
    }
  }
}
