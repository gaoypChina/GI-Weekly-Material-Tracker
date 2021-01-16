import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gi_weekly_material_tracker/models/grid.dart';
import 'package:gi_weekly_material_tracker/widgets/characters.dart';
import 'package:gi_weekly_material_tracker/widgets/materials.dart';
import 'package:gi_weekly_material_tracker/widgets/tracking.dart';
import 'package:gi_weekly_material_tracker/widgets/weapons.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;

class MainNavigationPage extends StatefulWidget {
  MainNavigationPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MainNavigationPageState createState() => _MainNavigationPageState();
}

class _MainNavigationPageState extends State<MainNavigationPage>
    with TickerProviderStateMixin {
  int _currentIndex = 0;

  List<Widget> _children;

  final Map<int, List<Tab>> _tabs = {
    0: [
      Tab(text: "Boss"),
      Tab(text: "Domains"),
      Tab(text: "Monster"),
      Tab(text: "Local Speciality"),
      Tab(text: "Week Planner")
    ],
    1: [
      Tab(text: "All"),
      Tab(
        icon: Image.asset(
          GridData.getElementImageRef("Anemo"),
          height: 20,
        ),
      ),
      Tab(
        icon: Image.asset(
          GridData.getElementImageRef("Cryo"),
          height: 20,
        ),
      ),
      Tab(
        icon: Image.asset(
          GridData.getElementImageRef("Electro"),
          height: 20,
        ),
      ),
      Tab(
        icon: Image.asset(
          GridData.getElementImageRef("Geo"),
          height: 20,
        ),
      ),
      Tab(
        icon: Image.asset(
          GridData.getElementImageRef("Hydro"),
          height: 20,
        ),
      ),
      Tab(
        icon: Image.asset(
          GridData.getElementImageRef("Pyro"),
          height: 20,
        ),
      ),
    ]
  };
  Map<int, TabController> _tabControllers;

  Widget _showAppBar() {
    if (!_tabs.containsKey(_currentIndex)) return null;
    return TabBar(
        controller: _tabControllers[_currentIndex],
        tabs: _tabs[_currentIndex],
        isScrollable: true);
  }

  @override
  void initState() {
    super.initState();
    _tabControllers = {
      0: TabController(vsync: this, length: _tabs[0].length),
      1: TabController(vsync: this, length: _tabs[1].length),
    };
    _children = [
      TabControllerWidget(
        tabController: _tabControllers[0],
      ),
      CharacterTabControllerWidget(
        tabController: _tabControllers[1],
      ),
      WeaponListGrid(),
      MaterialListGrid(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
          bottom: _showAppBar(),
          actions: [
            IconButton(
              icon: Icon(MdiIcons.fileDocument),
              tooltip: "View Consolidated Material List",
              onPressed: () => Get.toNamed('/globalTracking'),
            ),
            PopupMenuButton(
              onSelected: _overflowMenuSelection,
              elevation: 2.0,
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: "exit",
                  child: Text('Logout'),
                ),
                PopupMenuItem(
                  value: "settings",
                  child: Text('Settings'),
                )
              ],
            )
          ],
        ),
        body: _children[_currentIndex],
        bottomNavigationBar: BottomNavigationBar(
          selectedItemColor: Colors.deepOrange,
          unselectedItemColor: Colors.grey,
          currentIndex: _currentIndex,
          onTap: _onTabTapped,
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Tracker',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.account_circle),
              label: 'Characters',
            ),
            BottomNavigationBarItem(
              icon: Icon(MdiIcons.sword),
              label: 'Weapons',
            ),
            BottomNavigationBarItem(
              icon: Icon(MdiIcons.diamondStone),
              label: 'Materials',
            )
          ],
        ));
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  void _overflowMenuSelection(String action) {
    print("Menu Overflow Action: $action");
    switch (action) {
      case 'exit':
        _signOut();
        break;
      default:
        Get.toNamed('/settings');
        break;
    }
  }

  void _signOut() async {
    await _auth.signOut();
    Get.offAllNamed('/'); // Go to login screem
  }
}
