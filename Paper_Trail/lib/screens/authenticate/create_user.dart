import 'package:flutter/material.dart';
import 'package:paper_trail/models/user.dart';
import 'package:paper_trail/screens/authenticate/authenticate.dart';
import 'package:paper_trail/services/database.dart';

/// Widget for creating a user. Requires a name and a starting balance
class CreateUserScreen extends StatefulWidget {
  const CreateUserScreen({super.key});

  @override
  State<CreateUserScreen> createState() => _CreateUserScreenState();
}

class _CreateUserScreenState extends State<CreateUserScreen> {
  final _formKey = GlobalKey<FormState>();
  String name = "";
  double balance = 0.0;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
          decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.background
          ),
          child: Padding(
            padding: const EdgeInsets.only(left: 10, right: 10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Image(image: AssetImage('lib/images/paper_trail_logo.png'),),
                const Text("Welcome to Paper Trail", style: TextStyle(fontSize: 35),),
                const SizedBox(height: 20,),
                const Text(
                  "An app designed to help you keep track of your finances",
                  style: TextStyle(fontSize: 20),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20,),
                const Text(
                  "To get started, please enter your details below",
                  style: TextStyle(fontSize: 15),
                  textAlign: TextAlign.center,
                ),
                Form(
                  key: _formKey,
                  child: Padding(
                    padding: const EdgeInsets.all(15),
                    child: Column(
                      children: [
                        TextFormField(
                          decoration: const InputDecoration(
                              hintText: "Enter your name"
                          ),
                          validator: (value){
                            if(value != null && value.isEmpty){
                              return "I know for a fact your name is not blank";
                            } else {
                              return null;
                            }
                          },
                          onChanged: (value){
                            setState(() {
                              name = value;
                            });
                          },
                        ),
                        const SizedBox(height: 20,),
                        TextFormField(
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          decoration: const InputDecoration(
                              hintText: "Enter initial balance"
                          ),
                          validator: (value){
                            if(value == null || value.isEmpty){
                              return "Amount cannot be empty";
                            }
                            try{
                              double.parse(value);
                            }catch(e){
                              return "Please enter a valid number";
                            }
                            return null;
                          },
                          onChanged: (value){
                            setState(() {
                              balance = double.parse(value);
                            });
                          },
                        ),
                        const SizedBox(height: 20,),
                        ElevatedButton(
                          onPressed: () async {
                            if(_formKey.currentState!.validate()){
                              await DatabaseService.createUser(AppUser(name: name, balance: balance));
                              Navigator.of(context).pop();
                              Navigator.of(context).push(MaterialPageRoute(builder: (context) => const Authenticate()));
                            }
                          },
                          child: const Text("Start")
                        )
                      ],
                    ),
                  ),
                )
              ],
            ),
          )
      ),
    );
  }
}
