// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $JoueursTable extends Joueurs with TableInfo<$JoueursTable, Joueur> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $JoueursTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _nomMeta = const VerificationMeta('nom');
  @override
  late final GeneratedColumn<String> nom = GeneratedColumn<String>(
    'nom',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 50,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, nom];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'joueurs';
  @override
  VerificationContext validateIntegrity(
    Insertable<Joueur> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('nom')) {
      context.handle(
        _nomMeta,
        nom.isAcceptableOrUnknown(data['nom']!, _nomMeta),
      );
    } else if (isInserting) {
      context.missing(_nomMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Joueur map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Joueur(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      nom: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}nom'],
      )!,
    );
  }

  @override
  $JoueursTable createAlias(String alias) {
    return $JoueursTable(attachedDatabase, alias);
  }
}

class Joueur extends DataClass implements Insertable<Joueur> {
  final int id;
  final String nom;
  const Joueur({required this.id, required this.nom});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['nom'] = Variable<String>(nom);
    return map;
  }

  JoueursCompanion toCompanion(bool nullToAbsent) {
    return JoueursCompanion(id: Value(id), nom: Value(nom));
  }

  factory Joueur.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Joueur(
      id: serializer.fromJson<int>(json['id']),
      nom: serializer.fromJson<String>(json['nom']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'nom': serializer.toJson<String>(nom),
    };
  }

  Joueur copyWith({int? id, String? nom}) =>
      Joueur(id: id ?? this.id, nom: nom ?? this.nom);
  Joueur copyWithCompanion(JoueursCompanion data) {
    return Joueur(
      id: data.id.present ? data.id.value : this.id,
      nom: data.nom.present ? data.nom.value : this.nom,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Joueur(')
          ..write('id: $id, ')
          ..write('nom: $nom')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, nom);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Joueur && other.id == this.id && other.nom == this.nom);
}

class JoueursCompanion extends UpdateCompanion<Joueur> {
  final Value<int> id;
  final Value<String> nom;
  const JoueursCompanion({
    this.id = const Value.absent(),
    this.nom = const Value.absent(),
  });
  JoueursCompanion.insert({this.id = const Value.absent(), required String nom})
    : nom = Value(nom);
  static Insertable<Joueur> custom({
    Expression<int>? id,
    Expression<String>? nom,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (nom != null) 'nom': nom,
    });
  }

  JoueursCompanion copyWith({Value<int>? id, Value<String>? nom}) {
    return JoueursCompanion(id: id ?? this.id, nom: nom ?? this.nom);
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (nom.present) {
      map['nom'] = Variable<String>(nom.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('JoueursCompanion(')
          ..write('id: $id, ')
          ..write('nom: $nom')
          ..write(')'))
        .toString();
  }
}

class $PartiesTable extends Parties with TableInfo<$PartiesTable, Party> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PartiesTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _nombreJoueursMeta = const VerificationMeta(
    'nombreJoueurs',
  );
  @override
  late final GeneratedColumn<int> nombreJoueurs = GeneratedColumn<int>(
    'nombre_joueurs',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL CHECK (nombre_joueurs IN (3, 4, 5))',
  );
  static const VerificationMeta _dateCreationMeta = const VerificationMeta(
    'dateCreation',
  );
  @override
  late final GeneratedColumn<DateTime> dateCreation = GeneratedColumn<DateTime>(
    'date_creation',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [id, nombreJoueurs, dateCreation];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'parties';
  @override
  VerificationContext validateIntegrity(
    Insertable<Party> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('nombre_joueurs')) {
      context.handle(
        _nombreJoueursMeta,
        nombreJoueurs.isAcceptableOrUnknown(
          data['nombre_joueurs']!,
          _nombreJoueursMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_nombreJoueursMeta);
    }
    if (data.containsKey('date_creation')) {
      context.handle(
        _dateCreationMeta,
        dateCreation.isAcceptableOrUnknown(
          data['date_creation']!,
          _dateCreationMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Party map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Party(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      nombreJoueurs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}nombre_joueurs'],
      )!,
      dateCreation: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date_creation'],
      )!,
    );
  }

  @override
  $PartiesTable createAlias(String alias) {
    return $PartiesTable(attachedDatabase, alias);
  }
}

class Party extends DataClass implements Insertable<Party> {
  final int id;
  final int nombreJoueurs;
  final DateTime dateCreation;
  const Party({
    required this.id,
    required this.nombreJoueurs,
    required this.dateCreation,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['nombre_joueurs'] = Variable<int>(nombreJoueurs);
    map['date_creation'] = Variable<DateTime>(dateCreation);
    return map;
  }

  PartiesCompanion toCompanion(bool nullToAbsent) {
    return PartiesCompanion(
      id: Value(id),
      nombreJoueurs: Value(nombreJoueurs),
      dateCreation: Value(dateCreation),
    );
  }

  factory Party.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Party(
      id: serializer.fromJson<int>(json['id']),
      nombreJoueurs: serializer.fromJson<int>(json['nombreJoueurs']),
      dateCreation: serializer.fromJson<DateTime>(json['dateCreation']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'nombreJoueurs': serializer.toJson<int>(nombreJoueurs),
      'dateCreation': serializer.toJson<DateTime>(dateCreation),
    };
  }

  Party copyWith({int? id, int? nombreJoueurs, DateTime? dateCreation}) =>
      Party(
        id: id ?? this.id,
        nombreJoueurs: nombreJoueurs ?? this.nombreJoueurs,
        dateCreation: dateCreation ?? this.dateCreation,
      );
  Party copyWithCompanion(PartiesCompanion data) {
    return Party(
      id: data.id.present ? data.id.value : this.id,
      nombreJoueurs: data.nombreJoueurs.present
          ? data.nombreJoueurs.value
          : this.nombreJoueurs,
      dateCreation: data.dateCreation.present
          ? data.dateCreation.value
          : this.dateCreation,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Party(')
          ..write('id: $id, ')
          ..write('nombreJoueurs: $nombreJoueurs, ')
          ..write('dateCreation: $dateCreation')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, nombreJoueurs, dateCreation);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Party &&
          other.id == this.id &&
          other.nombreJoueurs == this.nombreJoueurs &&
          other.dateCreation == this.dateCreation);
}

class PartiesCompanion extends UpdateCompanion<Party> {
  final Value<int> id;
  final Value<int> nombreJoueurs;
  final Value<DateTime> dateCreation;
  const PartiesCompanion({
    this.id = const Value.absent(),
    this.nombreJoueurs = const Value.absent(),
    this.dateCreation = const Value.absent(),
  });
  PartiesCompanion.insert({
    this.id = const Value.absent(),
    required int nombreJoueurs,
    this.dateCreation = const Value.absent(),
  }) : nombreJoueurs = Value(nombreJoueurs);
  static Insertable<Party> custom({
    Expression<int>? id,
    Expression<int>? nombreJoueurs,
    Expression<DateTime>? dateCreation,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (nombreJoueurs != null) 'nombre_joueurs': nombreJoueurs,
      if (dateCreation != null) 'date_creation': dateCreation,
    });
  }

  PartiesCompanion copyWith({
    Value<int>? id,
    Value<int>? nombreJoueurs,
    Value<DateTime>? dateCreation,
  }) {
    return PartiesCompanion(
      id: id ?? this.id,
      nombreJoueurs: nombreJoueurs ?? this.nombreJoueurs,
      dateCreation: dateCreation ?? this.dateCreation,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (nombreJoueurs.present) {
      map['nombre_joueurs'] = Variable<int>(nombreJoueurs.value);
    }
    if (dateCreation.present) {
      map['date_creation'] = Variable<DateTime>(dateCreation.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PartiesCompanion(')
          ..write('id: $id, ')
          ..write('nombreJoueurs: $nombreJoueurs, ')
          ..write('dateCreation: $dateCreation')
          ..write(')'))
        .toString();
  }
}

class $PartieJoueursTable extends PartieJoueurs
    with TableInfo<$PartieJoueursTable, PartieJoueur> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PartieJoueursTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _partieIdMeta = const VerificationMeta(
    'partieId',
  );
  @override
  late final GeneratedColumn<int> partieId = GeneratedColumn<int>(
    'partie_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES parties (id)',
    ),
  );
  static const VerificationMeta _joueurIdMeta = const VerificationMeta(
    'joueurId',
  );
  @override
  late final GeneratedColumn<int> joueurId = GeneratedColumn<int>(
    'joueur_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES joueurs (id)',
    ),
  );
  static const VerificationMeta _ordreMeta = const VerificationMeta('ordre');
  @override
  late final GeneratedColumn<int> ordre = GeneratedColumn<int>(
    'ordre',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, partieId, joueurId, ordre];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'partie_joueurs';
  @override
  VerificationContext validateIntegrity(
    Insertable<PartieJoueur> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('partie_id')) {
      context.handle(
        _partieIdMeta,
        partieId.isAcceptableOrUnknown(data['partie_id']!, _partieIdMeta),
      );
    } else if (isInserting) {
      context.missing(_partieIdMeta);
    }
    if (data.containsKey('joueur_id')) {
      context.handle(
        _joueurIdMeta,
        joueurId.isAcceptableOrUnknown(data['joueur_id']!, _joueurIdMeta),
      );
    } else if (isInserting) {
      context.missing(_joueurIdMeta);
    }
    if (data.containsKey('ordre')) {
      context.handle(
        _ordreMeta,
        ordre.isAcceptableOrUnknown(data['ordre']!, _ordreMeta),
      );
    } else if (isInserting) {
      context.missing(_ordreMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PartieJoueur map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PartieJoueur(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      partieId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}partie_id'],
      )!,
      joueurId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}joueur_id'],
      )!,
      ordre: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}ordre'],
      )!,
    );
  }

  @override
  $PartieJoueursTable createAlias(String alias) {
    return $PartieJoueursTable(attachedDatabase, alias);
  }
}

