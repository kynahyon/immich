import 'package:drift/drift.dart';
import 'package:immich_mobile/domain/models/config/app_config.dart';
import 'package:immich_mobile/domain/models/config/system_config.dart';
import 'package:immich_mobile/domain/models/metadata_key.dart';
import 'package:immich_mobile/extensions/string_extensions.dart';
import 'package:immich_mobile/infrastructure/entities/metadata.entity.drift.dart';
import 'package:immich_mobile/infrastructure/repositories/db.repository.dart';

abstract final class MetadataStore {
  static MetadataRepository? _instance;

  static MetadataRepository get instance {
    final instance = _instance;
    if (instance == null) {
      throw StateError('MetadataRepository not initialized. Call ensureInitialized() first');
    }
    return instance;
  }

  static Future<MetadataRepository> ensureInitialized(Drift db) async {
    if (_instance == null) {
      final instance = MetadataRepository(db);
      await instance._hydrate();
      _instance = instance;
    }
    return _instance!;
  }

  static AppConfig get appConfig => instance.appConfig;
  static SystemConfig get systemConfig => instance.systemConfig;
}

class MetadataRepository extends DriftDatabaseRepository {
  final Drift _db;
  final Map<MetadataKey, Object> _cache = {};

  MetadataRepository(this._db) : super(_db);

  AppConfig _appConfig = const .new();
  AppConfig get appConfig => _appConfig;

  SystemConfig _systemConfig = const .new();
  SystemConfig get systemConfig => _systemConfig;

  Future<void> refresh() async {
    _cache.clear();
    _appConfig = const .new();
    _systemConfig = const .new();
    await _hydrate();
  }

  Future<void> _hydrate() async => _hydrateCache(await _db.select(_db.metadataEntity).get());

  T _read<T extends Object>(MetadataKey<T> key) => (_cache[key] as T?) ?? key.defaultValue;

  Future<void> write<T extends Object, U extends T>(MetadataKey<T> key, U value) async {
    if (_read(key) == value) return;
    if (value == key.defaultValue) {
      return delete(key);
    }

    await _db
        .into(_db.metadataEntity)
        .insertOnConflictUpdate(
          MetadataEntityCompanion.insert(key: key.key, value: key.encode(value), updatedAt: Value(DateTime.now())),
        );
    _updateCache(key, value);
  }

  Future<void> delete<T extends Object>(MetadataKey<T> key) async {
    await (_db.delete(_db.metadataEntity)..where((t) => t.key.equals(key.key))).go();
    _updateCache(key, key.defaultValue);
  }

  Stream<AppConfig> watchAppConfig() => _watchDomain(MetadataDomain.appConfig).distinct();

  Stream<SystemConfig> watchSystemConfig() => _watchDomain(MetadataDomain.systemConfig).distinct();

  Stream<T> _watchDomain<T extends Object>(MetadataDomain<T> domain) {
    final query = _db.select(_db.metadataEntity)..where((t) => t.key.like('${domain.prefix}.%'));
    return query.watch().map((rows) {
      _hydrateCache(rows);
      return switch (domain) {
        .appConfig => _appConfig as T,
        .systemConfig => _systemConfig as T,
      };
    });
  }

  void _hydrateCache(List<MetadataEntityData> rows) {
    final keyMap = MetadataKey.asKeyMap();
    for (final row in rows) {
      final key = keyMap[row.key];
      if (key == null) continue;
      _updateCache(key, key.decode(row.value));
    }
  }

  void _updateCache<T extends Object>(MetadataKey<T> key, T value) {
    if (_cache[key] == value) return;
    _cache[key] = value;

    switch (key.domain) {
      case .appConfig:
        _appConfig = _buildAppConfig();
      case .systemConfig:
        _systemConfig = _buildSystemConfig();
    }
  }

  AppConfig _buildAppConfig() => .new(
    theme: .new(
      mode: _read(.themeMode),
      primaryColor: _read(.themePrimaryColor),
      dynamicTheme: _read(.themeDynamic),
      colorfulInterface: _read(.themeColorfulInterface),
    ),
    cleanup: .new(
      keepFavorites: _read(.cleanupKeepFavorites),
      keepMediaType: _read(.cleanupKeepMediaType),
      keepAlbumIds: _read(.cleanupKeepAlbumIds),
      cutoffDaysAgo: _read(.cleanupCutoffDaysAgo),
      defaultsInitialized: _read(.cleanupDefaultsInitialized),
    ),
    map: .new(
      relativeDays: _read(.mapRelativeDate),
      favoritesOnly: _read(.mapShowFavoriteOnly),
      includeArchived: _read(.mapIncludeArchived),
      themeMode: _read(.mapThemeMode),
      withPartners: _read(.mapWithPartners),
    ),
    timeline: .new(
      tilesPerRow: _read(.timelineTilesPerRow),
      groupAssetsBy: _read(.timelineGroupAssetsBy),
      storageIndicator: _read(.timelineStorageIndicator),
    ),
    image: .new(preferRemote: _read(.imagePreferRemote), loadOriginal: _read(.imageLoadOriginal)),
    viewer: .new(
      loopVideo: _read(.viewerLoopVideo),
      loadOriginalVideo: _read(.viewerLoadOriginalVideo),
      autoPlayVideo: _read(.viewerAutoPlayVideo),
      tapToNavigate: _read(.viewerTapToNavigate),
    ),
    album: .new(sortMode: _read(.albumSortMode), isReverse: _read(.albumIsReverse), isGrid: _read(.albumIsGrid)),
    backup: .new(
      enabled: _read(.backupEnabled),
      useCellularForVideos: _read(.backupUseCellularForVideos),
      useCellularForPhotos: _read(.backupUseCellularForPhotos),
      requireCharging: _read(.backupRequireCharging),
      triggerDelay: _read(.backupTriggerDelay),
      syncAlbums: _read(.backupSyncAlbums),
    ),
  );

  SystemConfig _buildSystemConfig() => .new(
    logLevel: _read(.logLevel),
    network: .new(
      autoEndpointSwitching: _read(.networkAutoEndpointSwitching),
      preferredWifiName: _read(.networkPreferredWifiName).nullIfEmpty,
      localEndpoint: _read(.networkLocalEndpoint).nullIfEmpty,
      externalEndpointList: _read(.networkExternalEndpointList),
      customHeaders: _read(.networkCustomHeaders),
    ),
  );
}
