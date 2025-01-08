import 'package:flutter/material.dart';
import '../models/joke.dart';
import '../services/api_services.dart';

class RandomJokeScreen extends StatefulWidget {
  const RandomJokeScreen({Key? key}) : super(key: key);

  @override
  _RandomJokeScreenState createState() => _RandomJokeScreenState();
}

class _RandomJokeScreenState extends State<RandomJokeScreen> {
  final ApiService _apiService = ApiService();
  Joke? joke;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRandomJoke();
  }

  Future<void> _loadRandomJoke() async {
    setState(() {
      isLoading = true;
    });

    try {
      final randomJoke = await _apiService.getRandomJoke();
      setState(() {
        joke = randomJoke;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Joke of the Day'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadRandomJoke,
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : joke == null
          ? const Center(child: Text('Failed to load joke'))
          : Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                joke!.setup,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                joke!.punchline,
                style: const TextStyle(
                  fontSize: 18,
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}