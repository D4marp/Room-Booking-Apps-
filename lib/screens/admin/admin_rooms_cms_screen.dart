import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/room_provider_v2.dart';
import '../../models/room_model.dart';
import '../../utils/app_theme.dart';
import '../../core/gen/assets.gen.dart';

class AdminRoomsCMSScreen extends StatefulWidget {
  const AdminRoomsCMSScreen({super.key});

  @override
  State<AdminRoomsCMSScreen> createState() => _AdminRoomsCMSScreenState();
}

class _AdminRoomsCMSScreenState extends State<AdminRoomsCMSScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      context.read<RoomProvider>().fetchRooms();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<RoomProvider>(
      builder: (context, roomProvider, _) {
        return Scaffold(
          backgroundColor: AppColors.creamBackground,
          appBar: AppBar(
            title: const Text('Room Management'),
            backgroundColor: Colors.transparent,
            elevation: 0,
            foregroundColor: AppColors.primaryText,
            actions: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: ElevatedButton.icon(
                  onPressed: () => _showAddRoomDialog(context),
                  icon: const Icon(Icons.add),
                  label: const Text('Add Room'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryRed,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          body: Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(Assets.images.tabScreen.path),
                fit: BoxFit.cover,
              ),
            ),
            child: roomProvider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : roomProvider.rooms.isEmpty
                    ? Center(
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
                      )
                    : Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: SingleChildScrollView(
                          child: Card(
                            elevation: 4,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: DataTable(
                                  columns: const [
                                    DataColumn(label: Text('Room Name')),
                                    DataColumn(label: Text('Capacity')),
                                    DataColumn(label: Text('Location')),
                                    DataColumn(label: Text('Amenities')),
                                    DataColumn(label: Text('Actions')),
                                  ],
                                  rows: [],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
          ),
        );
      },
    );
  }

  void _showAddRoomDialog(BuildContext context) {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();
    final capacityController = TextEditingController();
    final locationController = TextEditingController();
    final amenitiesController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Room'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Room Name'),
              ),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 3,
              ),
              TextField(
                controller: capacityController,
                decoration: const InputDecoration(labelText: 'Capacity'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: locationController,
                decoration: const InputDecoration(labelText: 'Location'),
              ),
              TextField(
                controller: amenitiesController,
                decoration: const InputDecoration(labelText: 'Amenities (comma separated)'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final room = RoomModel(
                id: '',
                name: nameController.text,
                description: descriptionController.text,
                capacity: int.tryParse(capacityController.text) ?? 0,
                location: locationController.text,
                amenities: amenitiesController.text.split(',').map((a) => a.trim()).toList(),
                imageUrl: '',
                availability: true,
              );

              final success = await context.read<RoomProvider>().createRoom(room);
              if (mounted) {
                Navigator.pop(context);
                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Room added successfully')),
                  );
                }
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showEditRoomDialog(BuildContext context, RoomModel room) {
    final nameController = TextEditingController(text: room.name);
    final descriptionController = TextEditingController(text: room.description);
    final capacityController = TextEditingController(text: room.capacity.toString());
    final locationController = TextEditingController(text: room.location);
    final amenitiesController = TextEditingController(text: (room.amenities ?? []).join(', '));

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Room'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Room Name'),
              ),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 3,
              ),
              TextField(
                controller: capacityController,
                decoration: const InputDecoration(labelText: 'Capacity'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: locationController,
                decoration: const InputDecoration(labelText: 'Location'),
              ),
              TextField(
                controller: amenitiesController,
                decoration: const InputDecoration(labelText: 'Amenities (comma separated)'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final updatedRoom = room.copyWith(
                name: nameController.text,
                description: descriptionController.text,
                capacity: int.tryParse(capacityController.text) ?? 0,
                location: locationController.text,
                amenities: amenitiesController.text.split(',').map((a) => a.trim()).toList(),
              );

              final success = await context.read<RoomProvider>().updateRoom(room.id, updatedRoom);
              if (mounted) {
                Navigator.pop(context);
                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Room updated successfully')),
                  );
                }
              }
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteRoom(BuildContext context, String roomId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: const Text('Are you sure you want to delete this room?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final success = await context.read<RoomProvider>().deleteRoom(roomId);
              if (mounted) {
                Navigator.pop(context);
                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Room deleted successfully')),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
