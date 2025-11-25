import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// AdminSetupService - Handles admin-only operations with proper permission checks
/// 
/// This service is used for admin panel operations and should only be called
/// after verifying the user has admin role.
class AdminSetupService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Check if current user is admin
  static Future<bool> isCurrentUserAdmin() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return false;

      final userDoc =
          await _firestore.collection('users').doc(user.uid).get();
      return userDoc.data()?['role'] == 'admin';
    } catch (e) {
      print('Error checking admin status: $e');
      return false;
    }
  }

  /// Add sample rooms (admin only)
  static Future<List<String>> addSampleRooms() async {
    // Check admin permission first
    if (!await isCurrentUserAdmin()) {
      throw 'Permission denied: Only admins can add rooms';
    }

    final sampleRooms = [
      {
        'name': 'Conference Room A',
        'description':
            'Large conference room with modern facilities, perfect for board meetings and client presentations.',
        'location': 'Building A, Floor 3',
        'city': 'Jakarta',
        'maxGuests': 15,
        'roomClass': 'Conference Room',
        'floor': 3,
        'building': 'A',
        'isAvailable': true,
        'primaryImageUrl':
            'https://images.unsplash.com/photo-1552664730-d307ca884978?w=800',
        'facilities': [
          'Projector',
          'Video Conference',
          'Whiteboard',
          'WiFi',
          'Air Conditioning'
        ],
        'hasAC': true,
      },
      {
        'name': 'Meeting Room B',
        'description':
            'Cozy meeting space perfect for team discussions and small group meetings.',
        'location': 'Building B, Floor 1',
        'city': 'Jakarta',
        'maxGuests': 6,
        'roomClass': 'Meeting Room',
        'floor': 1,
        'building': 'B',
        'isAvailable': true,
        'primaryImageUrl':
            'https://images.unsplash.com/photo-1552664730-d307ca884978?w=800',
        'facilities': ['Whiteboard', 'WiFi', 'Air Conditioning'],
        'hasAC': true,
      },
      {
        'name': 'Auditorium Hall',
        'description':
            'Large auditorium for seminars, training sessions, and large group events.',
        'location': 'Main Building, Ground Floor',
        'city': 'Jakarta',
        'maxGuests': 100,
        'roomClass': 'Auditorium',
        'floor': 0,
        'building': 'Main',
        'isAvailable': true,
        'primaryImageUrl':
            'https://images.unsplash.com/photo-1552664730-d307ca884978?w=800',
        'facilities': [
          'Stage',
          'Sound System',
          'Projectors',
          'WiFi',
          'Air Conditioning'
        ],
        'hasAC': true,
      },
      {
        'name': 'Study Room C',
        'description':
            'Quiet study space for students and professionals who need focused work environment.',
        'location': 'Building C, Floor 2',
        'city': 'Jakarta',
        'maxGuests': 4,
        'roomClass': 'Study Room',
        'floor': 2,
        'building': 'C',
        'isAvailable': true,
        'primaryImageUrl':
            'https://images.unsplash.com/photo-1552664730-d307ca884978?w=800',
        'facilities': ['Desks', 'WiFi', 'Air Conditioning', 'Quiet Environment'],
        'hasAC': true,
      },
      {
        'name': 'Executive Boardroom',
        'description':
            'Premium boardroom with luxury furniture and state-of-the-art technology.',
        'location': 'Building A, Floor 5',
        'city': 'Jakarta',
        'maxGuests': 12,
        'roomClass': 'Boardroom',
        'floor': 5,
        'building': 'A',
        'isAvailable': true,
        'primaryImageUrl':
            'https://images.unsplash.com/photo-1552664730-d307ca884978?w=800',
        'facilities': [
          '4K Display',
          'Video Conference',
          'Premium Furniture',
          'WiFi',
          'Air Conditioning'
        ],
        'hasAC': true,
      },
    ];

    final createdRoomIds = <String>[];
    final now = DateTime.now().millisecondsSinceEpoch;

    for (var roomData in sampleRooms) {
      try {
        // Add timestamps
        roomData['createdAt'] = now;
        roomData['updatedAt'] = now;

        final docRef = await _firestore.collection('rooms').add(roomData);
        createdRoomIds.add(docRef.id);
        print('✅ Added room: ${roomData['name']}');
      } catch (e) {
        print('❌ Error adding room ${roomData['name']}: $e');
        rethrow;
      }
    }

    print('✅ Sample rooms creation complete: ${createdRoomIds.length} rooms added');
    return createdRoomIds;
  }

  /// Get room count
  static Future<int> getRoomCount() async {
    try {
      final snapshot = await _firestore.collection('rooms').count().get();
      return snapshot.count ?? 0;
    } catch (e) {
      print('Error getting room count: $e');
      return 0;
    }
  }

  /// Delete all rooms (admin only - use carefully!)
  static Future<void> deleteAllRooms() async {
    if (!await isCurrentUserAdmin()) {
      throw 'Permission denied: Only admins can delete rooms';
    }

    try {
      final roomsSnapshot = await _firestore.collection('rooms').get();

      for (var doc in roomsSnapshot.docs) {
        await doc.reference.delete();
        print('Deleted room: ${doc.id}');
      }
      print('✅ All rooms deleted successfully');
    } catch (e) {
      print('❌ Error deleting rooms: $e');
      rethrow;
    }
  }

  /// Verify Firestore is accessible
  static Future<bool> verifyFirestoreAccess() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return false;

      // Try to read user document
      final userDoc =
          await _firestore.collection('users').doc(user.uid).get();
      return userDoc.exists;
    } catch (e) {
      print('Firestore access check failed: $e');
      return false;
    }
  }

  /// Get setup status
  static Future<Map<String, dynamic>> getSetupStatus() async {
    try {
      final user = _auth.currentUser;
      final isAdmin = await isCurrentUserAdmin();
      final roomCount = await getRoomCount();
      final firestoreAccessible = await verifyFirestoreAccess();

      return {
        'isLoggedIn': user != null,
        'userId': user?.uid,
        'userEmail': user?.email,
        'isAdmin': isAdmin,
        'roomCount': roomCount,
        'firestoreAccessible': firestoreAccessible,
      };
    } catch (e) {
      return {
        'error': e.toString(),
      };
    }
  }
}

