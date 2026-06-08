import 'package:freezed_annotation/freezed_annotation.dart';

part 'registry_models.freezed.dart';
part 'registry_models.g.dart';

@freezed
abstract class RegistryItem with _$RegistryItem {
  const factory RegistryItem({
    required String id,
    required String title,
    String? description,
    double? price,
    String? url,
    String? imageUrl,
    String? category,
    @Default(false) bool isClaimed,
    String? claimedByName,
    @Default(false) bool thankYouSent,
    @Default(0) int sortOrder,
  }) = _RegistryItem;

  factory RegistryItem.fromJson(Map<String, dynamic> json) =>
      _$RegistryItemFromJson(json);
}

@freezed
abstract class RegistryCashFund with _$RegistryCashFund {
  const factory RegistryCashFund({
    required String id,
    @Default('Our Honeymoon Fund') String title,
    String? description,
    double? targetAmount,
    @Default(false) bool isActive,
    String? shareToken,
  }) = _RegistryCashFund;

  factory RegistryCashFund.fromJson(Map<String, dynamic> json) =>
      _$RegistryCashFundFromJson(json);
}

@freezed
abstract class RegistrySummary with _$RegistrySummary {
  const factory RegistrySummary({
    @Default(0) int totalItems,
    @Default(0) int claimed,
    @Default(0) int unclaimed,
    @Default(0) int thankYousPending,
    @Default(0.0) double totalValue,
    @Default(0.0) double claimedValue,
  }) = _RegistrySummary;

  factory RegistrySummary.fromJson(Map<String, dynamic> json) =>
      _$RegistrySummaryFromJson(json);
}
