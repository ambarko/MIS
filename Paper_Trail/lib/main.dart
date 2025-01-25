import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:paper_trail/models/budget.dart';
import 'package:paper_trail/models/transaction.dart';
import 'package:paper_trail/models/transaction_type.dart';
import 'package:paper_trail/models/user.dart';
import 'package:paper_trail/screens/wrapper/wrapper.dart';
import 'package:paper_trail/services/database.dart';

/// Package name: "com.finki.mis.paper_trail"

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // automatically create budget entries for each month, if a budget is defined by the user
  // get the most recent months budget entry
  BudgetEntry? currentMonthsBudget = await DatabaseService.getMostRecentBudgetEntry();
  // if it is null, there is no budget defined.
  if(currentMonthsBudget!=null){ // else, budget is defined
    // and check if the current date is after the endDate of the budget
    if(DateTime.now().isAfter(currentMonthsBudget.endDate)){
      //if it is, create a new budget entry for the current month

      /// set start and end dates of the new budget
      DateTime startDate = DateTime(DateTime.now().year, DateTime.now().month, 1, 0, 0, 0); // creates a budget for the current month with the starting date being the first of the month
      DateTime endDate =  DateTime(DateTime.now().year, DateTime.now().month + 1, 1, 23, 59, 59).subtract(const Duration(days: 1)); // the ending date of the budget is the last day of the current month
      // value obtained by getting the first day of the next month and subtracting one day. accounts for different month lengths

      /// get the users current monthly budget
      AppUser user = await DatabaseService.getUser();
      double? amount = user.monthlyBudget;

      await DatabaseService.createBudgetEntry(BudgetEntry(amount: amount!, earned: 0, spent: 0, month: startDate.month, year: startDate.year, startDate: startDate, endDate: endDate));
      BudgetEntry? budgetEntry = await DatabaseService.getMostRecentBudgetEntry();

      /// get all previously existing transactions to calculate the sum of all expenses towards the budget
      List<TransactionEntry>? transactionsFromCurrentMonth = await DatabaseService.getAllTransactionBetween(startDate, endDate);
      double spent = 0.0;
      double earned = 0.0;
      if(transactionsFromCurrentMonth!=null){
        for(TransactionEntry transaction in transactionsFromCurrentMonth){
          await DatabaseService.assignTransactionEntryToBudget(transaction, budgetEntry!); // assign a transaction to the months budget
          if(transaction.type == TransactionType.expense){
            spent = spent + transaction.amount;
          } else { // == TransactionType.income
            earned = earned + transaction.amount;
          }
        }
      }

      await DatabaseService.setCurrentBudgetEntryEarned(earned);
      await DatabaseService.setCurrentBudgetEntrySpent(spent);
    }
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Paper Trail',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent),
        primaryColor: Colors.blueAccent,
        useMaterial3: true,
      ),
      home: const Wrapper(),
    );
  }
}