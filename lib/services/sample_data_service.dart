import 'package:cloud_firestore/cloud_firestore.dart';

class SampleDataService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Add sample room data with free images
  static Future<void> addSampleRooms() async {
    final sampleRooms = [
      {
        'name': 'Luxury Ocean View Suite',
        'description':
            'Experience breathtaking ocean views from this elegant suite featuring a king-size bed, private balcony, and modern amenities. Perfect for romantic getaways or special occasions.',
        'price': 5999.0,
        'location': 'Marine Drive',
        'city': 'Mumbai',
        'imageUrls': [
          'https://images.unsplash.com/photo-1582719478250-c89cae4dc85b?w=800&h=600&fit=crop',
          'https://images.unsplash.com/photo-1564013799919-ab600027ffc6?w=800&h=600&fit=crop',
          'https://images.unsplash.com/photo-1586611292717-f828b167408c?w=800&h=600&fit=crop',
        ],
        'amenities': [
          'Ocean View',
          'Private Balcony',
          'King Bed',
          'WiFi',
          'Room Service',
          'Mini Bar'
        ],
        'hasAC': true,
        'isAvailable': true,
        'maxGuests': 2,
        'contactNumber': '+91 9876543210',
        'createdAt': DateTime.now().millisecondsSinceEpoch,
      },
      {
        'name': 'Modern Business Suite',
        'description':
            'Ideal for business travelers with a dedicated workspace, high-speed internet, and conference call facilities. Located in the heart of the business district.',
        'price': 4500.0,
        'location': 'Bandra Kurla Complex',
        'city': 'Mumbai',
        'imageUrls': [
          'https://images.unsplash.com/photo-1560472354-b33ff0c44a43?w=800&h=600&fit=crop',
          'https://images.unsplash.com/photo-1578683010236-d716f9a3f461?w=800&h=600&fit=crop',
          'https://images.unsplash.com/photo-1631049307264-da0ec9d70304?w=800&h=600&fit=crop',
        ],
        'amenities': [
          'Work Desk',
          'Business Center',
          'WiFi',
          'Conference Call Setup',
          'Express Laundry'
        ],
        'hasAC': true,
        'isAvailable': true,
        'maxGuests': 2,
        'contactNumber': '+91 9876543211',
        'createdAt': DateTime.now().millisecondsSinceEpoch,
      },
      {
        'name': 'Cozy Family Room',
        'description':
            'Spacious family-friendly accommodation with separate sleeping areas, entertainment system, and easy access to family attractions.',
        'price': 3500.0,
        'location': 'Juhu Beach',
        'city': 'Mumbai',
        'imageUrls': [
          'https://images.unsplash.com/photo-1566665797739-1674de7a421a?w=800&h=600&fit=crop',
          'https://images.unsplash.com/photo-1595576508898-0ad5c879a061?w=800&h=600&fit=crop',
          'https://images.unsplash.com/photo-1584132967334-10e028bd69f7?w=800&h=600&fit=crop',
        ],
        'amenities': [
          'Family Room',
          'TV',
          'WiFi',
          'Kitchenette',
          'Beach Access',
          'Kids Play Area'
        ],
        'hasAC': true,
        'isAvailable': true,
        'maxGuests': 4,
        'contactNumber': '+91 9876543212',
        'createdAt': DateTime.now().millisecondsSinceEpoch,
      },
      {
        'name': 'Budget Traveler Room',
        'description':
            'Comfortable and affordable accommodation for budget-conscious travelers. Clean, safe, and conveniently located near public transport.',
        'price': 2000.0,
        'location': 'Andheri East',
        'city': 'Mumbai',
        'imageUrls': [
          'https://images.unsplash.com/photo-1586023492125-27b2c045efd7?w=800&h=600&fit=crop',
          'https://images.unsplash.com/photo-1595576508898-0ad5c879a061?w=800&h=600&fit=crop',
        ],
        'amenities': [
          'WiFi',
          'Shared Bathroom',
          'Lockers',
          'Common Area',
          'Metro Access'
        ],
        'hasAC': false,
        'isAvailable': true,
        'maxGuests': 2,
        'contactNumber': '+91 9876543213',
        'createdAt': DateTime.now().millisecondsSinceEpoch,
      },
      {
        'name': 'Premium Penthouse',
        'description':
            'Ultimate luxury penthouse with panoramic city views, private terrace, jacuzzi, and exclusive concierge service.',
        'price': 12000.0,
        'location': 'Worli',
        'city': 'Mumbai',
        'imageUrls': [
          'https://images.unsplash.com/photo-1590490360182-c33d57733427?w=800&h=600&fit=crop',
          'https://images.unsplash.com/photo-1582719478250-c89cae4dc85b?w=800&h=600&fit=crop',
          'https://images.unsplash.com/photo-1561501900-3701fa6a0864?w=800&h=600&fit=crop',
        ],
        'amenities': [
          'Penthouse',
          'City View',
          'Private Terrace',
          'Jacuzzi',
          'Concierge',
          'Valet Parking'
        ],
        'hasAC': true,
        'isAvailable': true,
        'maxGuests': 6,
        'contactNumber': '+91 9876543214',
        'createdAt': DateTime.now().millisecondsSinceEpoch,
      },
      // Delhi Rooms
      {
        'name': 'Heritage Palace Room',
        'description':
            'Stay in a restored heritage building with traditional architecture, modern amenities, and rich cultural ambiance.',
        'price': 4800.0,
        'location': 'Connaught Place',
        'city': 'Delhi',
        'imageUrls': [
          'https://images.unsplash.com/photo-1571896349842-33c89424de2d?w=800&h=600&fit=crop',
          'https://images.unsplash.com/photo-1578683010236-d716f9a3f461?w=800&h=600&fit=crop',
        ],
        'amenities': [
          'Heritage Architecture',
          'Cultural Tours',
          'WiFi',
          'Traditional Decor',
          'Room Service'
        ],
        'hasAC': true,
        'isAvailable': true,
        'maxGuests': 3,
        'contactNumber': '+91 9876543215',
        'createdAt': DateTime.now().millisecondsSinceEpoch,
      },
      {
        'name': 'Airport Transit Room',
        'description':
            'Convenient airport hotel for transit passengers with 24/7 shuttle service, comfortable beds, and quick check-in.',
        'price': 3200.0,
        'location': 'IGI Airport Area',
        'city': 'Delhi',
        'imageUrls': [
          'https://images.unsplash.com/photo-1564013799919-ab600027ffc6?w=800&h=600&fit=crop',
          'https://images.unsplash.com/photo-1586611292717-f828b167408c?w=800&h=600&fit=crop',
        ],
        'amenities': [
          'Airport Shuttle',
          '24/7 Check-in',
          'WiFi',
          'Luggage Storage',
          'Transit Lounge'
        ],
        'hasAC': true,
        'isAvailable': true,
        'maxGuests': 2,
        'contactNumber': '+91 9876543216',
        'createdAt': DateTime.now().millisecondsSinceEpoch,
      },
    ];

    // Add each room to Firestore
    for (var roomData in sampleRooms) {
      try {
        await _firestore.collection('rooms').add(roomData);
        print('Added room: ${roomData['name']}');
      } catch (e) {
        print('Error adding room ${roomData['name']}: $e');
      }
    }
  }

  // Check if sample data already exists
  static Future<bool> hasSampleData() async {
    final snapshot = await _firestore.collection('rooms').limit(1).get();
    return snapshot.docs.isNotEmpty;
  }

  // Initialize sample data if needed
  static Future<void> initializeSampleData() async {
    final hasData = await hasSampleData();
    if (!hasData) {
      await addSampleRooms();
      print('Sample room data added successfully!');
    } else {
      print('Sample data already exists');
    }
  }
}
