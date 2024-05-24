
import 'package:intl/intl.dart';
import 'package:synny_space/model/storage_card.dart';

final formater = DateFormat('dd/MM/yyyy');


class NeedsCard{
  NeedsCard({
    required this.parentId,
    required this.title,
    required this.childrens,
    this.price,
    this.deadline,

  });
  final String parentId;
  final String title;
  final List<StorageCard> childrens;
  final DateTime? deadline;
  final int? price;
  String get formatedDate{
    return formater.format(deadline!);
  }

}