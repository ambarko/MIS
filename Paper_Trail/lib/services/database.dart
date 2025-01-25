import 'package:paper_trail/models/budget.dart';
import 'package:paper_trail/models/user.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:paper_trail/models/transaction.dart';

class DatabaseService{
  Database? _database;
  static const transactionsTable = "transactions";
  static const userTable = "user";
  static const budgetTable = "monthly_budgets";

  final int _dbVersion = 1;

  Future<Database> _initialize() async{
    final path = await fullPath;
    var database = await openDatabase(
        path,
        version: _dbVersion,
        onCreate: create,
        singleInstance: true
    );
    return database;
  }

  /// Get database file path
  Future<String> get fullPath async {
    const name = 'paper_trail_test.db';
    final path = await getDatabasesPath();
    return join(path, name);
  }

  /// Get the database
  Future<Database> get database async{
    if (_database != null){
      return _database!;
    }
    _database = await _initialize();
    return _database!;
  }

  /// Create tables for all database models
  Future<void> create(Database database, int version) async {
    /// create table for user details
    await database.execute(
        """CREATE TABLE IF NOT EXISTS $userTable (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        balance REAL NOT NULL,
        monthlyBudget REAL
      );"""
    );
    /// create table for budgets
    await database.execute(
        """CREATE TABLE IF NOT EXISTS $budgetTable (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        amount REAL NOT NULL,
        earned REAL NOT NULL,
        spent REAL NOT NULL,
        month INTEGER NOT NULL,
        year INTEGER NOT NULL,
        startDate INTEGER NOT NULL,
        endDate INTEGER NOT NULL
      );"""
    );
    /// create table for transactions
    await database.execute(
        """CREATE TABLE IF NOT EXISTS $transactionsTable (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        budget_id INTEGER,
        type INTEGER NOT NULL,
        amount REAL NOT NULL,
        description TEXT NOT NULL,
        timestamp INTEGER NOT NULL,
        lat REAL,
        long REAL,
        imagePath TEXT,
        recurringType INTEGER NOT NULL,
        FOREIGN KEY (user_id) REFERENCES $userTable(id),
        FOREIGN KEY (budget_id) REFERENCES $budgetTable(id)
      );"""
    );

  }

