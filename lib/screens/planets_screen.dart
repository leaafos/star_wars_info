import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class PlanetsScreen extends StatefulWidget {
  @override
  _PlanetsScreenState createState() => _PlanetsScreenState();
}

class _PlanetsScreenState extends State<PlanetsScreen> {
  List planets = [];

  Future<void> fetchPlanets() async {
    final response = await http.get(Uri.parse('https://swapi.tech/api/planets?page=1&limit=10'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      List tempPlanets = [];

      for (var planet in data['results']) {
        final detailResponse = await http.get(Uri.parse(planet['url']));
        if (detailResponse.statusCode == 200) {
          final planetDetails = json.decode(detailResponse.body);
          final props = planetDetails['result']['properties'];

          tempPlanets.add({
            'name': planet['name'],
            'climate': props['climate'],
            'terrain': props['terrain'],
            'population': props['population'],
            'diameter': props['diameter'],
            'gravity': props['gravity'],
            'orbital_period': props['orbital_period'],
            'rotation_period': props['rotation_period'],
            'surface_water': props['surface_water'],
          });
        }
      }

      setState(() {
        planets = tempPlanets;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    fetchPlanets();
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

    return planets.isEmpty
        ? Center(child: CircularProgressIndicator())
        : GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 0.75,
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
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        planet['name'],
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.green[700],
                        ),
                      ),
                      SizedBox(height: 10),
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
          );
  }
}
