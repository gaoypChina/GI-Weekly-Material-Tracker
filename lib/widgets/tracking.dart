import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:get/get.dart';
import 'package:gi_weekly_material_tracker/models/grid.dart';
import 'package:gi_weekly_material_tracker/models/tracker.dart';
import 'package:gi_weekly_material_tracker/placeholder.dart';
import 'package:gi_weekly_material_tracker/util.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

final FirebaseFirestore _db = FirebaseFirestore.instance;
final FirebaseAuth _auth = FirebaseAuth.instance;

class TabControllerWidget extends StatefulWidget {
  TabControllerWidget({Key key, @required this.tabController})
      : super(key: key);

  final TabController tabController;

  @override
  _TabControllerWidgetState createState() => _TabControllerWidgetState();
}

class _TabControllerWidgetState extends State<TabControllerWidget> {
  final List<Widget> _children = [
    TrackerPage(path: "boss_drops"),
    TrackerPage(path: "domain_forgery"),
    TrackerPage(path: "mob_drops"),
    TrackerPage(path: "local_speciality"),
    PlannerPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return TabBarView(controller: widget.tabController, children: _children);
  }
}

class TrackerPage extends StatefulWidget {
  TrackerPage({Key key, @required this.path}) : super(key: key);

  final String path;

  @override
  _TrackerPageState createState() => _TrackerPageState();
}

class _TrackerPageState extends State<TrackerPage> {
  final String _uid = _auth.currentUser.uid;
  Map<String, dynamic> _materialData;
  Map<String, dynamic> _weaponData;
  Map<String, dynamic> _characterData;

  @override
  void initState() {
    super.initState();

    GridData.retrieveMaterialsMapData().then((value) => {
          setState(() {
            _materialData = value;
          })
        });

    GridData.retrieveCharactersMapData().then((value) => {
          setState(() {
            _characterData = value;
          })
        });

    GridData.retrieveWeaponsMapData().then((value) => {
          setState(() {
            _weaponData = value;
          })
        });
  }

  void _itemClickedAction(String type, String key) {
    switch (type) {
      case "material":
        Get.toNamed('/materials', arguments: [key, _materialData[key]]);
        break; // TODO: Update with the dialog box and stuff
      case "weapon":
        Get.toNamed('/weapons', arguments: [key, _weaponData[key]]);
        break;
      case "character":
        Get.toNamed('/characters', arguments: [key, _characterData[key]]);
        break;
      default:
        Util.showSnackbarQuick(
            context, "Unsupported Action. Contact Developer");
        break;
    }
  }

