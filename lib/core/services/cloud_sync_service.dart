import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import '../models/learning_models.dart';
import '../repositories/storage_repository.dart';

enum CloudSyncStatus {
  idle,
  syncing,
  synced,
  error,
  offline,
}

class CloudSyncService extends ChangeNotifier {
  static final CloudSyncService instance = CloudSyncService._();
  CloudSyncService._();

  CloudSyncStatus _status = CloudSyncStatus.idle;
  CloudSyncStatus get status => _status;

  DateTime? _lastSyncTime;
  DateTime? get lastSyncTime => _lastSyncTime;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  String _endpointUrl = '';
  String get endpointUrl => _endpointUrl;

  bool _initialized = false;

  Future<void> ensureInitialized() async {
    if (_initialized) return;
    _initialized = true;
    _endpointUrl = (await StorageRepository.loadCloudEndpoint()) ?? '';
    _lastSyncTime = await StorageRepository.loadLastSyncTime();
    notifyListeners();
  }

  Future<void> setEndpointUrl(String url) async {
    _endpointUrl = url.trim();
    await StorageRepository.saveCloudEndpoint(_endpointUrl);
    notifyListeners();
  }

  HttpClient _createClient() {
    final client = HttpClient();
    client.connectionTimeout = const Duration(seconds: 10);
    // السماح بالشهادات المخصصة إذا لزم الأمر في بيئات التطوير
    client.badCertificateCallback = (cert, host, port) => true;
    return client;
  }

  /// رفع المناهج والدروس الحالية إلى الخادم السحابي
  Future<bool> pushCurricula(List<CurriculumDomain> curricula) async {
    if (_endpointUrl.isEmpty) {
      _status = CloudSyncStatus.idle;
      _errorMessage = 'Cloud endpoint URL is not configured.';
      notifyListeners();
      return false;
    }

    _status = CloudSyncStatus.syncing;
    _errorMessage = null;
    notifyListeners();

    HttpClient? client;
    try {
      client = _createClient();
      final uri = Uri.parse(_endpointUrl);
      
      final request = await client.openUrl('PUT', uri);
      request.headers.contentType = ContentType.json;
      
      final payload = jsonEncode(curricula.map((c) => c.toJson()).toList());
      request.write(payload);

      final response = await request.close().timeout(const Duration(seconds: 12));
      
      if (response.statusCode >= 200 && response.statusCode < 300) {
        _status = CloudSyncStatus.synced;
        _lastSyncTime = DateTime.now();
        await StorageRepository.saveLastSyncTime(_lastSyncTime!);
        notifyListeners();
        return true;
      } else {
        _status = CloudSyncStatus.error;
        _errorMessage = 'HTTP ${response.statusCode}';
        notifyListeners();
        return false;
      }
    } on SocketException catch (e) {
      _status = CloudSyncStatus.offline;
      _errorMessage = 'Network unavailable: ${e.message}';
      notifyListeners();
      return false;
    } on TimeoutException {
      _status = CloudSyncStatus.offline;
      _errorMessage = 'Connection timed out';
      notifyListeners();
      return false;
    } catch (e) {
      _status = CloudSyncStatus.error;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    } finally {
      client?.close(force: true);
    }
  }

  /// سحب المناهج والدروس المحدثة من الخادم السحابي
  Future<List<CurriculumDomain>?> pullCurricula() async {
    if (_endpointUrl.isEmpty) {
      return null;
    }

    _status = CloudSyncStatus.syncing;
    _errorMessage = null;
    notifyListeners();

    HttpClient? client;
    try {
      client = _createClient();
      final uri = Uri.parse(_endpointUrl);
      
      final request = await client.getUrl(uri);
      final response = await request.close().timeout(const Duration(seconds: 12));

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final body = await response.transform(utf8.decoder).join();
        if (body.trim().isEmpty) return null;

        final decoded = jsonDecode(body);
        List<dynamic> list;
        if (decoded is List) {
          list = decoded;
        } else if (decoded is Map && decoded.containsKey('curricula')) {
          list = decoded['curricula'] as List;
        } else {
          list = [decoded];
        }

        final result = list
            .map((item) => CurriculumDomain.fromJson(item as Map<String, dynamic>))
            .toList();

        _status = CloudSyncStatus.synced;
        _lastSyncTime = DateTime.now();
        await StorageRepository.saveLastSyncTime(_lastSyncTime!);
        notifyListeners();
        return result;
      } else {
        _status = CloudSyncStatus.error;
        _errorMessage = 'HTTP ${response.statusCode}';
        notifyListeners();
        return null;
      }
    } on SocketException catch (e) {
      _status = CloudSyncStatus.offline;
      _errorMessage = 'Network unavailable: ${e.message}';
      notifyListeners();
      return null;
    } on TimeoutException {
      _status = CloudSyncStatus.offline;
      _errorMessage = 'Connection timed out';
      notifyListeners();
      return null;
    } catch (e) {
      _status = CloudSyncStatus.error;
      _errorMessage = e.toString();
      notifyListeners();
      return null;
    } finally {
      client?.close(force: true);
    }
  }
}
