import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart' show rootBundle;
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// 数据更新器：在线检查 GitHub Releases 上发布的最新数据包并增量下载。
class DataUpdater {
  DataUpdater({http.Client? client}) : _client = client ?? http.Client();
  final http.Client _client;

  static const _bundledVersionAsset = 'assets/data/version.json';
  static const _dataFiles = [
    'cities.json',
    'fruits.json',
    'recommendations.json',
    'prices.json',
  ];

  Future<Directory> dataDir() async {
    final docs = await getApplicationDocumentsDirectory();
    final dir = Directory(p.join(docs.path, 'data'));
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  /// 启动时调用：保证本地 data/version.json 至少有一份。
  Future<int> ensureLocalCopy() async {
    final dir = await dataDir();
    final localVer = File(p.join(dir.path, 'version.json'));
    if (await localVer.exists()) {
      try {
        return (jsonDecode(await localVer.readAsString())['version'] as num)
            .toInt();
      } catch (_) {}
    }
    final bundled = await rootBundle.loadString(_bundledVersionAsset);
    await localVer.writeAsString(bundled);
    return (jsonDecode(bundled)['version'] as num).toInt();
  }

  Future<int> currentVersion() async {
    final dir = await dataDir();
    final f = File(p.join(dir.path, 'version.json'));
    if (!await f.exists()) return await ensureLocalCopy();
    return (jsonDecode(await f.readAsString())['version'] as num).toInt();
  }

  Future<String> _manifestUrl() async {
    final dir = await dataDir();
    final f = File(p.join(dir.path, 'version.json'));
    final raw = await f.exists()
        ? await f.readAsString()
        : await rootBundle.loadString(_bundledVersionAsset);
    return jsonDecode(raw)['manifest_url'] as String;
  }

  /// 检查远端 manifest，如有新版本则下载并覆盖本地数据。
  Future<UpdateResult> checkAndDownload(
      {Duration timeout = const Duration(seconds: 8)}) async {
    final localVer = await currentVersion();
    final url = await _manifestUrl();
    final manifestResp = await _client.get(Uri.parse(url)).timeout(timeout);
    if (manifestResp.statusCode != 200) {
      return UpdateResult(
          updated: false, message: '检查更新失败：HTTP ${manifestResp.statusCode}');
    }
    final manifest = jsonDecode(manifestResp.body) as Map<String, dynamic>;
    final remoteVer = (manifest['version'] as num).toInt();
    if (remoteVer <= localVer) {
      return UpdateResult(updated: false, message: '已是最新版本 (v$localVer)');
    }

    final files =
        (manifest['files'] as Map<String, dynamic>).cast<String, String>();
    final dir = await dataDir();

    for (final entry in files.entries) {
      if (!_dataFiles.contains(entry.key) && entry.key != 'version.json') {
        continue;
      }
      final r = await _client.get(Uri.parse(entry.value)).timeout(timeout);
      if (r.statusCode != 200) {
        return UpdateResult(updated: false, message: '下载 ${entry.key} 失败');
      }
      await File(p.join(dir.path, entry.key)).writeAsBytes(r.bodyBytes);
    }

    final versionPayload = {
      'version': remoteVer,
      'data_revision': manifest['data_revision'] ?? '',
      'manifest_url': url,
    };
    await File(p.join(dir.path, 'version.json'))
        .writeAsString(jsonEncode(versionPayload));

    return UpdateResult(
      updated: true,
      message: '更新成功：v$localVer → v$remoteVer，重启后生效',
      newVersion: remoteVer,
    );
  }

  /// 读取数据文件（优先 documents/data/，回退 assets/data/）。
  Future<String> readDataFile(String filename) async {
    final dir = await dataDir();
    final f = File(p.join(dir.path, filename));
    if (await f.exists()) return f.readAsString();
    return rootBundle.loadString('assets/data/$filename');
  }
}

class UpdateResult {
  UpdateResult({required this.updated, required this.message, this.newVersion});
  final bool updated;
  final String message;
  final int? newVersion;
}
