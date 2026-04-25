// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $KanjiCardTableTable extends KanjiCardTable
    with TableInfo<$KanjiCardTableTable, KanjiCardData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $KanjiCardTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _kanjiMeta = const VerificationMeta('kanji');
  @override
  late final GeneratedColumn<String> kanji = GeneratedColumn<String>(
    'kanji',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _meaningsMeta = const VerificationMeta(
    'meanings',
  );
  @override
  late final GeneratedColumn<String> meanings = GeneratedColumn<String>(
    'meanings',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _onyomiMeta = const VerificationMeta('onyomi');
  @override
  late final GeneratedColumn<String> onyomi = GeneratedColumn<String>(
    'onyomi',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _kunyomiMeta = const VerificationMeta(
    'kunyomi',
  );
  @override
  late final GeneratedColumn<String> kunyomi = GeneratedColumn<String>(
    'kunyomi',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _strokeDataMeta = const VerificationMeta(
    'strokeData',
  );
  @override
  late final GeneratedColumn<String> strokeData = GeneratedColumn<String>(
    'stroke_data',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _jlptLevelMeta = const VerificationMeta(
    'jlptLevel',
  );
  @override
  late final GeneratedColumn<int> jlptLevel = GeneratedColumn<int>(
    'jlpt_level',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(5),
  );
  static const VerificationMeta _stabilityMeta = const VerificationMeta(
    'stability',
  );
  @override
  late final GeneratedColumn<double> stability = GeneratedColumn<double>(
    'stability',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _difficultyMeta = const VerificationMeta(
    'difficulty',
  );
  @override
  late final GeneratedColumn<double> difficulty = GeneratedColumn<double>(
    'difficulty',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _lastReviewMeta = const VerificationMeta(
    'lastReview',
  );
  @override
  late final GeneratedColumn<DateTime> lastReview = GeneratedColumn<DateTime>(
    'last_review',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _nextReviewMeta = const VerificationMeta(
    'nextReview',
  );
  @override
  late final GeneratedColumn<DateTime> nextReview = GeneratedColumn<DateTime>(
    'next_review',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _repsMeta = const VerificationMeta('reps');
  @override
  late final GeneratedColumn<int> reps = GeneratedColumn<int>(
    'reps',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _lapsesMeta = const VerificationMeta('lapses');
  @override
  late final GeneratedColumn<int> lapses = GeneratedColumn<int>(
    'lapses',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _stateMeta = const VerificationMeta('state');
  @override
  late final GeneratedColumn<int> state = GeneratedColumn<int>(
    'state',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    kanji,
    meanings,
    onyomi,
    kunyomi,
    strokeData,
    jlptLevel,
    stability,
    difficulty,
    lastReview,
    nextReview,
    reps,
    lapses,
    state,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'kanji_card_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<KanjiCardData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('kanji')) {
      context.handle(
        _kanjiMeta,
        kanji.isAcceptableOrUnknown(data['kanji']!, _kanjiMeta),
      );
    } else if (isInserting) {
      context.missing(_kanjiMeta);
    }
    if (data.containsKey('meanings')) {
      context.handle(
        _meaningsMeta,
        meanings.isAcceptableOrUnknown(data['meanings']!, _meaningsMeta),
      );
    } else if (isInserting) {
      context.missing(_meaningsMeta);
    }
    if (data.containsKey('onyomi')) {
      context.handle(
        _onyomiMeta,
        onyomi.isAcceptableOrUnknown(data['onyomi']!, _onyomiMeta),
      );
    } else if (isInserting) {
      context.missing(_onyomiMeta);
    }
    if (data.containsKey('kunyomi')) {
      context.handle(
        _kunyomiMeta,
        kunyomi.isAcceptableOrUnknown(data['kunyomi']!, _kunyomiMeta),
      );
    } else if (isInserting) {
      context.missing(_kunyomiMeta);
    }
    if (data.containsKey('stroke_data')) {
      context.handle(
        _strokeDataMeta,
        strokeData.isAcceptableOrUnknown(data['stroke_data']!, _strokeDataMeta),
      );
    }
    if (data.containsKey('jlpt_level')) {
      context.handle(
        _jlptLevelMeta,
        jlptLevel.isAcceptableOrUnknown(data['jlpt_level']!, _jlptLevelMeta),
      );
    }
    if (data.containsKey('stability')) {
      context.handle(
        _stabilityMeta,
        stability.isAcceptableOrUnknown(data['stability']!, _stabilityMeta),
      );
    }
    if (data.containsKey('difficulty')) {
      context.handle(
        _difficultyMeta,
        difficulty.isAcceptableOrUnknown(data['difficulty']!, _difficultyMeta),
      );
    }
    if (data.containsKey('last_review')) {
      context.handle(
        _lastReviewMeta,
        lastReview.isAcceptableOrUnknown(data['last_review']!, _lastReviewMeta),
      );
    }
    if (data.containsKey('next_review')) {
      context.handle(
        _nextReviewMeta,
        nextReview.isAcceptableOrUnknown(data['next_review']!, _nextReviewMeta),
      );
    } else if (isInserting) {
      context.missing(_nextReviewMeta);
    }
    if (data.containsKey('reps')) {
      context.handle(
        _repsMeta,
        reps.isAcceptableOrUnknown(data['reps']!, _repsMeta),
      );
    }
    if (data.containsKey('lapses')) {
      context.handle(
        _lapsesMeta,
        lapses.isAcceptableOrUnknown(data['lapses']!, _lapsesMeta),
      );
    }
    if (data.containsKey('state')) {
      context.handle(
        _stateMeta,
        state.isAcceptableOrUnknown(data['state']!, _stateMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  KanjiCardData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return KanjiCardData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      kanji: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}kanji'],
      )!,
      meanings: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}meanings'],
      )!,
      onyomi: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}onyomi'],
      )!,
      kunyomi: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}kunyomi'],
      )!,
      strokeData: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}stroke_data'],
      ),
      jlptLevel: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}jlpt_level'],
      )!,
      stability: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}stability'],
      )!,
      difficulty: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}difficulty'],
      )!,
      lastReview: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_review'],
      ),
      nextReview: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}next_review'],
      )!,
      reps: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}reps'],
      )!,
      lapses: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}lapses'],
      )!,
      state: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}state'],
      )!,
    );
  }

  @override
  $KanjiCardTableTable createAlias(String alias) {
    return $KanjiCardTableTable(attachedDatabase, alias);
  }
}

