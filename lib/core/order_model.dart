class OrderModel {
  final String? id;
  final int? amount;
  final int? amountReceived;
  final String? currency;
  final String? paymentMethod;
  final String? customerId;
  final String? paymentStatus;
  final String? latestCharge;

  OrderModel({
    required this.id,
    required this.amount,
    required this.amountReceived,
    required this.currency,
    required this.paymentMethod,
    required this.customerId,
    required this.paymentStatus,
    required this.latestCharge,
  });

  // Convert JSON to OrderModel object
  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json["id"],
      amount: json["amount"],
      amountReceived: json["amount_received"],
      currency: json["currency"],
      paymentMethod: json["payment_method"],
      customerId: json["customer"],
      paymentStatus: json["status"] ?? "unknown",
      latestCharge: json["latest_charge"] ?? "",
    );
  }

  // Convert OrderModel object to JSON
  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "amount": amount,
      "amount_received": amountReceived,
      "currency": currency,
      "payment_method": paymentMethod,
      "customer": customerId,
      "status": paymentStatus,
      "latest_charge": latestCharge,
    };
  }
}
