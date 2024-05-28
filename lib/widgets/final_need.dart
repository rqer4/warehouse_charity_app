import 'package:flutter/material.dart';
import 'package:synny_space/items_list/final_needs_list.dart';
import 'package:synny_space/model/needs_card.dart';
import 'package:synny_space/model/storage_card.dart';

class FinalNeed extends StatelessWidget {
  FinalNeed(
      {super.key,
      required this.loadedNeeds,
      required this.registeredItems,
      required this.onAddQuantity,
      this.isFromAddingNeed,
      this.createdNeedCard});
  bool? isFromAddingNeed;
  NeedsCard? createdNeedCard;
  final List<NeedsCard> loadedNeeds;
  final List<StorageCard> registeredItems;
  final void Function(NeedsCard, int) onAddQuantity;

  //void _loadItemsCards() async {}

  Widget ListsOfItems(int index) {
    NeedsCard needsCardLocal = loadedNeeds[index];
    List<StorageCard> subListOfItems = [];
    List<double> subListOfItemStart = [];
    List<double> subListOfItemGoals = [];

    if (needsCardLocal.childIds != null) {
      for (final id in needsCardLocal.childIds!) {
        int counter = 0;
        for (final item in registeredItems) {
          if (item.id.contains(id)) {
            subListOfItems.add(item);
            subListOfItemStart
                .add(loadedNeeds[index].childStartPoints![counter]);
            subListOfItemGoals.add(loadedNeeds[index].childGoals![counter]);
          }
        }
      }
      return FinalNeedsList(
        needsCardLocal: needsCardLocal,
        chosenNeedItems: subListOfItems,
        chosenItemStarts: subListOfItemStart,
        chosenItemGoals: subListOfItemGoals,
        onAddQuantity: onAddQuantity,
      );
    }
    return const Text('No items');
  }

  Widget ListFromCreatedItem() {
    List<StorageCard> subListOfItems = [];
    List<double> subListOfItemStart = [];
    List<double> subListOfItemGoals = [];
    if (createdNeedCard!.childIds != null) {
      for (final id in createdNeedCard!.childIds!) {
        int counter = 0;
        for (final item in registeredItems) {
          if (item.id.contains(id)) {
            subListOfItems.add(item);
            subListOfItemStart.add(createdNeedCard!.childStartPoints![counter]);
            subListOfItemGoals.add(createdNeedCard!.childGoals![counter]);
          }
        }
      }
      return FinalNeedsList(
        needsCardLocal: createdNeedCard!,
        chosenNeedItems: subListOfItems,
        chosenItemStarts: subListOfItemStart,
        chosenItemGoals: subListOfItemGoals,
        onAddQuantity: onAddQuantity,
      );
    }
    return const Text('No items');
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: ListView.builder(
        itemCount: isFromAddingNeed == null ? loadedNeeds.length : 1,
        key: ValueKey(DateTime.now().millisecondsSinceEpoch),
        scrollDirection: Axis.vertical,
        shrinkWrap: true,
        //physics: const PageScrollPhysics(),
        itemBuilder: (context, index) {
          return Card(
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(isFromAddingNeed == null
                        ? loadedNeeds[index].title
                        : createdNeedCard!.title),
                    Text(isFromAddingNeed == null
                        ? '${loadedNeeds[index].deadlineInSeconds == null ? '' : DateTime.fromMillisecondsSinceEpoch(loadedNeeds[index].deadlineInSeconds! - DateTime.now().millisecondsSinceEpoch)}'
                        : '${createdNeedCard!.deadlineInSeconds == null ? '' : DateTime.fromMillisecondsSinceEpoch(createdNeedCard!.deadlineInSeconds!)}')
                  ],
                ),
                isFromAddingNeed == null
                    ? ListsOfItems(index)
                    : ListFromCreatedItem(),
              ],
            ),
          );
        },
      ),
    );
  }
}
