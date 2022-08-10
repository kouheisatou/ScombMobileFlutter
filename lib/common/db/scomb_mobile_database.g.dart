// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'scomb_mobile_database.dart';

// **************************************************************************
// FloorGenerator
// **************************************************************************

// ignore: avoid_classes_with_only_static_members
class $FloorAppDatabase {
  /// Creates a database builder for a persistent database.
  /// Once a database is built, you should keep a reference to it and re-use it.
  static _$AppDatabaseBuilder databaseBuilder(String name) =>
      _$AppDatabaseBuilder(name);

  /// Creates a database builder for an in memory database.
  /// Information stored in an in memory database disappears when the process is killed.
  /// Once a database is built, you should keep a reference to it and re-use it.
  static _$AppDatabaseBuilder inMemoryDatabaseBuilder() =>
      _$AppDatabaseBuilder(null);
}

class _$AppDatabaseBuilder {
  _$AppDatabaseBuilder(this.name);

  final String? name;

  final List<Migration> _migrations = [];

  Callback? _callback;

  /// Adds migrations to the builder.
  _$AppDatabaseBuilder addMigrations(List<Migration> migrations) {
    _migrations.addAll(migrations);
    return this;
  }

  /// Adds a database [Callback] to the builder.
  _$AppDatabaseBuilder addCallback(Callback callback) {
    _callback = callback;
    return this;
  }

  /// Creates the database and initializes it.
  Future<AppDatabase> build() async {
    final path = name != null
        ? await sqfliteDatabaseFactory.getDatabasePath(name!)
        : ':memory:';
    final database = _$AppDatabase();
    database.database = await database.open(
      path,
      _migrations,
      _callback,
    );
    return database;
  }
}

class _$AppDatabase extends AppDatabase {
  _$AppDatabase([StreamController<String>? listener]) {
    changeListener = listener ?? StreamController<String>.broadcast();
  }

  SettingDao? _currentSettingDaoInstance;

  Future<sqflite.Database> open(String path, List<Migration> migrations,
      [Callback? callback]) async {
    final databaseOptions = sqflite.OpenDatabaseOptions(
      version: 1,
      onConfigure: (database) async {
        await database.execute('PRAGMA foreign_keys = ON');
        await callback?.onConfigure?.call(database);
      },
      onOpen: (database) async {
        await callback?.onOpen?.call(database);
      },
      onUpgrade: (database, startVersion, endVersion) async {
        await MigrationAdapter.runMigrations(
            database, startVersion, endVersion, migrations);

        await callback?.onUpgrade?.call(database, startVersion, endVersion);
      },
      onCreate: (database, version) async {
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `settings` (`settingKey` TEXT NOT NULL, `settingValue` TEXT NOT NULL, PRIMARY KEY (`settingKey`))');

        await callback?.onCreate?.call(database, version);
      },
    );
    return sqfliteDatabaseFactory.openDatabase(path, options: databaseOptions);
  }

  @override
  SettingDao get currentSettingDao {
    return _currentSettingDaoInstance ??=
        _$SettingDao(database, changeListener);
  }
}

class _$SettingDao extends SettingDao {
  _$SettingDao(this.database, this.changeListener)
      : _queryAdapter = QueryAdapter(database),
        _settingInsertionAdapter = InsertionAdapter(
            database,
            'settings',
            (Setting item) => <String, Object?>{
                  'settingKey': item.settingKey,
                  'settingValue': item.settingValue
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<Setting> _settingInsertionAdapter;

  @override
  Future<Setting?> getSetting(String settingKey) async {
    return _queryAdapter.query('SELECT * FROM settings WHERE settingKey = ?1',
        mapper: (Map<String, Object?> row) =>
            Setting(row['settingKey'] as String, row['settingValue'] as String),
        arguments: [settingKey]);
  }

  @override
  Future<List<Setting>> getAllSetting() async {
    return _queryAdapter.queryList('SELECT * FROM settingKey',
        mapper: (Map<String, Object?> row) => Setting(
            row['settingKey'] as String, row['settingValue'] as String));
  }

  @override
  Future<void> deleteSetting(String settingKey) async {
    await _queryAdapter.queryNoReturn(
        'DELETE FROM settings WHERE settingKey = ?1',
        arguments: [settingKey]);
  }

  @override
  Future<void> insertSetting(Setting setting) async {
    await _settingInsertionAdapter.insert(setting, OnConflictStrategy.replace);
  }
}
