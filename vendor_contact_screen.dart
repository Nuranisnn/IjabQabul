import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:my_app/models/wedding_planner_package.dart';
import 'package:my_app/widgets/package_vendor_card.dart';

class VendorContactScreen extends StatelessWidget {
  const VendorContactScreen({super.key, required this.planner});

  final WeddingPlannerPackage planner;

  Future<void> _launch(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PackageTheme.creamBg,
      appBar: AppBar(
        backgroundColor: PackageTheme.primaryPink,
        foregroundColor: Colors.white,
        title: const Text(
          'Contact Us',
          style: TextStyle(fontFamily: 'Serif', fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.network(
                planner.imageUrl,
                height: 180,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  height: 180,
                  color: PackageTheme.primaryPink.withValues(alpha: 0.3),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    planner.name,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Serif',
                      color: PackageTheme.textDark,
                    ),
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      planner.formattedPrice,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: PackageTheme.deepPink,
                      ),
                    ),
                    const Text('Starting from',
                        style: TextStyle(fontSize: 11, color: Colors.grey)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.location_on_outlined,
                    size: 18, color: PackageTheme.deepPink),
                const SizedBox(width: 4),
                Text(planner.locationName),
                const SizedBox(width: 12),
                const Icon(Icons.star, size: 18, color: PackageTheme.deepPink),
                const SizedBox(width: 4),
                Text('${planner.rating} (${planner.reviewCount})'),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Contact Us',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Serif',
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (planner.phone != null)
                    _contactTile(
                      Icons.phone_outlined,
                      'Phone',
                      planner.phone!,
                      onTap: () => _launch('tel:${planner.phone!.split('/').first.trim()}'),
                    ),
                  if (planner.email != null)
                    _contactTile(
                      Icons.email_outlined,
                      'Email',
                      planner.email!,
                      onTap: () => _launch('mailto:${planner.email}'),
                    ),
                  if (planner.instagram != null)
                    _contactTile(
                      Icons.camera_alt_outlined,
                      'Instagram',
                      planner.instagram!,
                      onTap: () {
                        final handle =
                            planner.instagram!.replaceAll('@', '');
                        _launch('https://instagram.com/$handle');
                      },
                    ),
                  if (planner.tiktok != null)
                    _contactTile(
                      Icons.music_note_outlined,
                      'TikTok',
                      planner.tiktok!,
                      onTap: () {
                        final handle = planner.tiktok!.replaceAll('@', '');
                        _launch('https://tiktok.com/@$handle');
                      },
                    ),
                  if (planner.website != null)
                    _contactTile(
                      Icons.language,
                      'Website',
                      planner.website!,
                      onTap: () => _launch(planner.website!),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _infoIcon(Icons.person_outline, '${planner.pax} Pax'),
                _infoIcon(Icons.access_time, planner.duration),
                _infoIcon(Icons.home_outlined, planner.category),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: PackageTheme.deepPink,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Back',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _contactTile(
    IconData icon,
    String label,
    String value, {
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Icon(icon, color: PackageTheme.deepPink),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: const TextStyle(
                          fontSize: 12, color: PackageTheme.deepPink)),
                  Text(value,
                      style: const TextStyle(
                          fontWeight: FontWeight.w500,
                          color: PackageTheme.textDark)),
                ],
              ),
            ),
            if (onTap != null)
              const Icon(Icons.open_in_new, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _infoIcon(IconData icon, String label) {
    return Column(
      children: [
        Icon(icon, color: PackageTheme.deepPink, size: 28),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}
