/// Heuristic: whether [raw] (often [Object.toString] or an API message)
/// indicates the client could not reach the network or remote host.
///
/// Used by [ErrorHelper] and [localizeApiError] so offline errors stay
/// user-friendly even when the SDK wraps the root cause.
bool messageIndicatesNoInternet(String? raw) {
  if (raw == null || raw.isEmpty) return false;
  final m = raw.toLowerCase();

  const fragments = [
    'socketexception',
    'clientexception',
    'failed host lookup',
    'failed to fetch',
    'network is unreachable',
    'no address associated with hostname',
    'no route to host',
    'nodename nor servname provided, or not known',
    'connection timed out',
    'timed out',
    'handshakeexception',
    'tlsexception',
    'connection reset by peer',
    'software caused connection abort',
    'network request failed',
    'err_internet_disconnected',
    'host lookup failed',
    'temporary failure in name resolution',
    'dns_probe_finished',
    'connection closed before full header was received',
    'connection closed while receiving',
  ];
  for (final f in fragments) {
    if (m.contains(f)) return true;
  }
  return false;
}
