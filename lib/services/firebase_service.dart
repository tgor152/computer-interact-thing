import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/mouse_event.dart';

class FirebaseService {
  User? get user => FirebaseAuth.instance.currentUser;
  bool _isSigningIn = false;
  
  bool get isSigningIn => _isSigningIn;
  
  Future<User?> signInAnonymously() async {
    _isSigningIn = true;
    try {
      final userCred = await FirebaseAuth.instance.signInAnonymously();
      _isSigningIn = false;
      return userCred.user;
    } catch (e) {
      _isSigningIn = false;
      rethrow;
    }
  }
  
  Future<void> uploadEventsToFirestore(List<MouseEvent> events) async {
    if (user == null) return;
    
    final batch = FirebaseFirestore.instance.batch();
    final userEvents = FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        .collection('mouse_events');
        
    for (final e in events) {
      final doc = userEvents.doc();
      batch.set(doc, {
        'timestamp': e.timestamp.toIso8601String(),
        'x': e.x,
        'y': e.y,
        'type': e.type,
      });
    }
    await batch.commit();
  }
}