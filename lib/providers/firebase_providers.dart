import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider for the Firebase Realtime Database instance.
final firebaseDatabaseProvider = Provider<FirebaseDatabase>((ref) {
  return FirebaseDatabase.instance;
});

/// Provider for a DatabaseReference to the root of the database.
final databaseReferenceProvider = Provider<DatabaseReference>((ref) {
  return ref.watch(firebaseDatabaseProvider).ref();
});
