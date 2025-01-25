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
import 'package:toggle_switch/toggle_switch.dart';
import 'package:paper_trail/shared/constants.dart';

/// Widget for adding a new transaction
class TransactionForm extends StatefulWidget {
  final VoidCallback onFormSubmit;
  const TransactionForm({super.key, required this.onFormSubmit});

  @override
  State<TransactionForm> createState() => _TransactionFormState();
}

class _TransactionFormState extends State<TransactionForm> {

  final _formKey = GlobalKey<FormState>();

  TransactionType transactionType = TransactionType.income;
  DateTime timestamp = DateTime.now();
  double amount = 0.0;
  String description = "";
  double? lat;
  double? long;
  String? imagePath;
  RecurringType recurringType = RecurringType.None;

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

  int initialLabelIndex = 0;
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
        imagePath = returnedImage.path;
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
        imagePath = returnedImage.path;
      });
    } else {
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                          lat == null ? const Text("") : Text("Lat: $lat"),
                          long == null ? const Text("") : Text("Long: $long"),
                        ],
                      ),
                      ElevatedButton.icon(
                          onPressed: () async {
                            LocationData? locationData = await LocationService().getLocation();
                            if(locationData != null){
                              setState(() {
                                lat = locationData.latitude;
                                long = locationData.longitude;
                              });
                            }
                          },
                          icon: const Icon(Icons.pin_drop),
                          label: const Text("Add current location to transaction")
                      ),
                      const SizedBox(height: 20,),
                      /// Attach photo to transaction
                      imagePath == null ? const Text("") : const Text("Successfully added image"),
                      Visibility(
                        visible: imagePath != null,
                        replacement: const SizedBox.shrink(),
                        child: imagePath != null ? Image.file(File(imagePath!)) : const SizedBox.shrink(),
                      ),
                      Visibility(
                        visible: (imagePath != null),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            /// Completely remove photo
                            Visibility(
                                visible: (imagePath != null),
                                child: ElevatedButton(
                                  onPressed: (){
                                    setState(() {
                                      imagePath = null;
                                      imagePath = null;
                                    });
                                  },
                                  child: const Text("Remove photo"),
                                )
                            ),
                          ],
                        ),
                      ),
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
                      ElevatedButton(
                          onPressed: () async {
                            if(_formKey.currentState!.validate()){
                              AppUser user = await DatabaseService.getUser();
                              final TransactionEntry newTransaction = TransactionEntry(
                                  userId: user.id!,
                                  type: transactionType,
                                  amount: amount,
                                  description: description,
                                  timestamp: timestamp,
                                  lat: lat,
                                  long: long,
                                  imagePath: imagePath,
                                  recurringType: recurringType);
                              /// Assign transaction to current months budget if it is defined
                              int month = timestamp.month;
                              int year = timestamp.year;
                              BudgetEntry? budgetEntry = await DatabaseService.getBudgetEntryByMonthAndYear(month, year);
                               if(budgetEntry != null) { // month/year has valid entry in budget table
                                newTransaction.budgetId = budgetEntry.id;
                                if(transactionType == TransactionType.income){
                                  await DatabaseService.incrementBudgetEntryEarned(amount, budgetEntry);
                                } else { // == TransactionType.expense
                                  await DatabaseService.incrementBudgetEntrySpent(amount, budgetEntry);
                                }
                              }
                              await DatabaseService.createTransaction(newTransaction);

                              /// Increase user balance with income or decrease with expense
                              if(transactionType == TransactionType.income){
                                user.balance = user.balance + amount;
                              } else { // == TransactionType.expense
                                user.balance = user.balance - amount;
                              }
                              await DatabaseService.updateUser(user);
                              widget.onFormSubmit();
                            }
                          },
                          child: Text("Add ${transactionType == TransactionType.income ? 'Income' : 'Expense'}")
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