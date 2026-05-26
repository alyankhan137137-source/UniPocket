import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import '../models/student_snapshot_model.dart';
import '../../../core/security/rate_limiter.dart';

class CloudSyncService {
  final FirebaseDatabase _db = FirebaseDatabase.instance;
  static const String _node = 'parent_views';

  // Singleton pattern
  CloudSyncService._internal();
  static final CloudSyncService instance = CloudSyncService._internal();

  Future<void> syncSnapshot(StudentSnapshot snapshot, String accessCode) async {
    if (AppRateLimiters.cloudSyncLimiter.isLimited('sync_$accessCode')) {
      debugPrint('Sync rate limited for accessCode: $accessCode');
      return;
    }

    try {
      final data = snapshot.toMap();
      // Realtime Database uses ServerValue.timestamp for server-side time
      data['syncedAt'] = ServerValue.timestamp;
      
      await _db.ref(_node).child(accessCode).set(data);
    } catch (e) {
      debugPrint('Error syncing snapshot to RTDB: $e');
      rethrow; // Rethrow to handle in UI
    }
  }

  Future<StudentSnapshot?> fetchSnapshot(String accessCode) async {
    if (AppRateLimiters.cloudSyncLimiter.isLimited('fetch_$accessCode')) {
      throw Exception("Too many requests. Please wait a moment.");
    }
    try {
      final event = await _db.ref(_node).child(accessCode).once();
      final data = event.snapshot.value;
      
      if (data == null) {
        return null;
      }

      // Realtime Database returns data as Map<Object?, Object?>
      final Map<String, dynamic> convertedData = Map<String, dynamic>.from(
        (data as Map).map(
          (key, value) => MapEntry(key.toString(), value),
        ),
      );

      return StudentSnapshot.fromMap(convertedData);
    } catch (e) {
      debugPrint('Error fetching snapshot from RTDB: $e');
      rethrow;
    }
  }

  Future<void> deleteSnapshot(String accessCode) async {
    try {
      await _db.ref(_node).child(accessCode).remove();
    } catch (e) {
      debugPrint('Error deleting snapshot from RTDB: $e');
    }
  }
}
