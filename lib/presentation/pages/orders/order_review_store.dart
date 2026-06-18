import 'package:zayrova/core/utils/local_storage.dart';

class StoredOrderReview {
  const StoredOrderReview({
    required this.orderId,
    required this.rating,
    required this.review,
    required this.submittedAt,
  });

  final String orderId;
  final int rating;
  final String review;
  final DateTime submittedAt;

  Map<String, dynamic> toJson() {
    return {
      'orderId': orderId,
      'rating': rating,
      'review': review,
      'submittedAt': submittedAt.toIso8601String(),
    };
  }

  static StoredOrderReview? fromJson(Map data) {
    final orderId = data['orderId'];
    final rating = data['rating'];
    final review = data['review'];
    final submittedAt = DateTime.tryParse(data['submittedAt']?.toString() ?? '');

    if (orderId is! String || rating is! int || review is! String) {
      return null;
    }

    return StoredOrderReview(
      orderId: orderId,
      rating: rating,
      review: review,
      submittedAt: submittedAt ?? DateTime.now(),
    );
  }
}

// Temporary local/session review persistence until a real reviews endpoint is
// available. Keep review storage isolated here so the future backend swap does
// not leak into order UI screens.
class OrderReviewStore {
  static const String _storageKey = 'zayrova_order_reviews';

  static Future<StoredOrderReview?> getReview(String orderId) async {
    final reviews = await _readReviews();
    final stored = reviews[orderId];

    if (stored is Map) {
      return StoredOrderReview.fromJson(stored);
    }

    return null;
  }

  static Future<void> saveReview(StoredOrderReview review) async {
    final reviews = await _readReviews();
    reviews[review.orderId] = review.toJson();
    await LocalStorage.set(_storageKey, reviews);
  }

  static Future<Map<String, dynamic>> _readReviews() async {
    final stored = await LocalStorage.get(_storageKey, Map);
    if (stored is Map) {
      return Map<String, dynamic>.from(stored);
    }

    return <String, dynamic>{};
  }
}
