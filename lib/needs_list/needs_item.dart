import 'package:flutter/material.dart';
import 'package:synny_space/items_list/items_list.dart';
import 'package:synny_space/model/needs_card.dart';
import 'package:synny_space/model/storage_card.dart';

class NeedsItem extends StatefulWidget {
  NeedsItem({super.key, required this.needItem, required this.onRemoveChild, required this.onCreateNeed});

  NeedsCard needItem;
  Function(StorageCard child) onRemoveChild;
  Function(List<double> listOfStartPoints, List<double> listOfGoals) onCreateNeed;
  @override
  State<NeedsItem> createState() => _NeedsItemState();
}

class _NeedsItemState extends State<NeedsItem> {
  onRemoveItem(StorageCard card) {
    setState(() {
      widget.onRemoveChild(card);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Text(
              widget.needItem.title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, decoration: TextDecoration.underline),
            ),
            Text(widget.needItem.deadline != null
                ? formater.format(widget.needItem.deadline!)
                : ''),
          ],
        ),
        ItemsList(
            isForNeeds: true,
            itemsList: widget.needItem.childrens!,
            removeItem: onRemoveItem,
            onCreateNeed: widget.onCreateNeed,)
      ],
    );
  }
}
