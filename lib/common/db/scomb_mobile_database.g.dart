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

  ClassCellDao? _currentClassCellDaoInstance;

  TaskDao? _currentTaskDaoInstance;

  Future<sqflite.Database> open(String path, List<Migration> migrations,
      [Callback? callback]) async {
    final databaseOptions = sqflite.OpenDatabaseOptions(
      version: 2,
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
            'CREATE TABLE IF NOT EXISTS `settings` (`settingKey` TEXT NOT NULL, `settingValue` TEXT, PRIMARY KEY (`settingKey`))');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `class_cell` (`classId` TEXT NOT NULL, `period` INTEGER NOT NULL, `dayOfWeek` INTEGER NOT NULL, `isUserClassCell` INTEGER NOT NULL, `timetableTitle` TEXT NOT NULL, `year` INTEGER, `term` TEXT, `name` TEXT, `teachers` TEXT, `room` TEXT, `customColorInt` INTEGER, `url` TEXT, `note` TEXT, `syllabusUrl` TEXT, PRIMARY KEY (`classId`, `period`, `dayOfWeek`, `isUserClassCell`, `timetableTitle`))');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `task` (`title` TEXT NOT NULL, `className` TEXT NOT NULL, `taskType` INTEGER NOT NULL, `deadline` INTEGER NOT NULL, `url` TEXT NOT NULL, `classId` TEXT NOT NULL, `reportId` TEXT NOT NULL, `id` TEXT NOT NULL, `customColor` INTEGER, `addManually` INTEGER NOT NULL, `done` INTEGER NOT NULL, PRIMARY KEY (`id`))');

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

  @override
  ClassCellDao get currentClassCellDao {
    return _currentClassCellDaoInstance ??=
        _$ClassCellDao(database, changeListener);
  }

  @override
  TaskDao get currentTaskDao {
    return _currentTaskDaoInstance ??= _$TaskDao(database, changeListener);
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
        mapper: (Map<String, Object?> row) => Setting(
            row['settingKey'] as String, row['settingValue'] as String?),
        arguments: [settingKey]);
  }

  @override
  Future<List<Setting>> getAllSetting() async {
    return _queryAdapter.queryList('SELECT * FROM settings',
        mapper: (Map<String, Object?> row) => Setting(
            row['settingKey'] as String, row['settingValue'] as String?));
  }

  @override
  Future<void> deleteSetting(String settingKey) async {
    await _queryAdapter.queryNoReturn(
        'DELETE FROM settings WHERE settingKey = ?1',
        arguments: [settingKey]);
  }

  @override
  Future<void> deleteAllSettings() async {
    await _queryAdapter.queryNoReturn('DELETE FROM settings');
  }

  @override
  Future<void> insertSetting(Setting setting) async {
    await _settingInsertionAdapter.insert(setting, OnConflictStrategy.replace);
  }
}

