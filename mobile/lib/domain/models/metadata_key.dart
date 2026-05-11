import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:immich_mobile/constants/colors.dart';
import 'package:immich_mobile/constants/enums.dart';
import 'package:immich_mobile/domain/models/config/app_config.dart';
import 'package:immich_mobile/domain/models/config/system_config.dart';
import 'package:immich_mobile/domain/models/log.model.dart';
import 'package:immich_mobile/domain/models/timeline.model.dart';
import 'package:immich_mobile/providers/album/album_sort_by_options.provider.dart';

enum MetadataDomain<T extends Object> {
  appConfig<AppConfig>('config.app'),
  systemConfig<SystemConfig>('config.system');

  final String prefix;
  const MetadataDomain(this.prefix);
}

enum MetadataKey<T extends Object> {
  // Theme
  themePrimaryColor<ImmichColorPreset>(.appConfig, .indigo, _EnumCodec(ImmichColorPreset.values)),
  themeMode<ThemeMode>(.appConfig, .system, _EnumCodec(ThemeMode.values)),
  themeDynamic<bool>(.appConfig, false),
  themeColorfulInterface<bool>(.appConfig, true),

  // Image
  imagePreferRemote<bool>(.appConfig, false),
  imageLoadOriginal<bool>(.appConfig, false),

  // Viewer
  viewerLoopVideo<bool>(.appConfig, true),
  viewerLoadOriginalVideo<bool>(.appConfig, false),
  viewerAutoPlayVideo<bool>(.appConfig, true),
  viewerTapToNavigate<bool>(.appConfig, false),

  // Network
  networkAutoEndpointSwitching<bool>(.systemConfig, false),
  networkPreferredWifiName<String>(.systemConfig, ''),
  networkLocalEndpoint<String>(.systemConfig, ''),
  networkExternalEndpointList<List<String>>(.systemConfig, [], _ListCodec(_PrimitiveCodec.string)),
  networkCustomHeaders<Map<String, String>>(
    .systemConfig,
    {},
    _MapCodec(_PrimitiveCodec.string, _PrimitiveCodec.string),
  ),

  // Album
  albumSortMode<AlbumSortMode>(.appConfig, AlbumSortMode.mostRecent, _EnumCodec(AlbumSortMode.values)),
  albumIsReverse<bool>(.appConfig, true),
  albumIsGrid<bool>(.appConfig, false),

  // Backup
  backupEnabled<bool>(.appConfig, false),
  backupUseCellularForVideos<bool>(.appConfig, false),
  backupUseCellularForPhotos<bool>(.appConfig, false),
  backupRequireCharging<bool>(.appConfig, false),
  backupTriggerDelay<int>(.appConfig, 30),
  backupSyncAlbums<bool>(.appConfig, false),

  // Timeline
  timelineTilesPerRow<int>(.appConfig, 4),
  timelineGroupAssetsBy<GroupAssetsBy>(.appConfig, GroupAssetsBy.day, _EnumCodec(GroupAssetsBy.values)),
  timelineStorageIndicator<bool>(.appConfig, true),

  // Log
  logLevel<LogLevel>(.systemConfig, .info, _EnumCodec(LogLevel.values)),

  // Map
  mapShowFavoriteOnly<bool>(.appConfig, false),
  mapRelativeDate<int>(.appConfig, 0),
  mapIncludeArchived<bool>(.appConfig, false),
  mapThemeMode<ThemeMode>(.appConfig, .system, _EnumCodec(ThemeMode.values)),
  mapWithPartners<bool>(.appConfig, false),

  // Cleanup
  cleanupKeepFavorites<bool>(.appConfig, true),
  cleanupKeepMediaType<AssetKeepType>(.appConfig, AssetKeepType.none, _EnumCodec(AssetKeepType.values)),
  cleanupKeepAlbumIds<List<String>>(.appConfig, [], _ListCodec(_PrimitiveCodec.string)),
  cleanupCutoffDaysAgo<int>(.appConfig, -1),
  cleanupDefaultsInitialized<bool>(.appConfig, false);

  final MetadataDomain domain;
  final T defaultValue;
  final _MetadataCodec<T>? _codecOverride;

