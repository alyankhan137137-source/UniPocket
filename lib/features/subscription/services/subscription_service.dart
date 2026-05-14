import 'dart:async';
import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Service responsible for managing the "Parent Plus" subscription lifecycle.
class SubscriptionService {
  static final SubscriptionService _instance = SubscriptionService._internal();
  factory SubscriptionService() => _instance;
  SubscriptionService._internal();

  static const String productId = 'parent_plus_monthly';
  static const String _tierKey = 'pt_subscription_tier';
  static const String _expiryKey = 'pt_subscription_expiry';

  final InAppPurchase _iap = InAppPurchase.instance;

  /// Returns true if the user has an active "Parent Plus" subscription that hasn't expired.
  Future<bool> get isParentPlus async {
    final prefs = await SharedPreferences.getInstance();
    final tier = prefs.getString(_tierKey) ?? 'free';
    final expiryStr = prefs.getString(_expiryKey);

    if (tier != 'parent_plus' || expiryStr == null) return false;

    final expiry = DateTime.tryParse(expiryStr);
    if (expiry == null) return false;

    return expiry.isAfter(DateTime.now());
  }

  /// Activates the subscription by saving the tier and expiry date.
  Future<void> activateSubscription(String expiresAt) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tierKey, 'parent_plus');
    await prefs.setString(_expiryKey, expiresAt);
  }

  /// Reverts the user to the free tier.
  Future<void> cancelSubscription() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tierKey, 'free');
    await prefs.remove(_expiryKey);
  }

  /// Initiates the purchase process for the "Parent Plus" tier.
  Future<bool> purchaseParentPlus(BuildContext context) async {
    final bool available = await _iap.isAvailable();
    if (!available) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Store is currently unavailable')),
        );
      }
      return false;
    }

    const Set<String> ids = {productId};
    final ProductDetailsResponse response = await _iap.queryProductDetails(ids);

    if (response.error != null || response.productDetails.isEmpty) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Product not found: ${response.error?.message}')),
        );
      }
      return false;
    }

    final ProductDetails productDetails = response.productDetails.first;
    final PurchaseParam purchaseParam = PurchaseParam(productDetails: productDetails);

    try {
      // For subscriptions, we usually use buyNonConsumable or buyConsumable depending on logic.
      // Here we assume non-consumable subscription logic.
      final bool success = await _iap.buyNonConsumable(purchaseParam: purchaseParam);
      
      if (!success) return false;

      // Note: In a production app, you should listen to the purchase stream globally.
      // This is a simplified version for the prototype.
      final Completer<bool> completer = Completer<bool>();
      
      late StreamSubscription<List<PurchaseDetails>> subscription;
      subscription = _iap.purchaseStream.listen((purchaseDetailsList) {
        for (var purchase in purchaseDetailsList) {
          if (purchase.productID == productId) {
            if (purchase.status == PurchaseStatus.purchased) {
              final expiryDate = DateTime.now().add(const Duration(days: 30)).toIso8601String();
              activateSubscription(expiryDate);
              
              if (purchase.pendingCompletePurchase) {
                _iap.completePurchase(purchase);
              }
              
              subscription.cancel();
              completer.complete(true);
            } else if (purchase.status == PurchaseStatus.error) {
              subscription.cancel();
              completer.complete(false);
            }
          }
        }
      }, onError: (error) {
        subscription.cancel();
        completer.complete(false);
      });

      return await completer.future;
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Purchase failed: $e')),
        );
      }
      return false;
    }
  }
}
