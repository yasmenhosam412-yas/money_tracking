import 'package:flutter_test/flutter_test.dart';
import 'package:imrpo/core/models/parsed_financial_entry.dart';
import 'package:imrpo/core/services/transaction_text_parser.dart';

void main() {
  group('parseSms', () {
    test('Vodafone income', () {
      const body =
          'تم استلام مبلغ 6000 جنيه من رقم 01094490330 المسجل بإسم Mohamed S Amer على رقم محفظتك 01024193022.\n'
          'رصيدك الحالي: 6004.88 جنيه\n'
          'تابع كل مصروفاتك من تاريخ المعاملات على أبلكيشن أنا فودافون http://vf.eg/vfcash';
      final r = TransactionTextParser.parseSms(body);
      expect(r, isNotNull);
      expect(r!.type, FinancialEntryType.income);
      expect(r.amount, 6000);
      expect(r.title, 'Mohamed S Amer');
    });

    test('Vodafone income variants — إستلام, transfer, English', () {
      const hamza =
          'تم إستلام مبلغ 500 جنيه من رقم 01012345678 المسجل باسم Ahmed على رقم محفظتك 01099999999.';
      final rHamza = TransactionTextParser.parseSms(hamza);
      expect(rHamza, isNotNull);
      expect(rHamza!.type, FinancialEntryType.income);
      expect(rHamza.amount, 500);
      expect(rHamza.title, 'Ahmed');

      const transfer =
          'تم تحويل مبلغ 1500 جنيه لمحفظتك من رقم 01011111111 المسجل بإسم Sara على رقم 01022222222';
      final rTransfer = TransactionTextParser.parseSms(transfer);
      expect(rTransfer!.type, FinancialEntryType.income);
      expect(rTransfer.amount, 1500);
      expect(rTransfer.title, 'Sara');

      const english =
          'You have received EGP 100.00 in your Vodafone Cash wallet from 01012345678';
      final rEn = TransactionTextParser.parseSms(english);
      expect(rEn!.type, FinancialEntryType.income);
      expect(rEn.amount, 100);
      expect(rEn.title, 'Vodafone Cash');

      const remittance = 'حوالة واردة بمبلغ 800 جنيه على محفظتك';
      final rRemit = TransactionTextParser.parseSms(remittance);
      expect(rRemit!.amount, 800);
    });

    test('Vodafone income without على رقم محفظتك', () {
      const body =
          'تم استلام مبلغ 8000 جنيه من رقم 01094490330 المسجل بإسم Mohamed S Amer رصيدك الحالي 8071.88 '
          'تاريخ العملية 00:25 26-04-05 رقم العملية 018912508702.\n'
          'تابع كل مصروفاتك من تاريخ المعاملات على أبلكيشن أنا فودافون http://vf.eg/vfcash';
      final smsDate = DateTime(2026, 4, 5, 1, 0);
      final r = TransactionTextParser.parseSms(body, smsReceivedAt: smsDate);
      expect(r, isNotNull);
      expect(r!.type, FinancialEntryType.income);
      expect(r.amount, 8000);
      expect(r.title, 'Mohamed S Amer');
      expect(r.date!.year, 2026);
      expect(r.date!.month, 4);
      expect(r.date!.day, 5);
      expect(r.date!.hour, 0);
      expect(r.date!.minute, 25);
    });

    test('Vodafone balance only — excluded', () {
      const body =
          'رصيد حسابك فى فودافون كاش الحالي6004.88 جنيه؛ تاريخ العملية 23:58 26-05-02';
      expect(TransactionTextParser.parseSms(body), isNull);
    });

    test('Card statement — excluded', () {
      const body =
          'Your card # XXXX2939 statement was issued today for a total amount of EGP 2006.19';
      expect(TransactionTextParser.parseSms(body), isNull);
    });

    test('Card bill payment — shown as income', () {
      const body =
          'Thank you for sending your payment. EGP 1000.00 has been credited to your card account # XXXX2939 for more information please call 19123.';
      final r = TransactionTextParser.parseSms(body);
      expect(r, isNotNull);
      expect(r!.type, FinancialEntryType.income);
      expect(r.amount, 1000);
      expect(r.title, 'Card payment');
    });

    test('Card purchase Talabat — expense', () {
      const body =
          'You have a Trx on your Card no. XXXX2939 from Talabat for EGP  204.16 on 19-May at 05:06  GMT+3 your available balance is 276.10 for more info please call 19123';
      final r = TransactionTextParser.parseSms(body);
      expect(r, isNotNull);
      expect(r!.type, FinancialEntryType.expense);
      expect(r.amount, 204.16);
      expect(r.title, 'Talabat');
    });

    test('Card purchase with date in text — title Talabat not Talabat 19', () {
      const body =
          'You have a Trx on your Card no. XXXX2939 from Talabat on 19-May at 05:06 for EGP 204.16 GMT+3 your available balance is 276.10';
      final r = TransactionTextParser.parseSms(body);
      expect(r, isNotNull);
      expect(r!.title, 'Talabat');
      expect(r.amount, 204.16);
    });

    test('Vodafone withdrawal تم سحب 5900 جنية — expense', () {
      const body =
          'تم سحب 5900.00 جنية من محفظة فودافون كاش. رصيد حسابك الحالي 45.88 جنيه. '
          'تاريخ العملية 11:44 26-05-04 رقم العملية; 019697621640. '
          'دلوقتي تقدر تسحب من محفظتك برسوم 5 جنيه بس بدل 1%! كلم *9*999# واشترك علشان';
      final smsDate = DateTime(2026, 5, 4, 12, 0);
      final r = TransactionTextParser.parseSms(body, smsReceivedAt: smsDate);
      expect(r, isNotNull);
      expect(r!.type, FinancialEntryType.expense);
      expect(r.amount, 5900);
      expect(r.title, 'Vodafone Cash');
      expect(r.date!.year, 2026);
      expect(r.date!.hour, 11);
      expect(r.date!.minute, 44);
    });

    test('Vodafone operation date 26-05-01 uses year near SMS date', () {
      const body =
          'تم استلام مبلغ 100 جنيه\nتاريخ العملية: 06:32 26-05-01';
      final smsDate = DateTime(2026, 5, 19, 10, 0);
      final r = TransactionTextParser.parseSms(body, smsReceivedAt: smsDate);
      expect(r, isNotNull);
      expect(r!.date!.year, 2026);
      expect(r.date!.month, 5);
      expect(r.date!.hour, 6);
      expect(r.date!.minute, 32);
    });

    test('Card purchase date matches on 19-May', () {
      const body =
          'You have a Trx on your Card from Talabat for EGP  204.16 on 19-May at 05:06 GMT+3';
      final smsDate = DateTime(2026, 5, 20);
      final r = TransactionTextParser.parseSms(body, smsReceivedAt: smsDate);
      expect(r!.date!.year, 2026);
      expect(r.date!.month, 5);
      expect(r.date!.day, 19);
      expect(r.date!.hour, 5);
      expect(r.date!.minute, 6);
    });

    test('Salary/bonus إضافة راتب/حافز — income', () {
      const bodyAr =
          'تم إضافة راتب/حافز بمبلغ 12500.00 جنيه على حسابكم. الرصيد المتاح 15000.00 جنيه';
      final rAr = TransactionTextParser.parseSms(bodyAr);
      expect(rAr, isNotNull);
      expect(rAr!.type, FinancialEntryType.income);
      expect(rAr.amount, 12500);
      expect(rAr.title, 'Salary / Bonus');

      const bodyEn =
          'EGP 8500.00 has been credited to your saving account. إضافة راتب/حافز. '
          'Available balance is EGP 12000.00';
      final rEn = TransactionTextParser.parseSms(bodyEn);
      expect(rEn, isNotNull);
      expect(rEn!.type, FinancialEntryType.income);
      expect(rEn.amount, 8500);
      expect(rEn.title, 'Salary / Bonus');
    });

    test('Bank deposit تم إيداع EGP 7900 إلى حساب — income not balance', () {
      const body =
          'تم إيداع EGP 7900 إلى حساب رقم #0014 يوم 06/04/2026 13:24 المتاح 220157.61 EGP للمزيد اتصل ب 19123';
      final r = TransactionTextParser.parseSms(
        body,
        smsReceivedAt: DateTime(2026, 4, 6, 14, 0),
        sender: '19123',
      );
      expect(r, isNotNull);
      expect(r!.type, FinancialEntryType.income);
      expect(r.amount, 7900);
      expect(r.title, 'Account #0014');
      expect(r.date!.year, 2026);
      expect(r.date!.month, 4);
      expect(r.date!.day, 6);
      expect(r.date!.hour, 13);
      expect(r.date!.minute, 24);
    });

    test('Vodafone income with VF-Cash sender', () {
      const body =
          'تم استلام مبلغ 8000 جنيه من رقم 01094490330 المسجل بإسم Mohamed S Amer رصيدك الحالي 8071.88';
      final r = TransactionTextParser.parseSms(
        body,
        sender: 'VF-Cash',
      );
      expect(r, isNotNull);
      expect(r!.type, FinancialEntryType.income);
      expect(r.amount, 8000);
      expect(r.title, 'Mohamed S Amer');
    });

    test('Instant outgoing transfer تم تحويل لحظى — expense', () {
      const bodyMultiline =
          'تم تحويل لحظى بمبلغ 200 إلى  رقم مرجعى B\n'
          'EC93BC فى 17/05/2026 04:54 للمزيد اتصل ب 19123';
      final rMulti = TransactionTextParser.parseSms(
        bodyMultiline,
        smsReceivedAt: DateTime(2026, 5, 17, 5, 0),
        sender: '19123',
      );
      expect(rMulti, isNotNull);
      expect(rMulti!.type, FinancialEntryType.expense);
      expect(rMulti.amount, 200);
      expect(rMulti.title, 'Ref B EC93BC');

      const body =
          'تم تحويل لحظى بمبلغ 200 إلى  رقم مرجعى BEC93BC في 17/05/2026 04:54 للمزيد اتصل ب 19123';
      final r = TransactionTextParser.parseSms(
        body,
        smsReceivedAt: DateTime(2026, 5, 17, 5, 0),
        sender: '19123',
      );
      expect(r, isNotNull);
      expect(r!.type, FinancialEntryType.expense);
      expect(r.amount, 200);
      expect(r.title, 'Ref BEC93BC');
      expect(r.date!.year, 2026);
      expect(r.date!.month, 5);
      expect(r.date!.day, 17);
      expect(r.date!.hour, 4);
      expect(r.date!.minute, 54);
    });

    test('Etisalat Cash income — same pipeline as Vodafone', () {
      const body =
          'تم استلام مبلغ 1200 جنيه من رقم 01112345678 المسجل باسم Ali Hassan على محفظة اتصالات كاش. '
          'رصيدك الحالي 3500 جنيه';
      final r = TransactionTextParser.parseSms(
        body,
        sender: 'Etisalat',
      );
      expect(r, isNotNull);
      expect(r!.type, FinancialEntryType.income);
      expect(r.amount, 1200);
      expect(r.title, 'Ali Hassan');

      const eAnd =
          'You have received EGP 75.00 in your e& money wallet from 01198765432';
      final rEn = TransactionTextParser.parseSms(eAnd, sender: 'e&');
      expect(rEn!.type, FinancialEntryType.income);
      expect(rEn.amount, 75);
      expect(rEn.title, 'Etisalat Cash');
    });

    test('CIB ATM withdrawal — expense', () {
      const bodyAr =
          'تم سحب مبلغ 1500 جنيه من الصراف الآلي لحسابكم. المتاح 12000 جنيه يوم 10/05/2026 14:30';
      final rAr = TransactionTextParser.parseSms(
        bodyAr,
        smsReceivedAt: DateTime(2026, 5, 10, 15, 0),
        sender: 'CIB',
      );
      expect(rAr, isNotNull);
      expect(rAr!.type, FinancialEntryType.expense);
      expect(rAr.amount, 1500);
      expect(rAr.title, 'ATM withdrawal');

      const bodyEn =
          'Cash withdrawal of EGP 500.00 from your account at ATM CIB Branch';
      final rEn = TransactionTextParser.parseSms(bodyEn, sender: 'CIB');
      expect(rEn!.type, FinancialEntryType.expense);
      expect(rEn.amount, 500);
    });

    test('Bill payment سداد فاتورة — expense', () {
      const body =
          'تم سداد فاتورة كهرباء بمبلغ 420 جنيه من حسابكم. الرصيد المتاح 8000 جنيه';
      final r = TransactionTextParser.parseSms(body, sender: 'CIB');
      expect(r, isNotNull);
      expect(r!.type, FinancialEntryType.expense);
      expect(r.amount, 420);
      expect(r.title, 'كهرباء');

      const bodyEn =
          'Bill payment of EGP 199.50 for internet was debited from your account';
      final rEn = TransactionTextParser.parseSms(bodyEn);
      expect(rEn!.type, FinancialEntryType.expense);
      expect(rEn.amount, 199.50);
    });

    test('Cash deposit — income', () {
      const body =
          'Cash deposit of EGP 3000.00 has been credited to your saving account. Available balance EGP 15000';
      final r = TransactionTextParser.parseSms(body, sender: 'CIB');
      expect(r, isNotNull);
      expect(r!.type, FinancialEntryType.income);
      expect(r.amount, 3000);

      const bodyAr =
          'تم ايداع نقدي بمبلغ 2500 جنيه على حسابكم رقم #4455 يوم 08/05/2026 09:15';
      final rAr = TransactionTextParser.parseSms(
        bodyAr,
        smsReceivedAt: DateTime(2026, 5, 8, 10, 0),
      );
      expect(rAr!.type, FinancialEntryType.income);
      expect(rAr.amount, 2500);
    });

    test('CIB card debit at merchant — expense', () {
      const body =
          'Your account was debited with EGP 850.00 at CARREFOUR on 12/05/2026 18:40';
      final r = TransactionTextParser.parseSms(body, sender: 'CIB');
      expect(r, isNotNull);
      expect(r!.type, FinancialEntryType.expense);
      expect(r.amount, 850);
      expect(r.title, 'CARREFOUR');
    });

    test('Hotline sender is not used as title', () {
      expect(TransactionTextParser.isPhoneOrHotline('19123'), isTrue);
      expect(TransactionTextParser.isPhoneOrHotline('01024193022'), isTrue);
      expect(TransactionTextParser.isPhoneOrHotline('Talabat'), isFalse);

      const body =
          'You have a Trx on your Card no. XXXX2939 from Talabat for EGP  50.00 on 19-May at 05:06';
      final title = TransactionTextParser.resolveSmsTitle(
        body: body,
        sender: '19123',
      );
      expect(title, 'Talabat');
    });
  });
}
