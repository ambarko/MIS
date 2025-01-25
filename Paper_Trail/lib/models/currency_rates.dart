class CurrencyRates{
  /// Disclaimer field from response
  String disclaimer;
  /// License field from response
  String license;
  /// Timestamp field from response
  int timestamp;
  /// Base field from response
  String base;
  /// Map with abbreviated currency names and their rate compared to the USD
  Map<String, double> rates;

  CurrencyRates({
    required this.disclaimer,
    required this.license,
    required this.timestamp,
    required this.base,
    required this.rates
  });

  Map<String, dynamic> toJson(){
    return {
      'disclaimer': disclaimer,
      'license': license,
      'timestamp': timestamp,
      'base': base,
      'rates': Map.from(rates).map((key, value) => MapEntry<String, dynamic>(key, value))
    };
  }

  factory CurrencyRates.fromJson(Map<String, dynamic> map){
    return CurrencyRates(
      disclaimer: map['disclaimer'],
      license: map['license'],
      timestamp: map['timestamp'],
      base: map['base'],
      rates: (map['rates'] as Map<String, dynamic>).map((key, value) {
        if (value is int) {
          return MapEntry(key, value.toDouble());
        }
        return MapEntry(key, value);
      }),
    );
  }


}