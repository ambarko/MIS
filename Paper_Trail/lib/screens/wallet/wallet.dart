// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:paper_trail/models/budget.dart';
import 'package:paper_trail/models/user.dart';
import 'package:paper_trail/screens/wallet/add_budget_dialog.dart';
import 'package:paper_trail/screens/wallet/edit_budget_dialog.dart';
import 'package:paper_trail/screens/wallet/month_overview.dart';
import 'package:paper_trail/services/database.dart';
import 'package:paper_trail/shared/constants.dart';
import 'package:percent_indicator/percent_indicator.dart';

/// Widget for visualizing users monthly data, with an additional overview on data on a by-month basis
class Wallet extends StatefulWidget {
  final VoidCallback onAddBudget;
  final AppUser user;
  const Wallet({super.key, required this.user, required this.onAddBudget});

  @override
  State<Wallet> createState() => _WalletState();
}

class _WalletState extends State<Wallet> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 20,),
            /// Data for current months budget
            FutureBuilder<BudgetEntry?>(
              future: DatabaseService.getMostRecentBudgetEntry(),
              builder: (BuildContext context, AsyncSnapshot<BudgetEntry?> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                } else if (snapshot.hasError) {
                  return Center(child: Text(snapshot.error.toString()));
                } else {
                  return widget.user.monthlyBudget == null ? // no monthly budget defined
                  Container(
                      color: Theme.of(context).colorScheme.onInverseSurface,
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(10, 5, 10, 5),
                        child: Column(
                          children: [
                            const Row(
                              children: [
                                Text(
                                  "You have no defined monthly budget",
                                  style: TextStyle(
                                      fontSize: 17
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                ElevatedButton(
                                    onPressed: (){
                                      showDialog(context: context, builder: (context) => BudgetDialog(
                                        onAddBudget: widget.onAddBudget,
                                      ));
                                    },
                                    child: const Text("Set one up now")
                                )
                              ],
                            ),
                          ],
                        ),
                      )
                  )
                      :
                  Container(
                      color: Theme.of(context).colorScheme.onInverseSurface,
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(10, 5, 10, 5),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CircularPercentIndicator(
                                  percent: snapshot.data!.spent < snapshot.data!.amount ? (snapshot.data!.spent/snapshot.data!.amount) : 1.0,
                                  lineWidth: 15,
                                  radius: 50,
                                  backgroundColor: Colors.lightBlue,
                                  progressColor: Colors.red,
                                  header: Text("You've spent", style: circularProgressIndicatorTextStyle),
                                  center: Text(
                                    "${((snapshot.data!.spent/snapshot.data!.amount)*100).toStringAsFixed(0)}%",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 25
                                    ),
                                  ),
                                  footer: Text("Of this months budget", style: circularProgressIndicatorTextStyle),
                                  animation: true,
                                ),
                              ],
                            ),
                            Visibility(
                              visible: snapshot.data!.spent > snapshot.data!.amount,
                              replacement: SizedBox.shrink(),
                              child: Text(
                                "You have exceeded this months budget!",
                                style: TextStyle(
                                  color: Colors.red,
                                  fontSize: 17
                                ),
                              )
                            ),
                            Text("Income: \$${snapshot.data!.earned.toStringAsFixed(2)}", style: budgetDetailsTextStyle.copyWith(color: Colors.green),),
                            Text("Expenses: \$${snapshot.data!.spent.toStringAsFixed(2)}", style: budgetDetailsTextStyle.copyWith(color: Colors.redAccent),),
                            Text("This months budget: \$${snapshot.data!.amount.toStringAsFixed(2)}", style: budgetDetailsTextStyle,),
                            snapshot.data!.spent <= snapshot.data!.amount ? Text("You have \$${(snapshot.data!.amount - snapshot.data!.spent).toStringAsFixed(2)} remaining") : SizedBox.shrink(),
                            ElevatedButton(
                              onPressed: (){
                                showDialog(context: context, builder: (context) => EditBudgetDialog(
                                  onEditBudget: widget.onAddBudget,
                                  currentBudget: snapshot.data!.amount,
                                ));
                              },
                              child: Text("Change budget")
                            )
                          ],
                        ),
                      )
                  );
                }
              },
            ),
            SizedBox(height: 20,),
            /// Month by month overview of transactions
            MonthOverview()
          ],
        ),
      ),
    );
  }
}
