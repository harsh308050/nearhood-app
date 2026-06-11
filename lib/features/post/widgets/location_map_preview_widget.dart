import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:nearhood/core/utils/custom_import.dart';

class LocationMapPreviewWidget extends StatelessWidget {
  final double? latitude;
  final double? longitude;
  final String address;
  final double height;
  final bool showCancelButton;
  final VoidCallback? onCancel;

  const LocationMapPreviewWidget({
    super.key,
    required this.latitude,
    required this.longitude,
    required this.address,
    this.height = 170.0,
    this.showCancelButton = false,
    this.onCancel,
  });

  String get _stadiaApiKey => (dotenv.env['STADIAMAPS_API_KEY'] ?? '').trim();

  String get _mapUrlTemplate {
    if (_stadiaApiKey.isNotEmpty) {
      return 'https://tiles.stadiamaps.com/tiles/alidade_smooth/{z}/{x}/{y}.png?api_key=$_stadiaApiKey';
    }
    return 'https://tile.openstreetmap.org/{z}/{x}/{y}.png';
  }

  Future<void> _launchDirections(BuildContext context) async {
    String urlString;
    if (latitude != null && longitude != null) {
      urlString =
          'https://www.google.com/maps/dir/?api=1&destination=$latitude,$longitude';
    } else {
      urlString =
          'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(address)}';
    }
    final Uri url = Uri.parse(urlString);
    try {
      if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
        await launchUrl(url);
      }
    } catch (e) {
      debugPrint('Error launching map URL: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Could not open map: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasCoords = latitude != null && longitude != null;

    return Container(
      height: height.h,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12.r),
        child: Stack(
          children: [
            // Map tile background or placeholder
            Positioned.fill(
              child: hasCoords
                  ? FlutterMap(
                      options: MapOptions(
                        initialCenter: LatLng(latitude!, longitude!),
                        initialZoom: 15.0,
                        interactionOptions: const InteractionOptions(
                          flags: InteractiveFlag.none,
                        ),
                      ),
                      children: [
                        TileLayer(
                          urlTemplate: _mapUrlTemplate,
                          userAgentPackageName: 'com.harsh.nearhood',
                        ),
                        MarkerLayer(
                          markers: [
                            Marker(
                              point: LatLng(latitude!, longitude!),
                              child: Icon(
                                Icons.location_on_rounded,
                                color: AppColors.red,
                                size: 32.r,
                              ),
                            ),
                          ],
                        ),
                      ],
                    )
                  : CustomImageView(
                      imagePath: AppAssets.mapPlaceholder,
                      fit: BoxFit.cover,
                    ),
            ),

            // If coordinates are missing, draw center pin over placeholder
            if (!hasCoords)
              Center(
                child: Icon(
                  Icons.location_on,
                  color: AppColors.red,
                  size: 36.r,
                ),
              ),

            // Cancel Button (if showCancelButton is true)
            if (showCancelButton && onCancel != null)
              Positioned(
                top: 8.h,
                right: 8.w,
                child: GestureDetector(
                  onTap: onCancel,
                  child: Container(
                    padding: EdgeInsets.all(4.r),
                    decoration: const BoxDecoration(
                      color: AppColors.red,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.close,
                      color: AppColors.white,
                      size: 14.r,
                    ),
                  ),
                ),
              ),

            // Address bar at the bottom
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                decoration: BoxDecoration(
                  color: AppColors.white.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(12.r),
                    bottomRight: Radius.circular(12.r),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.map_outlined,
                      color: AppColors.primaryBlue,
                      size: 16.r,
                    ),
                    sw(6),
                    Expanded(
                      child: CustomText(
                        address,

                        style: AppTypography.bodyText.copyWith(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.darkGrey,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    sw(8),
                    // Direction Button
                    GestureDetector(
                      onTap: () => _launchDirections(context),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 10.w,
                          vertical: 4.h,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primaryBlue,
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.directions_rounded,
                              color: AppColors.white,
                              size: 12.r,
                            ),
                            sw(4),
                            CustomText(
                              AppStrings.directions,
                              style: AppTypography.buttonLabel.copyWith(
                                color: AppColors.white,
                                fontSize: 10.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
