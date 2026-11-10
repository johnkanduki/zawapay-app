import '../send/recipient.dart';

/// What a Zawapay payment QR code carries: who to pay, and optionally the
/// amount asked for.
class PayRequest {
  const PayRequest({required this.username, this.amount, this.currency});

  final String username;
  final double? amount;
  final String? currency;
}

/// Zawapay payment QR code: `zawapay://pay/<username>`, with
/// `?amount=10&currency=USD` when an amount is asked for.
///
/// The username part never changes: it is the user's fixed "@". The QR code
/// never carries money, only who to pay and how much.
abstract final class PayQr {
  static const String _prefix = 'zawapay://pay/';

  /// Text to put in the QR code of an account.
  static String forUsername(
    String username, {
    double? amount,
    String? currency,
  }) {
    if (amount == null || amount <= 0 || currency == null) {
      return '$_prefix$username';
    }
    final text = amount == amount.roundToDouble()
        ? amount.toStringAsFixed(0)
        : amount.toStringAsFixed(2);
    return '$_prefix$username?amount=$text&currency=$currency';
  }

  /// The request in a scanned code, or null if it is not a Zawapay code.
  static PayRequest? parse(String? raw) {
    final text = raw?.trim();
    if (text == null || !text.toLowerCase().startsWith(_prefix)) return null;
    final rest = text.substring(_prefix.length);
    final cut = rest.indexOf('?');
    final username = (cut < 0 ? rest : rest.substring(0, cut))
        .replaceFirst('@', '')
        .toLowerCase();
    if (!RegExp(r'^[a-z0-9._]{1,30}$').hasMatch(username)) return null;
    final query = cut < 0
        ? const <String, String>{}
        : Uri.splitQueryString(rest.substring(cut + 1));
    final amount = double.tryParse(query['amount'] ?? '');
    final currency = query['currency']?.toUpperCase();
    return PayRequest(
      username: username,
      amount: amount != null && amount > 0 ? amount : null,
      currency: currency,
    );
  }

  /// The username in a scanned code, or null if it is not a Zawapay code.
  static String? usernameOf(String? raw) => parse(raw)?.username;

  /// The account behind a scanned code, or null when unknown.
  static Recipient? recipientOf(String? raw) {
    final username = usernameOf(raw);
    return username == null ? null : findByUsername(username);
  }
}
