import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/room_model.dart';

class RoomService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _collection = 'rooms';

  // Get all rooms
  static Stream<List<RoomModel>> getAllRooms() {
    return _firestore
        .collection(_collection)
        .where('isAvailable', isEqualTo: true)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => RoomModel.fromJson({...doc.data(), 'id': doc.id}))
          .toList();
    });
  }

  // Get rooms by city
  static Stream<List<RoomModel>> getRoomsByCity(String city) {
    return _firestore
        .collection(_collection)
        .where('city', isEqualTo: city)
        .where('isAvailable', isEqualTo: true)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => RoomModel.fromJson({...doc.data(), 'id': doc.id}))
          .toList();
    });
  }

  // Search rooms by name or location
  static Future<List<RoomModel>> searchRooms(String query) async {
    try {
      final lowercaseQuery = query.toLowerCase();

      // Search by name
      QuerySnapshot nameSnapshot = await _firestore
          .collection(_collection)
          .where('isAvailable', isEqualTo: true)
          .get();

      // Search by city
      QuerySnapshot citySnapshot = await _firestore
          .collection(_collection)
          .where('city', isGreaterThanOrEqualTo: lowercaseQuery)
          .where('city', isLessThanOrEqualTo: '$lowercaseQuery\uf8ff')
          .where('isAvailable', isEqualTo: true)
          .get();

      Set<String> processedIds = <String>{};
      List<RoomModel> rooms = [];

      // Process name results
      for (var doc in nameSnapshot.docs) {
        final room = RoomModel.fromJson(
            {...doc.data() as Map<String, dynamic>, 'id': doc.id});
        if (room.name.toLowerCase().contains(lowercaseQuery)) {
          rooms.add(room);
          processedIds.add(doc.id);
        }
      }

      // Process city results
      for (var doc in citySnapshot.docs) {
        if (!processedIds.contains(doc.id)) {
          final room = RoomModel.fromJson(
              {...doc.data() as Map<String, dynamic>, 'id': doc.id});
          rooms.add(room);
        }
      }

      return rooms;
    } catch (e) {
      throw 'Error searching rooms: $e';
    }
  }

  // Filter rooms
  static Future<List<RoomModel>> filterRooms({
    bool? hasAC,
    double? minPrice,
    double? maxPrice,
    String? city,
  }) async {
    try {
      Query query = _firestore
          .collection(_collection)
          .where('isAvailable', isEqualTo: true);

      if (hasAC != null) {
        query = query.where('hasAC', isEqualTo: hasAC);
      }

      if (city != null && city.isNotEmpty) {
        query = query.where('city', isEqualTo: city);
      }

      QuerySnapshot snapshot = await query.get();
      List<RoomModel> rooms = snapshot.docs
          .map((doc) => RoomModel.fromJson(
              {...doc.data() as Map<String, dynamic>, 'id': doc.id}))
          .toList();

      // Filter by price range (client-side filtering)
      if (minPrice != null || maxPrice != null) {
        rooms = rooms.where((room) {
          if (minPrice != null && room.price < minPrice) return false;
          if (maxPrice != null && room.price > maxPrice) return false;
          return true;
        }).toList();
      }

      return rooms;
    } catch (e) {
      throw 'Error filtering rooms: $e';
    }
  }

  // Get room by ID
  static Future<RoomModel?> getRoomById(String roomId) async {
    try {
      DocumentSnapshot doc =
          await _firestore.collection(_collection).doc(roomId).get();
      if (doc.exists) {
        return RoomModel.fromJson(
            {...doc.data() as Map<String, dynamic>, 'id': doc.id});
      }
      return null;
    } catch (e) {
      throw 'Error fetching room: $e';
    }
  }

  // Add new room (Admin function)
  static Future<String> addRoom(RoomModel room) async {
    try {
      DocumentReference docRef =
          await _firestore.collection(_collection).add(room.toJson());
      return docRef.id;
    } catch (e) {
      throw 'Error adding room: $e';
    }
  }

  // Update room (Admin function)
  static Future<void> updateRoom(RoomModel room) async {
    try {
      await _firestore.collection(_collection).doc(room.id).update(
            room.copyWith(updatedAt: DateTime.now()).toJson(),
          );
    } catch (e) {
      throw 'Error updating room: $e';
    }
  }

  // Delete room (Admin function)
  static Future<void> deleteRoom(String roomId) async {
    try {
      await _firestore.collection(_collection).doc(roomId).delete();
    } catch (e) {
      throw 'Error deleting room: $e';
    }
  }

  // Check room availability for specific dates
  static Future<bool> isRoomAvailable(
      String roomId, DateTime checkIn, DateTime checkOut) async {
    try {
      // Check if room exists and is available
      RoomModel? room = await getRoomById(roomId);
      if (room == null || !room.isAvailable) return false;

      // Check for existing bookings that conflict with the requested dates
      QuerySnapshot existingBookings = await _firestore
          .collection('bookings')
          .where('roomId', isEqualTo: roomId)
          .where('status', whereIn: ['pending', 'confirmed']).get();

      for (var booking in existingBookings.docs) {
        final data = booking.data() as Map<String, dynamic>;
        final existingCheckIn =
            DateTime.fromMillisecondsSinceEpoch(data['checkInDate']);
        final existingCheckOut =
            DateTime.fromMillisecondsSinceEpoch(data['checkOutDate']);

        // Check if dates overlap
        if (checkIn.isBefore(existingCheckOut) &&
            checkOut.isAfter(existingCheckIn)) {
          return false;
        }
      }

      return true;
    } catch (e) {
      throw 'Error checking room availability: $e';
    }
  }

  // Get popular cities
  static Future<List<String>> getPopularCities() async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection(_collection)
          .where('isAvailable', isEqualTo: true)
          .get();

      Set<String> cities = {};
      for (var doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        if (data['city'] != null) {
          cities.add(data['city'] as String);
        }
      }

      return cities.toList()..sort();
    } catch (e) {
      throw 'Error fetching cities: $e';
    }
  }

  // Get room statistics (Admin function)
  static Future<Map<String, dynamic>> getRoomStatistics() async {
    try {
      QuerySnapshot allRooms = await _firestore.collection(_collection).get();
      QuerySnapshot availableRooms = await _firestore
          .collection(_collection)
          .where('isAvailable', isEqualTo: true)
          .get();

      return {
        'totalRooms': allRooms.size,
        'availableRooms': availableRooms.size,
        'unavailableRooms': allRooms.size - availableRooms.size,
      };
    } catch (e) {
      throw 'Error fetching room statistics: $e';
    }
  }
}