  // user details CRUD
  /// Create user
  static Future<int> createUser(AppUser user) async {
    final database = await DatabaseService().database;
    return await database.insert(userTable, user.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  /// Update user information
  static Future<int> updateUser(AppUser user) async {
    final database = await DatabaseService().database;
    return await database.update(userTable, user.toMap(), where: 'id = ?', whereArgs: [user.id], conflictAlgorithm: ConflictAlgorithm.replace);
  }

  /// Delete user from database
  static Future<int> deleteUser(AppUser user) async {
    final database = await DatabaseService().database;
    return await database.delete(userTable, where: 'id = ?', whereArgs: [user.id]);
  }

  /// Get all users - technically supposed to return only one, however database.query() returns a list and in this case with one element
  static Future<List<AppUser>?> getAllUsers() async {
    final database = await DatabaseService().database;
    final List<Map<String, dynamic>> maps = await database.query(userTable);
    if(maps.isEmpty){
      return null;
    }
    return List.generate(maps.length, (index) => AppUser.fromMap(maps[index]));
  }

  /// Get singular user info - since the app is meant to have one user per device, get the only user that the list above returns
  static Future<AppUser> getUser() async {
    List<AppUser>? users = await getAllUsers();
    return users!.first;
  }

  // transactions CRUD
  /// Create transaction entry
  static Future<int> createTransaction(TransactionEntry transaction) async {
    final database = await DatabaseService().database;
    return await database.insert(transactionsTable, transaction.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  /// Update transaction entry in database
  static Future<int> updateTransaction(TransactionEntry transaction) async {
    final database = await DatabaseService().database;
    return await database.update(transactionsTable, transaction.toMap(), where: 'id = ?', whereArgs: [transaction.id], conflictAlgorithm: ConflictAlgorithm.replace);
  }

  /// Assign transaction entry to budget entry
  static Future<int> assignTransactionEntryToBudget(TransactionEntry transaction, BudgetEntry? budgetEntry) async {
    transaction.budgetId = budgetEntry?.id;
    return DatabaseService.updateTransaction(transaction);
  }

  /// Delete transaction entry from database
  static Future<int> deleteTransaction(TransactionEntry transaction) async {
    final database = await DatabaseService().database;
    return await database.delete(transactionsTable, where: 'id = ?', whereArgs: [transaction.id]);
  }

  /// Get transaction by id
  static Future<TransactionEntry?> getTransactionById(int id) async {
    final database = await DatabaseService().database;
    List<Map<String, dynamic>> maps = await database.query(
      transactionsTable,
      where: 'id = ?',
      whereArgs: [id]
    );
    if(maps.isEmpty){
      return null;
    }
    return TransactionEntry.fromMap(maps.first);
  }

  /// Get all transactions
  static Future<List<TransactionEntry>?> getAllTransactions() async {
    final database = await DatabaseService().database;
    final List<Map<String, dynamic>> maps = await database.query(transactionsTable);
    if(maps.isEmpty){
      return null;
    }
    return List.generate(maps.length, (index) => TransactionEntry.fromMap(maps[index]));
  }

  /// Get all transactions within one month - the month of the budget
  static Future<List<TransactionEntry>?> getAllTransactionBetween(DateTime startDate, DateTime endDate) async {
    final database = await DatabaseService().database;
    final List<Map<String, dynamic>> maps = await database.query(
      transactionsTable,
      where: 'timestamp >= ? AND timestamp <= ?',
      whereArgs: [startDate.millisecondsSinceEpoch, endDate.millisecondsSinceEpoch]
    );
    if(maps.isEmpty){
      return null;
    }
    return List.generate(maps.length, (index) => TransactionEntry.fromMap(maps[index]));
  }

  /// Get transactions that are assigned to a certain budget entry by the budget id
  static Future<List<TransactionEntry>?> getTransactionsByBudgetId(int id) async {
    final database = await DatabaseService().database;
    final List<Map<String, dynamic>> maps = await database.query(
        transactionsTable,
        where: 'budget_id = ?',
        whereArgs: [id]
    );
    if(maps.isEmpty){
      return null;
    }
    return List.generate(maps.length, (index) => TransactionEntry.fromMap(maps[index]));
  }

  // budget history CRUD
  /// Create new budget history entry
  static Future<int> createBudgetEntry(BudgetEntry budgetEntry) async {
    final database = await DatabaseService().database;
    return await database.insert(budgetTable, budgetEntry.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  /// Update budget history entry
  static Future<int> updateBudgetEntry(BudgetEntry budgetEntry) async {
    final database = await DatabaseService().database;
    return await database.update(budgetTable, budgetEntry.toMap(), where: 'id = ?', whereArgs: [budgetEntry.id], conflictAlgorithm: ConflictAlgorithm.replace);
  }

  /// Update the spent amount of a budget entry in the current budget month
  /// when adding a new expense or editing transaction with the new type being expense, increment the value of spent from the budget by the newValue
  static Future<int> incrementCurrentBudgetEntrySpent(double newValue) async {
    BudgetEntry? budgetEntry = await DatabaseService.getMostRecentBudgetEntry();
    budgetEntry!.spent = budgetEntry.spent + newValue;
    return DatabaseService.updateBudgetEntry(budgetEntry);
  }

  /// Update the spent amount of a budget entry in the current budget month
  /// when removing an expense or editing an expense to now be an income, subtract the spent value from the budget
  static Future<int> subtractCurrentBudgetEntrySpent(double newValue) async {
    BudgetEntry? budgetEntry = await DatabaseService.getMostRecentBudgetEntry();
    budgetEntry!.spent = budgetEntry.spent - newValue;
    return DatabaseService.updateBudgetEntry(budgetEntry);
  }

  /// Update the earned amount of a budget entry in the current budget month
  /// when adding a new income or editing transaction with the new type being income, increment the value of earned from the budget by the newValue
  static Future<int> incrementCurrentBudgetEntryEarned(double newValue) async {
    BudgetEntry? budgetEntry = await DatabaseService.getMostRecentBudgetEntry();
    budgetEntry!.earned = budgetEntry.earned + newValue;
    return DatabaseService.updateBudgetEntry(budgetEntry);
  }

  /// Update the earned amount of a budget entry in the current budget month
  /// when removing an income or editing an income to now be an expense, subtract the spent value from the budget
  static Future<int> subtractCurrentBudgetEntryEarned(double newValue) async {
    BudgetEntry? budgetEntry = await DatabaseService.getMostRecentBudgetEntry();
    budgetEntry!.earned = budgetEntry.earned - newValue;
    return DatabaseService.updateBudgetEntry(budgetEntry);
  }

  /// Set the value of spent to a newValue
  /// used when creating a new budget entry since we already calculate the spent amount from existing expenses when creating the budget
  static Future<int> setCurrentBudgetEntrySpent(double newValue) async {
    BudgetEntry? budgetEntry = await DatabaseService.getMostRecentBudgetEntry();
    budgetEntry!.spent = newValue;
    return DatabaseService.updateBudgetEntry(budgetEntry);
  }

  /// Set the value of spent to a newValue
  /// used when creating a new budget entry since we already calculate the earned amount from existing income transactions when creating the budget
  static Future<int> setCurrentBudgetEntryEarned(double newValue) async {
    BudgetEntry? budgetEntry = await DatabaseService.getMostRecentBudgetEntry();
    budgetEntry!.earned = newValue;
    return DatabaseService.updateBudgetEntry(budgetEntry);
  }

  /// Update the spent amount of a budget entry passed as parameter
  /// when adding a new expense or editing transaction with the new type being expense, increment the value of spent from the budget by the newValue
  static Future<int> incrementBudgetEntrySpent(double newValue, BudgetEntry budgetEntry) async {
    budgetEntry.spent = budgetEntry.spent + newValue;
    return DatabaseService.updateBudgetEntry(budgetEntry);
  }

  /// Update the spent amount of a budget entry passed as parameter
  /// when removing an expense or editing an expense to now be an income, subtract the spent value from the budget
  static Future<int> subtractBudgetEntrySpent(double newValue, BudgetEntry budgetEntry) async {
    budgetEntry.spent = budgetEntry.spent - newValue;
    return DatabaseService.updateBudgetEntry(budgetEntry);
  }

  /// Update the earned amount of a budget entry in a budget entry passed as parameter
  /// when adding a new income or editing transaction with the new type being income, increment the value of earned from the budget by the newValue
  static Future<int> incrementBudgetEntryEarned(double newValue, BudgetEntry budgetEntry) async {
    budgetEntry.earned = budgetEntry.earned + newValue;
    return DatabaseService.updateBudgetEntry(budgetEntry);
  }

  /// Update the earned amount of a budget entry in a budget entry passed as parameter
  /// when removing an income or editing an income to now be an expense, subtract the earned value from the budget
  static Future<int> subtractBudgetEntryEarned(double newValue, BudgetEntry budgetEntry) async {
    budgetEntry.earned = budgetEntry.earned - newValue;
    return DatabaseService.updateBudgetEntry(budgetEntry);
  }

  /// Get most recent budget history entry
  static Future<BudgetEntry?> getMostRecentBudgetEntry() async {
    final database = await DatabaseService().database;
    final List<Map<String, dynamic>> maps = await database.query(budgetTable);
    if(maps.isEmpty){
      return null;
    }
    return BudgetEntry.fromMap(maps.last);
  }

  /// Get budget history entry by month and year
  static Future<BudgetEntry?> getBudgetEntryByMonthAndYear(int month, int year) async {
    final database = await DatabaseService().database;
    final List<Map<String, dynamic>> maps = await database.query(
        budgetTable,
        where: 'month = ? AND year = ?',
        whereArgs: [month, year]
    );
    if(maps.isEmpty){
      return null;
    }
    return BudgetEntry.fromMap(maps.first);
  }

  /// Get all budget history entries
  static Future<List<BudgetEntry>?> getAllBudgetEntries() async {
    final database = await DatabaseService().database;
    final List<Map<String, dynamic>> maps = await database.query(budgetTable);
    if(maps.isEmpty){
      return null;
    }
    return List.generate(maps.length, (index) => BudgetEntry.fromMap(maps[index]));
  }

}