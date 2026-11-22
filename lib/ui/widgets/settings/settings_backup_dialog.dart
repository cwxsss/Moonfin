import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:path/path.dart' as p;

import '../../../preference/user_preferences.dart';
import '../../navigation/home_refresh_bus.dart';

/// 弹出配置导入与导出对话框
Future<void> showSettingsBackupDialog(BuildContext context) {
  return showDialog<void>(
    context: context,
    barrierDismissible: true,
    builder: (context) => const SettingsBackupDialog(),
  );
}

class SettingsBackupDialog extends StatefulWidget {
  const SettingsBackupDialog({super.key});

  @override
  State<SettingsBackupDialog> createState() => _SettingsBackupDialogState();
}

class _SettingsBackupDialogState extends State<SettingsBackupDialog>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final _prefs = GetIt.instance<UserPreferences>();
  final _importController = TextEditingController();

  String _exportedJson = '';
  String? _statusMessage;
  bool _isSuccess = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _generateExport();
  }

  void _generateExport() {
    try {
      _exportedJson = _prefs.exportPreferencesJson();
    } catch (e) {
      _exportedJson = '导出失败: $e';
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _importController.dispose();
    super.dispose();
  }

  Future<void> _copyExportToClipboard() async {
    await Clipboard.setData(ClipboardData(text: _exportedJson));
    if (!mounted) return;
    setState(() {
      _statusMessage = '已成功复制配置 JSON 到剪贴板！';
      _isSuccess = true;
    });
  }

  Future<void> _pasteFromClipboard() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    if (data?.text != null && mounted) {
      setState(() {
        _importController.text = data!.text!;
      });
    }
  }

  Future<void> _exportToFile() async {
    try {
      final userProfile = Platform.environment['USERPROFILE'] ??
          Platform.environment['HOME'] ??
          '';
      final downloadDir = Directory(p.join(userProfile, 'Downloads'));
      final targetDir = downloadDir.existsSync()
          ? downloadDir.path
          : Directory.current.path;
      final file = File(p.join(targetDir, 'moonfin_config_backup.json'));
      await file.writeAsString(_exportedJson);
      if (!mounted) return;
      setState(() {
        _statusMessage = '已成功保存配置到: ${file.path}';
        _isSuccess = true;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _statusMessage = '保存文件失败: $e';
        _isSuccess = false;
      });
    }
  }

  Future<void> _applyImport() async {
    final text = _importController.text.trim();
    if (text.isEmpty) {
      setState(() {
        _statusMessage = '请先粘贴或输入要导入的配置 JSON 内容';
        _isSuccess = false;
      });
      return;
    }

    try {
      final count = await _prefs.importPreferencesJson(text);
      homeRefreshBus.request(newMediaBar: true, force: true);
      if (!mounted) return;
      setState(() {
        _statusMessage = '成功导入并应用了 $count 项个性化配置！';
        _isSuccess = true;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _statusMessage = '导入失败，请检查配置格式: $e';
        _isSuccess = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xFF1E1E1E),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 540, maxHeight: 600),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.settings_backup_restore,
                          color: Colors.white, size: 22),
                      SizedBox(width: 8),
                      Text(
                        '配置备份与还原',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white70),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TabBar(
                controller: _tabController,
                indicatorColor: Theme.of(context).colorScheme.primary,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white54,
                tabs: const [
                  Tab(text: '导出配置'),
                  Tab(text: '导入配置'),
                ],
              ),
              const SizedBox(height: 12),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    // Tab 1: 导出
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text(
                          '当前客户端的所有自定义偏好（媒体库显隐、界面缩放、播放器偏好、主题等）已打包：',
                          style: TextStyle(color: Colors.white70, fontSize: 13),
                        ),
                        const SizedBox(height: 8),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.black38,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.white12),
                            ),
                            child: SingleChildScrollView(
                              child: SelectableText(
                                _exportedJson,
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontFamily: 'monospace',
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            OutlinedButton.icon(
                              icon: const Icon(Icons.save_alt_rounded, size: 18),
                              label: const Text('保存为文件'),
                              onPressed: _exportToFile,
                            ),
                            const SizedBox(width: 12),
                            ElevatedButton.icon(
                              icon: const Icon(Icons.copy_rounded, size: 18),
                              label: const Text('复制到剪贴板'),
                              onPressed: _copyExportToClipboard,
                            ),
                          ],
                        ),
                      ],
                    ),
                    // Tab 2: 导入
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text(
                          '将先前导出的 JSON 配置粘贴在下方，点击应用即可立即恢复：',
                          style: TextStyle(color: Colors.white70, fontSize: 13),
                        ),
                        const SizedBox(height: 8),
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.black38,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.white12),
                            ),
                            child: TextField(
                              controller: _importController,
                              maxLines: null,
                              expands: true,
                              style: const TextStyle(
                                color: Colors.white,
                                fontFamily: 'monospace',
                                fontSize: 12,
                              ),
                              decoration: const InputDecoration(
                                hintText: '在此粘贴配置 JSON 内容...',
                                hintStyle: TextStyle(color: Colors.white30),
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.all(12),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            TextButton.icon(
                              icon: const Icon(Icons.paste_rounded, size: 18),
                              label: const Text('从剪贴板粘贴'),
                              onPressed: _pasteFromClipboard,
                            ),
                            ElevatedButton.icon(
                              icon: const Icon(Icons.check_rounded, size: 18),
                              label: const Text('应用并还原配置'),
                              onPressed: _applyImport,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (_statusMessage != null) ...[
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: _isSuccess
                        ? Colors.green.withValues(alpha: 0.15)
                        : Colors.red.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: _isSuccess ? Colors.green : Colors.redAccent,
                      width: 0.8,
                    ),
                  ),
                  child: Text(
                    _statusMessage!,
                    style: TextStyle(
                      color: _isSuccess ? Colors.greenAccent : Colors.redAccent,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