class KanjiCardData extends DataClass implements Insertable<KanjiCardData> {
  final String id;
  final String kanji;
  final String meanings;
  final String onyomi;
  final String kunyomi;
  final String? strokeData;
  final int jlptLevel;
  final double stability;
  final double difficulty;
  final DateTime? lastReview;
  final DateTime nextReview;
  final int reps;
  final int lapses;
  final int state;
  const KanjiCardData({
    required this.id,
    required this.kanji,
    required this.meanings,
    required this.onyomi,
    required this.kunyomi,
    this.strokeData,
    required this.jlptLevel,
    required this.stability,
    required this.difficulty,
    this.lastReview,
    required this.nextReview,
    required this.reps,
    required this.lapses,
    required this.state,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['kanji'] = Variable<String>(kanji);
    map['meanings'] = Variable<String>(meanings);
    map['onyomi'] = Variable<String>(onyomi);
    map['kunyomi'] = Variable<String>(kunyomi);
    if (!nullToAbsent || strokeData != null) {
      map['stroke_data'] = Variable<String>(strokeData);
    }
    map['jlpt_level'] = Variable<int>(jlptLevel);
    map['stability'] = Variable<double>(stability);
    map['difficulty'] = Variable<double>(difficulty);
    if (!nullToAbsent || lastReview != null) {
      map['last_review'] = Variable<DateTime>(lastReview);
    }
    map['next_review'] = Variable<DateTime>(nextReview);
    map['reps'] = Variable<int>(reps);
    map['lapses'] = Variable<int>(lapses);
    map['state'] = Variable<int>(state);
    return map;
  }

  KanjiCardTableCompanion toCompanion(bool nullToAbsent) {
    return KanjiCardTableCompanion(
      id: Value(id),
      kanji: Value(kanji),
      meanings: Value(meanings),
      onyomi: Value(onyomi),
      kunyomi: Value(kunyomi),
      strokeData: strokeData == null && nullToAbsent
          ? const Value.absent()
          : Value(strokeData),
      jlptLevel: Value(jlptLevel),
      stability: Value(stability),
      difficulty: Value(difficulty),
      lastReview: lastReview == null && nullToAbsent
          ? const Value.absent()
          : Value(lastReview),
      nextReview: Value(nextReview),
      reps: Value(reps),
      lapses: Value(lapses),
      state: Value(state),
    );
  }

  factory KanjiCardData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return KanjiCardData(
      id: serializer.fromJson<String>(json['id']),
      kanji: serializer.fromJson<String>(json['kanji']),
      meanings: serializer.fromJson<String>(json['meanings']),
      onyomi: serializer.fromJson<String>(json['onyomi']),
      kunyomi: serializer.fromJson<String>(json['kunyomi']),
      strokeData: serializer.fromJson<String?>(json['strokeData']),
      jlptLevel: serializer.fromJson<int>(json['jlptLevel']),
      stability: serializer.fromJson<double>(json['stability']),
      difficulty: serializer.fromJson<double>(json['difficulty']),
      lastReview: serializer.fromJson<DateTime?>(json['lastReview']),
      nextReview: serializer.fromJson<DateTime>(json['nextReview']),
      reps: serializer.fromJson<int>(json['reps']),
      lapses: serializer.fromJson<int>(json['lapses']),
      state: serializer.fromJson<int>(json['state']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'kanji': serializer.toJson<String>(kanji),
      'meanings': serializer.toJson<String>(meanings),
      'onyomi': serializer.toJson<String>(onyomi),
      'kunyomi': serializer.toJson<String>(kunyomi),
      'strokeData': serializer.toJson<String?>(strokeData),
      'jlptLevel': serializer.toJson<int>(jlptLevel),
      'stability': serializer.toJson<double>(stability),
      'difficulty': serializer.toJson<double>(difficulty),
      'lastReview': serializer.toJson<DateTime?>(lastReview),
      'nextReview': serializer.toJson<DateTime>(nextReview),
      'reps': serializer.toJson<int>(reps),
      'lapses': serializer.toJson<int>(lapses),
      'state': serializer.toJson<int>(state),
    };
  }

  KanjiCardData copyWith({
    String? id,
    String? kanji,
    String? meanings,
    String? onyomi,
    String? kunyomi,
    Value<String?> strokeData = const Value.absent(),
    int? jlptLevel,
    double? stability,
    double? difficulty,
    Value<DateTime?> lastReview = const Value.absent(),
    DateTime? nextReview,
    int? reps,
    int? lapses,
    int? state,
  }) => KanjiCardData(
    id: id ?? this.id,
    kanji: kanji ?? this.kanji,
    meanings: meanings ?? this.meanings,
    onyomi: onyomi ?? this.onyomi,
    kunyomi: kunyomi ?? this.kunyomi,
    strokeData: strokeData.present ? strokeData.value : this.strokeData,
    jlptLevel: jlptLevel ?? this.jlptLevel,
    stability: stability ?? this.stability,
    difficulty: difficulty ?? this.difficulty,
    lastReview: lastReview.present ? lastReview.value : this.lastReview,
    nextReview: nextReview ?? this.nextReview,
    reps: reps ?? this.reps,
    lapses: lapses ?? this.lapses,
    state: state ?? this.state,
  );
  KanjiCardData copyWithCompanion(KanjiCardTableCompanion data) {
    return KanjiCardData(
      id: data.id.present ? data.id.value : this.id,
      kanji: data.kanji.present ? data.kanji.value : this.kanji,
      meanings: data.meanings.present ? data.meanings.value : this.meanings,
      onyomi: data.onyomi.present ? data.onyomi.value : this.onyomi,
      kunyomi: data.kunyomi.present ? data.kunyomi.value : this.kunyomi,
      strokeData: data.strokeData.present
          ? data.strokeData.value
          : this.strokeData,
      jlptLevel: data.jlptLevel.present ? data.jlptLevel.value : this.jlptLevel,
      stability: data.stability.present ? data.stability.value : this.stability,
      difficulty: data.difficulty.present
          ? data.difficulty.value
          : this.difficulty,
      lastReview: data.lastReview.present
          ? data.lastReview.value
          : this.lastReview,
      nextReview: data.nextReview.present
          ? data.nextReview.value
          : this.nextReview,
      reps: data.reps.present ? data.reps.value : this.reps,
      lapses: data.lapses.present ? data.lapses.value : this.lapses,
      state: data.state.present ? data.state.value : this.state,
    );
  }

  @override
  String toString() {
    return (StringBuffer('KanjiCardData(')
          ..write('id: $id, ')
          ..write('kanji: $kanji, ')
          ..write('meanings: $meanings, ')
          ..write('onyomi: $onyomi, ')
          ..write('kunyomi: $kunyomi, ')
          ..write('strokeData: $strokeData, ')
          ..write('jlptLevel: $jlptLevel, ')
          ..write('stability: $stability, ')
          ..write('difficulty: $difficulty, ')
          ..write('lastReview: $lastReview, ')
          ..write('nextReview: $nextReview, ')
          ..write('reps: $reps, ')
          ..write('lapses: $lapses, ')
          ..write('state: $state')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    kanji,
    meanings,
    onyomi,
    kunyomi,
    strokeData,
    jlptLevel,
    stability,
    difficulty,
    lastReview,
    nextReview,
    reps,
    lapses,
    state,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is KanjiCardData &&
          other.id == this.id &&
          other.kanji == this.kanji &&
          other.meanings == this.meanings &&
          other.onyomi == this.onyomi &&
          other.kunyomi == this.kunyomi &&
          other.strokeData == this.strokeData &&
          other.jlptLevel == this.jlptLevel &&
          other.stability == this.stability &&
          other.difficulty == this.difficulty &&
          other.lastReview == this.lastReview &&
          other.nextReview == this.nextReview &&
          other.reps == this.reps &&
          other.lapses == this.lapses &&
          other.state == this.state);
}

class KanjiCardTableCompanion extends UpdateCompanion<KanjiCardData> {
  final Value<String> id;
  final Value<String> kanji;
  final Value<String> meanings;
  final Value<String> onyomi;
  final Value<String> kunyomi;
  final Value<String?> strokeData;
  final Value<int> jlptLevel;
  final Value<double> stability;
  final Value<double> difficulty;
  final Value<DateTime?> lastReview;
  final Value<DateTime> nextReview;
  final Value<int> reps;
  final Value<int> lapses;
  final Value<int> state;
  final Value<int> rowid;
  const KanjiCardTableCompanion({
    this.id = const Value.absent(),
    this.kanji = const Value.absent(),
    this.meanings = const Value.absent(),
    this.onyomi = const Value.absent(),
    this.kunyomi = const Value.absent(),
    this.strokeData = const Value.absent(),
    this.jlptLevel = const Value.absent(),
    this.stability = const Value.absent(),
    this.difficulty = const Value.absent(),
    this.lastReview = const Value.absent(),
    this.nextReview = const Value.absent(),
    this.reps = const Value.absent(),
    this.lapses = const Value.absent(),
    this.state = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  KanjiCardTableCompanion.insert({
    required String id,
    required String kanji,
    required String meanings,
    required String onyomi,
    required String kunyomi,
    this.strokeData = const Value.absent(),
    this.jlptLevel = const Value.absent(),
    this.stability = const Value.absent(),
    this.difficulty = const Value.absent(),
    this.lastReview = const Value.absent(),
    required DateTime nextReview,
    this.reps = const Value.absent(),
    this.lapses = const Value.absent(),
    this.state = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       kanji = Value(kanji),
       meanings = Value(meanings),
       onyomi = Value(onyomi),
       kunyomi = Value(kunyomi),
       nextReview = Value(nextReview);
  static Insertable<KanjiCardData> custom({
    Expression<String>? id,
    Expression<String>? kanji,
    Expression<String>? meanings,
    Expression<String>? onyomi,
    Expression<String>? kunyomi,
    Expression<String>? strokeData,
    Expression<int>? jlptLevel,
    Expression<double>? stability,
    Expression<double>? difficulty,
    Expression<DateTime>? lastReview,
    Expression<DateTime>? nextReview,
    Expression<int>? reps,
    Expression<int>? lapses,
    Expression<int>? state,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (kanji != null) 'kanji': kanji,
      if (meanings != null) 'meanings': meanings,
      if (onyomi != null) 'onyomi': onyomi,
      if (kunyomi != null) 'kunyomi': kunyomi,
      if (strokeData != null) 'stroke_data': strokeData,
      if (jlptLevel != null) 'jlpt_level': jlptLevel,
      if (stability != null) 'stability': stability,
      if (difficulty != null) 'difficulty': difficulty,
      if (lastReview != null) 'last_review': lastReview,
      if (nextReview != null) 'next_review': nextReview,
      if (reps != null) 'reps': reps,
      if (lapses != null) 'lapses': lapses,
      if (state != null) 'state': state,
      if (rowid != null) 'rowid': rowid,
    });
  }

  KanjiCardTableCompanion copyWith({
    Value<String>? id,
    Value<String>? kanji,
    Value<String>? meanings,
    Value<String>? onyomi,
    Value<String>? kunyomi,
    Value<String?>? strokeData,
    Value<int>? jlptLevel,
    Value<double>? stability,
    Value<double>? difficulty,
    Value<DateTime?>? lastReview,
    Value<DateTime>? nextReview,
    Value<int>? reps,
    Value<int>? lapses,
    Value<int>? state,
    Value<int>? rowid,
  }) {
    return KanjiCardTableCompanion(
      id: id ?? this.id,
      kanji: kanji ?? this.kanji,
      meanings: meanings ?? this.meanings,
      onyomi: onyomi ?? this.onyomi,
      kunyomi: kunyomi ?? this.kunyomi,
      strokeData: strokeData ?? this.strokeData,
      jlptLevel: jlptLevel ?? this.jlptLevel,
      stability: stability ?? this.stability,
      difficulty: difficulty ?? this.difficulty,
      lastReview: lastReview ?? this.lastReview,
      nextReview: nextReview ?? this.nextReview,
      reps: reps ?? this.reps,
      lapses: lapses ?? this.lapses,
      state: state ?? this.state,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (kanji.present) {
      map['kanji'] = Variable<String>(kanji.value);
    }
    if (meanings.present) {
      map['meanings'] = Variable<String>(meanings.value);
    }
    if (onyomi.present) {
      map['onyomi'] = Variable<String>(onyomi.value);
    }
    if (kunyomi.present) {
      map['kunyomi'] = Variable<String>(kunyomi.value);
    }
    if (strokeData.present) {
      map['stroke_data'] = Variable<String>(strokeData.value);
    }
    if (jlptLevel.present) {
      map['jlpt_level'] = Variable<int>(jlptLevel.value);
    }
    if (stability.present) {
      map['stability'] = Variable<double>(stability.value);
    }
    if (difficulty.present) {
      map['difficulty'] = Variable<double>(difficulty.value);
    }
    if (lastReview.present) {
      map['last_review'] = Variable<DateTime>(lastReview.value);
    }
    if (nextReview.present) {
      map['next_review'] = Variable<DateTime>(nextReview.value);
    }
    if (reps.present) {
      map['reps'] = Variable<int>(reps.value);
    }
    if (lapses.present) {
      map['lapses'] = Variable<int>(lapses.value);
    }
    if (state.present) {
      map['state'] = Variable<int>(state.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('KanjiCardTableCompanion(')
          ..write('id: $id, ')
          ..write('kanji: $kanji, ')
          ..write('meanings: $meanings, ')
          ..write('onyomi: $onyomi, ')
          ..write('kunyomi: $kunyomi, ')
          ..write('strokeData: $strokeData, ')
          ..write('jlptLevel: $jlptLevel, ')
          ..write('stability: $stability, ')
          ..write('difficulty: $difficulty, ')
          ..write('lastReview: $lastReview, ')
          ..write('nextReview: $nextReview, ')
          ..write('reps: $reps, ')
          ..write('lapses: $lapses, ')
          ..write('state: $state, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $VocabularyTableTable extends VocabularyTable
    with TableInfo<$VocabularyTableTable, VocabularyTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $VocabularyTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _wordMeta = const VerificationMeta('word');
  @override
  late final GeneratedColumn<String> word = GeneratedColumn<String>(
    'word',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _readingMeta = const VerificationMeta(
    'reading',
  );
  @override
  late final GeneratedColumn<String> reading = GeneratedColumn<String>(
    'reading',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _meaningMeta = const VerificationMeta(
    'meaning',
  );
  @override
  late final GeneratedColumn<String> meaning = GeneratedColumn<String>(
    'meaning',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _jlptLevelMeta = const VerificationMeta(
    'jlptLevel',
  );
  @override
  late final GeneratedColumn<int> jlptLevel = GeneratedColumn<int>(
    'jlpt_level',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(5),
  );
  static const VerificationMeta _stabilityMeta = const VerificationMeta(
    'stability',
  );
  @override
  late final GeneratedColumn<double> stability = GeneratedColumn<double>(
    'stability',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _difficultyMeta = const VerificationMeta(
    'difficulty',
  );
  @override
  late final GeneratedColumn<double> difficulty = GeneratedColumn<double>(
    'difficulty',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _lastReviewMeta = const VerificationMeta(
    'lastReview',
  );
  @override
  late final GeneratedColumn<DateTime> lastReview = GeneratedColumn<DateTime>(
    'last_review',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _nextReviewMeta = const VerificationMeta(
    'nextReview',
  );
  @override
  late final GeneratedColumn<DateTime> nextReview = GeneratedColumn<DateTime>(
    'next_review',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _repsMeta = const VerificationMeta('reps');
  @override
  late final GeneratedColumn<int> reps = GeneratedColumn<int>(
    'reps',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _lapsesMeta = const VerificationMeta('lapses');
  @override
  late final GeneratedColumn<int> lapses = GeneratedColumn<int>(
    'lapses',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _stateMeta = const VerificationMeta('state');
  @override
  late final GeneratedColumn<int> state = GeneratedColumn<int>(
    'state',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    word,
    reading,
    meaning,
    jlptLevel,
    stability,
    difficulty,
    lastReview,
    nextReview,
    reps,
    lapses,
    state,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'vocabulary_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<VocabularyTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('word')) {
      context.handle(
        _wordMeta,
        word.isAcceptableOrUnknown(data['word']!, _wordMeta),
      );
    } else if (isInserting) {
      context.missing(_wordMeta);
    }
    if (data.containsKey('reading')) {
      context.handle(
        _readingMeta,
        reading.isAcceptableOrUnknown(data['reading']!, _readingMeta),
      );
    } else if (isInserting) {
      context.missing(_readingMeta);
    }
    if (data.containsKey('meaning')) {
      context.handle(
        _meaningMeta,
        meaning.isAcceptableOrUnknown(data['meaning']!, _meaningMeta),
      );
    } else if (isInserting) {
      context.missing(_meaningMeta);
    }
    if (data.containsKey('jlpt_level')) {
      context.handle(
        _jlptLevelMeta,
        jlptLevel.isAcceptableOrUnknown(data['jlpt_level']!, _jlptLevelMeta),
      );
    }
    if (data.containsKey('stability')) {
      context.handle(
        _stabilityMeta,
        stability.isAcceptableOrUnknown(data['stability']!, _stabilityMeta),
      );
    }
    if (data.containsKey('difficulty')) {
      context.handle(
        _difficultyMeta,
        difficulty.isAcceptableOrUnknown(data['difficulty']!, _difficultyMeta),
      );
    }
    if (data.containsKey('last_review')) {
      context.handle(
        _lastReviewMeta,
        lastReview.isAcceptableOrUnknown(data['last_review']!, _lastReviewMeta),
      );
    }
    if (data.containsKey('next_review')) {
      context.handle(
        _nextReviewMeta,
        nextReview.isAcceptableOrUnknown(data['next_review']!, _nextReviewMeta),
      );
    } else if (isInserting) {
      context.missing(_nextReviewMeta);
    }
    if (data.containsKey('reps')) {
      context.handle(
        _repsMeta,
        reps.isAcceptableOrUnknown(data['reps']!, _repsMeta),
      );
    }
    if (data.containsKey('lapses')) {
      context.handle(
        _lapsesMeta,
        lapses.isAcceptableOrUnknown(data['lapses']!, _lapsesMeta),
      );
    }
    if (data.containsKey('state')) {
      context.handle(
        _stateMeta,
        state.isAcceptableOrUnknown(data['state']!, _stateMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  VocabularyTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return VocabularyTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      word: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}word'],
      )!,
      reading: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reading'],
      )!,
      meaning: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}meaning'],
      )!,
      jlptLevel: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}jlpt_level'],
      )!,
      stability: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}stability'],
      )!,
      difficulty: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}difficulty'],
      )!,
      lastReview: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_review'],
      ),
      nextReview: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}next_review'],
      )!,
      reps: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}reps'],
      )!,
      lapses: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}lapses'],
      )!,
      state: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}state'],
      )!,
    );
  }

  @override
  $VocabularyTableTable createAlias(String alias) {
    return $VocabularyTableTable(attachedDatabase, alias);
  }
}

