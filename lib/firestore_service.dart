import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Fetch articles
  Future<List<Map<String, dynamic>>> getArticles() async {
    final snapshot = await _firestore.collection('articles').get();
    return snapshot.docs.map((doc) => doc.data()).toList();
  }

  // Save user references
  Future<void> saveReference(String userId, Map<String, dynamic> reference) async {
    await _firestore.collection('users').doc(userId).collection('references').add(reference);
  }

  // Fetch user references
  Future<List<Map<String, dynamic>>> getReferences(String userId) async {
    final snapshot = await _firestore.collection('users').doc(userId).collection('references').get();
    return snapshot.docs.map((doc) => doc.data()).toList();
  }
}
