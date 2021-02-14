import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_image/firebase_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gi_weekly_material_tracker/models/characterdata.dart';
import 'package:gi_weekly_material_tracker/models/commondata.dart';
import 'package:gi_weekly_material_tracker/models/materialdata.dart';
import 'package:gi_weekly_material_tracker/models/weapondata.dart';
import 'package:gi_weekly_material_tracker/util.dart';
import 'package:octo_image/octo_image.dart';
import 'package:transparent_image/transparent_image.dart';

final FirebaseFirestore _db = FirebaseFirestore.instance;

class GridData {
  static final Map<String, Map<String, CommonData>> _staticData = {};
  static final Map<String, bool> _downloading = {};

  static Color getRarityColor(int rarity) {
    switch (rarity) {
      case 1:
        return Color(0xFF72778b);
      case 2:
        return Color(0xFF2a9072);
      case 3:
        return Color(0xFF5180cc);
      case 4:
        return Color(0xFFa256e1);
      case 5:
        return Color(0xFFbd6932);
      default:
        return Colors.black;
    }
  }

  static Widget getAscensionImage(
    String itemKey,
    Map<String, MaterialDataCommon> data,
  ) {
    if (itemKey == null) return Image.memory(kTransparentImage, height: 16);

    return getImageAssetFromFirebase(
      data[itemKey].image,
      height: 16,
    );
  }

  static Color getCountColor(int current, int max) {
    return (current >= max) ? Colors.greenAccent : Colors.white;
  }

  static Color getCountColorBW(int current, int max) {
    return (current >= max)
        ? Colors.green
        : (Util.themeNotifier.isDarkMode())
            ? Colors.white
            : Colors.black;
  }

  static String getElementImageRef(String element) {
    switch (element.toLowerCase()) {
      case 'geo':
        return 'assets/images/elements/Element_Geo.png';
      case 'anemo':
        return 'assets/images/elements/Element_Anemo.png';
      case 'cryo':
        return 'assets/images/elements/Element_Cryo.png';
      case 'dendro':
        return 'assets/images/elements/Element_Dendro.png';
      case 'electro':
        return 'assets/images/elements/Element_Electro.png';
      case 'hydro':
        return 'assets/images/elements/Element_Hydro.png';
      case 'pyro':
        return 'assets/images/elements/Element_Pyro.png';
    }

    return null;
  }

  static void setStaticData(String type, QuerySnapshot snapshot) {
    if (snapshot == null) return;
    print('Updating $type static data in memory');
    var data = <String, dynamic>{};
    snapshot.docs.forEach((element) {
      data.putIfAbsent(element.id, () => element.data());
    });
    switch (type) {
      case 'characters':
        _staticData[type] = CharacterData.getList(data);
        break;
      case 'weapons':
        _staticData[type] = WeaponData.getList(data);
        break;
      case 'materials':
        _staticData[type] = MaterialDataCommon.getList(data);
        break;
    }
  }

  static Future<Map<String, MaterialDataCommon>>
      retrieveMaterialsMapData() async =>
          (await _retrieveStaticData('materials'))
              as Map<String, MaterialDataCommon>;

  static Future<Map<String, WeaponData>> retrieveWeaponsMapData() async =>
      (await _retrieveStaticData('weapons')) as Map<String, WeaponData>;

  static Future<Map<String, CharacterData>> retrieveCharactersMapData() async =>
      (await _retrieveStaticData('characters')) as Map<String, CharacterData>;

  static String getDayString(int day) {
    switch (day) {
      case 1:
        return 'Mon';
      case 2:
        return 'Tue';
      case 3:
        return 'Wed';
      case 4:
        return 'Thu';
      case 5:
        return 'Fri';
      case 6:
        return 'Sat';
      case 7:
        return 'Sun';
    }

    return 'Unknown';
  }

  static String getRomanNumberArray(int number) {
    switch (number) {
      case 0:
        return 'I';
      case 1:
        return 'II';
      case 2:
        return 'III';
      case 3:
        return 'IV';
      case 4:
        return 'V';
      case 5:
        return 'VI';
      case 6:
        return 'VII';
      case 7:
        return 'VIII';
      case 8:
        return 'IX';
      case 9:
        return 'X';
      case 10:
        return 'XI';
      case -1:
        return ''; // Disabled
      default:
        return (number + 1).toString();
    }
  }

  static Widget getImageAssetFromFirebase(imageRef, {double height}) {
    if (imageRef == null) return Image.memory(kTransparentImage);

    return FutureBuilder(
      future: Util.getFirebaseStorageUrl(imageRef),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: SizedBox(
                height: height,
                width: height,
                child: OctoImage(
                  placeholderBuilder: (context) => SizedBox(
                    child: CircularProgressIndicator(),
                    height: height,
                    width: height,
                  ),
                  errorBuilder: (context, obj, trace) => Icon(Icons.error),
                  image: _getFirebaseImage(snapshot.data),
                  placeholderFadeInDuration: Duration(seconds: 2),
                ),
              ),
            ),
          );
        }

        return Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(8),
              child: Center(
                child: SizedBox(
                  child: CircularProgressIndicator(),
                  height: height,
                  width: height,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Image.memory(
                kTransparentImage,
                height: height,
              ),
            ),
          ],
        );
      },
    );
  }

  static Widget getGridData(CommonData data) {
    return Card(
      color: getRarityColor(data.rarity),
      child: GridTile(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Stack(
            children: [
              getImageAssetFromFirebase(data.image),
            ],
          ),
        ),
        footer: Padding(
          padding: const EdgeInsets.all(2),
          child: Text(
            data.name,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  static void launchWikiUrl(BuildContext context, CommonData data) async {
    if (!await Util.launchWebPage(
      data.wiki,
      rarityColor: GridData.getRarityColor(data.rarity),
    )) {
      Util.showSnackbarQuick(
        context,
        'Wiki Page not available for ${data.name}',
      );
    }
  }

  static List<Widget> generateInfoLine(String textData, IconData icon) {
    return [
      Padding(
        padding: const EdgeInsets.all(8),
        child: Row(
          children: [
            Icon(icon),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: 8, right: 8),
                child: Text(textData.replaceAll('\\n', '\n')),
              ),
            ),
          ],
        ),
      ),
      Divider(),
    ];
  }

  static List<Widget> getAscensionMaterialDataWidgets(
    int qty,
    String name,
    Map<String, MaterialDataCommon> data,
  ) {
    return [
      getAscensionImage(name, data),
      Text((qty == 0) ? '' : qty.toString()),
      Spacer(),
    ];
  }

  static Future<Map<String, CommonData>> _retrieveStaticData(
    String type,
  ) async {
    if (_downloading.containsKey(type) && _downloading[type]) {
      // Wait for processing to end
      return Future.delayed(
        const Duration(seconds: 1),
        () => _retrieveStaticData(type),
      );
    }
    if (!_staticData.containsKey(type)) {
      _downloading[type] = true;
      print('Retrieving $type static data from Firestore');
      var snapshot = await _db.collection(type).get();
      _downloading[type] = false;
      setStaticData(type, snapshot);
    }

    return _staticData[type];
  }

  static ImageProvider _getFirebaseImage(String url) {
    return (kIsWeb) ? CachedNetworkImageProvider(url) : FirebaseImage(url);
  }
}
