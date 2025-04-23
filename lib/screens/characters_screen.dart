import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class CharactersScreen extends StatefulWidget {
  @override
  _CharactersScreenState createState() => _CharactersScreenState();
}

class _CharactersScreenState extends State<CharactersScreen> {
  List characters = [];

  // Fonction pour récupérer les personnages depuis l'API
  Future<void> fetchCharacters() async {
    final response = await http.get(Uri.parse('https://swapi.tech/api/people?page=1&limit=10'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      List tempCharacters = [];

      // Pour chaque personnage, faire une requête pour obtenir les détails supplémentaires
      for (var char in data['results']) {
        final charDetailsResponse = await http.get(Uri.parse(char['url']));
        if (charDetailsResponse.statusCode == 200) {
          final charDetails = json.decode(charDetailsResponse.body);
          tempCharacters.add({
            'name': char['name'],
            'height': charDetails['result']['properties']['height'],
            'mass': charDetails['result']['properties']['mass'],
            'hair_color': charDetails['result']['properties']['hair_color'],
            'skin_color': charDetails['result']['properties']['skin_color'],
            'eye_color': charDetails['result']['properties']['eye_color'],
            'birth_year': charDetails['result']['properties']['birth_year'],
            'gender': charDetails['result']['properties']['gender'],
            'uid': char['uid'],
          });
        } else {
          print("Failed to fetch details for character: ${char['name']}");
        }
      }

      setState(() {
        characters = tempCharacters;
      });
    } else {
      throw Exception('Failed to load characters');
    }
  }

  @override
  void initState() {
    super.initState();
    fetchCharacters();
  }

  @override
  Widget build(BuildContext context) {
    // Taille de l'écran
    double screenWidth = MediaQuery.of(context).size.width;

    // Déterminer le nombre de colonnes en fonction de la taille de l'écran
    int crossAxisCount = 2; // Valeur par défaut pour les petits écrans
    if (screenWidth > 1200) {
      crossAxisCount = 4; // 4 colonnes pour les grands écrans
    } else if (screenWidth > 800) {
      crossAxisCount = 3; // 3 colonnes pour les écrans de taille moyenne
    }

    return characters.isEmpty
        ? Center(child: CircularProgressIndicator())
        : GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount, // Nombre de colonnes basé sur la taille de l'écran
              crossAxisSpacing: 10, // Espacement horizontal entre les éléments
              mainAxisSpacing: 10, // Espacement vertical entre les éléments
              childAspectRatio: 0.95, // Rapport largeur/hauteur des cartes
            ),
            itemCount: characters.length,
            itemBuilder: (context, index) {
              final char = characters[index];
              return Card(
                elevation: 5,
                margin: EdgeInsets.all(10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Titre du personnage
                      Text(
                        char['name'],
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.blueAccent,
                        ),
                      ),
                      SizedBox(height: 10),
                      // Masquer les champs vides
                      if (char['height'] != null)
                        Text('Height: ${char['height']} cm', style: TextStyle(color: Colors.grey[700])),
                      if (char['mass'] != null)
                        Text('Mass: ${char['mass']} kg', style: TextStyle(color: Colors.grey[700])),
                      if (char['hair_color'] != null)
                        Text('Hair Color: ${char['hair_color']}', style: TextStyle(color: Colors.grey[700])),
                      if (char['skin_color'] != null)
                        Text('Skin Color: ${char['skin_color']}', style: TextStyle(color: Colors.grey[700])),
                      if (char['eye_color'] != null)
                        Text('Eye Color: ${char['eye_color']}', style: TextStyle(color: Colors.grey[700])),
                      if (char['birth_year'] != null)
                        Text('Birth Year: ${char['birth_year']}', style: TextStyle(color: Colors.grey[700])),
                      if (char['gender'] != null)
                        Text('Gender: ${char['gender']}', style: TextStyle(color: Colors.grey[700])),
                    ],
                  ),
                ),
              );
            },
          );
  }
}
