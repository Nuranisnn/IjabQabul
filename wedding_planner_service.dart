import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:my_app/models/wedding_planner_package.dart';
import 'package:my_app/utils/distance_utils.dart';
import 'package:my_app/utils/malaysia_locations.dart';

class WeddingPlannerService {
  WeddingPlannerService({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;
  static const _collection = 'WeddingPlanners';

  /// Seed data matching the PDF mockups (Seri Impian, Indah Events, Damai).
  static List<WeddingPlannerPackage> get defaultPlanners => [
    WeddingPlannerPackage(
      id: 'seri_impian',
      name: 'Seri Impian Wedding',
      startingPrice: 28000,
      locationName: 'Shah Alam',
      state: 'Selangor',
      latitude: MalaysiaLocations.cities['Shah Alam']!.lat,
      longitude: MalaysiaLocations.cities['Shah Alam']!.lng,
      rating: 4.9,
      reviewCount: 184,
      category: 'Garden',
      inclusions: const [
        'Full Hall Decoration',
        'Catering',
        '2 Photographers (Photos & Videos)',
        'Makeup (Natural Glam)',
        'PA System',
        'Air-conditioned venue',
      ],
      pax: 200,
      duration: '1 Day',
      venueType: 'Indoor',
      decorationLevel: 'Full Hall Decoration',
      cateringPax: 200,
      makeupLevel: 'Full Glam 2 Person',
      photographerCount: 2,
      photographyDetail: '2 Photographers (Photos & Videos)',
      imageUrl:
          'https://images.unsplash.com/photo-1505944357431-27579db47558?q=80&w=1173&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
      phone: '012-2484449 / 03-3344229',
      email: 'seriimpianwedding@gmail.com',
      instagram: '@SeriImpianWedding',
      tiktok: '@SeriImpianWedding',
      website: 'https://seriimpianwedding.com.my',
    ),
    WeddingPlannerPackage(
      id: 'indah_events',
      name: 'Indah Events',
      startingPrice: 12000,
      locationName: 'Kajang',
      state: 'Selangor',
      latitude: MalaysiaLocations.cities['Kajang']!.lat,
      longitude: MalaysiaLocations.cities['Kajang']!.lng,
      rating: 4.3,
      reviewCount: 52,
      category: 'Traditional',
      inclusions: const [
        'Full Hall Decoration',
        'Catering',
        '1 Photographers (Photos & Videos)',
        'Makeup (Natural)',
        'PA System',
        'Air-conditioned venue',
      ],
      pax: 100,
      duration: '1 Day',
      venueType: 'Indoor',
      decorationLevel: 'Basic Hall Decoration',
      cateringPax: 150,
      makeupLevel: 'Basic Glam 1 Person',
      photographerCount: 1,
      photographyDetail: '1 Photographer (Photos only)',
      imageUrl:
          'https://images.unsplash.com/photo-1601482441062-b9f13131f33a?q=80&w=1170&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
      email: 'indahevents@gmail.com',
      instagram: '@IndahEvents',
    ),
    WeddingPlannerPackage(
      id: 'damai_planner',
      name: 'Damai Wedding Planner',
      startingPrice: 35000,
      locationName: 'Damansara',
      state: 'Selangor',
      latitude: MalaysiaLocations.cities['Damansara']!.lat,
      longitude: MalaysiaLocations.cities['Damansara']!.lng,
      rating: 4.6,
      reviewCount: 98,
      category: 'Ballroom',
      inclusions: const [
        'Full Hall Decoration',
        'Catering',
        '3 Photographers (Photos & Videos)',
        'Makeup (Full Glam)',
        'PA System',
        'Air-conditioned venue',
      ],
      pax: 300,
      duration: '1 Day',
      venueType: 'Indoor',
      decorationLevel: 'Full Hall Decoration',
      cateringPax: 300,
      makeupLevel: 'Full Glam 2 Person',
      photographerCount: 3,
      photographyDetail: '3 Photographers (Photos & Videos)',
      imageUrl:
          'https://images.unsplash.com/photo-1780542900375-0cf459e38fbb?q=80&w=1170&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
      phone: '018-2259663 / 03-3343229',
      email: 'damaiweddingplanner@gmail.com',
      instagram: '@DamaiWeddingPlanner',
      tiktok: '@DamaiWeddingPlanner',
      website: 'https://damaiweddingplanner.com.my',
    ),
  ];

  Future<List<WeddingPlannerPackage>> fetchPlanners() async {
    try {
      final snapshot = await _firestore.collection(_collection).get();

      if (snapshot.docs.isEmpty) {
        await _seedFirestore();
        return defaultPlanners;
      }

      return snapshot.docs
          .map((doc) => WeddingPlannerPackage.fromFirestore(doc.data(), doc.id))
          .toList();
    } catch (_) {
      return defaultPlanners;
    }
  }

  Future<void> _seedFirestore() async {
    final batch = _firestore.batch();
    for (final planner in defaultPlanners) {
      final ref = _firestore.collection(_collection).doc(planner.id);
      batch.set(ref, planner.toFirestore());
    }
    await batch.commit();
  }

  List<PlannerWithDistance> sortByProximity({
    required List<WeddingPlannerPackage> planners,
    required double userLat,
    required double userLng,
    String? userState,
    String category = 'All',
    String searchQuery = '',
  }) {
    final query = searchQuery.trim().toLowerCase();
    var filtered = planners.where((p) {
      final matchesCategory =
          category == 'All' ||
          p.category.toLowerCase() == category.toLowerCase();
      final matchesSearch =
          query.isEmpty || p.name.toLowerCase().contains(query);
      return matchesCategory && matchesSearch;
    }).toList();

    final withDistance = filtered.map((planner) {
      final distance = calculateDistanceKm(
        userLat,
        userLng,
        planner.latitude,
        planner.longitude,
      );
      final sameState =
          userState != null &&
          userState.isNotEmpty &&
          planner.state.toLowerCase() == userState.toLowerCase();
      return PlannerWithDistance(
        planner: planner,
        distanceKm: distance,
        sameState: sameState,
      );
    }).toList();

    withDistance.sort((a, b) {
      if (a.sameState != b.sameState) {
        return a.sameState ? -1 : 1;
      }
      return a.distanceKm.compareTo(b.distanceKm);
    });

    return withDistance;
  }

  static const List<String> categories = [
    'All',
    'Garden',
    'Ballroom',
    'Traditional',
  ];
}
