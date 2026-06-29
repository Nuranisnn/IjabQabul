import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:my_app/login_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String _name = '';
  String _email = '';
  String _state = '';
  String _weddingDate = '';

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final user = FirebaseAuth.instance.currentUser;

      if (user == null) return;

      final doc = await FirebaseFirestore.instance
          .collection('Users')
          .doc(user.uid)
          .get();

      if (doc.exists) {
        final data = doc.data()!;

        final Timestamp nikahTimestamp = data['nikahDate'];

        setState(() {
          _name = data['name'] ?? '';
          _email = user.email ?? '';
          _state = data['state'] ?? '';

          _weddingDate =
              DateFormat('dd MMMM yyyy').format(nikahTimestamp.toDate());

          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint(e.toString());

      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      physics: const ClampingScrollPhysics(),
      child: Column(
        children: [
          _buildCard(
            child: Column(
              children: [
                const SizedBox(height: 15),

                Stack(
                  alignment: Alignment.center,
                  children: [
                    Transform.translate(
                      offset: const Offset(-22, 0),
                      child: const CircleAvatar(
                        radius: 34,
                        backgroundColor: Color(0xFFEBBABA),
                      ),
                    ),
                    Transform.translate(
                      offset: const Offset(22, 0),
                      child: const CircleAvatar(
                        radius: 34,
                        backgroundColor: Color(0xFFC49E9E),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 18),

                Text(
                  _name,
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF4A4A4A),
                    fontFamily: 'Serif',
                  ),
                ),

                const SizedBox(height: 6),

                Text(
                  'Wedding • $_weddingDate',
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 15,
                  ),
                ),

                const SizedBox(height: 15),
              ],
            ),
          ),

          const SizedBox(height: 20),

          _buildCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Account Information',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Serif',
                  ),
                ),

                const SizedBox(height: 15),

                _buildContactItem(
                  Icons.email_outlined,
                  'Email',
                  _email,
                ),

                _buildContactItem(
                  Icons.location_on_outlined,
                  'Location',
                  _state,
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          _buildMenuItem(
            Icons.settings_outlined,
            'Settings',
          ),

          const SizedBox(height: 20),

          _buildCard(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.logout,
                  color: Color(0xFFEBBABA),
                ),

                const SizedBox(width: 10),

                TextButton(
                  onPressed: () async {
                    await FirebaseAuth.instance.signOut();

                    if (!context.mounted) return;

                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                        builder: (_) => const LoginPage(),
                      ),
                      (route) => false,
                    );
                  },
                  child: const Text(
                    'Log Out',
                    style: TextStyle(
                      color: Color(0xFFEBBABA),
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 25),

          const Text(
            'IjabQabul v1.0',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 12,
            ),
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

 Widget _buildCard({required Widget child}) {
  return Container(
    width: double.infinity,
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(30),
    ),
    child: child,
  );
}
  Widget _buildContactItem(
      IconData icon,
      String label,
      String value,
      ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Icon(
            icon,
            color: const Color(0xFFEBBABA),
            size: 24,
          ),

          const SizedBox(width: 18),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: Color(0xFFEBBABA),
                    fontSize: 12,
                  ),
                ),

                const SizedBox(height: 3),

                Text(
                  value,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    color: Color(0xFF4A4A4A),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(
      IconData icon,
      String title,
      {String? badge}
      ) {
    return _buildCard(
      child: Row(
        children: [
          Icon(
            icon,
            color: Colors.grey.shade500,
            size: 24,
          ),

          const SizedBox(width: 18),

          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF4A4A4A),
            ),
          ),

          const Spacer(),

          if (badge != null)
            CircleAvatar(
              radius: 12,
              backgroundColor: const Color(0xFFEBBABA),
              child: Text(
                badge,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                ),
              ),
            )
          else
            const Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Colors.grey,
            ),
        ],
      ),
    );
  }
}