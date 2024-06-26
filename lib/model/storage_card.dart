
//import 'package:intl/intl.dart';


enum Cathegory { food, drinks, medicine, hygiene, auto, amunition, canc, electronics,  }

enum MeasureUnit { liters, ml, kg, grams, mg, pcs, pairs, metr, size, tonn }

class StorageCard {
  StorageCard({
    required this.id,
    required this.barcode,
    required this.image,
    required this.quantity,
    required this.title,
    required this.cathegory,
    required this.measureVolume,
    required this.measureUnit,
  }) ;

  final String id;
  final dynamic barcode;
  String title;
  double quantity;
  String image;
  String cathegory;
  double measureVolume;
  String measureUnit;
}
