// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $CitiesTable extends Cities with TableInfo<$CitiesTable, City> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CitiesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
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
  static const VerificationMeta _provinceMeta = const VerificationMeta(
    'province',
  );
  @override
  late final GeneratedColumn<String> province = GeneratedColumn<String>(
    'province',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _regionMeta = const VerificationMeta('region');
  @override
  late final GeneratedColumn<String> region = GeneratedColumn<String>(
    'region',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _climateZoneMeta = const VerificationMeta(
    'climateZone',
  );
  @override
  late final GeneratedColumn<String> climateZone = GeneratedColumn<String>(
    'climate_zone',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _latMeta = const VerificationMeta('lat');
  @override
  late final GeneratedColumn<double> lat = GeneratedColumn<double>(
    'lat',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lngMeta = const VerificationMeta('lng');
  @override
  late final GeneratedColumn<double> lng = GeneratedColumn<double>(
    'lng',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    province,
    region,
    climateZone,
    lat,
    lng,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cities';
  @override
  VerificationContext validateIntegrity(
    Insertable<City> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('province')) {
      context.handle(
        _provinceMeta,
        province.isAcceptableOrUnknown(data['province']!, _provinceMeta),
      );
    } else if (isInserting) {
      context.missing(_provinceMeta);
    }
    if (data.containsKey('region')) {
      context.handle(
        _regionMeta,
        region.isAcceptableOrUnknown(data['region']!, _regionMeta),
      );
    } else if (isInserting) {
      context.missing(_regionMeta);
    }
    if (data.containsKey('climate_zone')) {
      context.handle(
        _climateZoneMeta,
        climateZone.isAcceptableOrUnknown(
          data['climate_zone']!,
          _climateZoneMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_climateZoneMeta);
    }
    if (data.containsKey('lat')) {
      context.handle(
        _latMeta,
        lat.isAcceptableOrUnknown(data['lat']!, _latMeta),
      );
    } else if (isInserting) {
      context.missing(_latMeta);
    }
    if (data.containsKey('lng')) {
      context.handle(
        _lngMeta,
        lng.isAcceptableOrUnknown(data['lng']!, _lngMeta),
      );
    } else if (isInserting) {
      context.missing(_lngMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  City map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return City(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      province: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}province'],
      )!,
      region: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}region'],
      )!,
      climateZone: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}climate_zone'],
      )!,
      lat: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}lat'],
      )!,
      lng: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}lng'],
      )!,
    );
  }

  @override
  $CitiesTable createAlias(String alias) {
    return $CitiesTable(attachedDatabase, alias);
  }
}

