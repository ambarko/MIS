import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:paper_trail/models/budget.dart';
import 'package:paper_trail/models/transaction.dart';
import 'package:paper_trail/models/user.dart';
import 'package:paper_trail/screens/transactions/all_transactions_list_item.dart';
import 'package:paper_trail/screens/transactions/edit_transaction_form.dart';
import 'package:paper_trail/screens/transactions/transaction_details_dialog.dart';
import 'package:paper_trail/services/database.dart';
import 'package:paper_trail/models/transaction_type.dart';

/// Widget for showing all transactions grouped by the date and the time created
class TransactionsList extends StatefulWidget {
  final VoidCallback updateUserBalance;
  const TransactionsList({super.key, required this.updateUserBalance});

  @override
  State<TransactionsList> createState() => _TransactionsListState();
}

class _TransactionsListState extends State<TransactionsList> {
  Map<DateTime, List<TransactionEntry>> groupTransactionsByDate(List<TransactionEntry> transactions) {
    Map<DateTime, List<TransactionEntry>> groupedTransactions = {};

    for (TransactionEntry transaction in transactions) {
      DateTime date = DateTime(transaction.timestamp.year, transaction.timestamp.month, transaction.timestamp.day);
      if (!groupedTransactions.containsKey(date)) {
        groupedTransactions[date] = [];
      }
      groupedTransactions[date]!.add(transaction);
    }

    return groupedTransactions;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<List<TransactionEntry>?>(
        future: DatabaseService.getAllTransactions(),
        builder: (BuildContext context, AsyncSnapshot<List<TransactionEntry>?> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return Center(child: Text(snapshot.error.toString()));
          } else if (snapshot.hasData && snapshot.data != null) {
            Map<DateTime, List<TransactionEntry>> groupedTransactions = groupTransactionsByDate(snapshot.data!);
            List<DateTime> dates = groupedTransactions.keys.toList();
            dates.sort((a, b) => b.compareTo(a)); /// Sort dates in descending order
            return ListView.builder(
                itemCount: groupedTransactions.length,
                itemBuilder: (context, index) {
                  DateTime date = dates[index];
                  List<TransactionEntry> transactionsForDate = groupedTransactions[date]!;
                  transactionsForDate.sort((a, b) => a.timestamp.compareTo(b.timestamp)); /// Sort transactions within a date in ascending order
                  return Padding(
                      padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.inversePrimary,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Column(
                          children: [
                            ListTile(
                              title:  Row(
                                children: [
                                  Text(DateFormat("MMMM d, y").format(date), style: const TextStyle(fontWeight: FontWeight.bold),),
                                  Expanded(
                                      child: Text(
                                        DateFormat("EEEE").format(date),
                                        style: const TextStyle(fontWeight: FontWeight.bold),
                                        textAlign: TextAlign.right,
                                      )
                                  )
                                ],
                              ),
                            ),
                            ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: transactionsForDate.length,
                              itemBuilder: (context, index) => TransactionListItem(
                                transaction: transactionsForDate[index],
                                onDelete: () async {
                                  AppUser user = await DatabaseService.getUser();

                                  /// Adjust the balance of the user to account for the transaction being removed
                                  if(snapshot.data![index].type == TransactionType.expense){
                                    user.balance = user.balance + snapshot.data![index].amount; // if the transaction was an expense, return the amount back to the user
                                    BudgetEntry? budgetEntry = await DatabaseService.getBudgetEntryByMonthAndYear(snapshot.data![index].timestamp.month, snapshot.data![index].timestamp.year);
                                    if(budgetEntry != null){
                                      await DatabaseService.subtractBudgetEntrySpent(snapshot.data![index].amount, budgetEntry); //remove from spent
                                    }
                                  } else { // == income
                                    user.balance = user.balance - snapshot.data![index].amount; // vice versa
                                    BudgetEntry? budgetEntry = await DatabaseService.getBudgetEntryByMonthAndYear(snapshot.data![index].timestamp.month, snapshot.data![index].timestamp.year);
                                    if(budgetEntry != null){
                                      await DatabaseService.subtractBudgetEntryEarned(snapshot.data![index].amount, budgetEntry);
                                    }
                                  }
                                  await DatabaseService.updateUser(user);
                                  await DatabaseService.deleteTransaction(snapshot.data![index]);
                                  widget.updateUserBalance();
                                  setState((){});
                                },
                                onEdit: () async {
                                  await Navigator.of(context).push(MaterialPageRoute(builder: (context) => TransactionEdit(transaction: transactionsForDate[index])));
                                  widget.updateUserBalance();
                                  setState(() {});
                                },
                                showDetails: () {
                                  showDialog(context: context, builder: (context) => TransactionDetailsDialog(transaction: transactionsForDate[index],));
                                },
                              ),
                            )
                          ],
                        ),
                      )
                  );
                }
            );
          } else {
            return const Center(
              child: Padding(
                padding: EdgeInsets.only(left: 20, right: 20),
                child: Text("No transactions yet. You can start adding them by pressing on \"Add\" below.", textAlign: TextAlign.center,),
              )
            );
          }
        },
      ),
    );
  }
}
