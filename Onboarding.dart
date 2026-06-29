import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
//import 'package:my_app/homepage.dart';
import 'package:my_app/mainNavPage.dart';
//import 'package:my_app/timelineviewscreen.dart';

// Shared App Palette
class AppColors {
  static const Color creamBg = Color(0xFFFFF9E5);
  static const Color primaryPink = Color(0xFFE5B6B6);
  static const Color deepPink = Color(0xFFBA8B8B);
  static const Color textDark = Color(0xFF5C4646);
  static const Color white = Colors.white;
}

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  String? _selectedState;
  String _selectedRole = 'Groom'; // Default role selection
  DateTime? _selectedDate;
  final TextEditingController _dateController = TextEditingController();
  bool _isSaving = false;

  final List<String> _malaysianStates = [
    'Selangor', 'Kuala Lumpur', 'Johor', 'Penang', 'Perak', 'Kedah', 
    'Melaka', 'Negeri Sembilan', 'Pahang', 'Kelantan', 'Terengganu', 'Perlis', 'Sabah', 'Sarawak'
  ];

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 180)),
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.deepPink,
              onPrimary: Colors.white,
              surface: AppColors.creamBg,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _dateController.text = "${picked.day}/${picked.month}/${picked.year}";
      });
    }
  }

  @override
  void dispose() {
    _dateController.dispose();
    super.dispose();
  }

  Future<void> _saveUserOnboarding() async {
    final User? user = FirebaseAuth.instance.currentUser;
    final String? uid = user?.uid;
    final String? name = user?.displayName?.trim();

    if (uid == null || uid.isEmpty) {
      throw Exception('Missing user account. Please log in again.');
    }

    await FirebaseFirestore.instance.collection('Users').doc(uid).set({
      'name': name,
      'state': _selectedState,
      'role': _selectedRole,
      'nikahDate': Timestamp.fromDate(_selectedDate!),
      'updatedAt': FieldValue.serverTimestamp(),
      'uid': uid,
    }, SetOptions(merge: true));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                "Let's get to know you",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: AppColors.deepPink),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) => Row(
                  children: [
                    if (index < 4) Container(width: 40, height: 2, color: AppColors.primaryPink.withValues(alpha: 0.4)),
                  ],
                )),
              ),
              const SizedBox(height: 40),
              const Text("What is your state?", style: TextStyle(fontSize: 16, color: AppColors.deepPink)),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                initialValue: _selectedState,
                hint: const Text("Select State"),
                decoration: _inputDecoration(),
                items: _malaysianStates.map((state) => DropdownMenuItem(value: state, child: Text(state))).toList(),
                onChanged: (val) => setState(() => _selectedState = val),
              ),
              const SizedBox(height: 24),
              const Text("What is your role?", style: TextStyle(fontSize: 16, color: AppColors.deepPink)),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(child: _buildRoleButton('Groom')),
                  const SizedBox(width: 16),
                  Expanded(child: _buildRoleButton('Bride')),
                ],
              ),
              const SizedBox(height: 24),
              const Text("Date of nikah (tentative)", style: TextStyle(fontSize: 16, color: AppColors.deepPink)),
              const SizedBox(height: 8),
              TextField(
                controller: _dateController,
                readOnly: true,
                onTap: () => _selectDate(context),
                decoration: _inputDecoration().copyWith(
                  hintText: "dd/mm/yyyy",
                  suffixIcon: const Icon(Icons.calendar_today, color: AppColors.deepPink),
                ),
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: (_selectedState != null && _selectedDate != null && !_isSaving)
                    ? () async {
                        setState(() {
                          _isSaving = true;
                        });

                        try {
                          await _saveUserOnboarding();
                          if (!context.mounted) {
                            return;
                          }

                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const MainNavigationScreen(),
                            ),
                          );
                        } catch (error) {
                          if (!context.mounted) {
                            return;
                          }

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(error.toString().replaceFirst('Exception: ', ''))),
                          );
                        } finally {
                          if (mounted) {
                            setState(() {
                              _isSaving = false;
                            });
                          }
                        }
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.deepPink,
                  disabledBackgroundColor: AppColors.deepPink.withValues(alpha: 0.5),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                ),
                child: _isSaving
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text("Next", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoleButton(String role) {
    bool isSelected = _selectedRole == role;
    return OutlinedButton(
      onPressed: () => setState(() => _selectedRole = role),
      style: OutlinedButton.styleFrom(
        backgroundColor: isSelected ? AppColors.deepPink : Colors.transparent,
        side: const BorderSide(color: AppColors.deepPink),
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      ),
      child: Text(role, style: TextStyle(color: isSelected ? Colors.white : AppColors.deepPink)),
    );
  }

  InputDecoration _inputDecoration() {
    return const InputDecoration(
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: AppColors.deepPink)),
      focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: AppColors.deepPink, width: 2)),
    );
  }
}