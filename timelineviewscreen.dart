import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'TimelineEngine.dart';
import 'package:my_app/task_card.dart';
import 'package:my_app/firestore_service.dart';

class TimelineViewScreen extends StatefulWidget {
  const TimelineViewScreen({super.key});

  @override
  State<TimelineViewScreen> createState() => _TimelineViewScreenState();
}

class _TimelineViewScreenState extends State<TimelineViewScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  List<WeddingTask> _activeTimeline = [];
  bool _isLoading = true;
  String? _loadError;

  @override
  void initState() {
    super.initState();
    _loadTimelineData();
  }

  Future<void> _loadTimelineData() async {
    try {
      final User? user = FirebaseAuth.instance.currentUser;
      final String? uid = user?.uid;

      if (uid == null || uid.isEmpty) {
        throw Exception('Missing user account. Please log in again.');
      }

      final snapshot =
          await FirebaseFirestore.instance.collection('Users').doc(uid).get();

      if (!snapshot.exists) {
        throw Exception('No onboarding data found. Please complete onboarding first.');
      }

      final data = snapshot.data();
      if (data == null) {
        throw Exception('User data is empty. Please complete onboarding again.');
      }

      final Timestamp? nikahDateTimestamp = data['nikahDate'] as Timestamp?;
      final String? state = data['state'] as String?;
      final String role = (data['role'] as String?) ?? 'Groom';

      if (nikahDateTimestamp == null || state == null || state.isEmpty) {
        throw Exception('Incomplete onboarding data. Please complete onboarding again.');
      }

      final generatedTasks = TimelineEngine.generateTimeline(
        nikahDate: nikahDateTimestamp.toDate(),
        state: state,
        role: role,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _activeTimeline = generatedTasks;
        _isLoading = false;
        _loadError = null;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isLoading = false;
        _loadError = error.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF6E9),
      appBar: AppBar(
        backgroundColor: const Color(0xFFE5B6B6),
        elevation: 0,
        title: const Text('Timeline & Collaboration', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFBA8B8B)))
          : _loadError != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Text(
                      _loadError!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Color(0xFF5C4646),
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                )
          : SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _activeTimeline.length,
                      itemBuilder: (context, index) {
                        final task = _activeTimeline[index];
                        return IntrinsicHeight(
                          child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: 24,
                              child: Column(
                                children: [
                                  Container(
                                    width: 14,
                                    height: 14,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: const Color(0xFFBA8B8B),
                                        width: 2,
                                      ),
                                    ),
                                  ),

                                  if (index != _activeTimeline.length - 1)
                                    Expanded(
                                      child: Container(
                                        width: 2,
                                        color: const Color(0xFFBA8B8B).withOpacity(0.4),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: TaskCard(
                                task: task,
                                firestoreService:  _firestoreService,
                              ),
                            ),
                          ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}