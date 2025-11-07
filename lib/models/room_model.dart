class RoomModel {
  final String id;
  final String name;
  final String description;
  final double price;
  final String location;
  final String city;
  final List<String> imageUrls;
  final List<String> amenities;
  final bool hasAC;
  final bool isAvailable;
  final int maxGuests;
  final String contactNumber;
  final DateTime createdAt;
  final DateTime? updatedAt;

  RoomModel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.location,
    required this.city,
    required this.imageUrls,
    required this.amenities,
    required this.hasAC,
    required this.isAvailable,
    required this.maxGuests,
    required this.contactNumber,
    required this.createdAt,
    this.updatedAt,
  });

  factory RoomModel.fromJson(Map<String, dynamic> json) {
    return RoomModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      price: (json['price'] ?? 0.0).toDouble(),
      location: json['location'] ?? '',
      city: json['city'] ?? '',
      imageUrls: List<String>.from(json['imageUrls'] ?? []),
      amenities: List<String>.from(json['amenities'] ?? []),
      hasAC: json['hasAC'] ?? false,
      isAvailable: json['isAvailable'] ?? true,
      maxGuests: json['maxGuests'] ?? 2,
      contactNumber: json['contactNumber'] ?? '',
      createdAt: DateTime.fromMillisecondsSinceEpoch(json['createdAt'] ?? 0),
      updatedAt: json['updatedAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['updatedAt'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'location': location,
      'city': city,
      'imageUrls': imageUrls,
      'amenities': amenities,
      'hasAC': hasAC,
      'isAvailable': isAvailable,
      'maxGuests': maxGuests,
      'contactNumber': contactNumber,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt?.millisecondsSinceEpoch,
    };
  }

  RoomModel copyWith({
    String? id,
    String? name,
    String? description,
    double? price,
    String? location,
    String? city,
    List<String>? imageUrls,
    List<String>? amenities,
    bool? hasAC,
    bool? isAvailable,
    int? maxGuests,
    String? contactNumber,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return RoomModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      location: location ?? this.location,
      city: city ?? this.city,
      imageUrls: imageUrls ?? this.imageUrls,
      amenities: amenities ?? this.amenities,
      hasAC: hasAC ?? this.hasAC,
      isAvailable: isAvailable ?? this.isAvailable,
      maxGuests: maxGuests ?? this.maxGuests,
      contactNumber: contactNumber ?? this.contactNumber,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  String get formattedPrice => '₹${price.toStringAsFixed(0)}/night';

  double get pricePerNight => price;

  String get primaryImageUrl => imageUrls.isNotEmpty ? imageUrls.first : '';

  bool get hasImages => imageUrls.isNotEmpty;
}
