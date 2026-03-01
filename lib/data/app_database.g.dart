// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $SessionsTable extends Sessions with TableInfo<$SessionsTable, Session> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SessionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _startedAtMeta =
      const VerificationMeta('startedAt');
  @override
  late final GeneratedColumn<int> startedAt = GeneratedColumn<int>(
      'started_at', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _endedAtMeta =
      const VerificationMeta('endedAt');
  @override
  late final GeneratedColumn<int> endedAt = GeneratedColumn<int>(
      'ended_at', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _categoryMeta =
      const VerificationMeta('category');
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
      'category', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _subCategoryMeta =
      const VerificationMeta('subCategory');
  @override
  late final GeneratedColumn<String> subCategory = GeneratedColumn<String>(
      'sub_category', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _intentMeta = const VerificationMeta('intent');
  @override
  late final GeneratedColumn<String> intent = GeneratedColumn<String>(
      'intent', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _baselineAimSecondsMeta =
      const VerificationMeta('baselineAimSeconds');
  @override
  late final GeneratedColumn<int> baselineAimSeconds = GeneratedColumn<int>(
      'baseline_aim_seconds', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(2700));
  static const VerificationMeta _qualityScoreMeta =
      const VerificationMeta('qualityScore');
  @override
  late final GeneratedColumn<double> qualityScore = GeneratedColumn<double>(
      'quality_score', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0.0));
  static const VerificationMeta _focusDensityMeta =
      const VerificationMeta('focusDensity');
  @override
  late final GeneratedColumn<double> focusDensity = GeneratedColumn<double>(
      'focus_density', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0.0));
  static const VerificationMeta _sessionOneRmSecondsMeta =
      const VerificationMeta('sessionOneRmSeconds');
  @override
  late final GeneratedColumn<int> sessionOneRmSeconds = GeneratedColumn<int>(
      'session_one_rm_seconds', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _totalElapsedSecondsMeta =
      const VerificationMeta('totalElapsedSeconds');
  @override
  late final GeneratedColumn<int> totalElapsedSeconds = GeneratedColumn<int>(
      'total_elapsed_seconds', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _lapCountMeta =
      const VerificationMeta('lapCount');
  @override
  late final GeneratedColumn<int> lapCount = GeneratedColumn<int>(
      'lap_count', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _isCompletedMeta =
      const VerificationMeta('isCompleted');
  @override
  late final GeneratedColumn<bool> isCompleted = GeneratedColumn<bool>(
      'is_completed', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("is_completed" IN (0, 1))'),
      defaultValue: const Constant(false));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        startedAt,
        endedAt,
        category,
        subCategory,
        intent,
        baselineAimSeconds,
        qualityScore,
        focusDensity,
        sessionOneRmSeconds,
        totalElapsedSeconds,
        lapCount,
        isCompleted
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sessions';
  @override
  VerificationContext validateIntegrity(Insertable<Session> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('started_at')) {
      context.handle(_startedAtMeta,
          startedAt.isAcceptableOrUnknown(data['started_at']!, _startedAtMeta));
    } else if (isInserting) {
      context.missing(_startedAtMeta);
    }
    if (data.containsKey('ended_at')) {
      context.handle(_endedAtMeta,
          endedAt.isAcceptableOrUnknown(data['ended_at']!, _endedAtMeta));
    }
    if (data.containsKey('category')) {
      context.handle(_categoryMeta,
          category.isAcceptableOrUnknown(data['category']!, _categoryMeta));
    } else if (isInserting) {
      context.missing(_categoryMeta);
    }
    if (data.containsKey('sub_category')) {
      context.handle(
          _subCategoryMeta,
          subCategory.isAcceptableOrUnknown(
              data['sub_category']!, _subCategoryMeta));
    }
    if (data.containsKey('intent')) {
      context.handle(_intentMeta,
          intent.isAcceptableOrUnknown(data['intent']!, _intentMeta));
    }
    if (data.containsKey('baseline_aim_seconds')) {
      context.handle(
          _baselineAimSecondsMeta,
          baselineAimSeconds.isAcceptableOrUnknown(
              data['baseline_aim_seconds']!, _baselineAimSecondsMeta));
    }
    if (data.containsKey('quality_score')) {
      context.handle(
          _qualityScoreMeta,
          qualityScore.isAcceptableOrUnknown(
              data['quality_score']!, _qualityScoreMeta));
    }
    if (data.containsKey('focus_density')) {
      context.handle(
          _focusDensityMeta,
          focusDensity.isAcceptableOrUnknown(
              data['focus_density']!, _focusDensityMeta));
    }
    if (data.containsKey('session_one_rm_seconds')) {
      context.handle(
          _sessionOneRmSecondsMeta,
          sessionOneRmSeconds.isAcceptableOrUnknown(
              data['session_one_rm_seconds']!, _sessionOneRmSecondsMeta));
    }
    if (data.containsKey('total_elapsed_seconds')) {
      context.handle(
          _totalElapsedSecondsMeta,
          totalElapsedSeconds.isAcceptableOrUnknown(
              data['total_elapsed_seconds']!, _totalElapsedSecondsMeta));
    }
    if (data.containsKey('lap_count')) {
      context.handle(_lapCountMeta,
          lapCount.isAcceptableOrUnknown(data['lap_count']!, _lapCountMeta));
    }
    if (data.containsKey('is_completed')) {
      context.handle(
          _isCompletedMeta,
          isCompleted.isAcceptableOrUnknown(
              data['is_completed']!, _isCompletedMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Session map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Session(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      startedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}started_at'])!,
      endedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}ended_at']),
      category: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}category'])!,
      subCategory: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sub_category']),
      intent: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}intent']),
      baselineAimSeconds: attachedDatabase.typeMapping.read(
          DriftSqlType.int, data['${effectivePrefix}baseline_aim_seconds'])!,
      qualityScore: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}quality_score'])!,
      focusDensity: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}focus_density'])!,
      sessionOneRmSeconds: attachedDatabase.typeMapping.read(
          DriftSqlType.int, data['${effectivePrefix}session_one_rm_seconds'])!,
      totalElapsedSeconds: attachedDatabase.typeMapping.read(
          DriftSqlType.int, data['${effectivePrefix}total_elapsed_seconds'])!,
      lapCount: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}lap_count'])!,
      isCompleted: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_completed'])!,
    );
  }

  @override
  $SessionsTable createAlias(String alias) {
    return $SessionsTable(attachedDatabase, alias);
  }
}

class Session extends DataClass implements Insertable<Session> {
  final int id;

  /// ISO 8601 start timestamp (stored as int epoch ms)
  final int startedAt;

  /// Null until session ends
  final int? endedAt;
  final String category;
  final String? subCategory;
  final String? intent;

  /// Baseline aim in seconds
  final int baselineAimSeconds;

  /// Computed KPIs stored at finish
  final double qualityScore;
  final double focusDensity;

