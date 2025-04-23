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
  bool isLoading = false;
  int currentPage = 1;
  final int filmsPerPage = 5; // Nombre de films à charger à chaque fois

  // Fonction pour récupérer les films depuis l'API
  Future<void> fetchFilms() async {
    if (isLoading) return; // Empêche plusieurs chargements simultanés

    setState(() {
      isLoading = true;
    });

    try {
      final response = await http.get(Uri.parse('https://swapi.tech/api/films?page=$currentPage&limit=$filmsPerPage'));

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
            'characters': props['characters'], // Liste des liens vers les personnages
          });
        }

        setState(() {
          films.addAll(tempFilms); // Ajouter les nouveaux films à la liste existante
          currentPage++; // Incrémenter la page actuelle pour la prochaine requête
          isLoading = false;
        });
      } else {
        throw Exception("Erreur lors de la récupération des films. Code : ${response.statusCode}");
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print("Erreur dans la récupération des films : $e");
      // Affiche une alerte pour l'utilisateur si la requête échoue
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
        return data['result']['properties']['name'];  // Retourne le nom du personnage
      } else {
        throw Exception("Erreur lors de la récupération du personnage. Code : ${response.statusCode}");
      }
    } catch (e) {
      print("Erreur d'accès au personnage: $e");
      return 'Erreur d\'accès';  // En cas d'erreur de connexion
    }
  }

  @override
  void initState() {
    super.initState();
    fetchFilms(); // Charger les films au démarrage
  }

  @override
  Widget build(BuildContext context) {
    return films.isEmpty
        ? Center(child: CircularProgressIndicator())
        : Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: EdgeInsets.all(10),
                  itemCount: films.length,
                  itemBuilder: (context, index) {
                    final film = films[index];

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
                              ExpansionTile(
                                title: Text(
                                  "Personnages",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                children: [
                                  LayoutBuilder(
                                    builder: (context, constraints) {
                                      int crossAxisCount = 4;
                                      if (constraints.maxWidth < 600) {
                                        crossAxisCount = 2;  // 2 colonnes pour les petits écrans
                                      } else if (constraints.maxWidth < 1200) {
                                        crossAxisCount = 3;  // 3 colonnes pour les écrans moyens
                                      }

                                      return GridView.builder(
                                        shrinkWrap: true, 
                                        physics: NeverScrollableScrollPhysics(),
                                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                          crossAxisCount: crossAxisCount,
                                          crossAxisSpacing: 3.0,
                                          mainAxisSpacing: 1.0,
                                          childAspectRatio: 2.75,
                                        ),
                                        itemCount: film['characters'].length,
                                        itemBuilder: (context, idx) {
                                          final characterUrl = film['characters'][idx];

                                          return FutureBuilder<String>(
                                            future: fetchCharacterName(characterUrl),
                                            builder: (context, snapshot) {
                                              if (snapshot.connectionState == ConnectionState.waiting) {
                                                return Center(child: CircularProgressIndicator());
                                              } else if (snapshot.hasError) {
                                                return Center(child: Text("Erreur de chargement"));
                                              } else if (!snapshot.hasData) {
                                                return Center(child: Text("Nom inconnu"));
                                              } else {
                                                return Card(
                                                  color: const Color.fromARGB(255, 20, 0, 46),
                                                  child: Center(
                                                    child: Padding(
                                                      padding: EdgeInsets.all(4.0),
                                                      child: Text(
                                                        snapshot.data ?? 'Nom inconnu',
                                                        textAlign: TextAlign.center,
                                                        style: TextStyle(
                                                          fontSize: 10,
                                                          fontWeight: FontWeight.bold,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                );
                                              }
                                            },
                                          );
                                        },
                                      );
                                    },
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              // Afficher un bouton "Charger plus" si ce n'est pas en cours de chargement
              if (!isLoading)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ElevatedButton(
                    onPressed: fetchFilms, // Charger plus de films
                    child: Text("Charger plus"),
                  ),
                ),
              if (isLoading)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: CircularProgressIndicator(),
                ),
            ],
          );
  }
}
