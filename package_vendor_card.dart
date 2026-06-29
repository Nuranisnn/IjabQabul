import 'package:flutter/material.dart';
import 'package:my_app/models/wedding_planner_package.dart';

class PackageTheme {
  static const Color primaryPink = Color(0xFFE5B6B6);
  static const Color deepPink = Color(0xFFBA8B8B);
  static const Color creamBg = Color(0xFFFFF9E5);
  static const Color textDark = Color(0xFF5C4646);
}

class PackageVendorCard extends StatelessWidget {
  const PackageVendorCard({
    super.key,
    required this.item,
    required this.isSelected,
    required this.onTap,
    required this.onToggleCompare,
  });

  final PlannerWithDistance item;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onToggleCompare;

  @override
  Widget build(BuildContext context) {
    final planner = item.planner;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                  child: Image.network(
                    planner.imageUrl,
                    height: 160,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      height: 160,
                      color: PackageTheme.primaryPink.withValues(alpha: 0.3),
                      child: const Icon(Icons.image, size: 48),
                    ),
                  ),
                ),
                Positioned(
                  top: 10,
                  right: 10,
                  child: GestureDetector(
                    onTap: onToggleCompare,
                    child: CircleAvatar(
                      radius: 16,
                      backgroundColor: isSelected
                          ? PackageTheme.deepPink
                          : Colors.white.withValues(alpha: 0.9),
                      child: Icon(
                        isSelected ? Icons.check : Icons.bookmark_border,
                        size: 18,
                        color: isSelected ? Colors.white : PackageTheme.deepPink,
                      ),
                    ),
                  ),
                ),
                if (item.sameState)
                  Positioned(
                    top: 10,
                    left: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: PackageTheme.deepPink,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'Same State',
                        style: TextStyle(color: Colors.white, fontSize: 10),
                      ),
                    ),
                  ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          planner.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: PackageTheme.textDark,
                            fontFamily: 'Serif',
                          ),
                        ),
                      ),
                      Text(
                        planner.formattedPrice,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: PackageTheme.deepPink,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        size: 16,
                        color: PackageTheme.deepPink,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        planner.locationName,
                        style: const TextStyle(
                          fontSize: 13,
                          color: PackageTheme.textDark,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Icon(
                        Icons.near_me_outlined,
                        size: 14,
                        color: PackageTheme.deepPink,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        item.distanceLabel,
                        style: TextStyle(
                          fontSize: 12,
                          color: PackageTheme.deepPink.withValues(alpha: 0.9),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(
                        Icons.star,
                        size: 16,
                        color: PackageTheme.deepPink,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${planner.rating} (${planner.reviewCount})',
                        style: const TextStyle(
                          fontSize: 13,
                          color: PackageTheme.textDark,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: PackageTheme.primaryPink.withValues(alpha: 0.4),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          planner.category,
                          style: const TextStyle(
                            fontSize: 11,
                            color: PackageTheme.textDark,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
