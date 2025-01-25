import 'package:flutter/material.dart';
import 'package:paper_trail/models/budget.dart';
import 'package:paper_trail/models/transaction.dart';
import 'package:paper_trail/models/transaction_type.dart';
import 'package:paper_trail/models/user.dart';
import 'package:paper_trail/services/database.dart';
import 'package:paper_trail/shared/constants.dart';

/// Dialog for creating monthly budget data
class BudgetDialog extends StatefulWidget {
  final VoidCallback onAddBudget;
  const BudgetDialog({super.key, required this.onAddBudget});

  @override
  State<BudgetDialog> createState() => _BudgetDialogState();
}

class _BudgetDialogState extends State<BudgetDialog> {
  final _formKey = GlobalKey<FormState>();
  double amount = 0.0;
  DateTime startDate = DateTime(DateTime.now().year, DateTime.now().month, 1, 0, 0, 0); // creates a budget for the current month with the starting date being the first of the month
  DateTime endDate =  DateTime(DateTime.now().year, DateTime.now().month + 1, 1, 23, 59, 59).subtract(const Duration(days: 1)); // the ending date of the budget is the last day of the current month
  // value obtained by getting the first day of the next month and subtracting one day. accounts for different month lengths

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Monthly budget details"),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const Text(
                "Budget amount",
                style: formPromptTextStyle,
              ),
              TextFormField(
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: (value){
                  if(value == null || value.isEmpty){
                    return "Amount cannot be empty";
                  }
                  try{
                    double parsedValue = double.parse(value);
                    if(parsedValue <= 0){
                      return "Amount must be greater than zero";
                    }
                  }catch(e){
                    return "Please enter a valid number";
                  }
                  return null;
                },
                onChanged: (value){
                  setState(() {
                    amount = double.parse(value);
                  });
                },
              ),
              const SizedBox(height: 20,),
              const Text(
                "The budget starts the first of each month and ends on the last day",
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20,),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () async {
                      if(_formKey.currentState!.validate()){
                        /// Create new budget entry
                        await DatabaseService.createBudgetEntry(BudgetEntry(amount: amount, earned: 0, spent: 0, month: startDate.month, year: startDate.year, startDate: startDate, endDate: endDate));
                        BudgetEntry? budgetEntry = await DatabaseService.getMostRecentBudgetEntry();

                        /// Set the users monthly budget
                        AppUser user = await DatabaseService.getUser();
                        user.monthlyBudget = budgetEntry!.amount;
                        await DatabaseService.updateUser(user);

                        /// Get all previously existing transactions to calculate the sum of all expenses towards the budget
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

                        widget.onAddBudget();
                        Navigator.of(context).pop();
                      }
                    },
                    child: const Text("Confirm")
                  ),
                  ElevatedButton(
                      onPressed: () async {
                        Navigator.of(context).pop();
                      },
                      child: const Text("Cancel")
                  )
                ],
              )
              
            ],
          ),
        ),
      ),
    );
  }
}
