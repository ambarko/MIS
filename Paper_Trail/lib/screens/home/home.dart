import 'package:flutter/material.dart';
import 'package:paper_trail/models/user.dart';
import 'package:paper_trail/screens/authenticate/authenticate.dart';
import 'package:paper_trail/screens/converter/converter.dart';
import 'package:paper_trail/screens/transactions/add_transaction_form.dart';
import 'package:paper_trail/screens/transactions/all_transactions_list.dart';
import 'package:paper_trail/screens/wallet/wallet.dart';
import 'package:paper_trail/services/database.dart';

/// Home screen containing a navigation bar to move between different screens
class HomeScreen extends StatefulWidget {
  final AppUser user;
  const HomeScreen({super.key, required this.user});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int currentPageIndex = 0;

  late AppUser user;

  @override
  void initState(){
    super.initState();
    user = widget.user;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<AppUser?>(
      future: DatabaseService.getUser(),
      builder: (context, snapshot){
        if(snapshot.hasData && snapshot.data != null){
          user = snapshot.data!;
          return Scaffold(
            bottomNavigationBar: NavigationBar(
              destinations: const [
                NavigationDestination(
                  icon: Icon(Icons.list_alt),
                  label: "Transactions"
                ),
                NavigationDestination(
                  icon: Icon(Icons.add),
                  label: "Add"
                ),
                NavigationDestination(
                  icon: Icon(Icons.account_balance_wallet_outlined),
                  label: "Wallet"
                ),
                NavigationDestination(
                    icon: Icon(Icons.compare_arrows),
                    label: "Converter"
                ),
              ],
              selectedIndex: currentPageIndex,
              onDestinationSelected: (int index){
                setState(() {
                  currentPageIndex = index;
                });
              },
            ),
            appBar: AppBar(
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Hi ${user.name}", style: TextStyle(color: Theme.of(context).colorScheme.background),),
                  Text("Balance: \$${user.balance.toStringAsFixed(2)}", style: TextStyle(color: Theme.of(context).colorScheme.background),)
                ],
              ),
              backgroundColor: Theme.of(context).colorScheme.primary,
            ),
            body: <Widget>[
              /// Transactions page
              TransactionsList(
                  updateUserBalance: (){ // callback function used to refresh the title of the appBar with the new value after deleting a transaction
                    setState(() {});
                  }
              ),
              /// Add new transaction page
              TransactionForm(onFormSubmit: () {
                setState(() {
                  currentPageIndex = 0;
                });
              },),
              /// Monthly budget details
              Wallet(
                user: user,
                onAddBudget: () {
                  setState(() {
                    currentPageIndex = 2;
                  });
                },
              ),
              /// Check currency exchange rates
              const CurrencyConverter(),
            ][currentPageIndex]
          );
        } else {
          return const Authenticate();
        }
      }
    );
  }
}
