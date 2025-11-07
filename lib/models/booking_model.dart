enum BookingStatus {
  pending,
  confirmed,
  cancelled,
  completed,
}

enum PaymentStatus {
  pending,
  paid,
  failed,
  refunded,
}

class BookingModel {
  final String id;
  final String userId;
  final String roomId;
  final DateTime checkInDate;
  final DateTime checkOutDate;
  final int numberOfGuests;
  final double totalAmount;
  final BookingStatus status;
  final PaymentStatus paymentStatus;
  final String? paymentId;
  final String? razorpayOrderId;
  final String? razorpayPaymentId;
  final String? razorpaySignature;
  final DateTime createdAt;
  final DateTime? updatedAt;

  // Additional room details for display
  final String? roomName;
  final String? roomLocation;
  final String? roomImageUrl;

  BookingModel({
    required this.id,
    required this.userId,
    required this.roomId,
    required this.checkInDate,
    required this.checkOutDate,
    required this.numberOfGuests,
    required this.totalAmount,
    required this.status,
    required this.paymentStatus,
    this.paymentId,
    this.razorpayOrderId,
    this.razorpayPaymentId,
    this.razorpaySignature,
    required this.createdAt,
    this.updatedAt,
    this.roomName,
    this.roomLocation,
    this.roomImageUrl,
  });

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    return BookingModel(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      roomId: json['roomId'] ?? '',
      checkInDate:
          DateTime.fromMillisecondsSinceEpoch(json['checkInDate'] ?? 0),
      checkOutDate:
          DateTime.fromMillisecondsSinceEpoch(json['checkOutDate'] ?? 0),
      numberOfGuests: json['numberOfGuests'] ?? 1,
      totalAmount: (json['totalAmount'] ?? 0.0).toDouble(),
      status: BookingStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => BookingStatus.pending,
      ),
      paymentStatus: PaymentStatus.values.firstWhere(
        (e) => e.name == json['paymentStatus'],
        orElse: () => PaymentStatus.pending,
      ),
      paymentId: json['paymentId'],
      razorpayOrderId: json['razorpayOrderId'],
      razorpayPaymentId: json['razorpayPaymentId'],
      razorpaySignature: json['razorpaySignature'],
      createdAt: DateTime.fromMillisecondsSinceEpoch(json['createdAt'] ?? 0),
      updatedAt: json['updatedAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['updatedAt'])
          : null,
      roomName: json['roomName'],
      roomLocation: json['roomLocation'],
      roomImageUrl: json['roomImageUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'roomId': roomId,
      'checkInDate': checkInDate.millisecondsSinceEpoch,
      'checkOutDate': checkOutDate.millisecondsSinceEpoch,
      'numberOfGuests': numberOfGuests,
      'totalAmount': totalAmount,
      'status': status.name,
      'paymentStatus': paymentStatus.name,
      'paymentId': paymentId,
      'razorpayOrderId': razorpayOrderId,
      'razorpayPaymentId': razorpayPaymentId,
      'razorpaySignature': razorpaySignature,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt?.millisecondsSinceEpoch,
      'roomName': roomName,
      'roomLocation': roomLocation,
      'roomImageUrl': roomImageUrl,
    };
  }

  BookingModel copyWith({
    String? id,
    String? userId,
    String? roomId,
    DateTime? checkInDate,
    DateTime? checkOutDate,
    int? numberOfGuests,
    double? totalAmount,
    BookingStatus? status,
    PaymentStatus? paymentStatus,
    String? paymentId,
    String? razorpayOrderId,
    String? razorpayPaymentId,
    String? razorpaySignature,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? roomName,
    String? roomLocation,
    String? roomImageUrl,
  }) {
    return BookingModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      roomId: roomId ?? this.roomId,
      checkInDate: checkInDate ?? this.checkInDate,
      checkOutDate: checkOutDate ?? this.checkOutDate,
      numberOfGuests: numberOfGuests ?? this.numberOfGuests,
      totalAmount: totalAmount ?? this.totalAmount,
      status: status ?? this.status,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      paymentId: paymentId ?? this.paymentId,
      razorpayOrderId: razorpayOrderId ?? this.razorpayOrderId,
      razorpayPaymentId: razorpayPaymentId ?? this.razorpayPaymentId,
      razorpaySignature: razorpaySignature ?? this.razorpaySignature,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      roomName: roomName ?? this.roomName,
      roomLocation: roomLocation ?? this.roomLocation,
      roomImageUrl: roomImageUrl ?? this.roomImageUrl,
    );
  }

  // Computed properties
  int get numberOfNights => checkOutDate.difference(checkInDate).inDays;

  String get formattedTotalAmount => '₹${totalAmount.toStringAsFixed(0)}';

  String get statusDisplayName {
    switch (status) {
      case BookingStatus.pending:
        return 'Pending';
      case BookingStatus.confirmed:
        return 'Confirmed';
      case BookingStatus.cancelled:
        return 'Cancelled';
      case BookingStatus.completed:
        return 'Completed';
    }
  }

  String get paymentStatusDisplayName {
    switch (paymentStatus) {
      case PaymentStatus.pending:
        return 'Payment Pending';
      case PaymentStatus.paid:
        return 'Paid';
      case PaymentStatus.failed:
        return 'Payment Failed';
      case PaymentStatus.refunded:
        return 'Refunded';
    }
  }

  bool get canBeCancelled {
    return status == BookingStatus.pending || status == BookingStatus.confirmed;
  }

  bool get isPaid {
    return paymentStatus == PaymentStatus.paid;
  }
}
