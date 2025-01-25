import 'package:flutter/material.dart';
import 'package:paper_trail/models/budget.dart';
import 'package:paper_trail/models/user.dart';
import 'package:paper_trail/services/database.dart';
import 'package:paper_trail/shared/constants.dart';

/// Dialog for editing the amount of the current months budget
class EditBudgetDialog extends StatefulWidget {
  final double currentBudget;
  final VoidCallback onEditBudget;
  const EditBudgetDialog({super.key, required this.onEditBudget, required this.currentBudget});

  @override
  State<EditBudgetDialog> createState() => _EditBudgetDialogState();
}

class _EditBudgetDialogState extends State<EditBudgetDialog> {
  late double amount;
  final _formKey = GlobalKey<FormState>();

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
                initialValue: widget.currentBudget.toStringAsFixed(2),
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
                "Reminder: The budget starts the first of each month and ends on the last day",
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20,),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                      onPressed: () async {
                        if(_formKey.currentState!.validate()){
                          AppUser user = await DatabaseService.getUser();
                          user.monthlyBudget = amount;
                          await DatabaseService.updateUser(user);
                          BudgetEntry? budgetEntry = await DatabaseService.getMostRecentBudgetEntry();
                          budgetEntry!.amount = amount;
                          await DatabaseService.updateBudgetEntry(budgetEntry);
                          widget.onEditBudget();
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
