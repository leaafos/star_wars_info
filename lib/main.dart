import 'package:flutter/material.dart';
import 'screens/films_screen.dart';
import 'screens/planets_screen.dart';
import 'screens/characters_screen.dart';

void main() => runApp(const StarWarsApp());

class StarWarsApp extends StatelessWidget {
  const StarWarsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Star Wars Info',
      theme: ThemeData.dark(),
      home: const ResponsiveHome(),
    );
  }
}

class ResponsiveHome extends StatefulWidget {
  const ResponsiveHome({super.key});

  @override
  State<ResponsiveHome> createState() => _ResponsiveHomeState();
}

class _ResponsiveHomeState extends State<ResponsiveHome> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    FilmsScreen(),
    PlanetsScreen(),
    CharactersScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Détecter la largeur de l'écran
    final screenWidth = MediaQuery.of(context).size.width;
    final bool isWide = screenWidth > 600; // Largeur pour afficher le NavigationRail
    final bool showLabels = screenWidth > 800; // Afficher les labels seulement sur grand écran

    return Scaffold(
      appBar: AppBar(title: const Text('Star Wars Info')),
      body: Row(
        children: [
          // Afficher le NavigationRail uniquement sur grands écrans
          if (isWide)
            NavigationRail(
              selectedIndex: _selectedIndex,
              onDestinationSelected: _onItemTapped,
              labelType: showLabels
                  ? NavigationRailLabelType.all // Affiche les labels sur grands écrans
                  : NavigationRailLabelType.none, // Ne montre pas les labels sur petits écrans
              destinations: [
                NavigationRailDestination(
                  icon: const Icon(Icons.movie),
                  label: const Text('Films'),
                ),
                NavigationRailDestination(
                  icon: const Icon(Icons.public),
                  label: const Text('Planètes'),
                ),
                NavigationRailDestination(
                  icon: const Icon(Icons.people),
                  label: const Text('Personnages'),
                ),
              ],
            ),
          Expanded(child: _screens[_selectedIndex]), // Affiche le contenu sélectionné
        ],
      ),
      bottomNavigationBar: isWide
          ? null // Pas de BottomNavigationBar sur grands écrans
          : BottomNavigationBar(
              currentIndex: _selectedIndex,
              onTap: _onItemTapped,
              selectedItemColor: Colors.yellow,
              backgroundColor: Colors.black,
              items: const [
                BottomNavigationBarItem(icon: Icon(Icons.movie), label: 'Films'),
                BottomNavigationBarItem(icon: Icon(Icons.public), label: 'Planètes'),
                BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Personnages'),
              ],
            ),
    );
  }
  }
