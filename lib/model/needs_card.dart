
import 'package:intl/intl.dart';
import 'package:synny_space/model/storage_card.dart';

final formater = DateFormat('dd/MM/yyyy');


class NeedsCard{
  NeedsCard({
    required this.parentId,
    required this.title,
    this.childrens,
    this.childIds,
    this.childGoals,
    this.childStartPoints,
    this.deadline,
    this.deadlineInSeconds,

  });
  final String parentId;
  final String title;
  final List<StorageCard>? childrens;
  final DateTime? deadline;
  final int? deadlineInSeconds;
  final List<dynamic>? childIds;
  final List<dynamic>? childGoals;
  final List<dynamic>? childStartPoints;
  String get formatedDate{
    return formater.format(deadline!);
  }

}