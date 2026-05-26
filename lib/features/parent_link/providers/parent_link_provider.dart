import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/student_snapshot_model.dart';
import '../services/cloud_sync_service.dart';

/// State for the ParentLink sync process.
class ParentLinkState {
  final bool isSyncing;
  final String? error;
  final bool lastSyncSuccessful;

  ParentLinkState({
    this.isSyncing = false,
    this.error,
    this.lastSyncSuccessful = false,
  });

  ParentLinkState copyWith({
    bool? isSyncing,
    String? error,
    bool? lastSyncSuccessful,
  }) {
    return ParentLinkState(
      isSyncing: isSyncing ?? this.isSyncing,
      error: error,
      lastSyncSuccessful: lastSyncSuccessful ?? this.lastSyncSuccessful,
    );
  }
}

/// Notifier to manage syncing data to the Parent View.
class ParentLinkNotifier extends StateNotifier<ParentLinkState> {
  ParentLinkNotifier() : super(ParentLinkState());

  /// Syncs the current local data to Firebase for the given [accessCode].
  Future<void> syncDataToParent(String accessCode, StudentSnapshot snapshot) async {
    state = state.copyWith(isSyncing: true, error: null);
    
    try {
      await CloudSyncService.instance.syncSnapshot(snapshot, accessCode);
      state = state.copyWith(isSyncing: false, lastSyncSuccessful: true);
    } catch (e) {
      state = state.copyWith(isSyncing: false, error: e.toString(), lastSyncSuccessful: false);
    }
  }
}

/// Provider for the [ParentLinkNotifier].
final parentLinkNotifierProvider = StateNotifierProvider<ParentLinkNotifier, ParentLinkState>((ref) {
  return ParentLinkNotifier();
});

/// FutureProvider to fetch parent view data by access code.
final parentViewDataProvider = FutureProvider.family<StudentSnapshot?, String>((ref, accessCode) async {
  return await CloudSyncService.instance.fetchSnapshot(accessCode);
});