class _$ClassCellDao extends ClassCellDao {
  _$ClassCellDao(this.database, this.changeListener)
      : _queryAdapter = QueryAdapter(database),
        _classCellInsertionAdapter = InsertionAdapter(
            database,
            'class_cell',
            (ClassCell item) => <String, Object?>{
                  'classId': item.classId,
                  'period': item.period,
                  'dayOfWeek': item.dayOfWeek,
                  'isUserClassCell': item.isUserClassCell ? 1 : 0,
                  'timetableTitle': item.timetableTitle,
                  'year': item.year,
                  'term': item.term,
                  'name': item.name,
                  'teachers': item.teachers,
                  'room': item.room,
                  'customColorInt': item.customColorInt,
                  'url': item.url,
                  'note': item.note,
                  'syllabusUrl': item.syllabusUrl
                }),
        _classCellDeletionAdapter = DeletionAdapter(
            database,
            'class_cell',
            ['classId'],
            (ClassCell item) => <String, Object?>{
                  'classId': item.classId,
                  'period': item.period,
                  'dayOfWeek': item.dayOfWeek,
                  'isUserClassCell': item.isUserClassCell ? 1 : 0,
                  'timetableTitle': item.timetableTitle,
                  'year': item.year,
                  'term': item.term,
                  'name': item.name,
                  'teachers': item.teachers,
                  'room': item.room,
                  'customColorInt': item.customColorInt,
                  'url': item.url,
                  'note': item.note,
                  'syllabusUrl': item.syllabusUrl
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<ClassCell> _classCellInsertionAdapter;

  final DeletionAdapter<ClassCell> _classCellDeletionAdapter;

  @override
  Future<List<ClassCell>> getAllClasses() async {
    return _queryAdapter.queryList('SELECT * FROM class_cell',
        mapper: (Map<String, Object?> row) => ClassCell(
            row['classId'] as String,
            row['period'] as int,
            row['dayOfWeek'] as int,
            (row['isUserClassCell'] as int) != 0,
            row['timetableTitle'] as String,
            row['year'] as int?,
            row['term'] as String?,
            row['name'] as String?,
            row['teachers'] as String?,
            row['room'] as String?,
            row['customColorInt'] as int?,
            row['url'] as String?,
            row['note'] as String?,
            row['syllabusUrl'] as String?));
  }

  @override
  Future<ClassCell?> getClassCellByClassId(String classId) async {
    return _queryAdapter.query(
        'SELECT * FROM class_cell WHERE classId = ?1 LIMIT 1',
        mapper: (Map<String, Object?> row) => ClassCell(
            row['classId'] as String,
            row['period'] as int,
            row['dayOfWeek'] as int,
            (row['isUserClassCell'] as int) != 0,
            row['timetableTitle'] as String,
            row['year'] as int?,
            row['term'] as String?,
            row['name'] as String?,
            row['teachers'] as String?,
            row['room'] as String?,
            row['customColorInt'] as int?,
            row['url'] as String?,
            row['note'] as String?,
            row['syllabusUrl'] as String?),
        arguments: [classId]);
  }

  @override
  Future<void> removeTimetable(String timetableTitle) async {
    await _queryAdapter.queryNoReturn(
        'DELETE FROM class_cell WHERE timetableTitle = ?1',
        arguments: [timetableTitle]);
  }

  @override
  Future<void> insertClassCell(ClassCell classCell) async {
    await _classCellInsertionAdapter.insert(
        classCell, OnConflictStrategy.replace);
  }

  @override
  Future<void> removeClassCell(ClassCell classCell) async {
    await _classCellDeletionAdapter.delete(classCell);
  }
}

class _$TaskDao extends TaskDao {
  _$TaskDao(this.database, this.changeListener)
      : _queryAdapter = QueryAdapter(database),
        _taskInsertionAdapter = InsertionAdapter(
            database,
            'task',
            (Task item) => <String, Object?>{
                  'title': item.title,
                  'className': item.className,
                  'taskType': item.taskType,
                  'deadline': item.deadline,
                  'url': item.url,
                  'classId': item.classId,
                  'reportId': item.reportId,
                  'id': item.id,
                  'customColor': item.customColor,
                  'addManually': item.addManually ? 1 : 0,
                  'done': item.done ? 1 : 0
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<Task> _taskInsertionAdapter;

  @override
  Future<List<Task>> getAllTasks() async {
    return _queryAdapter.queryList('SELECT * FROM task',
        mapper: (Map<String, Object?> row) => Task(
            row['title'] as String,
            row['className'] as String,
            row['taskType'] as int,
            row['deadline'] as int,
            row['url'] as String,
            row['reportId'] as String,
            row['classId'] as String,
            row['customColor'] as int?,
            (row['addManually'] as int) != 0,
            (row['done'] as int) != 0));
  }

  @override
  Future<Task?> getTask(String id) async {
    return _queryAdapter.query('SELECT * FROM task WHERE id = ?1',
        mapper: (Map<String, Object?> row) => Task(
            row['title'] as String,
            row['className'] as String,
            row['taskType'] as int,
            row['deadline'] as int,
            row['url'] as String,
            row['reportId'] as String,
            row['classId'] as String,
            row['customColor'] as int?,
            (row['addManually'] as int) != 0,
            (row['done'] as int) != 0),
        arguments: [id]);
  }

  @override
  Future<void> removeTask(String id) async {
    await _queryAdapter
        .queryNoReturn('DELETE FROM task WHERE id = ?1', arguments: [id]);
  }

  @override
  Future<void> insertTask(Task task) async {
    await _taskInsertionAdapter.insert(task, OnConflictStrategy.replace);
  }
}
