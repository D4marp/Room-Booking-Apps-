import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../models/room_model.dart';
import '../../utils/app_theme.dart';
import '../../widgets/custom_button.dart';
import '../booking/booking_screen.dart';

class RoomDetailsScreen extends StatefulWidget {
  final RoomModel room;

  const RoomDetailsScreen({
    super.key,
    required this.room,
  });

  @override
  State<RoomDetailsScreen> createState() => _RoomDetailsScreenState();
}

class _RoomDetailsScreenState extends State<RoomDetailsScreen> {
  final PageController _pageController = PageController();
  int _currentImageIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          Expanded(flex: 2, child: _buildImageCarousel()),
          Expanded(
            flex: 3,
            child: Stack(
              children: [
                _buildRoomDetails(),
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: _buildBookButton(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageCarousel() {
    return Stack(
      children: [
        PageView.builder(
          controller: _pageController,
          itemCount: widget.room.imageUrls.length,
          onPageChanged: (index) => setState(() => _currentImageIndex = index),
          itemBuilder: (context, index) => CachedNetworkImage(
            imageUrl: widget.room.imageUrls[index],
            fit: BoxFit.cover,
            placeholder: (context, url) => Container(
              color: Colors.grey.shade200,
              child: const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryBlue),
                ),
              ),
            ),
            errorWidget: (context, url, error) => Container(
              color: Colors.grey.shade200,
              child: const Center(
                child: Icon(Icons.hotel, size: 60, color: AppColors.lightText),
              ),
            ),
          ),
        ),
        Positioned(
          top: 16,
          left: 16,
          child: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
            ),
          ),
        ),
        Positioned(
          bottom: 16,
          left: 0,
          right: 0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: widget.room.imageUrls.asMap().entries.map((entry) {
              return Container(
                width: 8,
                height: 8,
                margin: const EdgeInsets.symmetric(horizontal: 3),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _currentImageIndex == entry.key
                      ? Colors.white
                      : Colors.white.withOpacity(0.5),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildRoomDetails() {
    return Container(
      color: Colors.black87,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: _buildReservaHeader(),
          ),
          const SizedBox(height: AppSpacing.sm),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              child: _buildScheduleSection(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: _buildQuickInfoChips(),
          ),
        ],
      ),
    );
  }

  Widget _buildReservaHeader() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFFB71C1C),
            const Color(0xFF8B0000),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            widget.room.name,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 28,
                ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 6),
          Text(
            widget.room.roomClass,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.white.withOpacity(0.85),
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              const Icon(Icons.location_on, color: Colors.white70, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '${widget.room.location}, ${widget.room.city}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: widget.room.isAvailable
                  ? Colors.green.withOpacity(0.2)
                  : Colors.red.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: widget.room.isAvailable
                    ? Colors.green.withOpacity(0.7)
                    : Colors.red.withOpacity(0.7),
                width: 1.5,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  widget.room.isAvailable ? Icons.check_circle : Icons.cancel,
                  color: widget.room.isAvailable ? Colors.green : Colors.red,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  widget.room.isAvailable ? 'Available' : 'Booked',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleSection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade900,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade800),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.grey.shade800)),
            ),
            child: Row(
              children: [
                const Icon(Icons.schedule, color: Colors.white70, size: 18),
                const SizedBox(width: 6),
                Text(
                  'Schedule',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _buildScheduleList(),
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleList() {
    // TODO: Fetch real schedule from Firebase
    // Untuk sekarang tampilkan pesan kosong jika tidak ada data
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.event_available,
            color: Colors.white30,
            size: 40,
          ),
          const SizedBox(height: 8),
          Text(
            'No schedule available',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white54,
                  fontSize: 14,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickInfoChips() {
    return Row(
      children: [
        Expanded(
          child: _buildInfoChip(
            icon: Icons.people,
            label: 'Capacity',
            value: '${widget.room.maxGuests}',
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: _buildInfoChip(
            icon: widget.room.hasAC ? Icons.ac_unit : Icons.wind_power,
            label: 'Climate',
            value: widget.room.hasAC ? 'AC' : 'Fan',
          ),
        ),
      ],
    );
  }

  Widget _buildInfoChip({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.grey.shade900,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade800),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.white70, size: 18),
          const SizedBox(height: 6),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.white54,
                  fontSize: 11,
                ),
          ),
          const SizedBox(height: 3),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookButton() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: const BoxDecoration(
        color: Colors.black87,
        boxShadow: [
          BoxShadow(
            color: Colors.black54,
            blurRadius: 8,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: CustomButton(
          text: 'Book Now',
          onPressed: widget.room.isAvailable
              ? () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => BookingScreen(room: widget.room),
                    ),
                  );
                }
              : null,
          backgroundColor: widget.room.isAvailable
              ? const Color(0xFFB71C1C)
              : Colors.grey.shade600,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}
