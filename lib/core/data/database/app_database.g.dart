// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $AlarmsTableTable extends AlarmsTable
    with TableInfo<$AlarmsTableTable, AlarmsTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AlarmsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _alarmIdMeta = const VerificationMeta(
    'alarmId',
  );
  @override
  late final GeneratedColumn<int> alarmId = GeneratedColumn<int>(
    'alarm_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _soundPathMeta = const VerificationMeta(
    'soundPath',
  );
  @override
  late final GeneratedColumn<String> soundPath = GeneratedColumn<String>(
    'sound_path',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(AppConstants.defaultSound),
  );
  static const VerificationMeta _isEnabledMeta = const VerificationMeta(
    'isEnabled',
  );
  @override
  late final GeneratedColumn<bool> isEnabled = GeneratedColumn<bool>(
    'is_enabled',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_enabled" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _vibrateMeta = const VerificationMeta(
    'vibrate',
  );
  @override
  late final GeneratedColumn<bool> vibrate = GeneratedColumn<bool>(
    'vibrate',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("vibrate" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _createdDateMeta = const VerificationMeta(
    'createdDate',
  );
  @override
  late final GeneratedColumn<DateTime> createdDate = GeneratedColumn<DateTime>(
    'created_date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _nextTriggerMeta = const VerificationMeta(
    'nextTrigger',
  );
  @override
  late final GeneratedColumn<DateTime> nextTrigger = GeneratedColumn<DateTime>(
    'next_trigger',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _firedTimeMinutesMeta = const VerificationMeta(
    'firedTimeMinutes',
  );
  @override
  late final GeneratedColumn<int> firedTimeMinutes = GeneratedColumn<int>(
    'fired_time_minutes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    alarmId,
    name,
    title,
    soundPath,
    isEnabled,
    vibrate,
    createdDate,
    nextTrigger,
    firedTimeMinutes,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'alarms_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<AlarmsTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('alarm_id')) {
      context.handle(
        _alarmIdMeta,
        alarmId.isAcceptableOrUnknown(data['alarm_id']!, _alarmIdMeta),
      );
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    }
    if (data.containsKey('sound_path')) {
      context.handle(
        _soundPathMeta,
        soundPath.isAcceptableOrUnknown(data['sound_path']!, _soundPathMeta),
      );
    }
    if (data.containsKey('is_enabled')) {
      context.handle(
        _isEnabledMeta,
        isEnabled.isAcceptableOrUnknown(data['is_enabled']!, _isEnabledMeta),
      );
    }
    if (data.containsKey('vibrate')) {
      context.handle(
        _vibrateMeta,
        vibrate.isAcceptableOrUnknown(data['vibrate']!, _vibrateMeta),
      );
    }
    if (data.containsKey('created_date')) {
      context.handle(
        _createdDateMeta,
        createdDate.isAcceptableOrUnknown(
          data['created_date']!,
          _createdDateMeta,
        ),
      );
    }
    if (data.containsKey('next_trigger')) {
      context.handle(
        _nextTriggerMeta,
        nextTrigger.isAcceptableOrUnknown(
          data['next_trigger']!,
          _nextTriggerMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_nextTriggerMeta);
    }
    if (data.containsKey('fired_time_minutes')) {
      context.handle(
        _firedTimeMinutesMeta,
        firedTimeMinutes.isAcceptableOrUnknown(
          data['fired_time_minutes']!,
          _firedTimeMinutesMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_firedTimeMinutesMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {alarmId};
  @override
  AlarmsTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AlarmsTableData(
      alarmId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}alarm_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      soundPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sound_path'],
      )!,
      isEnabled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_enabled'],
      )!,
      vibrate: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}vibrate'],
      )!,
      createdDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_date'],
      )!,
      nextTrigger: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}next_trigger'],
      )!,
      firedTimeMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}fired_time_minutes'],
      )!,
    );
  }

  @override
  $AlarmsTableTable createAlias(String alias) {
    return $AlarmsTableTable(attachedDatabase, alias);
  }
}

