import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:paper_trail/models/recurring_type.dart';
import 'package:paper_trail/models/transaction.dart';
import 'package:paper_trail/models/transaction_type.dart';
import 'package:paper_trail/services/location.dart';

/// Dialog that shows all details of a transaction entry
class TransactionDetailsDialog extends StatelessWidget {
  final TransactionEntry transaction;
  const TransactionDetailsDialog({super.key, required this.transaction});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("${transaction.type == TransactionType.income ? 'Income' : 'Expense'} on ${DateFormat("dd/MM/yyyy").format(transaction.timestamp)}"),
      content: SingleChildScrollView(
        child: Column(
          children: [
            Text("Time: ${DateFormat("HH:mm").format(transaction.timestamp)}"),
            Text("Amount: \$${transaction.amount.toStringAsFixed(2)}"),
            transaction.recurringType == RecurringType.None ? const Text("One time transaction") : Text("${transaction.recurringType.name} transaction"),
            transaction.description != '' ? Text("Description: ${transaction.description}") : const Text("No description provided"),
            transaction.long != null && transaction.lat != null ? ElevatedButton(
              onPressed: (){
                LocationService().openGoogleMaps(transaction.lat!, transaction.long!);
              },
              child: const Text("See location of transaction")
            ) : const Text("No tracked location for this transaction"),
            transaction.imagePath != null ? Image.file(File(transaction.imagePath!)) : const Text("No image available"),
          ],
        ),
      ),
    );
  }
}