class PartieJoueur extends DataClass implements Insertable<PartieJoueur> {
  final int id;
  final int partieId;
  final int joueurId;
  final int ordre;
  const PartieJoueur({
    required this.id,
    required this.partieId,
    required this.joueurId,
    required this.ordre,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['partie_id'] = Variable<int>(partieId);
    map['joueur_id'] = Variable<int>(joueurId);
    map['ordre'] = Variable<int>(ordre);
    return map;
  }

  PartieJoueursCompanion toCompanion(bool nullToAbsent) {
    return PartieJoueursCompanion(
      id: Value(id),
      partieId: Value(partieId),
      joueurId: Value(joueurId),
      ordre: Value(ordre),
    );
  }

  factory PartieJoueur.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PartieJoueur(
      id: serializer.fromJson<int>(json['id']),
      partieId: serializer.fromJson<int>(json['partieId']),
      joueurId: serializer.fromJson<int>(json['joueurId']),
      ordre: serializer.fromJson<int>(json['ordre']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'partieId': serializer.toJson<int>(partieId),
      'joueurId': serializer.toJson<int>(joueurId),
      'ordre': serializer.toJson<int>(ordre),
    };
  }

  PartieJoueur copyWith({int? id, int? partieId, int? joueurId, int? ordre}) =>
      PartieJoueur(
        id: id ?? this.id,
        partieId: partieId ?? this.partieId,
        joueurId: joueurId ?? this.joueurId,
        ordre: ordre ?? this.ordre,
      );
  PartieJoueur copyWithCompanion(PartieJoueursCompanion data) {
    return PartieJoueur(
      id: data.id.present ? data.id.value : this.id,
      partieId: data.partieId.present ? data.partieId.value : this.partieId,
      joueurId: data.joueurId.present ? data.joueurId.value : this.joueurId,
      ordre: data.ordre.present ? data.ordre.value : this.ordre,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PartieJoueur(')
          ..write('id: $id, ')
          ..write('partieId: $partieId, ')
          ..write('joueurId: $joueurId, ')
          ..write('ordre: $ordre')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, partieId, joueurId, ordre);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PartieJoueur &&
          other.id == this.id &&
          other.partieId == this.partieId &&
          other.joueurId == this.joueurId &&
          other.ordre == this.ordre);
}

class PartieJoueursCompanion extends UpdateCompanion<PartieJoueur> {
  final Value<int> id;
  final Value<int> partieId;
  final Value<int> joueurId;
  final Value<int> ordre;
  const PartieJoueursCompanion({
    this.id = const Value.absent(),
    this.partieId = const Value.absent(),
    this.joueurId = const Value.absent(),
    this.ordre = const Value.absent(),
  });
  PartieJoueursCompanion.insert({
    this.id = const Value.absent(),
    required int partieId,
    required int joueurId,
    required int ordre,
  }) : partieId = Value(partieId),
       joueurId = Value(joueurId),
       ordre = Value(ordre);
  static Insertable<PartieJoueur> custom({
    Expression<int>? id,
    Expression<int>? partieId,
    Expression<int>? joueurId,
    Expression<int>? ordre,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (partieId != null) 'partie_id': partieId,
      if (joueurId != null) 'joueur_id': joueurId,
      if (ordre != null) 'ordre': ordre,
    });
  }

  PartieJoueursCompanion copyWith({
    Value<int>? id,
    Value<int>? partieId,
    Value<int>? joueurId,
    Value<int>? ordre,
  }) {
    return PartieJoueursCompanion(
      id: id ?? this.id,
      partieId: partieId ?? this.partieId,
      joueurId: joueurId ?? this.joueurId,
      ordre: ordre ?? this.ordre,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (partieId.present) {
      map['partie_id'] = Variable<int>(partieId.value);
    }
    if (joueurId.present) {
      map['joueur_id'] = Variable<int>(joueurId.value);
    }
    if (ordre.present) {
      map['ordre'] = Variable<int>(ordre.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PartieJoueursCompanion(')
          ..write('id: $id, ')
          ..write('partieId: $partieId, ')
          ..write('joueurId: $joueurId, ')
          ..write('ordre: $ordre')
          ..write(')'))
        .toString();
  }
}

class $ManchesTable extends Manches with TableInfo<$ManchesTable, Manche> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ManchesTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _partieIdMeta = const VerificationMeta(
    'partieId',
  );
  @override
  late final GeneratedColumn<int> partieId = GeneratedColumn<int>(
    'partie_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES parties (id)',
    ),
  );
  static const VerificationMeta _numeroMeta = const VerificationMeta('numero');
  @override
  late final GeneratedColumn<int> numero = GeneratedColumn<int>(
    'numero',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _contratMeta = const VerificationMeta(
    'contrat',
  );
  @override
  late final GeneratedColumn<String> contrat = GeneratedColumn<String>(
    'contrat',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _preneurIdMeta = const VerificationMeta(
    'preneurId',
  );
  @override
  late final GeneratedColumn<int> preneurId = GeneratedColumn<int>(
    'preneur_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES joueurs (id)',
    ),
  );
  static const VerificationMeta _appeleIdMeta = const VerificationMeta(
    'appeleId',
  );
  @override
  late final GeneratedColumn<int> appeleId = GeneratedColumn<int>(
    'appele_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES joueurs (id)',
    ),
  );
  static const VerificationMeta _pointsPreneurMeta = const VerificationMeta(
    'pointsPreneur',
  );
  @override
  late final GeneratedColumn<int> pointsPreneur = GeneratedColumn<int>(
    'points_preneur',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL CHECK (points_preneur BETWEEN 0 AND 91)',
  );
  static const VerificationMeta _boutsMeta = const VerificationMeta('bouts');
  @override
  late final GeneratedColumn<int> bouts = GeneratedColumn<int>(
    'bouts',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL CHECK (bouts BETWEEN 0 AND 3)',
  );
  static const VerificationMeta _petitAuBoutMeta = const VerificationMeta(
    'petitAuBout',
  );
  @override
  late final GeneratedColumn<String> petitAuBout = GeneratedColumn<String>(
    'petit_au_bout',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _poigneeMeta = const VerificationMeta(
    'poignee',
  );
  @override
  late final GeneratedColumn<String> poignee = GeneratedColumn<String>(
    'poignee',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _chelemMeta = const VerificationMeta('chelem');
  @override
  late final GeneratedColumn<String> chelem = GeneratedColumn<String>(
    'chelem',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dateCreationMeta = const VerificationMeta(
    'dateCreation',
  );
  @override
  late final GeneratedColumn<DateTime> dateCreation = GeneratedColumn<DateTime>(
    'date_creation',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    partieId,
    numero,
    contrat,
    preneurId,
    appeleId,
    pointsPreneur,
    bouts,
    petitAuBout,
    poignee,
    chelem,
    dateCreation,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'manches';
  @override
  VerificationContext validateIntegrity(
    Insertable<Manche> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('partie_id')) {
      context.handle(
        _partieIdMeta,
        partieId.isAcceptableOrUnknown(data['partie_id']!, _partieIdMeta),
      );
    } else if (isInserting) {
      context.missing(_partieIdMeta);
    }
    if (data.containsKey('numero')) {
      context.handle(
        _numeroMeta,
        numero.isAcceptableOrUnknown(data['numero']!, _numeroMeta),
      );
    } else if (isInserting) {
      context.missing(_numeroMeta);
    }
    if (data.containsKey('contrat')) {
      context.handle(
        _contratMeta,
        contrat.isAcceptableOrUnknown(data['contrat']!, _contratMeta),
      );
    } else if (isInserting) {
      context.missing(_contratMeta);
    }
    if (data.containsKey('preneur_id')) {
      context.handle(
        _preneurIdMeta,
        preneurId.isAcceptableOrUnknown(data['preneur_id']!, _preneurIdMeta),
      );
    } else if (isInserting) {
      context.missing(_preneurIdMeta);
    }
    if (data.containsKey('appele_id')) {
      context.handle(
        _appeleIdMeta,
        appeleId.isAcceptableOrUnknown(data['appele_id']!, _appeleIdMeta),
      );
    }
    if (data.containsKey('points_preneur')) {
      context.handle(
        _pointsPreneurMeta,
        pointsPreneur.isAcceptableOrUnknown(
          data['points_preneur']!,
          _pointsPreneurMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_pointsPreneurMeta);
    }
    if (data.containsKey('bouts')) {
      context.handle(
        _boutsMeta,
        bouts.isAcceptableOrUnknown(data['bouts']!, _boutsMeta),
      );
    } else if (isInserting) {
      context.missing(_boutsMeta);
    }
    if (data.containsKey('petit_au_bout')) {
      context.handle(
        _petitAuBoutMeta,
        petitAuBout.isAcceptableOrUnknown(
          data['petit_au_bout']!,
          _petitAuBoutMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_petitAuBoutMeta);
    }
    if (data.containsKey('poignee')) {
      context.handle(
        _poigneeMeta,
        poignee.isAcceptableOrUnknown(data['poignee']!, _poigneeMeta),
      );
    } else if (isInserting) {
      context.missing(_poigneeMeta);
    }
    if (data.containsKey('chelem')) {
      context.handle(
        _chelemMeta,
        chelem.isAcceptableOrUnknown(data['chelem']!, _chelemMeta),
      );
    } else if (isInserting) {
      context.missing(_chelemMeta);
    }
    if (data.containsKey('date_creation')) {
      context.handle(
        _dateCreationMeta,
        dateCreation.isAcceptableOrUnknown(
          data['date_creation']!,
          _dateCreationMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Manche map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Manche(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      partieId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}partie_id'],
      )!,
      numero: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}numero'],
      )!,
      contrat: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}contrat'],
      )!,
      preneurId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}preneur_id'],
      )!,
      appeleId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}appele_id'],
      ),
      pointsPreneur: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}points_preneur'],
      )!,
      bouts: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}bouts'],
      )!,
      petitAuBout: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}petit_au_bout'],
      )!,
      poignee: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}poignee'],
      )!,
      chelem: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}chelem'],
      )!,
      dateCreation: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date_creation'],
      )!,
    );
  }

  @override
  $ManchesTable createAlias(String alias) {
    return $ManchesTable(attachedDatabase, alias);
  }
}