class AlarmsTableData extends DataClass implements Insertable<AlarmsTableData> {
  final int alarmId;
  final String name;
  final String title;
  final String soundPath;
  final bool isEnabled;
  final bool vibrate;
  final DateTime createdDate;
  final DateTime nextTrigger;
  final int firedTimeMinutes;
  const AlarmsTableData({
    required this.alarmId,
    required this.name,
    required this.title,
    required this.soundPath,
    required this.isEnabled,
    required this.vibrate,
    required this.createdDate,
    required this.nextTrigger,
    required this.firedTimeMinutes,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['alarm_id'] = Variable<int>(alarmId);
    map['name'] = Variable<String>(name);
    map['title'] = Variable<String>(title);
    map['sound_path'] = Variable<String>(soundPath);
    map['is_enabled'] = Variable<bool>(isEnabled);
    map['vibrate'] = Variable<bool>(vibrate);
    map['created_date'] = Variable<DateTime>(createdDate);
    map['next_trigger'] = Variable<DateTime>(nextTrigger);
    map['fired_time_minutes'] = Variable<int>(firedTimeMinutes);
    return map;
  }

  AlarmsTableCompanion toCompanion(bool nullToAbsent) {
    return AlarmsTableCompanion(
      alarmId: Value(alarmId),
      name: Value(name),
      title: Value(title),
      soundPath: Value(soundPath),
      isEnabled: Value(isEnabled),
      vibrate: Value(vibrate),
      createdDate: Value(createdDate),
      nextTrigger: Value(nextTrigger),
      firedTimeMinutes: Value(firedTimeMinutes),
    );
  }

  factory AlarmsTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AlarmsTableData(
      alarmId: serializer.fromJson<int>(json['alarmId']),
      name: serializer.fromJson<String>(json['name']),
      title: serializer.fromJson<String>(json['title']),
      soundPath: serializer.fromJson<String>(json['soundPath']),
      isEnabled: serializer.fromJson<bool>(json['isEnabled']),
      vibrate: serializer.fromJson<bool>(json['vibrate']),
      createdDate: serializer.fromJson<DateTime>(json['createdDate']),
      nextTrigger: serializer.fromJson<DateTime>(json['nextTrigger']),
      firedTimeMinutes: serializer.fromJson<int>(json['firedTimeMinutes']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'alarmId': serializer.toJson<int>(alarmId),
      'name': serializer.toJson<String>(name),
      'title': serializer.toJson<String>(title),
      'soundPath': serializer.toJson<String>(soundPath),
      'isEnabled': serializer.toJson<bool>(isEnabled),
      'vibrate': serializer.toJson<bool>(vibrate),
      'createdDate': serializer.toJson<DateTime>(createdDate),
      'nextTrigger': serializer.toJson<DateTime>(nextTrigger),
      'firedTimeMinutes': serializer.toJson<int>(firedTimeMinutes),
    };
  }

  AlarmsTableData copyWith({
    int? alarmId,
    String? name,
    String? title,
    String? soundPath,
    bool? isEnabled,
    bool? vibrate,
    DateTime? createdDate,
    DateTime? nextTrigger,
    int? firedTimeMinutes,
  }) => AlarmsTableData(
    alarmId: alarmId ?? this.alarmId,
    name: name ?? this.name,
    title: title ?? this.title,
    soundPath: soundPath ?? this.soundPath,
    isEnabled: isEnabled ?? this.isEnabled,
    vibrate: vibrate ?? this.vibrate,
    createdDate: createdDate ?? this.createdDate,
    nextTrigger: nextTrigger ?? this.nextTrigger,
    firedTimeMinutes: firedTimeMinutes ?? this.firedTimeMinutes,
  );
  AlarmsTableData copyWithCompanion(AlarmsTableCompanion data) {
    return AlarmsTableData(
      alarmId: data.alarmId.present ? data.alarmId.value : this.alarmId,
      name: data.name.present ? data.name.value : this.name,
      title: data.title.present ? data.title.value : this.title,
      soundPath: data.soundPath.present ? data.soundPath.value : this.soundPath,
      isEnabled: data.isEnabled.present ? data.isEnabled.value : this.isEnabled,
      vibrate: data.vibrate.present ? data.vibrate.value : this.vibrate,
      createdDate: data.createdDate.present
          ? data.createdDate.value
          : this.createdDate,
      nextTrigger: data.nextTrigger.present
          ? data.nextTrigger.value
          : this.nextTrigger,
      firedTimeMinutes: data.firedTimeMinutes.present
          ? data.firedTimeMinutes.value
          : this.firedTimeMinutes,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AlarmsTableData(')
          ..write('alarmId: $alarmId, ')
          ..write('name: $name, ')
          ..write('title: $title, ')
          ..write('soundPath: $soundPath, ')
          ..write('isEnabled: $isEnabled, ')
          ..write('vibrate: $vibrate, ')
          ..write('createdDate: $createdDate, ')
          ..write('nextTrigger: $nextTrigger, ')
          ..write('firedTimeMinutes: $firedTimeMinutes')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    alarmId,
    name,
    title,
    soundPath,
    isEnabled,
    vibrate,
    createdDate,
    nextTrigger,
    firedTimeMinutes,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AlarmsTableData &&
          other.alarmId == this.alarmId &&
          other.name == this.name &&
          other.title == this.title &&
          other.soundPath == this.soundPath &&
          other.isEnabled == this.isEnabled &&
          other.vibrate == this.vibrate &&
          other.createdDate == this.createdDate &&
          other.nextTrigger == this.nextTrigger &&
          other.firedTimeMinutes == this.firedTimeMinutes);
}

class AlarmsTableCompanion extends UpdateCompanion<AlarmsTableData> {
  final Value<int> alarmId;
  final Value<String> name;
  final Value<String> title;
  final Value<String> soundPath;
  final Value<bool> isEnabled;
  final Value<bool> vibrate;
  final Value<DateTime> createdDate;
  final Value<DateTime> nextTrigger;
  final Value<int> firedTimeMinutes;
  const AlarmsTableCompanion({
    this.alarmId = const Value.absent(),
    this.name = const Value.absent(),
    this.title = const Value.absent(),
    this.soundPath = const Value.absent(),
    this.isEnabled = const Value.absent(),
    this.vibrate = const Value.absent(),
    this.createdDate = const Value.absent(),
    this.nextTrigger = const Value.absent(),
    this.firedTimeMinutes = const Value.absent(),
  });
  AlarmsTableCompanion.insert({
    this.alarmId = const Value.absent(),
    required String name,
    this.title = const Value.absent(),
    this.soundPath = const Value.absent(),
    this.isEnabled = const Value.absent(),
    this.vibrate = const Value.absent(),
    this.createdDate = const Value.absent(),
    required DateTime nextTrigger,
    required int firedTimeMinutes,
  }) : name = Value(name),
       nextTrigger = Value(nextTrigger),
       firedTimeMinutes = Value(firedTimeMinutes);
  static Insertable<AlarmsTableData> custom({
    Expression<int>? alarmId,
    Expression<String>? name,
    Expression<String>? title,
    Expression<String>? soundPath,
    Expression<bool>? isEnabled,
    Expression<bool>? vibrate,
    Expression<DateTime>? createdDate,
    Expression<DateTime>? nextTrigger,
    Expression<int>? firedTimeMinutes,
  }) {
    return RawValuesInsertable({
      if (alarmId != null) 'alarm_id': alarmId,
      if (name != null) 'name': name,
      if (title != null) 'title': title,
      if (soundPath != null) 'sound_path': soundPath,
      if (isEnabled != null) 'is_enabled': isEnabled,
      if (vibrate != null) 'vibrate': vibrate,
      if (createdDate != null) 'created_date': createdDate,
      if (nextTrigger != null) 'next_trigger': nextTrigger,
      if (firedTimeMinutes != null) 'fired_time_minutes': firedTimeMinutes,
    });
  }

  AlarmsTableCompanion copyWith({
    Value<int>? alarmId,
    Value<String>? name,
    Value<String>? title,
    Value<String>? soundPath,
    Value<bool>? isEnabled,
    Value<bool>? vibrate,
    Value<DateTime>? createdDate,
    Value<DateTime>? nextTrigger,
    Value<int>? firedTimeMinutes,
  }) {
    return AlarmsTableCompanion(
      alarmId: alarmId ?? this.alarmId,
      name: name ?? this.name,
      title: title ?? this.title,
      soundPath: soundPath ?? this.soundPath,
      isEnabled: isEnabled ?? this.isEnabled,
      vibrate: vibrate ?? this.vibrate,
      createdDate: createdDate ?? this.createdDate,
      nextTrigger: nextTrigger ?? this.nextTrigger,
      firedTimeMinutes: firedTimeMinutes ?? this.firedTimeMinutes,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (alarmId.present) {
      map['alarm_id'] = Variable<int>(alarmId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (soundPath.present) {
      map['sound_path'] = Variable<String>(soundPath.value);
    }
    if (isEnabled.present) {
      map['is_enabled'] = Variable<bool>(isEnabled.value);
    }
    if (vibrate.present) {
      map['vibrate'] = Variable<bool>(vibrate.value);
    }
    if (createdDate.present) {
      map['created_date'] = Variable<DateTime>(createdDate.value);
    }
    if (nextTrigger.present) {
      map['next_trigger'] = Variable<DateTime>(nextTrigger.value);
    }
    if (firedTimeMinutes.present) {
      map['fired_time_minutes'] = Variable<int>(firedTimeMinutes.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AlarmsTableCompanion(')
          ..write('alarmId: $alarmId, ')
          ..write('name: $name, ')
          ..write('title: $title, ')
          ..write('soundPath: $soundPath, ')
          ..write('isEnabled: $isEnabled, ')
          ..write('vibrate: $vibrate, ')
          ..write('createdDate: $createdDate, ')
          ..write('nextTrigger: $nextTrigger, ')
          ..write('firedTimeMinutes: $firedTimeMinutes')
          ..write(')'))
        .toString();
  }
}

class $AlarmDaysTableTable extends AlarmDaysTable
    with TableInfo<$AlarmDaysTableTable, AlarmDaysTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AlarmDaysTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _excutionIdMeta = const VerificationMeta(
    'excutionId',
  );
  @override
  late final GeneratedColumn<int> excutionId = GeneratedColumn<int>(
    'excution_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<AlarmDays, int> repeatDays =
      GeneratedColumn<int>(
        'repeat_days',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
      ).withConverter<AlarmDays>($AlarmDaysTableTable.$converterrepeatDays);
  static const VerificationMeta _alarmIdMeta = const VerificationMeta(
    'alarmId',
  );
  @override
  late final GeneratedColumn<int> alarmId = GeneratedColumn<int>(
    'alarm_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES alarms_table (alarm_id) ON UPDATE CASCADE ON DELETE CASCADE',
    ),
  );
  @override
  List<GeneratedColumn> get $columns => [id, excutionId, repeatDays, alarmId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'alarm_days_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<AlarmDaysTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('excution_id')) {
      context.handle(
        _excutionIdMeta,
        excutionId.isAcceptableOrUnknown(data['excution_id']!, _excutionIdMeta),
      );
    } else if (isInserting) {
      context.missing(_excutionIdMeta);
    }
    if (data.containsKey('alarm_id')) {
      context.handle(
        _alarmIdMeta,
        alarmId.isAcceptableOrUnknown(data['alarm_id']!, _alarmIdMeta),
      );
    } else if (isInserting) {
      context.missing(_alarmIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AlarmDaysTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AlarmDaysTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      excutionId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}excution_id'],
      )!,
      repeatDays: $AlarmDaysTableTable.$converterrepeatDays.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}repeat_days'],
        )!,
      ),
      alarmId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}alarm_id'],
      )!,
    );
  }

