import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:paper_trail/models/transaction.dart';
import 'package:paper_trail/models/transaction_type.dart';

/// Stylized Widget for displaying an individual transaction entry
class TransactionListItem extends StatelessWidget {
  final TransactionEntry transaction;
  final VoidCallback showDetails;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  const TransactionListItem({super.key, required this.transaction, required this.onDelete, required this.onEdit, required this.showDetails});
  
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(5),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Theme.of(context).colorScheme.background
        ),
        child: ListTile(
          title: Row(
            children: [
              Text(
                transaction.type == TransactionType.income ? 'Income' : 'Expense',
                style: TextStyle(
                  color: transaction.type == TransactionType.income ? Colors.green : Colors.red
                ),
              ),
              Expanded(
                child: Text("${transaction.type == TransactionType.income ? '+' : '-'}\$${transaction.amount.toStringAsFixed(2)}",textAlign: TextAlign.center,),
              ),
              Text(
                DateFormat('HH:mm').format(transaction.timestamp),
              ),
            ],
          ),
          subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
              Text(transaction.description),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton.icon(
                    onPressed: showDetails,
                    icon: const Icon(Icons.list_alt),
                    label: const Text('Details'),
                  ),
                  TextButton.icon(
                    onPressed: onEdit,
                    icon: const Icon(Icons.edit),
                    label: const Text('Edit'),
                  ),
                  TextButton.icon(
                    onPressed: onDelete,
                    icon: const Icon(Icons.delete),
                    label: const Text('Delete'),
                  ),
                ],
              ),
            ]
          ),
        ),
      ),
    );
  }
}