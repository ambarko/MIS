class BudgetEntry{
  int? id;
  double amount;
  double earned; // used for easier access to the sum of all income transactions
  double spent; // initially this should be 0 when creating a new months budget, as more expenses are added this amount increases
  int month; // month for which the budget details is assigned
  int year; // year in which the month belongs
  DateTime startDate; // what date the budget started counting
  DateTime endDate; // what time the budget for the month expires

  BudgetEntry({
    this.id,
    required this.amount,
    required this.earned,
    required this.spent,
    required this.month,
    required this.year,
    required this.startDate,
    required this.endDate
  });

  Map<String, dynamic> toMap(){
    return{
      'amount': amount,
      'earned': earned,
      'spent': spent,
      'month': month,
      'year': year,
      'startDate': startDate.millisecondsSinceEpoch,
      'endDate': endDate.millisecondsSinceEpoch
    };
  }

  factory BudgetEntry.fromMap(Map<String, dynamic> map){
    return BudgetEntry(
      id: map['id'],
      earned: map['earned'],
      amount: map['amount'],
      spent: map['spent'],
      month: map['month'],
      year: map['year'],
      startDate: DateTime.fromMillisecondsSinceEpoch(map['startDate']),
      endDate: DateTime.fromMillisecondsSinceEpoch(map['endDate'])
    );
  }

}