import 'package:flutter/material.dart';
import 'package:paper_trail/models/user.dart';
import 'package:paper_trail/screens/authenticate/create_user.dart';
import 'package:paper_trail/screens/home/home.dart';
import 'package:paper_trail/services/database.dart';

/// Widget that checks if a user exists for the app and redirects towards different screens/widgets accordingly. If there is no user created, it redirects to the CreateUserScreen,
/// while if a user account is present it proceeds to the home page.
class Authenticate extends StatefulWidget {
  const Authenticate({super.key});

  @override
  State<Authenticate> createState() => _AuthenticateState();
}

class _AuthenticateState extends State<Authenticate> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<List<AppUser>?>(
        future: DatabaseService.getAllUsers(),
        builder: (BuildContext context, AsyncSnapshot<List<AppUser>?> snapshot) {
          if(snapshot.connectionState == ConnectionState.waiting){
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError){
            return Center(child: Text(snapshot.error.toString()),);
          } else if (snapshot.hasData && snapshot.data != null){ // user exists
            return HomeScreen(
              user: snapshot.data!.first,
            );
          } else { // no user data
            return const CreateUserScreen();
          }
        },
      ),
    );
  }
}


