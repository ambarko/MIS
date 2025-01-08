import 'package:flutter/material.dart';
import '../models/joke.dart';
import '../services/api_services.dart';

class JokesListScreen extends StatefulWidget {
  final String jokeType;
  final Function(Joke) onAddFavorite;
  final Function(Joke) onRemoveFavorite;

  const JokesListScreen({
    Key? key,
    required this.jokeType,
    required this.onAddFavorite,
    required this.onRemoveFavorite,
  }) : super(key: key);

  @override
  _JokesListScreenState createState() => _JokesListScreenState();
}

class _JokesListScreenState extends State<JokesListScreen> {
  final ApiService _apiService = ApiService();
  List<Joke> jokes = [];

  @override
  void initState() {
    super.initState();
    _loadJokes();
  }

  Future<void> _loadJokes() async {
    try {
      final loadedJokes = await _apiService.getJokesByType(widget.jokeType);
      setState(() {
        jokes = loadedJokes;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
  }

  void _toggleFavorite(Joke joke) {
    setState(() {
      joke.isFavorite = !joke.isFavorite;
      if (joke.isFavorite) {
        widget.onAddFavorite(joke);
      } else {
        widget.onRemoveFavorite(joke);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.jokeType} Jokes'),
      ),
      body: ListView.builder(
        itemCount: jokes.length,
        itemBuilder: (context, index) {
          final joke = jokes[index];
          return Card(
            margin: const EdgeInsets.all(8),
            child: ExpansionTile(
              title: Text(joke.setup),
              trailing: IconButton(
                icon: Icon(
                  joke.isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: joke.isFavorite ? Colors.red : null,
                ),
                onPressed: () => _toggleFavorite(joke),
              ),
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    joke.punchline,
                    style: const TextStyle(
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}