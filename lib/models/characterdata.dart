import 'package:gi_weekly_material_tracker/models/commondata.dart';

class CharacterData extends CommonData {
  String affiliation;
  String birthday;
  String constellation;
  String element;
  String gender;
  String genshinGGPath;
  String introduction;
  String nation;
  String weapon;
  Map<String, CharacterAscension> ascension;

  CharacterData(
      {this.affiliation,
      this.birthday,
      this.constellation,
      description,
      this.element,
      this.gender,
      this.genshinGGPath,
      image,
      this.introduction,
      name,
      this.nation,
      rarity,
      this.weapon,
      this.ascension})
      : super(
            image: image, name: name, rarity: rarity, description: description);

  factory CharacterData.fromJson(Map<String, dynamic> parsedJson) {
    return CharacterData(
      image: parsedJson['image'],
      gender: parsedJson['gender'],
      birthday: parsedJson['birthday'],
      name: parsedJson['name'],
      description: parsedJson['description'],
      nation: parsedJson['nation'],
      weapon: parsedJson['weapon'],
      rarity: parsedJson['rarity'],
      affiliation: parsedJson['affiliation'],
      constellation: parsedJson['constellation'],
      introduction: parsedJson['introduction'],
      genshinGGPath: parsedJson['genshinggpath'],
      element: parsedJson['element'],
      ascension: CharacterAscension.getFromMap(parsedJson['ascension']),
    );
  }

  static Map<String, CharacterData> getList(Map<String, dynamic> listString) {
    Map<String, CharacterData> _fin = new Map();
    listString.forEach((key, value) {
      _fin.putIfAbsent(key, () => CharacterData.fromJson(value));
    });
    return _fin;
  }
}

class CharacterAscension extends CommonAscension {
  String material4;
  int material4Qty;

  CharacterAscension(
      {level,
      material1,
      material1Qty,
      material2,
      material2Qty,
      material3,
      material3Qty,
      this.material4,
      this.material4Qty,
      mora})
      : super(
            level: level,
            mora: mora,
            material1: material1,
            material1Qty: material1Qty,
            material2: material2,
            material2Qty: material2Qty,
            material3: material3,
            material3Qty: material3Qty);

  factory CharacterAscension.fromJson(Map<String, dynamic> parsedJson) {
    return CharacterAscension(
      material2Qty: parsedJson['material2qty'],
      material1: parsedJson['material1'],
      material1Qty: parsedJson['material1qty'],
      mora: parsedJson['mora'],
      material2: parsedJson['material2'],
      level: parsedJson['level'],
      material4: parsedJson['material4'],
      material4Qty: parsedJson['material4qty'],
      material3Qty: parsedJson['material3qty'],
      material3: parsedJson['material3'],
    );
  }

  static Map<String, CharacterAscension> getFromMap(
      Map<String, dynamic> ascend) {
    Map<String, CharacterAscension> _fin = new Map();
    if (ascend.containsKey("1"))
      _fin.putIfAbsent("1", () => new CharacterAscension.fromJson(ascend['1']));
    if (ascend.containsKey("2"))
      _fin.putIfAbsent("2", () => new CharacterAscension.fromJson(ascend['2']));
    if (ascend.containsKey("3"))
      _fin.putIfAbsent("3", () => new CharacterAscension.fromJson(ascend['3']));
    if (ascend.containsKey("4"))
      _fin.putIfAbsent("4", () => new CharacterAscension.fromJson(ascend['4']));
    if (ascend.containsKey("5"))
      _fin.putIfAbsent("5", () => new CharacterAscension.fromJson(ascend['5']));
    if (ascend.containsKey("6"))
      _fin.putIfAbsent("6", () => new CharacterAscension.fromJson(ascend['6']));
    return _fin;
  }
}
