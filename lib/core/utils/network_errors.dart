import 'dart:async';
import 'dart:io';

/// True when [e] (or a nested cause) indicates no connectivity / DNS failure.
bool isNetworkError(Object e) {
  final seen = <Object>{};
  Object? current = e;
  while (current != null && seen.add(current)) {
    if (_isDirectNetworkError(current)) return true;
    current = _nestedCause(current);
  }
  return false;
}

bool _isDirectNetworkError(Object e) {
  if (e is SocketException) return true;
  if (e is IOException) return true;
  if (e is TimeoutException) return true;
  final type = e.runtimeType.toString();
  if (type.contains('ClientException') ||
      type.contains('HandshakeException') ||
      type.contains('TlsException')) {
    return true;
  }
  final msg = e.toString().toLowerCase();
  return msg.contains('socketexception') ||
      msg.contains('clientexception') ||
      msg.contains('connection abort') ||
      msg.contains('connection refused') ||
      msg.contains('connection reset') ||
      msg.contains('network is unreachable') ||
      msg.contains('failed host lookup') ||
      msg.contains('no address associated with hostname') ||
      msg.contains('timed out');
}

Object? _nestedCause(Object e) {
  try {
    final dynamic d = e;
    final inner = d.exception ?? d.error ?? d.cause;
    if (inner is Object && inner != e) return inner;
  } catch (_) {}
  return null;
}
