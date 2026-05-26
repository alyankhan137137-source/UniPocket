import 'dart:collection';

/// A simple in-memory rate limiter to mitigate brute-force or spam attacks.
class RateLimiter {
  final int maxRequests;
  final Duration window;
  final Map<String, Queue<DateTime>> _requests = {};

  RateLimiter({this.maxRequests = 5, this.window = const Duration(minutes: 1)});

  /// Checks if the [key] (e.g., action type or user ID) is rate-limited.
  bool isLimited(String key) {
    final now = DateTime.now();
    _requests.putIfAbsent(key, () => Queue<DateTime>());
    
    final queue = _requests[key]!;

    // Remove expired timestamps
    while (queue.isNotEmpty && now.difference(queue.first) > window) {
      queue.removeFirst();
    }

    if (queue.length >= maxRequests) {
      return true;
    }

    queue.addLast(now);
    return false;
  }

  /// Clears the rate limit for a specific key (e.g., after successful verification).
  void reset(String key) {
    _requests.remove(key);
  }
}

/// Global rate limiters for specific app actions.
class AppRateLimiters {
  static final pinAttemptLimiter = RateLimiter(maxRequests: 5, window: const Duration(minutes: 5));
  static final cloudSyncLimiter = RateLimiter(maxRequests: 3, window: const Duration(minutes: 1));
}
