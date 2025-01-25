import 'package:flutter/material.dart';
import 'package:paper_trail/models/currency_rates.dart';
import 'package:paper_trail/services/converter.dart';
import 'package:paper_trail/shared/constants.dart';

/// Currency converter that allows the user to check the value of other currencies.
class CurrencyConverter extends StatefulWidget {
  const CurrencyConverter({super.key});

  @override
  State<CurrencyConverter> createState() => _CurrencyConverterState();
}

class _CurrencyConverterState extends State<CurrencyConverter> {

  // while the variables is declared as nullable, an error is thrown that it is not initialized, which is why the redundant initialization is present
  late CurrencyRates? rates = null;
  final _convertUSDFormKey = GlobalKey<FormState>();
  double convertUSDAmount = 0.0;
  late String selectedCurrency;
  double convertedCurrencyAmount = 0.0;
  bool convertUSDFormValidated = false;

  final _convertAnyFormKey = GlobalKey<FormState>();
  double convertAnyAmount = 0.0;
  late String initialCurrency;
  late String newCurrency;
  double convertedAnyCurrencyAmount = 0.0;
  bool convertAnyFormValidated = false;

  @override
  void initState(){
    super.initState();
    fetchRates();
  }

  /// Gets the rates for currencies from the Currency Converter Service
  Future<void> fetchRates() async {
    final CurrencyRates ratesFromResponse = await CurrencyConverterService.rates;
    if (ratesFromResponse != null) {
      setState(() {
        rates = ratesFromResponse;
        selectedCurrency = rates!.rates.keys.first;
        initialCurrency = rates!.rates.keys.firstWhere((element) => element == "USD");
        newCurrency = rates!.rates.keys.firstWhere((element) => element == "EUR");
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return  (rates != null) ? Scaffold(
      body:SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20,),
            /// Convert usd to any currency
            Container(
              color: Theme.of(context).colorScheme.onInverseSurface,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
                child: Form(
                  key: _convertUSDFormKey,
                  child: Column(
                    children: [
                      const Text(
                        "Convert USD to Any currency",
                         style: formPromptTextStyle
                      ),
                      TextFormField(
                        decoration: const InputDecoration(
                            hintText: "Enter amount in USD"
                        ),
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        validator: (value){
                          if(value == null || value.isEmpty){
                            return "Amount cannot be empty";
                          }
                          try{
                            double parsedValue = double.parse(value);
                          }catch(e){
                            return "Please enter a valid number";
                          }
                          return null;
                        },
                        onChanged: (value){
                          setState(() {
                            convertUSDAmount = double.parse(value);
                          });
                        },
                      ),
                      const SizedBox(height: 10,),
                      const Text("Select currency"),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          DropdownButton<String>(
                            value: selectedCurrency,
                            onChanged: (String? newValue) {
                              setState(() {
                                selectedCurrency = newValue!;
                              });
                            },
                            items: rates!.rates.keys.map((String currency) {
                              return DropdownMenuItem<String>(
                                value: currency,
                                child: Text(currency),
                              );
                            }).toList()
                          ),
                          ElevatedButton(
                            onPressed: (){
                              if(_convertUSDFormKey.currentState!.validate()){
                                setState((){
                                  convertedCurrencyAmount = convertUSDAmount * rates!.rates[selectedCurrency]!;
                                  convertUSDFormValidated = true;
                                });
                              } else {
                                convertUSDFormValidated = false;
                              }
                            },
                            child: const Text("Convert"),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10,),
                      Visibility(
                        visible: convertUSDFormValidated,
                        replacement: const SizedBox.shrink(),
                        child: Text(
                          "${convertUSDAmount.toStringAsFixed(2)} USD = $convertedCurrencyAmount $selectedCurrency",
                          style: const TextStyle(
                            fontSize: 17
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              )
            ),
            const SizedBox(height: 20,),
            /// Convert any to any currency
            Container(
                color: Theme.of(context).colorScheme.onInverseSurface,
                child: Padding(
                padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
                child: Form(
                  key: _convertAnyFormKey,
                  child: Column(
                    children: [
                      const Text(
                        "Convert Any currency",
                        style: formPromptTextStyle
                      ),
                      TextFormField(
                        decoration: const InputDecoration(
                          hintText: "Enter amount"
                        ),
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        validator: (value){
                          if(value == null || value.isEmpty){
                            return "Amount cannot be empty";
                          }
                          try{
                            double parsedValue = double.parse(value);
                          }catch(e){
                            return "Please enter a valid number";
                          }
                          return null;
                        },
                        onChanged: (value){
                          setState(() {
                            convertAnyAmount = double.parse(value);
                          });
                        },
                      ),
                      const SizedBox(height: 10,),
                      const Text("Select currency"),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          DropdownButton<String>(
                              value: initialCurrency,
                              onChanged: (String? newValue) {
                                setState(() {
                                  initialCurrency = newValue!;
                                  convertAnyFormValidated = false;
                                });
                              },
                              items: rates!.rates.keys.map((String currency) {
                                return DropdownMenuItem<String>(
                                  value: currency,
                                  child: Text(currency),
                                );
                              }).toList()
                          ),
                          DropdownButton<String>(
                              value: newCurrency,
                              onChanged: (String? newValue) {
                                setState(() {
                                  convertAnyFormValidated = false;
                                  newCurrency = newValue!;
                                });
                              },
                              items: rates!.rates.keys.map((String currency) {
                                return DropdownMenuItem<String>(
                                  value: currency,
                                  child: Text(currency),
                                );
                              }).toList()
                          ),
                          ElevatedButton(
                            onPressed: (){
                              if(_convertAnyFormKey.currentState!.validate()){
                                setState((){
                                  convertedAnyCurrencyAmount = (convertAnyAmount / rates!.rates[initialCurrency]!) * rates!.rates[newCurrency]!;
                                  convertAnyFormValidated = true;
                                });
                              } else {
                                convertAnyFormValidated = false;
                              }
                            },
                            child: const Text("Convert"),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10,),
                      Visibility(
                        visible: convertAnyFormValidated,
                        replacement: const SizedBox.shrink(),
                        child: Text(
                          "${convertAnyAmount.toStringAsFixed(2)} $initialCurrency = $convertedAnyCurrencyAmount $newCurrency",
                          style: const TextStyle(
                              fontSize: 17
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              )
            ),
          ],
        ),
      ),
    ) :
    /// If the data isn't retrieved from the Open Exchange Rate API, or the user isn't connected to the Internet, displays a circular progress indicator with a message
    const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            height: 70,
            width: 70,
            child: CircularProgressIndicator(
              strokeWidth: 7,
            ),
          ),
          SizedBox(height: 20),
          Text("Retrieving data, please wait.", textAlign: TextAlign.center,),
          SizedBox(height: 10,),
          Text("Please make sure you are connected to the internet before accessing this feature", textAlign: TextAlign.center,)
        ],
      ),
    );
  }
}