// class NumericValue {
//   final String decimal;
//   final List<List<int>> rational;
//   final Map<String, String> fraction;

//   NumericValue({
//     required this.decimal,
//     required this.rational,
//     required this.fraction,
//   });

//   factory NumericValue.fromJson(Map<String, dynamic> json) => NumericValue(
//         decimal: json['decimal'],
//         rational: List<List<int>>.from(
//             json['rational'].map((x) => List<int>.from(x))),
//         fraction: Map.from(json['fraction'])
//             .map((k, v) => MapEntry<String, String>(k, v.toString())),
//       );

//   Map<String, dynamic> toJson() => {
//         'decimal': decimal,
//         'rational': rational,
//         'fraction': fraction,
//       };
// }
