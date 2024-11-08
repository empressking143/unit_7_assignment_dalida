import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_expanded_tile/flutter_expanded_tile.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<dynamic>> staffFuture;

  final String apiUrl = "https://hp-api.onrender.com/api/characters/staff";

  Future<List<dynamic>> fetchStaffData() async {
    final response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to load data");
    }
  }

  @override
  void initState() {
    super.initState();
    staffFuture = fetchStaffData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Unit 7 - API Calls"),
      ),
      body: FutureBuilder<List<dynamic>>(
        future: staffFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          if (snapshot.hasData && snapshot.data != null) {
            return ExpandedTileList.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index, controller) {
                final staffMember = snapshot.data![index];
                final String name = staffMember['name'] ?? 'No name available';
                final String imageUrl = staffMember['image'] ?? '';
                final String description = staffMember['actor'] ?? 'No description available';
                final String species = staffMember['species'] ?? 'Unknown species';
                final String house = staffMember['house'] ?? 'Unknown house';
                final String dateOfBirth = staffMember['dateOfBirth'] ?? 'Unknown date of birth';
                final bool alive = staffMember['alive'] ?? false;

                return ExpandedTile(
                  controller: controller,
                  title: Text(name),
                  leading: imageUrl.isNotEmpty
                      ? Image.network(imageUrl, width: 50, height: 50, fit: BoxFit.cover)
                      : const Icon(Icons.person),
                  content: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      imageUrl.isNotEmpty
                          ? Image.network(imageUrl, height: 150)
                          : const SizedBox.shrink(),
                      const SizedBox(height: 10),
                      Text("Actor: $description"),
                      Text("Species: $species"),
                      Text("House: $house"),
                      Text("Date of Birth: $dateOfBirth"),
                      Text("Status: ${alive ? 'Alive' : 'Deceased'}"),
                    ],
                  ),
                );
              },
            );
          }
          return const Center(child: Text("No data found"));
        },
      ),
    );
  }
}
