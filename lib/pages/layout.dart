import 'package:allspice_mobile/pages/recipe_page.dart';
import 'package:allspice_mobile/pages/settings_page.dart';
import 'package:allspice_mobile/pages/spice_page.dart';
import 'package:flutter/material.dart';

import '../main.dart';

class MyLayout extends StatefulWidget {
  MyLayout({Key? key}) : super(key: key);
  // final String title;

  @override
  _MyLayoutState createState() => _MyLayoutState();
}

class _MyLayoutState extends State<MyLayout> {
  int _currentIndex = 1;

  // final tabs = [
  //   Center(child: Text("Recipes")),
  //   Center(child: Text("Spices")),
  //   Center(child: Text("Settings")),
  // ];

  PageController _pageController = PageController(initialPage: 1);
  List<Widget> _screens = [
    RecipePage(),
    SpicePage(),
    SettingsPage(),
  ];

  void _onPageChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("AllSpice"),
        elevation: 1,
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/bg.png"),
            alignment: Alignment.bottomRight,
          ),
        ),
        child: PageView(
          controller: _pageController,
          children: _screens,
          onPageChanged: _onPageChanged,
          // physics: NeverScrollableScrollPhysics(),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        // backgroundColor: Colors.white,
        currentIndex: _currentIndex,
        elevation: 0,
        iconSize: 35.0,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: mainColor,
        items: [
          BottomNavigationBarItem(
            icon: Icon(
              Icons.menu_book,
            ),
            label: "",
            tooltip: "Recipes",
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.home,
            ),
            label: "",
            tooltip: "Spices",
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.settings,
            ),
            label: "",
            tooltip: "Settings",
          )
        ],
        onTap: (index) {
          // _pageController.jumpToPage(index);
          _pageController.animateToPage(index,
              duration: Duration(milliseconds: 400), curve: Curves.decelerate);
        },
      ),
    );
  }
}
