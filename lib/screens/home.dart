import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/app_state_manager.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../auth.dart';
import 'export_screens.dart';

class Home extends StatefulWidget {
  const Home({
    super.key,
    required this.currentTab,
    required this.title,
    });

  final int currentTab;
  final String title;

  @override
  HomeState createState() => HomeState();
}

class HomeState extends State<Home> {
  static List<Widget> pages = <Widget>[
    PopularScreen(),
    const SearchScreen(),
    const ProfileScreen(),
    
  ];

  final User? user = Auth().currentUser;

  static List<String> titles = <String>[
    'Popular Movies',
    'Explore Movies',
    'Your Profile' 
  ];

  Future<void> signOut() async {
    await Auth().signOut();
  }

  Widget _signOutButton(){
    return IconButton(
        icon: const Icon(Icons.logout),
            onPressed: () {
              Provider.of<AppStateManager>(context, listen: false).logout();
              signOut();
            },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(titles[widget.currentTab],
          style: Theme.of(context).textTheme.headline6,
        ),
        actions: <Widget>[
          _signOutButton(),        
        ],
      ),
      body: IndexedStack(index: widget.currentTab, children: pages),
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Theme.of(context).textSelectionTheme.selectionColor,
        currentIndex: widget.currentTab,
        onTap: (index) {
          Provider.of<AppStateManager>(context, listen: false).goToTab(index);
          context.goNamed('home', params: {'tab': '$index'});
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.movie_creation_rounded),
            label: 'Popular Movies',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Search Movies',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  Widget profileButton(int currentTab) {
    return Padding(
      padding: const EdgeInsets.only(right: 16.0),
      child: GestureDetector(
        child: const CircleAvatar(
          backgroundColor: Colors.transparent,
        ),
        onTap: () {
          // TODO: Navigate to profile screen
        },
      ),
    );
  }
}