class City extends DataClass implements Insertable<City> {
  final String id;
  final String name;
  final String province;
  final String region;
  final String climateZone;
  final double lat;
  final double lng;
  const City({
    required this.id,
    required this.name,
    required this.province,
    required this.region,
    required this.climateZone,
    required this.lat,
    required this.lng,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['province'] = Variable<String>(province);
    map['region'] = Variable<String>(region);
    map['climate_zone'] = Variable<String>(climateZone);
    map['lat'] = Variable<double>(lat);
    map['lng'] = Variable<double>(lng);
    return map;
  }

  CitiesCompanion toCompanion(bool nullToAbsent) {
    return CitiesCompanion(
      id: Value(id),
      name: Value(name),
      province: Value(province),
      region: Value(region),
      climateZone: Value(climateZone),
      lat: Value(lat),
      lng: Value(lng),
    );
  }

  factory City.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return City(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      province: serializer.fromJson<String>(json['province']),
      region: serializer.fromJson<String>(json['region']),
      climateZone: serializer.fromJson<String>(json['climateZone']),
      lat: serializer.fromJson<double>(json['lat']),
      lng: serializer.fromJson<double>(json['lng']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'province': serializer.toJson<String>(province),
      'region': serializer.toJson<String>(region),
      'climateZone': serializer.toJson<String>(climateZone),
      'lat': serializer.toJson<double>(lat),
      'lng': serializer.toJson<double>(lng),
    };
  }

  City copyWith({
    String? id,
    String? name,
    String? province,
    String? region,
    String? climateZone,
    double? lat,
    double? lng,
  }) => City(
    id: id ?? this.id,
    name: name ?? this.name,
    province: province ?? this.province,
    region: region ?? this.region,
    climateZone: climateZone ?? this.climateZone,
    lat: lat ?? this.lat,
    lng: lng ?? this.lng,
  );
  City copyWithCompanion(CitiesCompanion data) {
    return City(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      province: data.province.present ? data.province.value : this.province,
      region: data.region.present ? data.region.value : this.region,
      climateZone: data.climateZone.present
          ? data.climateZone.value
          : this.climateZone,
      lat: data.lat.present ? data.lat.value : this.lat,
      lng: data.lng.present ? data.lng.value : this.lng,
    );
  }

  @override
  String toString() {
    return (StringBuffer('City(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('province: $province, ')
          ..write('region: $region, ')
          ..write('climateZone: $climateZone, ')
          ..write('lat: $lat, ')
          ..write('lng: $lng')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, name, province, region, climateZone, lat, lng);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is City &&
          other.id == this.id &&
          other.name == this.name &&
          other.province == this.province &&
          other.region == this.region &&
          other.climateZone == this.climateZone &&
          other.lat == this.lat &&
          other.lng == this.lng);
}

class CitiesCompanion extends UpdateCompanion<City> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> province;
  final Value<String> region;
  final Value<String> climateZone;
  final Value<double> lat;
  final Value<double> lng;
  final Value<int> rowid;
  const CitiesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.province = const Value.absent(),
    this.region = const Value.absent(),
    this.climateZone = const Value.absent(),
    this.lat = const Value.absent(),
    this.lng = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CitiesCompanion.insert({
    required String id,
    required String name,
    required String province,
    required String region,
    required String climateZone,
    required double lat,
    required double lng,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       province = Value(province),
       region = Value(region),
       climateZone = Value(climateZone),
       lat = Value(lat),
       lng = Value(lng);
  static Insertable<City> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? province,
    Expression<String>? region,
    Expression<String>? climateZone,
    Expression<double>? lat,
    Expression<double>? lng,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (province != null) 'province': province,
      if (region != null) 'region': region,
      if (climateZone != null) 'climate_zone': climateZone,
      if (lat != null) 'lat': lat,
      if (lng != null) 'lng': lng,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CitiesCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String>? province,
    Value<String>? region,
    Value<String>? climateZone,
    Value<double>? lat,
    Value<double>? lng,
    Value<int>? rowid,
  }) {
    return CitiesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      province: province ?? this.province,
      region: region ?? this.region,
      climateZone: climateZone ?? this.climateZone,
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (province.present) {
      map['province'] = Variable<String>(province.value);
    }
    if (region.present) {
      map['region'] = Variable<String>(region.value);
    }
    if (climateZone.present) {
      map['climate_zone'] = Variable<String>(climateZone.value);
    }
    if (lat.present) {
      map['lat'] = Variable<double>(lat.value);
    }
    if (lng.present) {
      map['lng'] = Variable<double>(lng.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CitiesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('province: $province, ')
          ..write('region: $region, ')
          ..write('climateZone: $climateZone, ')
          ..write('lat: $lat, ')
          ..write('lng: $lng, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $FruitsTable extends Fruits with TableInfo<$FruitsTable, Fruit> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FruitsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
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
  static const VerificationMeta _englishNameMeta = const VerificationMeta(
    'englishName',
  );
  @override
  late final GeneratedColumn<String> englishName = GeneratedColumn<String>(
    'english_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _imageMeta = const VerificationMeta('image');
  @override
  late final GeneratedColumn<String> image = GeneratedColumn<String>(
    'image',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _colorHexMeta = const VerificationMeta(
    'colorHex',
  );
  @override
  late final GeneratedColumn<String> colorHex = GeneratedColumn<String>(
    'color_hex',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _brixMinMeta = const VerificationMeta(
    'brixMin',
  );
  @override
  late final GeneratedColumn<double> brixMin = GeneratedColumn<double>(
    'brix_min',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _brixMaxMeta = const VerificationMeta(
    'brixMax',
  );
  @override
  late final GeneratedColumn<double> brixMax = GeneratedColumn<double>(
    'brix_max',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _calorieKcalPer100gMeta =
      const VerificationMeta('calorieKcalPer100g');
  @override
  late final GeneratedColumn<int> calorieKcalPer100g = GeneratedColumn<int>(
    'calorie_kcal_per_100g',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _tcmNatureMeta = const VerificationMeta(
    'tcmNature',
  );
  @override
  late final GeneratedColumn<String> tcmNature = GeneratedColumn<String>(
    'tcm_nature',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _peakSeasonMeta = const VerificationMeta(
    'peakSeason',
  );
  @override
  late final GeneratedColumn<String> peakSeason = GeneratedColumn<String>(
    'peak_season',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _aliasJsonMeta = const VerificationMeta(
    'aliasJson',
  );
  @override
  late final GeneratedColumn<String> aliasJson = GeneratedColumn<String>(
    'alias_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _vitaminsJsonMeta = const VerificationMeta(
    'vitaminsJson',
  );
  @override
  late final GeneratedColumn<String> vitaminsJson = GeneratedColumn<String>(
    'vitamins_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _mineralsJsonMeta = const VerificationMeta(
    'mineralsJson',
  );
  @override
  late final GeneratedColumn<String> mineralsJson = GeneratedColumn<String>(
    'minerals_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _benefitsJsonMeta = const VerificationMeta(
    'benefitsJson',
  );
  @override
  late final GeneratedColumn<String> benefitsJson = GeneratedColumn<String>(
    'benefits_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _contraindicationsJsonMeta =
      const VerificationMeta('contraindicationsJson');
  @override
  late final GeneratedColumn<String> contraindicationsJson =
      GeneratedColumn<String>(
        'contraindications_json',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _originsJsonMeta = const VerificationMeta(
    'originsJson',
  );
  @override
  late final GeneratedColumn<String> originsJson = GeneratedColumn<String>(
    'origins_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    englishName,
    image,
    colorHex,
    brixMin,
    brixMax,
    calorieKcalPer100g,
    tcmNature,
    peakSeason,
    aliasJson,
    vitaminsJson,
    mineralsJson,
    benefitsJson,
    contraindicationsJson,
    originsJson,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'fruits';
  @override
  VerificationContext validateIntegrity(
    Insertable<Fruit> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('english_name')) {
      context.handle(
        _englishNameMeta,
        englishName.isAcceptableOrUnknown(
          data['english_name']!,
          _englishNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_englishNameMeta);
    }
    if (data.containsKey('image')) {
      context.handle(
        _imageMeta,
        image.isAcceptableOrUnknown(data['image']!, _imageMeta),
      );
    } else if (isInserting) {
      context.missing(_imageMeta);
    }
    if (data.containsKey('color_hex')) {
      context.handle(
        _colorHexMeta,
        colorHex.isAcceptableOrUnknown(data['color_hex']!, _colorHexMeta),
      );
    } else if (isInserting) {
      context.missing(_colorHexMeta);
    }
    if (data.containsKey('brix_min')) {
      context.handle(
        _brixMinMeta,
        brixMin.isAcceptableOrUnknown(data['brix_min']!, _brixMinMeta),
      );
    } else if (isInserting) {
      context.missing(_brixMinMeta);
    }
    if (data.containsKey('brix_max')) {
      context.handle(
        _brixMaxMeta,
        brixMax.isAcceptableOrUnknown(data['brix_max']!, _brixMaxMeta),
      );
    } else if (isInserting) {
      context.missing(_brixMaxMeta);
    }
    if (data.containsKey('calorie_kcal_per_100g')) {
      context.handle(
        _calorieKcalPer100gMeta,
        calorieKcalPer100g.isAcceptableOrUnknown(
          data['calorie_kcal_per_100g']!,
          _calorieKcalPer100gMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_calorieKcalPer100gMeta);
    }
    if (data.containsKey('tcm_nature')) {
      context.handle(
        _tcmNatureMeta,
        tcmNature.isAcceptableOrUnknown(data['tcm_nature']!, _tcmNatureMeta),
      );
    } else if (isInserting) {
      context.missing(_tcmNatureMeta);
    }
    if (data.containsKey('peak_season')) {
      context.handle(
        _peakSeasonMeta,
        peakSeason.isAcceptableOrUnknown(data['peak_season']!, _peakSeasonMeta),
      );
    } else if (isInserting) {
      context.missing(_peakSeasonMeta);
    }
    if (data.containsKey('alias_json')) {
      context.handle(
        _aliasJsonMeta,
        aliasJson.isAcceptableOrUnknown(data['alias_json']!, _aliasJsonMeta),
      );
    } else if (isInserting) {
      context.missing(_aliasJsonMeta);
    }
    if (data.containsKey('vitamins_json')) {
      context.handle(
        _vitaminsJsonMeta,
        vitaminsJson.isAcceptableOrUnknown(
          data['vitamins_json']!,
          _vitaminsJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_vitaminsJsonMeta);
    }
    if (data.containsKey('minerals_json')) {
      context.handle(
        _mineralsJsonMeta,
        mineralsJson.isAcceptableOrUnknown(
          data['minerals_json']!,
          _mineralsJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_mineralsJsonMeta);
    }
    if (data.containsKey('benefits_json')) {
      context.handle(
        _benefitsJsonMeta,
        benefitsJson.isAcceptableOrUnknown(
          data['benefits_json']!,
          _benefitsJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_benefitsJsonMeta);
    }
    if (data.containsKey('contraindications_json')) {
      context.handle(
        _contraindicationsJsonMeta,
        contraindicationsJson.isAcceptableOrUnknown(
          data['contraindications_json']!,
          _contraindicationsJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_contraindicationsJsonMeta);
    }
    if (data.containsKey('origins_json')) {
      context.handle(
        _originsJsonMeta,
        originsJson.isAcceptableOrUnknown(
          data['origins_json']!,
          _originsJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_originsJsonMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Fruit map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Fruit(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      englishName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}english_name'],
      )!,
      image: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}image'],
      )!,
      colorHex: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}color_hex'],
      )!,
      brixMin: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}brix_min'],
      )!,
      brixMax: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}brix_max'],
      )!,
      calorieKcalPer100g: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}calorie_kcal_per_100g'],
      )!,
      tcmNature: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tcm_nature'],
      )!,
      peakSeason: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}peak_season'],
      )!,
      aliasJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}alias_json'],
      )!,
      vitaminsJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}vitamins_json'],
      )!,
      mineralsJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}minerals_json'],
      )!,
      benefitsJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}benefits_json'],
      )!,
      contraindicationsJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}contraindications_json'],
      )!,
      originsJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}origins_json'],
      )!,
    );
  }

  @override
  $FruitsTable createAlias(String alias) {
    return $FruitsTable(attachedDatabase, alias);
  }
}

