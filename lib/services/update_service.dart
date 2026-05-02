import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:open_file/open_file.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';

import '../theme/app_theme.dart';

// ─────────────────────────────────────────────────────────────────────────────
//  UpdateService
//
//  Vérifie à chaque démarrage si une mise à jour est disponible en consultant
//  un fichier version.json hébergé à distance.
//
//  Format attendu du version.json :
//  {
//    "build"    : 2,
//    "version"  : "1.0.1",
//    "apk_url"  : "https://example.com/tarika.apk",
//    "changelog": "Corrections et nouvelles fonctionnalités"
//  }
//
//  version.json est hébergé à la racine du repo GitHub :
//  https://github.com/Mohamed-el-hedi-dridi/app-tarika/blob/main/version.json
//
//  APK via GitHub Releases :
//  https://github.com/Mohamed-el-hedi-dridi/app-tarika/releases/download/vX.Y.Z/tarika.apk
// ─────────────────────────────────────────────────────────────────────────────
class UpdateService {
  static const String _versionJsonUrl =
      'https://raw.githubusercontent.com/Mohamed-el-hedi-dridi/app-tarika/main/version.json';

  /// À appeler via WidgetsBinding.addPostFrameCallback après le premier rendu.
  static Future<void> checkForUpdate(BuildContext context) async {
    if (!Platform.isAndroid) return;
    try {
      await _doCheck(context);
    } catch (_) {
      // Non critique — l'app continue normalement.
    }
  }

  static Future<void> _doCheck(BuildContext context) async {
    final info = await PackageInfo.fromPlatform();
    final currentBuild = int.tryParse(info.buildNumber) ?? 0;

    final response = await http
        .get(Uri.parse(_versionJsonUrl))
        .timeout(const Duration(seconds: 10));

    if (response.statusCode != 200) return;

    final data = json.decode(response.body) as Map<String, dynamic>;
    final remoteBuild = (data['build'] as num).toInt();
    if (remoteBuild <= currentBuild) return;

    if (!context.mounted) return;
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => _UpdateDialog(
        version: data['version'] as String? ?? '',
        changelog: data['changelog'] as String? ?? '',
        apkUrl: data['apk_url'] as String,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Dialogue de mise à jour avec barre de progression
// ─────────────────────────────────────────────────────────────────────────────
class _UpdateDialog extends StatefulWidget {
  final String version;
  final String changelog;
  final String apkUrl;

  const _UpdateDialog({
    required this.version,
    required this.changelog,
    required this.apkUrl,
  });

  @override
  State<_UpdateDialog> createState() => _UpdateDialogState();
}

class _UpdateDialogState extends State<_UpdateDialog> {
  double _progress = 0;
  bool   _downloading = false;
  String? _error;

  Future<void> _startDownload() async {
    setState(() {
      _downloading = true;
      _error = null;
      _progress = 0;
    });

    final client = http.Client();
    try {
      final tempDir  = await getTemporaryDirectory();
      final apkPath  = '${tempDir.path}/tarika_update.apk';
      final file     = File(apkPath);
      final sink     = file.openWrite();

      final request  = http.Request('GET', Uri.parse(widget.apkUrl));
      final response = await client
          .send(request)
          .timeout(const Duration(minutes: 10));

      final total = response.contentLength ?? 0;
      int received = 0;
      int lastNotifiedPercent = -1;

      await for (final chunk in response.stream) {
        sink.add(chunk);
        received += chunk.length;
        if (total > 0) {
          final percent = (received * 100 ~/ total);
          // Mise à jour UI tous les 2 % pour limiter les rebuilds
          if (percent != lastNotifiedPercent && percent % 2 == 0) {
            lastNotifiedPercent = percent;
            if (mounted) setState(() => _progress = received / total);
          }
        }
      }

      await sink.flush();
      await sink.close();

      if (mounted) setState(() => _progress = 1.0);

      await OpenFile.open(apkPath);

      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) {
        setState(() {
          _downloading = false;
          _error = 'فشل التحميل — تحقق من اتصالك بالإنترنت';
        });
      }
    } finally {
      client.close();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: AlertDialog(
        backgroundColor: AppTheme.cream,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.system_update_rounded, color: AppTheme.primaryGreen),
            const SizedBox(width: 10),
            Text(
              'تحديث جديد متاح',
              style: AppTheme.arabicTitle(size: 17, color: AppTheme.primaryGreen),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Version
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppTheme.lightGold.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppTheme.gold.withValues(alpha: 0.4)),
              ),
              child: Text(
                'الإصدار ${widget.version}',
                style: AppTheme.arabicBody(size: 14, color: AppTheme.darkBrown),
                textAlign: TextAlign.center,
              ),
            ),

            // Changelog
            if (widget.changelog.isNotEmpty) ...[
              const SizedBox(height: 10),
              Text(
                widget.changelog,
                style: AppTheme.arabicBody(size: 13, color: Colors.black54),
              ),
            ],

            // Barre de progression
            if (_downloading) ...[
              const SizedBox(height: 16),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: _progress > 0 ? _progress : null,
                  backgroundColor: AppTheme.lightGold,
                  color: AppTheme.primaryGreen,
                  minHeight: 8,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                _progress > 0
                    ? 'جارٍ التحميل… ${(_progress * 100).toStringAsFixed(0)}٪'
                    : 'جارٍ التحميل…',
                style: AppTheme.arabicBody(size: 12, color: AppTheme.primaryGreen),
                textAlign: TextAlign.center,
              ),
            ],

            // Erreur
            if (_error != null) ...[
              const SizedBox(height: 10),
              Row(
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 16),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      _error!,
                      style: const TextStyle(color: Colors.red, fontSize: 13),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
        actions: [
          if (!_downloading)
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'لاحقاً',
                style: AppTheme.arabicBody(size: 14, color: Colors.black45),
              ),
            ),
          if (!_downloading)
            FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: AppTheme.primaryGreen,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              icon: const Icon(Icons.download_rounded, size: 18),
              label: Text(
                'تحديث الآن',
                style: AppTheme.arabicBody(size: 14, color: Colors.white),
              ),
              onPressed: _startDownload,
            ),
        ],
      ),
    );
  }
}
