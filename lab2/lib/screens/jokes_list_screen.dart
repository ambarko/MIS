import 'package:flutter/material.dart';
import '../models/joke.dart';
import '../services/api_services.dart';
import '../widgets/joke_card.dart';

class JokesListScreen extends StatelessWidget {
  final String type;

  const JokesListScreen({super.key, required this.type});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('$type jokes'),
      ),
      body: FutureBuilder<List<Joke>>(
        future: ApiServices.fetchJokesByType(type),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            final jokes = snapshot.data!;
            return ListView.builder(
              padding: const EdgeInsets.all(10),
              itemCount: jokes.length,
              itemBuilder: (context, index) {
                return JokeCard(
                  title: jokes[index].setup,
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text(jokes[index].punchline),
                          actions: <Widget>[
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: const Text('Close'),
                            ),
                          ],
                        );
                      },
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
