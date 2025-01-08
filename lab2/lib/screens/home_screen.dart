import 'package:flutter/material.dart';
import '../services/api_services.dart';
import '../models/joke.dart';
import '../services/notification_service.dart';
import 'jokes_list_screen.dart';
import 'random_joke_screen.dart';
import 'favorites_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ApiService _apiService = ApiService();
  final NotificationService _notificationService = NotificationService();
  List<String> jokeTypes = [];
  List<Joke> favoriteJokes = [];
  bool notificationsEnabled = false;

  @override
  void initState() {
    super.initState();
    _loadJokeTypes();
    _loadNotificationSettings();
  }
  Future<void> _loadNotificationSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      notificationsEnabled = prefs.getBool('notifications_enabled') ?? false;
    });
  }
  Future<void> _toggleNotifications(bool value) async {
    if (value) {
      // Request permissions before enabling notifications
      final granted = await _notificationService.requestPermissions();
      if (!granted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Notification permissions are required to enable daily jokes'),
          ),
        );
        return;
      }
    }

    final prefs = await SharedPreferences.getInstance();
    setState(() {
      notificationsEnabled = value;
    });
    await prefs.setBool('notifications_enabled', value);

    if (value) {
      await _notificationService.scheduleJokeNotification();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Daily joke notifications enabled!')),
      );
    } else {
      await _notificationService.cancelNotifications();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Notifications disabled')),
      );
    }
  }

  Future<void> _loadJokeTypes() async {
    try {
      final types = await _apiService.getJokeTypes();
      setState(() {
        jokeTypes = types;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
  }

  void _addToFavorites(Joke joke) {
    setState(() {
      if (!favoriteJokes.any((j) => j.id == joke.id)) {
        joke.isFavorite = true;
        favoriteJokes.add(joke);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Added to favorites!')),
        );
      }
    });
  }

  void _removeFromFavorites(Joke joke) {
    setState(() {
      joke.isFavorite = false;
      favoriteJokes.removeWhere((j) => j.id == joke.id);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Removed from favorites!')),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 255, 248, 186),
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 191, 186, 255),
        title: const Text('Joke Types'),
        actions: [
          IconButton(
            icon: Icon(
              notificationsEnabled ? Icons.notifications_active : Icons.notifications_off,
              color: notificationsEnabled ? Colors.yellow : null,
            ),
            onPressed: () {
              _toggleNotifications(!notificationsEnabled);
            },
          ),
          IconButton(
            icon: const Icon(Icons.favorite),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => FavoritesScreen(  // Променето име
                    favoriteJokes: favoriteJokes,
                    onRemoveFavorite: _removeFromFavorites,
                  ),
                ),
              );
            },
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: TextButton.icon(
              icon: const Icon(Icons.shuffle, color: Colors.black),
              label: const Text(
                'Random',
                style: TextStyle(color: Colors.black),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const RandomJokeScreen(),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      body: jokeTypes.isEmpty
          ? const Center(
        child: CircularProgressIndicator(),
      )
          : GridView.builder(
        padding: const EdgeInsets.all(8),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 3/2,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
        ),
        itemCount: jokeTypes.length,
        itemBuilder: (context, index) {
          return Card(
            color: Color.fromARGB(255, 135, 207, 231),
            elevation: 4,
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => JokesListScreen(
                      jokeType: jokeTypes[index],
                      onAddFavorite: _addToFavorites,
                      onRemoveFavorite: _removeFromFavorites,
                    ),
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Theme.of(context).primaryColor.withOpacity(0),
                      Theme.of(context).primaryColor,
                    ],
                  ),
                ),
                child: Center(
                  child: Text(
                    jokeTypes[index].toUpperCase(),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 3, 3, 3),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}