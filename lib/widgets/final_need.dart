import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:synny_space/items_list/final_needs_list.dart';
import 'package:synny_space/model/needs_card.dart';
import 'package:synny_space/model/storage_card.dart';

class FinalNeed extends StatefulWidget {
  FinalNeed(
      {super.key,
      required this.loadedNeeds,
      required this.registeredItems,
      required this.onAddQuantity,
      required this.onRemoveNeed,
      this.isFromAddingNeed,
      this.createdNeedCard});
  bool? isFromAddingNeed;
  NeedsCard? createdNeedCard;
  final List<NeedsCard> loadedNeeds;
  final List<StorageCard> registeredItems;
  final void Function(NeedsCard, int) onAddQuantity;
  final void Function(NeedsCard) onRemoveNeed;

  @override
  State<FinalNeed> createState() => _FinalNeedState();
}

class _FinalNeedState extends State<FinalNeed> {
  //void _loadItemsCards() async {}

  Widget swipeBackground() {
    return Container(
      color: Colors.red,
      child: const Align(
        alignment: Alignment.centerRight,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            Icon(
              Icons.edit,
              color: Colors.white,
            ),
            Text(
              'Delete',
              style: TextStyle(color: Colors.white),
              textAlign: TextAlign.right,
            ),
            SizedBox(
              width: 20,
            ),
          ],
        ),
      ),
    );
  }

  void updateTotalProgres(NeedsCard changedNeedCard) {
    int counter = 0;
    for (final card in widget.loadedNeeds) {
      if (card.parentId == changedNeedCard.parentId) {
        setState(() {
          widget.loadedNeeds[counter] = changedNeedCard;
        });
      }
      counter++;
    }
  }

  Widget totalProgressBar(BuildContext context, int index) {
    NeedsCard needsCardLocal = widget.isFromAddingNeed == null
        ? widget.loadedNeeds[index]
        : widget.createdNeedCard!;
    double sumStartPoints = 0;
    double sumOfGoals = 0;

    for (int i = 0; i < needsCardLocal.childStartPoints!.length; i++) {
      sumStartPoints +=
          double.parse(needsCardLocal.childStartPoints![i].toString());
      sumOfGoals += double.parse(needsCardLocal.childGoals![i].toString());
    }

    double progres = sumStartPoints / sumOfGoals;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
      child: Column(
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('0%'),
              Text('100%'),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.85,
                height: 9,
                child: LinearProgressIndicator(
                  color: const Color.fromARGB(255, 51, 144, 23),
                  borderRadius: BorderRadius.circular(8),
                  value: progres,
                ),
              ),
            ],
          ),
          Text(
            'Загальний прогрес: ${(progres * 100).toStringAsFixed(2)}%',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ],
      ),
    );
  }

  Widget ListsOfItems(int index) {
    NeedsCard needsCardLocal = widget.loadedNeeds[index];
    List<StorageCard> subListOfItems = [];
    List<double> subListOfItemStart = [];
    List<double> subListOfItemGoals = [];
    int counter = 0;
    if (needsCardLocal.childIds != null) {
      for (final id in needsCardLocal.childIds!) {
        for (final item in widget.registeredItems) {
          if (item.id.contains(id)) {
            subListOfItems.add(item);
            subListOfItemStart
                .add(widget.loadedNeeds[index].childStartPoints![counter]);
            subListOfItemGoals
                .add(widget.loadedNeeds[index].childGoals![counter]);
          }
        }
        counter++;
      }
      return FinalNeedsList(
        needsCardLocal: needsCardLocal,
        chosenNeedItems: subListOfItems,
        chosenItemStarts: subListOfItemStart,
        chosenItemGoals: subListOfItemGoals,
        onAddQuantity: widget.onAddQuantity,
        updateTotalProgres: updateTotalProgres,
      );
    }
    return const Text('No items');
  }

  Widget ListFromCreatedItem() {
    List<StorageCard> subListOfItems = [];
    List<double> subListOfItemStart = [];
    List<double> subListOfItemGoals = [];
    int counter = 0;
    if (widget.createdNeedCard!.childIds != null) {
      for (final id in widget.createdNeedCard!.childIds!) {
        for (final item in widget.registeredItems) {
          if (item.id.contains(id)) {
            subListOfItems.add(item);
            subListOfItemStart
                .add(widget.createdNeedCard!.childStartPoints![counter]);
            subListOfItemGoals
                .add(widget.createdNeedCard!.childGoals![counter]);
          }
        }
        counter++;
      }
      return FinalNeedsList(
        needsCardLocal: widget.createdNeedCard!,
        chosenNeedItems: subListOfItems,
        chosenItemStarts: subListOfItemStart,
        chosenItemGoals: subListOfItemGoals,
        onAddQuantity: widget.onAddQuantity,
        updateTotalProgres: updateTotalProgres,
      );
    }
    return const Text('No items');
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: ListView.builder(
          itemCount:
              widget.isFromAddingNeed == null ? widget.loadedNeeds.length : 1,
          key: ValueKey(DateTime.now().millisecondsSinceEpoch),
          scrollDirection: Axis.vertical,
          shrinkWrap: true,
          //physics: const PageScrollPhysics(),
          itemBuilder: (ctx, index) => Dismissible(
                key: ValueKey(widget.loadedNeeds[index]),
                direction: DismissDirection.endToStart,
                background: swipeBackground(),
                confirmDismiss: (direction) async {
                  await showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        content:
                            const Text('You sure you want to delete item?'),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: const Text('Cancel'),
                          ),
                          ElevatedButton.icon(
                            onPressed: () {
                              widget.onRemoveNeed(widget.loadedNeeds[index]);
                              Navigator.of(context).pop();
                            },
                            icon: const Icon(CupertinoIcons.trash),
                            label: const Text('Delete'),
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                foregroundColor: Colors.white),
                          )
                        ],
                      );
                    },
                  );

                  return null;
                },
                onDismissed: (direction) {},
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 30),
                  child: Card.outlined(
                    //color:  Color.fromARGB(61, 166, 95, 2),
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                widget.isFromAddingNeed == null
                                    ? widget.loadedNeeds[index].title
                                    : widget.createdNeedCard!.title,
                                style: const TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.w600),
                              ),
                              Text(widget.isFromAddingNeed == null
                                  ? widget.loadedNeeds[index]
                                              .deadlineInSeconds !=
                                          0
                                      ? ('Залишилось ${DateTime.fromMillisecondsSinceEpoch(widget.loadedNeeds[index].deadlineInSeconds! - DateTime.now().millisecondsSinceEpoch).day} дні')
                                      : 'Без терміну'
                                  : 'Залишилось: ${widget.createdNeedCard!.deadlineInSeconds == null ? '' : widget.createdNeedCard!.deadlineInSeconds!}')
                            ],
                          ),
                        ),
                        widget.loadedNeeds[index].childIds != null
                            ? widget.isFromAddingNeed == null
                                ? ListsOfItems(index)
                                : ListFromCreatedItem()
                            : const Text(''),
                        widget.loadedNeeds[index].childIds != null
                            ? totalProgressBar(context, index)
                            : const Text('')
                      ],
                    ),
                  ),
                ),
              )),
    );
  }
}
