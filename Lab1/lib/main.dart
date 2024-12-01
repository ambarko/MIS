import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Lab1: Obleka App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  HomeScreen({Key? key}) : super(key: key);

  final List<Item> items = [
    Item(
      name: "Маица",
      description: "Маица со лежерен крој, изработена од компактна текстурирана ткаенина. Има кружен изрез, долги ракави и ребрести рабови.",
      price: "1490",
      imagePath:
          "https://static.zara.net/assets/public/70c4/d8fa/3e674257ab3c/9fc416f8058c/00526323251-a4/00526323251-a4.jpg?ts=1731066734734&w=563",
    ),
    Item(
      name: "Јакна",
      description: "Полнета јакна изработена од техничка ткаенина. Висока јака со приспособлива качулка и долги ракави. Паспулирани џебови на колковите и внатрешен џеб. Еластични рабови. Предно закопчување со патент.",
      price: "4590",
      imagePath:
          "https://static.zara.net/assets/public/9fc8/d658/33f147e2844d/e018ec9ea97f/06985322639-a1/06985322639-a1.jpg?ts=1726217702107&w=563",
    ),
    Item(
      name: "Фармерки",
      description: "Straight-leg фармерки со пет џеба. Избледен ефект. Предно закопчување со копчиња.",
      price: "1990",
      imagePath:
          "https://static.zara.net/assets/public/b97e/97f5/bbc64592bfd4/881a97fde3e0/04365310400-a1/04365310400-a1.jpg?ts=1724411138513&w=563",
    ),
    Item(
      name: "Патики",
      description: "Патики во ретро стил. Кожен горен дел од еднобојна кожа со детаљ од велур на врвот. Седум окца на горниот дел за врвки. Контрастен ѓон.",
      price: "2990",
      imagePath:
          "https://static.zara.net/assets/public/6e76/6cc8/49dc4432978c/857f29797122/12281320202-e2/12281320202-e2.jpg?ts=1722335095033&w=563",
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Мартин Амбарков - 193020"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index];
            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DetailsScreen(item: item),
                  ),
                );
              },
              child: Card(
                elevation: 5,
                child: Column(
                  children: [
                    Expanded(
                      child: Image.network(
                        item.imagePath,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(Icons.error, size: 50);
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        item.name,
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class DetailsScreen extends StatelessWidget {
  final Item item;

  const DetailsScreen({Key? key, required this.item}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(item.name),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 1.5,
              child: Image.network(
                item.imagePath,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(Icons.error, size: 50);
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    item.description,
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "Цена: ${item.price} денари",
                    style: const TextStyle(
                      fontSize: 18,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Item {
  final String name;
  final String description;
  final String price;
  final String imagePath;

  Item({
    required this.name,
    required this.description,
    required this.price,
    required this.imagePath,
  });
}