  Widget _getSupportingWidget(String image, int ascension) {
    if (image == null) return Container();
    return Container(
      height: 48,
      width: 48,
      child: Stack(
        children: [
          GridData.getImageAssetFromFirebase(image, height: 32),
          Align(
            alignment: FractionalOffset.bottomLeft,
            child: Text(
              GridData.getRomanNumberArray(ascension - 1).toString(),
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    CollectionReference ref =
        _db.collection("tracking").doc(_uid).collection(widget.path);
    return StreamBuilder(
        stream: ref.snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Text("Error occurred getting snapshot");
          }

          if (snapshot.connectionState == ConnectionState.waiting ||
              _materialData == null ||
              _characterData == null ||
              _weaponData == null) {
            return Util.centerLoadingCircle("");
          }

          QuerySnapshot data = snapshot.data;
          final int _collectionLen = data.docs.length;

          if (_collectionLen > 0) {
            return ListView.builder(
              itemCount: _collectionLen,
              itemBuilder: (context, index) {
                Map<String, dynamic> _data = data.docs[index].data();
                String _dataId = data.docs[index].id;
                print(_data);
                Map<String, dynamic> _material = _materialData[_data["name"]];
                String extraImageRef;
                int extraAscensionRef = 0;
                var _ascendTier = _dataId.substring(_dataId.length - 1);
                if (_data["addData"] != null) {
                  // Grab image ref of extra data based on addedBy
                  if (_data["addedBy"] == "character") {
                    // Grab from character
                    extraImageRef = _characterData[_data["addData"]]["image"];
                    extraAscensionRef = int.tryParse(_ascendTier) ?? 0;
                  } else if (_data["addedBy"] == "weapon") {
                    // Grab from weapon
                    extraImageRef = _weaponData[_data["addData"]]["image"];
                    extraAscensionRef = int.tryParse(_ascendTier) ?? 0;
                  }
                }

                return Card(
                  color: GridData.getRarityColor(_material["rarity"]),
                  child: InkWell(
                    onTap: () => _itemClickedAction(
                        _data["addedBy"],
                        (_data["addedBy"] == "material")
                            ? _data["name"]
                            : _data["addData"]),
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          GridData.getImageAssetFromFirebase(_material["image"],
                              height: 48),
                          Container(
                            width: MediaQuery.of(context).size.width - 180,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Text(
                                  _material["name"],
                                  style: TextStyle(
                                      fontSize: 20, color: Colors.white),
                                ),
                                RatingBar.builder(
                                  ignoreGestures: true,
                                  itemCount: 5,
                                  itemSize: 12,
                                  unratedColor: Colors.transparent,
                                  initialRating: double.tryParse(
                                      _material['rarity'].toString()),
                                  itemBuilder: (context, _) =>
                                      Icon(Icons.star, color: Colors.amber),
                                  onRatingUpdate: (rating) {
                                    print(rating);
                                  },
                                ),
                                Text(
                                  _material["obtained"]
                                      .toString()
                                      .replaceAll("\\n", "\n"),
                                  style: TextStyle(
                                      fontSize: 11, color: Colors.white),
                                ),
                              ],
                            ),
                          ),
                          Spacer(),
                          Column(
                            children: [
                              Text(
                                "${_data["current"]}/${_data["max"]}",
                                style: TextStyle(
                                    fontSize: 18, color: Colors.white),
                              ),
                              Row(
                                children: [
                                  ButtonTheme(
                                    padding: EdgeInsets.symmetric(
                                        vertical: 4.0, horizontal: 8.0),
                                    //adds padding inside the button
                                    materialTapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                    //limits the touch area to the button area
                                    minWidth: 0,
                                    //wraps child's width
                                    height: 0,
                                    //wraps child's height
                                    child: FlatButton(
                                      onPressed: () =>
                                          TrackingData.decrementCount(_dataId,
                                              _data["type"], _data["current"]),
                                      child: Icon(Icons.remove,
                                          color: Colors.white),
                                    ),
                                  ),
                                  ButtonTheme(
                                    padding: EdgeInsets.symmetric(
                                        vertical: 4.0, horizontal: 8.0),
                                    //adds padding inside the button
                                    materialTapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                    //limits the touch area to the button area
                                    minWidth: 0,
                                    //wraps child's width
                                    height: 0,
                                    //wraps child's height
                                    child: FlatButton(
                                      onPressed: () =>
                                          TrackingData.incrementCount(
                                              _dataId,
                                              _data["type"],
                                              _data["current"],
                                              _data["max"]),
                                      child:
                                          Icon(Icons.add, color: Colors.white),
                                    ),
                                  ),
                                ],
                              ),
                              _getSupportingWidget(
                                  extraImageRef, extraAscensionRef),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          } else {
            return Center(
              child: Text("No items being tracked for this material category"),
            );
          }
        });
  }
}

class PlannerPage extends StatefulWidget {
  @override
  _PlannerPageState createState() => _PlannerPageState();
}

class _PlannerPageState extends State<PlannerPage> {
  final String _uid = _auth.currentUser.uid;
  Map<String, dynamic> _materialData;

  tz.TZDateTime _cDT, _beforeDT, _afterDT, _coffDT, _dbDT;

  @override
  void initState() {
    super.initState();
    GridData.retrieveMaterialsMapData().then((value) => {
          setState(() {
            _materialData = value;
          })
        });

    tz.initializeTimeZones();
    var gmt8 = tz.getLocation("Asia/Singapore");
    _cDT = tz.TZDateTime.now(gmt8);
    _beforeDT = tz.TZDateTime(gmt8, _cDT.year, _cDT.month, _cDT.day, 0, 0, 0, 0); // This day at 12am
    _dbDT = _cDT.subtract(Duration(days: 1));
    _afterDT = _beforeDT.add(Duration(days: 1)); // Next day at 12am
    _coffDT = tz.TZDateTime(gmt8, _cDT.year, _cDT.month, _cDT.day, 4, 0, 0, 0); // This day at 4am
  }

  @override
  Widget build(BuildContext context) {
    CollectionReference ref =
        _db.collection("tracking").doc(_uid).collection("domain_forgery");
    return StreamBuilder(
        stream: ref.snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Text("Error occurred getting snapshot");
          }

          if (snapshot.connectionState == ConnectionState.waiting ||
              _materialData == null) {
            return Util.centerLoadingCircle("");
          }

          QuerySnapshot data = snapshot.data;
          List<String> _finalDomainMaterials = data.docs
              .map((snapshot) => snapshot.data()["name"].toString())
              .toSet()
              .toList();
          Map<int, Set<String>> _mappedData = {
            1: new Set(),
            2: new Set(),
            3: new Set(),
            4: new Set(),
            5: new Set(),
            6: new Set(),
            7: new Set(),
          };
          _finalDomainMaterials.forEach((domainMaterial) {
            List<dynamic> _daysForMaterial =
                _materialData[domainMaterial]["days"];
            _daysForMaterial.forEach((day) {
              _mappedData[day].add(domainMaterial);
            });
          });

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
                  child: Text("Day resets at 4am GMT+8 (Asia). US/EU times coming soon",
                    style: TextStyle(fontSize: 12),
                  ),
                ),
                ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: _mappedData.length,
                  itemBuilder: (context, index) {
                    int key = _mappedData.keys.elementAt(index);
                    List<String> _curData = _mappedData[key].toList();
                    return ListTile(
                      tileColor: _getTileColorIfCurrentDay(key),
                      title: Text(GridData.getDayString(key)),
                      subtitle: _getGridMaterials(_curData),
                    );
                  },
                ),
              ],
            ),
          );
        });
  }

  Color _getTileColorIfCurrentDay(int key) {
    bool currentDay = false;
    if (_cDT.isAfter(_coffDT) && _cDT.isBefore(_afterDT) && _cDT.weekday == key) currentDay = true;
    else if (_cDT.isBefore(_coffDT) && _cDT.isAfter(_beforeDT) && _dbDT.weekday == key) currentDay = true;

    if (currentDay) return Colors.lightGreen;
    else return Colors.transparent;
  }
  
  Widget _getGridMaterials(List<String> _curData) {
    if (_curData.isEmpty) return Text("Not tracking any domain materials for this day");
    return GridView.count(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      crossAxisCount: 3,
      children: _curData.map((materialId) {
        return GestureDetector(
          onTap: () => Get.toNamed('/materials',
              arguments: [materialId, _materialData[materialId]]),
          child: GridData.getGridData(_materialData[materialId]),
        );
      }).toList(),
    );
  }
}
