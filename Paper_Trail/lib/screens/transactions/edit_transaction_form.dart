import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:location/location.dart';
import 'package:paper_trail/models/budget.dart';
import 'package:paper_trail/models/recurring_type.dart';
import 'package:paper_trail/models/transaction.dart';
import 'package:paper_trail/models/transaction_type.dart';
import 'package:paper_trail/models/user.dart';
import 'package:paper_trail/services/database.dart';
import 'package:paper_trail/services/location.dart';
import 'package:paper_trail/shared/constants.dart';
import 'package:toggle_switch/toggle_switch.dart';

/// Widget for editing existing transaction entry
class TransactionEdit extends StatefulWidget {
  final TransactionEntry transaction;
  const TransactionEdit({super.key, required this.transaction});

  @override
  State<TransactionEdit> createState() => _TransactionEditState();
}

class _TransactionEditState extends State<TransactionEdit> {
  final _formKey = GlobalKey<FormState>();
  late TransactionEntry transaction;
  late int initialLabelIndex;

  @override
  void initState(){
    super.initState();
    transaction = widget.transaction;
    if(transaction.type == TransactionType.income){
      initialLabelIndex = 0;
    } else {
      initialLabelIndex = 1;
    }
    transactionType = transaction.type;
    id = transaction.id!;
    amount = transaction.amount;
    description = transaction.description;
    oldTimestamp = transaction.timestamp;
    timestamp = transaction.timestamp;
    oldLat = transaction.lat;
    oldLong = transaction.long;
    oldImagePath = transaction.imagePath;
    recurringType = transaction.recurringType;
  }

  late int id;
  late TransactionType transactionType;
  late DateTime oldTimestamp; // used to check which month the transaction is in to verify in what months budget it should be counted in
  late DateTime timestamp; // used for date picker and selecting the new date/time of the transaction
  late double amount;
  late String description;
  late double? oldLat;
  late double? oldLong;
  double? newLat;
  double? newLong;
  late String? oldImagePath;
  String? newImagePath;
  late RecurringType recurringType;

  /// Opens a date picker widget to choose the date of a transaction
  Future<DateTime?> pickDate() async {
    final datePicked = await showDatePicker(
      context: context,
      initialDate: timestamp,
      firstDate: DateTime(2022),
      lastDate: DateTime(2078),
    );
    return datePicked;
  }

