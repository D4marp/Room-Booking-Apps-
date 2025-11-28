import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/room_model.dart';
import '../../providers/room_provider.dart';
import '../../utils/app_theme.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

class AddEditRoomScreen extends StatefulWidget {
  final RoomModel? room;
  
  const AddEditRoomScreen({Key? key, this.room}) : super(key: key);

  @override
  State<AddEditRoomScreen> createState() => _AddEditRoomScreenState();
}

class _AddEditRoomScreenState extends State<AddEditRoomScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _cityController;
  late TextEditingController _addressController;
  late TextEditingController _capacityController;
  late TextEditingController _imageUrlController;
  late TextEditingController _floorController;
  late TextEditingController _buildingController;
  
  String _selectedClass = 'Meeting Room';
  bool _isAvailable = true;
  bool _isLoading = false;
  
  final List<String> _roomClasses = [
    'Meeting Room',
    'Conference Room',
    'Class Room',
    'Lecture Hall',
    'Training Room',
    'Board Room',
    'Study Room',
    'Lab',
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.room?.name ?? '');
    _descriptionController =
        TextEditingController(text: widget.room?.description ?? '');
    _cityController = TextEditingController(text: widget.room?.city ?? '');
    _addressController =
        TextEditingController(text: widget.room?.location ?? '');
    _capacityController =
        TextEditingController(text: widget.room?.maxGuests.toString() ?? '');
    _imageUrlController = TextEditingController(
        text: widget.room?.imageUrls.isNotEmpty == true ? widget.room!.imageUrls.first : '');
    _floorController = TextEditingController(text: widget.room?.floor ?? '');
    _buildingController = TextEditingController(text: widget.room?.building ?? '');
    
    if (widget.room != null) {
      _selectedClass = widget.room!.roomClass;
      _isAvailable = widget.room!.isAvailable;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _cityController.dispose();
    _addressController.dispose();
    _capacityController.dispose();
    _imageUrlController.dispose();
    _floorController.dispose();
    _buildingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.room == null ? 'Add Room' : 'Edit Room'),
        backgroundColor: AppColors.primaryRed,
        foregroundColor: Colors.white,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            CustomTextField(
              controller: _nameController,
              labelText: 'Room Name',
              hintText: 'e.g., Conference Room A',
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter room name';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            
            CustomTextField(
              controller: _descriptionController,
              labelText: 'Description',
              hintText: 'Room description',
              maxLines: 3,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter description';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            
            DropdownButtonFormField<String>(
              value: _selectedClass,
              decoration: const InputDecoration(
                labelText: 'Room Class',
                border: OutlineInputBorder(),
              ),
              items: _roomClasses.map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedClass = newValue!;
                });
              },
            ),
            const SizedBox(height: 16),
            
            CustomTextField(
              controller: _capacityController,
              labelText: 'Capacity (persons)',
              hintText: 'e.g., 10',
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter capacity';
                }
                if (int.tryParse(value) == null) {
                  return 'Please enter valid number';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            
            CustomTextField(
              controller: _buildingController,
              labelText: 'Building (Optional)',
              hintText: 'e.g., Building A',
            ),
            const SizedBox(height: 16),
            
            CustomTextField(
              controller: _floorController,
              labelText: 'Floor (Optional)',
              hintText: 'e.g., 3rd Floor',
            ),
            const SizedBox(height: 16),
            
            CustomTextField(
              controller: _cityController,
              labelText: 'City',
              hintText: 'e.g., Jakarta',
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter city';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            
            CustomTextField(
              controller: _addressController,
              labelText: 'Address',
              hintText: 'Full address',
              maxLines: 2,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter address';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            
            CustomTextField(
              controller: _imageUrlController,
              labelText: 'Image URL',
              hintText: 'https://example.com/image.jpg',
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter image URL';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            
            SwitchListTile(
              title: const Text('Available for Booking'),
              subtitle: Text(_isAvailable
                  ? 'Room is available'
                  : 'Room is not available'),
              value: _isAvailable,
              onChanged: (bool value) {
                setState(() {
                  _isAvailable = value;
                });
              },
              activeColor: AppColors.primaryRed,
            ),
            const SizedBox(height: 24),
            
            CustomButton(
              onPressed: _isLoading ? () {} : _saveRoom,
              text: _isLoading
                  ? 'Saving...'
                  : (widget.room == null ? 'Add Room' : 'Update Room'),
            ),
          ],
        ),
      ),
    );
  }

  void _saveRoom() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final roomProvider = Provider.of<RoomProvider>(context, listen: false);
      
      final roomData = {
        'name': _nameController.text,
        'description': _descriptionController.text,
        'roomClass': _selectedClass,
        'capacity': int.parse(_capacityController.text),
        'city': _cityController.text,
        'address': _addressController.text,
        'imageUrl': _imageUrlController.text,
        'isAvailable': _isAvailable,
        'floor': _floorController.text.isEmpty ? null : _floorController.text,
        'building': _buildingController.text.isEmpty ? null : _buildingController.text,
      };

      if (widget.room == null) {
        // Add new room
        await roomProvider.addRoom(roomData);
      } else {
        // Update existing room
        await roomProvider.updateRoom(widget.room!.id, roomData);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.room == null
                ? 'Room added successfully'
                : 'Room updated successfully'),
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
