
//import 'package:intl/intl.dart';


enum Cathegory { food, drinks, medicine, hygiene, auto, amunition }

enum MeasureUnit { liters, ml, kg, grams, mg, pcs }

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
  final int barcode;
  String title;
  int quantity;
  String image;
  Cathegory cathegory;
  double measureVolume;
  MeasureUnit measureUnit;
}