  /// Longest unbroken focus lap (seconds)
  final int sessionOneRmSeconds;
  final int totalElapsedSeconds;
  final int lapCount;
  final bool isCompleted;
  const Session(
      {required this.id,
      required this.startedAt,
      this.endedAt,
      required this.category,
      this.subCategory,
      this.intent,
      required this.baselineAimSeconds,
      required this.qualityScore,
      required this.focusDensity,
      required this.sessionOneRmSeconds,
      required this.totalElapsedSeconds,
      required this.lapCount,
      required this.isCompleted});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['started_at'] = Variable<int>(startedAt);
    if (!nullToAbsent || endedAt != null) {
      map['ended_at'] = Variable<int>(endedAt);
    }
    map['category'] = Variable<String>(category);
    if (!nullToAbsent || subCategory != null) {
      map['sub_category'] = Variable<String>(subCategory);
    }
    if (!nullToAbsent || intent != null) {
      map['intent'] = Variable<String>(intent);
    }
    map['baseline_aim_seconds'] = Variable<int>(baselineAimSeconds);
    map['quality_score'] = Variable<double>(qualityScore);
    map['focus_density'] = Variable<double>(focusDensity);
    map['session_one_rm_seconds'] = Variable<int>(sessionOneRmSeconds);
    map['total_elapsed_seconds'] = Variable<int>(totalElapsedSeconds);
    map['lap_count'] = Variable<int>(lapCount);
    map['is_completed'] = Variable<bool>(isCompleted);
    return map;
  }

  SessionsCompanion toCompanion(bool nullToAbsent) {
    return SessionsCompanion(
      id: Value(id),
      startedAt: Value(startedAt),
      endedAt: endedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(endedAt),
      category: Value(category),
      subCategory: subCategory == null && nullToAbsent
          ? const Value.absent()
          : Value(subCategory),
      intent:
          intent == null && nullToAbsent ? const Value.absent() : Value(intent),
      baselineAimSeconds: Value(baselineAimSeconds),
      qualityScore: Value(qualityScore),
      focusDensity: Value(focusDensity),
      sessionOneRmSeconds: Value(sessionOneRmSeconds),
      totalElapsedSeconds: Value(totalElapsedSeconds),
      lapCount: Value(lapCount),
      isCompleted: Value(isCompleted),
    );
  }

  factory Session.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Session(
      id: serializer.fromJson<int>(json['id']),
      startedAt: serializer.fromJson<int>(json['startedAt']),
      endedAt: serializer.fromJson<int?>(json['endedAt']),
      category: serializer.fromJson<String>(json['category']),
      subCategory: serializer.fromJson<String?>(json['subCategory']),
      intent: serializer.fromJson<String?>(json['intent']),
      baselineAimSeconds: serializer.fromJson<int>(json['baselineAimSeconds']),
      qualityScore: serializer.fromJson<double>(json['qualityScore']),
      focusDensity: serializer.fromJson<double>(json['focusDensity']),
      sessionOneRmSeconds:
          serializer.fromJson<int>(json['sessionOneRmSeconds']),
      totalElapsedSeconds:
          serializer.fromJson<int>(json['totalElapsedSeconds']),
      lapCount: serializer.fromJson<int>(json['lapCount']),
      isCompleted: serializer.fromJson<bool>(json['isCompleted']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'startedAt': serializer.toJson<int>(startedAt),
      'endedAt': serializer.toJson<int?>(endedAt),
      'category': serializer.toJson<String>(category),
      'subCategory': serializer.toJson<String?>(subCategory),
      'intent': serializer.toJson<String?>(intent),
      'baselineAimSeconds': serializer.toJson<int>(baselineAimSeconds),
      'qualityScore': serializer.toJson<double>(qualityScore),
      'focusDensity': serializer.toJson<double>(focusDensity),
      'sessionOneRmSeconds': serializer.toJson<int>(sessionOneRmSeconds),
      'totalElapsedSeconds': serializer.toJson<int>(totalElapsedSeconds),
      'lapCount': serializer.toJson<int>(lapCount),
      'isCompleted': serializer.toJson<bool>(isCompleted),
    };
  }

  Session copyWith(
          {int? id,
          int? startedAt,
          Value<int?> endedAt = const Value.absent(),
          String? category,
          Value<String?> subCategory = const Value.absent(),
          Value<String?> intent = const Value.absent(),
          int? baselineAimSeconds,
          double? qualityScore,
          double? focusDensity,
          int? sessionOneRmSeconds,
          int? totalElapsedSeconds,
          int? lapCount,
          bool? isCompleted}) =>
      Session(
        id: id ?? this.id,
        startedAt: startedAt ?? this.startedAt,
        endedAt: endedAt.present ? endedAt.value : this.endedAt,
        category: category ?? this.category,
        subCategory: subCategory.present ? subCategory.value : this.subCategory,
        intent: intent.present ? intent.value : this.intent,
        baselineAimSeconds: baselineAimSeconds ?? this.baselineAimSeconds,
        qualityScore: qualityScore ?? this.qualityScore,
        focusDensity: focusDensity ?? this.focusDensity,
        sessionOneRmSeconds: sessionOneRmSeconds ?? this.sessionOneRmSeconds,
        totalElapsedSeconds: totalElapsedSeconds ?? this.totalElapsedSeconds,
        lapCount: lapCount ?? this.lapCount,
        isCompleted: isCompleted ?? this.isCompleted,
      );
  Session copyWithCompanion(SessionsCompanion data) {
    return Session(
      id: data.id.present ? data.id.value : this.id,
      startedAt: data.startedAt.present ? data.startedAt.value : this.startedAt,
      endedAt: data.endedAt.present ? data.endedAt.value : this.endedAt,
      category: data.category.present ? data.category.value : this.category,
      subCategory:
          data.subCategory.present ? data.subCategory.value : this.subCategory,
      intent: data.intent.present ? data.intent.value : this.intent,
      baselineAimSeconds: data.baselineAimSeconds.present
          ? data.baselineAimSeconds.value
          : this.baselineAimSeconds,
      qualityScore: data.qualityScore.present
          ? data.qualityScore.value
          : this.qualityScore,
      focusDensity: data.focusDensity.present
          ? data.focusDensity.value
          : this.focusDensity,
      sessionOneRmSeconds: data.sessionOneRmSeconds.present
          ? data.sessionOneRmSeconds.value
          : this.sessionOneRmSeconds,
      totalElapsedSeconds: data.totalElapsedSeconds.present
          ? data.totalElapsedSeconds.value
          : this.totalElapsedSeconds,
      lapCount: data.lapCount.present ? data.lapCount.value : this.lapCount,
      isCompleted:
          data.isCompleted.present ? data.isCompleted.value : this.isCompleted,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Session(')
          ..write('id: $id, ')
          ..write('startedAt: $startedAt, ')
          ..write('endedAt: $endedAt, ')
          ..write('category: $category, ')
          ..write('subCategory: $subCategory, ')
          ..write('intent: $intent, ')
          ..write('baselineAimSeconds: $baselineAimSeconds, ')
          ..write('qualityScore: $qualityScore, ')
          ..write('focusDensity: $focusDensity, ')
          ..write('sessionOneRmSeconds: $sessionOneRmSeconds, ')
          ..write('totalElapsedSeconds: $totalElapsedSeconds, ')
          ..write('lapCount: $lapCount, ')
          ..write('isCompleted: $isCompleted')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      startedAt,
      endedAt,
      category,
      subCategory,
      intent,
      baselineAimSeconds,
      qualityScore,
      focusDensity,
      sessionOneRmSeconds,
      totalElapsedSeconds,
      lapCount,
      isCompleted);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Session &&
          other.id == this.id &&
          other.startedAt == this.startedAt &&
          other.endedAt == this.endedAt &&
          other.category == this.category &&
          other.subCategory == this.subCategory &&
          other.intent == this.intent &&
          other.baselineAimSeconds == this.baselineAimSeconds &&
          other.qualityScore == this.qualityScore &&
          other.focusDensity == this.focusDensity &&
          other.sessionOneRmSeconds == this.sessionOneRmSeconds &&
          other.totalElapsedSeconds == this.totalElapsedSeconds &&
          other.lapCount == this.lapCount &&
          other.isCompleted == this.isCompleted);
}

