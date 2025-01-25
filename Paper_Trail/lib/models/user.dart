/// Model for the user. Contains name, balance and a monthly budget value that can be edited.
class AppUser{
  int? id;
  String name;
  double balance;
  double? monthlyBudget;

  AppUser({this.id, required this.name, required this.balance, this.monthlyBudget});

  Map<String, dynamic> toMap(){
    return {
      'name': name,
      'balance': balance,
      'monthlyBudget': monthlyBudget,
    };
  }

  factory AppUser.fromMap(Map<String, dynamic> map){
    return AppUser(
      id: map['id'],
      name: map['name'],
      balance: map['balance'],
      monthlyBudget: map['monthlyBudget']
    );
  }

}