import 'package:flutter_test/flutter_test.dart';
import 'package:zawapay_app/features/history/my_transfers.dart';
import 'package:zawapay_app/features/history/transfer.dart';

void main() {
  test('Every status stays in the history: success, pending and failed', () {
    expect(statusOf('confirmed'), TransferStatus.success);
    for (final s in [
      'created',
      'collecting',
      'collected',
      'paying_out',
      'paid_out',
      'payout_failed',
    ]) {
      expect(statusOf(s), TransferStatus.pending, reason: s);
    }
    expect(statusOf('collect_failed'), TransferStatus.failed);
    expect(statusOf('refunded'), TransferStatus.failed);
  });

  test(
    'A transfer from the server: sent by @, by number, abroad, received',
    () {
      final byHandle = transferFromServer({
        'id': '1',
        'reference': 'ZP-1',
        'status': 'collect_failed',
        'currency': 'USD',
        'received': '1.00',
        'fee': '0.07',
        'paid': '1.07',
        'outgoing': true,
        'sender': 'johnkanduki',
        'recipient': 'johnkanduki2',
        'recipientName': 'John Deux',
        'receivePhone': '+243975135801',
        'createdAt': '2026-11-11T16:07:32Z',
        'updatedAt': '2026-11-11T16:40:00Z',
      });
      expect(byHandle.status, TransferStatus.failed);
      expect(byHandle.other.handle, '@johnkanduki2');
      expect(byHandle.failedAt, isNotNull);
      expect(byHandle.paid, 1.07);

      final abroad = transferFromServer({
        'id': '2',
        'status': 'collecting',
        'currency': 'USD',
        'received': '99.93',
        'fee': '3.38',
        'paid': '103.31',
        'outgoing': true,
        'sender': 'johnkanduki',
        'recipient': null,
        'receivePhone': '+256771234567',
        'destCountry': 'UG',
        'destCurrency': 'UGX',
        'destAmount': '400000',
        'createdAt': '2026-11-12T10:00:00Z',
      });
      expect(abroad.status, TransferStatus.pending);
      expect(abroad.other.isNumber, isTrue);
      expect(abroad.other.countryCode, 'UG');
      expect(abroad.received, 400000);
      expect(abroad.currency, 'UGX');
      expect(abroad.paid, 103.31);
      expect(abroad.paidCurrency, 'USD');

      final received = transferFromServer({
        'id': '3',
        'status': 'confirmed',
        'currency': 'USD',
        'received': '10.00',
        'fee': '0.70',
        'paid': '10.70',
        'outgoing': false,
        'sender': 'amina',
        'senderName': 'Amina Diallo',
        'receivePhone': '+243975135801',
        'createdAt': '2026-11-12T10:00:00Z',
      });
      expect(received.outgoing, isFalse);
      expect(received.other.handle, '@amina');
      expect(received.signedAmount('fr'), '+10 \$');
    },
  );
}
