import 'dart:io';

import 'package:imrpo/core/helpers/supabase_auth_helper.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Uploads receipt images to Supabase Storage (`receipts` bucket).
class ReceiptStorageService {
  ReceiptStorageService({required SupabaseClient client}) : _client = client;

  final SupabaseClient _client;
  static const _bucket = 'receipts';

  Future<String> uploadReceipt(File file) async {
    final userId = SupabaseAuthHelper.requireUserId();
    final ext = _extension(file.path);
    final path = '$userId/${DateTime.now().millisecondsSinceEpoch}.$ext';
    await _client.storage.from(_bucket).upload(
          path,
          file,
          fileOptions: const FileOptions(upsert: false),
        );
    return _client.storage.from(_bucket).getPublicUrl(path);
  }

  Future<void> deleteByPublicUrl(String? publicUrl) async {
    if (publicUrl == null || publicUrl.trim().isEmpty) return;
    final path = _pathFromPublicUrl(publicUrl);
    if (path == null) return;
    try {
      await _client.storage.from(_bucket).remove([path]);
    } catch (_) {
      // Best-effort cleanup.
    }
  }

  String? _pathFromPublicUrl(String url) {
    final marker = '/storage/v1/object/public/$_bucket/';
    final index = url.indexOf(marker);
    if (index < 0) return null;
    return Uri.decodeComponent(url.substring(index + marker.length));
  }

  String _extension(String path) {
    final dot = path.lastIndexOf('.');
    if (dot < 0 || dot == path.length - 1) return 'jpg';
    final ext = path.substring(dot + 1).toLowerCase();
    if (ext == 'jpeg') return 'jpg';
    if (ext == 'png' || ext == 'webp' || ext == 'heic') return ext;
    return 'jpg';
  }
}
