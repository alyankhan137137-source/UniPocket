// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transaction_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$transactionRepositoryHash() =>
    r'c4d60ca65448430bd6b135bfc57b7862eb6458a8';

/// See also [transactionRepository].
@ProviderFor(transactionRepository)
final transactionRepositoryProvider =
    AutoDisposeProvider<TransactionRepository>.internal(
  transactionRepository,
  name: r'transactionRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$transactionRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef TransactionRepositoryRef
    = AutoDisposeProviderRef<TransactionRepository>;
String _$transactionNotifierHash() =>
    r'f1913776d4df049643b01bc2d5545d43e13d12d5';

/// See also [TransactionNotifier].
@ProviderFor(TransactionNotifier)
final transactionNotifierProvider = AutoDisposeAsyncNotifierProvider<
    TransactionNotifier, List<Expense>>.internal(
  TransactionNotifier.new,
  name: r'transactionNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$transactionNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$TransactionNotifier = AutoDisposeAsyncNotifier<List<Expense>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
