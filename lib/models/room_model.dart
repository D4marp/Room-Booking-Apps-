class RoomModel {
  final String id;
  final String name;
  final String description;
  final String location;
  final int capacity;
  final List<String>? amenities;
  final bool? availability;
  final String? imageUrl;
  final DateTime? createdAt;

  RoomModel({
    required this.id,
    required this.name,
    required this.description,
    required this.location,
    required this.capacity,
    this.amenities,
    this.availability,
    this.imageUrl,
    this.createdAt,
  });

  factory RoomModel.fromJson(Map<String, dynamic> json) {
    return RoomModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      location: json['location'] ?? '',
      capacity: json['capacity'] ?? 0,
      amenities: json['amenities'] != null 
          ? List<String>.from(json['amenities'] as List)
          : null,
      availability: json['availability'] ?? true,
      imageUrl: json['imageUrl'],
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'location': location,
      'capacity': capacity,
      'amenities': amenities,
      'availability': availability,
      'imageUrl': imageUrl,
      'createdAt': createdAt?.toIso8601String(),
    };
  }

  RoomModel copyWith({
    String? id,
    String? name,
    String? description,
    String? location,
    int? capacity,
    List<String>? amenities,
    bool? availability,
    String? imageUrl,
    DateTime? createdAt,
  }) {
    return RoomModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      location: location ?? this.location,
      capacity: capacity ?? this.capacity,
      amenities: amenities ?? this.amenities,
      availability: availability ?? this.availability,
      imageUrl: imageUrl ?? this.imageUrl,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