class Fruit extends DataClass implements Insertable<Fruit> {
  final String id;
  final String name;
  final String englishName;
  final String image;
  final String colorHex;
  final double brixMin;
  final double brixMax;
  final int calorieKcalPer100g;
  final String tcmNature;
  final String peakSeason;
  final String aliasJson;
  final String vitaminsJson;
  final String mineralsJson;
  final String benefitsJson;
  final String contraindicationsJson;
  final String originsJson;
  const Fruit({
    required this.id,
    required this.name,
    required this.englishName,
    required this.image,
    required this.colorHex,
    required this.brixMin,
    required this.brixMax,
    required this.calorieKcalPer100g,
    required this.tcmNature,
    required this.peakSeason,
    required this.aliasJson,
    required this.vitaminsJson,
    required this.mineralsJson,
    required this.benefitsJson,
    required this.contraindicationsJson,
    required this.originsJson,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['english_name'] = Variable<String>(englishName);
    map['image'] = Variable<String>(image);
    map['color_hex'] = Variable<String>(colorHex);
    map['brix_min'] = Variable<double>(brixMin);
    map['brix_max'] = Variable<double>(brixMax);
    map['calorie_kcal_per_100g'] = Variable<int>(calorieKcalPer100g);
    map['tcm_nature'] = Variable<String>(tcmNature);
    map['peak_season'] = Variable<String>(peakSeason);
    map['alias_json'] = Variable<String>(aliasJson);
    map['vitamins_json'] = Variable<String>(vitaminsJson);
    map['minerals_json'] = Variable<String>(mineralsJson);
    map['benefits_json'] = Variable<String>(benefitsJson);
    map['contraindications_json'] = Variable<String>(contraindicationsJson);
    map['origins_json'] = Variable<String>(originsJson);
    return map;
  }

  FruitsCompanion toCompanion(bool nullToAbsent) {
    return FruitsCompanion(
      id: Value(id),
      name: Value(name),
      englishName: Value(englishName),
      image: Value(image),
      colorHex: Value(colorHex),
      brixMin: Value(brixMin),
      brixMax: Value(brixMax),
      calorieKcalPer100g: Value(calorieKcalPer100g),
      tcmNature: Value(tcmNature),
      peakSeason: Value(peakSeason),
      aliasJson: Value(aliasJson),
      vitaminsJson: Value(vitaminsJson),
      mineralsJson: Value(mineralsJson),
      benefitsJson: Value(benefitsJson),
      contraindicationsJson: Value(contraindicationsJson),
      originsJson: Value(originsJson),
    );
  }

  factory Fruit.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Fruit(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      englishName: serializer.fromJson<String>(json['englishName']),
      image: serializer.fromJson<String>(json['image']),
      colorHex: serializer.fromJson<String>(json['colorHex']),
      brixMin: serializer.fromJson<double>(json['brixMin']),
      brixMax: serializer.fromJson<double>(json['brixMax']),
      calorieKcalPer100g: serializer.fromJson<int>(json['calorieKcalPer100g']),
      tcmNature: serializer.fromJson<String>(json['tcmNature']),
      peakSeason: serializer.fromJson<String>(json['peakSeason']),
      aliasJson: serializer.fromJson<String>(json['aliasJson']),
      vitaminsJson: serializer.fromJson<String>(json['vitaminsJson']),
      mineralsJson: serializer.fromJson<String>(json['mineralsJson']),
      benefitsJson: serializer.fromJson<String>(json['benefitsJson']),
      contraindicationsJson: serializer.fromJson<String>(
        json['contraindicationsJson'],
      ),
      originsJson: serializer.fromJson<String>(json['originsJson']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'englishName': serializer.toJson<String>(englishName),
      'image': serializer.toJson<String>(image),
      'colorHex': serializer.toJson<String>(colorHex),
      'brixMin': serializer.toJson<double>(brixMin),
      'brixMax': serializer.toJson<double>(brixMax),
      'calorieKcalPer100g': serializer.toJson<int>(calorieKcalPer100g),
      'tcmNature': serializer.toJson<String>(tcmNature),
      'peakSeason': serializer.toJson<String>(peakSeason),
      'aliasJson': serializer.toJson<String>(aliasJson),
      'vitaminsJson': serializer.toJson<String>(vitaminsJson),
      'mineralsJson': serializer.toJson<String>(mineralsJson),
      'benefitsJson': serializer.toJson<String>(benefitsJson),
      'contraindicationsJson': serializer.toJson<String>(contraindicationsJson),
      'originsJson': serializer.toJson<String>(originsJson),
    };
  }

  Fruit copyWith({
    String? id,
    String? name,
    String? englishName,
    String? image,
    String? colorHex,
    double? brixMin,
    double? brixMax,
    int? calorieKcalPer100g,
    String? tcmNature,
    String? peakSeason,
    String? aliasJson,
    String? vitaminsJson,
    String? mineralsJson,
    String? benefitsJson,
    String? contraindicationsJson,
    String? originsJson,
  }) => Fruit(
    id: id ?? this.id,
    name: name ?? this.name,
    englishName: englishName ?? this.englishName,
    image: image ?? this.image,
    colorHex: colorHex ?? this.colorHex,
    brixMin: brixMin ?? this.brixMin,
    brixMax: brixMax ?? this.brixMax,
    calorieKcalPer100g: calorieKcalPer100g ?? this.calorieKcalPer100g,
    tcmNature: tcmNature ?? this.tcmNature,
    peakSeason: peakSeason ?? this.peakSeason,
    aliasJson: aliasJson ?? this.aliasJson,
    vitaminsJson: vitaminsJson ?? this.vitaminsJson,
    mineralsJson: mineralsJson ?? this.mineralsJson,
    benefitsJson: benefitsJson ?? this.benefitsJson,
    contraindicationsJson: contraindicationsJson ?? this.contraindicationsJson,
    originsJson: originsJson ?? this.originsJson,
  );
  Fruit copyWithCompanion(FruitsCompanion data) {
    return Fruit(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      englishName: data.englishName.present
          ? data.englishName.value
          : this.englishName,
      image: data.image.present ? data.image.value : this.image,
      colorHex: data.colorHex.present ? data.colorHex.value : this.colorHex,
      brixMin: data.brixMin.present ? data.brixMin.value : this.brixMin,
      brixMax: data.brixMax.present ? data.brixMax.value : this.brixMax,
      calorieKcalPer100g: data.calorieKcalPer100g.present
          ? data.calorieKcalPer100g.value
          : this.calorieKcalPer100g,
      tcmNature: data.tcmNature.present ? data.tcmNature.value : this.tcmNature,
      peakSeason: data.peakSeason.present
          ? data.peakSeason.value
          : this.peakSeason,
      aliasJson: data.aliasJson.present ? data.aliasJson.value : this.aliasJson,
      vitaminsJson: data.vitaminsJson.present
          ? data.vitaminsJson.value
          : this.vitaminsJson,
      mineralsJson: data.mineralsJson.present
          ? data.mineralsJson.value
          : this.mineralsJson,
      benefitsJson: data.benefitsJson.present
          ? data.benefitsJson.value
          : this.benefitsJson,
      contraindicationsJson: data.contraindicationsJson.present
          ? data.contraindicationsJson.value
          : this.contraindicationsJson,
      originsJson: data.originsJson.present
          ? data.originsJson.value
          : this.originsJson,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Fruit(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('englishName: $englishName, ')
          ..write('image: $image, ')
          ..write('colorHex: $colorHex, ')
          ..write('brixMin: $brixMin, ')
          ..write('brixMax: $brixMax, ')
          ..write('calorieKcalPer100g: $calorieKcalPer100g, ')
          ..write('tcmNature: $tcmNature, ')
          ..write('peakSeason: $peakSeason, ')
          ..write('aliasJson: $aliasJson, ')
          ..write('vitaminsJson: $vitaminsJson, ')
          ..write('mineralsJson: $mineralsJson, ')
          ..write('benefitsJson: $benefitsJson, ')
          ..write('contraindicationsJson: $contraindicationsJson, ')
          ..write('originsJson: $originsJson')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    englishName,
    image,
    colorHex,
    brixMin,
    brixMax,
    calorieKcalPer100g,
    tcmNature,
    peakSeason,
    aliasJson,
    vitaminsJson,
    mineralsJson,
    benefitsJson,
    contraindicationsJson,
    originsJson,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Fruit &&
          other.id == this.id &&
          other.name == this.name &&
          other.englishName == this.englishName &&
          other.image == this.image &&
          other.colorHex == this.colorHex &&
          other.brixMin == this.brixMin &&
          other.brixMax == this.brixMax &&
          other.calorieKcalPer100g == this.calorieKcalPer100g &&
          other.tcmNature == this.tcmNature &&
          other.peakSeason == this.peakSeason &&
          other.aliasJson == this.aliasJson &&
          other.vitaminsJson == this.vitaminsJson &&
          other.mineralsJson == this.mineralsJson &&
          other.benefitsJson == this.benefitsJson &&
          other.contraindicationsJson == this.contraindicationsJson &&
          other.originsJson == this.originsJson);
}

class FruitsCompanion extends UpdateCompanion<Fruit> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> englishName;
  final Value<String> image;
  final Value<String> colorHex;
  final Value<double> brixMin;
  final Value<double> brixMax;
  final Value<int> calorieKcalPer100g;
  final Value<String> tcmNature;
  final Value<String> peakSeason;
  final Value<String> aliasJson;
  final Value<String> vitaminsJson;
  final Value<String> mineralsJson;
  final Value<String> benefitsJson;
  final Value<String> contraindicationsJson;
  final Value<String> originsJson;
  final Value<int> rowid;
  const FruitsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.englishName = const Value.absent(),
    this.image = const Value.absent(),
    this.colorHex = const Value.absent(),
    this.brixMin = const Value.absent(),
    this.brixMax = const Value.absent(),
    this.calorieKcalPer100g = const Value.absent(),
    this.tcmNature = const Value.absent(),
    this.peakSeason = const Value.absent(),
    this.aliasJson = const Value.absent(),
    this.vitaminsJson = const Value.absent(),
    this.mineralsJson = const Value.absent(),
    this.benefitsJson = const Value.absent(),
    this.contraindicationsJson = const Value.absent(),
    this.originsJson = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  FruitsCompanion.insert({
    required String id,
    required String name,
    required String englishName,
    required String image,
    required String colorHex,
    required double brixMin,
    required double brixMax,
    required int calorieKcalPer100g,
    required String tcmNature,
    required String peakSeason,
    required String aliasJson,
    required String vitaminsJson,
    required String mineralsJson,
    required String benefitsJson,
    required String contraindicationsJson,
    required String originsJson,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       englishName = Value(englishName),
       image = Value(image),
       colorHex = Value(colorHex),
       brixMin = Value(brixMin),
       brixMax = Value(brixMax),
       calorieKcalPer100g = Value(calorieKcalPer100g),
       tcmNature = Value(tcmNature),
       peakSeason = Value(peakSeason),
       aliasJson = Value(aliasJson),
       vitaminsJson = Value(vitaminsJson),
       mineralsJson = Value(mineralsJson),
       benefitsJson = Value(benefitsJson),
       contraindicationsJson = Value(contraindicationsJson),
       originsJson = Value(originsJson);
  static Insertable<Fruit> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? englishName,
    Expression<String>? image,
    Expression<String>? colorHex,
    Expression<double>? brixMin,
    Expression<double>? brixMax,
    Expression<int>? calorieKcalPer100g,
    Expression<String>? tcmNature,
    Expression<String>? peakSeason,
    Expression<String>? aliasJson,
    Expression<String>? vitaminsJson,
    Expression<String>? mineralsJson,
    Expression<String>? benefitsJson,
    Expression<String>? contraindicationsJson,
    Expression<String>? originsJson,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (englishName != null) 'english_name': englishName,
      if (image != null) 'image': image,
      if (colorHex != null) 'color_hex': colorHex,
      if (brixMin != null) 'brix_min': brixMin,
      if (brixMax != null) 'brix_max': brixMax,
      if (calorieKcalPer100g != null)
        'calorie_kcal_per_100g': calorieKcalPer100g,
      if (tcmNature != null) 'tcm_nature': tcmNature,
      if (peakSeason != null) 'peak_season': peakSeason,
      if (aliasJson != null) 'alias_json': aliasJson,
      if (vitaminsJson != null) 'vitamins_json': vitaminsJson,
      if (mineralsJson != null) 'minerals_json': mineralsJson,
      if (benefitsJson != null) 'benefits_json': benefitsJson,
      if (contraindicationsJson != null)
        'contraindications_json': contraindicationsJson,
      if (originsJson != null) 'origins_json': originsJson,
      if (rowid != null) 'rowid': rowid,
    });
  }

  FruitsCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String>? englishName,
    Value<String>? image,
    Value<String>? colorHex,
    Value<double>? brixMin,
    Value<double>? brixMax,
    Value<int>? calorieKcalPer100g,
    Value<String>? tcmNature,
    Value<String>? peakSeason,
    Value<String>? aliasJson,
    Value<String>? vitaminsJson,
    Value<String>? mineralsJson,
    Value<String>? benefitsJson,
    Value<String>? contraindicationsJson,
    Value<String>? originsJson,
    Value<int>? rowid,
  }) {
    return FruitsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      englishName: englishName ?? this.englishName,
      image: image ?? this.image,
      colorHex: colorHex ?? this.colorHex,
      brixMin: brixMin ?? this.brixMin,
      brixMax: brixMax ?? this.brixMax,
      calorieKcalPer100g: calorieKcalPer100g ?? this.calorieKcalPer100g,
      tcmNature: tcmNature ?? this.tcmNature,
      peakSeason: peakSeason ?? this.peakSeason,
      aliasJson: aliasJson ?? this.aliasJson,
      vitaminsJson: vitaminsJson ?? this.vitaminsJson,
      mineralsJson: mineralsJson ?? this.mineralsJson,
      benefitsJson: benefitsJson ?? this.benefitsJson,
      contraindicationsJson:
          contraindicationsJson ?? this.contraindicationsJson,
      originsJson: originsJson ?? this.originsJson,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (englishName.present) {
      map['english_name'] = Variable<String>(englishName.value);
    }
    if (image.present) {
      map['image'] = Variable<String>(image.value);
    }
    if (colorHex.present) {
      map['color_hex'] = Variable<String>(colorHex.value);
    }
    if (brixMin.present) {
      map['brix_min'] = Variable<double>(brixMin.value);
    }
    if (brixMax.present) {
      map['brix_max'] = Variable<double>(brixMax.value);
    }
    if (calorieKcalPer100g.present) {
      map['calorie_kcal_per_100g'] = Variable<int>(calorieKcalPer100g.value);
    }
    if (tcmNature.present) {
      map['tcm_nature'] = Variable<String>(tcmNature.value);
    }
    if (peakSeason.present) {
      map['peak_season'] = Variable<String>(peakSeason.value);
    }
    if (aliasJson.present) {
      map['alias_json'] = Variable<String>(aliasJson.value);
    }
    if (vitaminsJson.present) {
      map['vitamins_json'] = Variable<String>(vitaminsJson.value);
    }
    if (mineralsJson.present) {
      map['minerals_json'] = Variable<String>(mineralsJson.value);
    }
    if (benefitsJson.present) {
      map['benefits_json'] = Variable<String>(benefitsJson.value);
    }
    if (contraindicationsJson.present) {
      map['contraindications_json'] = Variable<String>(
        contraindicationsJson.value,
      );
    }
    if (originsJson.present) {
      map['origins_json'] = Variable<String>(originsJson.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FruitsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('englishName: $englishName, ')
          ..write('image: $image, ')
          ..write('colorHex: $colorHex, ')
          ..write('brixMin: $brixMin, ')
          ..write('brixMax: $brixMax, ')
          ..write('calorieKcalPer100g: $calorieKcalPer100g, ')
          ..write('tcmNature: $tcmNature, ')
          ..write('peakSeason: $peakSeason, ')
          ..write('aliasJson: $aliasJson, ')
          ..write('vitaminsJson: $vitaminsJson, ')
          ..write('mineralsJson: $mineralsJson, ')
          ..write('benefitsJson: $benefitsJson, ')
          ..write('contraindicationsJson: $contraindicationsJson, ')
          ..write('originsJson: $originsJson, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $RecommendationsTable extends Recommendations
    with TableInfo<$RecommendationsTable, Recommendation> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RecommendationsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _cityIdMeta = const VerificationMeta('cityId');
  @override
  late final GeneratedColumn<String> cityId = GeneratedColumn<String>(
    'city_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _monthMeta = const VerificationMeta('month');
  @override
  late final GeneratedColumn<int> month = GeneratedColumn<int>(
    'month',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _periodMeta = const VerificationMeta('period');
  @override
  late final GeneratedColumn<String> period = GeneratedColumn<String>(
    'period',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fruitIdMeta = const VerificationMeta(
    'fruitId',
  );
  @override
  late final GeneratedColumn<String> fruitId = GeneratedColumn<String>(
    'fruit_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _scoreMeta = const VerificationMeta('score');
  @override
  late final GeneratedColumn<int> score = GeneratedColumn<int>(
    'score',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _reasonMeta = const VerificationMeta('reason');
  @override
  late final GeneratedColumn<String> reason = GeneratedColumn<String>(
    'reason',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _localityMeta = const VerificationMeta(
    'locality',
  );
  @override
  late final GeneratedColumn<String> locality = GeneratedColumn<String>(
    'locality',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    cityId,
    month,
    period,
    fruitId,
    score,
    reason,
    locality,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'recommendations';
  @override
  VerificationContext validateIntegrity(
    Insertable<Recommendation> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('city_id')) {
      context.handle(
        _cityIdMeta,
        cityId.isAcceptableOrUnknown(data['city_id']!, _cityIdMeta),
      );
    } else if (isInserting) {
      context.missing(_cityIdMeta);
    }
    if (data.containsKey('month')) {
      context.handle(
        _monthMeta,
        month.isAcceptableOrUnknown(data['month']!, _monthMeta),
      );
    } else if (isInserting) {
      context.missing(_monthMeta);
    }
    if (data.containsKey('period')) {
      context.handle(
        _periodMeta,
        period.isAcceptableOrUnknown(data['period']!, _periodMeta),
      );
    } else if (isInserting) {
      context.missing(_periodMeta);
    }
    if (data.containsKey('fruit_id')) {
      context.handle(
        _fruitIdMeta,
        fruitId.isAcceptableOrUnknown(data['fruit_id']!, _fruitIdMeta),
      );
    } else if (isInserting) {
      context.missing(_fruitIdMeta);
    }
    if (data.containsKey('score')) {
      context.handle(
        _scoreMeta,
        score.isAcceptableOrUnknown(data['score']!, _scoreMeta),
      );
    } else if (isInserting) {
      context.missing(_scoreMeta);
    }
    if (data.containsKey('reason')) {
      context.handle(
        _reasonMeta,
        reason.isAcceptableOrUnknown(data['reason']!, _reasonMeta),
      );
    } else if (isInserting) {
      context.missing(_reasonMeta);
    }
    if (data.containsKey('locality')) {
      context.handle(
        _localityMeta,
        locality.isAcceptableOrUnknown(data['locality']!, _localityMeta),
      );
    } else if (isInserting) {
      context.missing(_localityMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Recommendation map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Recommendation(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      cityId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}city_id'],
      )!,
      month: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}month'],
      )!,
      period: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}period'],
      )!,
      fruitId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}fruit_id'],
      )!,
      score: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}score'],
      )!,
      reason: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reason'],
      )!,
      locality: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}locality'],
      )!,
    );
  }

  @override
  $RecommendationsTable createAlias(String alias) {
    return $RecommendationsTable(attachedDatabase, alias);
  }
}

