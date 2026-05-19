import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_sms_inbox/flutter_sms_inbox.dart';
import 'package:imrpo/core/models/parsed_financial_entry.dart';
import 'package:imrpo/core/services/currency_preferences.dart';
import 'package:imrpo/core/services/service_locator.dart';
import 'package:imrpo/core/services/transaction_text_parser.dart';
import 'package:permission_handler/permission_handler.dart';

class SmsMessageItem {
  final String id;
  final String sender;
  final String body;
  final DateTime date;
  final ParsedFinancialEntry parsed;

  const SmsMessageItem({
    required this.id,
    required this.sender,
    required this.body,
    required this.date,
    required this.parsed,
  });

  /// Sender / bank short code shown in lists and form title (not message body).
  String get header => sender.trim();

  /// Merchant, person, or bank name — never a hotline like 19123.
  String displayTitle(String fallbackLabel) {
    return TransactionTextParser.resolveSmsTitle(
          parsedTitle: parsed.title,
          body: body,
          sender: header,
        ) ??
        fallbackLabel;
  }

  /// Bank sender line (hidden when it is only a hotline number).
  String? get displaySubtitle {
    final title = TransactionTextParser.resolveSmsTitle(
      parsedTitle: parsed.title,
      body: body,
      sender: header,
    );
    if (title == null || header.isEmpty) return null;
    if (TransactionTextParser.isPhoneOrHotline(header)) return null;
    if (header == title) return null;
    return header;
  }
}

class SmsPageResult {
  final List<SmsMessageItem> items;
  final int nextRawStart;
  final bool hasMore;
  final int rawScanned;

  const SmsPageResult({
    required this.items,
    required this.nextRawStart,
    required this.hasMore,
    this.rawScanned = 0,
  });
}

class SmsImportService {
  /// Financial messages returned per UI page (after scanning raw inbox).
  static const defaultPageSize = 50;

  /// Raw inbox rows fetched per query call.
  static const _rawBatchSize = 150;

  /// Cap raw rows scanned per load call (avoids ANR on huge inboxes).
  static const _maxRawScanPerCall = 2500;

  /// On first refresh, scan deeper so older Vodafone/bank SMS appear.
  static const _initialMaxRawScan = 2500;

  bool get isSupported => !kIsWeb && Platform.isAndroid;

  Future<bool> requestPermission() async {
    if (!isSupported) return false;
    final status = await Permission.sms.request();
    return status.isGranted;
  }

  Future<bool> hasPermission() async {
    if (!isSupported) return false;
    return Permission.sms.isGranted;
  }

  /// Loads the next page of parsed financial SMS (scans many raw messages per call).
  Future<SmsPageResult> loadFinancialMessagesPage({
    int rawStart = 0,
    int pageSize = defaultPageSize,
    int? maxRawScan,
  }) async {
    if (!isSupported) {
      return const SmsPageResult(items: [], nextRawStart: 0, hasMore: false);
    }

    final granted = await hasPermission() || await requestPermission();
    if (!granted) {
      return const SmsPageResult(items: [], nextRawStart: 0, hasMore: false);
    }

    final scanLimit = maxRawScan ?? _maxRawScanPerCall;
    final query = SmsQuery();
    final items = <SmsMessageItem>[];
    final seenIds = <String>{};
    var offset = rawStart;
    var hasMoreRaw = true;
    var rawScanned = 0;

    while (items.length < pageSize && hasMoreRaw && rawScanned < scanLimit) {
      final batch = await query.querySms(
        kinds: [SmsQueryKind.inbox],
        start: offset,
        count: _rawBatchSize,
      );

      if (batch.isEmpty) {
        hasMoreRaw = false;
        break;
      }

      offset += batch.length;
      rawScanned += batch.length;
      if (batch.length < _rawBatchSize) {
        hasMoreRaw = false;
      }

      for (var i = 0; i < batch.length; i++) {
        final msg = batch[i];
        final item = _mapMessage(msg, items.length + i);
        if (item == null) continue;
        if (!seenIds.add(item.id)) continue;
        items.add(item);
        if (items.length >= pageSize) break;
      }
    }

    return SmsPageResult(
      items: items,
      nextRawStart: offset,
      hasMore: hasMoreRaw,
      rawScanned: rawScanned,
    );
  }

  /// First load: gather more financial messages by scanning further back in inbox.
  Future<SmsPageResult> loadInitialFinancialMessages({
    int targetCount = 80,
  }) async {
    return loadFinancialMessagesPage(
      rawStart: 0,
      pageSize: targetCount,
      maxRawScan: _initialMaxRawScan,
    );
  }

  SmsMessageItem? _mapMessage(SmsMessage msg, int fallbackIndex) {
    final body = msg.body ?? '';
    if (body.trim().isEmpty) return null;

    final header = (msg.address ?? '').trim();
    final smsDate = msg.date ?? DateTime.now();
    final parsed = TransactionTextParser.parseSms(
      body,
      defaultCurrencyCode: getIt<CurrencyPreferences>().displayCode,
      smsReceivedAt: smsDate,
      sender: header.isEmpty ? null : header,
    );
    if (parsed == null) return null;

    final transactionDate = parsed.date ?? smsDate;
    final enriched = parsed.copyWith(
      date: transactionDate,
      title: TransactionTextParser.resolveSmsTitle(
        parsedTitle: parsed.title,
        body: body,
        sender: header,
      ),
    );

    return SmsMessageItem(
      id: _messageId(msg, fallbackIndex),
      sender: header,
      body: body,
      date: transactionDate,
      parsed: enriched,
    );
  }

  static String _messageId(SmsMessage msg, int fallbackIndex) {
    if (msg.id != null) return msg.id.toString();
    final body = msg.body ?? '';
    final address = msg.address ?? '';
    final date = msg.date?.millisecondsSinceEpoch ?? fallbackIndex;
    return '${address}_${date}_${body.hashCode}';
  }
}
