import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/firebase_providers.dart';

/// Repository for managing parent link data in Firebase.
class ParentLinkRepository {
  final DatabaseReference _dbRef;

  ParentLinkRepository(this._dbRef);

  /// Saves a snapshot of student data to the database, accessible via [accessCode].
  /// 
  /// This allows parents to view the data without needing a full account or 
  /// specific card configurations.
  Future<void> saveParentView(String accessCode, Map<String, dynamic> data) async {
    try {
      await _dbRef.child('parent_views').child(accessCode).set({
        ...data,
        'lastUpdated': ServerValue.timestamp,
      });
    } catch (e) {
      throw Exception('Failed to save parent view: $e');
    }
  }

  /// Retrieves student data using the provided [accessCode].
  Future<DataSnapshot> getParentView(String accessCode) async {
    return await _dbRef.child('parent_views').child(accessCode).get();
  }
}

/// Provider for the [ParentLinkRepository].
final parentLinkRepositoryProvider = Provider<ParentLinkRepository>((ref) {
  final dbRef = ref.watch(databaseReferenceProvider);
  return ParentLinkRepository(dbRef);
});
