import 'package:paper_trail/models/transaction_type.dart';
import 'package:paper_trail/models/recurring_type.dart';

/// Model for the transactions
class TransactionEntry {
  int? id;
  final int userId;
  int? budgetId;
  TransactionType type;
  double amount;
  String description;
  DateTime timestamp;
  double? lat;
  double? long;
  String? imagePath;
  RecurringType recurringType;

  TransactionEntry({
    this.id,
    required this.userId,
    this.budgetId,
    required this.type,
    required this.amount,
    required this.description,
    required this.timestamp,
    this.lat,
    this.long,
    this.imagePath,
    required this.recurringType
  });

  Map<String, dynamic> toMap() {
    return {
      'user_id': userId,
      'budget_id': budgetId,
      'type': type.index,
      'amount': amount,
      'description': description,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'lat': lat,
      'long': long,
      'imagePath': imagePath,
      'recurringType': recurringType.index,
    };
  }

  factory TransactionEntry.fromMap(Map<String, dynamic> map){
    return TransactionEntry(
      id: map['id'],
      userId: map['user_id'],
      budgetId: map['budget_id'],
      type: TransactionType.values[map['type']],
      amount: map['amount'],
      description: map['description'],
      timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp']),
      lat: map['lat'],
      long: map['long'],
      imagePath: map['imagePath'],
      recurringType: RecurringType.values[map['recurringType']],
    );
  }

}