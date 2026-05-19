import 'package:imrpo/core/l10n/l10n_error_tokens.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Throws when a delete affects zero rows (RLS miss, wrong id, etc.).
void ensureDeleteSucceeded(List<dynamic> deletedRows) {
  if (deletedRows.isEmpty) {
    throw PostgrestException(
      message: l10nDeleteNotFoundToken,
      code: 'PGRST116',
    );
  }
}
