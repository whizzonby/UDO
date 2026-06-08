// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'registry_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_RegistryItem _$RegistryItemFromJson(Map<String, dynamic> json) =>
    _RegistryItem(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      price: (json['price'] as num?)?.toDouble(),
      url: json['url'] as String?,
      imageUrl: json['imageUrl'] as String?,
      category: json['category'] as String?,
      isClaimed: json['isClaimed'] as bool? ?? false,
      claimedByName: json['claimedByName'] as String?,
      thankYouSent: json['thankYouSent'] as bool? ?? false,
      sortOrder: (json['sortOrder'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$RegistryItemToJson(_RegistryItem instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'price': instance.price,
      'url': instance.url,
      'imageUrl': instance.imageUrl,
      'category': instance.category,
      'isClaimed': instance.isClaimed,
      'claimedByName': instance.claimedByName,
      'thankYouSent': instance.thankYouSent,
      'sortOrder': instance.sortOrder,
    };

_RegistryCashFund _$RegistryCashFundFromJson(Map<String, dynamic> json) =>
    _RegistryCashFund(
      id: json['id'] as String,
      title: json['title'] as String? ?? 'Our Honeymoon Fund',
      description: json['description'] as String?,
      targetAmount: (json['targetAmount'] as num?)?.toDouble(),
      isActive: json['isActive'] as bool? ?? false,
      shareToken: json['shareToken'] as String?,
    );

Map<String, dynamic> _$RegistryCashFundToJson(_RegistryCashFund instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'targetAmount': instance.targetAmount,
      'isActive': instance.isActive,
      'shareToken': instance.shareToken,
    };

_RegistrySummary _$RegistrySummaryFromJson(Map<String, dynamic> json) =>
    _RegistrySummary(
      totalItems: (json['totalItems'] as num?)?.toInt() ?? 0,
      claimed: (json['claimed'] as num?)?.toInt() ?? 0,
      unclaimed: (json['unclaimed'] as num?)?.toInt() ?? 0,
      thankYousPending: (json['thankYousPending'] as num?)?.toInt() ?? 0,
      totalValue: (json['totalValue'] as num?)?.toDouble() ?? 0.0,
      claimedValue: (json['claimedValue'] as num?)?.toDouble() ?? 0.0,
    );

Map<String, dynamic> _$RegistrySummaryToJson(_RegistrySummary instance) =>
    <String, dynamic>{
      'totalItems': instance.totalItems,
      'claimed': instance.claimed,
      'unclaimed': instance.unclaimed,
      'thankYousPending': instance.thankYousPending,
      'totalValue': instance.totalValue,
      'claimedValue': instance.claimedValue,
    };
