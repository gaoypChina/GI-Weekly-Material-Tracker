import 'package:gi_weekly_material_tracker/models/commondata.dart';

class MaterialDataCommon extends CommonData {
  String? type;
  String? innerType;
  String? obtained;

  MaterialDataCommon({
    image,
    rarity,
    this.type,
    this.innerType,
    name,
    description,
    wiki,
    this.obtained,
    released,
  }) : super(
          name: name,
          rarity: rarity,
          image: image,
          description: description,
          wiki: wiki,
          released: released,
        );

  factory MaterialDataCommon.fromJson(Map<String, dynamic> parsedJson) {
    return MaterialDataCommon(
      image: parsedJson['image'],
      rarity: parsedJson['rarity'],
      type: parsedJson['type'],
      innerType: parsedJson['innerType'],
      name: parsedJson['name'],
      description: parsedJson['description'],
      wiki: parsedJson['wiki'],
      obtained: parsedJson['obtained'],
      released: parsedJson['released'],
    );
  }

  static Map<String, MaterialDataCommon> getList(
    Map<String, dynamic> listString,
  ) {
    var fin = <String, MaterialDataCommon>{};
    listString.forEach((key, value) {
      switch (value['innerType']) {
        case 'mob_drops':
          fin.putIfAbsent(key, () => MaterialDataMob.fromJson(value));
          break;
        case 'domain_material':
          fin.putIfAbsent(key, () => MaterialDataDomains.fromJson(value));
          break;
        default:
          fin.putIfAbsent(key, () => MaterialDataCommon.fromJson(value));
          break;
      }
    });

    return fin;
  }
}

class MaterialDataMob extends MaterialDataCommon {
  List<String>? enemies;

  MaterialDataMob({
    image,
    rarity,
    type,
    innerType,
    name,
    description,
    obtained,
    wiki,
    this.enemies,
    released,
  }) : super(
          image: image,
          rarity: rarity,
          type: type,
          innerType: innerType,
          name: name,
          description: description,
          wiki: wiki,
          obtained: obtained,
          released: released,
        );

  factory MaterialDataMob.fromJson(Map<String, dynamic> parsedJson) {
    return MaterialDataMob(
      image: parsedJson['image'],
      rarity: parsedJson['rarity'],
      type: parsedJson['type'],
      innerType: parsedJson['innerType'],
      name: parsedJson['name'],
      description: parsedJson['description'],
      obtained: parsedJson['obtained'],
      wiki: parsedJson['wiki'],
      enemies: (parsedJson['enemies'] as List<dynamic>)
          .map((e) => e.toString())
          .toSet()
          .toList(),
      released: parsedJson['released'],
    );
  }
}

class MaterialDataDomains extends MaterialDataCommon {
  List<int>? days;

  MaterialDataDomains({
    image,
    rarity,
    type,
    innerType,
    name,
    description,
    obtained,
    wiki,
    this.days,
    released,
  }) : super(
          image: image,
          rarity: rarity,
          type: type,
          innerType: innerType,
          name: name,
          description: description,
          wiki: wiki,
          obtained: obtained,
          released: released,
        );

  factory MaterialDataDomains.fromJson(Map<String, dynamic> parsedJson) {
    return MaterialDataDomains(
      image: parsedJson['image'],
      rarity: parsedJson['rarity'],
      type: parsedJson['type'],
      innerType: parsedJson['innerType'],
      name: parsedJson['name'],
      description: parsedJson['description'],
      obtained: parsedJson['obtained'],
      wiki: parsedJson['wiki'],
      days: (parsedJson['days'] as List<dynamic>)
          .map((e) => int.tryParse(e.toString()) ?? 0)
          .toSet()
          .toList(),
      released: parsedJson['released'],
    );
  }
}
