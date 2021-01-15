import 'dart:io';

import 'package:filesize/filesize.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gi_weekly_material_tracker/util.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  String _location = "Loading", _cacheSize = "Loading", _version = "Loading";
  bool _darkMode = false;
  int _cacheFiles = 0;

  SharedPreferences _prefs;

  void _refresh() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    Map<String, int> _files = {"fileNum": 0, "size": 0};

    PackageInfo pkgInfo = await PackageInfo.fromPlatform();
    String version = pkgInfo.version, build = pkgInfo.buildNumber;
    if (!kIsWeb) {
      Directory dir = await getTemporaryDirectory();
      Directory _cacheDir = dir;
      _files = _dirStatSync(_cacheDir.path);
    }
    String type = (kIsWeb)
        ? "Web"
        : (Platform.isAndroid)
            ? "Android"
            : (Platform.isIOS)
                ? 'iOS'
                : "Others";

    setState(() {
      _prefs = pref;
      _location = _prefs.getString("location") ?? "Asia";
      _darkMode = _prefs.getBool("dark_mode") ?? false;
      _cacheFiles = _files["fileNum"];
      _cacheSize = filesize(_files["size"]);
      _version = "Version: $version build $build ($type)";
    });
  }

  @override
  Widget build(BuildContext context) {
    _refresh();
    return Scaffold(
      appBar: AppBar(title: Text("Settings")),
      body: SettingsList(
        sections: [
          SettingsSection(
            title: 'User Login',
            titlePadding: const EdgeInsets.all(16),
            tiles: [
              SettingsTile(
                title: "Currently Logged in as",
                trailing: Text(""),
                subtitle: Util.getUserEmail(),
                leading: Icon(Icons.face),
              ),
            ],
          ),
          SettingsSection(
            title: "Settings",
            tiles: [
              SettingsTile.switchTile(
                title: "Dark Mode",
                leading: Icon(Icons.wb_sunny_outlined),
                onToggle: (bool value) {
                  _prefs.setBool("dark_mode", value).then((value) {
                    Util.themeNotifier.toggleTheme();
                  });
                  setState(() {
                    _darkMode = value;
                  });
                },
                switchValue: _darkMode,
              ),
              SettingsTile(
                title: "Game Server Location",
                subtitle: _location,
                leading: Icon(MdiIcons.server),
                onPressed: (context) {
                  Get.to(RegionSettingsPage());
                },
              ),
              SettingsTile(
                title: "Cache",
                subtitle: "Currently using $_cacheSize ($_cacheFiles files)",
                trailing: Text(""),
                enabled: !kIsWeb,
                leading: Icon(Icons.cached_rounded),
              ),
              SettingsTile(
                title: "Clear Cache",
                leading: Icon(MdiIcons.trashCanOutline),
                enabled: !kIsWeb,
                onPressed: (context) {
                  _clearCache();
                },
              ),
            ],
          ),
          CustomSection(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 22, bottom: 8),
                  child: Text(
                    _version,
                    style: TextStyle(color: Color(0xFF777777)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _clearCache() async {
    Directory tmp = await getTemporaryDirectory();
    List<FileSystemEntity> files = tmp.listSync();
    files.forEach((file) async {
      await file.delete(recursive: true);
    });
    Util.showSnackbarQuick(context, "Cache Cleared");
    _refresh();
  }

  Map<String, int> _dirStatSync(String dirPath) {
    int fileNum = 0;
    int totalSize = 0;
    var dir = Directory(dirPath);
    try {
      if (dir.existsSync()) {
        dir
            .listSync(recursive: true, followLinks: false)
            .forEach((FileSystemEntity entity) {
          if (entity is File) {
            fileNum++;
            totalSize += entity.lengthSync();
          }
        });
      }
    } catch (e) {
      print(e.toString());
    }

    return {'fileNum': fileNum, 'size': totalSize};
  }
}

class RegionSettingsPage extends StatefulWidget {
  @override
  _RegionSettingsPageState createState() => _RegionSettingsPageState();
}

class _RegionSettingsPageState extends State<RegionSettingsPage> {
  String _regionKey;
  SharedPreferences _prefs;

  @override
  void initState() {
    super.initState();
    SharedPreferences.getInstance().then((value) {
      setState(() {
        _prefs = value;
        _regionKey = value.getString("location") ?? "Asia";
      });
    });
  }

  Widget _buildBody() {
    if (_regionKey == null) return Util.centerLoadingCircle("Getting Region");
    return SettingsList(
      sections: [
        SettingsSection(
          tiles: [
            SettingsTile(
              title: "Asia",
              subtitle: "GMT+8",
              trailing: trailingWidget("Asia"),
              onPressed: (context) {
                changeRegion("Asia");
              },
            ),
            SettingsTile(
              title: "America",
              subtitle: "GMT-5",
              trailing: trailingWidget("NA"),
              onPressed: (context) {
                changeRegion("NA");
              },
            ),
            SettingsTile(
              title: "Europe",
              subtitle: "GMT+1",
              trailing: trailingWidget("EU"),
              onPressed: (context) {
                changeRegion("EU");
              },
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Game Server Location")),
      body: _buildBody(),
    );
  }

  Widget trailingWidget(String region) {
    return Radio(
      toggleable: false,
      autofocus: false,
      value: region,
      onChanged: (ig) {},
      groupValue: _regionKey,
    );
  }

  void changeRegion(String region) async {
    await _prefs.setString("location", region);
    setState(() {
      _regionKey = region;
    });
  }
}
