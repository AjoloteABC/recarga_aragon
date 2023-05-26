import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:line_icons/line_icons.dart';
import 'package:unam_movil/pages/my_user_info.dart';
import 'package:unam_movil/pages/user_info_screen.dart';
import 'package:unam_movil/pages/my_map.dart';
import 'package:unam_movil/pages/my_nfc.dart';
import 'package:unam_movil/pages/my_profile.dart';
// La informacion del usuario una vez iniciada sesion

class MyNavigationBar extends StatefulWidget {
  const MyNavigationBar({Key? key, required User user})
      : _user = user,
        super(key: key);

  final User _user;

  @override
  _MyNavigationBarState createState() => _MyNavigationBarState();
}

class _MyNavigationBarState extends State<MyNavigationBar> {
  int _selectedIndex = 0;

  static List<Widget> _widgetOptions(User user) {
    return [
      UserInfoScreen(user: user),
      MyNFC(),
      MyMap(),
      MyProfile(),
      //MyInfo(user: user),

    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: _widgetOptions(widget._user)[_selectedIndex]),
      bottomNavigationBar: Container(
        color: Colors.black,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 20.0),
          child: GNav(
            backgroundColor: Colors.black,
            color: Colors.white,
            activeColor: Colors.white,
            tabBackgroundColor: Colors.grey.shade800,
            gap: 8,
            padding: EdgeInsets.all(16),
            tabs: [
              GButton(icon: Icons.home, text: 'Inicio'),
              GButton(icon: Icons.nfc, text: 'Recarga'),
              GButton(icon: Icons.map, text: 'Mapa'),
              GButton(
                iconSize: 24,
                icon: LineIcons.user,
                leading: CircleAvatar(
                  radius: 12,
                  backgroundImage: NetworkImage(widget._user.photoURL!),
                ),
                text: 'Perfil',
              ),
            ],
            selectedIndex: _selectedIndex,
            onTabChange: (index) {
              setState(() {
                _selectedIndex = index;
              });
            },
          ),
        ),
      ),
    );
  }
}
