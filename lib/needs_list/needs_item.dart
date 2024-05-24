import 'package:flutter/material.dart';
import 'package:synny_space/items_list/items_list.dart';
import 'package:synny_space/model/needs_card.dart';
import 'package:synny_space/model/storage_card.dart';

class NeedsItem extends StatefulWidget {
  NeedsItem({
    super.key,
    required this.needItem,
    required this.onRemoveChild
  });

  NeedsCard needItem;
  Function(StorageCard child) onRemoveChild;

  @override
  State<NeedsItem> createState() => _NeedsItemState();
}

class _NeedsItemState extends State<NeedsItem> {
  onRemoveItem(StorageCard card){
    setState(() {
      widget.onRemoveChild(card);
    });
    
  }

  @override
  Widget build(BuildContext context) {
    return Card.outlined(
      child: Column(
        children: [
          Row(
            children: [
              Text(widget.needItem.title),
              Text(widget.needItem.deadline != null
                  ? formater.format(widget.needItem.deadline!)
                  : ''),
            ],
          ),
          Container(constraints: const BoxConstraints(maxHeight: 355) ,child: ItemsList(itemsList: widget.needItem.childrens, removeItem: onRemoveItem))
        ],
        
      ),
    );
  }
}