class Recommendation extends DataClass implements Insertable<Recommendation> {
  final int id;
  final String cityId;
  final int month;
  final String period;
  final String fruitId;
  final int score;
  final String reason;
  final String locality;
  const Recommendation({
    required this.id,
    required this.cityId,
    required this.month,
    required this.period,
    required this.fruitId,
    required this.score,
    required this.reason,
    required this.locality,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['city_id'] = Variable<String>(cityId);
    map['month'] = Variable<int>(month);
    map['period'] = Variable<String>(period);
    map['fruit_id'] = Variable<String>(fruitId);
    map['score'] = Variable<int>(score);
    map['reason'] = Variable<String>(reason);
    map['locality'] = Variable<String>(locality);
    return map;
  }

  RecommendationsCompanion toCompanion(bool nullToAbsent) {
    return RecommendationsCompanion(
      id: Value(id),
      cityId: Value(cityId),
      month: Value(month),
      period: Value(period),
      fruitId: Value(fruitId),
      score: Value(score),
      reason: Value(reason),
      locality: Value(locality),
    );
  }

  factory Recommendation.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Recommendation(
      id: serializer.fromJson<int>(json['id']),
      cityId: serializer.fromJson<String>(json['cityId']),
      month: serializer.fromJson<int>(json['month']),
      period: serializer.fromJson<String>(json['period']),
      fruitId: serializer.fromJson<String>(json['fruitId']),
      score: serializer.fromJson<int>(json['score']),
      reason: serializer.fromJson<String>(json['reason']),
      locality: serializer.fromJson<String>(json['locality']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'cityId': serializer.toJson<String>(cityId),
      'month': serializer.toJson<int>(month),
      'period': serializer.toJson<String>(period),
      'fruitId': serializer.toJson<String>(fruitId),
      'score': serializer.toJson<int>(score),
      'reason': serializer.toJson<String>(reason),
      'locality': serializer.toJson<String>(locality),
    };
  }

  Recommendation copyWith({
    int? id,
    String? cityId,
    int? month,
    String? period,
    String? fruitId,
    int? score,
    String? reason,
    String? locality,
  }) => Recommendation(
    id: id ?? this.id,
    cityId: cityId ?? this.cityId,
    month: month ?? this.month,
    period: period ?? this.period,
    fruitId: fruitId ?? this.fruitId,
    score: score ?? this.score,
    reason: reason ?? this.reason,
    locality: locality ?? this.locality,
  );
  Recommendation copyWithCompanion(RecommendationsCompanion data) {
    return Recommendation(
      id: data.id.present ? data.id.value : this.id,
      cityId: data.cityId.present ? data.cityId.value : this.cityId,
      month: data.month.present ? data.month.value : this.month,
      period: data.period.present ? data.period.value : this.period,
      fruitId: data.fruitId.present ? data.fruitId.value : this.fruitId,
      score: data.score.present ? data.score.value : this.score,
      reason: data.reason.present ? data.reason.value : this.reason,
      locality: data.locality.present ? data.locality.value : this.locality,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Recommendation(')
          ..write('id: $id, ')
          ..write('cityId: $cityId, ')
          ..write('month: $month, ')
          ..write('period: $period, ')
          ..write('fruitId: $fruitId, ')
          ..write('score: $score, ')
          ..write('reason: $reason, ')
          ..write('locality: $locality')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, cityId, month, period, fruitId, score, reason, locality);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Recommendation &&
          other.id == this.id &&
          other.cityId == this.cityId &&
          other.month == this.month &&
          other.period == this.period &&
          other.fruitId == this.fruitId &&
          other.score == this.score &&
          other.reason == this.reason &&
          other.locality == this.locality);
}

class RecommendationsCompanion extends UpdateCompanion<Recommendation> {
  final Value<int> id;
  final Value<String> cityId;
  final Value<int> month;
  final Value<String> period;
  final Value<String> fruitId;
  final Value<int> score;
  final Value<String> reason;
  final Value<String> locality;
  const RecommendationsCompanion({
    this.id = const Value.absent(),
    this.cityId = const Value.absent(),
    this.month = const Value.absent(),
    this.period = const Value.absent(),
    this.fruitId = const Value.absent(),
    this.score = const Value.absent(),
    this.reason = const Value.absent(),
    this.locality = const Value.absent(),
  });
  RecommendationsCompanion.insert({
    this.id = const Value.absent(),
    required String cityId,
    required int month,
    required String period,
    required String fruitId,
    required int score,
    required String reason,
    required String locality,
  }) : cityId = Value(cityId),
       month = Value(month),
       period = Value(period),
       fruitId = Value(fruitId),
       score = Value(score),
       reason = Value(reason),
       locality = Value(locality);
  static Insertable<Recommendation> custom({
    Expression<int>? id,
    Expression<String>? cityId,
    Expression<int>? month,
    Expression<String>? period,
    Expression<String>? fruitId,
    Expression<int>? score,
    Expression<String>? reason,
    Expression<String>? locality,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (cityId != null) 'city_id': cityId,
      if (month != null) 'month': month,
      if (period != null) 'period': period,
      if (fruitId != null) 'fruit_id': fruitId,
      if (score != null) 'score': score,
      if (reason != null) 'reason': reason,
      if (locality != null) 'locality': locality,
    });
  }

  RecommendationsCompanion copyWith({
    Value<int>? id,
    Value<String>? cityId,
    Value<int>? month,
    Value<String>? period,
    Value<String>? fruitId,
    Value<int>? score,
    Value<String>? reason,
    Value<String>? locality,
  }) {
    return RecommendationsCompanion(
      id: id ?? this.id,
      cityId: cityId ?? this.cityId,
      month: month ?? this.month,
      period: period ?? this.period,
      fruitId: fruitId ?? this.fruitId,
      score: score ?? this.score,
      reason: reason ?? this.reason,
      locality: locality ?? this.locality,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (cityId.present) {
      map['city_id'] = Variable<String>(cityId.value);
    }
    if (month.present) {
      map['month'] = Variable<int>(month.value);
    }
    if (period.present) {
      map['period'] = Variable<String>(period.value);
    }
    if (fruitId.present) {
      map['fruit_id'] = Variable<String>(fruitId.value);
    }
    if (score.present) {
      map['score'] = Variable<int>(score.value);
    }
    if (reason.present) {
      map['reason'] = Variable<String>(reason.value);
    }
    if (locality.present) {
      map['locality'] = Variable<String>(locality.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RecommendationsCompanion(')
          ..write('id: $id, ')
          ..write('cityId: $cityId, ')
          ..write('month: $month, ')
          ..write('period: $period, ')
          ..write('fruitId: $fruitId, ')
          ..write('score: $score, ')
          ..write('reason: $reason, ')
          ..write('locality: $locality')
          ..write(')'))
        .toString();
  }
}

class $FavoritesTable extends Favorites
    with TableInfo<$FavoritesTable, Favorite> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FavoritesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _fruitIdMeta = const VerificationMeta(
    'fruitId',
  );
  @override
  late final GeneratedColumn<String> fruitId = GeneratedColumn<String>(
    'fruit_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _addedAtMeta = const VerificationMeta(
    'addedAt',
  );
  @override
  late final GeneratedColumn<String> addedAt = GeneratedColumn<String>(
    'added_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [fruitId, addedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'favorites';
  @override
  VerificationContext validateIntegrity(
    Insertable<Favorite> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('fruit_id')) {
      context.handle(
        _fruitIdMeta,
        fruitId.isAcceptableOrUnknown(data['fruit_id']!, _fruitIdMeta),
      );
    } else if (isInserting) {
      context.missing(_fruitIdMeta);
    }
    if (data.containsKey('added_at')) {
      context.handle(
        _addedAtMeta,
        addedAt.isAcceptableOrUnknown(data['added_at']!, _addedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_addedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {fruitId};
  @override
  Favorite map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Favorite(
      fruitId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}fruit_id'],
      )!,
      addedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}added_at'],
      )!,
    );
  }

  @override
  $FavoritesTable createAlias(String alias) {
    return $FavoritesTable(attachedDatabase, alias);
  }
}

class Favorite extends DataClass implements Insertable<Favorite> {
  final String fruitId;
  final String addedAt;
  const Favorite({required this.fruitId, required this.addedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['fruit_id'] = Variable<String>(fruitId);
    map['added_at'] = Variable<String>(addedAt);
    return map;
  }

  FavoritesCompanion toCompanion(bool nullToAbsent) {
    return FavoritesCompanion(fruitId: Value(fruitId), addedAt: Value(addedAt));
  }

  factory Favorite.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Favorite(
      fruitId: serializer.fromJson<String>(json['fruitId']),
      addedAt: serializer.fromJson<String>(json['addedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'fruitId': serializer.toJson<String>(fruitId),
      'addedAt': serializer.toJson<String>(addedAt),
    };
  }

  Favorite copyWith({String? fruitId, String? addedAt}) => Favorite(
    fruitId: fruitId ?? this.fruitId,
    addedAt: addedAt ?? this.addedAt,
  );
  Favorite copyWithCompanion(FavoritesCompanion data) {
    return Favorite(
      fruitId: data.fruitId.present ? data.fruitId.value : this.fruitId,
      addedAt: data.addedAt.present ? data.addedAt.value : this.addedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Favorite(')
          ..write('fruitId: $fruitId, ')
          ..write('addedAt: $addedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(fruitId, addedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Favorite &&
          other.fruitId == this.fruitId &&
          other.addedAt == this.addedAt);
}

class FavoritesCompanion extends UpdateCompanion<Favorite> {
  final Value<String> fruitId;
  final Value<String> addedAt;
  final Value<int> rowid;
  const FavoritesCompanion({
    this.fruitId = const Value.absent(),
    this.addedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  FavoritesCompanion.insert({
    required String fruitId,
    required String addedAt,
    this.rowid = const Value.absent(),
  }) : fruitId = Value(fruitId),
       addedAt = Value(addedAt);
  static Insertable<Favorite> custom({
    Expression<String>? fruitId,
    Expression<String>? addedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (fruitId != null) 'fruit_id': fruitId,
      if (addedAt != null) 'added_at': addedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  FavoritesCompanion copyWith({
    Value<String>? fruitId,
    Value<String>? addedAt,
    Value<int>? rowid,
  }) {
    return FavoritesCompanion(
      fruitId: fruitId ?? this.fruitId,
      addedAt: addedAt ?? this.addedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (fruitId.present) {
      map['fruit_id'] = Variable<String>(fruitId.value);
    }
    if (addedAt.present) {
      map['added_at'] = Variable<String>(addedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FavoritesCompanion(')
          ..write('fruitId: $fruitId, ')
          ..write('addedAt: $addedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $UserPrefsTable extends UserPrefs
    with TableInfo<$UserPrefsTable, UserPref> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UserPrefsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [key, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'user_prefs';
  @override
  VerificationContext validateIntegrity(
    Insertable<UserPref> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  UserPref map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UserPref(
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value'],
      )!,
    );
  }

  @override
  $UserPrefsTable createAlias(String alias) {
    return $UserPrefsTable(attachedDatabase, alias);
  }
}

class UserPref extends DataClass implements Insertable<UserPref> {
  final String key;
  final String value;
  const UserPref({required this.key, required this.value});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    return map;
  }

  UserPrefsCompanion toCompanion(bool nullToAbsent) {
    return UserPrefsCompanion(key: Value(key), value: Value(value));
  }

  factory UserPref.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UserPref(
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String>(json['value']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String>(value),
    };
  }

  UserPref copyWith({String? key, String? value}) =>
      UserPref(key: key ?? this.key, value: value ?? this.value);
  UserPref copyWithCompanion(UserPrefsCompanion data) {
    return UserPref(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UserPref(')
          ..write('key: $key, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, value);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UserPref && other.key == this.key && other.value == this.value);
}

class UserPrefsCompanion extends UpdateCompanion<UserPref> {
  final Value<String> key;
  final Value<String> value;
  final Value<int> rowid;
  const UserPrefsCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  UserPrefsCompanion.insert({
    required String key,
    required String value,
    this.rowid = const Value.absent(),
  }) : key = Value(key),
       value = Value(value);
  static Insertable<UserPref> custom({
    Expression<String>? key,
    Expression<String>? value,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (rowid != null) 'rowid': rowid,
    });
  }

  UserPrefsCompanion copyWith({
    Value<String>? key,
    Value<String>? value,
    Value<int>? rowid,
  }) {
    return UserPrefsCompanion(
      key: key ?? this.key,
      value: value ?? this.value,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UserPrefsCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $CitiesTable cities = $CitiesTable(this);
  late final $FruitsTable fruits = $FruitsTable(this);
  late final $RecommendationsTable recommendations = $RecommendationsTable(
    this,
  );
  late final $FavoritesTable favorites = $FavoritesTable(this);
  late final $UserPrefsTable userPrefs = $UserPrefsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    cities,
    fruits,
    recommendations,
    favorites,
    userPrefs,
  ];
}

typedef $$CitiesTableCreateCompanionBuilder =
    CitiesCompanion Function({
      required String id,
      required String name,
      required String province,
      required String region,
      required String climateZone,
      required double lat,
      required double lng,
      Value<int> rowid,
    });
typedef $$CitiesTableUpdateCompanionBuilder =
    CitiesCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String> province,
      Value<String> region,
      Value<String> climateZone,
      Value<double> lat,
      Value<double> lng,
      Value<int> rowid,
    });

class $$CitiesTableFilterComposer
    extends Composer<_$AppDatabase, $CitiesTable> {
  $$CitiesTableFilterComposer({
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

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get province => $composableBuilder(
    column: $table.province,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get region => $composableBuilder(
    column: $table.region,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get climateZone => $composableBuilder(
    column: $table.climateZone,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get lat => $composableBuilder(
    column: $table.lat,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get lng => $composableBuilder(
    column: $table.lng,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CitiesTableOrderingComposer
    extends Composer<_$AppDatabase, $CitiesTable> {
  $$CitiesTableOrderingComposer({
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

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get province => $composableBuilder(
    column: $table.province,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get region => $composableBuilder(
    column: $table.region,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get climateZone => $composableBuilder(
    column: $table.climateZone,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get lat => $composableBuilder(
    column: $table.lat,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get lng => $composableBuilder(
    column: $table.lng,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CitiesTableAnnotationComposer
    extends Composer<_$AppDatabase, $CitiesTable> {
  $$CitiesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get province =>
      $composableBuilder(column: $table.province, builder: (column) => column);

  GeneratedColumn<String> get region =>
      $composableBuilder(column: $table.region, builder: (column) => column);

  GeneratedColumn<String> get climateZone => $composableBuilder(
    column: $table.climateZone,
    builder: (column) => column,
  );

  GeneratedColumn<double> get lat =>
      $composableBuilder(column: $table.lat, builder: (column) => column);

  GeneratedColumn<double> get lng =>
      $composableBuilder(column: $table.lng, builder: (column) => column);
}

class $$CitiesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CitiesTable,
          City,
          $$CitiesTableFilterComposer,
          $$CitiesTableOrderingComposer,
          $$CitiesTableAnnotationComposer,
          $$CitiesTableCreateCompanionBuilder,
          $$CitiesTableUpdateCompanionBuilder,
          (City, BaseReferences<_$AppDatabase, $CitiesTable, City>),
          City,
          PrefetchHooks Function()
        > {
  $$CitiesTableTableManager(_$AppDatabase db, $CitiesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CitiesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CitiesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CitiesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> province = const Value.absent(),
                Value<String> region = const Value.absent(),
                Value<String> climateZone = const Value.absent(),
                Value<double> lat = const Value.absent(),
                Value<double> lng = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CitiesCompanion(
                id: id,
                name: name,
                province: province,
                region: region,
                climateZone: climateZone,
                lat: lat,
                lng: lng,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                required String province,
                required String region,
                required String climateZone,
                required double lat,
                required double lng,
                Value<int> rowid = const Value.absent(),
              }) => CitiesCompanion.insert(
                id: id,
                name: name,
                province: province,
                region: region,
                climateZone: climateZone,
                lat: lat,
                lng: lng,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CitiesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CitiesTable,
      City,
      $$CitiesTableFilterComposer,
      $$CitiesTableOrderingComposer,
      $$CitiesTableAnnotationComposer,
      $$CitiesTableCreateCompanionBuilder,
      $$CitiesTableUpdateCompanionBuilder,
      (City, BaseReferences<_$AppDatabase, $CitiesTable, City>),
      City,
      PrefetchHooks Function()
    >;
typedef $$FruitsTableCreateCompanionBuilder =
    FruitsCompanion Function({
      required String id,
      required String name,
      required String englishName,
      required String image,
      required String colorHex,
      required double brixMin,
      required double brixMax,
      required int calorieKcalPer100g,
      required String tcmNature,
      required String peakSeason,
      required String aliasJson,
      required String vitaminsJson,
      required String mineralsJson,
      required String benefitsJson,
      required String contraindicationsJson,
      required String originsJson,
      Value<int> rowid,
    });
typedef $$FruitsTableUpdateCompanionBuilder =
    FruitsCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String> englishName,
      Value<String> image,
      Value<String> colorHex,
      Value<double> brixMin,
      Value<double> brixMax,
      Value<int> calorieKcalPer100g,
      Value<String> tcmNature,
      Value<String> peakSeason,
      Value<String> aliasJson,
      Value<String> vitaminsJson,
      Value<String> mineralsJson,
      Value<String> benefitsJson,
      Value<String> contraindicationsJson,
      Value<String> originsJson,
      Value<int> rowid,
    });

class $$FruitsTableFilterComposer
    extends Composer<_$AppDatabase, $FruitsTable> {
  $$FruitsTableFilterComposer({
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

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get englishName => $composableBuilder(
    column: $table.englishName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get image => $composableBuilder(
    column: $table.image,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get colorHex => $composableBuilder(
    column: $table.colorHex,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get brixMin => $composableBuilder(
    column: $table.brixMin,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get brixMax => $composableBuilder(
    column: $table.brixMax,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get calorieKcalPer100g => $composableBuilder(
    column: $table.calorieKcalPer100g,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tcmNature => $composableBuilder(
    column: $table.tcmNature,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get peakSeason => $composableBuilder(
    column: $table.peakSeason,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get aliasJson => $composableBuilder(
    column: $table.aliasJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get vitaminsJson => $composableBuilder(
    column: $table.vitaminsJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mineralsJson => $composableBuilder(
    column: $table.mineralsJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get benefitsJson => $composableBuilder(
    column: $table.benefitsJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get contraindicationsJson => $composableBuilder(
    column: $table.contraindicationsJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get originsJson => $composableBuilder(
    column: $table.originsJson,
    builder: (column) => ColumnFilters(column),
  );
}

class $$FruitsTableOrderingComposer
    extends Composer<_$AppDatabase, $FruitsTable> {
  $$FruitsTableOrderingComposer({
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

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get englishName => $composableBuilder(
    column: $table.englishName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get image => $composableBuilder(
    column: $table.image,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get colorHex => $composableBuilder(
    column: $table.colorHex,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get brixMin => $composableBuilder(
    column: $table.brixMin,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get brixMax => $composableBuilder(
    column: $table.brixMax,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get calorieKcalPer100g => $composableBuilder(
    column: $table.calorieKcalPer100g,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tcmNature => $composableBuilder(
    column: $table.tcmNature,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get peakSeason => $composableBuilder(
    column: $table.peakSeason,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get aliasJson => $composableBuilder(
    column: $table.aliasJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get vitaminsJson => $composableBuilder(
    column: $table.vitaminsJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mineralsJson => $composableBuilder(
    column: $table.mineralsJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get benefitsJson => $composableBuilder(
    column: $table.benefitsJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get contraindicationsJson => $composableBuilder(
    column: $table.contraindicationsJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get originsJson => $composableBuilder(
    column: $table.originsJson,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$FruitsTableAnnotationComposer
    extends Composer<_$AppDatabase, $FruitsTable> {
  $$FruitsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get englishName => $composableBuilder(
    column: $table.englishName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get image =>
      $composableBuilder(column: $table.image, builder: (column) => column);

  GeneratedColumn<String> get colorHex =>
      $composableBuilder(column: $table.colorHex, builder: (column) => column);

  GeneratedColumn<double> get brixMin =>
      $composableBuilder(column: $table.brixMin, builder: (column) => column);

  GeneratedColumn<double> get brixMax =>
      $composableBuilder(column: $table.brixMax, builder: (column) => column);

  GeneratedColumn<int> get calorieKcalPer100g => $composableBuilder(
    column: $table.calorieKcalPer100g,
    builder: (column) => column,
  );

  GeneratedColumn<String> get tcmNature =>
      $composableBuilder(column: $table.tcmNature, builder: (column) => column);

  GeneratedColumn<String> get peakSeason => $composableBuilder(
    column: $table.peakSeason,
    builder: (column) => column,
  );

  GeneratedColumn<String> get aliasJson =>
      $composableBuilder(column: $table.aliasJson, builder: (column) => column);

  GeneratedColumn<String> get vitaminsJson => $composableBuilder(
    column: $table.vitaminsJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get mineralsJson => $composableBuilder(
    column: $table.mineralsJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get benefitsJson => $composableBuilder(
    column: $table.benefitsJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get contraindicationsJson => $composableBuilder(
    column: $table.contraindicationsJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get originsJson => $composableBuilder(
    column: $table.originsJson,
    builder: (column) => column,
  );
}

class $$FruitsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $FruitsTable,
          Fruit,
          $$FruitsTableFilterComposer,
          $$FruitsTableOrderingComposer,
          $$FruitsTableAnnotationComposer,
          $$FruitsTableCreateCompanionBuilder,
          $$FruitsTableUpdateCompanionBuilder,
          (Fruit, BaseReferences<_$AppDatabase, $FruitsTable, Fruit>),
          Fruit,
          PrefetchHooks Function()
        > {
  $$FruitsTableTableManager(_$AppDatabase db, $FruitsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FruitsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FruitsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FruitsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> englishName = const Value.absent(),
                Value<String> image = const Value.absent(),
                Value<String> colorHex = const Value.absent(),
                Value<double> brixMin = const Value.absent(),
                Value<double> brixMax = const Value.absent(),
                Value<int> calorieKcalPer100g = const Value.absent(),
                Value<String> tcmNature = const Value.absent(),
                Value<String> peakSeason = const Value.absent(),
                Value<String> aliasJson = const Value.absent(),
                Value<String> vitaminsJson = const Value.absent(),
                Value<String> mineralsJson = const Value.absent(),
                Value<String> benefitsJson = const Value.absent(),
                Value<String> contraindicationsJson = const Value.absent(),
                Value<String> originsJson = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => FruitsCompanion(
                id: id,
                name: name,
                englishName: englishName,
                image: image,
                colorHex: colorHex,
                brixMin: brixMin,
                brixMax: brixMax,
                calorieKcalPer100g: calorieKcalPer100g,
                tcmNature: tcmNature,
                peakSeason: peakSeason,
                aliasJson: aliasJson,
                vitaminsJson: vitaminsJson,
                mineralsJson: mineralsJson,
                benefitsJson: benefitsJson,
                contraindicationsJson: contraindicationsJson,
                originsJson: originsJson,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                required String englishName,
                required String image,
                required String colorHex,
                required double brixMin,
                required double brixMax,
                required int calorieKcalPer100g,
                required String tcmNature,
                required String peakSeason,
                required String aliasJson,
                required String vitaminsJson,
                required String mineralsJson,
                required String benefitsJson,
                required String contraindicationsJson,
                required String originsJson,
                Value<int> rowid = const Value.absent(),
              }) => FruitsCompanion.insert(
                id: id,
                name: name,
                englishName: englishName,
                image: image,
                colorHex: colorHex,
                brixMin: brixMin,
                brixMax: brixMax,
                calorieKcalPer100g: calorieKcalPer100g,
                tcmNature: tcmNature,
                peakSeason: peakSeason,
                aliasJson: aliasJson,
                vitaminsJson: vitaminsJson,
                mineralsJson: mineralsJson,
                benefitsJson: benefitsJson,
                contraindicationsJson: contraindicationsJson,
                originsJson: originsJson,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$FruitsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $FruitsTable,
      Fruit,
      $$FruitsTableFilterComposer,
      $$FruitsTableOrderingComposer,
      $$FruitsTableAnnotationComposer,
      $$FruitsTableCreateCompanionBuilder,
      $$FruitsTableUpdateCompanionBuilder,
      (Fruit, BaseReferences<_$AppDatabase, $FruitsTable, Fruit>),
      Fruit,
      PrefetchHooks Function()
    >;
typedef $$RecommendationsTableCreateCompanionBuilder =
    RecommendationsCompanion Function({
      Value<int> id,
      required String cityId,
      required int month,
      required String period,
      required String fruitId,
      required int score,
      required String reason,
      required String locality,
    });
typedef $$RecommendationsTableUpdateCompanionBuilder =
    RecommendationsCompanion Function({
      Value<int> id,
      Value<String> cityId,
      Value<int> month,
      Value<String> period,
      Value<String> fruitId,
      Value<int> score,
      Value<String> reason,
      Value<String> locality,
    });

class $$RecommendationsTableFilterComposer
    extends Composer<_$AppDatabase, $RecommendationsTable> {
  $$RecommendationsTableFilterComposer({
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

  ColumnFilters<String> get cityId => $composableBuilder(
    column: $table.cityId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get month => $composableBuilder(
    column: $table.month,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get period => $composableBuilder(
    column: $table.period,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fruitId => $composableBuilder(
    column: $table.fruitId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get score => $composableBuilder(
    column: $table.score,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get reason => $composableBuilder(
    column: $table.reason,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get locality => $composableBuilder(
    column: $table.locality,
    builder: (column) => ColumnFilters(column),
  );
}

class $$RecommendationsTableOrderingComposer
    extends Composer<_$AppDatabase, $RecommendationsTable> {
  $$RecommendationsTableOrderingComposer({
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

  ColumnOrderings<String> get cityId => $composableBuilder(
    column: $table.cityId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get month => $composableBuilder(
    column: $table.month,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get period => $composableBuilder(
    column: $table.period,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fruitId => $composableBuilder(
    column: $table.fruitId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get score => $composableBuilder(
    column: $table.score,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get reason => $composableBuilder(
    column: $table.reason,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get locality => $composableBuilder(
    column: $table.locality,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$RecommendationsTableAnnotationComposer
    extends Composer<_$AppDatabase, $RecommendationsTable> {
  $$RecommendationsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get cityId =>
      $composableBuilder(column: $table.cityId, builder: (column) => column);

  GeneratedColumn<int> get month =>
      $composableBuilder(column: $table.month, builder: (column) => column);

  GeneratedColumn<String> get period =>
      $composableBuilder(column: $table.period, builder: (column) => column);

  GeneratedColumn<String> get fruitId =>
      $composableBuilder(column: $table.fruitId, builder: (column) => column);

  GeneratedColumn<int> get score =>
      $composableBuilder(column: $table.score, builder: (column) => column);

  GeneratedColumn<String> get reason =>
      $composableBuilder(column: $table.reason, builder: (column) => column);

  GeneratedColumn<String> get locality =>
      $composableBuilder(column: $table.locality, builder: (column) => column);
}

class $$RecommendationsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $RecommendationsTable,
          Recommendation,
          $$RecommendationsTableFilterComposer,
          $$RecommendationsTableOrderingComposer,
          $$RecommendationsTableAnnotationComposer,
          $$RecommendationsTableCreateCompanionBuilder,
          $$RecommendationsTableUpdateCompanionBuilder,
          (
            Recommendation,
            BaseReferences<
              _$AppDatabase,
              $RecommendationsTable,
              Recommendation
            >,
          ),
          Recommendation,
          PrefetchHooks Function()
        > {
  $$RecommendationsTableTableManager(
    _$AppDatabase db,
    $RecommendationsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RecommendationsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RecommendationsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RecommendationsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> cityId = const Value.absent(),
                Value<int> month = const Value.absent(),
                Value<String> period = const Value.absent(),
                Value<String> fruitId = const Value.absent(),
                Value<int> score = const Value.absent(),
                Value<String> reason = const Value.absent(),
                Value<String> locality = const Value.absent(),
              }) => RecommendationsCompanion(
                id: id,
                cityId: cityId,
                month: month,
                period: period,
                fruitId: fruitId,
                score: score,
                reason: reason,
                locality: locality,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String cityId,
                required int month,
                required String period,
                required String fruitId,
                required int score,
                required String reason,
                required String locality,
              }) => RecommendationsCompanion.insert(
                id: id,
                cityId: cityId,
                month: month,
                period: period,
                fruitId: fruitId,
                score: score,
                reason: reason,
                locality: locality,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$RecommendationsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $RecommendationsTable,
      Recommendation,
      $$RecommendationsTableFilterComposer,
      $$RecommendationsTableOrderingComposer,
      $$RecommendationsTableAnnotationComposer,
      $$RecommendationsTableCreateCompanionBuilder,
      $$RecommendationsTableUpdateCompanionBuilder,
      (
        Recommendation,
        BaseReferences<_$AppDatabase, $RecommendationsTable, Recommendation>,
      ),
      Recommendation,
      PrefetchHooks Function()
    >;
typedef $$FavoritesTableCreateCompanionBuilder =
    FavoritesCompanion Function({
      required String fruitId,
      required String addedAt,
      Value<int> rowid,
    });
typedef $$FavoritesTableUpdateCompanionBuilder =
    FavoritesCompanion Function({
      Value<String> fruitId,
      Value<String> addedAt,
      Value<int> rowid,
    });

class $$FavoritesTableFilterComposer
    extends Composer<_$AppDatabase, $FavoritesTable> {
  $$FavoritesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get fruitId => $composableBuilder(
    column: $table.fruitId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get addedAt => $composableBuilder(
    column: $table.addedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$FavoritesTableOrderingComposer
    extends Composer<_$AppDatabase, $FavoritesTable> {
  $$FavoritesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get fruitId => $composableBuilder(
    column: $table.fruitId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get addedAt => $composableBuilder(
    column: $table.addedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$FavoritesTableAnnotationComposer
    extends Composer<_$AppDatabase, $FavoritesTable> {
  $$FavoritesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get fruitId =>
      $composableBuilder(column: $table.fruitId, builder: (column) => column);

  GeneratedColumn<String> get addedAt =>
      $composableBuilder(column: $table.addedAt, builder: (column) => column);
}

class $$FavoritesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $FavoritesTable,
          Favorite,
          $$FavoritesTableFilterComposer,
          $$FavoritesTableOrderingComposer,
          $$FavoritesTableAnnotationComposer,
          $$FavoritesTableCreateCompanionBuilder,
          $$FavoritesTableUpdateCompanionBuilder,
          (Favorite, BaseReferences<_$AppDatabase, $FavoritesTable, Favorite>),
          Favorite,
          PrefetchHooks Function()
        > {
  $$FavoritesTableTableManager(_$AppDatabase db, $FavoritesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FavoritesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FavoritesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FavoritesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> fruitId = const Value.absent(),
                Value<String> addedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => FavoritesCompanion(
                fruitId: fruitId,
                addedAt: addedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String fruitId,
                required String addedAt,
                Value<int> rowid = const Value.absent(),
              }) => FavoritesCompanion.insert(
                fruitId: fruitId,
                addedAt: addedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$FavoritesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $FavoritesTable,
      Favorite,
      $$FavoritesTableFilterComposer,
      $$FavoritesTableOrderingComposer,
      $$FavoritesTableAnnotationComposer,
      $$FavoritesTableCreateCompanionBuilder,
      $$FavoritesTableUpdateCompanionBuilder,
      (Favorite, BaseReferences<_$AppDatabase, $FavoritesTable, Favorite>),
      Favorite,
      PrefetchHooks Function()
    >;
typedef $$UserPrefsTableCreateCompanionBuilder =
    UserPrefsCompanion Function({
      required String key,
      required String value,
      Value<int> rowid,
    });
typedef $$UserPrefsTableUpdateCompanionBuilder =
    UserPrefsCompanion Function({
      Value<String> key,
      Value<String> value,
      Value<int> rowid,
    });

class $$UserPrefsTableFilterComposer
    extends Composer<_$AppDatabase, $UserPrefsTable> {
  $$UserPrefsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );
}

class $$UserPrefsTableOrderingComposer
    extends Composer<_$AppDatabase, $UserPrefsTable> {
  $$UserPrefsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$UserPrefsTableAnnotationComposer
    extends Composer<_$AppDatabase, $UserPrefsTable> {
  $$UserPrefsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);
}

class $$UserPrefsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $UserPrefsTable,
          UserPref,
          $$UserPrefsTableFilterComposer,
          $$UserPrefsTableOrderingComposer,
          $$UserPrefsTableAnnotationComposer,
          $$UserPrefsTableCreateCompanionBuilder,
          $$UserPrefsTableUpdateCompanionBuilder,
          (UserPref, BaseReferences<_$AppDatabase, $UserPrefsTable, UserPref>),
          UserPref,
          PrefetchHooks Function()
        > {
  $$UserPrefsTableTableManager(_$AppDatabase db, $UserPrefsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UserPrefsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UserPrefsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UserPrefsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> key = const Value.absent(),
                Value<String> value = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => UserPrefsCompanion(key: key, value: value, rowid: rowid),
          createCompanionCallback:
              ({
                required String key,
                required String value,
                Value<int> rowid = const Value.absent(),
              }) => UserPrefsCompanion.insert(
                key: key,
                value: value,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$UserPrefsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $UserPrefsTable,
      UserPref,
      $$UserPrefsTableFilterComposer,
      $$UserPrefsTableOrderingComposer,
      $$UserPrefsTableAnnotationComposer,
      $$UserPrefsTableCreateCompanionBuilder,
      $$UserPrefsTableUpdateCompanionBuilder,
      (UserPref, BaseReferences<_$AppDatabase, $UserPrefsTable, UserPref>),
      UserPref,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$CitiesTableTableManager get cities =>
      $$CitiesTableTableManager(_db, _db.cities);
  $$FruitsTableTableManager get fruits =>
      $$FruitsTableTableManager(_db, _db.fruits);
  $$RecommendationsTableTableManager get recommendations =>
      $$RecommendationsTableTableManager(_db, _db.recommendations);
  $$FavoritesTableTableManager get favorites =>
      $$FavoritesTableTableManager(_db, _db.favorites);
  $$UserPrefsTableTableManager get userPrefs =>
      $$UserPrefsTableTableManager(_db, _db.userPrefs);
}
