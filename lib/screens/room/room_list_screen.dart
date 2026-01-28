import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/room_provider_v2.dart';

class RoomListScreen extends StatefulWidget {
  const RoomListScreen({super.key});

  @override
  State<RoomListScreen> createState() => _RoomListScreenState();
}

class _RoomListScreenState extends State<RoomListScreen> {
  late RoomProvider _roomProvider;

  @override
  void initState() {
    super.initState();
    _roomProvider = context.read<RoomProvider>();
    
    // Fetch initial rooms
    Future.delayed(Duration.zero, () {
      _roomProvider.fetchRooms();
      // Start event-driven refresh (every 30 seconds)
      _roomProvider.startListeningToRoomChanges(refreshIntervalSeconds: 30);
    });
  }

  @override
  void dispose() {
    // Stop listening when screen is closed
    _roomProvider.stopListeningToRoomChanges();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Available Rooms'),
        centerTitle: true,
        elevation: 0,
      ),
      body: Consumer<RoomProvider>(
        builder: (context, roomProvider, _) {
          if (roomProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (roomProvider.errorMessage != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
                  const SizedBox(height: 16),
                  Text(roomProvider.errorMessage!),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => roomProvider.fetchRooms(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (roomProvider.rooms.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.meeting_room_outlined, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'No rooms available',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => roomProvider.fetchRooms(),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: roomProvider.rooms.length,
              itemBuilder: (context, index) {
                final room = roomProvider.rooms[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    title: Text(room.name),
                    subtitle: Text('${room.location} • Capacity: ${room.capacity}'),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Booking for ${room.name} coming soon!')),
                      );
                    },
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