class Manche extends DataClass implements Insertable<Manche> {
  final int id;
  final int partieId;
  final int numero;
  final String contrat;
  final int preneurId;
  final int? appeleId;
  final int pointsPreneur;
  final int bouts;
  final String petitAuBout;
  final String poignee;
  final String chelem;
  final DateTime dateCreation;
  const Manche({
    required this.id,
    required this.partieId,
    required this.numero,
    required this.contrat,
    required this.preneurId,
    this.appeleId,
    required this.pointsPreneur,
    required this.bouts,
    required this.petitAuBout,
    required this.poignee,
    required this.chelem,
    required this.dateCreation,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['partie_id'] = Variable<int>(partieId);
    map['numero'] = Variable<int>(numero);
    map['contrat'] = Variable<String>(contrat);
    map['preneur_id'] = Variable<int>(preneurId);
    if (!nullToAbsent || appeleId != null) {
      map['appele_id'] = Variable<int>(appeleId);
    }
    map['points_preneur'] = Variable<int>(pointsPreneur);
    map['bouts'] = Variable<int>(bouts);
    map['petit_au_bout'] = Variable<String>(petitAuBout);
    map['poignee'] = Variable<String>(poignee);
    map['chelem'] = Variable<String>(chelem);
    map['date_creation'] = Variable<DateTime>(dateCreation);
    return map;
  }

  ManchesCompanion toCompanion(bool nullToAbsent) {
    return ManchesCompanion(
      id: Value(id),
      partieId: Value(partieId),
      numero: Value(numero),
      contrat: Value(contrat),
      preneurId: Value(preneurId),
      appeleId: appeleId == null && nullToAbsent
          ? const Value.absent()
          : Value(appeleId),
      pointsPreneur: Value(pointsPreneur),
      bouts: Value(bouts),
      petitAuBout: Value(petitAuBout),
      poignee: Value(poignee),
      chelem: Value(chelem),
      dateCreation: Value(dateCreation),
    );
  }

  factory Manche.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Manche(
      id: serializer.fromJson<int>(json['id']),
      partieId: serializer.fromJson<int>(json['partieId']),
      numero: serializer.fromJson<int>(json['numero']),
      contrat: serializer.fromJson<String>(json['contrat']),
      preneurId: serializer.fromJson<int>(json['preneurId']),
      appeleId: serializer.fromJson<int?>(json['appeleId']),
      pointsPreneur: serializer.fromJson<int>(json['pointsPreneur']),
      bouts: serializer.fromJson<int>(json['bouts']),
      petitAuBout: serializer.fromJson<String>(json['petitAuBout']),
      poignee: serializer.fromJson<String>(json['poignee']),
      chelem: serializer.fromJson<String>(json['chelem']),
      dateCreation: serializer.fromJson<DateTime>(json['dateCreation']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'partieId': serializer.toJson<int>(partieId),
      'numero': serializer.toJson<int>(numero),
      'contrat': serializer.toJson<String>(contrat),
      'preneurId': serializer.toJson<int>(preneurId),
      'appeleId': serializer.toJson<int?>(appeleId),
      'pointsPreneur': serializer.toJson<int>(pointsPreneur),
      'bouts': serializer.toJson<int>(bouts),
      'petitAuBout': serializer.toJson<String>(petitAuBout),
      'poignee': serializer.toJson<String>(poignee),
      'chelem': serializer.toJson<String>(chelem),
      'dateCreation': serializer.toJson<DateTime>(dateCreation),
    };
  }

  Manche copyWith({
    int? id,
    int? partieId,
    int? numero,
    String? contrat,
    int? preneurId,
    Value<int?> appeleId = const Value.absent(),
    int? pointsPreneur,
    int? bouts,
    String? petitAuBout,
    String? poignee,
    String? chelem,
    DateTime? dateCreation,
  }) => Manche(
    id: id ?? this.id,
    partieId: partieId ?? this.partieId,
    numero: numero ?? this.numero,
    contrat: contrat ?? this.contrat,
    preneurId: preneurId ?? this.preneurId,
    appeleId: appeleId.present ? appeleId.value : this.appeleId,
    pointsPreneur: pointsPreneur ?? this.pointsPreneur,
    bouts: bouts ?? this.bouts,
    petitAuBout: petitAuBout ?? this.petitAuBout,
    poignee: poignee ?? this.poignee,
    chelem: chelem ?? this.chelem,
    dateCreation: dateCreation ?? this.dateCreation,
  );
  Manche copyWithCompanion(ManchesCompanion data) {
    return Manche(
      id: data.id.present ? data.id.value : this.id,
      partieId: data.partieId.present ? data.partieId.value : this.partieId,
      numero: data.numero.present ? data.numero.value : this.numero,
      contrat: data.contrat.present ? data.contrat.value : this.contrat,
      preneurId: data.preneurId.present ? data.preneurId.value : this.preneurId,
      appeleId: data.appeleId.present ? data.appeleId.value : this.appeleId,
      pointsPreneur: data.pointsPreneur.present
          ? data.pointsPreneur.value
          : this.pointsPreneur,
      bouts: data.bouts.present ? data.bouts.value : this.bouts,
      petitAuBout: data.petitAuBout.present
          ? data.petitAuBout.value
          : this.petitAuBout,
      poignee: data.poignee.present ? data.poignee.value : this.poignee,
      chelem: data.chelem.present ? data.chelem.value : this.chelem,
      dateCreation: data.dateCreation.present
          ? data.dateCreation.value
          : this.dateCreation,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Manche(')
          ..write('id: $id, ')
          ..write('partieId: $partieId, ')
          ..write('numero: $numero, ')
          ..write('contrat: $contrat, ')
          ..write('preneurId: $preneurId, ')
          ..write('appeleId: $appeleId, ')
          ..write('pointsPreneur: $pointsPreneur, ')
          ..write('bouts: $bouts, ')
          ..write('petitAuBout: $petitAuBout, ')
          ..write('poignee: $poignee, ')
          ..write('chelem: $chelem, ')
          ..write('dateCreation: $dateCreation')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    partieId,
    numero,
    contrat,
    preneurId,
    appeleId,
    pointsPreneur,
    bouts,
    petitAuBout,
    poignee,
    chelem,
    dateCreation,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Manche &&
          other.id == this.id &&
          other.partieId == this.partieId &&
          other.numero == this.numero &&
          other.contrat == this.contrat &&
          other.preneurId == this.preneurId &&
          other.appeleId == this.appeleId &&
          other.pointsPreneur == this.pointsPreneur &&
          other.bouts == this.bouts &&
          other.petitAuBout == this.petitAuBout &&
          other.poignee == this.poignee &&
          other.chelem == this.chelem &&
          other.dateCreation == this.dateCreation);
}

class ManchesCompanion extends UpdateCompanion<Manche> {
  final Value<int> id;
  final Value<int> partieId;
  final Value<int> numero;
  final Value<String> contrat;
  final Value<int> preneurId;
  final Value<int?> appeleId;
  final Value<int> pointsPreneur;
  final Value<int> bouts;
  final Value<String> petitAuBout;
  final Value<String> poignee;
  final Value<String> chelem;
  final Value<DateTime> dateCreation;
  const ManchesCompanion({
    this.id = const Value.absent(),
    this.partieId = const Value.absent(),
    this.numero = const Value.absent(),
    this.contrat = const Value.absent(),
    this.preneurId = const Value.absent(),
    this.appeleId = const Value.absent(),
    this.pointsPreneur = const Value.absent(),
    this.bouts = const Value.absent(),
    this.petitAuBout = const Value.absent(),
    this.poignee = const Value.absent(),
    this.chelem = const Value.absent(),
    this.dateCreation = const Value.absent(),
  });
  ManchesCompanion.insert({
    this.id = const Value.absent(),
    required int partieId,
    required int numero,
    required String contrat,
    required int preneurId,
    this.appeleId = const Value.absent(),
    required int pointsPreneur,
    required int bouts,
    required String petitAuBout,
    required String poignee,
    required String chelem,
    this.dateCreation = const Value.absent(),
  }) : partieId = Value(partieId),
       numero = Value(numero),
       contrat = Value(contrat),
       preneurId = Value(preneurId),
       pointsPreneur = Value(pointsPreneur),
       bouts = Value(bouts),
       petitAuBout = Value(petitAuBout),
       poignee = Value(poignee),
       chelem = Value(chelem);
  static Insertable<Manche> custom({
    Expression<int>? id,
    Expression<int>? partieId,
    Expression<int>? numero,
    Expression<String>? contrat,
    Expression<int>? preneurId,
    Expression<int>? appeleId,
    Expression<int>? pointsPreneur,
    Expression<int>? bouts,
    Expression<String>? petitAuBout,
    Expression<String>? poignee,
    Expression<String>? chelem,
    Expression<DateTime>? dateCreation,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (partieId != null) 'partie_id': partieId,
      if (numero != null) 'numero': numero,
      if (contrat != null) 'contrat': contrat,
      if (preneurId != null) 'preneur_id': preneurId,
      if (appeleId != null) 'appele_id': appeleId,
      if (pointsPreneur != null) 'points_preneur': pointsPreneur,
      if (bouts != null) 'bouts': bouts,
      if (petitAuBout != null) 'petit_au_bout': petitAuBout,
      if (poignee != null) 'poignee': poignee,
      if (chelem != null) 'chelem': chelem,
      if (dateCreation != null) 'date_creation': dateCreation,
    });
  }

  ManchesCompanion copyWith({
    Value<int>? id,
    Value<int>? partieId,
    Value<int>? numero,
    Value<String>? contrat,
    Value<int>? preneurId,
    Value<int?>? appeleId,
    Value<int>? pointsPreneur,
    Value<int>? bouts,
    Value<String>? petitAuBout,
    Value<String>? poignee,
    Value<String>? chelem,
    Value<DateTime>? dateCreation,
  }) {
    return ManchesCompanion(
      id: id ?? this.id,
      partieId: partieId ?? this.partieId,
      numero: numero ?? this.numero,
      contrat: contrat ?? this.contrat,
      preneurId: preneurId ?? this.preneurId,
      appeleId: appeleId ?? this.appeleId,
      pointsPreneur: pointsPreneur ?? this.pointsPreneur,
      bouts: bouts ?? this.bouts,
      petitAuBout: petitAuBout ?? this.petitAuBout,
      poignee: poignee ?? this.poignee,
      chelem: chelem ?? this.chelem,
      dateCreation: dateCreation ?? this.dateCreation,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (partieId.present) {
      map['partie_id'] = Variable<int>(partieId.value);
    }
    if (numero.present) {
      map['numero'] = Variable<int>(numero.value);
    }
    if (contrat.present) {
      map['contrat'] = Variable<String>(contrat.value);
    }
    if (preneurId.present) {
      map['preneur_id'] = Variable<int>(preneurId.value);
    }
    if (appeleId.present) {
      map['appele_id'] = Variable<int>(appeleId.value);
    }
    if (pointsPreneur.present) {
      map['points_preneur'] = Variable<int>(pointsPreneur.value);
    }
    if (bouts.present) {
      map['bouts'] = Variable<int>(bouts.value);
    }
    if (petitAuBout.present) {
      map['petit_au_bout'] = Variable<String>(petitAuBout.value);
    }
    if (poignee.present) {
      map['poignee'] = Variable<String>(poignee.value);
    }
    if (chelem.present) {
      map['chelem'] = Variable<String>(chelem.value);
    }
    if (dateCreation.present) {
      map['date_creation'] = Variable<DateTime>(dateCreation.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ManchesCompanion(')
          ..write('id: $id, ')
          ..write('partieId: $partieId, ')
          ..write('numero: $numero, ')
          ..write('contrat: $contrat, ')
          ..write('preneurId: $preneurId, ')
          ..write('appeleId: $appeleId, ')
          ..write('pointsPreneur: $pointsPreneur, ')
          ..write('bouts: $bouts, ')
          ..write('petitAuBout: $petitAuBout, ')
          ..write('poignee: $poignee, ')
          ..write('chelem: $chelem, ')
          ..write('dateCreation: $dateCreation')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $JoueursTable joueurs = $JoueursTable(this);
  late final $PartiesTable parties = $PartiesTable(this);
  late final $PartieJoueursTable partieJoueurs = $PartieJoueursTable(this);
  late final $ManchesTable manches = $ManchesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    joueurs,
    parties,
    partieJoueurs,
    manches,
  ];
}

typedef $$JoueursTableCreateCompanionBuilder =
    JoueursCompanion Function({Value<int> id, required String nom});
typedef $$JoueursTableUpdateCompanionBuilder =
    JoueursCompanion Function({Value<int> id, Value<String> nom});

final class $$JoueursTableReferences
    extends BaseReferences<_$AppDatabase, $JoueursTable, Joueur> {
  $$JoueursTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$PartieJoueursTable, List<PartieJoueur>>
  _partieJoueursRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.partieJoueurs,
    aliasName: $_aliasNameGenerator(db.joueurs.id, db.partieJoueurs.joueurId),
  );

  $$PartieJoueursTableProcessedTableManager get partieJoueursRefs {
    final manager = $$PartieJoueursTableTableManager(
      $_db,
      $_db.partieJoueurs,
    ).filter((f) => f.joueurId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_partieJoueursRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$JoueursTableFilterComposer
    extends Composer<_$AppDatabase, $JoueursTable> {
  $$JoueursTableFilterComposer({
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

  ColumnFilters<String> get nom => $composableBuilder(
    column: $table.nom,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> partieJoueursRefs(
    Expression<bool> Function($$PartieJoueursTableFilterComposer f) f,
  ) {
    final $$PartieJoueursTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.partieJoueurs,
      getReferencedColumn: (t) => t.joueurId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PartieJoueursTableFilterComposer(
            $db: $db,
            $table: $db.partieJoueurs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$JoueursTableOrderingComposer
    extends Composer<_$AppDatabase, $JoueursTable> {
  $$JoueursTableOrderingComposer({
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

  ColumnOrderings<String> get nom => $composableBuilder(
    column: $table.nom,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$JoueursTableAnnotationComposer
    extends Composer<_$AppDatabase, $JoueursTable> {
  $$JoueursTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get nom =>
      $composableBuilder(column: $table.nom, builder: (column) => column);

  Expression<T> partieJoueursRefs<T extends Object>(
    Expression<T> Function($$PartieJoueursTableAnnotationComposer a) f,
  ) {
    final $$PartieJoueursTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.partieJoueurs,
      getReferencedColumn: (t) => t.joueurId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PartieJoueursTableAnnotationComposer(
            $db: $db,
            $table: $db.partieJoueurs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$JoueursTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $JoueursTable,
          Joueur,
          $$JoueursTableFilterComposer,
          $$JoueursTableOrderingComposer,
          $$JoueursTableAnnotationComposer,
          $$JoueursTableCreateCompanionBuilder,
          $$JoueursTableUpdateCompanionBuilder,
          (Joueur, $$JoueursTableReferences),
          Joueur,
          PrefetchHooks Function({bool partieJoueursRefs})
        > {
  $$JoueursTableTableManager(_$AppDatabase db, $JoueursTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$JoueursTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$JoueursTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$JoueursTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> nom = const Value.absent(),
              }) => JoueursCompanion(id: id, nom: nom),
          createCompanionCallback:
              ({Value<int> id = const Value.absent(), required String nom}) =>
                  JoueursCompanion.insert(id: id, nom: nom),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$JoueursTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({partieJoueursRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (partieJoueursRefs) db.partieJoueurs,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (partieJoueursRefs)
                    await $_getPrefetchedData<
                      Joueur,
                      $JoueursTable,
                      PartieJoueur
                    >(
                      currentTable: table,
                      referencedTable: $$JoueursTableReferences
                          ._partieJoueursRefsTable(db),
                      managerFromTypedResult: (p0) => $$JoueursTableReferences(
                        db,
                        table,
                        p0,
                      ).partieJoueursRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.joueurId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$JoueursTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $JoueursTable,
      Joueur,
      $$JoueursTableFilterComposer,
      $$JoueursTableOrderingComposer,
      $$JoueursTableAnnotationComposer,
      $$JoueursTableCreateCompanionBuilder,
      $$JoueursTableUpdateCompanionBuilder,
      (Joueur, $$JoueursTableReferences),
      Joueur,
      PrefetchHooks Function({bool partieJoueursRefs})
    >;
typedef $$PartiesTableCreateCompanionBuilder =
    PartiesCompanion Function({
      Value<int> id,
      required int nombreJoueurs,
      Value<DateTime> dateCreation,
    });
typedef $$PartiesTableUpdateCompanionBuilder =
    PartiesCompanion Function({
      Value<int> id,
      Value<int> nombreJoueurs,
      Value<DateTime> dateCreation,
    });

final class $$PartiesTableReferences
    extends BaseReferences<_$AppDatabase, $PartiesTable, Party> {
  $$PartiesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$PartieJoueursTable, List<PartieJoueur>>
  _partieJoueursRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.partieJoueurs,
    aliasName: $_aliasNameGenerator(db.parties.id, db.partieJoueurs.partieId),
  );

  $$PartieJoueursTableProcessedTableManager get partieJoueursRefs {
    final manager = $$PartieJoueursTableTableManager(
      $_db,
      $_db.partieJoueurs,
    ).filter((f) => f.partieId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_partieJoueursRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$ManchesTable, List<Manche>> _manchesRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.manches,
    aliasName: $_aliasNameGenerator(db.parties.id, db.manches.partieId),
  );

  $$ManchesTableProcessedTableManager get manchesRefs {
    final manager = $$ManchesTableTableManager(
      $_db,
      $_db.manches,
    ).filter((f) => f.partieId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_manchesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$PartiesTableFilterComposer
    extends Composer<_$AppDatabase, $PartiesTable> {
  $$PartiesTableFilterComposer({
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

  ColumnFilters<int> get nombreJoueurs => $composableBuilder(
    column: $table.nombreJoueurs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get dateCreation => $composableBuilder(
    column: $table.dateCreation,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> partieJoueursRefs(
    Expression<bool> Function($$PartieJoueursTableFilterComposer f) f,
  ) {
    final $$PartieJoueursTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.partieJoueurs,
      getReferencedColumn: (t) => t.partieId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PartieJoueursTableFilterComposer(
            $db: $db,
            $table: $db.partieJoueurs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> manchesRefs(
    Expression<bool> Function($$ManchesTableFilterComposer f) f,
  ) {
    final $$ManchesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.manches,
      getReferencedColumn: (t) => t.partieId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ManchesTableFilterComposer(
            $db: $db,
            $table: $db.manches,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$PartiesTableOrderingComposer
    extends Composer<_$AppDatabase, $PartiesTable> {
  $$PartiesTableOrderingComposer({
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

  ColumnOrderings<int> get nombreJoueurs => $composableBuilder(
    column: $table.nombreJoueurs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get dateCreation => $composableBuilder(
    column: $table.dateCreation,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PartiesTableAnnotationComposer
    extends Composer<_$AppDatabase, $PartiesTable> {
  $$PartiesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get nombreJoueurs => $composableBuilder(
    column: $table.nombreJoueurs,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get dateCreation => $composableBuilder(
    column: $table.dateCreation,
    builder: (column) => column,
  );

  Expression<T> partieJoueursRefs<T extends Object>(
    Expression<T> Function($$PartieJoueursTableAnnotationComposer a) f,
  ) {
    final $$PartieJoueursTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.partieJoueurs,
      getReferencedColumn: (t) => t.partieId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PartieJoueursTableAnnotationComposer(
            $db: $db,
            $table: $db.partieJoueurs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> manchesRefs<T extends Object>(
    Expression<T> Function($$ManchesTableAnnotationComposer a) f,
  ) {
    final $$ManchesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.manches,
      getReferencedColumn: (t) => t.partieId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ManchesTableAnnotationComposer(
            $db: $db,
            $table: $db.manches,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$PartiesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PartiesTable,
          Party,
          $$PartiesTableFilterComposer,
          $$PartiesTableOrderingComposer,
          $$PartiesTableAnnotationComposer,
          $$PartiesTableCreateCompanionBuilder,
          $$PartiesTableUpdateCompanionBuilder,
          (Party, $$PartiesTableReferences),
          Party,
          PrefetchHooks Function({bool partieJoueursRefs, bool manchesRefs})
        > {
  $$PartiesTableTableManager(_$AppDatabase db, $PartiesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PartiesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PartiesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PartiesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> nombreJoueurs = const Value.absent(),
                Value<DateTime> dateCreation = const Value.absent(),
              }) => PartiesCompanion(
                id: id,
                nombreJoueurs: nombreJoueurs,
                dateCreation: dateCreation,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int nombreJoueurs,
                Value<DateTime> dateCreation = const Value.absent(),
              }) => PartiesCompanion.insert(
                id: id,
                nombreJoueurs: nombreJoueurs,
                dateCreation: dateCreation,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$PartiesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({partieJoueursRefs = false, manchesRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (partieJoueursRefs) db.partieJoueurs,
                    if (manchesRefs) db.manches,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (partieJoueursRefs)
                        await $_getPrefetchedData<
                          Party,
                          $PartiesTable,
                          PartieJoueur
                        >(
                          currentTable: table,
                          referencedTable: $$PartiesTableReferences
                              ._partieJoueursRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$PartiesTableReferences(
                                db,
                                table,
                                p0,
                              ).partieJoueursRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.partieId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (manchesRefs)
                        await $_getPrefetchedData<Party, $PartiesTable, Manche>(
                          currentTable: table,
                          referencedTable: $$PartiesTableReferences
                              ._manchesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$PartiesTableReferences(
                                db,
                                table,
                                p0,
                              ).manchesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.partieId == item.id,
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

typedef $$PartiesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PartiesTable,
      Party,
      $$PartiesTableFilterComposer,
      $$PartiesTableOrderingComposer,
      $$PartiesTableAnnotationComposer,
      $$PartiesTableCreateCompanionBuilder,
      $$PartiesTableUpdateCompanionBuilder,
      (Party, $$PartiesTableReferences),
      Party,
      PrefetchHooks Function({bool partieJoueursRefs, bool manchesRefs})
    >;
typedef $$PartieJoueursTableCreateCompanionBuilder =
    PartieJoueursCompanion Function({
      Value<int> id,
      required int partieId,
      required int joueurId,
      required int ordre,
    });
typedef $$PartieJoueursTableUpdateCompanionBuilder =
    PartieJoueursCompanion Function({
      Value<int> id,
      Value<int> partieId,
      Value<int> joueurId,
      Value<int> ordre,
    });

final class $$PartieJoueursTableReferences
    extends BaseReferences<_$AppDatabase, $PartieJoueursTable, PartieJoueur> {
  $$PartieJoueursTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $PartiesTable _partieIdTable(_$AppDatabase db) =>
      db.parties.createAlias(
        $_aliasNameGenerator(db.partieJoueurs.partieId, db.parties.id),
      );

  $$PartiesTableProcessedTableManager get partieId {
    final $_column = $_itemColumn<int>('partie_id')!;

    final manager = $$PartiesTableTableManager(
      $_db,
      $_db.parties,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_partieIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $JoueursTable _joueurIdTable(_$AppDatabase db) =>
      db.joueurs.createAlias(
        $_aliasNameGenerator(db.partieJoueurs.joueurId, db.joueurs.id),
      );

  $$JoueursTableProcessedTableManager get joueurId {
    final $_column = $_itemColumn<int>('joueur_id')!;

    final manager = $$JoueursTableTableManager(
      $_db,
      $_db.joueurs,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_joueurIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$PartieJoueursTableFilterComposer
    extends Composer<_$AppDatabase, $PartieJoueursTable> {
  $$PartieJoueursTableFilterComposer({
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

  ColumnFilters<int> get ordre => $composableBuilder(
    column: $table.ordre,
    builder: (column) => ColumnFilters(column),
  );

  $$PartiesTableFilterComposer get partieId {
    final $$PartiesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.partieId,
      referencedTable: $db.parties,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PartiesTableFilterComposer(
            $db: $db,
            $table: $db.parties,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$JoueursTableFilterComposer get joueurId {
    final $$JoueursTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.joueurId,
      referencedTable: $db.joueurs,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$JoueursTableFilterComposer(
            $db: $db,
            $table: $db.joueurs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PartieJoueursTableOrderingComposer
    extends Composer<_$AppDatabase, $PartieJoueursTable> {
  $$PartieJoueursTableOrderingComposer({
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

  ColumnOrderings<int> get ordre => $composableBuilder(
    column: $table.ordre,
    builder: (column) => ColumnOrderings(column),
  );

  $$PartiesTableOrderingComposer get partieId {
    final $$PartiesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.partieId,
      referencedTable: $db.parties,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PartiesTableOrderingComposer(
            $db: $db,
            $table: $db.parties,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$JoueursTableOrderingComposer get joueurId {
    final $$JoueursTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.joueurId,
      referencedTable: $db.joueurs,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$JoueursTableOrderingComposer(
            $db: $db,
            $table: $db.joueurs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PartieJoueursTableAnnotationComposer
    extends Composer<_$AppDatabase, $PartieJoueursTable> {
  $$PartieJoueursTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get ordre =>
      $composableBuilder(column: $table.ordre, builder: (column) => column);

  $$PartiesTableAnnotationComposer get partieId {
    final $$PartiesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.partieId,
      referencedTable: $db.parties,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PartiesTableAnnotationComposer(
            $db: $db,
            $table: $db.parties,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$JoueursTableAnnotationComposer get joueurId {
    final $$JoueursTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.joueurId,
      referencedTable: $db.joueurs,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$JoueursTableAnnotationComposer(
            $db: $db,
            $table: $db.joueurs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PartieJoueursTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PartieJoueursTable,
          PartieJoueur,
          $$PartieJoueursTableFilterComposer,
          $$PartieJoueursTableOrderingComposer,
          $$PartieJoueursTableAnnotationComposer,
          $$PartieJoueursTableCreateCompanionBuilder,
          $$PartieJoueursTableUpdateCompanionBuilder,
          (PartieJoueur, $$PartieJoueursTableReferences),
          PartieJoueur,
          PrefetchHooks Function({bool partieId, bool joueurId})
        > {
  $$PartieJoueursTableTableManager(_$AppDatabase db, $PartieJoueursTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PartieJoueursTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PartieJoueursTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PartieJoueursTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> partieId = const Value.absent(),
                Value<int> joueurId = const Value.absent(),
                Value<int> ordre = const Value.absent(),
              }) => PartieJoueursCompanion(
                id: id,
                partieId: partieId,
                joueurId: joueurId,
                ordre: ordre,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int partieId,
                required int joueurId,
                required int ordre,
              }) => PartieJoueursCompanion.insert(
                id: id,
                partieId: partieId,
                joueurId: joueurId,
                ordre: ordre,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$PartieJoueursTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({partieId = false, joueurId = false}) {
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
                    if (partieId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.partieId,
                                referencedTable: $$PartieJoueursTableReferences
                                    ._partieIdTable(db),
                                referencedColumn: $$PartieJoueursTableReferences
                                    ._partieIdTable(db)
                                    .id,
                              )
                              as T;
                    }
                    if (joueurId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.joueurId,
                                referencedTable: $$PartieJoueursTableReferences
                                    ._joueurIdTable(db),
                                referencedColumn: $$PartieJoueursTableReferences
                                    ._joueurIdTable(db)
                                    .id,
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

typedef $$PartieJoueursTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PartieJoueursTable,
      PartieJoueur,
      $$PartieJoueursTableFilterComposer,
      $$PartieJoueursTableOrderingComposer,
      $$PartieJoueursTableAnnotationComposer,
      $$PartieJoueursTableCreateCompanionBuilder,
      $$PartieJoueursTableUpdateCompanionBuilder,
      (PartieJoueur, $$PartieJoueursTableReferences),
      PartieJoueur,
      PrefetchHooks Function({bool partieId, bool joueurId})
    >;
typedef $$ManchesTableCreateCompanionBuilder =
    ManchesCompanion Function({
      Value<int> id,
      required int partieId,
      required int numero,
      required String contrat,
      required int preneurId,
      Value<int?> appeleId,
      required int pointsPreneur,
      required int bouts,
      required String petitAuBout,
      required String poignee,
      required String chelem,
      Value<DateTime> dateCreation,
    });
typedef $$ManchesTableUpdateCompanionBuilder =
    ManchesCompanion Function({
      Value<int> id,
      Value<int> partieId,
      Value<int> numero,
      Value<String> contrat,
      Value<int> preneurId,
      Value<int?> appeleId,
      Value<int> pointsPreneur,
      Value<int> bouts,
      Value<String> petitAuBout,
      Value<String> poignee,
      Value<String> chelem,
      Value<DateTime> dateCreation,
    });

final class $$ManchesTableReferences
    extends BaseReferences<_$AppDatabase, $ManchesTable, Manche> {
  $$ManchesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $PartiesTable _partieIdTable(_$AppDatabase db) => db.parties
      .createAlias($_aliasNameGenerator(db.manches.partieId, db.parties.id));

  $$PartiesTableProcessedTableManager get partieId {
    final $_column = $_itemColumn<int>('partie_id')!;

    final manager = $$PartiesTableTableManager(
      $_db,
      $_db.parties,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_partieIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $JoueursTable _preneurIdTable(_$AppDatabase db) => db.joueurs
      .createAlias($_aliasNameGenerator(db.manches.preneurId, db.joueurs.id));

  $$JoueursTableProcessedTableManager get preneurId {
    final $_column = $_itemColumn<int>('preneur_id')!;

    final manager = $$JoueursTableTableManager(
      $_db,
      $_db.joueurs,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_preneurIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $JoueursTable _appeleIdTable(_$AppDatabase db) => db.joueurs
      .createAlias($_aliasNameGenerator(db.manches.appeleId, db.joueurs.id));

  $$JoueursTableProcessedTableManager? get appeleId {
    final $_column = $_itemColumn<int>('appele_id');
    if ($_column == null) return null;
    final manager = $$JoueursTableTableManager(
      $_db,
      $_db.joueurs,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_appeleIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ManchesTableFilterComposer
    extends Composer<_$AppDatabase, $ManchesTable> {
  $$ManchesTableFilterComposer({
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

  ColumnFilters<int> get numero => $composableBuilder(
    column: $table.numero,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get contrat => $composableBuilder(
    column: $table.contrat,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get pointsPreneur => $composableBuilder(
    column: $table.pointsPreneur,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get bouts => $composableBuilder(
    column: $table.bouts,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get petitAuBout => $composableBuilder(
    column: $table.petitAuBout,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get poignee => $composableBuilder(
    column: $table.poignee,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get chelem => $composableBuilder(
    column: $table.chelem,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get dateCreation => $composableBuilder(
    column: $table.dateCreation,
    builder: (column) => ColumnFilters(column),
  );

  $$PartiesTableFilterComposer get partieId {
    final $$PartiesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.partieId,
      referencedTable: $db.parties,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PartiesTableFilterComposer(
            $db: $db,
            $table: $db.parties,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$JoueursTableFilterComposer get preneurId {
    final $$JoueursTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.preneurId,
      referencedTable: $db.joueurs,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$JoueursTableFilterComposer(
            $db: $db,
            $table: $db.joueurs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$JoueursTableFilterComposer get appeleId {
    final $$JoueursTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.appeleId,
      referencedTable: $db.joueurs,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$JoueursTableFilterComposer(
            $db: $db,
            $table: $db.joueurs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ManchesTableOrderingComposer
    extends Composer<_$AppDatabase, $ManchesTable> {
  $$ManchesTableOrderingComposer({
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

  ColumnOrderings<int> get numero => $composableBuilder(
    column: $table.numero,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get contrat => $composableBuilder(
    column: $table.contrat,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get pointsPreneur => $composableBuilder(
    column: $table.pointsPreneur,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get bouts => $composableBuilder(
    column: $table.bouts,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get petitAuBout => $composableBuilder(
    column: $table.petitAuBout,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get poignee => $composableBuilder(
    column: $table.poignee,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get chelem => $composableBuilder(
    column: $table.chelem,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get dateCreation => $composableBuilder(
    column: $table.dateCreation,
    builder: (column) => ColumnOrderings(column),
  );

  $$PartiesTableOrderingComposer get partieId {
    final $$PartiesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.partieId,
      referencedTable: $db.parties,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PartiesTableOrderingComposer(
            $db: $db,
            $table: $db.parties,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$JoueursTableOrderingComposer get preneurId {
    final $$JoueursTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.preneurId,
      referencedTable: $db.joueurs,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$JoueursTableOrderingComposer(
            $db: $db,
            $table: $db.joueurs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$JoueursTableOrderingComposer get appeleId {
    final $$JoueursTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.appeleId,
      referencedTable: $db.joueurs,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$JoueursTableOrderingComposer(
            $db: $db,
            $table: $db.joueurs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ManchesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ManchesTable> {
  $$ManchesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get numero =>
      $composableBuilder(column: $table.numero, builder: (column) => column);

  GeneratedColumn<String> get contrat =>
      $composableBuilder(column: $table.contrat, builder: (column) => column);

  GeneratedColumn<int> get pointsPreneur => $composableBuilder(
    column: $table.pointsPreneur,
    builder: (column) => column,
  );

  GeneratedColumn<int> get bouts =>
      $composableBuilder(column: $table.bouts, builder: (column) => column);

  GeneratedColumn<String> get petitAuBout => $composableBuilder(
    column: $table.petitAuBout,
    builder: (column) => column,
  );

  GeneratedColumn<String> get poignee =>
      $composableBuilder(column: $table.poignee, builder: (column) => column);

  GeneratedColumn<String> get chelem =>
      $composableBuilder(column: $table.chelem, builder: (column) => column);

  GeneratedColumn<DateTime> get dateCreation => $composableBuilder(
    column: $table.dateCreation,
    builder: (column) => column,
  );

  $$PartiesTableAnnotationComposer get partieId {
    final $$PartiesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.partieId,
      referencedTable: $db.parties,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PartiesTableAnnotationComposer(
            $db: $db,
            $table: $db.parties,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$JoueursTableAnnotationComposer get preneurId {
    final $$JoueursTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.preneurId,
      referencedTable: $db.joueurs,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$JoueursTableAnnotationComposer(
            $db: $db,
            $table: $db.joueurs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$JoueursTableAnnotationComposer get appeleId {
    final $$JoueursTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.appeleId,
      referencedTable: $db.joueurs,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$JoueursTableAnnotationComposer(
            $db: $db,
            $table: $db.joueurs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ManchesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ManchesTable,
          Manche,
          $$ManchesTableFilterComposer,
          $$ManchesTableOrderingComposer,
          $$ManchesTableAnnotationComposer,
          $$ManchesTableCreateCompanionBuilder,
          $$ManchesTableUpdateCompanionBuilder,
          (Manche, $$ManchesTableReferences),
          Manche,
          PrefetchHooks Function({bool partieId, bool preneurId, bool appeleId})
        > {
  $$ManchesTableTableManager(_$AppDatabase db, $ManchesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ManchesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ManchesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ManchesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> partieId = const Value.absent(),
                Value<int> numero = const Value.absent(),
                Value<String> contrat = const Value.absent(),
                Value<int> preneurId = const Value.absent(),
                Value<int?> appeleId = const Value.absent(),
                Value<int> pointsPreneur = const Value.absent(),
                Value<int> bouts = const Value.absent(),
                Value<String> petitAuBout = const Value.absent(),
                Value<String> poignee = const Value.absent(),
                Value<String> chelem = const Value.absent(),
                Value<DateTime> dateCreation = const Value.absent(),
              }) => ManchesCompanion(
                id: id,
                partieId: partieId,
                numero: numero,
                contrat: contrat,
                preneurId: preneurId,
                appeleId: appeleId,
                pointsPreneur: pointsPreneur,
                bouts: bouts,
                petitAuBout: petitAuBout,
                poignee: poignee,
                chelem: chelem,
                dateCreation: dateCreation,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int partieId,
                required int numero,
                required String contrat,
                required int preneurId,
                Value<int?> appeleId = const Value.absent(),
                required int pointsPreneur,
                required int bouts,
                required String petitAuBout,
                required String poignee,
                required String chelem,
                Value<DateTime> dateCreation = const Value.absent(),
              }) => ManchesCompanion.insert(
                id: id,
                partieId: partieId,
                numero: numero,
                contrat: contrat,
                preneurId: preneurId,
                appeleId: appeleId,
                pointsPreneur: pointsPreneur,
                bouts: bouts,
                petitAuBout: petitAuBout,
                poignee: poignee,
                chelem: chelem,
                dateCreation: dateCreation,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ManchesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({partieId = false, preneurId = false, appeleId = false}) {
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
                        if (partieId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.partieId,
                                    referencedTable: $$ManchesTableReferences
                                        ._partieIdTable(db),
                                    referencedColumn: $$ManchesTableReferences
                                        ._partieIdTable(db)
                                        .id,
                                  )
                                  as T;
                        }
                        if (preneurId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.preneurId,
                                    referencedTable: $$ManchesTableReferences
                                        ._preneurIdTable(db),
                                    referencedColumn: $$ManchesTableReferences
                                        ._preneurIdTable(db)
                                        .id,
                                  )
                                  as T;
                        }
                        if (appeleId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.appeleId,
                                    referencedTable: $$ManchesTableReferences
                                        ._appeleIdTable(db),
                                    referencedColumn: $$ManchesTableReferences
                                        ._appeleIdTable(db)
                                        .id,
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

typedef $$ManchesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ManchesTable,
      Manche,
      $$ManchesTableFilterComposer,
      $$ManchesTableOrderingComposer,
      $$ManchesTableAnnotationComposer,
      $$ManchesTableCreateCompanionBuilder,
      $$ManchesTableUpdateCompanionBuilder,
      (Manche, $$ManchesTableReferences),
      Manche,
      PrefetchHooks Function({bool partieId, bool preneurId, bool appeleId})
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$JoueursTableTableManager get joueurs =>
      $$JoueursTableTableManager(_db, _db.joueurs);
  $$PartiesTableTableManager get parties =>
      $$PartiesTableTableManager(_db, _db.parties);
  $$PartieJoueursTableTableManager get partieJoueurs =>
      $$PartieJoueursTableTableManager(_db, _db.partieJoueurs);
  $$ManchesTableTableManager get manches =>
      $$ManchesTableTableManager(_db, _db.manches);
}