  /// Opens a time picker widget to choose the time of a transaction
  Future<TimeOfDay?>? pickTime() async {
    final timePicked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: timestamp.hour, minute: timestamp.minute),
    );
    return timePicked;
  }

  /// Toggles the type of transaction between income and expense
  TransactionType toggleTransactionType(int index){
    if(index == 1){
      return TransactionType.expense;
    } else {
      return TransactionType.income;
    }
  }

  /// Opens the gallery to choose a photo to attach to the transaction
  Future pickImageFromGallery() async {
    final returnedImage = await ImagePicker().pickImage(source: ImageSource.gallery);
    if(returnedImage != null){
      setState(() {
        newImagePath = returnedImage.path;
      });
    } else {
      return;
    }
  }

  /// Opens the camera take a photo to attach to the transaction
  Future takePhotoWithCamera() async {
    final returnedImage = await ImagePicker().pickImage(source: ImageSource.camera);
    if(returnedImage != null){
      setState(() {
        newImagePath = returnedImage.path;
      });
    } else {
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Editing transaction"),
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Theme.of(context).colorScheme.background,
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(5),
            child: Container(
                decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.background,
                    borderRadius: BorderRadius.circular(40)
                ),
                child: Form(
                  key: _formKey,
                  child: Padding(
                    padding: const EdgeInsets.all(15),
                    child: Column(
                      children: [
                        /// Toggle between income or expense
                        ToggleSwitch(
                          minWidth: 100,
                          initialLabelIndex: initialLabelIndex,
                          totalSwitches: 2,
                          labels: const ["Income", "Expense"],
                          activeBgColors: const [[Colors.green], [Colors.red]],
                          onToggle: (index){
                            setState(() {
                              initialLabelIndex = index!;
                              transactionType = toggleTransactionType(index);
                            });
                          },
                        ),
                        const SizedBox(height: 20,),
                        /// Choose date and time for the transaction
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            /// Date
                            ElevatedButton.icon(
                              onPressed: () async {
                                DateTime? date = await pickDate();
                                if(date == null) return;
                                setState(() {
                                  timestamp = DateTime(date.year, date.month, date.day, timestamp.hour, timestamp.minute);
                                });
                              },
                              icon: const Icon(Icons.calendar_month),
                              label: Text(DateFormat("dd-MM-yyyy").format(timestamp)),
                            ),
                            /// Time
                            ElevatedButton.icon(
                              onPressed: () async {
                                TimeOfDay? time = await pickTime();
                                if(time == null) return;
                                setState(() {
                                  timestamp = DateTime(timestamp.year, timestamp.month, timestamp.day, time.hour, time.minute);
                                });
                              },
                              icon: const Icon(Icons.access_time),
                              label: Text(DateFormat("HH:mm").format(timestamp)),
                            ),
                          ],
                        ),
                        /// Amount of the transaction
                        const SizedBox(height: 20,),
                        const Text(
                          "Amount",
                          style: formPromptTextStyle,
                        ),
                        TextFormField(
                          initialValue: amount.toStringAsFixed(2),
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          decoration: const InputDecoration(
                              hintText: "Value of the transaction"
                          ),
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
                        /// Description of the transaction
                        const SizedBox(height: 20,),
                        const Text(
                            "Description",
                            style: formPromptTextStyle
                        ),
                        TextFormField(
                          initialValue: transaction.description,
                          decoration: const InputDecoration(
                              hintText: "Short description of the transaction"
                          ),
                          onChanged: (value){
                            setState(() {
                              description = value;
                            });
                          },
                        ),
                        /// Choose recurring type
                        const SizedBox(height: 20,),
                        const Text(
                            "Transaction recurring type:",
                            style: formPromptTextStyle
                        ),
                        DropdownButton(
                            value: recurringType,
                            items: RecurringType.values.map((type) {
                              return DropdownMenuItem<RecurringType>(
                                value: type,
                                child: Text(type.toString().split('.').last),
                              );
                            }).toList(),
                            onChanged: (value){
                              setState(() {
                                recurringType = value!;
                              });
                            }
                        ),
                        /// Attach location to transaction
                        const SizedBox(height: 20,),
                        const Text(
                            "Location",
                            style: formPromptTextStyle
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            newLat == null ? (oldLat == null ? const Text("") : Text("Lat $oldLat")) : Text("Lat: $newLat"),
                            newLong == null ? (oldLong == null ? const Text("") : Text("Lat $oldLong")) : Text("Lat: $newLong"),
                          ],
                        ),
                        ElevatedButton.icon(
                            onPressed: () async {
                              LocationData? locationData = await LocationService().getLocation();
                              if(locationData != null){
                                setState(() {
                                  newLat = locationData.latitude;
                                  newLong = locationData.longitude;
                                });
                              }
                            },
                            icon: const Icon(Icons.pin_drop),
                            label: const Text("Add current location to transaction")
                        ),
                        /// Hidden button to undo location change. Only visible if a new location is set
                        Visibility(
                          visible: ((newLat!=null && newLong!=null) && (oldLat!=null && oldLong!=null)),
                          child: ElevatedButton(
                              onPressed: (){
                                setState(() {
                                  newLat = null;
                                  newLong = null;
                                });
                              },
                              child: const Text("Undo")
                          )
                        ),
                        /// Hidden button to remove location, visible if location data is present
                        Visibility(
                          visible: ((newLat!=null && newLong!=null) || (oldLat!=null && oldLong!=null)),
                          child: ElevatedButton.icon(
                            onPressed: (){
                              setState(() {
                                oldLong = null;
                                oldLat = null;
                                newLong = null;
                                newLat = null;
                              });
                            },
                            icon: const Icon(Icons.highlight_remove_outlined),
                            label: const Text("Remove location data"),
                          ),
                        ),
                        const SizedBox(height: 20,),
                        /// Show attached photo to transaction
                        Visibility(
                          visible: newImagePath != null,
                          replacement: Visibility(
                            visible: oldImagePath != null,
                            replacement: const Text("No image selected"),
                            child: oldImagePath != null ? Image.file(File(oldImagePath!)) : const Text("No image selected"),
                          ),
                          child: newImagePath != null ? Image.file(File(newImagePath!)) : const Text("No image selected"),
                        ),
                        /// Show buttons to remove photo from transaction or undo photo change
                        Visibility(
                          visible: (newImagePath != null || oldImagePath != null),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              /// undo changed photo
                              Visibility(
                                visible: (newImagePath != null && newImagePath != oldImagePath),
                                child: ElevatedButton(
                                  onPressed: (){
                                    setState(() {
                                      newImagePath = null;
                                    });
                                  },
                                  child: const Text("Undo"),
                                ),
                              ),
                              /// Completely remove photo
                              Visibility(
                                visible: (oldImagePath != null),
                                child: ElevatedButton(
                                  onPressed: (){
                                    setState(() {
                                      oldImagePath = null;
                                      newImagePath = null;
                                    });
                                  },
                                  child: const Text("Remove photo"),
                                )
                              ),
                            ],
                          ),
                        ),
                        /// Attach photo to transaction
                        newImagePath == null ? const Text("") : const Text("Successfully added image"),
                        ElevatedButton.icon(
                          onPressed: pickImageFromGallery,
                          label: const Text("Choose image from Gallery"),
                          icon: const Icon(Icons.image_outlined),
                        ),
                        ElevatedButton.icon(
                            onPressed: takePhotoWithCamera,
                            icon: const Icon(Icons.camera_alt_outlined),
                            label: const Text("Take a photo with the Camera")
                        ),
                        const SizedBox(height: 20,),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            /// Confirm current form state
                            ElevatedButton(
                              onPressed: () async {
                                if(_formKey.currentState!.validate()){
                                  /// Retrieve data from database
                                  TransactionEntry? transactionFromDatabase = await DatabaseService.getTransactionById(id); // get the EXACT transaction we're trying to edit, ignoring the one passed as parameter to the widget
                                  final TransactionEntry finalTransaction = transactionFromDatabase!;
                                  AppUser user = await DatabaseService.getUser();

                                  /// Check image path
                                  String? finalImagePath;
                                  if(newImagePath != null || oldImagePath != null){
                                    if(newImagePath == null && oldImagePath != null){
                                      // no change to photo
                                      finalImagePath = oldImagePath;
                                    }
                                    if(newImagePath != null && oldImagePath == null){
                                      // previously no photo, add one now
                                      finalImagePath = newImagePath;
                                    }
                                    if(newImagePath != null && oldImagePath != null){
                                      // photo exists, replace with new
                                      finalImagePath = newImagePath;
                                    }
                                  } // else both are null, which means no photo

                                  /// Check location data
                                  double? finalLat;
                                  double? finalLong;
                                  if((newLat != null && newLong != null) || (oldLat != null && oldLong != null)){
                                    if((newLat == null && newLong == null) && (oldLat != null && oldLong != null)){
                                      // no change to location data
                                      finalLat = oldLat;
                                      finalLong = oldLong;
                                    }
                                    if((newLat != null && newLong != null) && (oldLat == null && oldLong == null)){
                                      // previously no location data, add now
                                      finalLat = newLat;
                                      finalLong = newLong;
                                    }
                                    if((newLat != null && newLong != null) && (oldLat != null && oldLong != null)){
                                      // location data exists, replace with new data
                                      finalLat = newLat;
                                      finalLong = newLong;
                                    }
                                  } // else both are null, which means no location data

                                  /// Adjust values of spent / earned in the table of budget entries
                                  int? budgetId;
                                  if( (timestamp.month == oldTimestamp.month) && (timestamp.year == oldTimestamp.year) ){ // if the new date of the transaction has the same month and year - then they're in the same budget month
                                    int month = timestamp.month;
                                    int year = timestamp.year;
                                    BudgetEntry? budgetEntry = await DatabaseService.getBudgetEntryByMonthAndYear(month, year);
                                    if(budgetEntry != null){ // if the record for budget entry exists, adjust the values of spent/earned accordingly
                                      if(transaction.type == TransactionType.income){
                                        await DatabaseService.subtractBudgetEntryEarned(transaction.amount, budgetEntry!);
                                      } else { // == TransactionType.expense
                                        await DatabaseService.subtractBudgetEntrySpent(transaction.amount, budgetEntry!);
                                      }
                                      if(transactionType == TransactionType.income){
                                        await DatabaseService.incrementBudgetEntryEarned(transaction.amount, budgetEntry!);
                                      } else { // == TransactionType.expense
                                        await DatabaseService.incrementBudgetEntrySpent(transaction.amount, budgetEntry!);
                                      }
                                    } // else it doesn't exist, so no need to adjusting anything
                                  } else { // the new month/year of the transaction is different from the old one.
                                    int oldMonth = oldTimestamp.month;
                                    int oldYear = oldTimestamp.year;
                                    BudgetEntry? oldBudgetEntry = await DatabaseService.getBudgetEntryByMonthAndYear(oldMonth, oldYear);
                                    int month = timestamp.month;
                                    int year = timestamp.year;
                                    BudgetEntry? newBudgetEntry = await DatabaseService.getBudgetEntryByMonthAndYear(month, year);
                                    await DatabaseService.assignTransactionEntryToBudget(transaction, newBudgetEntry);
                                    if(oldBudgetEntry != null && newBudgetEntry == null) { // if only the old entry exists, the new one doesn't
                                      if(transactionType == TransactionType.income){
                                        await DatabaseService.subtractBudgetEntryEarned(transaction.amount, oldBudgetEntry);
                                      } else {
                                        await DatabaseService.subtractBudgetEntrySpent(transaction.amount, oldBudgetEntry);
                                      }
                                    } else if(oldBudgetEntry == null && newBudgetEntry != null) { // if only the new entry exists, the old one doesn't
                                      budgetId = newBudgetEntry.id;
                                      if(transactionType == TransactionType.income){
                                        await DatabaseService.incrementBudgetEntryEarned(transaction.amount, newBudgetEntry);
                                      } else {
                                        await DatabaseService.incrementBudgetEntrySpent(transaction.amount, newBudgetEntry);
                                      }
                                    } else if(oldBudgetEntry != null && newBudgetEntry != null) { // both entries exist
                                      budgetId = newBudgetEntry.id;

                                      if(transactionType == TransactionType.income){
                                        await DatabaseService.subtractBudgetEntryEarned(transaction.amount, oldBudgetEntry);
                                        await DatabaseService.incrementBudgetEntryEarned(transaction.amount, newBudgetEntry);
                                      } else {
                                        await DatabaseService.subtractBudgetEntrySpent(transaction.amount, oldBudgetEntry);
                                        await DatabaseService.incrementBudgetEntrySpent(transaction.amount, newBudgetEntry);
                                      }
                                    } // else neither budget entry exists. nowhere to add or subtract from earned/spent. do nothing.
                                  }

                                  /// Adjust user balance
                                  // removes the value of the transaction from the users total balance
                                  if(transaction.type == TransactionType.income){
                                    user.balance = user.balance - transaction.amount;
                                  } else { // == TransactionType.expense
                                    user.balance = user.balance + transaction.amount;
                                  }
                                  if(transactionType == TransactionType.income){
                                    user.balance = user.balance + amount;
                                  } else { // == TransactionType.expense
                                    user.balance = user.balance - amount;
                                  }
                                  await DatabaseService.updateUser(user);

                                  /// Assign new values to transaction
                                  finalTransaction.budgetId = budgetId;
                                  finalTransaction.type = transactionType;
                                  finalTransaction.amount = amount;
                                  finalTransaction.description = description;
                                  finalTransaction.timestamp = timestamp;
                                  finalTransaction.lat = finalLat;
                                  finalTransaction.long = finalLong;
                                  finalTransaction.imagePath = finalImagePath;
                                  finalTransaction.recurringType = recurringType;

                                  await DatabaseService.updateTransaction(finalTransaction);
                                  Navigator.pop(context);
                                }
                              },
                              child: const Text("Confirm")
                            ),
                            /// Cancel
                            ElevatedButton(
                              onPressed: (){
                                Navigator.of(context).pop();
                              },
                              child: const Text("Cancel")
                            )
                          ],
                        )
                      ],
                    ),
                  ),
                )
            ),
          ),
        )
    );
  }
}
