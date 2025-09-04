import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kabtour_social_media/globals.dart';

import '../blocs/authentication_bloc.dart';
import 'add_content_page.dart';
import 'home_page.dart';
import 'login_page.dart';
import 'profile_page.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedPageIndex = 0;

  late PageController _pageController;

  List<Widget> get _pages => [
    HomePage(key: PageStorageKey('home')),
    AddContentPage(key: PageStorageKey('add')),
    ProfilePage(key: PageStorageKey('profile')),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _selectedPageIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );

    setState(() {
      _selectedPageIndex = index;

      if (index != 1) {
        _pages[1] = AddContentPage(key: UniqueKey());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthenticationBloc, AuthenticationState>(
      listener: (context, state) {
        if (!mounted) return;

        if (state is AuthenticationUnauthenticated) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const LoginPage()),
            (_) => false,
          );
        }
      },
      child: Scaffold(
        body: SafeArea(
          child: PageView(
            controller: _pageController,
            physics: const BouncingScrollPhysics(),
            onPageChanged: (index) {
              setState(() {
                _selectedPageIndex = index;
      
                if (index != 1) {
                  _pages[1] = AddContentPage(key: UniqueKey());
                }
              });
            },
            children: _pages,
          ),
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedPageIndex,
          onTap: _onItemTapped,
          backgroundColor: Colors.white,
          selectedItemColor: kabtourGreen,
          unselectedItemColor: Colors.grey[500],
          showSelectedLabels: false,
          showUnselectedLabels: false,
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined, size: 28),
              activeIcon: Icon(Icons.home, size: 28),
              label: "Home",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.add_box_outlined, size: 28),
              activeIcon: Icon(Icons.add_box, size: 28),
              label: "Add"
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline, size: 28),
              activeIcon: Icon(Icons.person, size: 28),
              label: "Profile",
            ),
          ],
        ),
      ),
    );
  }
}
