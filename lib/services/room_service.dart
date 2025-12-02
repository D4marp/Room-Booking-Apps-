import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/room_model.dart';

class RoomService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _collection = 'rooms';

  // Get all rooms
  static Stream<List<RoomModel>> getAllRooms() {
    return _firestore
        .collection(_collection)
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
    String? city,
    String? roomClass,
    int? minCapacity,
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

      if (roomClass != null && roomClass.isNotEmpty) {
        query = query.where('roomClass', isEqualTo: roomClass);
      }

      QuerySnapshot snapshot = await query.get();
      List<RoomModel> rooms = snapshot.docs
          .map((doc) => RoomModel.fromJson(
              {...doc.data() as Map<String, dynamic>, 'id': doc.id}))
          .toList();

      // Filter by capacity (client-side filtering)
      if (minCapacity != null) {
        rooms = rooms.where((room) {
          return room.maxGuests >= minCapacity;
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

  // Add new room (Admin function) - accepts Map
  static Future<String> addRoomFromMap(Map<String, dynamic> roomData) async {
    try {
      // Add timestamps
      roomData['createdAt'] = DateTime.now().millisecondsSinceEpoch;
      roomData['updatedAt'] = DateTime.now().millisecondsSinceEpoch;
      
      // Convert single imageUrl to imageUrls list if needed
      if (roomData.containsKey('imageUrl') && !roomData.containsKey('imageUrls')) {
        roomData['imageUrls'] = [roomData['imageUrl']];
        roomData.remove('imageUrl');
      }
      
      // Set default values if not provided
      roomData['amenities'] = roomData['amenities'] ?? [];
      roomData['hasAC'] = roomData['hasAC'] ?? true;
      roomData['location'] = roomData['location'] ?? roomData['city'] ?? '';
      roomData['contactNumber'] = roomData['contactNumber'] ?? '';
      roomData['maxGuests'] = roomData['maxGuests'] ?? roomData['capacity'] ?? 2;
      
      DocumentReference docRef = await _firestore.collection(_collection).add(roomData);
      return docRef.id;
    } catch (e) {
      throw 'Error adding room: $e';
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

  // Update room (Admin function) - accepts Map
  static Future<void> updateRoomFromMap(String roomId, Map<String, dynamic> roomData) async {
    try {
      // Add update timestamp
      roomData['updatedAt'] = DateTime.now().millisecondsSinceEpoch;
      
      // Convert single imageUrl to imageUrls list if needed
      if (roomData.containsKey('imageUrl') && !roomData.containsKey('imageUrls')) {
        roomData['imageUrls'] = [roomData['imageUrl']];
        roomData.remove('imageUrl');
      }
      
      // Set location from city if not provided
      if (roomData.containsKey('city') && !roomData.containsKey('location')) {
        roomData['location'] = roomData['city'];
      }
      
      // Map capacity to maxGuests if provided
      if (roomData.containsKey('capacity') && !roomData.containsKey('maxGuests')) {
        roomData['maxGuests'] = roomData['capacity'];
        roomData.remove('capacity');
      }
      
      await _firestore.collection(_collection).doc(roomId).update(roomData);
    } catch (e) {
      throw 'Error updating room: $e';
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

  // Check room availability for specific date and time
  static Future<bool> isRoomAvailable(
      String roomId, DateTime bookingDate, 
      {String? checkInTime, String? checkOutTime}) async {
    try {
      // Check if room exists and is available
      RoomModel? room = await getRoomById(roomId);
      if (room == null || !room.isAvailable) return false;

      // For same-day bookings, check time conflict
      // Get all active bookings for this room
      QuerySnapshot existingBookings = await _firestore
          .collection('bookings')
          .where('roomId', isEqualTo: roomId)
          .where('status', whereIn: ['pending', 'confirmed']).get();

      // Get the date (without time) for the requested booking
      final requestedDate = DateTime(bookingDate.year, bookingDate.month, bookingDate.day);
      
      // Use provided time strings if available
      final requestedCheckInTime = checkInTime ?? '08:00';
      final requestedCheckOutTime = checkOutTime ?? '17:00';

      debugPrint('🔍 Checking availability for room $roomId');
      debugPrint('   Requested: ${requestedDate.toString().split(' ')[0]} $requestedCheckInTime - $requestedCheckOutTime');

      for (var booking in existingBookings.docs) {
        final data = booking.data() as Map<String, dynamic>;
        final existingBookingDate = DateTime.fromMillisecondsSinceEpoch(data['bookingDate']);
        final existingDateOnly = DateTime(existingBookingDate.year, existingBookingDate.month, existingBookingDate.day);
        
        // Only check time conflict if booking is on the same day
        if (requestedDate.isAtSameMomentAs(existingDateOnly)) {
          final existingCheckInTime = data['checkInTime'] as String? ?? '00:00';
          final existingCheckOutTime = data['checkOutTime'] as String? ?? '00:00';

          debugPrint('   Existing booking: $existingCheckInTime - $existingCheckOutTime');

          // Parse times for comparison
          final requestedInMinutes = _timeToMinutes(requestedCheckInTime);
          final requestedOutMinutes = _timeToMinutes(requestedCheckOutTime);
          final existingInMinutes = _timeToMinutes(existingCheckInTime);
          final existingOutMinutes = _timeToMinutes(existingCheckOutTime);

          debugPrint('   Requested minutes: $requestedInMinutes - $requestedOutMinutes');
          debugPrint('   Existing minutes: $existingInMinutes - $existingOutMinutes');

          // Check if time slots overlap
          // Overlap occurs if: new_start < existing_end AND new_end > existing_start
          if (requestedInMinutes < existingOutMinutes && requestedOutMinutes > existingInMinutes) {
            debugPrint('   ❌ Time conflict detected!');
            return false;
          }
        }
      }

      debugPrint('   ✅ No conflicts, room available');
      return true;
    } catch (e) {
      throw 'Error checking room availability: $e';
    }
  }

  // Helper method to convert time string (HH:mm) to minutes
  static int _timeToMinutes(String timeStr) {
    try {
      final parts = timeStr.split(':');
      final hours = int.parse(parts[0]);
      final minutes = int.parse(parts[1]);
      return hours * 60 + minutes;
    } catch (e) {
      debugPrint('❌ Error parsing time $timeStr: $e');
      return 0;
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
