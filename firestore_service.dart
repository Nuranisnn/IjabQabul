import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'CustomSubTask.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Returns the current user's custom_subtasks collection.
  CollectionReference<Map<String, dynamic>> get _subTaskCollection {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception("User not logged in.");
    }

    return _firestore
        .collection('Users')
        .doc(user.uid)
        .collection('custom_subtasks');
  }

  Future<void> addSubTask(CustomSubTask subTask) async {
    await _subTaskCollection.add(subTask.toMap());
  }

  Future<List<CustomSubTask>> getSubTasks(String parentTaskId) async {
    final snapshot = await _subTaskCollection
      .where('parentTaskId', isEqualTo: parentTaskId)
      .get();

    return snapshot.docs.map((doc) {
      return CustomSubTask.fromMap(
        doc.id,
        doc.data(),
      );
    }).toList();

  }

  Future<void> updateSubTask(CustomSubTask subTask) async {
    await _subTaskCollection.doc(subTask.id).update(subTask.toMap());
  }

  Future<void> deleteSubTask(String id) async {
    await _subTaskCollection.doc(id).delete();
  }
}