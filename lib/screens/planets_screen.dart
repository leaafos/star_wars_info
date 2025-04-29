import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class PlanetsScreen extends StatefulWidget {
  @override
  _PlanetsScreenState createState() => _PlanetsScreenState();
}

class _PlanetsScreenState extends State<PlanetsScreen> {
  List planets = [];
  String? nextPageUrl;
  bool isLoading = false;

  // Fonction pour charger les planètes à partir d'une page spécifique
  Future<void> fetchPlanets(String url) async {
    if (isLoading) return; // Empêche les appels multiples simultanés
    setState(() {
      isLoading = true;
    });

    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      setState(() {
        nextPageUrl = data['next']; // Mise à jour de l'URL de la page suivante
      });

      // Charger les informations détaillées de chaque planète de cette page
      List newPlanets = [];
      for (var planetData in data['results']) {
        var detailedPlanet = await fetchPlanetDetails(planetData['url']); // Détails supplémentaires
        newPlanets.add(detailedPlanet);
      }

      setState(() {
        planets.addAll(newPlanets); // Ajouter les nouvelles planètes à la liste
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
      throw Exception('Failed to load planets');
    }
  }

  // Fonction pour charger les détails complets d'une planète
  Future<Map> fetchPlanetDetails(String url) async {
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      var planetDetails = json.decode(response.body);
      return planetDetails['result']['properties'];
    } else {
      throw Exception('Failed to load planet details');
    }
  }

  @override
  void initState() {
    super.initState();
    fetchPlanets('https://swapi.tech/api/planets'); // Charger la première page de planètes
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    int crossAxisCount = 2;
    if (screenWidth > 1200) {
      crossAxisCount = 4;
    } else if (screenWidth > 800) {
      crossAxisCount = 3;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("Planets"),
      ),
      body: planets.isEmpty
          ? Center(child: CircularProgressIndicator())  // Indicateur de chargement si aucune planète n'est encore chargée
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      childAspectRatio: 1.0,
                    ),
                    itemCount: planets.length,
                    itemBuilder: (context, index) {
                      final planet = planets[index];
                      return Card(
                        elevation: 5,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        margin: EdgeInsets.all(10),
                        clipBehavior: Clip.antiAlias, // Ajouté pour gérer les débordements visuels
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            return SingleChildScrollView(
                              padding: const EdgeInsets.all(12.0),
                              child: ConstrainedBox(
                                constraints: BoxConstraints(
                                  minHeight: constraints.maxHeight,
                                  minWidth: constraints.maxWidth,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      planet['name'] ?? 'Unknown',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.green[700],
                                      ),
                                    ),
                                    SizedBox(height: 20),
                                    if (planet['climate'] != null)
                                      Text("Climate: ${planet['climate']}", style: TextStyle(color: Colors.grey[700])),
                                    if (planet['terrain'] != null)
                                      Text("Terrain: ${planet['terrain']}", style: TextStyle(color: Colors.grey[700])),
                                    if (planet['population'] != null)
                                      Text("Population: ${planet['population']}", style: TextStyle(color: Colors.grey[700])),
                                    if (planet['diameter'] != null)
                                      Text("Diameter: ${planet['diameter']} km", style: TextStyle(color: Colors.grey[700])),
                                    if (planet['gravity'] != null)
                                      Text("Gravity: ${planet['gravity']}", style: TextStyle(color: Colors.grey[700])),
                                    if (planet['orbital_period'] != null)
                                      Text("Orbital Period: ${planet['orbital_period']} days", style: TextStyle(color: Colors.grey[700])),
                                    if (planet['rotation_period'] != null)
                                      Text("Rotation Period: ${planet['rotation_period']} hours", style: TextStyle(color: Colors.grey[700])),
                                    if (planet['surface_water'] != null)
                                      Text("Water Surface: ${planet['surface_water']}%", style: TextStyle(color: Colors.grey[700])),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      );

                    },
                  ),
                ),
                if (nextPageUrl != null && !isLoading) // Si une autre page est disponible et qu'on ne charge pas déjà
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ElevatedButton(
                      onPressed: () {
                        if (nextPageUrl != null) {
                          fetchPlanets(nextPageUrl!);  // Charger la page suivante
                        }
                      },
                      child: Text("Charger plus"),
                    ),
                  ),
                if (isLoading)  // Afficher un indicateur de chargement pendant le chargement de la page suivante
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: CircularProgressIndicator(),
                  ),
              ],
            ),
    );
  }
}
