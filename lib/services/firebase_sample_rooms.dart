import 'package:cloud_firestore/cloud_firestore.dart';

/// Firebase Sample Rooms Setup Service
/// Jalankan fungsi ini SETELAH membuat admin user dan security rules sudah dipublikasi
class FirebaseSampleRooms {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Tambahkan semua sample rooms ke Firestore
  static Future<void> addAllSampleRooms() async {
    try {
      print('🚀 Mulai menambahkan sample rooms...');
      
      final rooms = _getSampleRoomsData();
      
      for (var roomData in rooms) {
        try {
          await _firestore.collection('rooms').add(roomData);
          print('✅ Added: ${roomData['name']}');
        } catch (e) {
          print('❌ Error adding ${roomData['name']}: $e');
        }
      }
      
      print('✨ Semua sample rooms berhasil ditambahkan!');
    } catch (e) {
      print('Error adding sample rooms: $e');
      rethrow;
    }
  }

  /// Data sample rooms
  static List<Map<String, dynamic>> _getSampleRoomsData() {
    final now = DateTime.now().millisecondsSinceEpoch;
    
    return [
      {
        'id': 'room_1',
        'name': 'Conference Room A',
        'description': 'Ruang konferensi besar dengan fasilitas modern untuk rapat board dan presentasi klien.',
        'location': 'Gedung A, Lantai 3',
        'city': 'Jakarta',
        'roomClass': 'Conference Room',
        'maxGuests': 15,
        'floor': '3',
        'building': 'A',
        'isAvailable': true,
        'hasAC': true,
        'contactNumber': '+62 21 1234567',
        'imageUrls': [
          'https://images.unsplash.com/photo-1552664730-d307ca884978?w=800&h=600&fit=crop',
          'https://images.unsplash.com/photo-1552664730-d307ca884978?w=800&h=600&fit=crop',
        ],
        'amenities': [
          'Projector 4K',
          'Video Conference System',
          'Whiteboard',
          'WiFi High Speed',
          'Air Conditioning',
          'Meja Bundar',
        ],
        'createdAt': now,
        'updatedAt': now,
      },
      {
        'id': 'room_2',
        'name': 'Meeting Room B',
        'description': 'Ruang meeting nyaman untuk diskusi tim dan meeting kelompok kecil.',
        'location': 'Gedung B, Lantai 1',
        'city': 'Jakarta',
        'roomClass': 'Meeting Room',
        'maxGuests': 6,
        'floor': '1',
        'building': 'B',
        'isAvailable': true,
        'hasAC': true,
        'contactNumber': '+62 21 1234568',
        'imageUrls': [
          'https://images.unsplash.com/photo-1552664730-d307ca884978?w=800&h=600&fit=crop',
        ],
        'amenities': [
          'Whiteboard',
          'WiFi',
          'Air Conditioning',
          'Meja Meeting',
          'Kursi Ergonomis',
        ],
        'createdAt': now,
        'updatedAt': now,
      },
      {
        'id': 'room_3',
        'name': 'Auditorium Hall',
        'description': 'Auditorium besar untuk seminar, training session, dan acara kelompok besar.',
        'location': 'Gedung Utama, Lantai Dasar',
        'city': 'Jakarta',
        'roomClass': 'Auditorium',
        'maxGuests': 100,
        'floor': '0',
        'building': 'Main',
        'isAvailable': true,
        'hasAC': true,
        'contactNumber': '+62 21 1234569',
        'imageUrls': [
          'https://images.unsplash.com/photo-1552664730-d307ca884978?w=800&h=600&fit=crop',
        ],
        'amenities': [
          'Stage',
          'Sound System Professional',
          'Projectors Multiple',
          'WiFi',
          'Air Conditioning',
          'Kursi Teater',
          'Microphone System',
        ],
        'createdAt': now,
        'updatedAt': now,
      },
      {
        'id': 'room_4',
        'name': 'Study Room C',
        'description': 'Ruang belajar tenang untuk mahasiswa dan profesional yang memerlukan lingkungan fokus.',
        'location': 'Gedung C, Lantai 2',
        'city': 'Jakarta',
        'roomClass': 'Study Room',
        'maxGuests': 8,
        'floor': '2',
        'building': 'C',
        'isAvailable': true,
        'hasAC': true,
        'contactNumber': '+62 21 1234570',
        'imageUrls': [
          'https://images.unsplash.com/photo-1552664730-d307ca884978?w=800&h=600&fit=crop',
        ],
        'amenities': [
          'WiFi High Speed',
          'Air Conditioning',
          'Meja Belajar',
          'Kursi Nyaman',
          'Rak Buku',
          'Pencahayaan Optimal',
        ],
        'createdAt': now,
        'updatedAt': now,
      },
      {
        'id': 'room_5',
        'name': 'Training Room D',
        'description': 'Ruang training dilengkapi dengan peralatan pembelajaran modern untuk workshop dan training.',
        'location': 'Gedung D, Lantai 2',
        'city': 'Jakarta',
        'roomClass': 'Training Room',
        'maxGuests': 25,
        'floor': '2',
        'building': 'D',
        'isAvailable': true,
        'hasAC': true,
        'contactNumber': '+62 21 1234571',
        'imageUrls': [
          'https://images.unsplash.com/photo-1552664730-d307ca884978?w=800&h=600&fit=crop',
        ],
        'amenities': [
          'Projector',
          'Whiteboard',
          'WiFi',
          'Air Conditioning',
          'Meja Training',
          'Kursi Peserta',
          'Sound System',
        ],
        'createdAt': now,
        'updatedAt': now,
      },
      {
        'id': 'room_6',
        'name': 'Executive Office E',
        'description': 'Kantor eksekutif premium dengan konsultan pribadi, akses lounge, dan layanan full service.',
        'location': 'Gedung E, Lantai 4',
        'city': 'Jakarta',
        'roomClass': 'Office',
        'maxGuests': 2,
        'floor': '4',
        'building': 'E',
        'isAvailable': true,
        'hasAC': true,
        'contactNumber': '+62 21 1234572',
        'imageUrls': [
          'https://images.unsplash.com/photo-1552664730-d307ca884978?w=800&h=600&fit=crop',
        ],
        'amenities': [
          'WiFi Enterprise',
          'Air Conditioning Premium',
          'Meja Kerja Mewah',
          'Kursi Eksekutif',
          'Private Lounge',
          'Coffee Machine',
          'Mini Fridge',
        ],
        'createdAt': now,
        'updatedAt': now,
      },
    ];
  }

  /// Hapus semua sample rooms (untuk testing)
  static Future<void> deleteAllSampleRooms() async {
    try {
      print('🗑️ Menghapus semua sample rooms...');
      
      final snapshot = await _firestore.collection('rooms').get();
      
      for (var doc in snapshot.docs) {
        await doc.reference.delete();
        print('❌ Deleted: ${doc.id}');
      }
      
      print('✨ Semua rooms berhasil dihapus!');
    } catch (e) {
      print('Error deleting rooms: $e');
      rethrow;
    }
  }

  /// Cek jumlah rooms yang ada
  static Future<int> getRoomCount() async {
    try {
      final snapshot = await _firestore.collection('rooms').get();
      return snapshot.docs.length;
    } catch (e) {
      print('Error getting room count: $e');
      return 0;
    }
  }
}