  const MetadataKey(this.domain, this.defaultValue, [this._codecOverride]);

  String get key => '${domain.prefix}.$name';

  _MetadataCodec<T> get _codec => _codecOverride ?? _MetadataCodec.forPrimitive(defaultValue);

  String encode(T value) => _codec.encode(value);

  T decode(String raw) => _codec.decode(raw) ?? defaultValue;

  static Map<String, MetadataKey<Object>> asKeyMap() => {for (var value in MetadataKey.values) value.key: value};
}

sealed class _MetadataCodec<T extends Object> {
  const _MetadataCodec();

  String encode(T value);
  T? decode(String raw);

  static const Map<Type, _MetadataCodec<Object>> _primitives = {
    int: _PrimitiveCodec.integer,
    double: _PrimitiveCodec.real,
    bool: _PrimitiveCodec.boolean,
    String: _PrimitiveCodec.string,
    DateTime: _DateTimeCodec(),
  };

  static _MetadataCodec<T> forPrimitive<T extends Object>(T sample) {
    final codec = _primitives[sample.runtimeType];
    if (codec == null) {
      throw StateError(
        'No primitive codec for ${sample.runtimeType}. Provide an explicit codec when defining the MetadataKey.',
      );
    }
    return codec as _MetadataCodec<T>;
  }
}

final class _EnumCodec<T extends Enum> extends _MetadataCodec<T> {
  final List<T> values;

  const _EnumCodec(this.values);

  @override
  String encode(T value) => value.name;

  @override
  T? decode(String raw) => values.firstWhereOrNull((v) => v.name == raw);
}

final class _DateTimeCodec extends _MetadataCodec<DateTime> {
  const _DateTimeCodec();

  @override
  String encode(DateTime value) => value.toIso8601String();

  @override
  DateTime? decode(String raw) => DateTime.tryParse(raw);
}

final class _MapCodec<K extends Object, V extends Object> extends _MetadataCodec<Map<K, V>> {
  final _MetadataCodec<K> _keyCodec;
  final _MetadataCodec<V> _valueCodec;

  const _MapCodec(this._keyCodec, this._valueCodec);

  @override
  String encode(Map<K, V> value) {
    final entries = <String, String>{};
    value.forEach((k, v) => entries[_keyCodec.encode(k)] = _valueCodec.encode(v));
    return jsonEncode(entries);
  }

  @override
  Map<K, V>? decode(String raw) {
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map) return null;
      final result = <K, V>{};
      for (final entry in decoded.entries) {
        final rawKey = entry.key;
        final rawValue = entry.value;
        if (rawKey is! String || rawValue is! String) return null;
        final k = _keyCodec.decode(rawKey);
        final v = _valueCodec.decode(rawValue);
        if (k == null || v == null) return null;
        result[k] = v;
      }
      return result;
    } on FormatException {
      return null;
    }
  }
}

final class _ListCodec<T extends Object> extends _MetadataCodec<List<T>> {
  final _MetadataCodec<T> _elementCodec;

  const _ListCodec(this._elementCodec);

  @override
  String encode(List<T> value) => jsonEncode(value.map(_elementCodec.encode).toList());

  @override
  List<T>? decode(String raw) {
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return null;
      final result = <T>[];
      for (final item in decoded) {
        if (item is! String) return null;
        final element = _elementCodec.decode(item);
        if (element == null) return null;
        result.add(element);
      }
      return result;
    } on FormatException {
      return null;
    }
  }
}

final class _PrimitiveCodec<T extends Object> extends _MetadataCodec<T> {
  final T? Function(String) _parse;

  const _PrimitiveCodec._(this._parse);

  @override
  String encode(T value) => value.toString();

  @override
  T? decode(String raw) => _parse(raw);

  static const integer = _PrimitiveCodec<int>._(int.tryParse);
  static const real = _PrimitiveCodec<double>._(double.tryParse);
  static const boolean = _PrimitiveCodec<bool>._(bool.tryParse);
  static const string = _PrimitiveCodec<String>._(_identity);

  static String? _identity(String s) => s;
}
