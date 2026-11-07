class CardPaymentResult {
  /// success / failed / pending / error / cancelled
  final String status;
  final String? responseCode;
  final String? responseMessage;
  final String? referenceNumber; // -> sent as transaction_id
  final String? rrn;
  final double? amount;
  final String? cardBrand;
  final String? cardNumber;
  final String? authCode;
  final String? mid;
  final String? tid;

  CardPaymentResult({
    required this.status,
    this.responseCode,
    this.responseMessage,
    this.referenceNumber,
    this.rrn,
    this.amount,
    this.cardBrand,
    this.cardNumber,
    this.authCode,
    this.mid,
    this.tid,
  });

  bool get isApproved => status == 'success';

  factory CardPaymentResult.fromMap(Map map) {
    String? s(String k) => map[k]?.toString();
    return CardPaymentResult(
      status: s('status') ?? 'error',
      responseCode: s('responseCode'),
      responseMessage: s('responseMessage'),
      referenceNumber: s('referenceNumber'),
      rrn: s('rrn'),
      amount: (map['amount'] as num?)?.toDouble(),
      cardBrand: s('cardBrand'),
      cardNumber: s('cardNumber'),
      authCode: s('authCode'),
      mid: s('mid'),
      tid: s('tid'),
    );
  }

  factory CardPaymentResult.error(String message) =>
      CardPaymentResult(status: 'error', responseMessage: message);
}