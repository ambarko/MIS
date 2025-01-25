import 'package:flutter/material.dart';
import 'package:paper_trail/models/budget.dart';
import 'package:paper_trail/models/transaction.dart';
import 'package:paper_trail/models/transaction_type.dart';
import 'package:paper_trail/shared/constants.dart';
import 'package:paper_trail/services/database.dart';
import 'package:percent_indicator/percent_indicator.dart';

/// Month by month overview of transactions
class MonthOverview extends StatefulWidget {
  const MonthOverview({super.key});

  @override
  State<MonthOverview> createState() => _MonthOverviewState();
}

class _MonthOverviewState extends State<MonthOverview> {
  int overviewMonth = DateTime.now().month;
  int overviewYear = DateTime.now().year;
  BudgetEntry? budgetEntry = null;
  List<TransactionEntry>? transactions;
  double incomeFromTransactionEntries = 0.0;
  double expenseFromTransactionEntries = 0.0;


  @override
  void initState(){
    super.initState();
    getInitialBudgetEntryByMonthAndYear(overviewMonth, overviewYear);
  }

  // 2 functions below are literally the same, however one has a Future return type and when trying to initialize data, the initState() function can't be async.
  // Which is why the void function directly below is called.
  /// Gets an initial budget entry for displaying transaction data throughout a month. If no budget entry exists for the current month, find all transactions within that month.
  void getInitialBudgetEntryByMonthAndYear(int month, year) async {
    transactions = null; // resets the value of the transactions list to null incase there is a budget entry for the given month/year
    // because if there is, we simply access the spent/earned amounts to get income and expense data. If there isn't, we will have to calculate that value from a list of transactions
    incomeFromTransactionEntries = 0.0;
    expenseFromTransactionEntries = 0.0;
    budgetEntry = await DatabaseService.getBudgetEntryByMonthAndYear(month, year);
    if(budgetEntry == null){
      DateTime startDate = DateTime(year, month, 1, 0, 0, 0); // creates a budget for the current month with the starting date being the first of the month
      DateTime endDate =  DateTime(year, month + 1, 1, 23, 59, 59).subtract(const Duration(days: 1)); // the ending date of the budget is the last day of the current month
      // value obtained by getting the first day of the next month and subtracting one day. accounts for different month lengths
      transactions = await DatabaseService.getAllTransactionBetween(startDate, endDate);
      if(transactions == null){
      } else {
        for(TransactionEntry transaction in transactions!){
          if(transaction.type == TransactionType.income){
            incomeFromTransactionEntries += transaction.amount;
          } else { // == TransactionType.expense
            expenseFromTransactionEntries += transaction.amount;
          }
        }
      }
    }
    setState((){});
  }

  /// Tries to get a budget entry for a month/year. If it doesn't exist, find all transactions within that month. Used when cycling through months/years to update data
  Future<void> getBudgetEntryByMonthAndYear(int month, int year) async {
    transactions = null; // resets the value of the transactions list to null incase there is a budget entry for the given month/year
    // because if there is, we simply access the spent/earned amounts to get income and expense data. If there isn't, we will have to calculate that value from a list of transactions
    incomeFromTransactionEntries = 0.0;
    expenseFromTransactionEntries = 0.0;
    budgetEntry = await DatabaseService.getBudgetEntryByMonthAndYear(month, year);
    if(budgetEntry == null){
      DateTime startDate = DateTime(year, month, 1, 0, 0, 0); // creates a budget for the current month with the starting date being the first of the month
      DateTime endDate =  DateTime(year, month + 1, 1, 23, 59, 59).subtract(const Duration(days: 1)); // the ending date of the budget is the last day of the current month
      // value obtained by getting the first day of the next month and subtracting one day. accounts for different month lengths
      transactions = await DatabaseService.getAllTransactionBetween(startDate, endDate);
      if(transactions == null){
      } else {
        for(TransactionEntry transaction in transactions!){
          if(transaction.type == TransactionType.income){
            incomeFromTransactionEntries += transaction.amount;
          } else { // == TransactionType.expense
            expenseFromTransactionEntries += transaction.amount;
          }
        }
      }
    }
    setState((){});
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.onInverseSurface,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
        child: Column(
          children: [
            const SizedBox(height: 10,),
            const Text(
              "Overview",
              style: formPromptTextStyle,
            ),
            const SizedBox(height: 10,),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Container(
                  width: 45,
                  height: 45,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                      color: Theme.of(context).colorScheme.onPrimary,
                      onPressed: () async {
                        setState(() {
                          overviewMonth -= 1;
                          if(overviewMonth < 1){
                            overviewMonth = 12;
                            overviewYear -= 1;
                          }
                          setState((){});
                        });
                        await getBudgetEntryByMonthAndYear(overviewMonth, overviewYear);
                        setState((){});
                      },
                      icon: const Icon(Icons.arrow_back_ios_new)
                  ),
                ),
                Text(
                  "$overviewMonth/$overviewYear",
                  style: const TextStyle(
                    fontSize: 20
                  ),
                ),
                Container(
                  width: 45,
                  height: 45,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                      color: Theme.of(context).colorScheme.onPrimary,
                      onPressed: () async {
                        setState(() {
                          overviewMonth += 1;
                          if(overviewMonth > 12){
                            overviewMonth = 1;
                            overviewYear += 1;
                          }
                          setState((){});
                        });
                        await getBudgetEntryByMonthAndYear(overviewMonth, overviewYear);
                        setState((){});
                      },
                      icon: const Icon(Icons.arrow_forward_ios)
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15,),
            budgetEntry != null ?
              Text("Income: ${budgetEntry!.earned.toStringAsFixed(2)}")
                :
              (
                transactions != null ?
                Text("Income: ${incomeFromTransactionEntries.toStringAsFixed(2)}")
                    :
                const Text("No income data exists for this month")
              ),
            budgetEntry != null ?
              Text("Expense: ${budgetEntry!.spent.toStringAsFixed(2)}")
                  :
                (
                  transactions != null ?
                  Text("Expense: ${expenseFromTransactionEntries.toStringAsFixed(2)}")
                      :
                  const Text("No expense data exists for this month")
                ),
            budgetEntry != null ?
              Text("Spent ${((budgetEntry!.spent/budgetEntry!.amount)*100).toStringAsFixed(0)}% of \$${budgetEntry?.amount} budget")
                :
              const Text("No budget data exists for this month"),
            const SizedBox(height: 10,),
            Visibility(
              visible: budgetEntry != null,
              replacement: const SizedBox.shrink(),
              child: LinearPercentIndicator(
                lineHeight: 20,
                percent: budgetEntry != null ? (budgetEntry!.spent < budgetEntry!.amount ? (budgetEntry!.spent/budgetEntry!.amount) : 1.0) : 0,
                backgroundColor: Colors.lightBlue,
                progressColor: Colors.red,
              ),
            ),
            const SizedBox(height: 10,),
          ],
        ),
      ),
    );
  }
}