import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:my_app/providers/compare_packages_provider.dart';
import 'package:my_app/services/package_pdf_service.dart';
import 'package:my_app/widgets/package_vendor_card.dart';

class PackageComparisonScreen extends StatefulWidget {
  const PackageComparisonScreen({super.key});

  @override
  State<PackageComparisonScreen> createState() =>
      _PackageComparisonScreenState();
}

class _PackageComparisonScreenState extends State<PackageComparisonScreen> {
  final _pdfService = PackagePdfService();
  bool _isGenerating = false;

  @override
  Widget build(BuildContext context) {
    final packages = context.watch<ComparePackagesProvider>().selected;

    return Scaffold(
      backgroundColor: PackageTheme.creamBg,
      appBar: AppBar(
        backgroundColor: PackageTheme.primaryPink,
        foregroundColor: Colors.white,
        title: const Text(
          'Package Comparison',
          style: TextStyle(fontFamily: 'Serif', fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: packages.length < 2
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.compare_arrows,
                        size: 64, color: PackageTheme.deepPink),
                    const SizedBox(height: 16),
                    const Text(
                      'Select 2 wedding planner packages to compare.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: PackageTheme.textDark),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: PackageTheme.deepPink,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Browse Packages'),
                    ),
                  ],
                ),
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    children: packages
                        .map(
                          (p) => Expanded(
                            child: Container(
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: PackageTheme.deepPink,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                p.name,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                  const SizedBox(height: 16),
                  _comparisonRow('Starting Price',
                      packages.map((p) => p.formattedPrice).toList()),
                  _comparisonRow('Decoration',
                      packages.map((p) => p.decorationLevel).toList()),
                  _comparisonRow('Catering',
                      packages.map((p) => '${p.cateringPax} Pax').toList()),
                  _comparisonRow(
                      'Time', packages.map((p) => p.duration).toList()),
                  _comparisonRow(
                      'Venue', packages.map((p) => p.venueType).toList()),
                  _comparisonRow(
                      'Makeup', packages.map((p) => p.makeupLevel).toList()),
                  _comparisonRow('Location',
                      packages.map((p) => p.locationName).toList()),
                  _comparisonRow('Photography',
                      packages.map((p) => p.photographyDetail).toList()),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isGenerating
                          ? null
                          : () async {
                              setState(() => _isGenerating = true);
                              try {
                                await _pdfService.generateAndShareComparison(
                                  packages,
                                );
                              } finally {
                                if (mounted) {
                                  setState(() => _isGenerating = false);
                                }
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: PackageTheme.deepPink,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: _isGenerating
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              'Download PDF',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _comparisonRow(String label, List<String> values) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: PackageTheme.primaryPink.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                label,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: PackageTheme.textDark,
                  fontSize: 12,
                ),
              ),
            ),
          ),
          ...values.map(
            (value) => Expanded(
              flex: 3,
              child: Container(
                margin: const EdgeInsets.only(left: 6),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  value,
                  style: const TextStyle(
                    fontSize: 11,
                    color: PackageTheme.textDark,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
