import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'characters_screen.dart'; // Assurez-vous que ce fichier existe

class FilmsScreen extends StatefulWidget {
  @override
  _FilmsScreenState createState() => _FilmsScreenState();
}

class _FilmsScreenState extends State<FilmsScreen> {
  List films = [];
  Map<String, List<String>> filmCharactersCache = {}; // Cache pour les personnages
  Map<String, List<String>> filmPlanetsCache = {}; // Cache pour les planètes

  // Fonction pour récupérer les films depuis l'API
  Future<void> fetchFilms() async {
    try {
      final response = await http.get(Uri.parse('https://swapi.tech/api/films'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        List tempFilms = [];

        for (var film in data['result']) {
          final props = film['properties'];
          tempFilms.add({
            'title': props['title'],
            'director': props['director'],
            'producer': props['producer'],
            'release_date': props['release_date'],
            'characters': List<String>.from(props['characters'] ?? []), // Assurez-vous que c'est une liste de Strings
            'planets': List<String>.from(props['planets'] ?? []), // Assurez-vous que c'est une liste de Strings
          });
        }

        setState(() {
          films = tempFilms;
        });
      } else {
        throw Exception("Erreur lors de la récupération des films. Code : ${response.statusCode}");
      }
    } catch (e) {
      print("Erreur dans la récupération des films : $e");
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Erreur de connexion"),
            content: Text("Une erreur s'est produite lors de la récupération des films. Veuillez réessayer."),
            actions: <Widget>[
              TextButton(
                child: Text("OK"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }
  }

  // Fonction pour récupérer le nom du personnage en utilisant son URL
  Future<String> fetchCharacterName(String characterUrl) async {
    try {
      final fullUrl = characterUrl.startsWith('https://') 
          ? characterUrl 
          : 'https://swapi.tech/api' + characterUrl;

      final response = await http.get(Uri.parse(fullUrl));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['result']['properties']['name'];
      } else {
        throw Exception("Erreur lors de la récupération du personnage. Code : ${response.statusCode}");
      }
    } catch (e) {
      print("Erreur d'accès au personnage: $e");
      return 'Erreur d\'accès';  // En cas d'erreur de connexion
    }
  }

  // Fonction pour récupérer les noms des planètes
  Future<List<String>> fetchPlanetsNames(List<String> planetUrls) async {
    try {
      List<String> planetNames = [];
      for (var url in planetUrls) {
        final fullUrl = url.startsWith('https://') 
            ? url 
            : 'https://swapi.tech/api' + url;

        final response = await http.get(Uri.parse(fullUrl));
        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          planetNames.add(data['result']['properties']['name']);
        } else {
          throw Exception("Erreur lors de la récupération des planètes. Code : ${response.statusCode}");
        }
      }
      return planetNames;
    } catch (e) {
      print("Erreur d'accès aux planètes: $e");
      return [];
    }
  }

  @override
  void initState() {
    super.initState();
    fetchFilms();
  }

  @override
  Widget build(BuildContext context) {
    return films.isEmpty
        ? Center(child: CircularProgressIndicator())
        : ListView.builder(
            padding: EdgeInsets.all(10),
            itemCount: films.length,
            itemBuilder: (context, index) {
              final film = films[index];
              List<String> filmCharacters = filmCharactersCache[film['title']] ?? [];
              List<String> filmPlanets = filmPlanetsCache[film['title']] ?? [];

              return Card(
                margin: EdgeInsets.all(10),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        film['title'] ?? 'Titre inconnu',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 8),
                      Text(
                        "Réalisateur : ${film['director'] ?? 'Inconnu'}",
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        "Producteur : ${film['producer'] ?? 'Inconnu'}",
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        "Date de sortie : ${film['release_date'] ?? 'Inconnue'}",
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 8),
                      // Section des personnages en menu déroulant (accordion)
                      if (film['characters'] != null && film['characters'].isNotEmpty)
                        FutureBuilder<List<String>>(
                          future: fetchCharacterNames(film['characters']),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return Center(child: CircularProgressIndicator());
                            } else if (snapshot.hasError) {
                              return Center(child: Text("Erreur de chargement des personnages"));
                            } else if (snapshot.hasData) {
                              return ExpansionTile(
                                title: Text(
                                  "Personnages",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                children: snapshot.data!.map((character) {
                                  return Card(
                                    color: const Color.fromARGB(255, 20, 0, 46),
                                    child: Padding(
                                      padding: EdgeInsets.all(4.0),
                                      child: Center(
                                        child: Text(
                                          character,
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontSize: 10, // Taille de texte plus petite
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                }).toList(),
                              );
                            } else {
                              return Center(child: Text("Aucun personnage trouvé"));
                            }
                          },
                        ),
                    ],
                  ),
                ),
              );
            },
          );
  }

  // Fonction pour récupérer les noms des personnages depuis leurs URLs
  Future<List<String>> fetchCharacterNames(List<String> characterUrls) async {
    List<String> characterNames = [];
    for (var url in characterUrls) {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        characterNames.add(data['result']['properties']['name']);
      } else {
        print('Erreur de chargement des personnages');
      }
    }
    return characterNames;
  }
}