class SessionsCompanion extends UpdateCompanion<Session> {
  final Value<int> id;
  final Value<int> startedAt;
  final Value<int?> endedAt;
  final Value<String> category;
  final Value<String?> subCategory;
  final Value<String?> intent;
  final Value<int> baselineAimSeconds;
  final Value<double> qualityScore;
  final Value<double> focusDensity;
  final Value<int> sessionOneRmSeconds;
  final Value<int> totalElapsedSeconds;
  final Value<int> lapCount;
  final Value<bool> isCompleted;
  const SessionsCompanion({
    this.id = const Value.absent(),
    this.startedAt = const Value.absent(),
    this.endedAt = const Value.absent(),
    this.category = const Value.absent(),
    this.subCategory = const Value.absent(),
    this.intent = const Value.absent(),
    this.baselineAimSeconds = const Value.absent(),
    this.qualityScore = const Value.absent(),
    this.focusDensity = const Value.absent(),
    this.sessionOneRmSeconds = const Value.absent(),
    this.totalElapsedSeconds = const Value.absent(),
    this.lapCount = const Value.absent(),
    this.isCompleted = const Value.absent(),
  });
  SessionsCompanion.insert({
    this.id = const Value.absent(),
    required int startedAt,
    this.endedAt = const Value.absent(),
    required String category,
    this.subCategory = const Value.absent(),
    this.intent = const Value.absent(),
    this.baselineAimSeconds = const Value.absent(),
    this.qualityScore = const Value.absent(),
    this.focusDensity = const Value.absent(),
    this.sessionOneRmSeconds = const Value.absent(),
    this.totalElapsedSeconds = const Value.absent(),
    this.lapCount = const Value.absent(),
    this.isCompleted = const Value.absent(),
  })  : startedAt = Value(startedAt),
        category = Value(category);
  static Insertable<Session> custom({
    Expression<int>? id,
    Expression<int>? startedAt,
    Expression<int>? endedAt,
    Expression<String>? category,
    Expression<String>? subCategory,
    Expression<String>? intent,
    Expression<int>? baselineAimSeconds,
    Expression<double>? qualityScore,
    Expression<double>? focusDensity,
    Expression<int>? sessionOneRmSeconds,
    Expression<int>? totalElapsedSeconds,
    Expression<int>? lapCount,
    Expression<bool>? isCompleted,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (startedAt != null) 'started_at': startedAt,
      if (endedAt != null) 'ended_at': endedAt,
      if (category != null) 'category': category,
      if (subCategory != null) 'sub_category': subCategory,
      if (intent != null) 'intent': intent,
      if (baselineAimSeconds != null)
        'baseline_aim_seconds': baselineAimSeconds,
      if (qualityScore != null) 'quality_score': qualityScore,
      if (focusDensity != null) 'focus_density': focusDensity,
      if (sessionOneRmSeconds != null)
        'session_one_rm_seconds': sessionOneRmSeconds,
      if (totalElapsedSeconds != null)
        'total_elapsed_seconds': totalElapsedSeconds,
      if (lapCount != null) 'lap_count': lapCount,
      if (isCompleted != null) 'is_completed': isCompleted,
    });
  }

  SessionsCompanion copyWith(
      {Value<int>? id,
      Value<int>? startedAt,
      Value<int?>? endedAt,
      Value<String>? category,
      Value<String?>? subCategory,
      Value<String?>? intent,
      Value<int>? baselineAimSeconds,
      Value<double>? qualityScore,
      Value<double>? focusDensity,
      Value<int>? sessionOneRmSeconds,
      Value<int>? totalElapsedSeconds,
      Value<int>? lapCount,
      Value<bool>? isCompleted}) {
    return SessionsCompanion(
      id: id ?? this.id,
      startedAt: startedAt ?? this.startedAt,
      endedAt: endedAt ?? this.endedAt,
      category: category ?? this.category,
      subCategory: subCategory ?? this.subCategory,
      intent: intent ?? this.intent,
      baselineAimSeconds: baselineAimSeconds ?? this.baselineAimSeconds,
      qualityScore: qualityScore ?? this.qualityScore,
      focusDensity: focusDensity ?? this.focusDensity,
      sessionOneRmSeconds: sessionOneRmSeconds ?? this.sessionOneRmSeconds,
      totalElapsedSeconds: totalElapsedSeconds ?? this.totalElapsedSeconds,
      lapCount: lapCount ?? this.lapCount,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (startedAt.present) {
      map['started_at'] = Variable<int>(startedAt.value);
    }
    if (endedAt.present) {
      map['ended_at'] = Variable<int>(endedAt.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (subCategory.present) {
      map['sub_category'] = Variable<String>(subCategory.value);
    }
    if (intent.present) {
      map['intent'] = Variable<String>(intent.value);
    }
    if (baselineAimSeconds.present) {
      map['baseline_aim_seconds'] = Variable<int>(baselineAimSeconds.value);
    }
    if (qualityScore.present) {
      map['quality_score'] = Variable<double>(qualityScore.value);
    }
    if (focusDensity.present) {
      map['focus_density'] = Variable<double>(focusDensity.value);
    }
    if (sessionOneRmSeconds.present) {
      map['session_one_rm_seconds'] = Variable<int>(sessionOneRmSeconds.value);
    }
    if (totalElapsedSeconds.present) {
      map['total_elapsed_seconds'] = Variable<int>(totalElapsedSeconds.value);
    }
    if (lapCount.present) {
      map['lap_count'] = Variable<int>(lapCount.value);
    }
    if (isCompleted.present) {
      map['is_completed'] = Variable<bool>(isCompleted.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SessionsCompanion(')
          ..write('id: $id, ')
          ..write('startedAt: $startedAt, ')
          ..write('endedAt: $endedAt, ')
          ..write('category: $category, ')
          ..write('subCategory: $subCategory, ')
          ..write('intent: $intent, ')
          ..write('baselineAimSeconds: $baselineAimSeconds, ')
          ..write('qualityScore: $qualityScore, ')
          ..write('focusDensity: $focusDensity, ')
          ..write('sessionOneRmSeconds: $sessionOneRmSeconds, ')
          ..write('totalElapsedSeconds: $totalElapsedSeconds, ')
          ..write('lapCount: $lapCount, ')
          ..write('isCompleted: $isCompleted')
          ..write(')'))
        .toString();
  }
}

class $LapsTable extends Laps with TableInfo<$LapsTable, Lap> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LapsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _sessionIdMeta =
      const VerificationMeta('sessionId');
  @override
  late final GeneratedColumn<int> sessionId = GeneratedColumn<int>(
      'session_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES sessions (id)'));
  static const VerificationMeta _occurredAtMeta =
      const VerificationMeta('occurredAt');
  @override
  late final GeneratedColumn<int> occurredAt = GeneratedColumn<int>(
      'occurred_at', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _triggerMeta =
      const VerificationMeta('trigger');
  @override
  late final GeneratedColumn<String> trigger = GeneratedColumn<String>(
      'trigger', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
      'note', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _lapDurationSecondsMeta =
      const VerificationMeta('lapDurationSeconds');
  @override
  late final GeneratedColumn<int> lapDurationSeconds = GeneratedColumn<int>(
      'lap_duration_seconds', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  @override
  List<GeneratedColumn> get $columns =>
      [id, sessionId, occurredAt, trigger, note, lapDurationSeconds];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'laps';
  @override
  VerificationContext validateIntegrity(Insertable<Lap> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('session_id')) {
      context.handle(_sessionIdMeta,
          sessionId.isAcceptableOrUnknown(data['session_id']!, _sessionIdMeta));
    } else if (isInserting) {
      context.missing(_sessionIdMeta);
    }
    if (data.containsKey('occurred_at')) {
      context.handle(
          _occurredAtMeta,
          occurredAt.isAcceptableOrUnknown(
              data['occurred_at']!, _occurredAtMeta));
    } else if (isInserting) {
      context.missing(_occurredAtMeta);
    }
    if (data.containsKey('trigger')) {
      context.handle(_triggerMeta,
          trigger.isAcceptableOrUnknown(data['trigger']!, _triggerMeta));
    } else if (isInserting) {
      context.missing(_triggerMeta);
    }
    if (data.containsKey('note')) {
      context.handle(
          _noteMeta, note.isAcceptableOrUnknown(data['note']!, _noteMeta));
    }
    if (data.containsKey('lap_duration_seconds')) {
      context.handle(
          _lapDurationSecondsMeta,
          lapDurationSeconds.isAcceptableOrUnknown(
              data['lap_duration_seconds']!, _lapDurationSecondsMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Lap map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Lap(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      sessionId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}session_id'])!,
      occurredAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}occurred_at'])!,
      trigger: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}trigger'])!,
      note: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}note']),
      lapDurationSeconds: attachedDatabase.typeMapping.read(
          DriftSqlType.int, data['${effectivePrefix}lap_duration_seconds'])!,
    );
  }

  @override
  $LapsTable createAlias(String alias) {
    return $LapsTable(attachedDatabase, alias);
  }
}

class Lap extends DataClass implements Insertable<Lap> {
  final int id;
  final int sessionId;

  /// Epoch ms when distraction occurred
  final int occurredAt;

  /// DistractionTrigger.name
  final String trigger;
  final String? note;

  /// Duration of the focus lap that just ended (seconds)
  final int lapDurationSeconds;
  const Lap(
      {required this.id,
      required this.sessionId,
      required this.occurredAt,
      required this.trigger,
      this.note,
      required this.lapDurationSeconds});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['session_id'] = Variable<int>(sessionId);
    map['occurred_at'] = Variable<int>(occurredAt);
    map['trigger'] = Variable<String>(trigger);
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    map['lap_duration_seconds'] = Variable<int>(lapDurationSeconds);
    return map;
  }

  LapsCompanion toCompanion(bool nullToAbsent) {
    return LapsCompanion(
      id: Value(id),
      sessionId: Value(sessionId),
      occurredAt: Value(occurredAt),
      trigger: Value(trigger),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      lapDurationSeconds: Value(lapDurationSeconds),
    );
  }

  factory Lap.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Lap(
      id: serializer.fromJson<int>(json['id']),
      sessionId: serializer.fromJson<int>(json['sessionId']),
      occurredAt: serializer.fromJson<int>(json['occurredAt']),
      trigger: serializer.fromJson<String>(json['trigger']),
      note: serializer.fromJson<String?>(json['note']),
      lapDurationSeconds: serializer.fromJson<int>(json['lapDurationSeconds']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'sessionId': serializer.toJson<int>(sessionId),
      'occurredAt': serializer.toJson<int>(occurredAt),
      'trigger': serializer.toJson<String>(trigger),
      'note': serializer.toJson<String?>(note),
      'lapDurationSeconds': serializer.toJson<int>(lapDurationSeconds),
    };
  }

  Lap copyWith(
          {int? id,
          int? sessionId,
          int? occurredAt,
          String? trigger,
          Value<String?> note = const Value.absent(),
          int? lapDurationSeconds}) =>
      Lap(
        id: id ?? this.id,
        sessionId: sessionId ?? this.sessionId,
        occurredAt: occurredAt ?? this.occurredAt,
        trigger: trigger ?? this.trigger,
        note: note.present ? note.value : this.note,
        lapDurationSeconds: lapDurationSeconds ?? this.lapDurationSeconds,
      );
  Lap copyWithCompanion(LapsCompanion data) {
    return Lap(
      id: data.id.present ? data.id.value : this.id,
      sessionId: data.sessionId.present ? data.sessionId.value : this.sessionId,
      occurredAt:
          data.occurredAt.present ? data.occurredAt.value : this.occurredAt,
      trigger: data.trigger.present ? data.trigger.value : this.trigger,
      note: data.note.present ? data.note.value : this.note,
      lapDurationSeconds: data.lapDurationSeconds.present
          ? data.lapDurationSeconds.value
          : this.lapDurationSeconds,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Lap(')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('occurredAt: $occurredAt, ')
          ..write('trigger: $trigger, ')
          ..write('note: $note, ')
          ..write('lapDurationSeconds: $lapDurationSeconds')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, sessionId, occurredAt, trigger, note, lapDurationSeconds);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Lap &&
          other.id == this.id &&
          other.sessionId == this.sessionId &&
          other.occurredAt == this.occurredAt &&
          other.trigger == this.trigger &&
          other.note == this.note &&
          other.lapDurationSeconds == this.lapDurationSeconds);
}

class LapsCompanion extends UpdateCompanion<Lap> {
  final Value<int> id;
  final Value<int> sessionId;
  final Value<int> occurredAt;
  final Value<String> trigger;
  final Value<String?> note;
  final Value<int> lapDurationSeconds;
  const LapsCompanion({
    this.id = const Value.absent(),
    this.sessionId = const Value.absent(),
    this.occurredAt = const Value.absent(),
    this.trigger = const Value.absent(),
    this.note = const Value.absent(),
    this.lapDurationSeconds = const Value.absent(),
  });
  LapsCompanion.insert({
    this.id = const Value.absent(),
    required int sessionId,
    required int occurredAt,
    required String trigger,
    this.note = const Value.absent(),
    this.lapDurationSeconds = const Value.absent(),
  })  : sessionId = Value(sessionId),
        occurredAt = Value(occurredAt),
        trigger = Value(trigger);
  static Insertable<Lap> custom({
    Expression<int>? id,
    Expression<int>? sessionId,
    Expression<int>? occurredAt,
    Expression<String>? trigger,
    Expression<String>? note,
    Expression<int>? lapDurationSeconds,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (sessionId != null) 'session_id': sessionId,
      if (occurredAt != null) 'occurred_at': occurredAt,
      if (trigger != null) 'trigger': trigger,
      if (note != null) 'note': note,
      if (lapDurationSeconds != null)
        'lap_duration_seconds': lapDurationSeconds,
    });
  }

  LapsCompanion copyWith(
      {Value<int>? id,
      Value<int>? sessionId,
      Value<int>? occurredAt,
      Value<String>? trigger,
      Value<String?>? note,
      Value<int>? lapDurationSeconds}) {
    return LapsCompanion(
      id: id ?? this.id,
      sessionId: sessionId ?? this.sessionId,
      occurredAt: occurredAt ?? this.occurredAt,
      trigger: trigger ?? this.trigger,
      note: note ?? this.note,
      lapDurationSeconds: lapDurationSeconds ?? this.lapDurationSeconds,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (sessionId.present) {
      map['session_id'] = Variable<int>(sessionId.value);
    }
    if (occurredAt.present) {
      map['occurred_at'] = Variable<int>(occurredAt.value);
    }
    if (trigger.present) {
      map['trigger'] = Variable<String>(trigger.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (lapDurationSeconds.present) {
      map['lap_duration_seconds'] = Variable<int>(lapDurationSeconds.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LapsCompanion(')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('occurredAt: $occurredAt, ')
          ..write('trigger: $trigger, ')
          ..write('note: $note, ')
          ..write('lapDurationSeconds: $lapDurationSeconds')
          ..write(')'))
        .toString();
  }
}

class $AppSettingsTable extends AppSettings
    with TableInfo<$AppSettingsTable, AppSetting> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AppSettingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _cloudSyncEnabledMeta =
      const VerificationMeta('cloudSyncEnabled');
  @override
  late final GeneratedColumn<bool> cloudSyncEnabled = GeneratedColumn<bool>(
      'cloud_sync_enabled', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("cloud_sync_enabled" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _localOnlyNotesMeta =
      const VerificationMeta('localOnlyNotes');
  @override
  late final GeneratedColumn<bool> localOnlyNotes = GeneratedColumn<bool>(
      'local_only_notes', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("local_only_notes" IN (0, 1))'),
      defaultValue: const Constant(true));
  static const VerificationMeta _highContrastMeta =
      const VerificationMeta('highContrast');
  @override
  late final GeneratedColumn<bool> highContrast = GeneratedColumn<bool>(
      'high_contrast', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("high_contrast" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _fontFamilyMeta =
      const VerificationMeta('fontFamily');
  @override
  late final GeneratedColumn<String> fontFamily = GeneratedColumn<String>(
      'font_family', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('Inter'));
  static const VerificationMeta _hasCompletedOnboardingMeta =
      const VerificationMeta('hasCompletedOnboarding');
  @override
  late final GeneratedColumn<bool> hasCompletedOnboarding =
      GeneratedColumn<bool>('has_completed_onboarding', aliasedName, false,
          type: DriftSqlType.bool,
          requiredDuringInsert: false,
          defaultConstraints: GeneratedColumn.constraintIsAlways(
              'CHECK ("has_completed_onboarding" IN (0, 1))'),
          defaultValue: const Constant(false));
  static const VerificationMeta _totalSessionCountMeta =
      const VerificationMeta('totalSessionCount');
  @override
  late final GeneratedColumn<int> totalSessionCount = GeneratedColumn<int>(
      'total_session_count', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        cloudSyncEnabled,
        localOnlyNotes,
        highContrast,
        fontFamily,
        hasCompletedOnboarding,
        totalSessionCount
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'app_settings';
  @override
  VerificationContext validateIntegrity(Insertable<AppSetting> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('cloud_sync_enabled')) {
      context.handle(
          _cloudSyncEnabledMeta,
          cloudSyncEnabled.isAcceptableOrUnknown(
              data['cloud_sync_enabled']!, _cloudSyncEnabledMeta));
    }
    if (data.containsKey('local_only_notes')) {
      context.handle(
          _localOnlyNotesMeta,
          localOnlyNotes.isAcceptableOrUnknown(
              data['local_only_notes']!, _localOnlyNotesMeta));
    }
    if (data.containsKey('high_contrast')) {
      context.handle(
          _highContrastMeta,
          highContrast.isAcceptableOrUnknown(
              data['high_contrast']!, _highContrastMeta));
    }
    if (data.containsKey('font_family')) {
      context.handle(
          _fontFamilyMeta,
          fontFamily.isAcceptableOrUnknown(
              data['font_family']!, _fontFamilyMeta));
    }
    if (data.containsKey('has_completed_onboarding')) {
      context.handle(
          _hasCompletedOnboardingMeta,
          hasCompletedOnboarding.isAcceptableOrUnknown(
              data['has_completed_onboarding']!, _hasCompletedOnboardingMeta));
    }
    if (data.containsKey('total_session_count')) {
      context.handle(
          _totalSessionCountMeta,
          totalSessionCount.isAcceptableOrUnknown(
              data['total_session_count']!, _totalSessionCountMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AppSetting map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AppSetting(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      cloudSyncEnabled: attachedDatabase.typeMapping.read(
          DriftSqlType.bool, data['${effectivePrefix}cloud_sync_enabled'])!,
      localOnlyNotes: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}local_only_notes'])!,
      highContrast: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}high_contrast'])!,
      fontFamily: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}font_family'])!,
      hasCompletedOnboarding: attachedDatabase.typeMapping.read(
          DriftSqlType.bool,
          data['${effectivePrefix}has_completed_onboarding'])!,
      totalSessionCount: attachedDatabase.typeMapping.read(
          DriftSqlType.int, data['${effectivePrefix}total_session_count'])!,
    );
  }

  @override
  $AppSettingsTable createAlias(String alias) {
    return $AppSettingsTable(attachedDatabase, alias);
  }
}

class AppSetting extends DataClass implements Insertable<AppSetting> {
  final int id;
  final bool cloudSyncEnabled;
  final bool localOnlyNotes;
  final bool highContrast;
  final String fontFamily;
  final bool hasCompletedOnboarding;
  final int totalSessionCount;
  const AppSetting(
      {required this.id,
      required this.cloudSyncEnabled,
      required this.localOnlyNotes,
      required this.highContrast,
      required this.fontFamily,
      required this.hasCompletedOnboarding,
      required this.totalSessionCount});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['cloud_sync_enabled'] = Variable<bool>(cloudSyncEnabled);
    map['local_only_notes'] = Variable<bool>(localOnlyNotes);
    map['high_contrast'] = Variable<bool>(highContrast);
    map['font_family'] = Variable<String>(fontFamily);
    map['has_completed_onboarding'] = Variable<bool>(hasCompletedOnboarding);
    map['total_session_count'] = Variable<int>(totalSessionCount);
    return map;
  }

  AppSettingsCompanion toCompanion(bool nullToAbsent) {
    return AppSettingsCompanion(
      id: Value(id),
      cloudSyncEnabled: Value(cloudSyncEnabled),
      localOnlyNotes: Value(localOnlyNotes),
      highContrast: Value(highContrast),
      fontFamily: Value(fontFamily),
      hasCompletedOnboarding: Value(hasCompletedOnboarding),
      totalSessionCount: Value(totalSessionCount),
    );
  }

  factory AppSetting.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AppSetting(
      id: serializer.fromJson<int>(json['id']),
      cloudSyncEnabled: serializer.fromJson<bool>(json['cloudSyncEnabled']),
      localOnlyNotes: serializer.fromJson<bool>(json['localOnlyNotes']),
      highContrast: serializer.fromJson<bool>(json['highContrast']),
      fontFamily: serializer.fromJson<String>(json['fontFamily']),
      hasCompletedOnboarding:
          serializer.fromJson<bool>(json['hasCompletedOnboarding']),
      totalSessionCount: serializer.fromJson<int>(json['totalSessionCount']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'cloudSyncEnabled': serializer.toJson<bool>(cloudSyncEnabled),
      'localOnlyNotes': serializer.toJson<bool>(localOnlyNotes),
      'highContrast': serializer.toJson<bool>(highContrast),
      'fontFamily': serializer.toJson<String>(fontFamily),
      'hasCompletedOnboarding': serializer.toJson<bool>(hasCompletedOnboarding),
      'totalSessionCount': serializer.toJson<int>(totalSessionCount),
    };
  }

  AppSetting copyWith(
          {int? id,
          bool? cloudSyncEnabled,
          bool? localOnlyNotes,
          bool? highContrast,
          String? fontFamily,
          bool? hasCompletedOnboarding,
          int? totalSessionCount}) =>
      AppSetting(
        id: id ?? this.id,
        cloudSyncEnabled: cloudSyncEnabled ?? this.cloudSyncEnabled,
        localOnlyNotes: localOnlyNotes ?? this.localOnlyNotes,
        highContrast: highContrast ?? this.highContrast,
        fontFamily: fontFamily ?? this.fontFamily,
        hasCompletedOnboarding:
            hasCompletedOnboarding ?? this.hasCompletedOnboarding,
        totalSessionCount: totalSessionCount ?? this.totalSessionCount,
      );
  AppSetting copyWithCompanion(AppSettingsCompanion data) {
    return AppSetting(
      id: data.id.present ? data.id.value : this.id,
      cloudSyncEnabled: data.cloudSyncEnabled.present
          ? data.cloudSyncEnabled.value
          : this.cloudSyncEnabled,
      localOnlyNotes: data.localOnlyNotes.present
          ? data.localOnlyNotes.value
          : this.localOnlyNotes,
      highContrast: data.highContrast.present
          ? data.highContrast.value
          : this.highContrast,
      fontFamily:
          data.fontFamily.present ? data.fontFamily.value : this.fontFamily,
      hasCompletedOnboarding: data.hasCompletedOnboarding.present
          ? data.hasCompletedOnboarding.value
          : this.hasCompletedOnboarding,
      totalSessionCount: data.totalSessionCount.present
          ? data.totalSessionCount.value
          : this.totalSessionCount,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AppSetting(')
          ..write('id: $id, ')
          ..write('cloudSyncEnabled: $cloudSyncEnabled, ')
          ..write('localOnlyNotes: $localOnlyNotes, ')
          ..write('highContrast: $highContrast, ')
          ..write('fontFamily: $fontFamily, ')
          ..write('hasCompletedOnboarding: $hasCompletedOnboarding, ')
          ..write('totalSessionCount: $totalSessionCount')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, cloudSyncEnabled, localOnlyNotes,
      highContrast, fontFamily, hasCompletedOnboarding, totalSessionCount);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AppSetting &&
          other.id == this.id &&
          other.cloudSyncEnabled == this.cloudSyncEnabled &&
          other.localOnlyNotes == this.localOnlyNotes &&
          other.highContrast == this.highContrast &&
          other.fontFamily == this.fontFamily &&
          other.hasCompletedOnboarding == this.hasCompletedOnboarding &&
          other.totalSessionCount == this.totalSessionCount);
}

class AppSettingsCompanion extends UpdateCompanion<AppSetting> {
  final Value<int> id;
  final Value<bool> cloudSyncEnabled;
  final Value<bool> localOnlyNotes;
  final Value<bool> highContrast;
  final Value<String> fontFamily;
  final Value<bool> hasCompletedOnboarding;
  final Value<int> totalSessionCount;
  const AppSettingsCompanion({
    this.id = const Value.absent(),
    this.cloudSyncEnabled = const Value.absent(),
    this.localOnlyNotes = const Value.absent(),
    this.highContrast = const Value.absent(),
    this.fontFamily = const Value.absent(),
    this.hasCompletedOnboarding = const Value.absent(),
    this.totalSessionCount = const Value.absent(),
  });
  AppSettingsCompanion.insert({
    this.id = const Value.absent(),
    this.cloudSyncEnabled = const Value.absent(),
    this.localOnlyNotes = const Value.absent(),
    this.highContrast = const Value.absent(),
    this.fontFamily = const Value.absent(),
    this.hasCompletedOnboarding = const Value.absent(),
    this.totalSessionCount = const Value.absent(),
  });
  static Insertable<AppSetting> custom({
    Expression<int>? id,
    Expression<bool>? cloudSyncEnabled,
    Expression<bool>? localOnlyNotes,
    Expression<bool>? highContrast,
    Expression<String>? fontFamily,
    Expression<bool>? hasCompletedOnboarding,
    Expression<int>? totalSessionCount,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (cloudSyncEnabled != null) 'cloud_sync_enabled': cloudSyncEnabled,
      if (localOnlyNotes != null) 'local_only_notes': localOnlyNotes,
      if (highContrast != null) 'high_contrast': highContrast,
      if (fontFamily != null) 'font_family': fontFamily,
      if (hasCompletedOnboarding != null)
        'has_completed_onboarding': hasCompletedOnboarding,
      if (totalSessionCount != null) 'total_session_count': totalSessionCount,
    });
  }

  AppSettingsCompanion copyWith(
      {Value<int>? id,
      Value<bool>? cloudSyncEnabled,
      Value<bool>? localOnlyNotes,
      Value<bool>? highContrast,
      Value<String>? fontFamily,
      Value<bool>? hasCompletedOnboarding,
      Value<int>? totalSessionCount}) {
    return AppSettingsCompanion(
      id: id ?? this.id,
      cloudSyncEnabled: cloudSyncEnabled ?? this.cloudSyncEnabled,
      localOnlyNotes: localOnlyNotes ?? this.localOnlyNotes,
      highContrast: highContrast ?? this.highContrast,
      fontFamily: fontFamily ?? this.fontFamily,
      hasCompletedOnboarding:
          hasCompletedOnboarding ?? this.hasCompletedOnboarding,
      totalSessionCount: totalSessionCount ?? this.totalSessionCount,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (cloudSyncEnabled.present) {
      map['cloud_sync_enabled'] = Variable<bool>(cloudSyncEnabled.value);
    }
    if (localOnlyNotes.present) {
      map['local_only_notes'] = Variable<bool>(localOnlyNotes.value);
    }
    if (highContrast.present) {
      map['high_contrast'] = Variable<bool>(highContrast.value);
    }
    if (fontFamily.present) {
      map['font_family'] = Variable<String>(fontFamily.value);
    }
    if (hasCompletedOnboarding.present) {
      map['has_completed_onboarding'] =
          Variable<bool>(hasCompletedOnboarding.value);
    }
    if (totalSessionCount.present) {
      map['total_session_count'] = Variable<int>(totalSessionCount.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AppSettingsCompanion(')
          ..write('id: $id, ')
          ..write('cloudSyncEnabled: $cloudSyncEnabled, ')
          ..write('localOnlyNotes: $localOnlyNotes, ')
          ..write('highContrast: $highContrast, ')
          ..write('fontFamily: $fontFamily, ')
          ..write('hasCompletedOnboarding: $hasCompletedOnboarding, ')
          ..write('totalSessionCount: $totalSessionCount')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $SessionsTable sessions = $SessionsTable(this);
  late final $LapsTable laps = $LapsTable(this);
  late final $AppSettingsTable appSettings = $AppSettingsTable(this);
  late final SessionDao sessionDao = SessionDao(this as AppDatabase);
  late final LapDao lapDao = LapDao(this as AppDatabase);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities =>
      [sessions, laps, appSettings];
}

typedef $$SessionsTableCreateCompanionBuilder = SessionsCompanion Function({
  Value<int> id,
  required int startedAt,
  Value<int?> endedAt,
  required String category,
  Value<String?> subCategory,
  Value<String?> intent,
  Value<int> baselineAimSeconds,
  Value<double> qualityScore,
  Value<double> focusDensity,
  Value<int> sessionOneRmSeconds,
  Value<int> totalElapsedSeconds,
  Value<int> lapCount,
  Value<bool> isCompleted,
});
typedef $$SessionsTableUpdateCompanionBuilder = SessionsCompanion Function({
  Value<int> id,
  Value<int> startedAt,
  Value<int?> endedAt,
  Value<String> category,
  Value<String?> subCategory,
  Value<String?> intent,
  Value<int> baselineAimSeconds,
  Value<double> qualityScore,
  Value<double> focusDensity,
  Value<int> sessionOneRmSeconds,
  Value<int> totalElapsedSeconds,
  Value<int> lapCount,
  Value<bool> isCompleted,
});

final class $$SessionsTableReferences
    extends BaseReferences<_$AppDatabase, $SessionsTable, Session> {
  $$SessionsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$LapsTable, List<Lap>> _lapsRefsTable(
          _$AppDatabase db) =>
      MultiTypedResultKey.fromTable(db.laps,
          aliasName: $_aliasNameGenerator(db.sessions.id, db.laps.sessionId));

  $$LapsTableProcessedTableManager get lapsRefs {
    final manager = $$LapsTableTableManager($_db, $_db.laps)
        .filter((f) => f.sessionId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_lapsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$SessionsTableFilterComposer
    extends Composer<_$AppDatabase, $SessionsTable> {
  $$SessionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get startedAt => $composableBuilder(
      column: $table.startedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get endedAt => $composableBuilder(
      column: $table.endedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get category => $composableBuilder(
      column: $table.category, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get subCategory => $composableBuilder(
      column: $table.subCategory, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get intent => $composableBuilder(
      column: $table.intent, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get baselineAimSeconds => $composableBuilder(
      column: $table.baselineAimSeconds,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get qualityScore => $composableBuilder(
      column: $table.qualityScore, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get focusDensity => $composableBuilder(
      column: $table.focusDensity, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get sessionOneRmSeconds => $composableBuilder(
      column: $table.sessionOneRmSeconds,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get totalElapsedSeconds => $composableBuilder(
      column: $table.totalElapsedSeconds,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get lapCount => $composableBuilder(
      column: $table.lapCount, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isCompleted => $composableBuilder(
      column: $table.isCompleted, builder: (column) => ColumnFilters(column));

  Expression<bool> lapsRefs(
      Expression<bool> Function($$LapsTableFilterComposer f) f) {
    final $$LapsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.laps,
        getReferencedColumn: (t) => t.sessionId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$LapsTableFilterComposer(
              $db: $db,
              $table: $db.laps,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$SessionsTableOrderingComposer
    extends Composer<_$AppDatabase, $SessionsTable> {
  $$SessionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get startedAt => $composableBuilder(
      column: $table.startedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get endedAt => $composableBuilder(
      column: $table.endedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get category => $composableBuilder(
      column: $table.category, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get subCategory => $composableBuilder(
      column: $table.subCategory, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get intent => $composableBuilder(
      column: $table.intent, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get baselineAimSeconds => $composableBuilder(
      column: $table.baselineAimSeconds,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get qualityScore => $composableBuilder(
      column: $table.qualityScore,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get focusDensity => $composableBuilder(
      column: $table.focusDensity,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get sessionOneRmSeconds => $composableBuilder(
      column: $table.sessionOneRmSeconds,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get totalElapsedSeconds => $composableBuilder(
      column: $table.totalElapsedSeconds,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get lapCount => $composableBuilder(
      column: $table.lapCount, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isCompleted => $composableBuilder(
      column: $table.isCompleted, builder: (column) => ColumnOrderings(column));
}

class $$SessionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SessionsTable> {
  $$SessionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get startedAt =>
      $composableBuilder(column: $table.startedAt, builder: (column) => column);

  GeneratedColumn<int> get endedAt =>
      $composableBuilder(column: $table.endedAt, builder: (column) => column);

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<String> get subCategory => $composableBuilder(
      column: $table.subCategory, builder: (column) => column);

  GeneratedColumn<String> get intent =>
      $composableBuilder(column: $table.intent, builder: (column) => column);

  GeneratedColumn<int> get baselineAimSeconds => $composableBuilder(
      column: $table.baselineAimSeconds, builder: (column) => column);

  GeneratedColumn<double> get qualityScore => $composableBuilder(
      column: $table.qualityScore, builder: (column) => column);

  GeneratedColumn<double> get focusDensity => $composableBuilder(
      column: $table.focusDensity, builder: (column) => column);

  GeneratedColumn<int> get sessionOneRmSeconds => $composableBuilder(
      column: $table.sessionOneRmSeconds, builder: (column) => column);

  GeneratedColumn<int> get totalElapsedSeconds => $composableBuilder(
      column: $table.totalElapsedSeconds, builder: (column) => column);

  GeneratedColumn<int> get lapCount =>
      $composableBuilder(column: $table.lapCount, builder: (column) => column);

  GeneratedColumn<bool> get isCompleted => $composableBuilder(
      column: $table.isCompleted, builder: (column) => column);

  Expression<T> lapsRefs<T extends Object>(
      Expression<T> Function($$LapsTableAnnotationComposer a) f) {
    final $$LapsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.laps,
        getReferencedColumn: (t) => t.sessionId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$LapsTableAnnotationComposer(
              $db: $db,
              $table: $db.laps,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$SessionsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $SessionsTable,
    Session,
    $$SessionsTableFilterComposer,
    $$SessionsTableOrderingComposer,
    $$SessionsTableAnnotationComposer,
    $$SessionsTableCreateCompanionBuilder,
    $$SessionsTableUpdateCompanionBuilder,
    (Session, $$SessionsTableReferences),
    Session,
    PrefetchHooks Function({bool lapsRefs})> {
  $$SessionsTableTableManager(_$AppDatabase db, $SessionsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SessionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SessionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SessionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> startedAt = const Value.absent(),
            Value<int?> endedAt = const Value.absent(),
            Value<String> category = const Value.absent(),
            Value<String?> subCategory = const Value.absent(),
            Value<String?> intent = const Value.absent(),
            Value<int> baselineAimSeconds = const Value.absent(),
            Value<double> qualityScore = const Value.absent(),
            Value<double> focusDensity = const Value.absent(),
            Value<int> sessionOneRmSeconds = const Value.absent(),
            Value<int> totalElapsedSeconds = const Value.absent(),
            Value<int> lapCount = const Value.absent(),
            Value<bool> isCompleted = const Value.absent(),
          }) =>
              SessionsCompanion(
            id: id,
            startedAt: startedAt,
            endedAt: endedAt,
            category: category,
            subCategory: subCategory,
            intent: intent,
            baselineAimSeconds: baselineAimSeconds,
            qualityScore: qualityScore,
            focusDensity: focusDensity,
            sessionOneRmSeconds: sessionOneRmSeconds,
            totalElapsedSeconds: totalElapsedSeconds,
            lapCount: lapCount,
            isCompleted: isCompleted,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int startedAt,
            Value<int?> endedAt = const Value.absent(),
            required String category,
            Value<String?> subCategory = const Value.absent(),
            Value<String?> intent = const Value.absent(),
            Value<int> baselineAimSeconds = const Value.absent(),
            Value<double> qualityScore = const Value.absent(),
            Value<double> focusDensity = const Value.absent(),
            Value<int> sessionOneRmSeconds = const Value.absent(),
            Value<int> totalElapsedSeconds = const Value.absent(),
            Value<int> lapCount = const Value.absent(),
            Value<bool> isCompleted = const Value.absent(),
          }) =>
              SessionsCompanion.insert(
            id: id,
            startedAt: startedAt,
            endedAt: endedAt,
            category: category,
            subCategory: subCategory,
            intent: intent,
            baselineAimSeconds: baselineAimSeconds,
            qualityScore: qualityScore,
            focusDensity: focusDensity,
            sessionOneRmSeconds: sessionOneRmSeconds,
            totalElapsedSeconds: totalElapsedSeconds,
            lapCount: lapCount,
            isCompleted: isCompleted,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) =>
                  (e.readTable(table), $$SessionsTableReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: ({lapsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (lapsRefs) db.laps],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (lapsRefs)
                    await $_getPrefetchedData<Session, $SessionsTable, Lap>(
                        currentTable: table,
                        referencedTable:
                            $$SessionsTableReferences._lapsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$SessionsTableReferences(db, table, p0).lapsRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.sessionId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$SessionsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $SessionsTable,
    Session,
    $$SessionsTableFilterComposer,
    $$SessionsTableOrderingComposer,
    $$SessionsTableAnnotationComposer,
    $$SessionsTableCreateCompanionBuilder,
    $$SessionsTableUpdateCompanionBuilder,
    (Session, $$SessionsTableReferences),
    Session,
    PrefetchHooks Function({bool lapsRefs})>;
typedef $$LapsTableCreateCompanionBuilder = LapsCompanion Function({
  Value<int> id,
  required int sessionId,
  required int occurredAt,
  required String trigger,
  Value<String?> note,
  Value<int> lapDurationSeconds,
});
typedef $$LapsTableUpdateCompanionBuilder = LapsCompanion Function({
  Value<int> id,
  Value<int> sessionId,
  Value<int> occurredAt,
  Value<String> trigger,
  Value<String?> note,
  Value<int> lapDurationSeconds,
});

final class $$LapsTableReferences
    extends BaseReferences<_$AppDatabase, $LapsTable, Lap> {
  $$LapsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $SessionsTable _sessionIdTable(_$AppDatabase db) => db.sessions
      .createAlias($_aliasNameGenerator(db.laps.sessionId, db.sessions.id));

  $$SessionsTableProcessedTableManager get sessionId {
    final $_column = $_itemColumn<int>('session_id')!;

    final manager = $$SessionsTableTableManager($_db, $_db.sessions)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_sessionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$LapsTableFilterComposer extends Composer<_$AppDatabase, $LapsTable> {
  $$LapsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get occurredAt => $composableBuilder(
      column: $table.occurredAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get trigger => $composableBuilder(
      column: $table.trigger, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get note => $composableBuilder(
      column: $table.note, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get lapDurationSeconds => $composableBuilder(
      column: $table.lapDurationSeconds,
      builder: (column) => ColumnFilters(column));

  $$SessionsTableFilterComposer get sessionId {
    final $$SessionsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.sessionId,
        referencedTable: $db.sessions,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SessionsTableFilterComposer(
              $db: $db,
              $table: $db.sessions,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$LapsTableOrderingComposer extends Composer<_$AppDatabase, $LapsTable> {
  $$LapsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get occurredAt => $composableBuilder(
      column: $table.occurredAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get trigger => $composableBuilder(
      column: $table.trigger, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get note => $composableBuilder(
      column: $table.note, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get lapDurationSeconds => $composableBuilder(
      column: $table.lapDurationSeconds,
      builder: (column) => ColumnOrderings(column));

  $$SessionsTableOrderingComposer get sessionId {
    final $$SessionsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.sessionId,
        referencedTable: $db.sessions,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SessionsTableOrderingComposer(
              $db: $db,
              $table: $db.sessions,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$LapsTableAnnotationComposer
    extends Composer<_$AppDatabase, $LapsTable> {
  $$LapsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get occurredAt => $composableBuilder(
      column: $table.occurredAt, builder: (column) => column);

  GeneratedColumn<String> get trigger =>
      $composableBuilder(column: $table.trigger, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<int> get lapDurationSeconds => $composableBuilder(
      column: $table.lapDurationSeconds, builder: (column) => column);

  $$SessionsTableAnnotationComposer get sessionId {
    final $$SessionsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.sessionId,
        referencedTable: $db.sessions,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SessionsTableAnnotationComposer(
              $db: $db,
              $table: $db.sessions,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$LapsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $LapsTable,
    Lap,
    $$LapsTableFilterComposer,
    $$LapsTableOrderingComposer,
    $$LapsTableAnnotationComposer,
    $$LapsTableCreateCompanionBuilder,
    $$LapsTableUpdateCompanionBuilder,
    (Lap, $$LapsTableReferences),
    Lap,
    PrefetchHooks Function({bool sessionId})> {
  $$LapsTableTableManager(_$AppDatabase db, $LapsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LapsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LapsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LapsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> sessionId = const Value.absent(),
            Value<int> occurredAt = const Value.absent(),
            Value<String> trigger = const Value.absent(),
            Value<String?> note = const Value.absent(),
            Value<int> lapDurationSeconds = const Value.absent(),
          }) =>
              LapsCompanion(
            id: id,
            sessionId: sessionId,
            occurredAt: occurredAt,
            trigger: trigger,
            note: note,
            lapDurationSeconds: lapDurationSeconds,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int sessionId,
            required int occurredAt,
            required String trigger,
            Value<String?> note = const Value.absent(),
            Value<int> lapDurationSeconds = const Value.absent(),
          }) =>
              LapsCompanion.insert(
            id: id,
            sessionId: sessionId,
            occurredAt: occurredAt,
            trigger: trigger,
            note: note,
            lapDurationSeconds: lapDurationSeconds,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) =>
                  (e.readTable(table), $$LapsTableReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: ({sessionId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
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
                      dynamic>>(state) {
                if (sessionId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.sessionId,
                    referencedTable: $$LapsTableReferences._sessionIdTable(db),
                    referencedColumn:
                        $$LapsTableReferences._sessionIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$LapsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $LapsTable,
    Lap,
    $$LapsTableFilterComposer,
    $$LapsTableOrderingComposer,
    $$LapsTableAnnotationComposer,
    $$LapsTableCreateCompanionBuilder,
    $$LapsTableUpdateCompanionBuilder,
    (Lap, $$LapsTableReferences),
    Lap,
    PrefetchHooks Function({bool sessionId})>;
typedef $$AppSettingsTableCreateCompanionBuilder = AppSettingsCompanion
    Function({
  Value<int> id,
  Value<bool> cloudSyncEnabled,
  Value<bool> localOnlyNotes,
  Value<bool> highContrast,
  Value<String> fontFamily,
  Value<bool> hasCompletedOnboarding,
  Value<int> totalSessionCount,
});
typedef $$AppSettingsTableUpdateCompanionBuilder = AppSettingsCompanion
    Function({
  Value<int> id,
  Value<bool> cloudSyncEnabled,
  Value<bool> localOnlyNotes,
  Value<bool> highContrast,
  Value<String> fontFamily,
  Value<bool> hasCompletedOnboarding,
  Value<int> totalSessionCount,
});

class $$AppSettingsTableFilterComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get cloudSyncEnabled => $composableBuilder(
      column: $table.cloudSyncEnabled,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get localOnlyNotes => $composableBuilder(
      column: $table.localOnlyNotes,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get highContrast => $composableBuilder(
      column: $table.highContrast, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get fontFamily => $composableBuilder(
      column: $table.fontFamily, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get hasCompletedOnboarding => $composableBuilder(
      column: $table.hasCompletedOnboarding,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get totalSessionCount => $composableBuilder(
      column: $table.totalSessionCount,
      builder: (column) => ColumnFilters(column));
}

class $$AppSettingsTableOrderingComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get cloudSyncEnabled => $composableBuilder(
      column: $table.cloudSyncEnabled,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get localOnlyNotes => $composableBuilder(
      column: $table.localOnlyNotes,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get highContrast => $composableBuilder(
      column: $table.highContrast,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get fontFamily => $composableBuilder(
      column: $table.fontFamily, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get hasCompletedOnboarding => $composableBuilder(
      column: $table.hasCompletedOnboarding,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get totalSessionCount => $composableBuilder(
      column: $table.totalSessionCount,
      builder: (column) => ColumnOrderings(column));
}

class $$AppSettingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<bool> get cloudSyncEnabled => $composableBuilder(
      column: $table.cloudSyncEnabled, builder: (column) => column);

  GeneratedColumn<bool> get localOnlyNotes => $composableBuilder(
      column: $table.localOnlyNotes, builder: (column) => column);

  GeneratedColumn<bool> get highContrast => $composableBuilder(
      column: $table.highContrast, builder: (column) => column);

  GeneratedColumn<String> get fontFamily => $composableBuilder(
      column: $table.fontFamily, builder: (column) => column);

  GeneratedColumn<bool> get hasCompletedOnboarding => $composableBuilder(
      column: $table.hasCompletedOnboarding, builder: (column) => column);

  GeneratedColumn<int> get totalSessionCount => $composableBuilder(
      column: $table.totalSessionCount, builder: (column) => column);
}

class $$AppSettingsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $AppSettingsTable,
    AppSetting,
    $$AppSettingsTableFilterComposer,
    $$AppSettingsTableOrderingComposer,
    $$AppSettingsTableAnnotationComposer,
    $$AppSettingsTableCreateCompanionBuilder,
    $$AppSettingsTableUpdateCompanionBuilder,
    (AppSetting, BaseReferences<_$AppDatabase, $AppSettingsTable, AppSetting>),
    AppSetting,
    PrefetchHooks Function()> {
  $$AppSettingsTableTableManager(_$AppDatabase db, $AppSettingsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AppSettingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AppSettingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AppSettingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<bool> cloudSyncEnabled = const Value.absent(),
            Value<bool> localOnlyNotes = const Value.absent(),
            Value<bool> highContrast = const Value.absent(),
            Value<String> fontFamily = const Value.absent(),
            Value<bool> hasCompletedOnboarding = const Value.absent(),
            Value<int> totalSessionCount = const Value.absent(),
          }) =>
              AppSettingsCompanion(
            id: id,
            cloudSyncEnabled: cloudSyncEnabled,
            localOnlyNotes: localOnlyNotes,
            highContrast: highContrast,
            fontFamily: fontFamily,
            hasCompletedOnboarding: hasCompletedOnboarding,
            totalSessionCount: totalSessionCount,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<bool> cloudSyncEnabled = const Value.absent(),
            Value<bool> localOnlyNotes = const Value.absent(),
            Value<bool> highContrast = const Value.absent(),
            Value<String> fontFamily = const Value.absent(),
            Value<bool> hasCompletedOnboarding = const Value.absent(),
            Value<int> totalSessionCount = const Value.absent(),
          }) =>
              AppSettingsCompanion.insert(
            id: id,
            cloudSyncEnabled: cloudSyncEnabled,
            localOnlyNotes: localOnlyNotes,
            highContrast: highContrast,
            fontFamily: fontFamily,
            hasCompletedOnboarding: hasCompletedOnboarding,
            totalSessionCount: totalSessionCount,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$AppSettingsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $AppSettingsTable,
    AppSetting,
    $$AppSettingsTableFilterComposer,
    $$AppSettingsTableOrderingComposer,
    $$AppSettingsTableAnnotationComposer,
    $$AppSettingsTableCreateCompanionBuilder,
    $$AppSettingsTableUpdateCompanionBuilder,
    (AppSetting, BaseReferences<_$AppDatabase, $AppSettingsTable, AppSetting>),
    AppSetting,
    PrefetchHooks Function()>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$SessionsTableTableManager get sessions =>
      $$SessionsTableTableManager(_db, _db.sessions);
  $$LapsTableTableManager get laps => $$LapsTableTableManager(_db, _db.laps);
  $$AppSettingsTableTableManager get appSettings =>
      $$AppSettingsTableTableManager(_db, _db.appSettings);
}
