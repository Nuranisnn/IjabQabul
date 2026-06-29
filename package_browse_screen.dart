import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:my_app/models/wedding_planner_package.dart';
import 'package:my_app/providers/compare_packages_provider.dart';
import 'package:my_app/services/location_service.dart';
import 'package:my_app/services/wedding_planner_service.dart';
import 'package:my_app/utils/malaysia_locations.dart';
import 'package:my_app/widgets/package_vendor_card.dart';
import 'package:my_app/screens/packages/package_detail_screen.dart';
import 'package:my_app/screens/packages/package_comparison_screen.dart';

class PackageBrowseScreen extends StatefulWidget {
  const PackageBrowseScreen({super.key});

  @override
  State<PackageBrowseScreen> createState() => _PackageBrowseScreenState();
}

class _PackageBrowseScreenState extends State<PackageBrowseScreen> {
  final _searchController = TextEditingController();
  final _plannerService = WeddingPlannerService();
  final _locationService = LocationService();

  List<WeddingPlannerPackage> _allPlanners = [];
  List<PlannerWithDistance> _displayPlanners = [];
  String _selectedCategory = 'All';
  String? _userState;
  String? _locationSourceLabel;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_applyFilters);
    _loadData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final planners = await _plannerService.fetchPlanners();
      final coords = await _resolveUserCoordinates();

      if (!mounted) return;

      setState(() {
        _allPlanners = planners;
        _userState = coords.state;
        _locationSourceLabel = coords.label;
        _displayPlanners = _plannerService.sortByProximity(
          planners: _allPlanners,
          userLat: coords.lat,
          userLng: coords.lng,
          userState: coords.state,
          category: _selectedCategory,
          searchQuery: _searchController.text,
        );
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<({double lat, double lng, String? state, String label})>
      _resolveUserCoordinates() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      try {
        final doc = await FirebaseFirestore.instance
            .collection('Users')
            .doc(uid)
            .get();
        final data = doc.data();
        if (data != null) {
          final lat = (data['latitude'] as num?)?.toDouble();
          final lng = (data['longitude'] as num?)?.toDouble();
          final state = data['state'] as String?;
          if (lat != null && lng != null) {
            return (
              lat: lat,
              lng: lng,
              state: state,
              label: 'Using your saved location${state != null ? ' ($state)' : ''}',
            );
          }
          if (state != null && state.isNotEmpty) {
            final centroid = MalaysiaLocations.coordsForState(state);
            if (centroid != null) {
              return (
                lat: centroid.lat,
                lng: centroid.lng,
                state: state,
                label: 'Using your state: $state',
              );
            }
          }
        }
      } catch (_) {}
    }

    final gps = await _locationService.getCurrentLocation();
    if (gps != null) {
      return (
        lat: gps.latitude,
        lng: gps.longitude,
        state: gps.state,
        label: gps.fromGps
            ? 'Using GPS${gps.state != null ? ' — detected ${gps.state}' : ''}'
            : 'Using device location',
      );
    }

    final fallback = MalaysiaLocations.stateCentroids['Selangor']!;
    return (
      lat: fallback.lat,
      lng: fallback.lng,
      state: 'Selangor',
      label: 'Default: Selangor (enable location for accurate sorting)',
    );
  }

  void _applyFilters() {
    if (_allPlanners.isEmpty) return;
    _resolveUserCoordinates().then((coords) {
      if (!mounted) return;
      setState(() {
        _displayPlanners = _plannerService.sortByProximity(
          planners: _allPlanners,
          userLat: coords.lat,
          userLng: coords.lng,
          userState: coords.state ?? _userState,
          category: _selectedCategory,
          searchQuery: _searchController.text,
        );
      });
    });
  }

  void _onCategorySelected(String category) {
    setState(() => _selectedCategory = category);
    _applyFilters();
  }

  @override
  Widget build(BuildContext context) {
    final compareProvider = context.watch<ComparePackagesProvider>();

    return Scaffold(
      backgroundColor: PackageTheme.creamBg,
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: PackageTheme.deepPink),
            )
          : _error != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(_error!, textAlign: TextAlign.center),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _loadData,
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadData,
                  color: PackageTheme.deepPink,
                  child: CustomScrollView(
                    slivers: [
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              TextField(
                                controller: _searchController,
                                decoration: InputDecoration(
                                  hintText: 'Search Vendors',
                                  prefixIcon: const Icon(Icons.search),
                                  filled: true,
                                  fillColor: Colors.white,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(24),
                                    borderSide: BorderSide.none,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  children: WeddingPlannerService.categories
                                      .map(
                                    (cat) => Padding(
                                      padding: const EdgeInsets.only(right: 8),
                                      child: ChoiceChip(
                                        label: Text(cat),
                                        selected: _selectedCategory == cat,
                                        selectedColor: PackageTheme.deepPink,
                                        labelStyle: TextStyle(
                                          color: _selectedCategory == cat
                                              ? Colors.white
                                              : PackageTheme.textDark,
                                        ),
                                        onSelected: (_) =>
                                            _onCategorySelected(cat),
                                      ),
                                    ),
                                  ).toList(),
                                ),
                              ),
                              const SizedBox(height: 12),
                              if (_locationSourceLabel != null)
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: PackageTheme.primaryPink
                                        .withValues(alpha: 0.35),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.my_location,
                                        size: 16,
                                        color: PackageTheme.deepPink,
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          _locationSourceLabel!,
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: PackageTheme.textDark,
                                          ),
                                        ),
                                      ),
                                      TextButton(
                                        onPressed: _loadData,
                                        child: const Text(
                                          'Refresh',
                                          style: TextStyle(fontSize: 12),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              const SizedBox(height: 16),
                              Text(
                                _searchController.text.isNotEmpty
                                    ? 'Top Results'
                                    : 'Top Picks — Nearest to You',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: PackageTheme.textDark,
                                  fontFamily: 'Serif',
                                ),
                              ),
                              const SizedBox(height: 12),
                            ],
                          ),
                        ),
                      ),
                      if (_displayPlanners.isEmpty)
                        const SliverFillRemaining(
                          child: Center(
                            child: Text(
                              'No wedding planners found for this filter.',
                              style: TextStyle(color: PackageTheme.textDark),
                            ),
                          ),
                        )
                      else
                        SliverPadding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          sliver: SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (context, index) {
                                final item = _displayPlanners[index];
                                return PackageVendorCard(
                                  item: item,
                                  isSelected: compareProvider
                                      .isSelected(item.planner.id),
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute<void>(
                                        builder: (_) => PackageDetailScreen(
                                          planner: item.planner,
                                          distanceKm: item.distanceKm,
                                        ),
                                      ),
                                    );
                                  },
                                  onToggleCompare: () {
                                    final provider = context
                                        .read<ComparePackagesProvider>();
                                    if (!provider.isSelected(item.planner.id) &&
                                        provider.count >=
                                            ComparePackagesProvider.maxCompare) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            'You can compare up to 2 packages. Deselect one first.',
                                          ),
                                        ),
                                      );
                                      return;
                                    }
                                    provider.toggle(item.planner);
                                  },
                                );
                              },
                              childCount: _displayPlanners.length,
                            ),
                          ),
                        ),
                      const SliverToBoxAdapter(child: SizedBox(height: 80)),
                    ],
                  ),
                ),
      floatingActionButton: compareProvider.count > 0
          ? FloatingActionButton.extended(
              onPressed: compareProvider.canCompare
                  ? () {
                      Navigator.push(
                        context,
                        MaterialPageRoute<void>(
                          builder: (_) => const PackageComparisonScreen(),
                        ),
                      );
                    }
                  : null,
              backgroundColor: PackageTheme.deepPink,
              label: Text(
                compareProvider.canCompare
                    ? 'Compare (${compareProvider.count})'
                    : 'Select ${2 - compareProvider.count} more',
              ),
              icon: const Icon(Icons.compare_arrows),
            )
          : null,
    );
  }
}
