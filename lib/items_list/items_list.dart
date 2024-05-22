import 'package:flutter/material.dart';
import 'package:synny_space/items_list/stored_item.dart';
import 'package:synny_space/model/storage_card.dart';

class ItemsList extends StatefulWidget {
  const ItemsList(
      {super.key, required this.itemsList, required this.removeItem});

  final List<StorageCard> itemsList;
  final void Function(StorageCard itemCard) removeItem;

  @override
  State<ItemsList> createState() => _ItemsListState();
}

class _ItemsListState extends State<ItemsList> {

 
  @override
  Widget build(context) {
    return ListView.builder(
      itemCount: widget.itemsList.length,
      itemBuilder: (ctx, index) => Dismissible(
        key: ValueKey(widget.itemsList[index]),
        onDismissed: (direction) {
          widget.removeItem(widget.itemsList[index]);
        },
        child: Padding(
          padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
          child: StoredItem(widget.itemsList[index]),
        ),
      ),
    );
  }
}