class VocabularyTableData extends DataClass
    implements Insertable<VocabularyTableData> {
  final String id;
  final String word;
  final String reading;
  final String meaning;
  final int jlptLevel;
  final double stability;
  final double difficulty;
  final DateTime? lastReview;
  final DateTime nextReview;
  final int reps;
  final int lapses;
  final int state;
  const VocabularyTableData({
    required this.id,
    required this.word,
    required this.reading,
    required this.meaning,
    required this.jlptLevel,
    required this.stability,
    required this.difficulty,
    this.lastReview,
    required this.nextReview,
    required this.reps,
    required this.lapses,
    required this.state,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['word'] = Variable<String>(word);
    map['reading'] = Variable<String>(reading);
    map['meaning'] = Variable<String>(meaning);
    map['jlpt_level'] = Variable<int>(jlptLevel);
    map['stability'] = Variable<double>(stability);
    map['difficulty'] = Variable<double>(difficulty);
    if (!nullToAbsent || lastReview != null) {
      map['last_review'] = Variable<DateTime>(lastReview);
    }
    map['next_review'] = Variable<DateTime>(nextReview);
    map['reps'] = Variable<int>(reps);
    map['lapses'] = Variable<int>(lapses);
    map['state'] = Variable<int>(state);
    return map;
  }

  VocabularyTableCompanion toCompanion(bool nullToAbsent) {
    return VocabularyTableCompanion(
      id: Value(id),
      word: Value(word),
      reading: Value(reading),
      meaning: Value(meaning),
      jlptLevel: Value(jlptLevel),
      stability: Value(stability),
      difficulty: Value(difficulty),
      lastReview: lastReview == null && nullToAbsent
          ? const Value.absent()
          : Value(lastReview),
      nextReview: Value(nextReview),
      reps: Value(reps),
      lapses: Value(lapses),
      state: Value(state),
    );
  }

  factory VocabularyTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return VocabularyTableData(
      id: serializer.fromJson<String>(json['id']),
      word: serializer.fromJson<String>(json['word']),
      reading: serializer.fromJson<String>(json['reading']),
      meaning: serializer.fromJson<String>(json['meaning']),
      jlptLevel: serializer.fromJson<int>(json['jlptLevel']),
      stability: serializer.fromJson<double>(json['stability']),
      difficulty: serializer.fromJson<double>(json['difficulty']),
      lastReview: serializer.fromJson<DateTime?>(json['lastReview']),
      nextReview: serializer.fromJson<DateTime>(json['nextReview']),
      reps: serializer.fromJson<int>(json['reps']),
      lapses: serializer.fromJson<int>(json['lapses']),
      state: serializer.fromJson<int>(json['state']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'word': serializer.toJson<String>(word),
      'reading': serializer.toJson<String>(reading),
      'meaning': serializer.toJson<String>(meaning),
      'jlptLevel': serializer.toJson<int>(jlptLevel),
      'stability': serializer.toJson<double>(stability),
      'difficulty': serializer.toJson<double>(difficulty),
      'lastReview': serializer.toJson<DateTime?>(lastReview),
      'nextReview': serializer.toJson<DateTime>(nextReview),
      'reps': serializer.toJson<int>(reps),
      'lapses': serializer.toJson<int>(lapses),
      'state': serializer.toJson<int>(state),
    };
  }

  VocabularyTableData copyWith({
    String? id,
    String? word,
    String? reading,
    String? meaning,
    int? jlptLevel,
    double? stability,
    double? difficulty,
    Value<DateTime?> lastReview = const Value.absent(),
    DateTime? nextReview,
    int? reps,
    int? lapses,
    int? state,
  }) => VocabularyTableData(
    id: id ?? this.id,
    word: word ?? this.word,
    reading: reading ?? this.reading,
    meaning: meaning ?? this.meaning,
    jlptLevel: jlptLevel ?? this.jlptLevel,
    stability: stability ?? this.stability,
    difficulty: difficulty ?? this.difficulty,
    lastReview: lastReview.present ? lastReview.value : this.lastReview,
    nextReview: nextReview ?? this.nextReview,
    reps: reps ?? this.reps,
    lapses: lapses ?? this.lapses,
    state: state ?? this.state,
  );
  VocabularyTableData copyWithCompanion(VocabularyTableCompanion data) {
    return VocabularyTableData(
      id: data.id.present ? data.id.value : this.id,
      word: data.word.present ? data.word.value : this.word,
      reading: data.reading.present ? data.reading.value : this.reading,
      meaning: data.meaning.present ? data.meaning.value : this.meaning,
      jlptLevel: data.jlptLevel.present ? data.jlptLevel.value : this.jlptLevel,
      stability: data.stability.present ? data.stability.value : this.stability,
      difficulty: data.difficulty.present
          ? data.difficulty.value
          : this.difficulty,
      lastReview: data.lastReview.present
          ? data.lastReview.value
          : this.lastReview,
      nextReview: data.nextReview.present
          ? data.nextReview.value
          : this.nextReview,
      reps: data.reps.present ? data.reps.value : this.reps,
      lapses: data.lapses.present ? data.lapses.value : this.lapses,
      state: data.state.present ? data.state.value : this.state,
    );
  }

  @override
  String toString() {
    return (StringBuffer('VocabularyTableData(')
          ..write('id: $id, ')
          ..write('word: $word, ')
          ..write('reading: $reading, ')
          ..write('meaning: $meaning, ')
          ..write('jlptLevel: $jlptLevel, ')
          ..write('stability: $stability, ')
          ..write('difficulty: $difficulty, ')
          ..write('lastReview: $lastReview, ')
          ..write('nextReview: $nextReview, ')
          ..write('reps: $reps, ')
          ..write('lapses: $lapses, ')
          ..write('state: $state')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    word,
    reading,
    meaning,
    jlptLevel,
    stability,
    difficulty,
    lastReview,
    nextReview,
    reps,
    lapses,
    state,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is VocabularyTableData &&
          other.id == this.id &&
          other.word == this.word &&
          other.reading == this.reading &&
          other.meaning == this.meaning &&
          other.jlptLevel == this.jlptLevel &&
          other.stability == this.stability &&
          other.difficulty == this.difficulty &&
          other.lastReview == this.lastReview &&
          other.nextReview == this.nextReview &&
          other.reps == this.reps &&
          other.lapses == this.lapses &&
          other.state == this.state);
}

class VocabularyTableCompanion extends UpdateCompanion<VocabularyTableData> {
  final Value<String> id;
  final Value<String> word;
  final Value<String> reading;
  final Value<String> meaning;
  final Value<int> jlptLevel;
  final Value<double> stability;
  final Value<double> difficulty;
  final Value<DateTime?> lastReview;
  final Value<DateTime> nextReview;
  final Value<int> reps;
  final Value<int> lapses;
  final Value<int> state;
  final Value<int> rowid;
  const VocabularyTableCompanion({
    this.id = const Value.absent(),
    this.word = const Value.absent(),
    this.reading = const Value.absent(),
    this.meaning = const Value.absent(),
    this.jlptLevel = const Value.absent(),
    this.stability = const Value.absent(),
    this.difficulty = const Value.absent(),
    this.lastReview = const Value.absent(),
    this.nextReview = const Value.absent(),
    this.reps = const Value.absent(),
    this.lapses = const Value.absent(),
    this.state = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  VocabularyTableCompanion.insert({
    required String id,
    required String word,
    required String reading,
    required String meaning,
    this.jlptLevel = const Value.absent(),
    this.stability = const Value.absent(),
    this.difficulty = const Value.absent(),
    this.lastReview = const Value.absent(),
    required DateTime nextReview,
    this.reps = const Value.absent(),
    this.lapses = const Value.absent(),
    this.state = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       word = Value(word),
       reading = Value(reading),
       meaning = Value(meaning),
       nextReview = Value(nextReview);
  static Insertable<VocabularyTableData> custom({
    Expression<String>? id,
    Expression<String>? word,
    Expression<String>? reading,
    Expression<String>? meaning,
    Expression<int>? jlptLevel,
    Expression<double>? stability,
    Expression<double>? difficulty,
    Expression<DateTime>? lastReview,
    Expression<DateTime>? nextReview,
    Expression<int>? reps,
    Expression<int>? lapses,
    Expression<int>? state,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (word != null) 'word': word,
      if (reading != null) 'reading': reading,
      if (meaning != null) 'meaning': meaning,
      if (jlptLevel != null) 'jlpt_level': jlptLevel,
      if (stability != null) 'stability': stability,
      if (difficulty != null) 'difficulty': difficulty,
      if (lastReview != null) 'last_review': lastReview,
      if (nextReview != null) 'next_review': nextReview,
      if (reps != null) 'reps': reps,
      if (lapses != null) 'lapses': lapses,
      if (state != null) 'state': state,
      if (rowid != null) 'rowid': rowid,
    });
  }

  VocabularyTableCompanion copyWith({
    Value<String>? id,
    Value<String>? word,
    Value<String>? reading,
    Value<String>? meaning,
    Value<int>? jlptLevel,
    Value<double>? stability,
    Value<double>? difficulty,
    Value<DateTime?>? lastReview,
    Value<DateTime>? nextReview,
    Value<int>? reps,
    Value<int>? lapses,
    Value<int>? state,
    Value<int>? rowid,
  }) {
    return VocabularyTableCompanion(
      id: id ?? this.id,
      word: word ?? this.word,
      reading: reading ?? this.reading,
      meaning: meaning ?? this.meaning,
      jlptLevel: jlptLevel ?? this.jlptLevel,
      stability: stability ?? this.stability,
      difficulty: difficulty ?? this.difficulty,
      lastReview: lastReview ?? this.lastReview,
      nextReview: nextReview ?? this.nextReview,
      reps: reps ?? this.reps,
      lapses: lapses ?? this.lapses,
      state: state ?? this.state,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (word.present) {
      map['word'] = Variable<String>(word.value);
    }
    if (reading.present) {
      map['reading'] = Variable<String>(reading.value);
    }
    if (meaning.present) {
      map['meaning'] = Variable<String>(meaning.value);
    }
    if (jlptLevel.present) {
      map['jlpt_level'] = Variable<int>(jlptLevel.value);
    }
    if (stability.present) {
      map['stability'] = Variable<double>(stability.value);
    }
    if (difficulty.present) {
      map['difficulty'] = Variable<double>(difficulty.value);
    }
    if (lastReview.present) {
      map['last_review'] = Variable<DateTime>(lastReview.value);
    }
    if (nextReview.present) {
      map['next_review'] = Variable<DateTime>(nextReview.value);
    }
    if (reps.present) {
      map['reps'] = Variable<int>(reps.value);
    }
    if (lapses.present) {
      map['lapses'] = Variable<int>(lapses.value);
    }
    if (state.present) {
      map['state'] = Variable<int>(state.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('VocabularyTableCompanion(')
          ..write('id: $id, ')
          ..write('word: $word, ')
          ..write('reading: $reading, ')
          ..write('meaning: $meaning, ')
          ..write('jlptLevel: $jlptLevel, ')
          ..write('stability: $stability, ')
          ..write('difficulty: $difficulty, ')
          ..write('lastReview: $lastReview, ')
          ..write('nextReview: $nextReview, ')
          ..write('reps: $reps, ')
          ..write('lapses: $lapses, ')
          ..write('state: $state, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $GrammarTableTable extends GrammarTable
    with TableInfo<$GrammarTableTable, GrammarTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $GrammarTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
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
    requiredDuringInsert: true,
  );
  static const VerificationMeta _structureMeta = const VerificationMeta(
    'structure',
  );
  @override
  late final GeneratedColumn<String> structure = GeneratedColumn<String>(
    'structure',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _explanationMeta = const VerificationMeta(
    'explanation',
  );
  @override
  late final GeneratedColumn<String> explanation = GeneratedColumn<String>(
    'explanation',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _exampleMeta = const VerificationMeta(
    'example',
  );
  @override
  late final GeneratedColumn<String> example = GeneratedColumn<String>(
    'example',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _jlptLevelMeta = const VerificationMeta(
    'jlptLevel',
  );
  @override
  late final GeneratedColumn<int> jlptLevel = GeneratedColumn<int>(
    'jlpt_level',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(5),
  );
  static const VerificationMeta _isLearnedMeta = const VerificationMeta(
    'isLearned',
  );
  @override
  late final GeneratedColumn<bool> isLearned = GeneratedColumn<bool>(
    'is_learned',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_learned" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    title,
    structure,
    explanation,
    example,
    jlptLevel,
    isLearned,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'grammar_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<GrammarTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('structure')) {
      context.handle(
        _structureMeta,
        structure.isAcceptableOrUnknown(data['structure']!, _structureMeta),
      );
    } else if (isInserting) {
      context.missing(_structureMeta);
    }
    if (data.containsKey('explanation')) {
      context.handle(
        _explanationMeta,
        explanation.isAcceptableOrUnknown(
          data['explanation']!,
          _explanationMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_explanationMeta);
    }
    if (data.containsKey('example')) {
      context.handle(
        _exampleMeta,
        example.isAcceptableOrUnknown(data['example']!, _exampleMeta),
      );
    } else if (isInserting) {
      context.missing(_exampleMeta);
    }
    if (data.containsKey('jlpt_level')) {
      context.handle(
        _jlptLevelMeta,
        jlptLevel.isAcceptableOrUnknown(data['jlpt_level']!, _jlptLevelMeta),
      );
    }
    if (data.containsKey('is_learned')) {
      context.handle(
        _isLearnedMeta,
        isLearned.isAcceptableOrUnknown(data['is_learned']!, _isLearnedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  GrammarTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return GrammarTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      structure: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}structure'],
      )!,
      explanation: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}explanation'],
      )!,
      example: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}example'],
      )!,
      jlptLevel: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}jlpt_level'],
      )!,
      isLearned: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_learned'],
      )!,
    );
  }

  @override
  $GrammarTableTable createAlias(String alias) {
    return $GrammarTableTable(attachedDatabase, alias);
  }
}

class GrammarTableData extends DataClass
    implements Insertable<GrammarTableData> {
  final String id;
  final String title;
  final String structure;
  final String explanation;
  final String example;
  final int jlptLevel;
  final bool isLearned;
  const GrammarTableData({
    required this.id,
    required this.title,
    required this.structure,
    required this.explanation,
    required this.example,
    required this.jlptLevel,
    required this.isLearned,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['title'] = Variable<String>(title);
    map['structure'] = Variable<String>(structure);
    map['explanation'] = Variable<String>(explanation);
    map['example'] = Variable<String>(example);
    map['jlpt_level'] = Variable<int>(jlptLevel);
    map['is_learned'] = Variable<bool>(isLearned);
    return map;
  }

  GrammarTableCompanion toCompanion(bool nullToAbsent) {
    return GrammarTableCompanion(
      id: Value(id),
      title: Value(title),
      structure: Value(structure),
      explanation: Value(explanation),
      example: Value(example),
      jlptLevel: Value(jlptLevel),
      isLearned: Value(isLearned),
    );
  }

  factory GrammarTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return GrammarTableData(
      id: serializer.fromJson<String>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      structure: serializer.fromJson<String>(json['structure']),
      explanation: serializer.fromJson<String>(json['explanation']),
      example: serializer.fromJson<String>(json['example']),
      jlptLevel: serializer.fromJson<int>(json['jlptLevel']),
      isLearned: serializer.fromJson<bool>(json['isLearned']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'title': serializer.toJson<String>(title),
      'structure': serializer.toJson<String>(structure),
      'explanation': serializer.toJson<String>(explanation),
      'example': serializer.toJson<String>(example),
      'jlptLevel': serializer.toJson<int>(jlptLevel),
      'isLearned': serializer.toJson<bool>(isLearned),
    };
  }

  GrammarTableData copyWith({
    String? id,
    String? title,
    String? structure,
    String? explanation,
    String? example,
    int? jlptLevel,
    bool? isLearned,
  }) => GrammarTableData(
    id: id ?? this.id,
    title: title ?? this.title,
    structure: structure ?? this.structure,
    explanation: explanation ?? this.explanation,
    example: example ?? this.example,
    jlptLevel: jlptLevel ?? this.jlptLevel,
    isLearned: isLearned ?? this.isLearned,
  );
  GrammarTableData copyWithCompanion(GrammarTableCompanion data) {
    return GrammarTableData(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      structure: data.structure.present ? data.structure.value : this.structure,
      explanation: data.explanation.present
          ? data.explanation.value
          : this.explanation,
      example: data.example.present ? data.example.value : this.example,
      jlptLevel: data.jlptLevel.present ? data.jlptLevel.value : this.jlptLevel,
      isLearned: data.isLearned.present ? data.isLearned.value : this.isLearned,
    );
  }

  @override
  String toString() {
    return (StringBuffer('GrammarTableData(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('structure: $structure, ')
          ..write('explanation: $explanation, ')
          ..write('example: $example, ')
          ..write('jlptLevel: $jlptLevel, ')
          ..write('isLearned: $isLearned')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    title,
    structure,
    explanation,
    example,
    jlptLevel,
    isLearned,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is GrammarTableData &&
          other.id == this.id &&
          other.title == this.title &&
          other.structure == this.structure &&
          other.explanation == this.explanation &&
          other.example == this.example &&
          other.jlptLevel == this.jlptLevel &&
          other.isLearned == this.isLearned);
}

class GrammarTableCompanion extends UpdateCompanion<GrammarTableData> {
  final Value<String> id;
  final Value<String> title;
  final Value<String> structure;
  final Value<String> explanation;
  final Value<String> example;
  final Value<int> jlptLevel;
  final Value<bool> isLearned;
  final Value<int> rowid;
  const GrammarTableCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.structure = const Value.absent(),
    this.explanation = const Value.absent(),
    this.example = const Value.absent(),
    this.jlptLevel = const Value.absent(),
    this.isLearned = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  GrammarTableCompanion.insert({
    required String id,
    required String title,
    required String structure,
    required String explanation,
    required String example,
    this.jlptLevel = const Value.absent(),
    this.isLearned = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       title = Value(title),
       structure = Value(structure),
       explanation = Value(explanation),
       example = Value(example);
  static Insertable<GrammarTableData> custom({
    Expression<String>? id,
    Expression<String>? title,
    Expression<String>? structure,
    Expression<String>? explanation,
    Expression<String>? example,
    Expression<int>? jlptLevel,
    Expression<bool>? isLearned,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (structure != null) 'structure': structure,
      if (explanation != null) 'explanation': explanation,
      if (example != null) 'example': example,
      if (jlptLevel != null) 'jlpt_level': jlptLevel,
      if (isLearned != null) 'is_learned': isLearned,
      if (rowid != null) 'rowid': rowid,
    });
  }

  GrammarTableCompanion copyWith({
    Value<String>? id,
    Value<String>? title,
    Value<String>? structure,
    Value<String>? explanation,
    Value<String>? example,
    Value<int>? jlptLevel,
    Value<bool>? isLearned,
    Value<int>? rowid,
  }) {
    return GrammarTableCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      structure: structure ?? this.structure,
      explanation: explanation ?? this.explanation,
      example: example ?? this.example,
      jlptLevel: jlptLevel ?? this.jlptLevel,
      isLearned: isLearned ?? this.isLearned,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (structure.present) {
      map['structure'] = Variable<String>(structure.value);
    }
    if (explanation.present) {
      map['explanation'] = Variable<String>(explanation.value);
    }
    if (example.present) {
      map['example'] = Variable<String>(example.value);
    }
    if (jlptLevel.present) {
      map['jlpt_level'] = Variable<int>(jlptLevel.value);
    }
    if (isLearned.present) {
      map['is_learned'] = Variable<bool>(isLearned.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('GrammarTableCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('structure: $structure, ')
          ..write('explanation: $explanation, ')
          ..write('example: $example, ')
          ..write('jlptLevel: $jlptLevel, ')
          ..write('isLearned: $isLearned, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ZenGardenTableTable extends ZenGardenTable
    with TableInfo<$ZenGardenTableTable, ZenGardenTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ZenGardenTableTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _waterMeta = const VerificationMeta('water');
  @override
  late final GeneratedColumn<int> water = GeneratedColumn<int>(
    'water',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _sunlightMeta = const VerificationMeta(
    'sunlight',
  );
  @override
  late final GeneratedColumn<int> sunlight = GeneratedColumn<int>(
    'sunlight',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _expMeta = const VerificationMeta('exp');
  @override
  late final GeneratedColumn<int> exp = GeneratedColumn<int>(
    'exp',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _plantsJsonMeta = const VerificationMeta(
    'plantsJson',
  );
  @override
  late final GeneratedColumn<String> plantsJson = GeneratedColumn<String>(
    'plants_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('[]'),
  );
  static const VerificationMeta _lastLoginMeta = const VerificationMeta(
    'lastLogin',
  );
  @override
  late final GeneratedColumn<DateTime> lastLogin = GeneratedColumn<DateTime>(
    'last_login',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    water,
    sunlight,
    exp,
    plantsJson,
    lastLogin,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'zen_garden_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<ZenGardenTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('water')) {
      context.handle(
        _waterMeta,
        water.isAcceptableOrUnknown(data['water']!, _waterMeta),
      );
    }
    if (data.containsKey('sunlight')) {
      context.handle(
        _sunlightMeta,
        sunlight.isAcceptableOrUnknown(data['sunlight']!, _sunlightMeta),
      );
    }
    if (data.containsKey('exp')) {
      context.handle(
        _expMeta,
        exp.isAcceptableOrUnknown(data['exp']!, _expMeta),
      );
    }
    if (data.containsKey('plants_json')) {
      context.handle(
        _plantsJsonMeta,
        plantsJson.isAcceptableOrUnknown(data['plants_json']!, _plantsJsonMeta),
      );
    }
    if (data.containsKey('last_login')) {
      context.handle(
        _lastLoginMeta,
        lastLogin.isAcceptableOrUnknown(data['last_login']!, _lastLoginMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ZenGardenTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ZenGardenTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      water: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}water'],
      )!,
      sunlight: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sunlight'],
      )!,
      exp: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}exp'],
      )!,
      plantsJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}plants_json'],
      )!,
      lastLogin: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_login'],
      ),
    );
  }

  @override
  $ZenGardenTableTable createAlias(String alias) {
    return $ZenGardenTableTable(attachedDatabase, alias);
  }
}

class ZenGardenTableData extends DataClass
    implements Insertable<ZenGardenTableData> {
  final int id;
  final int water;
  final int sunlight;
  final int exp;
  final String plantsJson;
  final DateTime? lastLogin;
  const ZenGardenTableData({
    required this.id,
    required this.water,
    required this.sunlight,
    required this.exp,
    required this.plantsJson,
    this.lastLogin,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['water'] = Variable<int>(water);
    map['sunlight'] = Variable<int>(sunlight);
    map['exp'] = Variable<int>(exp);
    map['plants_json'] = Variable<String>(plantsJson);
    if (!nullToAbsent || lastLogin != null) {
      map['last_login'] = Variable<DateTime>(lastLogin);
    }
    return map;
  }

  ZenGardenTableCompanion toCompanion(bool nullToAbsent) {
    return ZenGardenTableCompanion(
      id: Value(id),
      water: Value(water),
      sunlight: Value(sunlight),
      exp: Value(exp),
      plantsJson: Value(plantsJson),
      lastLogin: lastLogin == null && nullToAbsent
          ? const Value.absent()
          : Value(lastLogin),
    );
  }

  factory ZenGardenTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ZenGardenTableData(
      id: serializer.fromJson<int>(json['id']),
      water: serializer.fromJson<int>(json['water']),
      sunlight: serializer.fromJson<int>(json['sunlight']),
      exp: serializer.fromJson<int>(json['exp']),
      plantsJson: serializer.fromJson<String>(json['plantsJson']),
      lastLogin: serializer.fromJson<DateTime?>(json['lastLogin']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'water': serializer.toJson<int>(water),
      'sunlight': serializer.toJson<int>(sunlight),
      'exp': serializer.toJson<int>(exp),
      'plantsJson': serializer.toJson<String>(plantsJson),
      'lastLogin': serializer.toJson<DateTime?>(lastLogin),
    };
  }

  ZenGardenTableData copyWith({
    int? id,
    int? water,
    int? sunlight,
    int? exp,
    String? plantsJson,
    Value<DateTime?> lastLogin = const Value.absent(),
  }) => ZenGardenTableData(
    id: id ?? this.id,
    water: water ?? this.water,
    sunlight: sunlight ?? this.sunlight,
    exp: exp ?? this.exp,
    plantsJson: plantsJson ?? this.plantsJson,
    lastLogin: lastLogin.present ? lastLogin.value : this.lastLogin,
  );
  ZenGardenTableData copyWithCompanion(ZenGardenTableCompanion data) {
    return ZenGardenTableData(
      id: data.id.present ? data.id.value : this.id,
      water: data.water.present ? data.water.value : this.water,
      sunlight: data.sunlight.present ? data.sunlight.value : this.sunlight,
      exp: data.exp.present ? data.exp.value : this.exp,
      plantsJson: data.plantsJson.present
          ? data.plantsJson.value
          : this.plantsJson,
      lastLogin: data.lastLogin.present ? data.lastLogin.value : this.lastLogin,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ZenGardenTableData(')
          ..write('id: $id, ')
          ..write('water: $water, ')
          ..write('sunlight: $sunlight, ')
          ..write('exp: $exp, ')
          ..write('plantsJson: $plantsJson, ')
          ..write('lastLogin: $lastLogin')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, water, sunlight, exp, plantsJson, lastLogin);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ZenGardenTableData &&
          other.id == this.id &&
          other.water == this.water &&
          other.sunlight == this.sunlight &&
          other.exp == this.exp &&
          other.plantsJson == this.plantsJson &&
          other.lastLogin == this.lastLogin);
}

class ZenGardenTableCompanion extends UpdateCompanion<ZenGardenTableData> {
  final Value<int> id;
  final Value<int> water;
  final Value<int> sunlight;
  final Value<int> exp;
  final Value<String> plantsJson;
  final Value<DateTime?> lastLogin;
  const ZenGardenTableCompanion({
    this.id = const Value.absent(),
    this.water = const Value.absent(),
    this.sunlight = const Value.absent(),
    this.exp = const Value.absent(),
    this.plantsJson = const Value.absent(),
    this.lastLogin = const Value.absent(),
  });
  ZenGardenTableCompanion.insert({
    this.id = const Value.absent(),
    this.water = const Value.absent(),
    this.sunlight = const Value.absent(),
    this.exp = const Value.absent(),
    this.plantsJson = const Value.absent(),
    this.lastLogin = const Value.absent(),
  });
  static Insertable<ZenGardenTableData> custom({
    Expression<int>? id,
    Expression<int>? water,
    Expression<int>? sunlight,
    Expression<int>? exp,
    Expression<String>? plantsJson,
    Expression<DateTime>? lastLogin,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (water != null) 'water': water,
      if (sunlight != null) 'sunlight': sunlight,
      if (exp != null) 'exp': exp,
      if (plantsJson != null) 'plants_json': plantsJson,
      if (lastLogin != null) 'last_login': lastLogin,
    });
  }

  ZenGardenTableCompanion copyWith({
    Value<int>? id,
    Value<int>? water,
    Value<int>? sunlight,
    Value<int>? exp,
    Value<String>? plantsJson,
    Value<DateTime?>? lastLogin,
  }) {
    return ZenGardenTableCompanion(
      id: id ?? this.id,
      water: water ?? this.water,
      sunlight: sunlight ?? this.sunlight,
      exp: exp ?? this.exp,
      plantsJson: plantsJson ?? this.plantsJson,
      lastLogin: lastLogin ?? this.lastLogin,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (water.present) {
      map['water'] = Variable<int>(water.value);
    }
    if (sunlight.present) {
      map['sunlight'] = Variable<int>(sunlight.value);
    }
    if (exp.present) {
      map['exp'] = Variable<int>(exp.value);
    }
    if (plantsJson.present) {
      map['plants_json'] = Variable<String>(plantsJson.value);
    }
    if (lastLogin.present) {
      map['last_login'] = Variable<DateTime>(lastLogin.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ZenGardenTableCompanion(')
          ..write('id: $id, ')
          ..write('water: $water, ')
          ..write('sunlight: $sunlight, ')
          ..write('exp: $exp, ')
          ..write('plantsJson: $plantsJson, ')
          ..write('lastLogin: $lastLogin')
          ..write(')'))
        .toString();
  }
}

class $LessonTableTable extends LessonTable
    with TableInfo<$LessonTableTable, LessonTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LessonTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isCompletedMeta = const VerificationMeta(
    'isCompleted',
  );
  @override
  late final GeneratedColumn<bool> isCompleted = GeneratedColumn<bool>(
    'is_completed',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_completed" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [id, isCompleted];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'lesson_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<LessonTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('is_completed')) {
      context.handle(
        _isCompletedMeta,
        isCompleted.isAcceptableOrUnknown(
          data['is_completed']!,
          _isCompletedMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LessonTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LessonTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      isCompleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_completed'],
      )!,
    );
  }

  @override
  $LessonTableTable createAlias(String alias) {
    return $LessonTableTable(attachedDatabase, alias);
  }
}

class LessonTableData extends DataClass implements Insertable<LessonTableData> {
  final String id;
  final bool isCompleted;
  const LessonTableData({required this.id, required this.isCompleted});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['is_completed'] = Variable<bool>(isCompleted);
    return map;
  }

  LessonTableCompanion toCompanion(bool nullToAbsent) {
    return LessonTableCompanion(id: Value(id), isCompleted: Value(isCompleted));
  }

  factory LessonTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LessonTableData(
      id: serializer.fromJson<String>(json['id']),
      isCompleted: serializer.fromJson<bool>(json['isCompleted']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'isCompleted': serializer.toJson<bool>(isCompleted),
    };
  }

  LessonTableData copyWith({String? id, bool? isCompleted}) => LessonTableData(
    id: id ?? this.id,
    isCompleted: isCompleted ?? this.isCompleted,
  );
  LessonTableData copyWithCompanion(LessonTableCompanion data) {
    return LessonTableData(
      id: data.id.present ? data.id.value : this.id,
      isCompleted: data.isCompleted.present
          ? data.isCompleted.value
          : this.isCompleted,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LessonTableData(')
          ..write('id: $id, ')
          ..write('isCompleted: $isCompleted')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, isCompleted);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LessonTableData &&
          other.id == this.id &&
          other.isCompleted == this.isCompleted);
}

class LessonTableCompanion extends UpdateCompanion<LessonTableData> {
  final Value<String> id;
  final Value<bool> isCompleted;
  final Value<int> rowid;
  const LessonTableCompanion({
    this.id = const Value.absent(),
    this.isCompleted = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LessonTableCompanion.insert({
    required String id,
    this.isCompleted = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id);
  static Insertable<LessonTableData> custom({
    Expression<String>? id,
    Expression<bool>? isCompleted,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (isCompleted != null) 'is_completed': isCompleted,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LessonTableCompanion copyWith({
    Value<String>? id,
    Value<bool>? isCompleted,
    Value<int>? rowid,
  }) {
    return LessonTableCompanion(
      id: id ?? this.id,
      isCompleted: isCompleted ?? this.isCompleted,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (isCompleted.present) {
      map['is_completed'] = Variable<bool>(isCompleted.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LessonTableCompanion(')
          ..write('id: $id, ')
          ..write('isCompleted: $isCompleted, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $StudyLogTableTable extends StudyLogTable
    with TableInfo<$StudyLogTableTable, StudyLogTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $StudyLogTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _countMeta = const VerificationMeta('count');
  @override
  late final GeneratedColumn<int> count = GeneratedColumn<int>(
    'count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [date, count];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'study_log_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<StudyLogTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('count')) {
      context.handle(
        _countMeta,
        count.isAcceptableOrUnknown(data['count']!, _countMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {date};
  @override
  StudyLogTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return StudyLogTableData(
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date'],
      )!,
      count: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}count'],
      )!,
    );
  }

  @override
  $StudyLogTableTable createAlias(String alias) {
    return $StudyLogTableTable(attachedDatabase, alias);
  }
}

class StudyLogTableData extends DataClass
    implements Insertable<StudyLogTableData> {
  final DateTime date;
  final int count;
  const StudyLogTableData({required this.date, required this.count});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['date'] = Variable<DateTime>(date);
    map['count'] = Variable<int>(count);
    return map;
  }

  StudyLogTableCompanion toCompanion(bool nullToAbsent) {
    return StudyLogTableCompanion(date: Value(date), count: Value(count));
  }

  factory StudyLogTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return StudyLogTableData(
      date: serializer.fromJson<DateTime>(json['date']),
      count: serializer.fromJson<int>(json['count']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'date': serializer.toJson<DateTime>(date),
      'count': serializer.toJson<int>(count),
    };
  }

  StudyLogTableData copyWith({DateTime? date, int? count}) =>
      StudyLogTableData(date: date ?? this.date, count: count ?? this.count);
  StudyLogTableData copyWithCompanion(StudyLogTableCompanion data) {
    return StudyLogTableData(
      date: data.date.present ? data.date.value : this.date,
      count: data.count.present ? data.count.value : this.count,
    );
  }

  @override
  String toString() {
    return (StringBuffer('StudyLogTableData(')
          ..write('date: $date, ')
          ..write('count: $count')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(date, count);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is StudyLogTableData &&
          other.date == this.date &&
          other.count == this.count);
}

class StudyLogTableCompanion extends UpdateCompanion<StudyLogTableData> {
  final Value<DateTime> date;
  final Value<int> count;
  final Value<int> rowid;
  const StudyLogTableCompanion({
    this.date = const Value.absent(),
    this.count = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  StudyLogTableCompanion.insert({
    required DateTime date,
    this.count = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : date = Value(date);
  static Insertable<StudyLogTableData> custom({
    Expression<DateTime>? date,
    Expression<int>? count,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (date != null) 'date': date,
      if (count != null) 'count': count,
      if (rowid != null) 'rowid': rowid,
    });
  }

  StudyLogTableCompanion copyWith({
    Value<DateTime>? date,
    Value<int>? count,
    Value<int>? rowid,
  }) {
    return StudyLogTableCompanion(
      date: date ?? this.date,
      count: count ?? this.count,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (count.present) {
      map['count'] = Variable<int>(count.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('StudyLogTableCompanion(')
          ..write('date: $date, ')
          ..write('count: $count, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ReviewLogTableTable extends ReviewLogTable
    with TableInfo<$ReviewLogTableTable, ReviewLogTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ReviewLogTableTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _itemIdMeta = const VerificationMeta('itemId');
  @override
  late final GeneratedColumn<String> itemId = GeneratedColumn<String>(
    'item_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _itemTypeMeta = const VerificationMeta(
    'itemType',
  );
  @override
  late final GeneratedColumn<String> itemType = GeneratedColumn<String>(
    'item_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ratingMeta = const VerificationMeta('rating');
  @override
  late final GeneratedColumn<int> rating = GeneratedColumn<int>(
    'rating',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _reviewTimeMeta = const VerificationMeta(
    'reviewTime',
  );
  @override
  late final GeneratedColumn<DateTime> reviewTime = GeneratedColumn<DateTime>(
    'review_time',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _durationMsMeta = const VerificationMeta(
    'durationMs',
  );
  @override
  late final GeneratedColumn<int> durationMs = GeneratedColumn<int>(
    'duration_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    itemId,
    itemType,
    rating,
    reviewTime,
    durationMs,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'review_log_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<ReviewLogTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('item_id')) {
      context.handle(
        _itemIdMeta,
        itemId.isAcceptableOrUnknown(data['item_id']!, _itemIdMeta),
      );
    } else if (isInserting) {
      context.missing(_itemIdMeta);
    }
    if (data.containsKey('item_type')) {
      context.handle(
        _itemTypeMeta,
        itemType.isAcceptableOrUnknown(data['item_type']!, _itemTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_itemTypeMeta);
    }
    if (data.containsKey('rating')) {
      context.handle(
        _ratingMeta,
        rating.isAcceptableOrUnknown(data['rating']!, _ratingMeta),
      );
    } else if (isInserting) {
      context.missing(_ratingMeta);
    }
    if (data.containsKey('review_time')) {
      context.handle(
        _reviewTimeMeta,
        reviewTime.isAcceptableOrUnknown(data['review_time']!, _reviewTimeMeta),
      );
    } else if (isInserting) {
      context.missing(_reviewTimeMeta);
    }
    if (data.containsKey('duration_ms')) {
      context.handle(
        _durationMsMeta,
        durationMs.isAcceptableOrUnknown(data['duration_ms']!, _durationMsMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ReviewLogTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ReviewLogTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      itemId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}item_id'],
      )!,
      itemType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}item_type'],
      )!,
      rating: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}rating'],
      )!,
      reviewTime: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}review_time'],
      )!,
      durationMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}duration_ms'],
      )!,
    );
  }

  @override
  $ReviewLogTableTable createAlias(String alias) {
    return $ReviewLogTableTable(attachedDatabase, alias);
  }
}

class ReviewLogTableData extends DataClass
    implements Insertable<ReviewLogTableData> {
  final int id;
  final String itemId;
  final String itemType;
  final int rating;
  final DateTime reviewTime;
  final int durationMs;
  const ReviewLogTableData({
    required this.id,
    required this.itemId,
    required this.itemType,
    required this.rating,
    required this.reviewTime,
    required this.durationMs,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['item_id'] = Variable<String>(itemId);
    map['item_type'] = Variable<String>(itemType);
    map['rating'] = Variable<int>(rating);
    map['review_time'] = Variable<DateTime>(reviewTime);
    map['duration_ms'] = Variable<int>(durationMs);
    return map;
  }

  ReviewLogTableCompanion toCompanion(bool nullToAbsent) {
    return ReviewLogTableCompanion(
      id: Value(id),
      itemId: Value(itemId),
      itemType: Value(itemType),
      rating: Value(rating),
      reviewTime: Value(reviewTime),
      durationMs: Value(durationMs),
    );
  }

  factory ReviewLogTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ReviewLogTableData(
      id: serializer.fromJson<int>(json['id']),
      itemId: serializer.fromJson<String>(json['itemId']),
      itemType: serializer.fromJson<String>(json['itemType']),
      rating: serializer.fromJson<int>(json['rating']),
      reviewTime: serializer.fromJson<DateTime>(json['reviewTime']),
      durationMs: serializer.fromJson<int>(json['durationMs']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'itemId': serializer.toJson<String>(itemId),
      'itemType': serializer.toJson<String>(itemType),
      'rating': serializer.toJson<int>(rating),
      'reviewTime': serializer.toJson<DateTime>(reviewTime),
      'durationMs': serializer.toJson<int>(durationMs),
    };
  }

  ReviewLogTableData copyWith({
    int? id,
    String? itemId,
    String? itemType,
    int? rating,
    DateTime? reviewTime,
    int? durationMs,
  }) => ReviewLogTableData(
    id: id ?? this.id,
    itemId: itemId ?? this.itemId,
    itemType: itemType ?? this.itemType,
    rating: rating ?? this.rating,
    reviewTime: reviewTime ?? this.reviewTime,
    durationMs: durationMs ?? this.durationMs,
  );
  ReviewLogTableData copyWithCompanion(ReviewLogTableCompanion data) {
    return ReviewLogTableData(
      id: data.id.present ? data.id.value : this.id,
      itemId: data.itemId.present ? data.itemId.value : this.itemId,
      itemType: data.itemType.present ? data.itemType.value : this.itemType,
      rating: data.rating.present ? data.rating.value : this.rating,
      reviewTime: data.reviewTime.present
          ? data.reviewTime.value
          : this.reviewTime,
      durationMs: data.durationMs.present
          ? data.durationMs.value
          : this.durationMs,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ReviewLogTableData(')
          ..write('id: $id, ')
          ..write('itemId: $itemId, ')
          ..write('itemType: $itemType, ')
          ..write('rating: $rating, ')
          ..write('reviewTime: $reviewTime, ')
          ..write('durationMs: $durationMs')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, itemId, itemType, rating, reviewTime, durationMs);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ReviewLogTableData &&
          other.id == this.id &&
          other.itemId == this.itemId &&
          other.itemType == this.itemType &&
          other.rating == this.rating &&
          other.reviewTime == this.reviewTime &&
          other.durationMs == this.durationMs);
}

class ReviewLogTableCompanion extends UpdateCompanion<ReviewLogTableData> {
  final Value<int> id;
  final Value<String> itemId;
  final Value<String> itemType;
  final Value<int> rating;
  final Value<DateTime> reviewTime;
  final Value<int> durationMs;
  const ReviewLogTableCompanion({
    this.id = const Value.absent(),
    this.itemId = const Value.absent(),
    this.itemType = const Value.absent(),
    this.rating = const Value.absent(),
    this.reviewTime = const Value.absent(),
    this.durationMs = const Value.absent(),
  });
  ReviewLogTableCompanion.insert({
    this.id = const Value.absent(),
    required String itemId,
    required String itemType,
    required int rating,
    required DateTime reviewTime,
    this.durationMs = const Value.absent(),
  }) : itemId = Value(itemId),
       itemType = Value(itemType),
       rating = Value(rating),
       reviewTime = Value(reviewTime);
  static Insertable<ReviewLogTableData> custom({
    Expression<int>? id,
    Expression<String>? itemId,
    Expression<String>? itemType,
    Expression<int>? rating,
    Expression<DateTime>? reviewTime,
    Expression<int>? durationMs,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (itemId != null) 'item_id': itemId,
      if (itemType != null) 'item_type': itemType,
      if (rating != null) 'rating': rating,
      if (reviewTime != null) 'review_time': reviewTime,
      if (durationMs != null) 'duration_ms': durationMs,
    });
  }

  ReviewLogTableCompanion copyWith({
    Value<int>? id,
    Value<String>? itemId,
    Value<String>? itemType,
    Value<int>? rating,
    Value<DateTime>? reviewTime,
    Value<int>? durationMs,
  }) {
    return ReviewLogTableCompanion(
      id: id ?? this.id,
      itemId: itemId ?? this.itemId,
      itemType: itemType ?? this.itemType,
      rating: rating ?? this.rating,
      reviewTime: reviewTime ?? this.reviewTime,
      durationMs: durationMs ?? this.durationMs,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (itemId.present) {
      map['item_id'] = Variable<String>(itemId.value);
    }
    if (itemType.present) {
      map['item_type'] = Variable<String>(itemType.value);
    }
    if (rating.present) {
      map['rating'] = Variable<int>(rating.value);
    }
    if (reviewTime.present) {
      map['review_time'] = Variable<DateTime>(reviewTime.value);
    }
    if (durationMs.present) {
      map['duration_ms'] = Variable<int>(durationMs.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ReviewLogTableCompanion(')
          ..write('id: $id, ')
          ..write('itemId: $itemId, ')
          ..write('itemType: $itemType, ')
          ..write('rating: $rating, ')
          ..write('reviewTime: $reviewTime, ')
          ..write('durationMs: $durationMs')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $KanjiCardTableTable kanjiCardTable = $KanjiCardTableTable(this);
  late final $VocabularyTableTable vocabularyTable = $VocabularyTableTable(
    this,
  );
  late final $GrammarTableTable grammarTable = $GrammarTableTable(this);
  late final $ZenGardenTableTable zenGardenTable = $ZenGardenTableTable(this);
  late final $LessonTableTable lessonTable = $LessonTableTable(this);
  late final $StudyLogTableTable studyLogTable = $StudyLogTableTable(this);
  late final $ReviewLogTableTable reviewLogTable = $ReviewLogTableTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    kanjiCardTable,
    vocabularyTable,
    grammarTable,
    zenGardenTable,
    lessonTable,
    studyLogTable,
    reviewLogTable,
  ];
}

typedef $$KanjiCardTableTableCreateCompanionBuilder =
    KanjiCardTableCompanion Function({
      required String id,
      required String kanji,
      required String meanings,
      required String onyomi,
      required String kunyomi,
      Value<String?> strokeData,
      Value<int> jlptLevel,
      Value<double> stability,
      Value<double> difficulty,
      Value<DateTime?> lastReview,
      required DateTime nextReview,
      Value<int> reps,
      Value<int> lapses,
      Value<int> state,
      Value<int> rowid,
    });
typedef $$KanjiCardTableTableUpdateCompanionBuilder =
    KanjiCardTableCompanion Function({
      Value<String> id,
      Value<String> kanji,
      Value<String> meanings,
      Value<String> onyomi,
      Value<String> kunyomi,
      Value<String?> strokeData,
      Value<int> jlptLevel,
      Value<double> stability,
      Value<double> difficulty,
      Value<DateTime?> lastReview,
      Value<DateTime> nextReview,
      Value<int> reps,
      Value<int> lapses,
      Value<int> state,
      Value<int> rowid,
    });

class $$KanjiCardTableTableFilterComposer
    extends Composer<_$AppDatabase, $KanjiCardTableTable> {
  $$KanjiCardTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get kanji => $composableBuilder(
    column: $table.kanji,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get meanings => $composableBuilder(
    column: $table.meanings,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get onyomi => $composableBuilder(
    column: $table.onyomi,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get kunyomi => $composableBuilder(
    column: $table.kunyomi,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get strokeData => $composableBuilder(
    column: $table.strokeData,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get jlptLevel => $composableBuilder(
    column: $table.jlptLevel,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get stability => $composableBuilder(
    column: $table.stability,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get difficulty => $composableBuilder(
    column: $table.difficulty,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastReview => $composableBuilder(
    column: $table.lastReview,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get nextReview => $composableBuilder(
    column: $table.nextReview,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get reps => $composableBuilder(
    column: $table.reps,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lapses => $composableBuilder(
    column: $table.lapses,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get state => $composableBuilder(
    column: $table.state,
    builder: (column) => ColumnFilters(column),
  );
}

class $$KanjiCardTableTableOrderingComposer
    extends Composer<_$AppDatabase, $KanjiCardTableTable> {
  $$KanjiCardTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kanji => $composableBuilder(
    column: $table.kanji,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get meanings => $composableBuilder(
    column: $table.meanings,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get onyomi => $composableBuilder(
    column: $table.onyomi,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kunyomi => $composableBuilder(
    column: $table.kunyomi,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get strokeData => $composableBuilder(
    column: $table.strokeData,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get jlptLevel => $composableBuilder(
    column: $table.jlptLevel,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get stability => $composableBuilder(
    column: $table.stability,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get difficulty => $composableBuilder(
    column: $table.difficulty,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastReview => $composableBuilder(
    column: $table.lastReview,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get nextReview => $composableBuilder(
    column: $table.nextReview,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get reps => $composableBuilder(
    column: $table.reps,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lapses => $composableBuilder(
    column: $table.lapses,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get state => $composableBuilder(
    column: $table.state,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$KanjiCardTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $KanjiCardTableTable> {
  $$KanjiCardTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get kanji =>
      $composableBuilder(column: $table.kanji, builder: (column) => column);

  GeneratedColumn<String> get meanings =>
      $composableBuilder(column: $table.meanings, builder: (column) => column);

  GeneratedColumn<String> get onyomi =>
      $composableBuilder(column: $table.onyomi, builder: (column) => column);

  GeneratedColumn<String> get kunyomi =>
      $composableBuilder(column: $table.kunyomi, builder: (column) => column);

  GeneratedColumn<String> get strokeData => $composableBuilder(
    column: $table.strokeData,
    builder: (column) => column,
  );

  GeneratedColumn<int> get jlptLevel =>
      $composableBuilder(column: $table.jlptLevel, builder: (column) => column);

  GeneratedColumn<double> get stability =>
      $composableBuilder(column: $table.stability, builder: (column) => column);

  GeneratedColumn<double> get difficulty => $composableBuilder(
    column: $table.difficulty,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get lastReview => $composableBuilder(
    column: $table.lastReview,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get nextReview => $composableBuilder(
    column: $table.nextReview,
    builder: (column) => column,
  );

  GeneratedColumn<int> get reps =>
      $composableBuilder(column: $table.reps, builder: (column) => column);

  GeneratedColumn<int> get lapses =>
      $composableBuilder(column: $table.lapses, builder: (column) => column);

  GeneratedColumn<int> get state =>
      $composableBuilder(column: $table.state, builder: (column) => column);
}

class $$KanjiCardTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $KanjiCardTableTable,
          KanjiCardData,
          $$KanjiCardTableTableFilterComposer,
          $$KanjiCardTableTableOrderingComposer,
          $$KanjiCardTableTableAnnotationComposer,
          $$KanjiCardTableTableCreateCompanionBuilder,
          $$KanjiCardTableTableUpdateCompanionBuilder,
          (
            KanjiCardData,
            BaseReferences<_$AppDatabase, $KanjiCardTableTable, KanjiCardData>,
          ),
          KanjiCardData,
          PrefetchHooks Function()
        > {
  $$KanjiCardTableTableTableManager(
    _$AppDatabase db,
    $KanjiCardTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$KanjiCardTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$KanjiCardTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$KanjiCardTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> kanji = const Value.absent(),
                Value<String> meanings = const Value.absent(),
                Value<String> onyomi = const Value.absent(),
                Value<String> kunyomi = const Value.absent(),
                Value<String?> strokeData = const Value.absent(),
                Value<int> jlptLevel = const Value.absent(),
                Value<double> stability = const Value.absent(),
                Value<double> difficulty = const Value.absent(),
                Value<DateTime?> lastReview = const Value.absent(),
                Value<DateTime> nextReview = const Value.absent(),
                Value<int> reps = const Value.absent(),
                Value<int> lapses = const Value.absent(),
                Value<int> state = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => KanjiCardTableCompanion(
                id: id,
                kanji: kanji,
                meanings: meanings,
                onyomi: onyomi,
                kunyomi: kunyomi,
                strokeData: strokeData,
                jlptLevel: jlptLevel,
                stability: stability,
                difficulty: difficulty,
                lastReview: lastReview,
                nextReview: nextReview,
                reps: reps,
                lapses: lapses,
                state: state,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String kanji,
                required String meanings,
                required String onyomi,
                required String kunyomi,
                Value<String?> strokeData = const Value.absent(),
                Value<int> jlptLevel = const Value.absent(),
                Value<double> stability = const Value.absent(),
                Value<double> difficulty = const Value.absent(),
                Value<DateTime?> lastReview = const Value.absent(),
                required DateTime nextReview,
                Value<int> reps = const Value.absent(),
                Value<int> lapses = const Value.absent(),
                Value<int> state = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => KanjiCardTableCompanion.insert(
                id: id,
                kanji: kanji,
                meanings: meanings,
                onyomi: onyomi,
                kunyomi: kunyomi,
                strokeData: strokeData,
                jlptLevel: jlptLevel,
                stability: stability,
                difficulty: difficulty,
                lastReview: lastReview,
                nextReview: nextReview,
                reps: reps,
                lapses: lapses,
                state: state,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$KanjiCardTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $KanjiCardTableTable,
      KanjiCardData,
      $$KanjiCardTableTableFilterComposer,
      $$KanjiCardTableTableOrderingComposer,
      $$KanjiCardTableTableAnnotationComposer,
      $$KanjiCardTableTableCreateCompanionBuilder,
      $$KanjiCardTableTableUpdateCompanionBuilder,
      (
        KanjiCardData,
        BaseReferences<_$AppDatabase, $KanjiCardTableTable, KanjiCardData>,
      ),
      KanjiCardData,
      PrefetchHooks Function()
    >;
typedef $$VocabularyTableTableCreateCompanionBuilder =
    VocabularyTableCompanion Function({
      required String id,
      required String word,
      required String reading,
      required String meaning,
      Value<int> jlptLevel,
      Value<double> stability,
      Value<double> difficulty,
      Value<DateTime?> lastReview,
      required DateTime nextReview,
      Value<int> reps,
      Value<int> lapses,
      Value<int> state,
      Value<int> rowid,
    });
typedef $$VocabularyTableTableUpdateCompanionBuilder =
    VocabularyTableCompanion Function({
      Value<String> id,
      Value<String> word,
      Value<String> reading,
      Value<String> meaning,
      Value<int> jlptLevel,
      Value<double> stability,
      Value<double> difficulty,
      Value<DateTime?> lastReview,
      Value<DateTime> nextReview,
      Value<int> reps,
      Value<int> lapses,
      Value<int> state,
      Value<int> rowid,
    });

class $$VocabularyTableTableFilterComposer
    extends Composer<_$AppDatabase, $VocabularyTableTable> {
  $$VocabularyTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get word => $composableBuilder(
    column: $table.word,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get reading => $composableBuilder(
    column: $table.reading,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get meaning => $composableBuilder(
    column: $table.meaning,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get jlptLevel => $composableBuilder(
    column: $table.jlptLevel,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get stability => $composableBuilder(
    column: $table.stability,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get difficulty => $composableBuilder(
    column: $table.difficulty,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastReview => $composableBuilder(
    column: $table.lastReview,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get nextReview => $composableBuilder(
    column: $table.nextReview,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get reps => $composableBuilder(
    column: $table.reps,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lapses => $composableBuilder(
    column: $table.lapses,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get state => $composableBuilder(
    column: $table.state,
    builder: (column) => ColumnFilters(column),
  );
}

class $$VocabularyTableTableOrderingComposer
    extends Composer<_$AppDatabase, $VocabularyTableTable> {
  $$VocabularyTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get word => $composableBuilder(
    column: $table.word,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get reading => $composableBuilder(
    column: $table.reading,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get meaning => $composableBuilder(
    column: $table.meaning,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get jlptLevel => $composableBuilder(
    column: $table.jlptLevel,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get stability => $composableBuilder(
    column: $table.stability,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get difficulty => $composableBuilder(
    column: $table.difficulty,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastReview => $composableBuilder(
    column: $table.lastReview,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get nextReview => $composableBuilder(
    column: $table.nextReview,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get reps => $composableBuilder(
    column: $table.reps,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lapses => $composableBuilder(
    column: $table.lapses,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get state => $composableBuilder(
    column: $table.state,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$VocabularyTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $VocabularyTableTable> {
  $$VocabularyTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get word =>
      $composableBuilder(column: $table.word, builder: (column) => column);

  GeneratedColumn<String> get reading =>
      $composableBuilder(column: $table.reading, builder: (column) => column);

  GeneratedColumn<String> get meaning =>
      $composableBuilder(column: $table.meaning, builder: (column) => column);

  GeneratedColumn<int> get jlptLevel =>
      $composableBuilder(column: $table.jlptLevel, builder: (column) => column);

  GeneratedColumn<double> get stability =>
      $composableBuilder(column: $table.stability, builder: (column) => column);

  GeneratedColumn<double> get difficulty => $composableBuilder(
    column: $table.difficulty,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get lastReview => $composableBuilder(
    column: $table.lastReview,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get nextReview => $composableBuilder(
    column: $table.nextReview,
    builder: (column) => column,
  );

  GeneratedColumn<int> get reps =>
      $composableBuilder(column: $table.reps, builder: (column) => column);

  GeneratedColumn<int> get lapses =>
      $composableBuilder(column: $table.lapses, builder: (column) => column);

  GeneratedColumn<int> get state =>
      $composableBuilder(column: $table.state, builder: (column) => column);
}

class $$VocabularyTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $VocabularyTableTable,
          VocabularyTableData,
          $$VocabularyTableTableFilterComposer,
          $$VocabularyTableTableOrderingComposer,
          $$VocabularyTableTableAnnotationComposer,
          $$VocabularyTableTableCreateCompanionBuilder,
          $$VocabularyTableTableUpdateCompanionBuilder,
          (
            VocabularyTableData,
            BaseReferences<
              _$AppDatabase,
              $VocabularyTableTable,
              VocabularyTableData
            >,
          ),
          VocabularyTableData,
          PrefetchHooks Function()
        > {
  $$VocabularyTableTableTableManager(
    _$AppDatabase db,
    $VocabularyTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$VocabularyTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$VocabularyTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$VocabularyTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> word = const Value.absent(),
                Value<String> reading = const Value.absent(),
                Value<String> meaning = const Value.absent(),
                Value<int> jlptLevel = const Value.absent(),
                Value<double> stability = const Value.absent(),
                Value<double> difficulty = const Value.absent(),
                Value<DateTime?> lastReview = const Value.absent(),
                Value<DateTime> nextReview = const Value.absent(),
                Value<int> reps = const Value.absent(),
                Value<int> lapses = const Value.absent(),
                Value<int> state = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => VocabularyTableCompanion(
                id: id,
                word: word,
                reading: reading,
                meaning: meaning,
                jlptLevel: jlptLevel,
                stability: stability,
                difficulty: difficulty,
                lastReview: lastReview,
                nextReview: nextReview,
                reps: reps,
                lapses: lapses,
                state: state,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String word,
                required String reading,
                required String meaning,
                Value<int> jlptLevel = const Value.absent(),
                Value<double> stability = const Value.absent(),
                Value<double> difficulty = const Value.absent(),
                Value<DateTime?> lastReview = const Value.absent(),
                required DateTime nextReview,
                Value<int> reps = const Value.absent(),
                Value<int> lapses = const Value.absent(),
                Value<int> state = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => VocabularyTableCompanion.insert(
                id: id,
                word: word,
                reading: reading,
                meaning: meaning,
                jlptLevel: jlptLevel,
                stability: stability,
                difficulty: difficulty,
                lastReview: lastReview,
                nextReview: nextReview,
                reps: reps,
                lapses: lapses,
                state: state,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$VocabularyTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $VocabularyTableTable,
      VocabularyTableData,
      $$VocabularyTableTableFilterComposer,
      $$VocabularyTableTableOrderingComposer,
      $$VocabularyTableTableAnnotationComposer,
      $$VocabularyTableTableCreateCompanionBuilder,
      $$VocabularyTableTableUpdateCompanionBuilder,
      (
        VocabularyTableData,
        BaseReferences<
          _$AppDatabase,
          $VocabularyTableTable,
          VocabularyTableData
        >,
      ),
      VocabularyTableData,
      PrefetchHooks Function()
    >;
typedef $$GrammarTableTableCreateCompanionBuilder =
    GrammarTableCompanion Function({
      required String id,
      required String title,
      required String structure,
      required String explanation,
      required String example,
      Value<int> jlptLevel,
      Value<bool> isLearned,
      Value<int> rowid,
    });
typedef $$GrammarTableTableUpdateCompanionBuilder =
    GrammarTableCompanion Function({
      Value<String> id,
      Value<String> title,
      Value<String> structure,
      Value<String> explanation,
      Value<String> example,
      Value<int> jlptLevel,
      Value<bool> isLearned,
      Value<int> rowid,
    });

class $$GrammarTableTableFilterComposer
    extends Composer<_$AppDatabase, $GrammarTableTable> {
  $$GrammarTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get structure => $composableBuilder(
    column: $table.structure,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get explanation => $composableBuilder(
    column: $table.explanation,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get example => $composableBuilder(
    column: $table.example,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get jlptLevel => $composableBuilder(
    column: $table.jlptLevel,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isLearned => $composableBuilder(
    column: $table.isLearned,
    builder: (column) => ColumnFilters(column),
  );
}

class $$GrammarTableTableOrderingComposer
    extends Composer<_$AppDatabase, $GrammarTableTable> {
  $$GrammarTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get structure => $composableBuilder(
    column: $table.structure,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get explanation => $composableBuilder(
    column: $table.explanation,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get example => $composableBuilder(
    column: $table.example,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get jlptLevel => $composableBuilder(
    column: $table.jlptLevel,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isLearned => $composableBuilder(
    column: $table.isLearned,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$GrammarTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $GrammarTableTable> {
  $$GrammarTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get structure =>
      $composableBuilder(column: $table.structure, builder: (column) => column);

  GeneratedColumn<String> get explanation => $composableBuilder(
    column: $table.explanation,
    builder: (column) => column,
  );

  GeneratedColumn<String> get example =>
      $composableBuilder(column: $table.example, builder: (column) => column);

  GeneratedColumn<int> get jlptLevel =>
      $composableBuilder(column: $table.jlptLevel, builder: (column) => column);

  GeneratedColumn<bool> get isLearned =>
      $composableBuilder(column: $table.isLearned, builder: (column) => column);
}

class $$GrammarTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $GrammarTableTable,
          GrammarTableData,
          $$GrammarTableTableFilterComposer,
          $$GrammarTableTableOrderingComposer,
          $$GrammarTableTableAnnotationComposer,
          $$GrammarTableTableCreateCompanionBuilder,
          $$GrammarTableTableUpdateCompanionBuilder,
          (
            GrammarTableData,
            BaseReferences<_$AppDatabase, $GrammarTableTable, GrammarTableData>,
          ),
          GrammarTableData,
          PrefetchHooks Function()
        > {
  $$GrammarTableTableTableManager(_$AppDatabase db, $GrammarTableTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$GrammarTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$GrammarTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$GrammarTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> structure = const Value.absent(),
                Value<String> explanation = const Value.absent(),
                Value<String> example = const Value.absent(),
                Value<int> jlptLevel = const Value.absent(),
                Value<bool> isLearned = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => GrammarTableCompanion(
                id: id,
                title: title,
                structure: structure,
                explanation: explanation,
                example: example,
                jlptLevel: jlptLevel,
                isLearned: isLearned,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String title,
                required String structure,
                required String explanation,
                required String example,
                Value<int> jlptLevel = const Value.absent(),
                Value<bool> isLearned = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => GrammarTableCompanion.insert(
                id: id,
                title: title,
                structure: structure,
                explanation: explanation,
                example: example,
                jlptLevel: jlptLevel,
                isLearned: isLearned,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$GrammarTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $GrammarTableTable,
      GrammarTableData,
      $$GrammarTableTableFilterComposer,
      $$GrammarTableTableOrderingComposer,
      $$GrammarTableTableAnnotationComposer,
      $$GrammarTableTableCreateCompanionBuilder,
      $$GrammarTableTableUpdateCompanionBuilder,
      (
        GrammarTableData,
        BaseReferences<_$AppDatabase, $GrammarTableTable, GrammarTableData>,
      ),
      GrammarTableData,
      PrefetchHooks Function()
    >;
typedef $$ZenGardenTableTableCreateCompanionBuilder =
    ZenGardenTableCompanion Function({
      Value<int> id,
      Value<int> water,
      Value<int> sunlight,
      Value<int> exp,
      Value<String> plantsJson,
      Value<DateTime?> lastLogin,
    });
typedef $$ZenGardenTableTableUpdateCompanionBuilder =
    ZenGardenTableCompanion Function({
      Value<int> id,
      Value<int> water,
      Value<int> sunlight,
      Value<int> exp,
      Value<String> plantsJson,
      Value<DateTime?> lastLogin,
    });

class $$ZenGardenTableTableFilterComposer
    extends Composer<_$AppDatabase, $ZenGardenTableTable> {
  $$ZenGardenTableTableFilterComposer({
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

  ColumnFilters<int> get water => $composableBuilder(
    column: $table.water,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sunlight => $composableBuilder(
    column: $table.sunlight,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get exp => $composableBuilder(
    column: $table.exp,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get plantsJson => $composableBuilder(
    column: $table.plantsJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastLogin => $composableBuilder(
    column: $table.lastLogin,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ZenGardenTableTableOrderingComposer
    extends Composer<_$AppDatabase, $ZenGardenTableTable> {
  $$ZenGardenTableTableOrderingComposer({
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

  ColumnOrderings<int> get water => $composableBuilder(
    column: $table.water,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sunlight => $composableBuilder(
    column: $table.sunlight,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get exp => $composableBuilder(
    column: $table.exp,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get plantsJson => $composableBuilder(
    column: $table.plantsJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastLogin => $composableBuilder(
    column: $table.lastLogin,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ZenGardenTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $ZenGardenTableTable> {
  $$ZenGardenTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get water =>
      $composableBuilder(column: $table.water, builder: (column) => column);

  GeneratedColumn<int> get sunlight =>
      $composableBuilder(column: $table.sunlight, builder: (column) => column);

  GeneratedColumn<int> get exp =>
      $composableBuilder(column: $table.exp, builder: (column) => column);

  GeneratedColumn<String> get plantsJson => $composableBuilder(
    column: $table.plantsJson,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get lastLogin =>
      $composableBuilder(column: $table.lastLogin, builder: (column) => column);
}

class $$ZenGardenTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ZenGardenTableTable,
          ZenGardenTableData,
          $$ZenGardenTableTableFilterComposer,
          $$ZenGardenTableTableOrderingComposer,
          $$ZenGardenTableTableAnnotationComposer,
          $$ZenGardenTableTableCreateCompanionBuilder,
          $$ZenGardenTableTableUpdateCompanionBuilder,
          (
            ZenGardenTableData,
            BaseReferences<
              _$AppDatabase,
              $ZenGardenTableTable,
              ZenGardenTableData
            >,
          ),
          ZenGardenTableData,
          PrefetchHooks Function()
        > {
  $$ZenGardenTableTableTableManager(
    _$AppDatabase db,
    $ZenGardenTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ZenGardenTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ZenGardenTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ZenGardenTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> water = const Value.absent(),
                Value<int> sunlight = const Value.absent(),
                Value<int> exp = const Value.absent(),
                Value<String> plantsJson = const Value.absent(),
                Value<DateTime?> lastLogin = const Value.absent(),
              }) => ZenGardenTableCompanion(
                id: id,
                water: water,
                sunlight: sunlight,
                exp: exp,
                plantsJson: plantsJson,
                lastLogin: lastLogin,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> water = const Value.absent(),
                Value<int> sunlight = const Value.absent(),
                Value<int> exp = const Value.absent(),
                Value<String> plantsJson = const Value.absent(),
                Value<DateTime?> lastLogin = const Value.absent(),
              }) => ZenGardenTableCompanion.insert(
                id: id,
                water: water,
                sunlight: sunlight,
                exp: exp,
                plantsJson: plantsJson,
                lastLogin: lastLogin,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ZenGardenTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ZenGardenTableTable,
      ZenGardenTableData,
      $$ZenGardenTableTableFilterComposer,
      $$ZenGardenTableTableOrderingComposer,
      $$ZenGardenTableTableAnnotationComposer,
      $$ZenGardenTableTableCreateCompanionBuilder,
      $$ZenGardenTableTableUpdateCompanionBuilder,
      (
        ZenGardenTableData,
        BaseReferences<_$AppDatabase, $ZenGardenTableTable, ZenGardenTableData>,
      ),
      ZenGardenTableData,
      PrefetchHooks Function()
    >;
typedef $$LessonTableTableCreateCompanionBuilder =
    LessonTableCompanion Function({
      required String id,
      Value<bool> isCompleted,
      Value<int> rowid,
    });
typedef $$LessonTableTableUpdateCompanionBuilder =
    LessonTableCompanion Function({
      Value<String> id,
      Value<bool> isCompleted,
      Value<int> rowid,
    });

class $$LessonTableTableFilterComposer
    extends Composer<_$AppDatabase, $LessonTableTable> {
  $$LessonTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isCompleted => $composableBuilder(
    column: $table.isCompleted,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LessonTableTableOrderingComposer
    extends Composer<_$AppDatabase, $LessonTableTable> {
  $$LessonTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isCompleted => $composableBuilder(
    column: $table.isCompleted,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LessonTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $LessonTableTable> {
  $$LessonTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<bool> get isCompleted => $composableBuilder(
    column: $table.isCompleted,
    builder: (column) => column,
  );
}

class $$LessonTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LessonTableTable,
          LessonTableData,
          $$LessonTableTableFilterComposer,
          $$LessonTableTableOrderingComposer,
          $$LessonTableTableAnnotationComposer,
          $$LessonTableTableCreateCompanionBuilder,
          $$LessonTableTableUpdateCompanionBuilder,
          (
            LessonTableData,
            BaseReferences<_$AppDatabase, $LessonTableTable, LessonTableData>,
          ),
          LessonTableData,
          PrefetchHooks Function()
        > {
  $$LessonTableTableTableManager(_$AppDatabase db, $LessonTableTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LessonTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LessonTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LessonTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<bool> isCompleted = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LessonTableCompanion(
                id: id,
                isCompleted: isCompleted,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<bool> isCompleted = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LessonTableCompanion.insert(
                id: id,
                isCompleted: isCompleted,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LessonTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LessonTableTable,
      LessonTableData,
      $$LessonTableTableFilterComposer,
      $$LessonTableTableOrderingComposer,
      $$LessonTableTableAnnotationComposer,
      $$LessonTableTableCreateCompanionBuilder,
      $$LessonTableTableUpdateCompanionBuilder,
      (
        LessonTableData,
        BaseReferences<_$AppDatabase, $LessonTableTable, LessonTableData>,
      ),
      LessonTableData,
      PrefetchHooks Function()
    >;
typedef $$StudyLogTableTableCreateCompanionBuilder =
    StudyLogTableCompanion Function({
      required DateTime date,
      Value<int> count,
      Value<int> rowid,
    });
typedef $$StudyLogTableTableUpdateCompanionBuilder =
    StudyLogTableCompanion Function({
      Value<DateTime> date,
      Value<int> count,
      Value<int> rowid,
    });

class $$StudyLogTableTableFilterComposer
    extends Composer<_$AppDatabase, $StudyLogTableTable> {
  $$StudyLogTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get count => $composableBuilder(
    column: $table.count,
    builder: (column) => ColumnFilters(column),
  );
}

class $$StudyLogTableTableOrderingComposer
    extends Composer<_$AppDatabase, $StudyLogTableTable> {
  $$StudyLogTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get count => $composableBuilder(
    column: $table.count,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$StudyLogTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $StudyLogTableTable> {
  $$StudyLogTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<int> get count =>
      $composableBuilder(column: $table.count, builder: (column) => column);
}

class $$StudyLogTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $StudyLogTableTable,
          StudyLogTableData,
          $$StudyLogTableTableFilterComposer,
          $$StudyLogTableTableOrderingComposer,
          $$StudyLogTableTableAnnotationComposer,
          $$StudyLogTableTableCreateCompanionBuilder,
          $$StudyLogTableTableUpdateCompanionBuilder,
          (
            StudyLogTableData,
            BaseReferences<
              _$AppDatabase,
              $StudyLogTableTable,
              StudyLogTableData
            >,
          ),
          StudyLogTableData,
          PrefetchHooks Function()
        > {
  $$StudyLogTableTableTableManager(_$AppDatabase db, $StudyLogTableTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$StudyLogTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$StudyLogTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$StudyLogTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<DateTime> date = const Value.absent(),
                Value<int> count = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => StudyLogTableCompanion(
                date: date,
                count: count,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required DateTime date,
                Value<int> count = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => StudyLogTableCompanion.insert(
                date: date,
                count: count,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$StudyLogTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $StudyLogTableTable,
      StudyLogTableData,
      $$StudyLogTableTableFilterComposer,
      $$StudyLogTableTableOrderingComposer,
      $$StudyLogTableTableAnnotationComposer,
      $$StudyLogTableTableCreateCompanionBuilder,
      $$StudyLogTableTableUpdateCompanionBuilder,
      (
        StudyLogTableData,
        BaseReferences<_$AppDatabase, $StudyLogTableTable, StudyLogTableData>,
      ),
      StudyLogTableData,
      PrefetchHooks Function()
    >;
typedef $$ReviewLogTableTableCreateCompanionBuilder =
    ReviewLogTableCompanion Function({
      Value<int> id,
      required String itemId,
      required String itemType,
      required int rating,
      required DateTime reviewTime,
      Value<int> durationMs,
    });
typedef $$ReviewLogTableTableUpdateCompanionBuilder =
    ReviewLogTableCompanion Function({
      Value<int> id,
      Value<String> itemId,
      Value<String> itemType,
      Value<int> rating,
      Value<DateTime> reviewTime,
      Value<int> durationMs,
    });

class $$ReviewLogTableTableFilterComposer
    extends Composer<_$AppDatabase, $ReviewLogTableTable> {
  $$ReviewLogTableTableFilterComposer({
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

  ColumnFilters<String> get itemId => $composableBuilder(
    column: $table.itemId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get itemType => $composableBuilder(
    column: $table.itemType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get rating => $composableBuilder(
    column: $table.rating,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get reviewTime => $composableBuilder(
    column: $table.reviewTime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get durationMs => $composableBuilder(
    column: $table.durationMs,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ReviewLogTableTableOrderingComposer
    extends Composer<_$AppDatabase, $ReviewLogTableTable> {
  $$ReviewLogTableTableOrderingComposer({
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

  ColumnOrderings<String> get itemId => $composableBuilder(
    column: $table.itemId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get itemType => $composableBuilder(
    column: $table.itemType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get rating => $composableBuilder(
    column: $table.rating,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get reviewTime => $composableBuilder(
    column: $table.reviewTime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get durationMs => $composableBuilder(
    column: $table.durationMs,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ReviewLogTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $ReviewLogTableTable> {
  $$ReviewLogTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get itemId =>
      $composableBuilder(column: $table.itemId, builder: (column) => column);

  GeneratedColumn<String> get itemType =>
      $composableBuilder(column: $table.itemType, builder: (column) => column);

  GeneratedColumn<int> get rating =>
      $composableBuilder(column: $table.rating, builder: (column) => column);

  GeneratedColumn<DateTime> get reviewTime => $composableBuilder(
    column: $table.reviewTime,
    builder: (column) => column,
  );

  GeneratedColumn<int> get durationMs => $composableBuilder(
    column: $table.durationMs,
    builder: (column) => column,
  );
}

class $$ReviewLogTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ReviewLogTableTable,
          ReviewLogTableData,
          $$ReviewLogTableTableFilterComposer,
          $$ReviewLogTableTableOrderingComposer,
          $$ReviewLogTableTableAnnotationComposer,
          $$ReviewLogTableTableCreateCompanionBuilder,
          $$ReviewLogTableTableUpdateCompanionBuilder,
          (
            ReviewLogTableData,
            BaseReferences<
              _$AppDatabase,
              $ReviewLogTableTable,
              ReviewLogTableData
            >,
          ),
          ReviewLogTableData,
          PrefetchHooks Function()
        > {
  $$ReviewLogTableTableTableManager(
    _$AppDatabase db,
    $ReviewLogTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ReviewLogTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ReviewLogTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ReviewLogTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> itemId = const Value.absent(),
                Value<String> itemType = const Value.absent(),
                Value<int> rating = const Value.absent(),
                Value<DateTime> reviewTime = const Value.absent(),
                Value<int> durationMs = const Value.absent(),
              }) => ReviewLogTableCompanion(
                id: id,
                itemId: itemId,
                itemType: itemType,
                rating: rating,
                reviewTime: reviewTime,
                durationMs: durationMs,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String itemId,
                required String itemType,
                required int rating,
                required DateTime reviewTime,
                Value<int> durationMs = const Value.absent(),
              }) => ReviewLogTableCompanion.insert(
                id: id,
                itemId: itemId,
                itemType: itemType,
                rating: rating,
                reviewTime: reviewTime,
                durationMs: durationMs,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ReviewLogTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ReviewLogTableTable,
      ReviewLogTableData,
      $$ReviewLogTableTableFilterComposer,
      $$ReviewLogTableTableOrderingComposer,
      $$ReviewLogTableTableAnnotationComposer,
      $$ReviewLogTableTableCreateCompanionBuilder,
      $$ReviewLogTableTableUpdateCompanionBuilder,
      (
        ReviewLogTableData,
        BaseReferences<_$AppDatabase, $ReviewLogTableTable, ReviewLogTableData>,
      ),
      ReviewLogTableData,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$KanjiCardTableTableTableManager get kanjiCardTable =>
      $$KanjiCardTableTableTableManager(_db, _db.kanjiCardTable);
  $$VocabularyTableTableTableManager get vocabularyTable =>
      $$VocabularyTableTableTableManager(_db, _db.vocabularyTable);
  $$GrammarTableTableTableManager get grammarTable =>
      $$GrammarTableTableTableManager(_db, _db.grammarTable);
  $$ZenGardenTableTableTableManager get zenGardenTable =>
      $$ZenGardenTableTableTableManager(_db, _db.zenGardenTable);
  $$LessonTableTableTableManager get lessonTable =>
      $$LessonTableTableTableManager(_db, _db.lessonTable);
  $$StudyLogTableTableTableManager get studyLogTable =>
      $$StudyLogTableTableTableManager(_db, _db.studyLogTable);
  $$ReviewLogTableTableTableManager get reviewLogTable =>
      $$ReviewLogTableTableTableManager(_db, _db.reviewLogTable);
}
