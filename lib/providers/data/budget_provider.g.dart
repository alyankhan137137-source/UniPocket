// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'budget_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$budgetRepositoryHash() => r'8f8123ca8429664b3d0d91c5df10130d36e6d04d';

/// See also [budgetRepository].
@ProviderFor(budgetRepository)
final budgetRepositoryProvider = AutoDisposeProvider<BudgetRepository>.internal(
  budgetRepository,
  name: r'budgetRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$budgetRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef BudgetRepositoryRef = AutoDisposeProviderRef<BudgetRepository>;
String _$budgetNotifierHash() => r'bbdf8f56c6d280d26a30987250919594e78291b4';

/// See also [BudgetNotifier].
@ProviderFor(BudgetNotifier)
final budgetNotifierProvider =
    AutoDisposeAsyncNotifierProvider<BudgetNotifier, List<Budget>>.internal(
  BudgetNotifier.new,
  name: r'budgetNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$budgetNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$BudgetNotifier = AutoDisposeAsyncNotifier<List<Budget>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
