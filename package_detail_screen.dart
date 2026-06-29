import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:my_app/models/wedding_planner_package.dart';
import 'package:my_app/providers/compare_packages_provider.dart';
import 'package:my_app/widgets/package_vendor_card.dart';
import 'package:my_app/screens/packages/vendor_contact_screen.dart';
import 'package:my_app/screens/packages/package_comparison_screen.dart';

class PackageDetailScreen extends StatelessWidget {
  const PackageDetailScreen({
    super.key,
    required this.planner,
    this.distanceKm,
  });

  final WeddingPlannerPackage planner;
  final double? distanceKm;

  @override
  Widget build(BuildContext context) {
    final compareProvider = context.watch<ComparePackagesProvider>();
    final isSelected = compareProvider.isSelected(planner.id);

    return Scaffold(
      backgroundColor: PackageTheme.creamBg,
      appBar: AppBar(
        backgroundColor: PackageTheme.primaryPink,
        foregroundColor: Colors.white,
        title: const Text(
          'Package Detail',
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
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  height: 200,
                  color: PackageTheme.primaryPink.withValues(alpha: 0.3),
                  child: const Icon(Icons.image, size: 64),
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
                      color: PackageTheme.textDark,
                      fontFamily: 'Serif',
                    ),
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      planner.formattedPrice,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: PackageTheme.deepPink,
                      ),
                    ),
                    const Text(
                      'Starting from',
                      style: TextStyle(fontSize: 11, color: Colors.grey),
                    ),
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
                Text(
                  '${planner.locationName}, ${planner.state}',
                  style: const TextStyle(color: PackageTheme.textDark),
                ),
                if (distanceKm != null) ...[
                  const SizedBox(width: 12),
                  Icon(Icons.near_me_outlined,
                      size: 16, color: PackageTheme.deepPink.withValues(alpha: 0.9)),
                  const SizedBox(width: 2),
                  Text(
                    distanceKm! < 1
                        ? '${(distanceKm! * 1000).round()} m'
                        : '${distanceKm!.toStringAsFixed(1)} km',
                    style: TextStyle(
                      fontSize: 13,
                      color: PackageTheme.deepPink.withValues(alpha: 0.9),
                    ),
                  ),
                ],
                const SizedBox(width: 12),
                const Icon(Icons.star, size: 18, color: PackageTheme.deepPink),
                const SizedBox(width: 4),
                Text(
                  '${planner.rating} (${planner.reviewCount})',
                  style: const TextStyle(color: PackageTheme.textDark),
                ),
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
                    'Package Includes',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Serif',
                      color: PackageTheme.textDark,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...planner.inclusions.map(
                    (item) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('• ', style: TextStyle(fontSize: 16)),
                          Expanded(
                            child: Text(
                              item,
                              style: const TextStyle(
                                color: PackageTheme.textDark,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const Divider(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _infoIcon(Icons.person_outline, '${planner.pax} Pax'),
                      _infoIcon(Icons.access_time, planner.duration),
                      _infoIcon(Icons.home_outlined, planner.category),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  final provider = context.read<ComparePackagesProvider>();
                  if (!isSelected &&
                      provider.count >= ComparePackagesProvider.maxCompare) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Maximum 2 packages for comparison. Deselect one first.',
                        ),
                      ),
                    );
                    return;
                  }
                  provider.toggle(planner);
                },
                icon: Icon(
                  isSelected ? Icons.check_circle : Icons.compare_arrows,
                ),
                label: Text(
                  isSelected ? 'Added to Compare' : 'Add to Compare',
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: PackageTheme.deepPink,
                  side: const BorderSide(color: PackageTheme.deepPink),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute<void>(
                      builder: (_) => VendorContactScreen(planner: planner),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: PackageTheme.deepPink,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Contact Vendor',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            if (compareProvider.canCompare) ...[
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute<void>(
                        builder: (_) => const PackageComparisonScreen(),
                      ),
                    );
                  },
                  child: const Text('Go to Package Comparison'),
                ),
              ),
            ],
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
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: PackageTheme.textDark),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
