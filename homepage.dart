import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class HomePage extends StatefulWidget {

  // Constructor setup to receive data safely
  const HomePage({
    super.key, 
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final User? user = FirebaseAuth.instance.currentUser;
  late final String displayName = user?.displayName?.trim().isNotEmpty == true
        ? user!.displayName!.trim()
        : 'Aina & Hafiz';

  String _formatGuidelinesText(dynamic value, {String fallback = '-'}) {
    if (value == null) return fallback;
    final text = value.toString().trim();
    return text.isEmpty ? fallback : text;
  }

  double? _parseGuidelinesNumber(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString());
  }

  @override
  Widget build(BuildContext context) {
    final uid = user?.uid;
    final Stream<DocumentSnapshot<Map<String, dynamic>>>? userStream =
        uid == null || uid.isEmpty
            ? null
            : FirebaseFirestore.instance.collection('Users').doc(uid).snapshots();

    return Scaffold(
      backgroundColor: const Color(0xFFFFF9E5),
      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: userStream,
        builder: (context, snapshot) {
          final data = snapshot.data?.data();
          final fetchedState = (data?['state'] as String?)?.trim();
          final fetchedRole = (data?['role'] as String?)?.trim();
          final fetchedDate = (data?['nikahDate'] as Timestamp?)?.toDate();

          final stateId = (fetchedState?.isNotEmpty == true) ? fetchedState! : 'Selangor';
          final role = (fetchedRole?.isNotEmpty == true) ? fetchedRole! : 'Groom';
          final weddingDate = fetchedDate ?? DateTime(2026, 12, 20);
          final today = DateTime.now();
          final countdownDays = weddingDate.difference(DateTime(today.year, today.month, today.day)).inDays;
          final Stream<DocumentSnapshot<Map<String, dynamic>>> guidelinesStream = FirebaseFirestore.instance.collection('guidelines').doc(stateId).snapshots();
          
          debugPrint('Fetching guidelines for state: "$stateId"');
          //debugPrint('Guideline data: ${snapshot.guidelinesStream?.data()}');

          return ListView(
            padding: const EdgeInsets.only(top: 20, bottom: 20),
            physics: const ClampingScrollPhysics(), 
            children: [
                Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  //SizedBox(height: 20),
                  _buildProfile(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('State Jurisdiction', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w500, fontSize: 14, fontFamily: 'Inter')),
                                  const SizedBox(height: 2),
                                  Text(stateId, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16, fontFamily: 'Inter')),
                                ],
                              ),
                            ),
                            Container(
                              alignment: Alignment.topRight,
                              width: 60,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const CircleAvatar(
                                    radius: 28,
                                    backgroundColor: Colors.white,
                                    child: Icon(Icons.person, color: Color(0xFFEBBABA)),
                                  ),
                                  const SizedBox(height: 2),
                                  Container(
                                    alignment: Alignment.topCenter,
                                    child: Text(
                                      displayName, 
                                      style: const TextStyle(
                                        color: Colors.white, 
                                        fontWeight: FontWeight.w900, 
                                        fontSize: 14, 
                                        fontFamily: 'Inter'
                                      )
                                    ),
                                  )
                                ],
                              ),
                            )
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(child: _infoPill(Icons.favorite_border, 'Role', role)),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _infoPill(
                                Icons.calendar_today_outlined,
                                'Wedding Date',
                                '${weddingDate.day} ${DateFormat.MMMM().format(weddingDate)} ${weddingDate.year}',
                              ),
                            ),                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(10),
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: 
                        _countdownSection(countdownDays)
                  ),
                  const SizedBox(height: 15),
                  StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                    stream: guidelinesStream,
                    builder: (context, guidelineSnapshot) {
                      if (guidelineSnapshot.connectionState == ConnectionState.waiting) {
                        return _buildCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text('Overview', style: TextStyle(color: Color(0xFF4A4A4A), fontSize: 14, fontWeight: FontWeight.bold, fontFamily: 'Inter')),
                              SizedBox(height: 10),
                              Text('Loading guidelines...', style: TextStyle(color: Color(0xFF4A4A4A), fontSize: 12, fontWeight: FontWeight.w600, fontFamily: 'Inter')),
                            ],
                          ),
                        );
                      }

                      if (guidelineSnapshot.hasError) {
                        return _buildCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text('Overview', style: TextStyle(color: Color(0xFF4A4A4A), fontSize: 14, fontWeight: FontWeight.bold, fontFamily: 'Inter')),
                              SizedBox(height: 10),
                              Text('Unable to load guidelines right now.', style: TextStyle(color: Color(0xFF4A4A4A), fontSize: 12, fontWeight: FontWeight.w600, fontFamily: 'Inter')),
                            ],
                          ),
                        );
                      }
                      final guidelineData = guidelineSnapshot.data?.data() ?? <String, dynamic>{};
                      if (guidelineSnapshot.data?.exists != true) {
                        return _buildCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text('Overview', style: TextStyle(color: Color(0xFF4A4A4A), fontSize: 14, fontWeight: FontWeight.bold, fontFamily: 'Inter')),
                              SizedBox(height: 10),
                              Text('Guidelines not found for this state.', style: TextStyle(color: Color(0xFF4A4A4A), fontSize: 12, fontWeight: FontWeight.w600, fontFamily: 'Inter')),
                            ],
                          ),
                        );
                      }
                      final double? masKahwin = _parseGuidelinesNumber(guidelineData['mas_kahwin']);
                      final double? fees = _parseGuidelinesNumber(guidelineData['fees']);
                      final String portal = _formatGuidelinesText(guidelineData['portal']);
                      final String system = _formatGuidelinesText(guidelineData['system']);
                      final String uniqueFeature = _formatGuidelinesText(guidelineData['unique_feature'], fallback: '');
                      
                      debugPrint('Fetching guidelines: "$guidelineData"');
                      return _buildCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('OVERVIEW', style: TextStyle(color: Color(0xFF4A4A4A), fontSize: 14, fontWeight: FontWeight.bold, fontFamily: 'Inter')),
                            const SizedBox(height: 7),
                            _guidelineText('System', 'For $stateId, the system used is $system.'),
                            if (uniqueFeature.isNotEmpty) ...[
                              const SizedBox(height: 6),
                              _guidelineText('Unique Feature of $system', 'Unique Feature of the $stateId System, $system is that it has ${uniqueFeature.toLowerCase()}.'),
                            ],
                            const SizedBox(height: 6),
                            _guidelineText('Portal', 'The official portal for $system that is used to submit the related documents in $stateId is $portal.'),
                            const SizedBox(height: 6),
                            //_guidelineText('Mas Kahwin (Marriage)', 
                            if (masKahwin == 0) ...[
                              _guidelineText('Mas Kahwin (Marriage)', 'Mas kahwin for $stateId state has no fixed rate and is determined by the agreement of both parties.')
                            ] else if (masKahwin != null) ...[
                              _guidelineText('Mas Kahwin (Marriage)', 'The minimum Mas Kahwin for $stateId is RM${masKahwin.toStringAsFixed(2)}.')
                            ] else ...[
                              _guidelineText('Mas Kahwin (Marriage)', 'Mas kahwin for $stateId state has no fixed rate and is determined by the agreement of both parties.')
                            ],
                            const SizedBox(height: 6),
                            _guidelineText('Official Fees (Jurunikah & Saksi)', fees != null ? 'Total Official Fees (Jurunikah & Saksi) for $stateId is ranging from RM${fees.toStringAsFixed(2)}.' : 'Official fees (Jurunikah & Saksi) are not specified for $stateId.'),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              )
            ],
          );
        },
      ),
    );
  }

  Widget _guidelineText(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.info_outline, color: Color(0xFF4A4A4A), size: 18),
            const SizedBox(width: 8),
            Text(title, style: const TextStyle(color: Color(0xFF4A4A4A), fontSize: 14, fontWeight: FontWeight.bold, fontFamily: 'Inter')),
          ],
        ),
        const SizedBox(height: 2),
        Text(subtitle, style: const TextStyle(color: Color(0xFF4A4A4A), fontSize: 12, fontWeight: FontWeight.w600, fontFamily: 'Inter')),
      ],
    );
  }

  Widget _buildProfile({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.symmetric(horizontal: 20),
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFEBBABA),
        borderRadius: BorderRadius.circular(30), // Matching the high corner radius [1]
      ),
      child: child,
    );
  }

  Widget _countdownSection(int countdownDays) {
    final String countdownText = countdownDays > 1
        ? '$countdownDays days left'
        : countdownDays == 1
            ? '1 day left'
            : countdownDays == 0
                ? 'Wedding day is today'
                : 'Wedding date has passed';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white24,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          const Icon(Icons.hourglass_bottom, color: Color(0xFFEBBABA), size: 30),
          const SizedBox(width: 8),
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  'Wedding Countdown',
                  style: TextStyle(
                    color: Color(0xFFEBBABA),
                    fontWeight: FontWeight.w900,
                    fontSize: 20,
                    fontFamily: 'Inter',
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  countdownText,
                  style: const TextStyle(
                    color: Color(0xFF4A4A4A),
                    fontWeight: FontWeight.w900,
                    fontSize: 20,
                    fontFamily: 'Inter',
                  ),
                ),
              ],
            ),
          const SizedBox(height: 4)
        ],
      ),
    );
  }

  Widget _buildCard({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.symmetric(horizontal: 20),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30), // Matching the high corner radius [1]
      ),
      child: child,
    );
  }
  
  

  Widget _infoPill(IconData icon, String title, String subtitle) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white24,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.white, size: 16),
              const SizedBox(width: 6),
              Expanded(
                child: Text(title, style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.w500, fontSize: 12, fontFamily: 'Inter')),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(subtitle, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 14, fontFamily: 'Inter')),
        ],
      ),
    );
  }
}