import 'package:flutter/material.dart';
import '../services/api_services.dart';
import '../widgets/joke_card.dart';
import 'jokes_list_screen.dart';
import 'random_joke_screen.dart';

class JokeTypesScreen extends StatefulWidget {
  const JokeTypesScreen({super.key});

  @override
  State<JokeTypesScreen> createState() => _JokeTypesScreenState();
}

class _JokeTypesScreenState extends State<JokeTypesScreen> {
  late Future<List<String>> _jokeTypes;

  @override
  void initState() {
    super.initState();
    _jokeTypes = ApiServices.fetchJokeTypes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Joke Types'),
        actions: [
          IconButton(
            icon: const Icon(Icons.lightbulb),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const RandomJokeScreen()),
              );
            },
          ),
        ],
      ),
      body: FutureBuilder<List<String>>(
        future: _jokeTypes,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            final jokeTypes = snapshot.data!;
            return GridView.builder(
              padding: const EdgeInsets.all(10),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 3 / 2,
              ),
              itemCount: jokeTypes.length,
              itemBuilder: (context, index) {
                return JokeCard(
                  title: jokeTypes[index],
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => JokesListScreen(type: jokeTypes[index]),
                      ),
                    );
                  },
                );
              },
            );
          }
        },
      ),
    );
  }
}