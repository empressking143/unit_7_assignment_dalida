import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_expanded_tile/flutter_expanded_tile.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Future<List<dynamic>> fetchCharacters() async {
    final response = await http.get(Uri.parse('https://www.themealdb.com/api/json/v1/1/search.php?f=a'));

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonData = json.decode(response.body);
      return jsonData['meals']; 
    } else {
      throw Exception('Failed to load characters');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Meal List"),
      ),
      body: FutureBuilder<List<dynamic>>(
        future: fetchCharacters(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No meals found"));
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final character = snapshot.data![index];
                final controller = ExpandedTileController();

                String description = 'This is ${character['strMeal']}, which is a popular dish.';

                return ExpandedTile(
                  controller: controller,
                  title: Row(
                    children: [
                      const Icon(Icons.restaurant),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              character['strMeal'] ?? 'No Name',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  content: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        character['strMealThumb'] != null
                            ? Image.network(character['strMealThumb'])
                            : const SizedBox.shrink(),
                        const SizedBox(height: 8),
                        Text(
                          description, 
                          style: const TextStyle(fontSize: 14, fontStyle: FontStyle.italic),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}