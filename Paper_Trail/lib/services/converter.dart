import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:paper_trail/models/currency_rates.dart';

class CurrencyConverterService{
  static const String _key = '8352fc62f7554343a53fc6cdcd736bf4';
  static CurrencyRates? _rates;

  /// Get the response body of fetching the rates of currencies
  static Future<CurrencyRates> get rates async{
    if (_rates != null){
      return _rates!;
    }
    _rates = await fetchRates();
    return _rates!;
  }

  /// access Open Exchange Rates API to get the rates for all currencies with USD as base.
  /// to get the rates of currencies with different base currencies requires an "Unlimited Plan" subscription to the service.
  static Future<CurrencyRates?> fetchRates() async {
    var response = await http.get(Uri.parse('https://openexchangerates.org/api/latest.json?base=USD&app_id=$_key'));
    if(response.statusCode != 200){ // if the status code is not 200, an error has occurred
      return null;
    } else {
      // if there's no error, return all rates
      return ratesFromJson(response.body);
    }
  }
  /// convert the response from fetchRates into a CurrencyRates model which stores every parameter from the response
  static CurrencyRates ratesFromJson(String string){
    return CurrencyRates.fromJson(json.decode(string));
  }

}