  @override
  $AlarmDaysTableTable createAlias(String alias) {
    return $AlarmDaysTableTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<AlarmDays, int, int> $converterrepeatDays =
      const EnumIndexConverter<AlarmDays>(AlarmDays.values);
}

class AlarmDaysTableData extends DataClass
    implements Insertable<AlarmDaysTableData> {
  final int id;
  final int excutionId;
  final AlarmDays repeatDays;
  final int alarmId;
  const AlarmDaysTableData({
    required this.id,
    required this.excutionId,
    required this.repeatDays,
    required this.alarmId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['excution_id'] = Variable<int>(excutionId);
    {
      map['repeat_days'] = Variable<int>(
        $AlarmDaysTableTable.$converterrepeatDays.toSql(repeatDays),
      );
    }
    map['alarm_id'] = Variable<int>(alarmId);
    return map;
  }

  AlarmDaysTableCompanion toCompanion(bool nullToAbsent) {
    return AlarmDaysTableCompanion(
      id: Value(id),
      excutionId: Value(excutionId),
      repeatDays: Value(repeatDays),
      alarmId: Value(alarmId),
    );
  }

  factory AlarmDaysTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AlarmDaysTableData(
      id: serializer.fromJson<int>(json['id']),
      excutionId: serializer.fromJson<int>(json['excutionId']),
      repeatDays: $AlarmDaysTableTable.$converterrepeatDays.fromJson(
        serializer.fromJson<int>(json['repeatDays']),
      ),
      alarmId: serializer.fromJson<int>(json['alarmId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'excutionId': serializer.toJson<int>(excutionId),
      'repeatDays': serializer.toJson<int>(
        $AlarmDaysTableTable.$converterrepeatDays.toJson(repeatDays),
      ),
      'alarmId': serializer.toJson<int>(alarmId),
    };
  }

  AlarmDaysTableData copyWith({
    int? id,
    int? excutionId,
    AlarmDays? repeatDays,
    int? alarmId,
  }) => AlarmDaysTableData(
    id: id ?? this.id,
    excutionId: excutionId ?? this.excutionId,
    repeatDays: repeatDays ?? this.repeatDays,
    alarmId: alarmId ?? this.alarmId,
  );
  AlarmDaysTableData copyWithCompanion(AlarmDaysTableCompanion data) {
    return AlarmDaysTableData(
      id: data.id.present ? data.id.value : this.id,
      excutionId: data.excutionId.present
          ? data.excutionId.value
          : this.excutionId,
      repeatDays: data.repeatDays.present
          ? data.repeatDays.value
          : this.repeatDays,
      alarmId: data.alarmId.present ? data.alarmId.value : this.alarmId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AlarmDaysTableData(')
          ..write('id: $id, ')
          ..write('excutionId: $excutionId, ')
          ..write('repeatDays: $repeatDays, ')
          ..write('alarmId: $alarmId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, excutionId, repeatDays, alarmId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AlarmDaysTableData &&
          other.id == this.id &&
          other.excutionId == this.excutionId &&
          other.repeatDays == this.repeatDays &&
          other.alarmId == this.alarmId);
}

class AlarmDaysTableCompanion extends UpdateCompanion<AlarmDaysTableData> {
  final Value<int> id;
  final Value<int> excutionId;
  final Value<AlarmDays> repeatDays;
  final Value<int> alarmId;
  const AlarmDaysTableCompanion({
    this.id = const Value.absent(),
    this.excutionId = const Value.absent(),
    this.repeatDays = const Value.absent(),
    this.alarmId = const Value.absent(),
  });
  AlarmDaysTableCompanion.insert({
    this.id = const Value.absent(),
    required int excutionId,
    required AlarmDays repeatDays,
    required int alarmId,
  }) : excutionId = Value(excutionId),
       repeatDays = Value(repeatDays),
       alarmId = Value(alarmId);
  static Insertable<AlarmDaysTableData> custom({
    Expression<int>? id,
    Expression<int>? excutionId,
    Expression<int>? repeatDays,
    Expression<int>? alarmId,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (excutionId != null) 'excution_id': excutionId,
      if (repeatDays != null) 'repeat_days': repeatDays,
      if (alarmId != null) 'alarm_id': alarmId,
    });
  }

  AlarmDaysTableCompanion copyWith({
    Value<int>? id,
    Value<int>? excutionId,
    Value<AlarmDays>? repeatDays,
    Value<int>? alarmId,
  }) {
    return AlarmDaysTableCompanion(
      id: id ?? this.id,
      excutionId: excutionId ?? this.excutionId,
      repeatDays: repeatDays ?? this.repeatDays,
      alarmId: alarmId ?? this.alarmId,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (excutionId.present) {
      map['excution_id'] = Variable<int>(excutionId.value);
    }
    if (repeatDays.present) {
      map['repeat_days'] = Variable<int>(
        $AlarmDaysTableTable.$converterrepeatDays.toSql(repeatDays.value),
      );
    }
    if (alarmId.present) {
      map['alarm_id'] = Variable<int>(alarmId.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AlarmDaysTableCompanion(')
          ..write('id: $id, ')
          ..write('excutionId: $excutionId, ')
          ..write('repeatDays: $repeatDays, ')
          ..write('alarmId: $alarmId')
          ..write(')'))
        .toString();
  }
}

abstract class _$AlarmDatabase extends GeneratedDatabase {
  _$AlarmDatabase(QueryExecutor e) : super(e);
  $AlarmDatabaseManager get managers => $AlarmDatabaseManager(this);
  late final $AlarmsTableTable alarmsTable = $AlarmsTableTable(this);
  late final $AlarmDaysTableTable alarmDaysTable = $AlarmDaysTableTable(this);
  late final Index idxNextTrigger = Index(
    'idx_nextTrigger',
    'CREATE INDEX idx_nextTrigger ON alarms_table (next_trigger)',
  );
  late final Index idxEnabledNext = Index(
    'idx_enabled_next',
    'CREATE INDEX idx_enabled_next ON alarms_table (is_enabled, next_trigger)',
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    alarmsTable,
    alarmDaysTable,
    idxNextTrigger,
    idxEnabledNext,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'alarms_table',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('alarm_days_table', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'alarms_table',
        limitUpdateKind: UpdateKind.update,
      ),
      result: [TableUpdate('alarm_days_table', kind: UpdateKind.update)],
    ),
  ]);
}

typedef $$AlarmsTableTableCreateCompanionBuilder =
    AlarmsTableCompanion Function({
      Value<int> alarmId,
      required String name,
      Value<String> title,
      Value<String> soundPath,
      Value<bool> isEnabled,
      Value<bool> vibrate,
      Value<DateTime> createdDate,
      required DateTime nextTrigger,
      required int firedTimeMinutes,
    });
typedef $$AlarmsTableTableUpdateCompanionBuilder =
    AlarmsTableCompanion Function({
      Value<int> alarmId,
      Value<String> name,
      Value<String> title,
      Value<String> soundPath,
      Value<bool> isEnabled,
      Value<bool> vibrate,
      Value<DateTime> createdDate,
      Value<DateTime> nextTrigger,
      Value<int> firedTimeMinutes,
    });

final class $$AlarmsTableTableReferences
    extends
        BaseReferences<_$AlarmDatabase, $AlarmsTableTable, AlarmsTableData> {
  $$AlarmsTableTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$AlarmDaysTableTable, List<AlarmDaysTableData>>
  _alarmDaysTableRefsTable(_$AlarmDatabase db) => MultiTypedResultKey.fromTable(
    db.alarmDaysTable,
    aliasName: $_aliasNameGenerator(
      db.alarmsTable.alarmId,
      db.alarmDaysTable.alarmId,
    ),
  );

  $$AlarmDaysTableTableProcessedTableManager get alarmDaysTableRefs {
    final manager = $$AlarmDaysTableTableTableManager($_db, $_db.alarmDaysTable)
        .filter(
          (f) => f.alarmId.alarmId.sqlEquals($_itemColumn<int>('alarm_id')!),
        );

    final cache = $_typedResult.readTableOrNull(_alarmDaysTableRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$AlarmsTableTableFilterComposer
    extends Composer<_$AlarmDatabase, $AlarmsTableTable> {
  $$AlarmsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get alarmId => $composableBuilder(
    column: $table.alarmId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get soundPath => $composableBuilder(
    column: $table.soundPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isEnabled => $composableBuilder(
    column: $table.isEnabled,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get vibrate => $composableBuilder(
    column: $table.vibrate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdDate => $composableBuilder(
    column: $table.createdDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get nextTrigger => $composableBuilder(
    column: $table.nextTrigger,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get firedTimeMinutes => $composableBuilder(
    column: $table.firedTimeMinutes,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> alarmDaysTableRefs(
    Expression<bool> Function($$AlarmDaysTableTableFilterComposer f) f,
  ) {
    final $$AlarmDaysTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.alarmId,
      referencedTable: $db.alarmDaysTable,
      getReferencedColumn: (t) => t.alarmId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AlarmDaysTableTableFilterComposer(
            $db: $db,
            $table: $db.alarmDaysTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$AlarmsTableTableOrderingComposer
    extends Composer<_$AlarmDatabase, $AlarmsTableTable> {
  $$AlarmsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get alarmId => $composableBuilder(
    column: $table.alarmId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get soundPath => $composableBuilder(
    column: $table.soundPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isEnabled => $composableBuilder(
    column: $table.isEnabled,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get vibrate => $composableBuilder(
    column: $table.vibrate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdDate => $composableBuilder(
    column: $table.createdDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get nextTrigger => $composableBuilder(
    column: $table.nextTrigger,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get firedTimeMinutes => $composableBuilder(
    column: $table.firedTimeMinutes,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AlarmsTableTableAnnotationComposer
    extends Composer<_$AlarmDatabase, $AlarmsTableTable> {
  $$AlarmsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get alarmId =>
      $composableBuilder(column: $table.alarmId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get soundPath =>
      $composableBuilder(column: $table.soundPath, builder: (column) => column);

  GeneratedColumn<bool> get isEnabled =>
      $composableBuilder(column: $table.isEnabled, builder: (column) => column);

  GeneratedColumn<bool> get vibrate =>
      $composableBuilder(column: $table.vibrate, builder: (column) => column);

  GeneratedColumn<DateTime> get createdDate => $composableBuilder(
    column: $table.createdDate,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get nextTrigger => $composableBuilder(
    column: $table.nextTrigger,
    builder: (column) => column,
  );

  GeneratedColumn<int> get firedTimeMinutes => $composableBuilder(
    column: $table.firedTimeMinutes,
    builder: (column) => column,
  );

  Expression<T> alarmDaysTableRefs<T extends Object>(
    Expression<T> Function($$AlarmDaysTableTableAnnotationComposer a) f,
  ) {
    final $$AlarmDaysTableTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.alarmId,
      referencedTable: $db.alarmDaysTable,
      getReferencedColumn: (t) => t.alarmId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AlarmDaysTableTableAnnotationComposer(
            $db: $db,
            $table: $db.alarmDaysTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$AlarmsTableTableTableManager
    extends
        RootTableManager<
          _$AlarmDatabase,
          $AlarmsTableTable,
          AlarmsTableData,
          $$AlarmsTableTableFilterComposer,
          $$AlarmsTableTableOrderingComposer,
          $$AlarmsTableTableAnnotationComposer,
          $$AlarmsTableTableCreateCompanionBuilder,
          $$AlarmsTableTableUpdateCompanionBuilder,
          (AlarmsTableData, $$AlarmsTableTableReferences),
          AlarmsTableData,
          PrefetchHooks Function({bool alarmDaysTableRefs})
        > {
  $$AlarmsTableTableTableManager(_$AlarmDatabase db, $AlarmsTableTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AlarmsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AlarmsTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AlarmsTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> alarmId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> soundPath = const Value.absent(),
                Value<bool> isEnabled = const Value.absent(),
                Value<bool> vibrate = const Value.absent(),
                Value<DateTime> createdDate = const Value.absent(),
                Value<DateTime> nextTrigger = const Value.absent(),
                Value<int> firedTimeMinutes = const Value.absent(),
              }) => AlarmsTableCompanion(
                alarmId: alarmId,
                name: name,
                title: title,
                soundPath: soundPath,
                isEnabled: isEnabled,
                vibrate: vibrate,
                createdDate: createdDate,
                nextTrigger: nextTrigger,
                firedTimeMinutes: firedTimeMinutes,
              ),
          createCompanionCallback:
              ({
                Value<int> alarmId = const Value.absent(),
                required String name,
                Value<String> title = const Value.absent(),
                Value<String> soundPath = const Value.absent(),
                Value<bool> isEnabled = const Value.absent(),
                Value<bool> vibrate = const Value.absent(),
                Value<DateTime> createdDate = const Value.absent(),
                required DateTime nextTrigger,
                required int firedTimeMinutes,
              }) => AlarmsTableCompanion.insert(
                alarmId: alarmId,
                name: name,
                title: title,
                soundPath: soundPath,
                isEnabled: isEnabled,
                vibrate: vibrate,
                createdDate: createdDate,
                nextTrigger: nextTrigger,
                firedTimeMinutes: firedTimeMinutes,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$AlarmsTableTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({alarmDaysTableRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (alarmDaysTableRefs) db.alarmDaysTable,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (alarmDaysTableRefs)
                    await $_getPrefetchedData<
                      AlarmsTableData,
                      $AlarmsTableTable,
                      AlarmDaysTableData
                    >(
                      currentTable: table,
                      referencedTable: $$AlarmsTableTableReferences
                          ._alarmDaysTableRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$AlarmsTableTableReferences(
                            db,
                            table,
                            p0,
                          ).alarmDaysTableRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where(
                            (e) => e.alarmId == item.alarmId,
                          ),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$AlarmsTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AlarmDatabase,
      $AlarmsTableTable,
      AlarmsTableData,
      $$AlarmsTableTableFilterComposer,
      $$AlarmsTableTableOrderingComposer,
      $$AlarmsTableTableAnnotationComposer,
      $$AlarmsTableTableCreateCompanionBuilder,
      $$AlarmsTableTableUpdateCompanionBuilder,
      (AlarmsTableData, $$AlarmsTableTableReferences),
      AlarmsTableData,
      PrefetchHooks Function({bool alarmDaysTableRefs})
    >;
typedef $$AlarmDaysTableTableCreateCompanionBuilder =
    AlarmDaysTableCompanion Function({
      Value<int> id,
      required int excutionId,
      required AlarmDays repeatDays,
      required int alarmId,
    });
typedef $$AlarmDaysTableTableUpdateCompanionBuilder =
    AlarmDaysTableCompanion Function({
      Value<int> id,
      Value<int> excutionId,
      Value<AlarmDays> repeatDays,
      Value<int> alarmId,
    });

final class $$AlarmDaysTableTableReferences
    extends
        BaseReferences<
          _$AlarmDatabase,
          $AlarmDaysTableTable,
          AlarmDaysTableData
        > {
  $$AlarmDaysTableTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $AlarmsTableTable _alarmIdTable(_$AlarmDatabase db) =>
      db.alarmsTable.createAlias(
        $_aliasNameGenerator(db.alarmDaysTable.alarmId, db.alarmsTable.alarmId),
      );

  $$AlarmsTableTableProcessedTableManager get alarmId {
    final $_column = $_itemColumn<int>('alarm_id')!;

    final manager = $$AlarmsTableTableTableManager(
      $_db,
      $_db.alarmsTable,
    ).filter((f) => f.alarmId.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_alarmIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$AlarmDaysTableTableFilterComposer
    extends Composer<_$AlarmDatabase, $AlarmDaysTableTable> {
  $$AlarmDaysTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get excutionId => $composableBuilder(
    column: $table.excutionId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<AlarmDays, AlarmDays, int> get repeatDays =>
      $composableBuilder(
        column: $table.repeatDays,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  $$AlarmsTableTableFilterComposer get alarmId {
    final $$AlarmsTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.alarmId,
      referencedTable: $db.alarmsTable,
      getReferencedColumn: (t) => t.alarmId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AlarmsTableTableFilterComposer(
            $db: $db,
            $table: $db.alarmsTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AlarmDaysTableTableOrderingComposer
    extends Composer<_$AlarmDatabase, $AlarmDaysTableTable> {
  $$AlarmDaysTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get excutionId => $composableBuilder(
    column: $table.excutionId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get repeatDays => $composableBuilder(
    column: $table.repeatDays,
    builder: (column) => ColumnOrderings(column),
  );

  $$AlarmsTableTableOrderingComposer get alarmId {
    final $$AlarmsTableTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.alarmId,
      referencedTable: $db.alarmsTable,
      getReferencedColumn: (t) => t.alarmId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AlarmsTableTableOrderingComposer(
            $db: $db,
            $table: $db.alarmsTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AlarmDaysTableTableAnnotationComposer
    extends Composer<_$AlarmDatabase, $AlarmDaysTableTable> {
  $$AlarmDaysTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get excutionId => $composableBuilder(
    column: $table.excutionId,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<AlarmDays, int> get repeatDays =>
      $composableBuilder(
        column: $table.repeatDays,
        builder: (column) => column,
      );

  $$AlarmsTableTableAnnotationComposer get alarmId {
    final $$AlarmsTableTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.alarmId,
      referencedTable: $db.alarmsTable,
      getReferencedColumn: (t) => t.alarmId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AlarmsTableTableAnnotationComposer(
            $db: $db,
            $table: $db.alarmsTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AlarmDaysTableTableTableManager
    extends
        RootTableManager<
          _$AlarmDatabase,
          $AlarmDaysTableTable,
          AlarmDaysTableData,
          $$AlarmDaysTableTableFilterComposer,
          $$AlarmDaysTableTableOrderingComposer,
          $$AlarmDaysTableTableAnnotationComposer,
          $$AlarmDaysTableTableCreateCompanionBuilder,
          $$AlarmDaysTableTableUpdateCompanionBuilder,
          (AlarmDaysTableData, $$AlarmDaysTableTableReferences),
          AlarmDaysTableData,
          PrefetchHooks Function({bool alarmId})
        > {
  $$AlarmDaysTableTableTableManager(
    _$AlarmDatabase db,
    $AlarmDaysTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AlarmDaysTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AlarmDaysTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AlarmDaysTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> excutionId = const Value.absent(),
                Value<AlarmDays> repeatDays = const Value.absent(),
                Value<int> alarmId = const Value.absent(),
              }) => AlarmDaysTableCompanion(
                id: id,
                excutionId: excutionId,
                repeatDays: repeatDays,
                alarmId: alarmId,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int excutionId,
                required AlarmDays repeatDays,
                required int alarmId,
              }) => AlarmDaysTableCompanion.insert(
                id: id,
                excutionId: excutionId,
                repeatDays: repeatDays,
                alarmId: alarmId,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$AlarmDaysTableTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({alarmId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (alarmId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.alarmId,
                                referencedTable: $$AlarmDaysTableTableReferences
                                    ._alarmIdTable(db),
                                referencedColumn:
                                    $$AlarmDaysTableTableReferences
                                        ._alarmIdTable(db)
                                        .alarmId,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$AlarmDaysTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AlarmDatabase,
      $AlarmDaysTableTable,
      AlarmDaysTableData,
      $$AlarmDaysTableTableFilterComposer,
      $$AlarmDaysTableTableOrderingComposer,
      $$AlarmDaysTableTableAnnotationComposer,
      $$AlarmDaysTableTableCreateCompanionBuilder,
      $$AlarmDaysTableTableUpdateCompanionBuilder,
      (AlarmDaysTableData, $$AlarmDaysTableTableReferences),
      AlarmDaysTableData,
      PrefetchHooks Function({bool alarmId})
    >;

class $AlarmDatabaseManager {
  final _$AlarmDatabase _db;
  $AlarmDatabaseManager(this._db);
  $$AlarmsTableTableTableManager get alarmsTable =>
      $$AlarmsTableTableTableManager(_db, _db.alarmsTable);
  $$AlarmDaysTableTableTableManager get alarmDaysTable =>
      $$AlarmDaysTableTableTableManager(_db, _db.alarmDaysTable);
}
