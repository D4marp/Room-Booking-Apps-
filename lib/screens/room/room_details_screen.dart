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
      body: Column(
        children: [
          // Image Carousel
          Expanded(
            flex: 2,
            child: _buildImageCarousel(),
          ),

          // Room Details
          Expanded(
            flex: 3,
            child: _buildRoomDetails(),
          ),
        ],
      ),

      // Book Now Button
      bottomNavigationBar: _buildBookButton(),
    );
  }

  Widget _buildImageCarousel() {
    return Stack(
      children: [
        // Images
        PageView.builder(
          controller: _pageController,
          itemCount: widget.room.imageUrls.length,
          onPageChanged: (index) {
            setState(() {
              _currentImageIndex = index;
            });
          },
          itemBuilder: (context, index) {
            return CachedNetworkImage(
              imageUrl: widget.room.imageUrls[index],
              width: double.infinity,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                color: Colors.grey.shade200,
                child: const Center(
                  child: CircularProgressIndicator(
                    valueColor:
                        AlwaysStoppedAnimation<Color>(AppColors.primaryBlue),
                  ),
                ),
              ),
              errorWidget: (context, url, error) => Container(
                color: Colors.grey.shade200,
                child: const Center(
                  child: Icon(
                    Icons.hotel,
                    size: 60,
                    color: AppColors.lightText,
                  ),
                ),
              ),
            );
          },
        ),

        // Gradient overlay
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.3),
                  Colors.transparent,
                  Colors.transparent,
                  Colors.black.withOpacity(0.3),
                ],
                stops: const [0.0, 0.3, 0.7, 1.0],
              ),
            ),
          ),
        ),

        // Top Bar
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(
                      Icons.arrow_back,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
                const Spacer(),
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: IconButton(
                    onPressed: () {
                      // Add to favorites functionality
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Added to favorites!'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                    icon: const Icon(
                      Icons.favorite_outline,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // Image indicators
        if (widget.room.imageUrls.length > 1)
          Positioned(
            bottom: AppSpacing.lg,
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

        // Price badge
        Positioned(
          bottom: AppSpacing.lg,
          right: AppSpacing.lg,
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            decoration: BoxDecoration(
              color: AppColors.primaryBlue,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Text(
              widget.room.formattedPrice,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRoomDetails() {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.creamBackground,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Room name and availability
            Row(
              children: [
                Expanded(
                  child: Text(
                    widget.room.name,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryText,
                        ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm,
                  ),
                  decoration: BoxDecoration(
                    color: widget.room.isAvailable
                        ? AppColors.successGreen
                        : AppColors.errorRed,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    widget.room.isAvailable ? 'Available' : 'Booked',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: AppSpacing.sm),

            // Location
            Row(
              children: [
                const Icon(
                  Icons.location_on,
                  size: 18,
                  color: AppColors.secondaryText,
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    '${widget.room.location}, ${widget.room.city}',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: AppColors.secondaryText,
                        ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: AppSpacing.lg),

            // Quick info
            Row(
              children: [
                _buildQuickInfo(
                  Icons.people,
                  'Up to ${widget.room.maxGuests} guests',
                ),
                const SizedBox(width: AppSpacing.lg),
                _buildQuickInfo(
                  Icons.phone,
                  widget.room.contactNumber,
                ),
              ],
            ),

            const SizedBox(height: AppSpacing.lg),

            // AC Badge
            if (widget.room.hasAC)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
                decoration: BoxDecoration(
                  color: AppColors.successGreen.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppColors.successGreen,
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.ac_unit,
                      size: 16,
                      color: AppColors.successGreen,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Air Conditioning Available',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.successGreen,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: AppSpacing.lg),

            // Description
            Text(
              'About this room',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryText,
                  ),
            ),

            const SizedBox(height: AppSpacing.sm),

            Text(
              widget.room.description,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppColors.secondaryText,
                    height: 1.6,
                  ),
            ),

            const SizedBox(height: AppSpacing.lg),

            // Amenities
            if (widget.room.amenities.isNotEmpty) ...[
              Text(
                'Amenities',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryText,
                    ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: widget.room.amenities.map((amenity) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.sm,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primaryBlue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      amenity,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.primaryBlue,
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                  );
                }).toList(),
              ),
            ],

            const SizedBox(height: AppSpacing.xxl),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickInfo(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 16,
          color: AppColors.primaryBlue,
        ),
        const SizedBox(width: 4),
        Text(
          text,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.primaryText,
                fontWeight: FontWeight.w500,
              ),
        ),
      ],
    );
  }

  Widget _buildBookButton() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
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
              ? AppColors.primaryBlue
              : Colors.grey.shade400,
        ),
      ),
    );
  }
}
